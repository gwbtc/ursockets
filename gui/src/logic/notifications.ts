import type { Notification } from "@/types/notifications";
import type { Result } from "@/types/ui";
import type { Skein } from "./hark";

export function skeinToNote(skein: Skein): Result<Notification> {
  const path = skein.top.wer.split("/").filter((s) => !!s);
  console.log("skein path", path);
  const key = path[0];
  if (!key) return { error: "no path" };
  if (key === "fans") {
    const ship = path[1];
    const from = { urbit: ship };

    const n: Notification = {
      id: skein.top.id,
      type: "follow",
      from,
      timestamp: skein.time,
      unread: skein.unread,
      message: skein.top.con,
    };
    return { ok: n };
  } else if (key === "prof") {
    const ship = path[1];
    const from = { urbit: ship };
    const n: Notification = {
      id: skein.top.id,
      type: "profile",
      from,
      timestamp: skein.time,
      unread: skein.unread,
      message: skein.top.con,
    };
    return { ok: n };
  } else if (key === "fols") {
    const ok = path[1];
    const ship = path[2];
    const from = { urbit: ship };
    const type = ok === "1" ? "follow-granted" : "follow-denied";
    const n: Notification = {
      id: skein.top.id,
      type,
      from,
      timestamp: skein.time,
      unread: skein.unread,
      message: skein.top.con,
    };
    return { ok: n };
  } else if (key === "beg-req") {
    const ship = path[1];
    const from = { urbit: ship };
    const n: Notification = {
      id: skein.top.id,
      type: "access-request",
      from,
      timestamp: skein.time,
      unread: skein.unread,
      message: skein.top.con,
    };
    return { ok: n };
  } else if (key === "beg-res") {
    const ok = path[1];
    const reqType = path[2];
    const ship = path[3];
    const from = { urbit: ship };
    const type = ok === "1" ? "access-granted" : "access-denied";
    const n: Notification = {
      id: skein.top.id,
      type,
      from,
      timestamp: skein.time,
      unread: skein.unread,
      message: skein.top.con,
    };
    return { ok: n };
  } else if (key === "post") {
    const ship = path[2];
    const from = { urbit: ship };
    const n: Notification = {
      id: skein.top.id,
      type: "follow",
      from,
      timestamp: skein.time,
      unread: skein.unread,
      message: skein.top.con,
    };
    return { ok: n };
  } else return { error: "bad notification" };
}
// $%  [%prof =user prof=user-meta:nostr]              :: profile change
//     [%fans =user msg=@t]                            :: someone folowed me
//     [%fols =user accepted=? msg=@t]                 :: follow response
//     [%beg-req =user beg=begs-poke:ui msg=@t]        :: feed/post data request request
//     [%beg-res beg=begs-poke:ui accepted=? msg=@t]   :: feed/post data request response
//     [%post =pid:tp =user action=post-notif]         :: someone replied, reacted etc.
