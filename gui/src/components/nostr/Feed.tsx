import PostList from "@/components/feed/PostList";
import useLocalState from "@/state/state";
import spinner from "@/assets/triangles.svg";
import { useState } from "react";
import { eventsToFc } from "@/logic/nostrill";
import Icon from "@/components/Icon";
import toast from "react-hot-toast";

export default function Nostr() {
  const { nostrFeed, api, relays } = useLocalState((s) => ({
    nostrFeed: s.nostrFeed,
    api: s.api,
    relays: s.relays,
  }));
  console.log({ relays });
  const [isSyncing, setIsSyncing] = useState(false);
  console.log({ nostrFeed });
  const feed = eventsToFc(nostrFeed);
  console.log({ feed });
  const refetch = () => feed;

  const handleResync = async () => {
    if (!api) return;

    setIsSyncing(true);
    try {
      await api.syncRelays();
      toast.success("Nostr feed sync initiated");
    } catch (error) {
      toast.error("Failed to sync Nostr feed");
      console.error("Sync error:", error);
    } finally {
      setIsSyncing(false);
    }
  };

  if (Object.keys(relays).length === 0)
    return (
      <div className="nostr-empty-state">
        <div className="empty-content">
          <Icon name="nostr" size={48} color="textMuted" />
          <h3>No Nostr Relays Set Up</h3>
          <p>
            You haven't set any Nostr Relays to sync data from. You can do so in
            the Settings page.
          </p>
          <p>
            If you don't know of any, we recommend the following public relays:
          </p>
          <ul>
            <li>wss://nos.lol</li>
            <li>wss://relay.damus.io</li>
          </ul>
        </div>
      </div>
    );
  // Show empty state with resync option when no feed data
  if (!feed || !feed.feed || Object.keys(feed.feed).length === 0) {
    return (
      <div className="nostr-empty-state">
        <div className="empty-content">
          <Icon name="nostr" size={48} color="textMuted" />
          <h3>No Nostr Posts</h3>
          <p>
            Your Nostr feed appears to be empty. Try syncing with your relays to
            fetch the latest posts.
          </p>
          <button
            onClick={handleResync}
            disabled={isSyncing}
            className="resync-btn"
          >
            {isSyncing ? (
              <>
                <img src={spinner} alt="Loading" className="btn-spinner" />
                Syncing...
              </>
            ) : (
              <>
                <Icon name="settings" size={16} />
                Sync Relays
              </>
            )}
          </button>
        </div>
      </div>
    );
  }

  // Show feed with resync button in header
  return (
    <div className="nostr-feed">
      <div className="nostr-header">
        <div className="feed-info">
          <h4>Nostr Feed</h4>
          <span className="post-count">
            {Object.keys(feed.feed).length} posts
          </span>
        </div>
        <button
          onClick={handleResync}
          disabled={isSyncing}
          className="resync-btn-small"
          title="Sync with Nostr relays"
        >
          {isSyncing ? (
            <img src={spinner} alt="Loading" className="btn-spinner-small" />
          ) : (
            <Icon name="settings" size={16} />
          )}
        </button>
      </div>
      <PostList data={feed} refetch={refetch} />
    </div>
  );
}
