import "@/styles/Follows.css";
import useLocalState from "@/state/state";
import { useState } from "react";
import type { UserProfile, UserType } from "@/types/nostrill";
import type { FC } from "@/types/trill";
import Avatar from "@/components/Avatar";
import { eventToProfile, stringToUser } from "@/logic/nostrill";
import { abbreviateHex } from "@/logic/utils";
import { fetchFollowers, fetchFollows, fetchProfiles } from "@/logic/nostr";
import spinner from "@/assets/triangles.svg";
import UserModal from "@/components/modals/UserModal";
import { ArrowLeft, Users, UserPlus, RefreshCw } from "lucide-react";
import { useRequestAccess } from "@/hooks/useRequestAccess";

export default function Follows() {
  const { following, profiles, addProfile, relays, setModal } = useLocalState(
    (s) => ({
      following: s.following,
      profiles: s.profiles,
      addProfile: s.addProfile,
      relays: s.relays,
      setModal: s.setModal,
      api: s.api,
    }),
  );

  console.log({ profiles });
  const [isLoading, setLoading] = useState(false);

  const followList = Array.from(following.entries());
  const hasFollows = followList.length > 0;

  async function getFollowing(user: UserType) {
    setLoading(true);
    if ("nostr" in user) getNostrFollows(user.nostr);
    else getUrbitProfile(user.urbit, "following");
  }
  async function getFollowers(user: UserType) {
    setLoading(true);
    if ("nostr" in user) getNostrFollowers(user.nostr);
    else getUrbitProfile(user.urbit, "followers");
  }

  async function getProfiles(user: UserType[]) {
    //
    const { nostr, urbit } = user.reduce(
      (acc: { nostr: string[]; urbit: string[] }, item) => {
        if ("nostr" in item)
          return { ...acc, nostr: [...acc.nostr, item.nostr] };
        else return { ...acc, urbit: [...acc.urbit, item.urbit] };
      },
      { nostr: [], urbit: [] },
    );
    const nres = await getNostrProfiles(nostr);
    // const ures = await getUrbitProfiles(urbit)
  }
  async function getNostrProfiles(list: string[]) {
    const relayList = Object.keys(relays);
    if (relayList.length === 0) return;
    const relay = relayList[0];
    const res = await fetchProfiles(relay, list);
    for await (const msg of res) {
      if (msg[0] === "EVENT") {
        const event = msg[2];
        const prof = eventToProfile(event);
        if (prof) addProfile(event.pubkey, prof);
      }
      if (msg[0] === "EOSE") {
        setLoading(false);
        break;
      }
    }
  }
  async function getNostrFollows(pubkey: string) {
    const relayList = Object.keys(relays);
    if (relayList.length === 0) return;
    const relay = relayList[0];

    const user = { nostr: pubkey };
    const res = await fetchFollows(relay, pubkey);
    setLoading(false);
    setModal(
      <FList
        user={user}
        userString={pubkey}
        type="following"
        list={res.map((s) => ({ nostr: s }))}
        getProfiles={getProfiles}
      />,
    );
  }

  async function getNostrFollowers(pubkey: string) {
    const user = { nostr: pubkey };
    const relayList = Object.keys(relays);
    if (relayList.length === 0) return;
    const relay = relayList[0];
    const res = await fetchFollowers(relay, pubkey);
    setLoading(false);
    setModal(
      <FList
        user={user}
        userString={pubkey}
        getProfiles={getProfiles}
        type="followers"
        list={res.map((s) => ({ nostr: s }))}
      />,
    );
  }
  const { requestAccess, isLoading: isPeeking } = useRequestAccess();
  async function getUrbitProfile(patp: string, type: Direction) {
    const urbitProfile = profiles.get(patp);
    console.log({ urbitProfile }, "getting urbit profile");
    if (urbitProfile) {
      setModal(
        <FList
          user={{ urbit: patp }}
          userString={patp}
          type={type}
          list={
            type === "followers"
              ? urbitProfile.followers
              : urbitProfile.following
          }
          getProfiles={getProfiles}
        />,
      );
      setLoading(false);
    } else {
      const result = await requestAccess(patp);
      setLoading(false);
      if (!result || !result.profile) return;
      const urbitProfile = result.profile;
      if (result?.profile) {
        setModal(
          <FList
            user={{ urbit: patp }}
            userString={patp}
            type={type}
            list={
              type === "followers"
                ? urbitProfile.followers
                : urbitProfile.following
            }
            getProfiles={getProfiles}
          />,
        );
      }
    }
  }

  async function syncProfile(user: UserType) {
    if ("urbit" in user) {
      const result = await requestAccess(user.urbit);
    } else {
      //
    }
  }

  return (
    <div className="follows-page">
      <div className="follows-header">
        <div className="follows-header-content">
          <Users size={32} />
          <div>
            <h1>Following</h1>
            <p className="follows-subtitle">
              Manage your Nostr follows and discover their networks
            </p>
          </div>
        </div>
        <div className="follows-count">
          <span className="count-number">{following.size}</span>
          <span className="count-label">following</span>
        </div>
      </div>

      {!hasFollows ? (
        <div className="follows-empty">
          <UserPlus size={48} />
          <h3>No follows yet</h3>
          <p>Start following users to see them here</p>
        </div>
      ) : (
        <div className="follows-grid">
          {followList.map(([id, f]) => {
            const user = stringToUser(id);
            if ("error" in user) return null;
            return (
              <FollowEntry
                key={id}
                feed={f}
                id={id}
                user={user.ok}
                profile={profiles.get(id)}
                onSync={() => syncProfile(user.ok)}
                getFollowing={() => getFollowing(user.ok)}
                getFollowers={() => getFollowers(user.ok)}
                isLoading={isPeeking || isLoading}
              />
            );
          })}
        </div>
      )}
    </div>
  );
}

