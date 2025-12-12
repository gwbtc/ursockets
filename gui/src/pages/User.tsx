import Profile from "@/components/profile/Profile";
import useLocalState, { useStore } from "@/state/state";
import { useState } from "react";
import type { UserType } from "@/types/nostrill";
import { isValidPatp } from "urbit-ob";
import { ErrorPage } from "@/pages/Error";
import { useParams } from "wouter";
import { decodeNostrKey } from "@/logic/nostr";
import TrillFeed, { Inner } from "@/components/trill/User";
import NostrFeed from "@/components/nostr/User";

function UserLoader() {
  const params = useParams();
  console.log({ params });
  const userString = params.user;
  if (!userString) return <ErrorPage msg="no such user" />;
  else if (isValidPatp(userString))
    return <UserFeed user={{ urbit: userString }} userString={userString} />;
  else {
    const nostrKey = decodeNostrKey(userString);
    if (nostrKey)
      return <UserFeed user={{ nostr: nostrKey }} userString={userString} />;
    else return <ErrorPage msg="no such user" />;
  }
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
  const userString2 = "urbit" in user ? user.urbit : user.nostr;
  const feed = following.get(userString2);

  const [isFollowLoading, setIsFollowLoading] = useState(false);
  const [isAccessLoading, setIsAccessLoading] = useState(false);

  return (
    <div id="user-page">
      <Profile user={user} userString={userString} isMe={isMe} />
      {isMe ? (
        <MyFeed our={api!.airlock.our!} />
      ) : "urbit" in user ? (
        <TrillFeed
          patp={user.urbit}
          feed={feed}
          isFollowLoading={isFollowLoading}
          setIsFollowLoading={setIsFollowLoading}
          isAccessLoading={isAccessLoading}
          setIsAccessLoading={setIsAccessLoading}
        />
      ) : "nostr" in user ? (
        <NostrFeed
          pubkey={user.nostr}
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

function MyFeed({ our }: { our: string }) {
  const following = useLocalState((s) => s.following);
  const feed = following.get(our);
  if (!feed) return <ErrorPage msg="Critical error" />;
  return <Inner feed={feed} refetch={() => {}} />;
}
