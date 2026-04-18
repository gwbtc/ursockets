import PostList from "@/components/feed/PostList";
import useLocalState from "@/state/state";
import spinner from "@/assets/triangles.svg";
import { useEffect, useState } from "react";
import Icon from "@/components/Icon";
import toast from "react-hot-toast";
import { Contact, RefreshCw } from "lucide-react";
import type { RelayReqs, RelayStats } from "@/types/nostrill";

export default function Nostr() {
  const { nostrFeed, api, relays, lastEose, setEose } = useLocalState((s) => ({
    nostrFeed: s.nostrFeed,
    api: s.api,
    relays: s.relays,
    lastEose: s.lastEose,
    setEose: s.setEose,
  }));
  const [fetchingPosts, setFetchingPosts] = useState("");
  const [fetchingProfiles, setFetchingProfiles] = useState("");

  const refetch = () => nostrFeed;
  console.log({
    eose: lastEose,
    posts: fetchingPosts,
    profiles: fetchingProfiles,
  });

  useEffect(() => {
    if (!lastEose) return;
    if (lastEose === fetchingPosts) {
      setFetchingPosts("");
      toast.success("Nostr feed sync complete");
      setEose("");
      setFetchingProfiles("temp");
      toast.loading("Nostr profile sync initiated");
    }
    if (lastEose === fetchingProfiles) {
      setFetchingProfiles("");
      setEose("");
      toast.success("Nostr profiles sync complete");
    }
  }, [lastEose, fetchingPosts, fetchingProfiles]);

  useEffect(() => {
    const allReqs = Object.values(relays).reduce(
      (acc: RelayReqs, item: RelayStats) => {
        acc = Object.assign(acc, item.reqs);
        return acc;
      },
      {},
    );
    for (const [subId, req] of Object.entries(allReqs)) {
      if (req.name === "timeline" && !req.ongoing) setFetchingPosts(subId);
      if (req.name === "user profiles fetch" && !req.ongoing)
        setFetchingProfiles(subId);
    }
  }, [relays]);
  const handleResync = async () => {
    if (!api) return;
    toast.loading("Nostr post sync initiated");
    setFetchingPosts("temp");
    // TODO make this configurable
    const rels = Object.values(relays).map((r) => r.wid);
    try {
      const res = await api.syncRelays(rels);
      // const subId = await api.syncRelaysThread(rels);
      // setSubId(subId);
      // console.log("syncrelays", subId);
      // toast.success("Nostr feed sync initiated");
    } catch (error) {
      toast.error("Failed to sync Nostr feed");
      console.error("Sync error:", error);
    }
  };

  async function fetchProfiles() {
    if (!api) return;
    const rels = Object.values(relays).map((r) => r.wid);

    setFetchingProfiles("temp");
    try {
      const subId = await api.nostrProfiles(rels);
      setFetchingProfiles(subId);
      toast.loading("Nostr profile sync initiated");
    } catch (error) {
      toast.error("Failed to sync Nostr feed");
      console.error("Sync error:", error);
    }
  }
  console.log({ nostrFeed });
  console.log({ relays });

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
            disabled={!!fetchingPosts}
            className="resync-btn"
          >
            {fetchingPosts ? (
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
            disabled={!!fetchingPosts}
            className="btn-small"
            title="Sync with Nostr relays"
          >
            {fetchingPosts ? (
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
