import type { JSX } from "react";
import { start } from "@/logic/api";
import IO from "@/logic/requests/nostrill";
import type { ComposerData } from "@/types/ui";
import { create } from "zustand";
import type { UserProfile } from "@/types/nostrill";
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
  relays: Record<string, Event[]>;
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
  lastFact: any;
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
      console.log("store sub", data);
      if ("state" in data) {
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
        set({ lastFact: data.fact });
        if ("fols" in data.fact) {
          const { following, profiles } = get();
          if ("new" in data.fact.fols) {
            const { user, feed, profile } = data.fact.fols.new;
            following.set(user, feed);
            if (profile) profiles.set(user, profile);
            set({ following, profiles });
          }
          if ("quit" in data.fact.fols) {
            following.delete(data.fact.fols.quit);
            set({ following });
          }
        }
        if ("post" in data.fact) {
          if ("add" in data.fact.post) {
            const post: Poast = data.fact.post.add.post;
            const following = get().following;
            const curr = following.get(post.author);
            const fc = curr ? curr : { feed: {}, start: null, end: null };
            fc.feed[post.id] = post;
            following.set(post.author, fc);

            set({ following });
          }
        }
        if ("nostr" in data.fact) {
          set({ nostrFeed: data.fact.nostr });
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
