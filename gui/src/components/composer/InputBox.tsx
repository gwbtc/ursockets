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
    // Buckets for sorting
    let exactIdMatch: AutoCompleteCandidate | null = null;
    const exactDisplayMatches: AutoCompleteCandidate[] = [];
    const partialMatches: AutoCompleteCandidate[] = [];

    const MAX_CANDIDATES = 20;

    // Normalize query for ID matching (ensure ~)
    const qRaw = query.toLowerCase().trim();
    if (!qRaw) return [];

    const qPatp = qRaw.startsWith("~") ? qRaw : "~" + qRaw;

    for (const candidate of allCandidates) {
      // Optimization: if we have full buckets, we could stop, but we want the BEST matches
      // A simple O(N) scan is fine for typical contact list sizes (thousands).
      // If we hit a very large limit we might need to break, but sorting requires seeing all relevant ones.
      // Let's break only if we have WAY too many partials (e.g. 100) to keep sorting cheap,
      // but strictly we capped render at 20, filtering should be somewhat aggressive.
      // For now, scan all (safest for correctness).

      const cId = candidate.id.toLowerCase();
      const cDisp = candidate.display.toLowerCase();

      // 1. Exact ID Match (Top Priority)
      if (cId === qPatp || cId === qRaw) {
        exactIdMatch = candidate;
        continue;
      }

      // 2. Exact Display Match (High Priority)
      if (cDisp === qRaw) {
        exactDisplayMatches.push(candidate);
        continue;
      }

      // 3. Partials
      // We only gather partials if we haven't exceeded a safe buffer for sorting
      if (partialMatches.length < 50) {
        const matchId = cId.includes(qRaw);
        const matchDisplay = cDisp.includes(qRaw);

        if (matchId || matchDisplay) {
          partialMatches.push(candidate);
        }
      }
    }

    // Sort partials: Shorter matches first (closeness), then alphabetical
    partialMatches.sort((a, b) => {
      // Preference 1: Starts with query (prefix match)
      const aStarts =
        a.id.toLowerCase().startsWith(qRaw) ||
        a.display.toLowerCase().startsWith(qRaw);
      const bStarts =
        b.id.toLowerCase().startsWith(qRaw) ||
        b.display.toLowerCase().startsWith(qRaw);
      if (aStarts && !bStarts) return -1;
      if (!bStarts && aStarts) return 1;

      // Preference 2: Shorter ID length (closest match)
      // e.g. ~docteg (7) vs ~hostyr-docteg (14)
      if (a.id.length !== b.id.length) return a.id.length - b.id.length;

      // Preference 3: Alphabetical
      return a.id.localeCompare(b.id);
    });

    // Construct final list
    const result: AutoCompleteCandidate[] = [];
    if (exactIdMatch) result.push(exactIdMatch);
    result.push(...exactDisplayMatches);
    result.push(...partialMatches);

    // Cap result
    const cappedResult = result.slice(0, MAX_CANDIDATES);

    // Final check: if exactIdMatch wasn't found in candidates, but q is valid patp, append/prepend logic?
    // User wants exact match on top. If it wasn't in candidates, we should inject it at TOP.
    // Logic: if exactIdMatch is null, AND q is valid, create it.

    if (!exactIdMatch) {
      try {
        // Check explicit qRaw (e.g. ~zod)
        if (isValidPatq(qRaw) || isValidPatp(qRaw)) {
          // Ensure we don't duplicate if it was a display match or partial
          if (!cappedResult.find((c) => c.id === qRaw)) {
            cappedResult.unshift({ id: qRaw, display: qRaw, pic: "" });
          }
        }
        // Check qPatp (e.g. zod -> ~zod)
        else if (qRaw !== qPatp && (isValidPatp(qPatp) || isValidPatq(qPatp))) {
          if (!cappedResult.find((c) => c.id === qPatp)) {
            cappedResult.unshift({ id: qPatp, display: qPatp, pic: "" });
          }
        }
      } catch (e) {
        // urbit-ob functions might throw on invalid input
      }
    }

    return cappedResult;
  }, [mentionState, allCandidates]);



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
      document.execCommand("delete");
    }

    // Insert the chip
    // We construct the HTML for the chip
    // Note: ID must always be valid patp for Urbit

    // We use insertHTML to put in our special span
    const chipHtml = `<span contenteditable="false" class="mention-chip" data-id="${user.id}">${user.id}</span>&nbsp;`;
    document.execCommand("insertHTML", false, chipHtml);

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
      const form = inputRef.current?.closest("form");
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
      <div
        ref={inputRef}
        contentEditable
        className="input-editor"
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
              ref={
                i === mentionIndex
                  ? (el) => el?.scrollIntoView({ block: "nearest" })
                  : undefined
              }
              onClick={() => selectUser(user)}
              className={`mention-item ${i === mentionIndex ? "selected" : ""}`}
              style={{
                background:
                  i === mentionIndex ? "var(--color-accent)" : "transparent",
                color: i === mentionIndex ? "white" : "var(--color-text)",
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
