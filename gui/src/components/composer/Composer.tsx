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
import InputBox from "./InputBox";
import { ImageIcon, XCircleIcon } from "lucide-react";
import Modal from "../modals/Modal";
import S3Browser from "./S3Browser";

function Composer({ isAnon }: { isAnon?: boolean }) {
  const {
    api,
    composerData,
    setComposerData,
    contacts,
    profiles,
    s3,
    setModal,
  } = useLocalState((s) => ({
    api: s.api,
    composerData: s.composerData,
    setComposerData: s.setComposerData,
    contacts: s.contacts,
    profiles: s.profiles,
    s3: s.s3,
    setModal: s.setModal,
  }));
  const [input, setInput] = useState("");
  const [isExpanded, setIsExpanded] = useState(false);
  const [isLoading, setLoading] = useState(false);

  const inputRef = useRef<HTMLDivElement>(null);

  console.log({ composerData });
  // Input
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

  //
  // Helper to serialize content with images
  const getSerializedContent = () => {
    if (!inputRef.current) return input;

    // Check if we have any images to serialize
    const images = inputRef.current.querySelectorAll("img");
    if (images.length === 0) return input;

    // If we have images, clone and serialize
    const clone = inputRef.current.cloneNode(true) as HTMLElement;
    const cloneImages = clone.querySelectorAll("img");

    cloneImages.forEach((img) => {
      const src = img.getAttribute("src");
      if (src) {
        const replacement = document.createTextNode(` ![](${src}) `);
        img.replaceWith(replacement);
      }
    });

    return clone.innerText;
  };

  async function addSimple(content: string) {
    if (!api) return;
    return await api.addPost(content);
  }

  async function addComplex(content: string) {
    if (!api) return;
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
        ? api.addReply(content, host, id, thread)
        : composerData?.type === "quote"
          ? api.addQuote(content, host, id)
          : wait(500);
    return await res;
  }

  async function poast(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (!api) return;

    const content = getSerializedContent();
    if (!content.trim()) return;

    setLoading(true);
    const res = !composerData ? addSimple(content) : addComplex(content);
    if (await res) {
      setInput("");
      setComposerData(null); // Clear composer data after successful post
      toast.success("post sent");
      setLoading(false);
      setIsExpanded(false);
      if (inputRef.current) inputRef.current.innerText = "";
    }
  }
  const placeholder =
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

  const handleS3Select = (url: string) => {
    console.log("hey", url);
    console.log(inputRef.current);
    if (!inputRef.current) return;

    setInput((s) => s + ` ![](${url}) `);
    const thumbEl = `<img class="img-thumb" src="${url}"/>`;
    document.execCommand("insertHTML", false, thumbEl);
    setModal(null);
  };
  console.log({ input });

  const openS3Browser = () => {
    setModal(
      <Modal>
        <S3Browser onSelect={handleS3Select} onClose={() => setModal(null)} />
      </Modal>,
    );
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
          <InputBox
            input={input}
            setInput={setInput}
            setIsExpanded={setIsExpanded}
            contacts={contacts}
            profiles={profiles}
            placeholder={placeholder}
            inputRef={inputRef}
          />
          {isLoading ? (
            <img width="40" src={spinner} />
          ) : (
            <button type="submit" disabled={!input.trim()} className="post-btn">
              Post
            </button>
          )}
        </div>
        <div className="composer-controls">
          {s3 && (
            <button
              type="button"
              onClick={openS3Browser}
              className="icon-btn"
              title="s3 media"
            >
              <ImageIcon size={20} />
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
