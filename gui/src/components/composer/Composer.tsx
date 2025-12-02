import "@/styles/Composer.css";
import useLocalState from "@/state/state";
import spinner from "@/assets/triangles.svg";
import Sigil from "@/components/Sigil";
import { useState, useEffect, useRef, type FormEvent } from "react";
import Snippets, { ReplySnippet } from "./Snippets";
import toast from "react-hot-toast";
import Icon from "@/components/Icon";
import { wait, regexes } from "@/logic/utils";
import { uploadToS3 } from "@/logic/s3";
import type { UserType } from "@/types/nostrill";
import PostPermsEditor, {
  defaultPostPerms,
} from "@/components/permissions/PostPermsEditor";
import Modal from "@/components/modals/Modal";
import type { PostPerms } from "@/components/permissions/PostPermsEditor";
import {
  Maximize2,
  Minimize2,
  Plus,
  Trash2,
  Split,
  Image as ImageIcon,
  Link as LinkIcon,
} from "lucide-react";
import Avatar from "@/components/Avatar";
import S3Browser from "@/components/S3Browser";

function PermsWrapper({
  initialPerms,
  onSave,
}: {
  initialPerms: PostPerms;
  onSave: (p: PostPerms) => void;
}) {
  const [perms, setPerms] = useState(initialPerms);
  return (
    <div
      className="perms-modal-content"
      style={{ padding: "20px", color: "#fff" }}
    >
      <h2>Post Permissions</h2>
      <PostPermsEditor perms={perms} onChange={setPerms} />
      <div
        style={{
          marginTop: "15px",
          display: "flex",
          justifyContent: "flex-end",
        }}
      >
        <button onClick={() => onSave(perms)} className="post-btn">
          Save Permissions
        </button>
      </div>
    </div>
  );
}

interface MediaPreview {
  url: string;
  type: "img" | "vid" | "aud" | "link";
}

function splitText(text: string): string[] {
  const MAX_LENGTH = 280;
  const parts = [];
  let remaining = text;
  while (remaining.length > MAX_LENGTH) {
    let splitIndex = remaining.lastIndexOf(" ", MAX_LENGTH);
    if (splitIndex === -1) splitIndex = MAX_LENGTH;
    parts.push(remaining.slice(0, splitIndex).trim());
    remaining = remaining.slice(splitIndex).trim();
  }
  if (remaining) parts.push(remaining);
  return parts;
}

