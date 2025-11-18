import Modal from "./Modal";
import Avatar from "../Avatar";
import Icon from "@/components/Icon";
import useLocalState from "@/state/state";
import { useLocation } from "wouter";
import toast from "react-hot-toast";
import { isValidPatp } from "urbit-ob";
import { isValidNostrPubkey } from "@/logic/nostrill";
import { generateNprofile } from "@/logic/nostr";
import { useState } from "react";

export default function ({ userString }: { userString: string }) {
  const { setModal, api, pubkey, profiles, following, followers } = useLocalState((s) => ({
    setModal: s.setModal,
    api: s.api,
    pubkey: s.pubkey,
    profiles: s.profiles,
    following: s.following,
    followers: s.followers,
  }));
  const [_, navigate] = useLocation();
  const [loading, setLoading] = useState(false);

  function close() {
    setModal(null);
  }

  const user = isValidPatp(userString)
    ? { urbit: userString }
    : isValidNostrPubkey(userString)
      ? { nostr: userString }
      : { error: "" };

  if ("error" in user) {
    return (
      <Modal close={close}>
        <div className="user-modal-error">
          <Icon name="comet" size={48} />
          <p>Invalid user identifier</p>
        </div>
      </Modal>
    );
  }

  const itsMe =
    "urbit" in user
      ? user.urbit === api?.airlock.our
      : "nostr" in user
        ? user.nostr === pubkey
        : false;

  const profile = profiles.get(userString);
  const isFollowing = following.has(userString);
  const isFollower = followers.includes(userString);

  // Get follower/following counts from the user's feed if available
  const userFeed = following.get(userString);
  const postCount = userFeed ? Object.keys(userFeed.feed).length : 0;

  async function copy(e: React.MouseEvent) {
    e.stopPropagation();
    await navigator.clipboard.writeText(userString);
    toast.success("Copied to clipboard");
  }

  async function handleFollow(e: React.MouseEvent) {
    e.stopPropagation();
    if (!api) return;

    setLoading(true);
    try {
      if (isFollowing) {
        const result = await api.unfollow(userString);
        if ("ok" in result) {
          toast.success(`Unfollowed ${profile?.name || userString}`);
        } else {
          toast.error(result.error);
        }
      } else {
        const result = await api.follow(userString);
        if ("ok" in result) {
          toast.success(`Following ${profile?.name || userString}`);
        } else {
          toast.error(result.error);
        }
      }
    } catch (err) {
      toast.error("Action failed");
    } finally {
      setLoading(false);
    }
  }

  async function handleAvatarClick(e: React.MouseEvent) {
    e.stopPropagation();
    if ("nostr" in user) {
      const nprof = generateNprofile(userString);
      const href = `https://primal.net/p/${nprof}`;
      window.open(href, "_blank");
    }
  }

  const displayName = profile?.name || ("urbit" in user ? user.urbit : "Anon");
  const truncatedId = userString.length > 20
    ? `${userString.slice(0, 10)}...${userString.slice(-8)}`
    : userString;

  // Check if a string is a URL
  const isURL = (str: string): boolean => {
    try {
      new URL(str);
      return true;
    } catch {
      return str.startsWith('http://') || str.startsWith('https://');
    }
  };

  // Get banner image from profile.other
  const bannerImage = profile?.other?.banner || profile?.other?.Banner;

  // Filter out banner from other fields since we display it separately
  const otherFields = profile?.other
    ? Object.entries(profile.other).filter(
        ([key]) => key.toLowerCase() !== 'banner'
      )
    : [];

  return (
    <Modal close={close}>
      <div className="user-modal">
        {/* Banner Image */}
        {bannerImage && (
          <div className="user-modal-banner">
            <img src={bannerImage} alt="Profile banner" />
          </div>
        )}

        {/* Header with Avatar and Basic Info */}
        <div className="user-modal-header">
          <div
            className="user-modal-avatar-wrapper"
            onClick={handleAvatarClick}
            style={{ cursor: "nostr" in user ? "pointer" : "default" }}
          >
            <Avatar
              user={user}
              userString={userString}
              profile={profile}
              size={80}
              picOnly
            />
          </div>

          <div className="user-modal-info">
            <h2 className="user-modal-name">{displayName}</h2>
            <div className="user-modal-id-row">
              <span className="user-modal-id" title={userString}>
                {"urbit" in user ? user.urbit : truncatedId}
              </span>
              <Icon
                name="copy"
                size={16}
                className="user-modal-copy-icon cp"
                onClick={copy}
                title="Copy to clipboard"
              />
            </div>

            {/* User type badge */}
            <div className="user-modal-badge">
              {"urbit" in user ? (
                <span className="badge badge-urbit">Urbit</span>
              ) : (
                <span className="badge badge-nostr">Nostr</span>
              )}
              {itsMe && <span className="badge badge-me">You</span>}
              {isFollower && !itsMe && <span className="badge badge-follows">Follows you</span>}
            </div>
          </div>
        </div>

        {/* Profile About Section */}
        {profile?.about && (
          <div className="user-modal-about">
            <p>{profile.about}</p>
          </div>
        )}

        {/* Stats */}
        <div className="user-modal-stats">
          {postCount > 0 && (
            <div className="stat">
              <span className="stat-value">{postCount}</span>
              <span className="stat-label">Posts</span>
            </div>
          )}
          {/* Additional stats could go here */}
        </div>

        {/* Custom Fields */}
        {otherFields.length > 0 && (
          <div className="user-modal-custom-fields">
            <h4>Additional Info</h4>
            {otherFields.map(([key, value]) => (
              <div key={key} className="custom-field-item">
                <span className="field-key">{key}:</span>
                {isURL(value) ? (
                  <a
                    href={value}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="field-value field-link"
                    onClick={(e) => e.stopPropagation()}
                  >
                    {value}
                    <Icon name="nostr" size={12} className="external-link-icon" />
                  </a>
                ) : (
                  <span className="field-value">{value}</span>
                )}
              </div>
            ))}
          </div>
        )}

        {/* Action Buttons */}
        <div className="user-modal-actions">
          {!itsMe && (
            <button
              className={`action-btn ${isFollowing ? "following" : "follow"}`}
              onClick={handleFollow}
              disabled={loading}
            >
              <Icon name="pals" size={16} />
              {loading ? "..." : isFollowing ? "Following" : "Follow"}
            </button>
          )}

          {"urbit" in user ? (
            <>
              <button
                className="action-btn secondary"
                onClick={() => {
                  navigate(`/feed/${userString}`);
                  close();
                }}
              >
                <Icon name="home" size={16} />
                View Feed
              </button>
            </>
          ) : (
            <button
              className="action-btn secondary"
              onClick={handleAvatarClick}
            >
              <Icon name="nostr" size={16} />
              View on Primal
            </button>
          )}
        </div>
      </div>
    </Modal>
  );
}
