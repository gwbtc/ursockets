import type { Wevent as NostrEvent } from "./nostr";
import type { NostrFilter } from "@nostrify/nostrify";
import type { FC, FullNode, Poast } from "./trill";

export type UserType = { urbit: string } | { nostr: string };
export interface UserProfile extends BasicProfile {
  pubkey: string;
  following: UserType[];
  followingCount: number;
  followers: UserType[];
  followerCount: number;
  urbitID: UrbitID | null;
  gwid: GroundwireID;
}
export interface BasicProfile {
  name: string;
  picture: string; // URL
  about: string;
  other: Record<string, any>;
}
export interface UrbitID {
  patp: string;
  point: number;
  gwid: GroundwireID;
}
export interface GroundwireID {
  english: GWNyms;
  hanzi: GWNyms;
}
export interface GWNyms {
  nym: string;
  abridged: string;
  foreshortened: string;
}
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
  reqs: RelayReqs;
};
export type RelayReqs = Record<string, RelayRequest>;
export type RelayRequest = {
  // subID: string; // actually the key, not to add it
  eventsReceived: number;
  filters: NostrFilter[];
  name: string;
  ongoing: true | false | null;
  chunked?: boolean;
};

export type PeekRes = { feed: PeekFeedRes } | { thread: PeekThreadRes };
export type PeekFeedRes = Deferred<FeedData>;
export type PeekThreadRes = { id: string; data: Deferred<ThreadData> };

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
  | { sub: { subId: string; type: string } }
  | { eose: string }
  | { relays: Relays }
  | { "sent-post": { host: any; id: string; relays: string[] } }
  | { "sent-prof": string[] };

export type PostFact = { add: { post: Poast } } | { del: { post: Poast } };

export type EngaFact = { add: NostrEvent[] } | { del: NostrEvent[] };

export type FolsFact =
  | { "new-urbit": Enbowled<Deferred<FeedData>> }
  | { "new-nostr": NostrFollow }
  | { quit: string };

export type NostrFollow = {
  pubkey: string;
  profile: UserProfile | null;
  relays: string[];
};
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
