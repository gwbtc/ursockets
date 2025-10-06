import { useState } from "react";
import useLocalState from "@/state/state";
import Modal from "./modals/Modal";
import Icon from "./Icon";
import Avatar from "./Avatar";
import { useLocation } from "wouter";
import type { Notification, NotificationType } from "@/types/notifications";
import "@/styles/NotificationCenter.css";

const NotificationCenter = () => {
  const [_, navigate] = useLocation();
  const { 
    notifications, 
    unreadNotifications,
    markNotificationRead, 
    markAllNotificationsRead,
    clearNotifications,
    setModal 
  } = useLocalState((s) => ({
    notifications: s.notifications,
    unreadNotifications: s.unreadNotifications,
    markNotificationRead: s.markNotificationRead,
    markAllNotificationsRead: s.markAllNotificationsRead,
    clearNotifications: s.clearNotifications,
    setModal: s.setModal
  }));

  const [filter, setFilter] = useState<"all" | "unread">("all");

  const filteredNotifications = filter === "unread" 
    ? notifications.filter(n => !n.read)
    : notifications;

  const handleNotificationClick = (notification: Notification) => {
    // Mark as read
    if (!notification.read) {
      markNotificationRead(notification.id);
    }

    // Navigate based on notification type
    if (notification.postId) {
      // Navigate to post
      navigate(`/post/${notification.postId}`);
      setModal(null);
    } else if (notification.type === "follow" || notification.type === "access_request") {
      // Navigate to user profile
      navigate(`/feed/${notification.from}`);
      setModal(null);
    }
  };

  const getNotificationIcon = (type: NotificationType) => {
    switch (type) {
      case "follow":
      case "unfollow":
        return "pals";
      case "mention":
      case "reply":
        return "messages";
      case "repost":
        return "repost";
      case "react":
        return "emoji";
      case "access_request":
      case "access_granted":
        return "key";
      default:
        return "bell";
    }
  };

  const getNotificationText = (notification: Notification) => {
    switch (notification.type) {
      case "follow":
        return `${notification.from} started following you`;
      case "unfollow":
        return `${notification.from} unfollowed you`;
      case "mention":
        return `${notification.from} mentioned you in a post`;
      case "reply":
        return `${notification.from} replied to your post`;
      case "repost":
        return `${notification.from} reposted your post`;
      case "react":
        return `${notification.from} reacted ${notification.reaction || ""} to your post`;
      case "access_request":
        return `${notification.from} requested access to your feed`;
      case "access_granted":
        return `${notification.from} granted you access to their feed`;
      default:
        return notification.message || "New notification";
    }
  };

  const formatTimestamp = (date: Date) => {
    const now = new Date();
    const diff = now.getTime() - new Date(date).getTime();
    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (minutes < 1) return "Just now";
    if (minutes < 60) return `${minutes}m ago`;
    if (hours < 24) return `${hours}h ago`;
    if (days < 7) return `${days}d ago`;
    return new Date(date).toLocaleDateString();
  };

  return (
    <Modal close={() => setModal(null)}>
      <div className="notification-center">
        <div className="notification-header">
          <h2>Notifications</h2>
          <div className="notification-actions">
            {unreadNotifications > 0 && (
              <button
                className="mark-all-read-btn"
                onClick={markAllNotificationsRead}
              >
                Mark all as read
              </button>
            )}
            {notifications.length > 0 && (
              <button
                className="clear-all-btn"
                onClick={clearNotifications}
              >
                Clear all
              </button>
            )}
          </div>
        </div>

        <div className="notification-filters">
          <button
            className={`filter-btn ${filter === "all" ? "active" : ""}`}
            onClick={() => setFilter("all")}
          >
            All ({notifications.length})
          </button>
          <button
            className={`filter-btn ${filter === "unread" ? "active" : ""}`}
            onClick={() => setFilter("unread")}
          >
            Unread ({unreadNotifications})
          </button>
        </div>

        <div className="notification-list">
          {filteredNotifications.length === 0 ? (
            <div className="no-notifications">
              <Icon name="bell" size={48} color="textMuted" />
              <p>No {filter === "unread" ? "unread " : ""}notifications</p>
            </div>
          ) : (
            filteredNotifications.map((notification) => (
              <div
                key={notification.id}
                className={`notification-item ${!notification.read ? "unread" : ""}`}
                onClick={() => handleNotificationClick(notification)}
              >
                <div className="notification-icon">
                  <Icon 
                    name={getNotificationIcon(notification.type)} 
                    size={20}
                    color={!notification.read ? "primary" : "textSecondary"}
                  />
                </div>
                
                <div className="notification-content">
                  <div className="notification-user">
                    <Avatar p={notification.from} size={32} />
                    <div className="notification-text">
                      <p>{getNotificationText(notification)}</p>
                      <span className="notification-time">
                        {formatTimestamp(notification.timestamp)}
                      </span>
                    </div>
                  </div>
                </div>

                {!notification.read && <div className="unread-indicator" />}
              </div>
            ))
          )}
        </div>
      </div>
    </Modal>
  );
};

export default NotificationCenter;