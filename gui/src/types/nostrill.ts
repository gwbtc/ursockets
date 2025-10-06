import type { NostrEvent } from "./nostr";
import type { Poast } from "./trill";

export type UserType = { urbit: string } | { nostr: string };
export type UserProfile = {
  name: string;
  picture: string; // URL
  about: string;
  other: Record<string, string>;
};

export type PostWrapper =
  | { nostr: NostrPost }
  | { urbit: { post: Poast; nostr?: NostrMetadata } };
export type NostrPost = {
  relay: string;
  event: NostrEvent;
  post: Poast;
};
export type NostrMetadata = {
  pubkey?: string;
  eventId: string;
  relay?: string;
};
