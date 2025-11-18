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
import { ErrorPage } from "@/pages/Error";
import { useParams } from "wouter";
import { isValidNostrKey } from "@/logic/nostr";
import TrillFeed from "@/components/trill/User";
import NostrFeed from "@/components/nostr/User";

function UserLoader() {
  const params = useParams();
  console.log({ params });
  const userString = params.user;
  if (!userString) return <ErrorPage msg="no such user" />;
  else if (isValidPatp(userString))
    return <UserFeed user={{ urbit: userString }} userString={userString} />;
  else if (isValidNostrKey(userString))
    return <UserFeed user={{ nostr: userString }} userString={userString} />;
  else return <ErrorPage msg="no such user" />;
}

function UserFeed({
  user,
  userString,
}: {
  user: UserType;
  userString: string;
}) {
  const { api, pubkey } = useLocalState((s) => ({
    api: s.api,
    addProfile: s.addProfile,
    addNotification: s.addNotification,
    lastFact: s.lastFact,
    pubkey: s.pubkey,
  }));
  const isMe =
    "urbit" in user
      ? user.urbit === api?.airlock.our
      : "nostr" in user
        ? pubkey === user.nostr
        : false;
  // auto updating on SSE doesn't work if we do shallow
  const { following } = useStore();
  const feed = following.get(userString);
  const hasFeed = !feed ? false : Object.entries(feed).length > 0;
  const refetch = () => feed;

  const [isFollowLoading, setIsFollowLoading] = useState(false);
  const [isAccessLoading, setIsAccessLoading] = useState(false);

  return (
    <div id="user-page">
      <Profile user={user} userString={userString} isMe={isMe} />
      {isMe ? (
        <MyFeed />
      ) : "urbit" in user ? (
        <TrillFeed
          user={user}
          userString={userString}
          feed={feed}
          isFollowLoading={isFollowLoading}
          setIsFollowLoading={setIsFollowLoading}
          isAccessLoading={isAccessLoading}
          setIsAccessLoading={setIsAccessLoading}
        />
      ) : "nostr" in user ? (
        <NostrFeed
          user={user}
          userString={userString}
          feed={feed}
          isFollowLoading={isFollowLoading}
          setIsFollowLoading={setIsFollowLoading}
          isAccessLoading={isAccessLoading}
          setIsAccessLoading={setIsAccessLoading}
        />
      ) : null}
    </div>
  );
}

export default UserLoader;

function MyFeed() {
  return <></>;
}
