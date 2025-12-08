import type { PostProps } from "./Post";
import Icon from "@/components/Icon";
import { useState } from "react";
import useLocalState from "@/state/state";
import { useLocation } from "wouter";
import { displayCount } from "@/logic/utils";
import { TrillReactModal, stringToReact } from "./Reactions";
import toast from "react-hot-toast";
import NostrIcon from "./wrappers/NostrIcon";
import type { SPID } from "@/types/ui";
// TODO abstract this somehow

function Footer({ user, poast, thread, refetch }: PostProps) {
  const [_showMenu, setShowMenu] = useState(false);
  const [location, navigate] = useLocation();
  const [reposting, _setReposting] = useState(false);
  const { api, setComposerData, setModal } = useLocalState((s) => ({
    api: s.api,
    setComposerData: s.setComposerData,
    setModal: s.setModal,
  }));
  const our = api!.airlock.our!;
  function getComposerData(): SPID {
    return user && "urbit" in user
      ? { trill: poast }
      : { nostr: { post: poast, pubkey: user?.nostr || "", eventId: poast.hash } };
  }
  function doReply(e: React.MouseEvent) {
    console.log("do reply");
    e.stopPropagation();
    e.preventDefault();
    setComposerData({ type: "reply", post: getComposerData() });
    // Scroll to top where composer is located
    window.scrollTo({ top: 0, behavior: "smooth" });
    // Focus will be handled by the composer component
  }
  function doQuote(e: React.MouseEvent) {
    e.stopPropagation();
    e.preventDefault();
    setComposerData({
      type: "quote",
      post: getComposerData(),
    });
    // Scroll to top where composer is located
    window.scrollTo({ top: 0, behavior: "smooth" });
  }
  const childrenCount = poast.children
    ? poast.children.length
      ? poast.children.length
      : Object.keys(poast.children).length
    : 0;
  const myRP = poast.engagement.shared.find((r) => r.pid.ship === our);
  async function cancelRP(e: React.MouseEvent) {
    e.stopPropagation();
    e.preventDefault();
    const r = await api!.deletePost(user, poast.id);
    if (r) toast.success("Repost deleted");
    // refetch();
    if (location.includes(poast.id)) navigate("/");
  }
  async function sendRP(e: React.MouseEvent) {
    // TODO update backend because contents are only markdown now
    e.stopPropagation();
    e.preventDefault();
    const id = user && "urbit" in user ? poast.id : poast.hash;
    const r = await api!.addRP(user, id);
    if (r) {
      toast.success("Your repost was published");
    }
  }
  function doReact(e: React.MouseEvent) {
    e.stopPropagation();
    e.preventDefault();
    const modal = <TrillReactModal user={user} poast={poast} />;
    setModal(modal);
  }
  function showReplyCount() {
    if (poast.children[0]) fetchAndShow(); // Flatpoast
    // else {
    //   const authors = Object.keys(poast.children).map(
    //     (i) => poast.children[i].post.author
    //   );
    //   setEngagement({ type: "replies", ships: authors }, poast);
    // }
  }
  async function fetchAndShow() {
    // let authors = [];
    // for (let i of poast.children as string[]) {
    //   const res = await scrypoastFull(poast.host, i);
    //   if (res)
    //   authors.push(res.post.author || "deleter");
    // }
    // setEngagement({ type: "replies", ships: authors }, poast);
  }
  function showRepostCount() {
    // const ships = poast.engagement.shared.map((entry) => entry.host);
    // setEngagement({ type: "reposts", ships: ships }, poast);
  }
  function showQuoteCount() {
    // setEngagement({ type: "quotes", quotes: poast.engagement.quoted }, poast);
  }
  function showReactCount() {
    // setEngagement({ type: "reacts", reacts: poast.engagement.reacts }, poast);
  }

  const mostCommonReact = Object.values(poast.engagement.reacts).reduce(
    (acc: any, item) => {
      if (!acc.counts[item]) acc.counts[item] = 0;
      acc.counts[item] += 1;
      if (!acc.winner || acc.counts[item] > acc.counts[acc.winner])
        acc.winner = item;
      return acc;
    },
    { counts: {}, winner: "" },
  ).winner;
  const reactIcon = stringToReact(mostCommonReact);

  // TODO round up all helpers

  return (
    <div className="footer-wrapper post-footer">
      <footer>
        {!thread && (
          <div className="icon">
            <span
              role="link"
              onMouseUp={showReplyCount}
              className="reply-count"
            >
              {displayCount(childrenCount)}
            </span>
            <div className="icon-wrapper" role="link" onMouseUp={doReply}>
              <Icon name="reply" />
            </div>
          </div>
        )}
        <div className="icon">
          <span role="link" onMouseUp={showQuoteCount} className="quote-count">
            {displayCount(poast.engagement.quoted.length)}
          </span>
          <div className="icon-wrapper" role="link" onMouseUp={doQuote}>
            <Icon name="quote" />
          </div>
        </div>
        <div className="icon">
          <span
            role="link"
            onMouseUp={showRepostCount}
            className="repost-count"
          >
            {displayCount(poast.engagement.shared.length)}
          </span>
          {reposting ? (
            <p>...</p>
          ) : myRP ? (
            <div className="icon-wrapper" role="link" onMouseUp={cancelRP}>
              <Icon name="repost" className="my-rp" title="cancel repost" />
            </div>
          ) : (
            <div className="icon-wrapper" role="link" onMouseUp={sendRP}>
              <Icon name="repost" title="repost" />
            </div>
          )}
        </div>
        <div className="icon" role="link" onMouseUp={doReact}>
          <span
            role="link"
            onMouseUp={showReactCount}
            className="reaction-count"
          >
            {displayCount(Object.keys(poast.engagement.reacts).length)}
          </span>
          {reactIcon}
        </div>
        <NostrIcon poast={poast} />
      </footer>
    </div>
  );
}
export default Footer;

