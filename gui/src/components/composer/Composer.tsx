import useLocalState from "@/state/state";
import Sigil from "@/components/Sigil";
import { useState, useEffect, useRef, type FormEvent } from "react";
import Snippets, { ReplySnippet } from "./Snippets";
import toast from "react-hot-toast";
import Icon from "@/components/Icon";
import { wait } from "@/logic/utils";

function Composer({ isAnon }: { isAnon?: boolean }) {
  const { api, composerData, addNotification, setComposerData } = useLocalState(
    (s) => ({
      api: s.api,
      composerData: s.composerData,
      addNotification: s.addNotification,
      setComposerData: s.setComposerData,
    }),
  );
  const our = api!.airlock.our!;
  const [input, setInput] = useState("");
  const [isExpanded, setIsExpanded] = useState(false);
  const [isLoading, setLoading] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (composerData) {
      setIsExpanded(true);
      if (
        composerData.type === "reply" &&
        composerData.post &&
        "trill" in composerData.post
      ) {
        const author = composerData.post.trill.author;
        setInput(`${author} `);
      }
      // Auto-focus input when composer opens
      setTimeout(() => {
        inputRef.current?.focus();
      }, 100); // Small delay to ensure the composer is rendered
    }
  }, [composerData]);
  async function poast(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    // TODO
    setLoading(true);

    const res =
      composerData?.type === "reply" && "trill" in composerData.post
        ? api!.addReply(
            input,
            composerData.post.trill.host,
            composerData.post.trill.id,
            composerData.post.trill.thread || composerData.post.trill.id,
          )
        : composerData?.type === "quote" && "trill" in composerData.post
          ? api!.addQuote(input, {
              ship: composerData.post.trill.host,
              id: composerData.post.trill.id,
            })
          : !composerData
            ? api!.addPost(input)
            : wait(500);
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

      setInput("");
      setComposerData(null); // Clear composer data after successful post
      toast.success("post sent");
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
        <Sigil patp={our} size={46} />
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
          <button type="submit" disabled={!input.trim()} className="post-btn">
            Post
          </button>
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