function FollowEntry({
  feed,
  profile,
  id,
  user,
  onSync,
  getFollowing,
  getFollowers,
  isLoading,
}: {
  feed: FC;
  id: string;
  user: UserType;
  profile: UserProfile | undefined;
  onSync: () => void;
  getFollowing: () => Promise<void>;
  getFollowers: () => Promise<void>;
  isLoading: boolean;
}) {
  const displayName = profile?.name || abbreviateHex(id);
  const postCount = Object.keys(feed.feed).length;

  return (
    <div className="follow-card">
      <div className="follow-card-header">
        <Avatar user={user} picOnly={true} size={56} profile={profile} />
        <div className="follow-card-info">
          <h3 className="follow-card-name">{displayName}</h3>
          <p className="follow-card-id">{abbreviateHex(id)}</p>
        </div>
      </div>

      {profile?.about && <p className="follow-card-about">{profile.about}</p>}

      <div className="follow-card-stats">
        <div className="stat-item">
          <span className="stat-value">{postCount}</span>
          <span className="stat-label">posts</span>
        </div>
        {profile && (
          <>
            <div className="stat-item">
              <span className="stat-value">{profile.followingCount}</span>
              <span className="stat-label">following</span>
            </div>
            <div className="stat-item">
              <span className="stat-value">{profile.followerCount}</span>
              <span className="stat-label">followers</span>
            </div>
          </>
        )}
      </div>

      <div className="follow-card-actions">
        {isLoading ? (
          <img className="spinner" src={spinner} alt="Loading..." />
        ) : (
          <>
            <button
              className="follow-btn icon-only"
              onClick={onSync}
              title="Sync profile"
            >
              <RefreshCw size={16} />
            </button>
            <button className="follow-btn primary" onClick={getFollowing}>
              <Users size={16} />
              View Follows
            </button>
            <button className="follow-btn secondary" onClick={getFollowers}>
              <Users size={16} />
              View Followers
            </button>
          </>
        )}
      </div>
    </div>
  );
}
type Direction = "followers" | "following";

function FList({
  user,
  userString,
  type,
  list,
  getProfiles,
}: {
  user: UserType;
  userString: string;
  type: Direction;
  list: UserType[];
  getProfiles: (users: UserType[]) => Promise<void>;
}) {
  const [selectedUser, setSelectedUser] = useState<UserType | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const { profiles } = useLocalState((s) => ({
    profiles: s.profiles,
  }));
  const profile = profiles.get(userString);
  const name = profile?.name
    ? profile.name
    : "nostr" in user
      ? abbreviateHex(user.nostr)
      : user.urbit;

  async function handleFetchProfiles() {
    setIsLoading(true);
    await getProfiles(list);
    setIsLoading(false);
  }

  function openUserModal(userType: UserType) {
    setSelectedUser(userType);
  }

  function goBack() {
    setSelectedUser(null);
  }

  console.log("flist");
  console.log({ user, userString, type, list });

  return (
    <div className="subfollows-container">
      {/* Sliding panel wrapper */}
      <div
        className="subfollows-slider"
        style={{
          transform: selectedUser ? "translateX(-50%)" : "translateX(0)",
        }}
      >
        {/* List View */}
        <div className="subfollows-panel">
          <div className="subfollows-header">
            {type === "following" ? (
              <h2>Users followed by {name}</h2>
            ) : (
              <h2>Users following {name}</h2>
            )}
            <p className="subfollows-count">{list.length} users</p>
          </div>

          <button
            className="subfollows-fetch-btn"
            onClick={() => getProfiles(list)}
            disabled={isLoading}
          >
            {isLoading ? (
              <>
                <img className="spinner-small" src={spinner} alt="" />
                Fetching...
              </>
            ) : (
              <>
                <RefreshCw size={16} />
                Fetch Profiles
              </>
            )}
          </button>

          <div className="subfollows-list" id="follow-list">
            {list.map((user) => {
              console.log({ user });
              const userString = "nostr" in user ? user.nostr : user.urbit;
              const prof = profiles.get(userString);
              const name = prof?.name
                ? prof.name
                : "nostr" in user
                  ? abbreviateHex(user.nostr)
                  : user.urbit;
              return (
                <div
                  key={userString}
                  className="subfollows-entry"
                  onClick={() => openUserModal(user)}
                >
                  <Avatar
                    picOnly={true}
                    user={user}
                    size={36}
                    noClick={true}
                    profile={prof}
                  />
                  <div className="subfollows-entry-info" title={userString}>
                    <span className="subfollows-entry-name">{name}</span>
                    {prof?.name && (
                      <span className="subfollows-entry-id">
                        {"nostr" in user
                          ? abbreviateHex(user.nostr)
                          : user.urbit}
                      </span>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* User Detail View */}
        <div className="subfollows-panel subfollows-detail">
          {selectedUser && (
            <>
              <button className="subfollows-back-btn" onClick={goBack}>
                <ArrowLeft size={20} />
                Back to list
              </button>
              <UserModal user={selectedUser} />
            </>
          )}
        </div>
      </div>
    </div>
  );
}
