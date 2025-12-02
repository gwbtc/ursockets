export type Flag = string; // ~{ship}/{name}
export type Id = string; // @uvH

export type Thread = Id[];

export interface Threads {
  [time: string]: Thread; // time is @da
}

export interface Yarn {
  id: Id;
  rope: Rope;
  time: number;
  con: YarnContent[];
  wer: string;
  but: YarnButton | null;
}

export interface YarnButton {
  title: string;
  handler: string;
}

interface YarnContentShip {
  ship: string;
}

interface YarnContentEmphasis {
  emph: string;
}

export type YarnContent = string | YarnContentShip | YarnContentEmphasis;

export function isYarnShip(obj: YarnContent): obj is YarnContentShip {
  return !!obj && typeof obj !== "string" && "ship" in obj;
}

export function isYarnEmph(obj: YarnContent): obj is YarnContentEmphasis {
  return !!obj && typeof obj !== "string" && "emph" in obj;
}

export interface Rope {
  group: Flag | null;
  channel: Flag | null;
  desk: string;
  thread: string;
}

export type Seam = { group: Flag } | { desk: string } | { all: null };

export interface Yarns {
  [id: Id]: Yarn;
}

export interface Cable {
  rope: Rope;
  thread: Thread;
}

export interface Carpet {
  seam: Seam;
  yarns: Yarns;
  cable: Cable[];
  stitch: number;
}

export interface Blanket {
  seam: Seam;
  yarns: Yarns;
  quilt: {
    [key: number]: Thread;
  };
}

export interface HarkAddYarn {
  "add-yarn": {
    all: boolean;
    desk: boolean;
    yarn: Yarn;
  };
}

export interface HarkSawSeam {
  "saw-seam": Seam;
}

export interface HarkSawRope {
  "saw-rope": Rope;
}

export type HarkAction = HarkAddYarn | HarkSawSeam | HarkSawRope;
export type HarkAction1 = HarkAddNewYarn | HarkAction;

export interface HarkUpdate {
  yarns: Yarns;
  seam: Seam;
  threads: Threads;
}

export interface NewYarn extends Omit<Yarn, "id" | "time"> {
  all: boolean;
  desk: boolean;
}

export interface HarkAddNewYarn {
  "new-yarn": NewYarn;
}

export interface Skein {
  time: number;
  count: number;
  "ship-count": number;
  top: Yarn;
  unread: boolean;
}

// unreadNotifications: number;
// addNotification: (
//   notification: Omit<Notification, "id" | "timestamp" | "read">,
// ) => void;
// markNotificationRead: (id: string) => void;
// markAllNotificationsRead: () => void;
// clearNotifications: () => void;
//
//
// unreadNotifications: 0,
// addNotification: (notification) => {
//   const newNotification: Notification = {
//     ...notification,
//     id: `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
//     timestamp: new Date(),
//     read: false,
//   };
//   set((state) => ({
//     notifications: [newNotification, ...state.notifications],
//     unreadNotifications: state.unreadNotifications + 1,
//   }));
// },
// markNotificationRead: (id) => {
//   set((state) => ({
//     notifications: state.notifications.map((n) =>
//       n.id === id ? { ...n, read: true } : n,
//     ),
//     unreadNotifications: Math.max(0, state.unreadNotifications - 1),
//   }));
// },
// markAllNotificationsRead: () => {
//   set((state) => ({
//     notifications: state.notifications.map((n) => ({ ...n, read: true })),
//     unreadNotifications: 0,
//   }));
// },
// clearNotifications: () => {
//   set({ notifications: [], unreadNotifications: 0 });
// },
