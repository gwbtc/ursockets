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
  const { notifications, dismissNotification, setModal } = useLocalState(
    (s) => ({
      notifications: s.notifications,
      dismissNotification: s.dismissNotification,
      setModal: s.setModal,
    }),
  );
  console.log({ notifications });

  const [filter, setFilter] = useState<"all" | "unread">("all");

  const filteredNotifications =
    filter === "unread" ? notifications.filter((n) => n.unread) : notifications;

  console.log(filteredNotifications)

  const handleNotificationClick = (notification: Notification ) => {

    const from = "urbit" in notification.from
        ? notification.from.urbit
        : notification.from.nostr;

    // // Mark as read
    // if (notification.unread) {
    //   markNotificationRead(notification.id);
    // }
    // Navigate based on notification type
    if (notification.postId) {
      // Navigate to post
      navigate(`/t/${notification.postId}`);
      setModal(null);
    } else if (
      notification.type === "follow" ||
      notification.type === "access-request"
    ) {
      // Navigate to user profile
      navigate(`/u/${from}`);
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
      case "access-request":
      case "access-granted":
        return "key";
      case "access-denied":
        return "bell";
      default:
        return "bell";
    }
  };

  const formatTimestamp = (ts: number) => {
    const now = new Date();
    const diff = now.getTime() - new Date(ts).getTime();
    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (minutes < 1) return "Just now";
    if (minutes < 60) return `${minutes}m ago`;
    if (hours < 24) return `${hours}h ago`;
    if (days < 7) return `${days}d ago`;
    return new Date(ts).toLocaleDateString();
  };

  function dismissAll() {
    //
  }
  function markAllNotificationsRead() {
    //
  }
  const unreadNotifications = notifications.filter((n) => n.unread);
  return (
    <Modal close={() => setModal(null)}>
      <div className="notification-center">
        <div className="notification-header">
          <h2>Notifications</h2>
          <div className="notification-actions">
            {unreadNotifications.length > 0 && (
              <button
                className="mark-all-read-btn"
                onClick={markAllNotificationsRead}
              >
                Mark all as read
              </button>
            )}
            {notifications.length > 0 && (
              <button className="clear-all-btn" onClick={dismissAll}>
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
            Unread ({unreadNotifications.length})
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
                className={`notification-item ${notification.unread ? "unread" : ""}`}
                onClick={(e) => handleNotificationClick(notification, e)}
              >
                <div className="notification-icon">
                  <Icon
                    name={getNotificationIcon(notification.type)}
                    size={20}
                    color={notification.unread ? "primary" : "textSecondary"}
                  />
                </div>

                <div className="notification-content">
                  <div className="notification-user">
                    <Avatar user={notification.from} size={32} />
                    <div className="notification-text">
                      {notification.message.map((m, i) => (
                        <p key={m.toString() + i}>
                          {typeof m === "string" ? (
                            <span>{m}</span>
                          ) : "ship" in m ? (
                            <span className="ship">{m.ship}</span>
                          ) : (
                            <strong>{m.emph}</strong>
                          )}
                        </p>
                      ))}
                      <span className="notification-time">
                        {formatTimestamp(notification.timestamp)}
                      </span>
                    </div>
                  </div>
                </div>

                {notification.unread && <div className="unread-indicator" />}
              </div>
            ))
          )}
        </div>
      </div>
    </Modal>
  );
};

export default NotificationCenter;
