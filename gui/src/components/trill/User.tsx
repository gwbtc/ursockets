// import spinner from "@/assets/icons/spinner.svg";
import Composer from "@/components/composer/Composer";
import PostList from "@/components/feed/PostList";
import useLocalState from "@/state/state";
import Icon from "@/components/Icon";
import toast from "react-hot-toast";
import { useEffect } from "react";
import type { FC } from "@/types/trill";
import type { Ship } from "@/types/urbit";
import { useRequestAccess } from "@/hooks/useRequestAccess";

function UserFeed({
  patp,
  feed,
  isFollowLoading,
  setIsFollowLoading,
}: {
  patp: Ship;
  feed: FC | undefined;
  isFollowLoading: boolean;
  setIsFollowLoading: (b: boolean) => void;
}) {
  const { api, lastFact } = useLocalState((s) => ({
    api: s.api,
    lastFact: s.lastFact,
  }));
  const {
    requestAccess,
    isLoading: isAccessLoading,
    feed: accessFeed,
  } = useRequestAccess();
  const hasFeed = !feed ? false : Object.entries(feed).length > 0;
  const refetch = () => feed;

  useEffect(() => {
    console.log("fact", lastFact);
    console.log(isFollowLoading);
    if (!isFollowLoading) return;
    if (!lastFact) return;
    if (!("fols" in lastFact)) return;
    const follow = lastFact.fols;
    if (!follow) return;
    console.log("last fact", lastFact);
    if ("new-urbit" in follow) {
      const d = follow["new-urbit"];
      console.log(d.user);
      if (patp !== d.user) return;
      if (d.data.data === "maybe") {
        const toastMsg = `${d.user} will review your follow request manually.`;
        const msg = d.data.msg
          ? toastMsg + `\nHe added: ${d.data.msg}.`
          : toastMsg;
        toast.success(msg, { duration: 5000 });
      } else if (d.data.data === null) {
        const toastMsg = `${d.user} denied your follow request.`;
        const msg = d.data.msg
          ? toastMsg + `\nHe added: ${d.data.msg}.`
          : toastMsg;
        toast.error(msg, { duration: 5000 });
      } else toast.success(`Now following ${patp}`);
      //
      setIsFollowLoading(false);
    } else if ("quit" in follow) {
      toast.success(`Unfollowed ${patp}`);
      setIsFollowLoading(false);
    }
  }, [lastFact, patp, isFollowLoading]);

  const handleFollow = async () => {
    if (!api) return;

    setIsFollowLoading(true);
    try {
      if (!!feed) {
        await api.unfollow({ urbit: patp });
      } else {
        await api.follow({ urbit: patp });
        toast.success(`Follow request sent to ${patp}`);
      }
    } catch (error) {
      toast.error(`Failed to ${!!feed ? "unfollow" : "follow"} ${patp}`);
      setIsFollowLoading(false);
      console.error("Follow error:", error);
    }
  };

  const handleRequestAccess = () => requestAccess(patp);

  return (
    <>
      <div className="user-actions">
        <button
          onClick={handleFollow}
          disabled={isFollowLoading}
          className={`action-btn ${!!feed ? "" : "follow"}`}
        >
          {isFollowLoading ? (
            <>
              <Icon name="settings" size={16} />
              {!!feed ? "Unfollowing..." : "Following..."}
            </>
          ) : (
            <>
              <Icon name={!!feed ? "bell" : "pals"} size={16} />
              {!!feed ? "Unfollow" : "Follow"}
            </>
          )}
        </button>

        <button
          onClick={handleRequestAccess}
          disabled={isAccessLoading}
          className="action-btn access"
        >
          {isAccessLoading ? (
            <>
              <Icon name="settings" size={16} />
              Requesting...
            </>
          ) : (
            <>
              <Icon name="key" size={16} />
              Request Access
            </>
          )}
        </button>
      </div>

      {feed && hasFeed ? (
        <Inner feed={feed} refetch={refetch} />
      ) : accessFeed ? (
        <Inner feed={accessFeed} refetch={refetch} />
      ) : null}

      {!feed && !accessFeed && (
        <div id="other-user-feed">
          <div className="empty-feed-message">
            <Icon name="messages" size={48} color="textMuted" />
            <h3>No Posts Available</h3>
            <p>
              This user's posts are not publicly visible.
              {!!feed && " Try following them"} or request temporary access to
              see their content.
            </p>
          </div>
        </div>
      )}
    </>
  );
}

export default UserFeed;

export function Inner({ feed, refetch }: { feed: FC; refetch: any }) {
  return (
    <div id="feed-proper">
      <Composer />
      <PostList data={feed} refetch={refetch} />
    </div>
  );
}
