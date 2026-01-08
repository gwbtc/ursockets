import useLocalState from "@/state/state";
import Icon from "@/components/Icon";
import spinner from "@/assets/triangles.svg";
import type { FC, FullFeed, FullNode } from "@/types/trill";
import Composer from "@/components/composer/Composer";
import type { UserProfile } from "@/types/nostrill";
import { useEffect, useState } from "react";
import toast from "react-hot-toast";
import { eventsToFF, eventToFn } from "@/logic/trill/helpers";
import { toFlat } from "../post/RP";
import type { NostrEvent } from "@/types/nostr";
import { createCache } from "@/logic/cache";
import Post from "../post/Post";
import Modal from "../modals/Modal";

type Props = {
  idString: string; // before decoding, nevent or hex or whatever
  host: string;
  id: string;
  feed?: FC;
  profile?: UserProfile;
};
const cache = createCache({ dbName: "nostrill", storeName: "nosted" });

export default function Thread(props: Props) {
  const { api, nostrFeed, composerData, setComposerData, setModal, lastFact } =
    useLocalState((s) => ({
      api: s.api,
      nostrFeed: s.nostrFeed,
      lastFact: s.lastFact,
      composerData: s.composerData,
      setComposerData: s.setComposerData,
      setModal: s.setModal,
    }));
  const { id, idString, feed, profile } = props;

  const poast = feed?.feed[id];
  const host = poast?.author || "";
  const [data, setData] = useState<FullFeed>();

  useEffect(() => {
    const event = nostrFeed[id];
    if (event) {
      console.log({ event });
      const fn = eventToFn(event);
      const ff = eventsToFF([fn]);
      setData(ff);
    }
  }, [id, nostrFeed]);

  useEffect(() => {
    if (!lastFact) return;
    if (!("nostr" in lastFact)) return;
    if (!("thread" in lastFact.nostr)) return;
    const thread = lastFact.nostr.thread;
    console.log({ thread, id });
    // TODO
    // thread can be an empty array. relays are unreliable like that
    // nevent to hex conversion works well, that's not the issue
    // might want to track which relay is providing what nostr data in the UI too so we can juggle different ones

    // toast.success("thread fetched succesfully, rendering");
    // cache.set("evs", lastFact.nostr.thread);
    // const nodes = lastFact.nostr.thread.map(eventToFn);
    // const ff = eventsToFF(nodes);
    // setData(ff);
  }, [lastFact]);

  console.log("nostr event", data);

  // if (event) return <Render event={}

  useEffect(() => {
    console.log({ composerData });
    if (composerData)
      setModal(
        <Modal
          close={() => {
            setComposerData(null);
          }}
        >
          <Composer />
        </Modal>,
      );
  }, [composerData]);
  // useTimeout(() => {
  //   if (!data) setError("Request timed out");
  // }, 10_000);
  //

  useEffect(() => {
    if (!api) return;
    const init = async () => {
      const cached: NostrEvent[] | null = await cache.get("evs");
      console.log("cached events", cached);
      // if (cached) {
      //   const nodes = cached.map(eventToFn);
      //   const ff = eventsToFF(nodes);
      //   setData(ff);
      // }
    };
    init();
  }, [id]);

  console.log({ data });

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
        <h2>Nostr Thread</h2>
        <div className="thread-info">
          <span className="thread-host">{host}</span>
          <span className="thread-separator">•</span>
          <span className="thread-id">#{id}</span>
        </div>
      </div>
      <div id="feed-proper">
        {data ? (
          <>
            <Head node={data[id]} profile={profile} />
          </>
        ) : (
          <Loader {...props} />
        )}
      </div>
    </>
  );
}

function Loader(props: Props) {
  const { id } = props;
  const { api, lastFact } = useLocalState((s) => ({
    api: s.api,
    nostrFeed: s.nostrFeed,
    lastFact: s.lastFact,
    composerData: s.composerData,
    setComposerData: s.setComposerData,
    setModal: s.setModal,
  }));
  const [error, setError] = useState("");

  async function tryAgain() {
    if (!api) return;
    setError("");
    const res = await api.nostrThread(id);
    if (res) toast.success("Sent request to relay");
  }

  return !error ? (
    <div className="text-center m-10 text-2xl">
      <h2>Error Loading Thread</h2>
      <p className="error">{error}</p>
      <button className="cycle-btn mx-auto my-8" onClick={tryAgain}>
        Try Again
      </button>
    </div>
  ) : (
    <>
      <h2 className="text-center my-8">Loading Thread...</h2>
      <div className="loading-container">
        <img className="x-center" src={spinner} alt="Loading" />
      </div>
      <button onClick={() => setError("timeout")}>Give Up </button>
    </>
  );
}
function Render({ event }: { event: NostrEvent }) {
  return <div>wtf</div>;
}
function Head({ node, profile }: { node: FullNode; profile?: UserProfile }) {
  return (
    <>
      <Post
        poast={toFlat(node)}
        user={{ nostr: node.author }}
        profile={profile}
      />
      <div id="thread-children">
        <Minithread ff={node.children} />
      </div>
    </>
  );
}

function Minithread({ ff }: { ff: FullFeed }) {
  const profiles = useLocalState((s) => s.profiles);
  const nodes = Object.values(ff);
  return (
    <div id="tail">
      {nodes.map((c) => {
        const profile = profiles.get(c.author);
        return (
          <div key={c.hash} className="minithread">
            <Post
              user={{ nostr: c.author }}
              poast={toFlat(c)}
              profile={profile}
            />
            <Grandchildren node={c} />
          </div>
        );
      })}
    </div>
  );
}
function Grandchildren({ node }: { node: FullNode }) {
  return (
    <div className="tail">
      <Minithread ff={node.children} />
    </div>
  );
}
