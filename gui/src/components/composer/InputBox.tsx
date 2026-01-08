import type { UserProfile } from "@/types/nostrill";
import type { UrbitContacts } from "@/types/urbit";
import Avatar from "@/components/Avatar";
import { useEffect, useRef, useState, useMemo } from "react";
import { isValidPatp, isValidPatq } from "urbit-ob";

type Props = {
  placeholder: string;
  input: string;
  setInput: (s: string) => void;
  setIsExpanded: (s: boolean) => void;
  contacts: UrbitContacts;
  profiles: Map<string, UserProfile>;
};
type AutoCompleteCandidate = { id: string; display: string; pic: string };

export default function ({
  input,
  setInput,
  setIsExpanded,
  contacts,
  profiles,
  placeholder,
}: Props) {
  // Autocomplete state
  const [mentionState, setMentionState] = useState<{
    active: boolean;
    query: string;
    type: string;
    start: number;
  } | null>(null);
  const [mentionIndex, setMentionIndex] = useState(0);

  const inputRef = useRef<HTMLDivElement>(null);
  // Track last known cursor index to restore if needed, though mostly we rely on live selection
  const cursorRef = useRef<number>(0);

  // Sync external input prop changes (mainly for clearing)
  useEffect(() => {
    if (inputRef.current && input !== inputRef.current.innerText) {
      // Only update if significantly different (e.g. clear) to avoid cursor jumps
      if (input === "") {
        inputRef.current.innerText = "";
      }
    }
  }, [input]);

  // Helper to get caret position relative to text content
  const getCaretIndex = (element: HTMLElement) => {
    let position = 0;
    const isSupported = typeof window.getSelection !== "undefined";
    if (isSupported) {
      const selection = window.getSelection();
      if (selection && selection.rangeCount !== 0) {
        const range = window.getSelection()?.getRangeAt(0);
        const preCaretRange = range?.cloneRange();
        preCaretRange?.selectNodeContents(element);
        preCaretRange?.setEnd(range!.endContainer, range!.endOffset);
        position = preCaretRange?.toString().length || 0;
      }
    }
    return position;
  };

  // Pre-calculate all possible candidates to avoid doing this on every render/keystroke
  // This only runs when contacts or profiles change
  const allCandidates = useMemo(() => {
    const candidates: AutoCompleteCandidate[] = [];
    const seen = new Set<string>();

    // Search contacts
    if (contacts) {
      Object.entries(contacts).forEach(([ship, data]) => {
        if (data && !seen.has(ship)) {
          candidates.push({
            id: ship,
            display: data.nickname || ship,
            pic: data.avatar || "",
          });
          seen.add(ship);
        }
      });
    }

    // Search profiles
    if (profiles) {
      profiles.forEach((prof, key) => {
        if (!seen.has(key)) {
          candidates.push({
            id: key,
            display: prof.name || key,
            pic: prof.picture,
          });
          seen.add(key);
        }
      });
    }
    return candidates;
  }, [contacts, profiles]);

  // Filter candidates based on query
  // This runs on keystroke but is fast because it operates on a flat array
  const mentionCandidates = useMemo(() => {
    if (!mentionState) return [];
    const { query } = mentionState;
    const q = termToPatp(query).toLowerCase(); // Normalize if needed, or just lower

    const matches: AutoCompleteCandidate[] = [];
    let count = 0;
    const MAX_CANDIDATES = 20;

    for (const candidate of allCandidates) {
      if (count >= MAX_CANDIDATES) break;

      const matchId = candidate.id.toLowerCase().includes(q);
      const matchDisplay = candidate.display.toLowerCase().includes(q);

      if (matchId || matchDisplay) {
        matches.push(candidate);
        count++;
      }
    }

    // Always allow exact valid patq or patp if it's not already matched
    // We allow this even if MAX_CANDIDATES is reached.

    // Check patq
    if (
      isValidPatq(q) &&
      !matches.find((m) => m.id === q)
    ) {
      matches.push({ id: q, display: q, pic: "" });
    }

    // Check patp (autofix missing ~)
    const asPatp = q.startsWith("~") ? q : "~" + q;
    if (
      isValidPatp(asPatp) &&
      !matches.find((m) => m.id === asPatp)
    ) {
      matches.push({ id: asPatp, display: asPatp, pic: "" });
    }

    return matches;
  }, [mentionState, allCandidates]);

  function termToPatp(s: string) {
    return s.startsWith("~") ? s : s;
  }

  // Mention detection
  function checkMention(text: string, cursor: number) {
    const textBefore = text.slice(0, cursor);
    // Match @... or ~... at the end of the string, preceded by start or whitespace
    const match = textBefore.match(/(?:^|\s)([@~])([a-z0-9-]*)$/i);

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
  }

  const handleInput = (e: React.FormEvent<HTMLDivElement>) => {
    const el = e.currentTarget;
    const text = el.innerText;
    setInput(text);

    const cursor = getCaretIndex(el);
    cursorRef.current = cursor;
    checkMention(text, cursor);
  };

  const handlePaste = (e: React.ClipboardEvent) => {
    e.preventDefault();
    const text = e.clipboardData.getData("text/plain");
    document.execCommand("insertText", false, text);
  };

  const selectUser = (user: AutoCompleteCandidate) => {
    if (!mentionState || !inputRef.current) return;

    const sel = window.getSelection();
    if (!sel || sel.rangeCount === 0) return;
    const range = sel.getRangeAt(0);

    // We need to delete the typed query (e.g. @zod) and replace it with a chip
    // This is tricky with DOM ranges because the text might be split across nodes.
    // Simplest reliable way for this specific case:
    // 1. Restore the selection to the end of the query (we know logic start/length).
    // 2. Delete backwards.
    // However, direct range manipulation is better.

    // Let's rely on the mentionState.start logic which is relative to plain text.
    // Actually, since we are contentEditable, simpler is:
    // We know the current cursor is at the end of the mention.
    // We know the length of the query + trigger (1).
    const deleteLength = mentionState.query.length + 1; // +1 for @ or ~

    // Delete the text
    for (let i = 0; i < deleteLength; i++) {
      document.execCommand('delete');
    }

    // Insert the chip
    // We construct the HTML for the chip
    // Note: ID must always be valid patp for Urbit
    const chipLabel = user.id; // Or user.display if we want fancy
    // Using user.id (patp) is safer for now as it's the actual value

    // We use insertHTML to put in our special span
    const chipHtml = `<span contenteditable="false" class="mention-chip" data-id="${user.id}">${user.id}</span>&nbsp;`;
    document.execCommand('insertHTML', false, chipHtml);

    // Update state to match (this might happen automatically via onInput, 
    // but insertHTML sometimes doesn't trigger onInput in React immediately?)
    // Actually execCommand DOES trigger onInput usually.
    // But let's be safe and manually update state if needed, but safer to let onInput handle it 
    // to avoid conflict.

    setMentionState(null);
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLDivElement>) => {
    if (e.key === "Enter" && e.ctrlKey) {
      e.preventDefault();
      // Submit form potentially? Need logic from parent? 
      // The original just did requestSubmit on the form.
      // e.currentTarget is div, closest form?
      // document.forms[0]?.requestSubmit(); // risky
      // For now let's leave it, or passed down prop?
      // original: e.currentTarget.form?.requestSubmit();
      // div doesn't have form property.
      const form = inputRef.current?.closest('form');
      form?.requestSubmit();
    } else if (mentionState && mentionCandidates.length > 0) {
      if (e.key === "ArrowDown") {
        e.preventDefault();
        setMentionIndex((prev) => (prev + 1) % mentionCandidates.length);
      } else if (e.key === "ArrowUp") {
        e.preventDefault();
        setMentionIndex(
          (prev) =>
            (prev - 1 + mentionCandidates.length) % mentionCandidates.length,
        );
      } else if (e.key === "Enter" || e.key === "Tab") {
        e.preventDefault();
        selectUser(mentionCandidates[mentionIndex]);
      } else if (e.key === "Escape") {
        setMentionState(null);
      }
    }
  };

  return (
    <>
      <style>{`
            .mention-chip {
                background-color: #e0f2f1;
                color: #00695c;
                border-radius: 4px;
                padding: 2px 4px;
                margin: 0 2px;
                display: inline-block;
                font-family: monospace;
            }
            .input-editor {
                border: 1px solid #ccc; /* fallback */
                border-radius: 0.5rem;
                padding: 0.75rem;
                min-height: 2.5rem;
                max-height: 8rem;
                overflow-y: auto;
                outline: none;
                white-space: pre-wrap;
                word-wrap: break-word;
            }
            .input-editor:focus {
                border-color: #2a9d8f;
                ring: 2px solid #2a9d8f;
            }
            .input-editor:empty:before {
                content: attr(data-placeholder);
                color: #aaa;
            }
        `}</style>
      <div
        ref={inputRef}
        contentEditable
        className="input-editor w-full bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100"
        onInput={handleInput}
        onKeyDown={handleKeyDown}
        onPaste={handlePaste}
        onFocus={() => setIsExpanded(true)}
        role="textbox"
        tabIndex={0}
        data-placeholder={placeholder}
        suppressContentEditableWarning
      />

      {mentionState && mentionCandidates.length > 0 && (
        <div className="mention-autocomplete">
          {mentionCandidates.map((user, i) => (
            <div
              key={user.id}
              ref={i === mentionIndex ? (el) => el?.scrollIntoView({ block: "nearest" }) : undefined}
              onClick={() => selectUser(user)}
              className={`mention-item ${i === mentionIndex ? "selected" : ""}`}
              style={{
                background: i === mentionIndex ? "#2a9d8f" : "transparent",
                color: i === mentionIndex ? "#fff" : "#ccc",
              }}
            >
              {!user.pic && user.id && user.id[0] === "~" ? (
                <Avatar
                  user={{ urbit: user.id }}
                  size={24}
                  customClass="flex-avatar"
                />
              ) : (
                <div style={{ display: "flex", flexDirection: "column" }}>
                  <span style={{ fontWeight: 500, fontSize: "0.9em" }}>
                    {user.display}
                  </span>
                  {user.id !== user.display && (
                    <span style={{ fontSize: "0.75em", opacity: 0.8 }}>
                      {user.id}
                    </span>
                  )}
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </>
  );
}
