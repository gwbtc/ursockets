import PostList from "@/components/feed/PostList";
import useLocalState from "@/state/state";
import spinner from "@/assets/triangles.svg";
import { useEffect, useState } from "react";
import Icon from "@/components/Icon";
import toast from "react-hot-toast";
import { Contact, RefreshCw } from "lucide-react";

export default function Nostr() {
  const { nostrFeed, api, relays, lastEose, setEose } = useLocalState((s) => ({
    nostrFeed: s.nostrFeed,
    api: s.api,
    relays: s.relays,
    lastEose: s.lastEose,
    setEose: s.setEose,
  }));
  const [isSyncing, setIsSyncing] = useState(false);
  const [subId, setSubId] = useState("");

  const refetch = () => nostrFeed;

  useEffect(() => {
    if (!lastEose || !subId) return;
    if (lastEose === subId) {
      setIsSyncing(false);
      setEose("");
      toast.success("Nostr feed sync complete");
    }
  }, [lastEose, subId]);
  const handleResync = async () => {
    if (!api) return;

    // setIsSyncing(true);
    // TODO make this configurable
    const rels = Object.values(relays).map((r) => r.wid);
    try {
      const subId = await api.syncRelays(rels);
      setSubId(subId);
      console.log("syncrelays", subId);
      toast.success("Nostr feed sync initiated");
    } catch (error) {
      toast.error("Failed to sync Nostr feed");
      console.error("Sync error:", error);
      // } finally {
      // setIsSyncing(false);
    }
  };

  async function fetchProfiles() {
    if (!api) return;
    const rels = Object.values(relays).map((r) => r.wid);

    setIsSyncing(true);
    try {
      const subId = await api.nostrProfiles(rels);
      setSubId(subId);
      toast.success("Nostr profile sync initiated");
    } catch (error) {
      toast.error("Failed to sync Nostr feed");
      console.error("Sync error:", error);
    }
  }

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
  if (Object.keys(nostrFeed.feed).length === 0) {
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
            {Object.keys(nostrFeed.feed).length} posts
          </span>
        </div>
        <div className="flex gap-4">
          <button
            className="btn-small"
            onClick={fetchProfiles}
            title="Fetch user profiles"
          >
            <Contact />
          </button>

          <button
            onClick={handleResync}
            disabled={isSyncing}
            className="btn-small"
            title="Sync with Nostr relays"
          >
            {isSyncing ? (
              <img src={spinner} alt="Loading" className="btn-spinner-small" />
            ) : (
              <RefreshCw />
            )}
          </button>
        </div>
      </div>
      <PostList data={nostrFeed} refetch={refetch} />
    </div>
  );
}