// function Menu({
//   poast,
//   setShowMenu,
//   refetch,
// }: {
//   poast: Poast;
//   setShowMenu: Function;
//   refetch: Function;
// }) {
//   const ref = useRef<HTMLDivElement>(null);
//   const [location, navigate] = useLocation();
//   // TODO this is a mess and the event still propagates
//   useEffect(() => {
//     const checkIfClickedOutside = (e: any) => {
//       e.stopPropagation();
//       if (ref && ref.current && !ref.current.contains(e.target))
//         setShowMenu(false);
//     };
//     document.addEventListener("mousedown", checkIfClickedOutside);
//     return () => {
//       document.removeEventListener("mousedown", checkIfClickedOutside);
//     };
//   }, []);
//   const { our, setModal, setAlert } = useLocalState();
//   const mine = our === poast.host || our === poast.author;
//   async function doDelete(e: React.MouseEvent) {
//     e.stopPropagation();
//     deletePost(poast.host, poast.id);
//     setAlert("Post deleted");
//     setShowMenu(false);
//     refetch();
//     if (location.includes(poast.id)) navigate("/");
//   }
//   async function copyLink(e: React.MouseEvent) {
//     e.stopPropagation();
//     const link = trillPermalink(poast);
//     await navigator.clipboard.writeText(link);
//     // some alert
//     setShowMenu(false);
//   }
//   function openStats(e: React.MouseEvent) {
//     e.stopPropagation();
//     e.preventDefault();
//     const m = <StatsModal poast={poast} close={() => setModal(null)} />;
//     setModal(m);
//   }
//   return (
//     <div ref={ref} id="post-menu">
//       {/* <p onClick={openShare}>Share to Groups</p> */}
//       <p role="link" onMouseUp={openStats}>
//         See Stats
//       </p>
//       <p role="link" onMouseUp={copyLink}>
//         Permalink
//       </p>
//       {mine && (
//         <p role="link" onMouseUp={doDelete}>
//           Delete Post
//         </p>
//       )}
//     </div>
//   );
// }
