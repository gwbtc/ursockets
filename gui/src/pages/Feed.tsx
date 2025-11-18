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
import { ErrorPage } from "@/Router";
import NostrFeed from "@/components/nostr/Feed";

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
          <Following />
        ) : active === "nostr" ? (
          <NostrFeed />
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
function Following() {
  const following = useLocalState((s) => s.following2);
  console.log({ following });

  // console.log(data, "scry feed data");
  // if (isPending) return <img className="x-center" src={spinner} />;
  // else if ("bucun" in data) return <p>Error</p>;
  // else return <Inner data={data} refetch={refetch} />;

  return (
    <div>
      <PostList data={following} refetch={() => {}} />
    </div>
  );
}

export default Loader;
// TODO
type MixFeed = any;

function Inner({ data, refetch }: { data: MixFeed; refetch: Function }) {
  return <PostList data={data.mix.fc} refetch={refetch} />;
}
