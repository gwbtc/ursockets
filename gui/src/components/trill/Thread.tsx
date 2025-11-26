import useLocalState from "@/state/state";
import Icon from "@/components/Icon";
import spinner from "@/assets/triangles.svg";
import Post from "@/components/post/Post";
import { extractThread, toFlat } from "@/logic/trill/helpers";
import type { FC, FullNode, Poast } from "@/types/trill";
import Composer from "@/components/composer/Composer";
import type { UserProfile } from "@/types/nostrill";
import type { Ship } from "@/types/urbit";
import { useEffect, useState } from "react";

export default function Thread({
  host,
  id,
  feed,
  profile,
}: {
  host: Ship;
  id: string;
  feed?: FC;
  profile?: UserProfile;
}) {
  const poast = feed?.feed[id];
  console.log({ poast });
  return (
    <>
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
          <span className="thread-host">~{host}</span>
          <span className="thread-separator">•</span>
          <span className="thread-id">#{id}</span>
        </div>
      </div>
      <div id="feed-proper">
        {poast && poast.children.length === 0 ? (
          <Head poast={poast} profile={profile} />
        ) : (
          <Loader poast={poast} host={host} id={id} profile={profile} />
        )}
      </div>
    </>
  );
}
function Loader({
  host,
  id,
  profile,
  poast,
}: {
  host: Ship;
  id: string;
  poast?: Poast;
  profile?: UserProfile;
}) {
  const api = useLocalState((s) => s.api);
  const [data, setData] = useState<FullNode>();
  const [error, setError] = useState("");
  console.log({ data });
  async function fetchThread() {
    const res = await api!.scryThread(host, id);
    if ("error" in res) setError(res.error);
    else setData(res.ok);
  }
  useEffect(() => {
    fetchThread();
  }, [host, id]);

  if (data)
    return (
      <>
        <Head poast={toFlat(data)} profile={profile} />
        <div id="thread-children">
          <ChildTree node={data} />
        </div>
      </>
    );
  if (poast)
    return (
      <>
        <Head poast={poast} profile={profile} />
        <div id="thread-children">
          <h2>Loading Replies...</h2>
          <div className="loading-container">
            <img className="x-center" src={spinner} alt="Loading" />
          </div>
        </div>
      </>
    );
  if (error)
    return (
      <div className="thread-header">
        <h2>Error Loading Thread</h2>
        <p className="error">{error}</p>
      </div>
    );
  else
    return (
      <div id="feed-proper">
        <h2>Loading Thread...</h2>
        <div className="loading-container">
          <img className="x-center" src={spinner} alt="Loading" />
        </div>
      </div>
    );
}

function Head({ poast, profile }: { poast: Poast; profile?: UserProfile }) {
  return (
    <div id="thread-head">
      <Post user={{ urbit: poast.host }} poast={poast} profile={profile} />
    </div>
  );
}

function ChildTree({ node }: { node: FullNode }) {
  const profiles = useLocalState((s) => s.profiles);
  const kids = Object.values(node.children || {});
  kids.sort((a, b) => b.time - a.time);
  return (
    <>
      {kids.map((k) => {
        const profile = profiles.get(k.author);
        return (
          <div key={k.id} className="minithread">
            <Post
              user={{ urbit: k.author }}
              profile={profile}
              poast={toFlat(k)}
            />
            <Grandchildren node={k} />
          </div>
        );
      })}
    </>
  );
  function Grandchildren({ node }: { node: FullNode }) {
    return (
      <div className="tail">
        <ChildTree node={node} />
      </div>
    );
  }
}
// function ChildTree({ node }: { node: FullNode }) {
//   const { threadChildren, replies } = extractThread(node);
//   return (
//     <>
//       <div id="tail">
//         {threadChildren.map((n) => {
//           return (
//             <Post user={{ urbit: n.author }} key={n.id} poast={toFlat(n)} />
//           );
//         })}
//       </div>
//       <div id="replies">
//         {replies.map((n) => (
//           <ReplyThread key={n.id} node={n} />
//         ))}
//       </div>
//     </>
//   );
// }

// function ReplyThread({ node }: { node: FullNode }) {
//   // const { threadChildren, replies } = extractThread(node);
//   const { replies } = extractThread(node);
//   return (
//     <div className="trill-reply-thread">
//       <div className="head">
//         <Post user={{ urbit: node.author }} poast={toFlat(node)} />
//       </div>
//       <div className="tail">
//         {replies.map((r) => (
//           <Post key={r.id} user={{ urbit: r.author }} poast={toFlat(r)} />
//         ))}
//       </div>
//     </div>
//   );
// }

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
