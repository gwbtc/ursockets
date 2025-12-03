import Icon from "@/components/Icon";
import useLocalState from "@/state/state";
import toast from "react-hot-toast";
import type { Poast } from "@/types/trill";
import { generateNevent } from "@/logic/nostr";
export default function ({ poast }: { poast: Poast }) {
  const { relays, api } = useLocalState((s) => ({
    relays: s.relays,
    api: s.api,
  }));

  async function handleClick(e: React.MouseEvent) {
    e.stopPropagation();
    if (poast.event) {
      const nevent = generateNevent(poast.event);
      console.log({ nevent });
      const href = `https://primal.net/e/${nevent}`;
      window.open(href, "_blank");
    } else sendToRelay(e);
  }
  async function sendToRelay(e: React.MouseEvent) {
    //
    const urls = Object.keys(relays);
    await api!.relayPost(poast.host, poast.id, urls);
    toast.success("Post relayed");
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
