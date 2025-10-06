// import spinner from "@/assets/icons/spinner.svg";
import "@/styles/trill.css";
import "@/styles/feed.css";
import UserLoader from "./User";
import PostList from "@/components/feed/PostList";
import useLocalState from "@/state/state";
import { useParams } from "wouter";
import spinner from "@/assets/triangles.svg";
import { useState } from "react";
import Composer from "@/components/composer/Composer";
import Icon from "@/components/Icon";
import toast from "react-hot-toast";
import { eventsToFc } from "@/logic/nostrill";
import { ErrorPage } from "@/Router";

type FeedType = "global" | "following" | "nostr";
function Loader() {
  // const { api } = useLocalState();
  const params = useParams();
  console.log({ params });
  // const [loc, navigate] = useLocation();
  // console.log({ loc });
  // const our = api!.airlock.ship;
  if (params.taip === "global") return <FeedPage t={"global"} />;
  if (params.taip === "nostr") return <FeedPage t={"nostr"} />;
  // else if (param === FeedType.Rumors) return <Rumors />;
  // else if (param === FeedType.Home) return <UserFeed p={our} />;
  else if (params.taip) return <UserLoader userString={params.taip!} />;
  else return <ErrorPage msg="No such page" />;
}
function FeedPage({ t }: { t: FeedType }) {
  const [active, setActive] = useState<FeedType>(t);
  return (
    <main>
      <div id="top-tabs">
        <div
          className={active === "global" ? "active" : ""}
          onClick={() => setActive("global")}
        >
          Global
        </div>
        <div
          className={active === "following" ? "active" : ""}
          onClick={() => setActive("following")}
        >
          Following
        </div>
        <div
          className={active === "nostr" ? "active" : ""}
          onClick={() => setActive("nostr")}
        >
          Nostr
        </div>
      </div>
      <div id="feed-proper">
        <Composer />
        {active === "global" ? (
          <Global />
        ) : active === "following" ? (
          <Global />
        ) : active === "nostr" ? (
          <Nostr />
        ) : null}
      </div>
    </main>
  );
}
//   {active === "global" ? (
//     <Global />
//   ) : active === "following" ? (
//     <Global />
//   ) : (
//     <Global />
//   )}

function Global() {
  // const { api } = useLocalState();
  // const { isPending, data, refetch } = useQuery({
  //   queryKey: ["globalFeed"],
  //   queryFn: () => {
  //     return api!.scryFeed(null, null);
  //   },
  // });
  // console.log(data, "scry feed data");
  // if (isPending) return <img className="x-center" src={spinner} />;
  // else if ("bucun" in data) return <p>Error</p>;
  // else return <Inner data={data} refetch={refetch} />;
  return <p>Error</p>;
}
function Nostr() {
  const { nostrFeed, api } = useLocalState((s) => ({
    nostrFeed: s.nostrFeed,
    api: s.api,
  }));
  const [isSyncing, setIsSyncing] = useState(false);
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

export default Loader;
// TODO
type MixFeed = any;

function Inner({ data, refetch }: { data: MixFeed; refetch: Function }) {
  return <PostList data={data.mix.fc} refetch={refetch} />;
}
