import type { JSX } from "react";
import { start } from "@/logic/api";
import IO from "@/logic/requests/nostrill";
import type { ComposerData } from "@/types/ui";
import { create } from "zustand";
import type { Fact, Relays, UserProfile } from "@/types/nostrill";
import type { Event } from "@/types/nostr";
import type { FC, Gate, Poast } from "@/types/trill";
import type { Notification } from "@/types/notifications";
import { useShallow } from "zustand/shallow";
import type { HarkAction, Skein } from "@/types/hark";
import { skeinToNote } from "@/logic/notifications";
import { defaultGate } from "@/logic/bunts";
import { eventsToFc, addEventToFc } from "@/logic/nostrill";
// TODO handle airlock connection issues
// the SSE pipeline has a "status-update" event FWIW
// type AirlockState = "connecting" | "connected" | "failed";
export type LocalState = {
  isNew: boolean;
  api: IO | null;
  init: () => Promise<void>;
  UISettings: Record<string, any>;
  modal: JSX.Element | null;
  setModal: (modal: JSX.Element | null) => void;
  composerData: ComposerData | null;
  setComposerData: (c: ComposerData | null) => void;
  pubkey: string;
  nostrFeed: FC;
  relays: Relays;
  profiles: Map<string, UserProfile>; // pubkey key
  addProfile: (key: string, u: UserProfile) => void;
  following: Map<string, FC>;
  following2: FC;
  followers: string[];
  // Notifications
  notifications: Notification[];
  setNotifications: (n: Notification[]) => void;
  lastFact: Fact | null;
  feedPerms: Gate;
};

const creator = create<LocalState>();
export const useStore = creator((set, get) => ({
  isNew: false,
  api: null,
  init: async () => {
    const airlock = await start();
    const api = new IO(airlock);
    console.log({ api });
    api.scryHark().then((r) => {
      console.log("hark scry res", r);
      if ("ok" in r) {
        const notifications = r.ok.reduce((acc: Notification[], sk) => {
          const note = skeinToNote(sk);
          if ("ok" in note) return [...acc, note.ok];
          else return acc;
        }, []);
        set({ notifications });
      }
    });
    api.subscribeHark((data: HarkAction) => {
      console.log("hark data", data);
      if ("add-yarn" in data) {
        if (data["add-yarn"].yarn.rope.desk !== "nostrill") return;
        const nots = get().notifications;
        const yarn = data["add-yarn"].yarn;
        const skein: Skein = {
          top: yarn,
          time: yarn.time,
          "ship-count": 0,
          unread: true,
          count: 0,
        };
        const note = skeinToNote(skein);
        if ("error" in note) return;
        const notifications = [...nots, note.ok];
        set({ notifications });
      }
    });
    await api.subscribeStore((data) => {
      if ("state" in data) {
        console.log("state", data.state);
        const { feed, nostr, following, following2, relays, profiles, pubkey } =
          data.state;
        const flwing = new Map(Object.entries(following as Record<string, FC>));
        flwing.set(api!.airlock.our!, feed);
        //  TODO do this in the backend
        const nostrFeed = eventsToFc(nostr);
        set({
          relays,
          nostrFeed,
          profiles: new Map(Object.entries(profiles)),
          following: flwing,
          following2,
          pubkey,
        });
      } else if ("fact" in data) {
        const fact: Fact = data.fact;
        set({ lastFact: fact });
        if ("fols" in fact) {
          const { following, profiles } = get();
          if ("new" in fact.fols) {
            const { user, data } = fact.fols.new;
            if (data.data === "maybe") return;
            if (data.data) {
              const { feed, profile } = data.data;
              following.set(user, feed);
              if (profile) profiles.set(user, profile);
              set({ following, profiles });
            }
          }
          if ("quit" in fact.fols) {
            following.delete(fact.fols.quit);
            set({ following });
          }
        }
        if ("post" in fact) {
          if ("add" in fact.post) {
            const post: Poast = fact.post.add.post;
            const following = get().following;
            const curr = following.get(post.author);
            const fc = curr ? curr : { feed: {}, start: null, end: null };
            fc.feed[post.id] = post;
            following.set(post.author, fc);

            set({ following });
          }
          if ("del" in fact.post) {
            const post: Poast = fact.post.del.post;
            const following = get().following;
            const curr = following.get(post.author);

            if (curr && curr.feed[post.id]) {
              delete curr.feed[post.id];
              following.set(post.author, curr);

              set({ following });
            }
          }
        }
        if ("nostr" in fact) {
          console.log("nostr fact", fact);
          // if ("feed" in fact.nostr) set({ nostrFeed: fact.nostr.feed });
          if ("thread" in fact.nostr)
            console.log("nostr thread!!!", fact.nostr.thread);
          if ("relays" in fact.nostr) set({ relays: fact.nostr.relays });
          if ("event" in fact.nostr) {
            // console.log("san event", fact.nostr.event);
            const event: Event = fact.nostr.event;
            if (event.kind === 1) {
              const nostrFeed = get().nostrFeed;
              const nf = addEventToFc(event, nostrFeed);
              set({ nostrFeed: nf });
            }
            if (event.kind === 0) {
              const profiles = get().profiles;
              const data = JSON.parse(event.content);
              const { name, picture, about, ...other } = data;
              const prof = { name, picture, about, other };
              const np = profiles.set(event.pubkey, prof);
              set({ profiles: np });
            }
          }
          // if ("user" in data.fact.nostr)
          // if ("thread" in data.fact.nostr)
        }
      }
    });
    set({ api });
  },
  pubkey: "",
  profiles: new Map(),
  addProfile: (key, profile) => {
    const profiles = get().profiles;
    profiles.set(key, profile);
    set({ profiles });
  },
  lastFact: null,
  relays: {},
  nostrFeed: { feed: {}, start: null, end: null },
  following: new Map(),
  followers: [],
  following2: { feed: {}, start: "", end: "" },
  UISettings: {},
  modal: null,
  setModal: (modal) => set({ modal }),
  // composer data
  composerData: null,
  setComposerData: (composerData) => set({ composerData }),
  // Notifications
  notifications: [],
  setNotifications: (notifications) => {
    set({ notifications });
  },
  feedPerms: defaultGate,
}));

const useShallowStore = <T extends (state: LocalState) => any>(
  selector: T,
): ReturnType<T> => useStore(useShallow(selector));

export default useShallowStore;
