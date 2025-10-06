import Icon from "@/components/Icon";
import useLocalState from "@/state/state";
import toast from "react-hot-toast";
import type { Poast } from "@/types/trill";
export default function ({ poast }: { poast: Poast }) {
  const { relays, api } = useLocalState((s) => ({
    relays: s.relays,
    api: s.api,
  }));

  async function sendToRelay(e: React.MouseEvent) {
    e.stopPropagation();
    //
    const urls = Object.keys(relays);
    await api!.relayPost(poast.host, poast.id, urls);
    toast.success("Post relayed");
  }
  // TODO round up all helpers

  return (
    <div className="icon" role="link" onMouseUp={sendToRelay}>
      <Icon name="nostr" size={20} title="relay to nostr" />
    </div>
  );
}
