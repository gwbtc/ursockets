import Icon from "@/components/Icon";

export default function ({ open }: { open: () => void }) {
  async function handleClick(e: React.MouseEvent) {
    e.stopPropagation();
    open();
  }
  return (
    <div className="icon" role="link" onMouseUp={handleClick}>
      <span />
      <Icon name="nostr" title="relay to nostr" />
    </div>
  );
}

// npub1w8k2hk9kkv653cr4luqmx9tglldpn59vy7yqvlvex2xxmeygt96s4dlh8p