function Composer({ isAnon }: { isAnon?: boolean }) {
  const {
    api,
    composerData,
    addNotification,
    setComposerData,
    setModal,
    contacts,
    profiles,
    s3,
  } = useLocalState((s) => ({
    api: s.api,
    composerData: s.composerData,
    addNotification: s.addNotification,
    setComposerData: s.setComposerData,
    setModal: s.setModal,
    contacts: s.contacts,
    profiles: s.profiles,
    s3: s.s3,
  }));
  const [input, setInput] = useState("");
  const [isExpanded, setIsExpanded] = useState(false);
  const [isLoading, setLoading] = useState(false);
  const [isUploading, setIsUploading] = useState(false);
  const [perms, setPerms] = useState<PostPerms>(defaultPostPerms);
  const [previews, setPreviews] = useState<MediaPreview[]>([]);
  const [isMaximized, setIsMaximized] = useState(false);
  const [isThreadMode, setIsThreadMode] = useState(false);
  const [threadParts, setThreadParts] = useState<string[]>([]);

  // Autocomplete state
  const [mentionState, setMentionState] = useState<{
    active: boolean;
    query: string;
    type: string;
    start: number;
  } | null>(null);
  const [mentionIndex, setMentionIndex] = useState(0);

  const inputRef = useRef<HTMLTextAreaElement>(null);

  console.log({ composerData });

  // Load draft on mount
  useEffect(() => {
    const draft = localStorage.getItem("trill-draft");
    if (draft) {
      setInput(draft);
      if (draft.trim().length > 0) setIsExpanded(true);
    }
  }, []);

  // Save draft on input change
  useEffect(() => {
    localStorage.setItem("trill-draft", input);
  }, [input]);

  useEffect(() => {
    if (composerData) {
      setIsExpanded(true);
      // Auto-focus input when composer opens
      setTimeout(() => {
        inputRef.current?.focus();
      }, 100);
    }
  }, [composerData]);

  // Detect links in input
  useEffect(() => {
    const words = input.split(/[\s\n]+/);
    const urls = words.filter(
      (w) => w.startsWith("http") || w.startsWith("blob:"),
    );
    const uniqueUrls = [...new Set(urls)];

    const newPreviews: MediaPreview[] = uniqueUrls.map((url) => {
      const { img, vid, aud } = regexes();
      if (img.test(url)) return { url, type: "img" };
      if (vid.test(url)) return { url, type: "vid" };
      if (aud.test(url)) return { url, type: "aud" };
      return { url, type: "link" };
    });

    setPreviews(newPreviews);
  }, [input]);

  // Mention detection
  const checkMention = (text: string, cursor: number) => {
    const textBefore = text.slice(0, cursor);
    // Match @... or ~... at the end of the string, preceded by start or whitespace
    const match = textBefore.match(/(?:^|\s)([@~])([a-z0-9-]*)$/i);
    console.log({ match });
    if (match) {
      // Adjust start index if there was a leading space
      const offset =
        match[0].startsWith(" ") || match[0].startsWith("\n") ? 1 : 0;
      setMentionState({
        active: true,
        type: match[1],
        query: match[2],
        start: match.index! + offset,
      });
      setMentionIndex(0);
    } else {
      setMentionState(null);
    }
  };

  const handleInput = (e: React.FormEvent<HTMLTextAreaElement>) => {
    const val = e.currentTarget.value;
    setInput(val);
    checkMention(val, e.currentTarget.selectionStart);
  };

  // Get filtered users
  const getFilteredUsers = () => {
    if (!mentionState) return [];
    const { query, type } = mentionState;
    const q = query.toLowerCase();

    const matches: Array<{ id: string; display: string; sub: string }> = [];

    // Search contacts
    if (contacts) {
      Object.entries(contacts).forEach(([ship, data]) => {
        const nick = (data as any).nickname || "";
        const matchShip = ship.includes(q);
        const matchNick = nick.toLowerCase().includes(q);

        if (type === "~") {
          if (matchShip) {
            matches.push({ id: ship, display: ship, sub: nick });
          }
        } else {
          if (matchShip || matchNick) {
            matches.push({ id: ship, display: nick || ship, sub: ship });
          }
        }
      });
    }

    // Search profiles
    if (profiles) {
      profiles.forEach((prof, key) => {
        const name = prof.name || "";
        const matchKey = key.includes(q);
        const matchName = name.toLowerCase().includes(q);

        // Avoid duplicates if in contacts
        if (!matches.find((m) => m.id === key)) {
          if (type === "~") {
            if (matchKey) {
              matches.push({ id: key, display: key, sub: name });
            }
          } else {
            if (matchKey || matchName) {
              matches.push({ id: key, display: name || key, sub: key });
            }
          }
        }
      });
    }

    return matches.slice(0, 5);
  };

  const filteredUsers = getFilteredUsers();

  const selectUser = (user: { id: string }) => {
    if (!mentionState) return;
    const { start, query, type } = mentionState;
    // For now, always insert the ship name (ID)
    // If using Nostr, maybe npub? But system uses internal IDs mostly.
    // Let's use the ID (ship or pubkey).
    // If it's an urbit ship, prepend ~ if needed?
    // ID usually has ~ for urbit.

    const toInsert = user.id;
    // const toInsert = user.id.startsWith("~") ? user.id : user.id; // simple

    const before = input.slice(0, start);
    const after = input.slice(start + 1 + query.length); // +1 for @ or ~

    const newVal = before + toInsert + " " + after;
    setInput(newVal);
    setMentionState(null);

    // Restore focus and cursor (approximate)
    setTimeout(() => {
      inputRef.current?.focus();
      const newCursor = before.length + toInsert.length + 1;
      inputRef.current?.setSelectionRange(newCursor, newCursor);
    }, 10);
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (mentionState && filteredUsers.length > 0) {
      if (e.key === "ArrowDown") {
        e.preventDefault();
        setMentionIndex((prev) => (prev + 1) % filteredUsers.length);
      } else if (e.key === "ArrowUp") {
        e.preventDefault();
        setMentionIndex(
          (prev) => (prev - 1 + filteredUsers.length) % filteredUsers.length,
        );
      } else if (e.key === "Enter" || e.key === "Tab") {
        e.preventDefault();
        selectUser(filteredUsers[mentionIndex]);
      } else if (e.key === "Escape") {
        setMentionState(null);
      }
    }
  };

  function openPermsModal(e: React.MouseEvent) {
    e.preventDefault();
    setModal(
      <Modal>
        <PermsWrapper
          initialPerms={perms}
          onSave={(p) => {
            setPerms(p);
            setModal(null);
            toast.success("Permissions updated");
          }}
        />
      </Modal>,
    );
  }

  const handleS3Select = (url: string) => {
    const cursor = inputRef.current?.selectionStart || input.length;
    const textBefore = input.slice(0, cursor);
    const textAfter = input.slice(cursor);
    const newText =
      textBefore +
      (textBefore && !textBefore.endsWith(" ") ? " " : "") +
      url +
      " " +
      textAfter;

    setInput(newText);
    setModal(null);
  };

  const openS3Browser = () => {
    setModal(
      <Modal>
        <S3Browser onSelect={handleS3Select} onClose={() => setModal(null)} />
      </Modal>,
    );
  };

  const handlePaste = async (e: React.ClipboardEvent) => {
    if (e.clipboardData.files.length > 0) {
      const file = e.clipboardData.files[0];
      if (file.type.startsWith("image/") || file.type.startsWith("video/")) {
        e.preventDefault();

        if (s3) {
          setIsUploading(true);
          const toastId = toast.loading("Uploading media...");
          try {
            const url = await uploadToS3(file, s3);

            const cursor = inputRef.current?.selectionStart || input.length;
            const textBefore = input.slice(0, cursor);
            const textAfter = input.slice(cursor);
            const newText =
              textBefore +
              (textBefore && !textBefore.endsWith(" ") ? " " : "") +
              url +
              " " +
              textAfter;

            setInput(newText);
            toast.success("Upload complete", { id: toastId });
          } catch (err) {
            console.error(err);
            toast.error("Upload failed: " + err, { id: toastId });
          } finally {
            setIsUploading(false);
          }
        } else {
          const url = URL.createObjectURL(file);
          const cursor = inputRef.current?.selectionStart || input.length;
          const textBefore = input.slice(0, cursor);
          const textAfter = input.slice(cursor);
          const newText =
            textBefore +
            (textBefore && !textBefore.endsWith(" ") ? " " : "") +
            url +
            " " +
            textAfter;

          setInput(newText);
          toast(
            "Image pasted (local preview only - configure S3 in Groups/Settings for uploads)",
            {
              icon: "⚠️",
              style: {
                borderRadius: "10px",
                background: "#333",
                color: "#fff",
              },
            },
          );
        }
      }
    }
  };

  const startThread = () => {
    const parts = splitText(input);
    setThreadParts(parts);
    setIsThreadMode(true);
    setIsMaximized(true);
  };

  const addThreadPart = () => {
    setThreadParts([...threadParts, ""]);
  };

  const removeThreadPart = (index: number) => {
    const newParts = [...threadParts];
    newParts.splice(index, 1);
    setThreadParts(newParts);
    if (newParts.length === 0) setIsThreadMode(false);
  };

  const updateThreadPart = (index: number, val: string) => {
    const newParts = [...threadParts];
    newParts[index] = val;
    setThreadParts(newParts);
  };

  async function addSimple() {
    if (!api) return; // TODOhandle error
    return await api.addPost(input, perms);
  }

  async function postThread(host: UserType) {
    if (!api) return;
    let lastId = "";
    let rootId = "";

    const our = api.airlock.our;

    for (const [i, part] of threadParts.entries()) {
      if (!part.trim()) continue;

      if (i === 0) {
        await api.addPost(part, perms);
        // Wait and find ID
        await wait(2000); // Give it time
        // Scry own feed to find latest
        // This is a best-effort attempt to link
        if (our) {
          const res = await api.scryFeed(our, null, null, true, false);
          if ("ok" in res) {
            // Assuming first one is latest
            const latest = Object.values(res.ok.feed.feed)[0]; // Might need sorting
            if (latest) {
              lastId = latest.id;
              rootId = latest.id;
            }
          }
        }
      } else {
        if (lastId) {
          await api.addReply(part, host, lastId, rootId, perms);
          await wait(1000);
          // Try to update lastId? For linear thread A->B->C
          // Ideally we find B's ID. But scanning feed again is heavy.
          // If we keep rootId, it's a flat thread (replies to A).
          // Linear thread is better for reading.
          // Let's try to find the new ID if possible, or just fallback to root.
          if (our) {
            const res = await api.scryFeed(our, null, null, true, true); // Include replies
            if ("ok" in res) {
              // We need to find the post we just made.
              // It might be complicated. For prototype, creating a flat thread (all reply to root) is safer/easier.
              // Or linear if we trust timing.
              // Let's stick to: All reply to previous?
              // If we can't get ID, we break chain.
              // Let's just use rootId for all subsequent posts if we can't find intermediate IDs quickly.
              // Actually, let's try linear:
              const feed = Object.values(res.ok.feed.feed).sort(
                (a, b) => b.time - a.time,
              );
              if (
                feed[0] &&
                feed[0].contents[0] &&
                JSON.stringify(feed[0].contents).includes(part.slice(0, 20))
              ) {
                lastId = feed[0].id;
              }
            }
          }
        } else {
          // Fallback: just post as new post
          await api.addPost(part, perms);
          await wait(1000);
        }
      }
    }
    return { ok: true };
  }

  async function addComplex() {
    if (!api) return; // TODOhandle error
    if (!composerData) return;
    const host: UserType =
      "trill" in composerData.post
        ? { urbit: composerData.post.trill.author }
        : "nostr" in composerData.post
          ? { nostr: composerData.post.nostr.pubkey }
          : { urbit: api.airlock.our! };
    const id =
      "trill" in composerData.post
        ? composerData.post.trill.id
        : "nostr" in composerData.post
          ? composerData.post.nostr.eventId
          : "";
    const thread =
      "trill" in composerData.post
        ? composerData.post.trill.thread || composerData.post.trill.id
        : "nostr" in composerData.post
          ? composerData.post.nostr.eventId
          : "";

    const res =
      composerData.type === "reply"
        ? api.addReply(input, host, id, thread, perms)
        : composerData?.type === "quote"
          ? api.addQuote(input, host, id, perms)
          : wait(500);
    return await res;
  }
  async function poast(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (!api) return; // TODOhandle error
    const our = api.airlock.our!;
    setLoading(true);

    let res;
    if (isThreadMode) {
      const host = api.airlock.our ? { urbit: api.airlock.our } : { urbit: "" }; // Fallback
      res = postThread(host);
    } else {
      res = !composerData ? addSimple() : addComplex();
    }

    const ares = await res;
    if (ares) {
      // // Check for mentions in the post (ship names starting with ~)
      const mentions = input.match(/~[a-z-]+/g);
      if (mentions) {
        mentions.forEach((mention) => {
          if (mention !== our) {
            // Don't notify self-mentions
            addNotification({
              type: "mention",
              from: our,
              message: `You mentioned ${mention} in a post`,
            });
          }
        });
      }

      // If this is a reply, add notification
      if (
        composerData?.type === "reply" &&
        composerData.post &&
        "trill" in composerData.post
      ) {
        if (composerData.post.trill.author !== our) {
          addNotification({
            type: "reply",
            from: our,
            message: `You replied to ${composerData.post.trill.author}'s post`,
            postId: composerData.post.trill.id,
          });
        }
      }

      localStorage.removeItem("trill-draft");
      setInput("");
      setThreadParts([]);
      setIsThreadMode(false);
      setIsMaximized(false);
      setPerms(defaultPostPerms); // Reset perms
      setComposerData(null); // Clear composer data after successful post
      toast.success("post sent");
      setLoading(false);
      setIsExpanded(false);
    }
  }
  const placeHolder =
    composerData?.type === "reply"
      ? "Write your reply..."
      : composerData?.type === "quote"
        ? "Add your thoughts..."
        : isAnon
          ? "> be me"
          : "What's going on in Urbit";

  const clearComposer = (e: React.MouseEvent) => {
    e.preventDefault();
    localStorage.removeItem("trill-draft");
    setComposerData(null);
    setInput("");
    setThreadParts([]);
    setIsThreadMode(false);
    setIsExpanded(false);
    setIsMaximized(false);
    setPerms(defaultPostPerms);
  };

  return (
    <form
      id="composer"
      className={`${isExpanded ? "expanded" : ""} ${composerData ? "has-context" : ""} ${isMaximized ? "maximized" : ""}`}
      onSubmit={poast}
    >
      {!isMaximized && (
        <div className="sigil avatar">
          <Sigil patp={api?.airlock.our || ""} size={46} />
        </div>
      )}

      {isMaximized && (
        <button
          type="button"
          className="close-maximized"
          onClick={() => setIsMaximized(false)}
        >
          <Minimize2 size={20} />
        </button>
      )}

      <div className="composer-content">
        {/* Reply snippets appear above input */}
        {composerData && composerData.type === "reply" && (
          <div className="composer-context reply-context">
            <div className="context-header">
              <span className="context-type">
                <Icon name="reply" size={14} /> Replying to
              </span>
              <button
                className="clear-context"
                onClick={clearComposer}
                title="Clear"
                type="button"
              >
                ×
              </button>
            </div>
            <ReplySnippet post={composerData.post} />
          </div>
        )}

        {/* Quote context header above input (without snippet) */}
        {composerData && composerData.type === "quote" && (
          <div className="quote-header">
            <div className="context-header">
              <span className="context-type">
                <Icon name="quote" size={14} /> Quote posting
              </span>
              <button
                className="clear-context"
                onClick={clearComposer}
                title="Clear"
                type="button"
              >
                ×
              </button>
            </div>
          </div>
        )}

        <div className="composer-input-row" style={{ position: "relative" }}>
          {isThreadMode ? (
            <div
              className="thread-editor"
              style={{
                flex: 1,
                display: "flex",
                flexDirection: "column",
                gap: "10px",
              }}
            >
              {threadParts.map((part, i) => (
                <div key={i} style={{ display: "flex", gap: "8px" }}>
                  <textarea
                    value={part}
                    onChange={(e) => updateThreadPart(i, e.target.value)}
                    placeholder={`Part ${i + 1}`}
                    style={{ flex: 1, minHeight: "100px" }}
                  />
                  <button
                    type="button"
                    onClick={() => removeThreadPart(i)}
                    style={{
                      background: "none",
                      border: "none",
                      color: "#666",
                      cursor: "pointer",
                    }}
                  >
                    <Trash2 size={16} />
                  </button>
                </div>
              ))}
              <button
                type="button"
                onClick={addThreadPart}
                style={{
                  alignSelf: "center",
                  display: "flex",
                  alignItems: "center",
                  gap: "4px",
                  background: "transparent",
                  border: "1px dashed #666",
                  color: "#aaa",
                  padding: "8px 16px",
                  borderRadius: "4px",
                  cursor: "pointer",
                }}
              >
                <Plus size={16} /> Add Part
              </button>
            </div>
          ) : (
            <>
              <textarea
                ref={inputRef}
                value={input}
                onInput={handleInput}
                onKeyDown={handleKeyDown}
                onFocus={() => setIsExpanded(true)}
                onPaste={handlePaste}
                placeholder={placeHolder}
                rows={
                  input.split("\n").length > 1
                    ? Math.min(input.split("\n").length, 5)
                    : 1
                }
              />
              {mentionState && filteredUsers.length > 0 && (
                <div
                  className="mention-autocomplete"
                  style={{
                    position: "absolute",
                    bottom: "100%",
                    left: "0",
                    background: "#1a1a1a",
                    border: "1px solid #333",
                    borderRadius: "8px",
                    boxShadow: "0 4px 12px rgba(0,0,0,0.5)",
                    zIndex: 100,
                    maxHeight: "200px",
                    overflowY: "auto",
                    minWidth: "200px",
                  }}
                >
                  {filteredUsers.map((user, i) => (
                    <div
                      key={user.id}
                      onClick={() => selectUser(user)}
                      className={`mention-item ${i === mentionIndex ? "selected" : ""}`}
                      style={{
                        padding: "8px 12px",
                        cursor: "pointer",
                        display: "flex",
                        alignItems: "center",
                        gap: "8px",
                        background:
                          i === mentionIndex ? "#2a9d8f" : "transparent",
                        color: i === mentionIndex ? "#fff" : "#ccc",
                      }}
                    >
                      <Avatar user={user.id} size={24} />
                      <div style={{ display: "flex", flexDirection: "column" }}>
                        <span style={{ fontWeight: 500, fontSize: "0.9em" }}>
                          {user.display}
                        </span>
                        {user.sub !== user.display && (
                          <span style={{ fontSize: "0.75em", opacity: 0.8 }}>
                            {user.sub}
                          </span>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </>
          )}

          <div
            className="composer-controls"
            style={{
              display: "flex",
              flexDirection: isMaximized ? "row" : "column",
              gap: "8px",
              marginTop: "8px",
            }}
          >
            <button
              type="button"
              onClick={openS3Browser}
              className="icon-btn"
              title="Media Library"
              style={{
                background: "transparent",
                border: "none",
                cursor: "pointer",
              }}
            >
              <ImageIcon size={20} color="#888" />
            </button>

            <button
              type="button"
              onClick={openPermsModal}
              className="icon-btn"
              title="Post Permissions"
              style={{
                background: "transparent",
                border: "none",
                cursor: "pointer",
              }}
            >
              <Icon name="settings" size={20} />
            </button>

            {!isMaximized && (
              <button
                type="button"
                onClick={() => setIsMaximized(true)}
                className="icon-btn"
                title="Maximize"
                style={{
                  background: "transparent",
                  border: "none",
                  cursor: "pointer",
                }}
              >
                <Maximize2 size={20} color="#888" />
              </button>
            )}

            {!isThreadMode && input.length > 280 && (
              <button
                type="button"
                onClick={startThread}
                className="icon-btn"
                title="Split into Thread"
                style={{
                  background: "transparent",
                  border: "none",
                  cursor: "pointer",
                  color: "var(--color-accent)",
                }}
              >
                <span style={{ fontSize: "12px", fontWeight: "bold" }}>
                  Split
                </span>
              </button>
            )}
          </div>

          {isLoading || isUploading ? (
            <div className="loading-container">
              {isUploading ? (
                <span style={{ fontSize: "0.8em", marginRight: "10px" }}>
                  Uploading...
                </span>
              ) : null}
              <img src={spinner} />
            </div>
          ) : (
            <button
              type="submit"
              disabled={!isThreadMode && !input.trim()}
              className="post-btn"
            >
              {isThreadMode ? `Post Thread (${threadParts.length})` : "Post"}
            </button>
          )}
        </div>

        {/* Media Previews */}
        {!isThreadMode && previews.length > 0 && (
          <div className="media-preview">
            {previews.map((p, i) => (
              <div key={p.url + i} className="preview-item">
                {p.type === "img" && <img src={p.url} alt="Preview" />}
                {p.type === "vid" && <video src={p.url} controls />}
                {p.type === "aud" && <audio src={p.url} controls />}
                {p.type === "link" && (
                  <div className="link-preview">
                    <LinkIcon size={16} />
                    <span style={{ fontSize: "0.8em", marginLeft: "4px" }}>
                      {p.url.length > 30 ? p.url.slice(0, 27) + "..." : p.url}
                    </span>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}

        {/* Quote snippets appear below input */}
        {composerData && composerData.type === "quote" && (
          <div className="composer-context quote-context">
            <Snippets post={composerData.post} />
          </div>
        )}
      </div>
    </form>
  );
}

export default Composer;
