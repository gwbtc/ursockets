import type { NostrEvent } from "./nostr";
import type { FC, Poast } from "./trill";

export type UserType = { urbit: string } | { nostr: string };
export type UserProfile = {
  name: string;
  picture: string; // URL
  about: string;
  other: Record<string, any>;
};
export type DateObj = { month: number; day: number; year?: number };

export type PostWrapper =
  | { nostr: NostrPost }
  | { urbit: { post: Poast; nostr?: NostrMetadata } };
export type NostrPost = {
  relay: string;
  event: NostrEvent;
  post: Poast;
};
export type NostrMetadata = {
  pubkey: string;
  eventId: string;
  relay?: string;
  post: Poast;
};
export type Relays = Record<string, RelayStats>;
export type RelayStats = {
  start: number;
  wid: number;
  reqs: Record<string, number>;
};

export type Fact =
  | { nostr: NostrFact }
  | { post: PostFact }
  | { enga: EngaFact }
  | { fols: FolsFact }
  | { hark: Notification };

export type NostrFact =
  | { feed: NostrEvent[] }
  | { user: NostrEvent[] }
  | { thread: NostrEvent[] }
  | { event: NostrEvent }
  | { relays: Relays };

export type PostFact = { add: { post: Poast } } | { del: { post: Poast } };

export type EngaFact = { add: NostrEvent[] } | { del: NostrEvent[] };

export type FolsFact =
  | { new: { user: string; feed: FC; profile: UserProfile } }
  | { quit: string };

export type Notification =
  | { prof: NostrEvent[] }
  | { fols: NostrEvent[] }
  | { beg: NostrEvent[] }
  | { fans: NostrEvent[] }
  | { post: NostrEvent[] };
