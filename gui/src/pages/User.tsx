// import spinner from "@/assets/icons/spinner.svg";
import Composer from "@/components/composer/Composer";
import PostList from "@/components/feed/PostList";
import Profile from "@/components/profile/Profile";
import useLocalState, { useStore } from "@/state/state";
import Icon from "@/components/Icon";
import toast from "react-hot-toast";
import { useEffect, useState } from "react";
import type { FC } from "@/types/trill";
import type { UserType } from "@/types/nostrill";
import { isValidPatp } from "urbit-ob";
import { isValidNostrPubkey } from "@/logic/nostrill";
import { ErrorPage } from "@/Router";

function UserLoader({ userString }: { userString: string }) {
  const { api, pubkey } = useLocalState((s) => ({
    api: s.api,
    pubkey: s.pubkey,
  }));
  // auto updating on SSE doesn't work if we do shallow

  const user = isValidPatp(userString)
    ? { urbit: userString }
    : isValidNostrPubkey(userString)
      ? { nostr: userString }
      : { error: "" };

  const isOwnProfile =
    "urbit" in user
      ? user.urbit === api?.airlock.our
      : "nostr" in user
        ? pubkey === user.nostr
        : false;
  if ("error" in user) return <ErrorPage msg={"Invalid user"} />;
  else
    return <UserFeed user={user} userString={userString} isMe={isOwnProfile} />;
}

function UserFeed({
  user,
  userString,
  isMe,
}: {
  user: UserType;
  userString: string;
  isMe: boolean;
}) {
  const { api, addProfile, addNotification, lastFact } = useLocalState((s) => ({
    api: s.api,
    addProfile: s.addProfile,
    addNotification: s.addNotification,
    lastFact: s.lastFact,
  }));
  // auto updating on SSE doesn't work if we do shallow
  const { following } = useStore();
  const feed = following.get(userString);
  const hasFeed = !feed ? false : Object.entries(feed).length > 0;
  const refetch = () => feed;
  const isFollowing = following.has(userString);

  const [isFollowLoading, setIsFollowLoading] = useState(false);
  const [isAccessLoading, setIsAccessLoading] = useState(false);
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
      if (isFollowing) {
        await api.unfollow(user);
      } else {
        await api.follow(user);
        toast.success(`Follow request sent to ${userString}`);
      }
    } catch (error) {
      toast.error(
        `Failed to ${isFollowing ? "unfollow" : "follow"} ${userString}`,
      );
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
    <div id="user-page">
      <Profile user={user} userString={userString} isMe={isMe} />

      {!isMe && (
        <div className="user-actions">
          <button
            onClick={handleFollow}
            disabled={isFollowLoading}
            className={`action-btn ${isFollowing ? "" : "follow"}`}
          >
            {isFollowLoading ? (
              <>
                <Icon name="settings" size={16} />
                {isFollowing ? "Unfollowing..." : "Following..."}
              </>
            ) : (
              <>
                <Icon name={isFollowing ? "bell" : "pals"} size={16} />
                {isFollowing ? "Unfollow" : "Follow"}
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
      )}

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

      {!isMe && !feed && !fc && (
        <div id="other-user-feed">
          <div className="empty-feed-message">
            <Icon name="messages" size={48} color="textMuted" />
            <h3>No Posts Available</h3>
            <p>
              This user's posts are not publicly visible.
              {!isFollowing && " Try following them"} or request temporary
              access to see their content.
            </p>
          </div>
        </div>
      )}
    </div>
  );
}

export default UserLoader;
