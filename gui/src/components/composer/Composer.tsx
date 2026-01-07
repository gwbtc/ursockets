import "@/styles/Composer.css";
import useLocalState from "@/state/state";
import spinner from "@/assets/triangles.svg";
import Sigil from "@/components/Sigil";
import { useState, useEffect, useRef, type FormEvent } from "react";
import Snippets, { ReplySnippet } from "./Snippets";
import toast from "react-hot-toast";
import Icon from "@/components/Icon";
import { wait } from "@/logic/utils";
import type { UserType } from "@/types/nostrill";

function Composer({ isAnon }: { isAnon?: boolean }) {
  const { api, composerData, setComposerData } = useLocalState((s) => ({
    api: s.api,
    composerData: s.composerData,
    setComposerData: s.setComposerData,
  }));
  const [input, setInput] = useState("");
  const [isExpanded, setIsExpanded] = useState(false);
  const [isLoading, setLoading] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);

  console.log({ composerData });
  useEffect(() => {
    if (composerData) {
      setIsExpanded(true);
      if (
        composerData.type === "reply" &&
        composerData.post &&
        "trill" in composerData.post
      ) {
      }
      // Auto-focus input when composer opens
      setTimeout(() => {
        inputRef.current?.focus();
      }, 100); // Small delay to ensure the composer is rendered
    }
  }, [composerData]);
  async function addSimple() {
    if (!api) return; // TODOhandle error
    return await api.addPost(input);
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
        ? api.addReply(input, host, id, thread)
        : composerData?.type === "quote"
          ? api.addQuote(input, host, id)
          : wait(500);
    return await res;
  }
  async function poast(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (!api) return; // TODOhandle error
    setLoading(true);
    const res = !composerData ? addSimple() : addComplex();
    if (await res) {
      setInput("");
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
    setComposerData(null);
    setInput("");
    setIsExpanded(false);
  };

  return (
    <form
      id="composer"
      className={`${isExpanded ? "expanded" : ""} ${composerData ? "has-context" : ""}`}
      onSubmit={poast}
    >
      <div className="sigil avatar">
        <Sigil patp={api?.airlock.our || ""} size={46} />
      </div>

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

        <div className="composer-input-row">
          <input
            ref={inputRef}
            value={input}
            onInput={(e) => setInput(e.currentTarget.value)}
            onFocus={() => setIsExpanded(true)}
            placeholder={placeHolder}
          />
          {isLoading ? (
            <img width="40" src={spinner} />
          ) : (
            <button type="submit" disabled={!input.trim()} className="post-btn">
              Post
            </button>
          )}
        </div>

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
