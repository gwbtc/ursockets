// import spinner from "@/assets/icons/spinner.svg";
import Composer from "@/components/composer/Composer";
import PostList from "@/components/feed/PostList";
import useLocalState from "@/state/state";
import Icon from "@/components/Icon";
import toast from "react-hot-toast";
import { useEffect, useState } from "react";
import type { FC } from "@/types/trill";
import type { UserType } from "@/types/nostrill";

function UserFeed({
  user,
  userString,
  feed,
  isFollowLoading,
  setIsFollowLoading,
  isAccessLoading,
  setIsAccessLoading,
}: {
  user: UserType;
  userString: string;
  feed: FC | undefined;
  isFollowLoading: boolean;
  setIsFollowLoading: (b: boolean) => void;
  isAccessLoading: boolean;
  setIsAccessLoading: (b: boolean) => void;
}) {
  const { api, addProfile, addNotification, lastFact } = useLocalState((s) => ({
    api: s.api,
    addProfile: s.addProfile,
    addNotification: s.addNotification,
    lastFact: s.lastFact,
  }));
  const hasFeed = !feed ? false : Object.entries(feed).length > 0;
  const refetch = () => feed;

  const [fc, setFC] = useState<FC>();

  useEffect(() => {
    console.log("fact", lastFact);
    console.log(isFollowLoading);
    if (!isFollowLoading) return;
    const follow = lastFact?.fols;
    if (!follow) return;
    if ("new" in follow) {
      if (userString !== follow.new.user) return;
      toast.success(`Now following ${userString}`);
      setIsFollowLoading(false);
      addNotification({
        type: "follow",
        from: userString,
        message: `You are now following ${userString}`,
      });
    } else if ("quit" in follow) {
      toast.success(`Unfollowed ${userString}`);
      setIsFollowLoading(false);
      addNotification({
        type: "unfollow",
        from: userString,
        message: `You unfollowed ${userString}`,
      });
    }
  }, [lastFact, userString, isFollowLoading]);

  const handleFollow = async () => {
    if (!api) return;

    setIsFollowLoading(true);
    try {
      if (!!feed) {
        await api.unfollow(user);
      } else {
        await api.follow(user);
        toast.success(`Follow request sent to ${userString}`);
      }
    } catch (error) {
      toast.error(`Failed to ${!!feed ? "unfollow" : "follow"} ${userString}`);
      setIsFollowLoading(false);
      console.error("Follow error:", error);
    }
  };

  const handleRequestAccess = async () => {
    if (!api) return;
    if (!("urbit" in user)) return;

    setIsAccessLoading(true);
    try {
      const res = await api.peekFeed(user.urbit);
      toast.success(`Access request sent to ${user.urbit}`);
      addNotification({
        type: "access_request",
        from: userString,
        message: `Access request sent to ${userString}`,
      });
      if ("error" in res) toast.error(res.error);
      else {
        console.log("peeked", res.ok.feed);
        setFC(res.ok.feed);
        if (res.ok.profile) addProfile(userString, res.ok.profile);
      }
    } catch (error) {
      toast.error(`Failed to request access from ${user.urbit}`);
      console.error("Access request error:", error);
    } finally {
      setIsAccessLoading(false);
    }
  };
  console.log({ user, userString, feed, fc });

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
        <div id="feed-proper">
          <Composer />
          <PostList data={feed} refetch={refetch} />
        </div>
      ) : fc ? (
        <div id="feed-proper">
          <Composer />
          <PostList data={fc} refetch={refetch} />
        </div>
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
