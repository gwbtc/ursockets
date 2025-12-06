import type {
  Notification,
  Req,
  Post,
  ReqStatus,
  NotificationType,
} from "@/types/notifications";
import type { Result } from "@/types/ui";
import type { Skein } from "@/types/hark";
import type { UserType } from "@/types/nostrill";

export function skeinToNote(skein: Skein): Result<Notification> {
  const path = skein.top.wer.split("/").filter((s) => !!s);
  console.log("skein path", path);
  const key = path[0];
  if (!key) return { error: "no path" };
  let type: NotificationType | null = null;
  let from: UserType | null = null;
  if (key === "req") {
    const mtype = req(path);
    if ("ok" in mtype) type = mtype.ok;
  } else if (key === "res") {
    const mtype = req(path);
    if ("ok" in mtype) type = { res: mtype.ok.req };
  } else if (key === "prof") {
    const ship = path[1];
    from = { urbit: ship };
    type = { prof: ship };
  } else if (key === "post") {
    const mtype = post(path);
    if ("ok" in mtype) type = { post: mtype.ok };
  } else if (key === "nostr") {
    const tipe = path[1];
    if (tipe === "relay-down") {
      const url = path[2];
      type = { nostr: { relayDown: url } };
    } else if (tipe === "new-relay") {
      const url = path[2];
      type = { nostr: { newRelay: url } };
    } else if (tipe === "keys") {
      const ship = path[2];
      const pubkey = path[3];
      type = { nostr: { keys: { user: ship, pubkey } } };
    }
  }
  if (!type) return { error: "bad skein" };

  const n: Notification = {
    id: skein.top.id,
    type,
    timestamp: skein.time,
    unread: skein.unread,
    message: skein.top.con,
  };
  const nn = from ? { ...n, from } : n;
  return { ok: nn };

  //
  function req(path: string[]): Result<{ req: Req }> {
    const tipe = path[1];
    if (!tipe) return { error: "" };
    if (tipe === "fols") {
      const ship = path[2];
      from = { urbit: ship };
      const statu = path[3];
      const status = statu as ReqStatus;
      return { ok: { req: { fols: ship, status } } };
    }
    if (tipe === "begs") {
      const subt = path[2];
      if (subt === "feed") {
        const ship = path[3];
        from = { urbit: ship };
        const statu = path[4];
        const status = statu as ReqStatus;
        return { ok: { req: { status, begs: { feed: null } } } };
      } else if (subt === "thread") {
        const ship = path[3];
        from = { urbit: ship };
        const id = path[4];
        const statu = path[5];
        const status = statu as ReqStatus;
        return { ok: { req: { status, begs: { thread: id } } } };
      } else return { error: "bad skein" };
    } else return { error: "bad skein" };
  }
  function post(path: string[]): Result<Post> {
    const tipe = path[1];
    const ship = path[2];
    from = { urbit: ship };
    if (!tipe) return { error: "" };
    if (tipe === "reply") {
      const host = path[3];
      const parId = path[4];
      const parent = { ship: host, id: parId };
      const id = path[5];
      return { ok: { reply: { user: ship, parent, id } } };
    } else if (tipe === "quote") {
      const host = path[3];
      const parId = path[4];
      const src = { ship: host, id: parId };
      const id = path[5];
      const target = { ship: ship, id };
      return { ok: { quote: { user: ship, src, target } } };
    } else if (tipe === "rp") {
      // TODO
      const host = path[3];
      const parId = path[4];
      const src = { ship: host, id: parId };
      const id = path[5];
      const target = { ship: ship, id };
      return { ok: { quote: { user: ship, src, target } } };
    } else if (tipe === "reaction") {
      const host = path[3];
      const parId = path[4];
      const post = { ship: host, id: parId };
      const reaction = path[5];
      return { ok: { reaction: { user: ship, post, reaction } } };
    } else if (tipe === "mention") {
      const host = path[3];
      const id = path[4];
      const pid = { ship: host, id };
      return { ok: { mention: { user: ship, post: pid } } };
    } else if (tipe === "delReply") {
      const host = path[3];
      const parId = path[4];
      const parent = { ship: host, id: parId };
      const id = path[5];
      return { ok: { delReply: { user: ship, parent, id } } };
    } else if (tipe === "delParent") {
      const host = path[3];
      const parId = path[4];
      const parent = { ship: host, id: parId };
      const id = path[5];
      return { ok: { delReply: { user: ship, parent, id } } };
    } else if (tipe === "delQuote") {
      const host = path[3];
      const parId = path[4];
      const parent = { ship: host, id: parId };
      const id = path[5];
      return { ok: { delReply: { user: ship, parent, id } } };
    } else return { error: "bad skein" };
  }
}
