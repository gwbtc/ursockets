// import spinner from "@/assets/icons/spinner.svg";
import Composer from "@/components/composer/Composer";
import PostList from "@/components/feed/PostList";
import useLocalState from "@/state/state";
import Icon from "@/components/Icon";
import toast from "react-hot-toast";
import { useEffect, useState } from "react";
import type { FC } from "@/types/trill";
import type { Ship } from "@/types/urbit";

function UserFeed({
  patp,
  feed,
  isFollowLoading,
  setIsFollowLoading,
  isAccessLoading,
  setIsAccessLoading,
}: {
  patp: Ship;
  feed: FC | undefined;
  isFollowLoading: boolean;
  setIsFollowLoading: (b: boolean) => void;
  isAccessLoading: boolean;
  setIsAccessLoading: (b: boolean) => void;
}) {
  const { api, addProfile, lastFact } = useLocalState((s) => ({
    api: s.api,
    addProfile: s.addProfile,
    lastFact: s.lastFact,
  }));
  const hasFeed = !feed ? false : Object.entries(feed).length > 0;
  const refetch = () => feed;

  const [fc, setFC] = useState<FC>();

  useEffect(() => {
    console.log("fact", lastFact);
    console.log(isFollowLoading);
    if (!isFollowLoading) return;
    if (!lastFact) return;
    if (!("fols" in lastFact)) return;
    const follow = lastFact.fols;
    if (!follow) return;
    console.log("last fact", lastFact);
    if ("new" in follow) {
      console.log(follow.new.user);
      if (patp !== follow.new.user) return;
      if (follow.new.data.data === "maybe") {
        const toastMsg = `${follow.new.user} will review your follow request manually.`;
        const msg = follow.new.data.msg
          ? toastMsg + `\nHe added: ${follow.new.data.msg}.`
          : toastMsg;
        toast.success(msg, { duration: 5000 });
      } else if (follow.new.data.data === null) {
        const toastMsg = `${follow.new.user} denied your follow request.`;
        const msg = follow.new.data.msg
          ? toastMsg + `\nHe added: ${follow.new.data.msg}.`
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

  const handleRequestAccess = async () => {
    if (!api) return;
    setIsAccessLoading(true);
    try {
      const res = await api.peekFeed(patp);
      toast.success(`Access request sent to ${patp}`);
      if ("error" in res) toast.error(res.error);
      else {
        console.log("peeked", res);
        if (res.ok.data === "maybe") {
          const toastMsg = `${patp} will review your access request manually.`;
          const msg = res.ok.msg
            ? toastMsg + `\nHe added: ${res.ok.msg}.`
            : toastMsg;
          toast.success(msg, { duration: 5000 });
        } else if (!res.ok.data) {
          const toastMsg = `${patp} denied your access request.`;
          const msg = res.ok.msg
            ? toastMsg + `\nHe added: ${res.ok.msg}.`
            : toastMsg;
          toast.error(msg, { duration: 5000 });
        } else {
          const toastMsg = `${patp} granted your access request.`;
          const msg = res.ok.msg
            ? toastMsg + `\nHe added: ${res.ok.msg}.`
            : toastMsg;
          toast.success(msg);
          setFC(res.ok.data.feed);
          if (res.ok.data.profile) addProfile(patp, res.ok.data.profile);
        }
      }
    } catch (error) {
      toast.error(`Failed to request access from ${patp}`);
      console.error("Access request error:", error);
    } finally {
      setIsAccessLoading(false);
    }
  };
  console.log({ patp, feed, fc });

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
      ) : fc ? (
        <Inner feed={fc} refetch={refetch} />
      ) : null}

      {!feed && !fc && (
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
