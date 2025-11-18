// import { generateSecretKey, getPublicKey } from "nostr-tools/pure";
import * as nip19 from "nostr-tools/nip19";
import type { Event } from "@/types/nostr";

export function generateNevent(event: Event) {
  const evp: nip19.EventPointer = {
    id: event.id,
    author: event.pubkey,
    kind: event.kind,
  };
  const nev = nip19.neventEncode(evp);
  return nev;
}

export function generateNpub(pubkey: string) {
  const npub = nip19.npubEncode(pubkey);
  return npub;
}
export function generateNprofile(pubkey: string) {
  const prof = { pubkey };
  const nprofile = nip19.nprofileEncode(prof);
  return nprofile;
}

// let sk = generateSecretKey()
// let nsec = nip19.nsecEncode(sk)
// let { type, data } = nip19.decode(nsec)
// assert(type === 'nsec')
// assert(data === sk)

// let pk = getPublicKey(generateSecretKey())
// let npub = nip19.npubEncode(pk)
// let { type, data } = nip19.decode(npub)
// assert(type === 'npub')
// assert(data === pk)

// let pk = getPublicKey(generateSecretKey())
// let relays = ['wss://relay.nostr.example.mydomain.example.com', 'wss://nostr.banana.com']
// let nprofile = nip19.nprofileEncode({ pubkey: pk, relays })
// let { type, data } = nip19.decode(nprofile)
// assert(type === 'nprofile')
// assert(data.pubkey === pk)
// assert(data.relays.length === 2)
