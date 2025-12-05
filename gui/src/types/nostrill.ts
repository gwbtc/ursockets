import type { NostrEvent } from "./nostr";
import type { FC, FullNode, Poast } from "./trill";

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

export type PeekRes = { feed: PeekFeedRes } | { thread: PeekThreadRes };
export type PeekFeedRes = Deferred<FeedData>;
export type PeekThreadRes = Deferred<ThreadData>;

export type ThreadData = { node: FullNode; thread: FullNode[] };
export type Fact =
  | { nostr: NostrFact }
  | { post: PostFact }
  | { fols: FolsFact };

export type NostrFact =
  | { feed: NostrEvent[] }
  | { user: NostrEvent[] }
  | { thread: NostrEvent[] }
  | { event: NostrEvent }
  | { relays: Relays };

export type PostFact = { add: { post: Poast } } | { del: { post: Poast } };

export type EngaFact = { add: NostrEvent[] } | { del: NostrEvent[] };

export type FolsFact = { new: Enbowled<Deferred<FeedData>> } | { quit: string };
export type FeedData = { feed: FC; profile: UserProfile | null };

export type Notification =
  | { prof: NostrEvent[] }
  | { fols: NostrEvent[] }
  | { beg: NostrEvent[] }
  | { fans: NostrEvent[] }
  | { post: NostrEvent[] };

export type Enbowled<T> = {
  user: string;
  ts: number;
  data: T;
};
export type Deferred<T> = {
  data: "maybe" | Approved<T>;
  msg: string;
};
export type Approved<T> = T | null;
