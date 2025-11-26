import "@/styles/trill.css";
import "@/styles/feed.css";
import PostList from "@/components/feed/PostList";
import useLocalState from "@/state/state";
import { useParams } from "wouter";
import spinner from "@/assets/triangles.svg";
import { useState } from "react";
import Composer from "@/components/composer/Composer";
import { ErrorPage } from "@/pages/Error";
import NostrFeed from "@/components/nostr/Feed";
import { consolidateFeeds, disaggregate } from "@/logic/nostrill";

type FeedType = "urbit" | "following" | "nostr";
function Loader() {
  const params = useParams();
  if (!params.taip) return <FeedPage t="nostr" />;
  // if (params.taip === "urbit") return <FeedPage t={"urbit"} />;
  if (params.taip === "following") return <FeedPage t={"following"} />;
  if (params.taip === "nostr") return <FeedPage t={"nostr"} />;
  // else if (param === FeedType.Rumors) return <Rumors />;
  // else if (param === FeedType.Home) return <UserFeed p={our} />;
  else return <ErrorPage msg="No such page" />;
}
function FeedPage({ t }: { t: FeedType }) {
  const [active, setActive] = useState<FeedType>(t);
  return (
    <>
      <div id="top-tabs">
        <div
          className={active === "urbit" ? "active" : ""}
          onClick={() => setActive("urbit")}
        >
          Urbit
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
        {active === "urbit" ? (
          <Urbit />
        ) : active === "following" ? (
          <Following />
        ) : active === "nostr" ? (
          <NostrFeed />
        ) : null}
      </div>
    </>
  );
}

function Urbit() {
  const following = useLocalState((s) => s.following);
  const feed = disaggregate(following, "urbit");
  return (
    <div>
      <PostList data={feed} refetch={() => {}} />
    </div>
  );
}
function Following() {
  const following = useLocalState((s) => s.following);
  const feed = consolidateFeeds(following);
  return (
    <div>
      <PostList data={feed} refetch={() => {}} />
    </div>
  );
}

export default Loader;
// TODO
type MixFeed = any;

function Inner({ data, refetch }: { data: MixFeed; refetch: Function }) {
  return <PostList data={data.mix.fc} refetch={refetch} />;
}
