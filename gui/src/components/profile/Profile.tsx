import "@/styles/Profile.css";
import type { UserProfile, UserType } from "@/types/nostrill";
import useLocalState from "@/state/state";
import Avatar from "../Avatar";
import ProfileEditor from "./Editor";
import { ProfValue } from "../modals/UserModal";

interface Props {
  user: UserType;
  userString: string;
  isMe: boolean;
  onSave?: () => void;
}

const Loader: React.FC<Props> = (props) => {
  const { profiles } = useLocalState((s) => ({
    profiles: s.profiles,
  }));
  const { user } = props;
  const userString2 = "urbit" in user ? user.urbit : user.nostr;
  const profile = profiles.get(userString2);

  if (props.isMe) return <ProfileEditor {...props} profile={profile} />;
  else return <Profile profile={profile} {...props} />;
};
function Profile({
  user,
  userString,
  profile,
}: {
  user: UserType;
  userString: string;
  profile: UserProfile | undefined;
}) {
  // Initialize state with existing profile or defaults

  // View-only mode for other users' profiles - no editing allowed
  const bannerImage = profile?.other?.banner || profile?.other?.Banner;
  const customFields = profile?.other ? Object.entries(profile.other) : [];
  return (
    <div className="profile">
      {bannerImage && (
        <div className="user-banner">
          <img src={bannerImage} alt="Profile banner" />
        </div>
      )}
      <div className="flex items-center gap-4">
        <div className="profile-picture">
          <Avatar user={user} size={120} picOnly={true} profile={profile} />
        </div>
        <h2 className="text-4xl">{profile?.name || userString}</h2>
      </div>
      <div className="profile-info">
        {profile?.about && <p className="profile-about">{profile.about}</p>}

        {customFields.length > 0 && (
          <div className="profile-custom-fields">
            <h4>Additional Info</h4>

            {customFields.map(([key, value], index) => {
              if (key.toLocaleLowerCase() === "banner") return null;
              return (
                <div key={index} className="custom-field-view">
                  <span className="field-key">{key}:</span>
                  <ProfValue value={value} />
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}

export default Loader;
