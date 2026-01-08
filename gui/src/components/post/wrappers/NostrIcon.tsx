import Icon from "@/components/Icon";
import useLocalState from "@/state/state";
import toast from "react-hot-toast";
import type { Poast } from "@/types/trill";
import { generateNevent } from "@/logic/nostr";
import ConfirmationDialog from "@/components/modals/ConfirmationDialog";

export default function ({ poast }: { poast: Poast }) {
  const { relays, api, setModal } = useLocalState((s) => ({
    relays: s.relays,
    api: s.api,
    setModal: s.setModal,
  }));

  async function handleClick(e: React.MouseEvent) {
    e.stopPropagation();
    if (poast.event) {
      const nevent = generateNevent(poast.event);
      console.log({ nevent });
      const href = `https://primal.net/e/${nevent}`;
      window.open(href, "_blank");
    } else showConfirmation(e);
  }

  function showConfirmation(e: React.MouseEvent) {
    e.stopPropagation();
    e.preventDefault();
    setModal(
      <ConfirmationDialog
        message="Send this post to a Nostr Relay?"
        onConfirm={doSendToRelay}
        onCancel={() => setModal(null)}
      />,
    );
  }

  async function doSendToRelay() {
    const urls = Object.keys(relays);
    await api!.relayPost(poast.host, poast.id, urls);
    toast.success("Post relayed");
    setModal(null);
  }
  // TODO round up all helpers

  return (
    <div className="icon" role="link" onMouseUp={handleClick}>
      <span />
      <Icon name="nostr" title="relay to nostr" />
    </div>
  );
}

// npub1w8k2hk9kkv653cr4luqmx9tglldpn59vy7yqvlvex2xxmeygt96s4dlh8p
