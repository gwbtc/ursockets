import type { Poast } from "@/types/trill";
import Modal from "./Modal";
import triangles from "@/assets/triangles.svg";
import useLocalState from "@/state/state";
import { useEffect, useState } from "react";
import type { NostrEvent } from "@/types/nostr";
import CodeBlock from "../CodeBlock";

export default function ({ poast }: { poast: Poast }) {
  const { relays, api, setModal, lastFact } = useLocalState((s) => ({
    relays: s.relays,
    api: s.api,
    setModal: s.setModal,
    lastFact: s.lastFact,
  }));
  const [status, setStatus] = useState<"init" | "pending" | "done">("init");
  const [event, setEvent] = useState<NostrEvent>();

  useEffect(() => {
    if (!lastFact) return;
    if (!("nostr" in lastFact)) return;
    if (!("sent" in lastFact.nostr)) return;
    console.log("lastfact", lastFact.nostr.sent);
    const { id, host, event } = lastFact.nostr.sent as any;
    if (id !== poast.id || host !== poast.host) return;
    setEvent(event);

    console.log(poast.host, poast.id);
  }, [lastFact]);

  async function handleConfirm() {
    setStatus("pending");
    try {
      const urls = Object.keys(relays);
      await api!.relayPost(poast.host, poast.id, urls);
    } finally {
      // setStatus("done");
    }
  }

  return (
    <Modal close={() => setModal(null)}>
      <div className="confirmation-dialog">
        {event ? (
          <div>
            <p>Your post was sent to Nostr</p>
            <p>Event ID:</p>
            <CodeBlock>{event.id}</CodeBlock>
          </div>
        ) : status === "pending" ? (
          <div className="loading-spinner">
            <img src={triangles} alt="Loading..." />
          </div>
        ) : status === "init" ? (
          <>
            <p>Send this post to your Nostr Relays?</p>

            <div className="confirmation-buttons">
              <button className="btn-confirm" onClick={handleConfirm}>
                Yes
              </button>
              <button className="btn-cancel" onClick={() => setModal(null)}>
                Cancel
              </button>
            </div>
          </>
        ) : null}
      </div>
    </Modal>
  );
}

// npub1w8k2hk9kkv653cr4luqmx9tglldpn59vy7yqvlvex2xxmeygt96s4dlh8p
