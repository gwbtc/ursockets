import useLocalState from "@/state/state";
import { useState } from "react";
import Icon from "@/components/Icon";
import toast from "react-hot-toast";
import type { UserType } from "@/types/nostrill";
import type { FC } from "@/types/trill";
import Composer from "../composer/Composer";
import PostList from "@/components/feed/PostList";

export default function NostrUser({
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
  const { api } = useLocalState((s) => ({
    api: s.api,
  }));
  const [fc, setFC] = useState<FC>();

  // Show empty state with resync option when no feed data

  async function refetch() {
    //
  }
  async function handleFollow() {
    if (!api) return;

    setIsFollowLoading(true);
    try {
      if (feed) {
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
  }
  async function handleRequestAccess() {
    if (!api) return;

    setIsAccessLoading(true);
    // try {
    //   const res = await api.peekFeed(user.urbit);
    //   toast.success(`Access request sent to ${user.urbit}`);
    //   addNotification({
    //     type: "access_request",
    //     from: userString,
    //     message: `Access request sent to ${userString}`,
    //   });
    //   if ("error" in res) toast.error(res.error);
    //   else {
    //     console.log("peeked", res.ok.feed);
    //     setFC(res.ok.feed);
    //     if (res.ok.profile) addProfile(userString, res.ok.profile);
    //   }
    // } catch (error) {
    //   toast.error(`Failed to request access from ${user.urbit}`);
    //   console.error("Access request error:", error);
    // } finally {
    //   setIsAccessLoading(false);
    // }
  }
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

        {(!feed || !feed.feed || Object.keys(feed.feed).length === 0) && (
          <button
            onClick={handleRequestAccess}
            disabled={isAccessLoading}
            className="action-btn access"
          >
            {isAccessLoading ? (
              <>
                <Icon name="settings" size={16} />
                Fetching...
              </>
            ) : (
              <>
                <Icon name="key" size={16} />
                Fetch Feed
              </>
            )}
          </button>
        )}
      </div>
      {(feed || fc) && (
        <div id="feed-proper">
          <Composer />
          <PostList data={(feed || fc)!} refetch={refetch} />
        </div>
      )}
    </>
  );
}
