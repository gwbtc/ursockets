import type { JSX } from "react";
import { start } from "@/logic/api";
import IO from "@/logic/requests/nostrill";
import type { ComposerData } from "@/types/ui";
import { create } from "zustand";
import type { Fact, Relays, UserProfile } from "@/types/nostrill";
import type { Event } from "@/types/nostr";
import type { FC, Poast } from "@/types/trill";
import type { Notification } from "@/types/notifications";
import { useShallow } from "zustand/shallow";
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
  nostrFeed: Event[];
  relays: Relays;
  profiles: Map<string, UserProfile>; // pubkey key
  addProfile: (key: string, u: UserProfile) => void;
  following: Map<string, FC>;
  following2: FC;
  followers: string[];
  // Notifications
  notifications: Notification[];
  unreadNotifications: number;
  addNotification: (
    notification: Omit<Notification, "id" | "timestamp" | "read">,
  ) => void;
  markNotificationRead: (id: string) => void;
  markAllNotificationsRead: () => void;
  clearNotifications: () => void;
  lastFact: Fact | null;
};

const creator = create<LocalState>();
export const useStore = creator((set, get) => ({
  isNew: false,
  api: null,
  init: async () => {
    const airlock = await start();
    const api = new IO(airlock);
    console.log({ api });
    await api.subscribeStore((data) => {
      if ("state" in data) {
        console.log("state", data.state);
        const { feed, nostr, following, following2, relays, profiles, pubkey } =
          data.state;
        const flwing = new Map(Object.entries(following as Record<string, FC>));
        flwing.set(api!.airlock.our!, feed);
        set({
          relays,
          nostrFeed: nostr,
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
            const { user, feed, profile } = fact.fols.new;
            following.set(user, feed);
            if (profile) profiles.set(user, profile);
            set({ following, profiles });
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
        }
        if ("nostr" in fact) {
          console.log("nostr fact", fact);
          if ("feed" in fact.nostr) set({ nostrFeed: fact.nostr.feed });
          if ("relays" in fact.nostr) set({ relays: fact.nostr.relays });
          if ("event" in fact.nostr) {
            // console.log("san event", fact.nostr.event);
            const event: Event = fact.nostr.event;
            if (event.kind === 1) {
              const nostrFeed = get().nostrFeed;
              set({ nostrFeed: [...nostrFeed, event] });
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
  nostrFeed: [],
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
  unreadNotifications: 0,
  addNotification: (notification) => {
    const newNotification: Notification = {
      ...notification,
      id: `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      timestamp: new Date(),
      read: false,
    };
    set((state) => ({
      notifications: [newNotification, ...state.notifications],
      unreadNotifications: state.unreadNotifications + 1,
    }));
  },
  markNotificationRead: (id) => {
    set((state) => ({
      notifications: state.notifications.map((n) =>
        n.id === id ? { ...n, read: true } : n,
      ),
      unreadNotifications: Math.max(0, state.unreadNotifications - 1),
    }));
  },
  markAllNotificationsRead: () => {
    set((state) => ({
      notifications: state.notifications.map((n) => ({ ...n, read: true })),
      unreadNotifications: 0,
    }));
  },
  clearNotifications: () => {
    set({ notifications: [], unreadNotifications: 0 });
  },
}));

const useShallowStore = <T extends (state: LocalState) => any>(
  selector: T,
): ReturnType<T> => useStore(useShallow(selector));

export default useShallowStore;
