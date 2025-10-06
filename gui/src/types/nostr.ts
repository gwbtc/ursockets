export type Event = {
  id: string; // hex, no 0x, 32bytes
  pubkey: string; // ""
  sig: string; // "", 64 bytes
  created_at: number;
  kind: number;
  tags: Tag[];
  content: string;
};

export type NostrEvent = Event;
export type Tag = string[];
