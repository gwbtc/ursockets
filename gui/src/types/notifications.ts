import type { YarnContent } from "@/logic/hark";
import type { Ship } from "./urbit";
import type { UserType } from "./nostrill";

export type NotificationType =
  | "follow"
  | "unfollow"
  | "profile"
  | "mention"
  | "reply"
  | "repost"
  | "react"
  | "follow-granted"
  | "follow-denied"
  | "access-request"
  | "access-granted"
  | "access-denied"
  | "fetching-nostr"
  | "nostr_fetch_success";

export interface Notification {
  id: string;
  type: NotificationType;
  from: UserType;
  timestamp: number;
  unread: boolean;
  // Optional context data
  postId?: string;
  message: YarnContent[];
  reaction?: string;
}

export interface NotificationState {
  notifications: Notification[];
  unreadCount: number;
}
