import { useParams } from "wouter";
import { useQuery } from "@tanstack/react-query";
import useLocalState from "@/state/state";
import PostList from "@/components/feed/PostList";
import Composer from "@/components/composer/Composer";
import Icon from "@/components/Icon";
import spinner from "@/assets/triangles.svg";
import { ErrorPage } from "@/Router";
import "@/styles/trill.css";
import "@/styles/feed.css";
import Post from "@/components/post/Post";
import { toFlat } from "@/logic/trill/helpers";

export default function Thread() {
  const params = useParams<{ host: string; id: string }>();
  const { host, id } = params;
  const { api } = useLocalState((s) => ({ api: s.api }));

  async function fetchThread() {
    return await api!.scryThread(host, id);
  }
  const { isPending, data, error, refetch } = useQuery({
    queryKey: ["thread", params.host, params.id],
    queryFn: fetchThread,
    enabled: !!api && !!params.host && !!params.id,
  });

  console.log({ data });
  if (!params.host || !params.id) {
    return <ErrorPage msg="Invalid thread URL" />;
  }

  if (isPending) {
    return (
      <main>
        <div className="thread-header">
          <h2>Loading Thread...</h2>
        </div>
        <div className="loading-container">
          <img className="x-center" src={spinner} alt="Loading" />
        </div>
      </main>
    );
  }

  if (error) {
    return (
      <main>
        <div className="thread-header">
          <h2>Error Loading Thread</h2>
        </div>
        <ErrorPage msg={error.message || "Failed to load thread"} />
      </main>
    );
  }

  if (!data || "error" in data) {
    return (
      <main>
        <div className="thread-header">
          <h2>Thread Not Found</h2>
        </div>
        <ErrorPage
          msg={data?.error || "This thread doesn't exist or isn't accessible"}
        />
      </main>
    );
  }

  return (
    <main>
      <div className="thread-header">
        <div className="thread-nav">
          <button
            className="back-btn"
            onClick={() => window.history.back()}
            title="Go back"
          >
            <Icon name="reply" size={16} />
            <span>Back to Feed</span>
          </button>
        </div>
        <h2>Thread</h2>
        <div className="thread-info">
          <span className="thread-host">~{params.host}</span>
          <span className="thread-separator">•</span>
          <span className="thread-id">#{params.id}</span>
        </div>
      </div>

      <div id="feed-proper">
        <Composer />
        <div className="thread-content">
          <Post poast={toFlat(data.ok)} />
        </div>
      </div>
    </main>
  );
}
// function OwnData(props: Props) {
//   const { api } = useLocalState((s) => ({
//     api: s.api,
//   }));
//   const { host, id } = props;
//   async function fetchThread() {
//     return await api!.scryThread(host, id);
//   }
//   const { isLoading, isError, data, refetch } = useQuery({
//     queryKey: ["trill-thread", host, id],
//     queryFn: fetchThread,
//   });
//   return isLoading ? (
//     <div className={props.className}>
//       <div className="x-center not-found">
//         <p className="x-center">Scrying Post, please wait...</p>
//         <img src={spinner} className="x-center s-100" alt="" />
//       </div>
//     </div>
//   ) : null;
// }
// function SomeoneElses(props: Props) {
//   // const { api, following } = useLocalState((s) => ({
//   //   api: s.api,
//   //   following: s.following,
//   // }));
//   return <div>ho</div>;
// }
