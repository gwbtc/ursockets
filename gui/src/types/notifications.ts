import type { Ship } from "./urbit";

export type NotificationType =
  | "follow"
  | "unfollow"
  | "mention"
  | "reply"
  | "repost"
  | "react"
  | "access_request"
  | "access_granted"
  | "fetching_nostr"
  | "nostr_fetch_success";

export interface Notification {
  id: string;
  type: NotificationType;
  from: Ship | string; // Ship for Urbit users, string for Nostr pubkeys
  timestamp: Date;
  read: boolean;
  // Optional context data
  postId?: string;
  message?: string;
  reaction?: string;
}

export interface NotificationState {
  notifications: Notification[];
  unreadCount: number;
}
