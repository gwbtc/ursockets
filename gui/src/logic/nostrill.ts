import type { Event } from "@/types/nostr";
import type { Content, FC, Poast } from "@/types/trill";
import { engagementBunt, openLock } from "./bunts";
import type { UserType } from "@/types/nostrill";
import type { Result } from "@/types/ui";
import { isValidPatp } from "urbit-ob";
export function eventsToFc(postEvents: Event[]): FC {
  const fc = postEvents.reduce(
    (acc: FC, event: Event) => {
      const p = eventToPoast(event);
      if (!p) return acc;
      acc.feed[p.id] = p;
      if (!acc.start || event.created_at < Number(acc.start)) acc.start = p.id;
      if (!acc.end || event.created_at > Number(acc.end)) acc.end = p.id;
      return acc;
    },
    { feed: {}, start: null, end: null } as FC,
  );
  return fc;
}
export function eventToPoast(event: Event): Poast | null {
  if (event.kind !== 1) return null;
  const contents: Content = [{ paragraph: [{ text: event.content }] }];
  const ts = event.created_at * 1000;
  const id = `${ts}`;
  const poast: Poast = {
    id,
    host: event.pubkey,
    author: event.pubkey,
    contents,
    thread: id,
    parent: null,
    read: openLock,
    write: openLock,
    tags: [],
    time: ts,
    engagement: engagementBunt,
    children: [],
  };
  for (const tag of event.tags) {
    const f = tag[0];
    if (!f) continue;
    const ff = f.toLowerCase();
    console.log("tag", ff);
    if (ff === "e") {
      const [, eventId, _relayURL, marker, _pubkey, ..._] = tag;
      // TODO
      if (marker === "root") poast.thread = eventId;
      else if (marker === "reply") poast.parent = eventId;
    }
    //
    if (ff === "r")
      contents.push({
        paragraph: [{ link: { show: tag[1]!, href: tag[1]! } }],
      });
    if (ff === "p")
      contents.push({
        paragraph: [{ ship: tag[1]! }],
      });
    if (ff === "q")
      contents.push({
        ref: {
          type: "nostr",
          ship: tag[1]!,
          path: tag[2] || "" + `/${tag[3] || ""}`,
        },
      });
  }
  return poast;
}

export function userToString(user: UserType): Result<string> {
  if ("urbit" in user) {
    const isValid = isValidPatp(user.urbit);
    if (isValid) return { ok: user.urbit };
    else return { error: "invalid @p" };
  } else if ("nostr" in user) return { ok: user.nostr };
  else return { error: "unknown user" };
}
export function isValidNostrPubkey(pubkey: string): boolean {
  // TODO
  if (pubkey.length !== 64) return false;
  try {
    BigInt("0x" + pubkey);
    return true;
  } catch (_e) {
    return false;
  }
}
// NOTE common tags:
// imeta
// client
// nonce
// proxy

// export function parseEventTags(event: Event) {
//   const effects: any[] = [];
//   for (const tag of event.tags) {
//     const f = tag[0];
//     if (!f) continue;
//     const ff = f.toLowerCase();
//     switch (ff) {
//       case "p": {
//         const [, pubkey, relayURL, ..._] = tag;
//         // people mention
//         break;
//       }
//       case "e": {
//         // marker to be "root" or "reply"
//         // event mention
//         break;
//       }
//       case "q": {
//         const [, eventId, relayURL, pubkey, ..._] = tag;
//         // event mention
//         break;
//       }
//       case "t": {
//         const [, hashtag, ..._] = tag;
//         // event mention
//         break;
//       }
//       case "r": {
//         const [, url, ..._] = tag;
//         // event mention
//         break;
//       }
//       case "alt": {
//         const [, summary, ..._] = tag;
//         // event mention
//         break;
//       }
//       default: {
//         break;
//       }
//     }
//   }
//   return effects;
// }
