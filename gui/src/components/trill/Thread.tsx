import useLocalState from "@/state/state";
import Icon from "@/components/Icon";
import spinner from "@/assets/triangles.svg";
import Post from "@/components/post/Post";
import { toFlat } from "@/logic/trill/helpers";
import type { FC, FullNode, Poast } from "@/types/trill";
import type { UserProfile } from "@/types/nostrill";
import type { Ship } from "@/types/urbit";
import { useEffect, useState } from "react";
import Body from "../post/Body";
import Footer from "../post/Footer";
import Composer from "@/components/composer/Composer";

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
  const composerData = useLocalState((s) => s.composerData);

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
          <span className="thread-host">{host}</span>
          <span className="thread-separator">•</span>
          <span className="thread-id">#{id}</span>
        </div>
      </div>
      <div id="feed-proper">
        {composerData && <Composer />}
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
  const [ted, setThread] = useState<FullNode[]>([]);
  const [error, setError] = useState("");
  console.log({ data });
  console.log({ted})
  async function fetchThread() {
    const res = await api!.scryThread(host, id);
    console.log("scried thread", res);
    if ("error" in res) setError(res.error);
    else {
      setData(res.ok.node);
      setThread(res.ok.thread);
    }
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
  if (ted.length > 1)
    return <LongThread thread={ted} node={data} profile={profile} />;
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
  const [expandedPosts, setExpandedPosts] = useState<Set<string>>(new Set());

  const toggleExpanded = (postId: string) => {
    setExpandedPosts((prev) => {
      const next = new Set(prev);
      if (next.has(postId)) {
        next.delete(postId);
      } else {
        next.add(postId);
      }
      return next;
    });
  };

  return <ChildTreeInner node={node} expandedPosts={expandedPosts} toggleExpanded={toggleExpanded} />;
}

function ChildTreeInner({
  node,
  expandedPosts,
  toggleExpanded
}: {
  node: FullNode;
  expandedPosts: Set<string>;
  toggleExpanded: (postId: string) => void;
}) {
  const profiles = useLocalState((s) => s.profiles);
  const kids = Object.values(node.children || {});
  kids.sort((a, b) => b.time - a.time);

  return (
    <>
      {kids.map((k) => {
        const profile = profiles.get(k.author);
        const isExpanded = expandedPosts.has(k.id);
        const hasChildren = Object.keys(k.children || {}).length > 0;
        return (
          <div key={k.id} className="minithread">
            <Post
              user={{ urbit: k.author }}
              profile={profile}
              poast={toFlat(k)}
              onToggleReplies={hasChildren ? () => toggleExpanded(k.id) : undefined}
              repliesExpanded={isExpanded}
            />
            {isExpanded && hasChildren && (
              <div className="tail">
                <ChildTreeInner node={k} expandedPosts={expandedPosts} toggleExpanded={toggleExpanded} />
              </div>
            )}
          </div>
        );
      })}
    </>
  );
}

function LongThread({
  thread,
  profile,
}: {
  thread: FullNode[];
  node?: FullNode;
  profile?: UserProfile;
}) {
  const [expandedPosts, setExpandedPosts] = useState<Set<string>>(new Set());

  const toggleExpanded = (postId: string) => {
    setExpandedPosts((prev) => {
      const next = new Set(prev);
      if (next.has(postId)) {
        next.delete(postId);
      } else {
        next.add(postId);
      }
      return next;
    });
  };

  if (thread.length === 0) return <p>wtf</p>;
  const op = thread[0];
  return (
    <div id="trill-thread">
      <div id="thread-op">
        <Post
          poast={toFlat(op)}
          user={{ urbit: op.author }}
          profile={profile}
          thread={true}
        />
      </div>
      {thread.slice(1).map((child, i) => {
        const hasChildren = Object.keys(child.children || {}).length > 0;
        const isExpanded = expandedPosts.has(child.id);
        return (
          <div key={child.id} className="timeline-post trill-post cp thread-child">
            <div className="left">{`${i + 2}/${thread.length}`}</div>
            <div className="right">
              <Body poast={toFlat(child)} user={{ urbit: child.author }} />
              <Footer
                poast={toFlat(child)}
                user={{ urbit: child.author }}
                thread={true}
                onToggleReplies={hasChildren ? () => toggleExpanded(child.id) : undefined}
                repliesExpanded={isExpanded}
              />
              {isExpanded && hasChildren && (
                <div className="tail">
                  <ChildTreeInner node={child} expandedPosts={expandedPosts} toggleExpanded={toggleExpanded} />
                </div>
              )}
            </div>
          </div>
        );
      })}
    </div>
  );
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
