import "@/styles/Profile.css";
import type { UserProfile, UserType } from "@/types/nostrill";
import useLocalState from "@/state/state";
import Avatar from "../Avatar";
import ProfileEditor from "./Editor";

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
  const profile = profiles.get(props.userString);

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
  const customFields = profile?.other ? Object.entries(profile.other) : [];
  return (
    <div className="profile view-mode">
      <div className="profile-picture">
        <Avatar
          user={user}
          userString={userString}
          size={120}
          picOnly={true}
          profile={profile}
        />
      </div>
      <div className="profile-info">
        <h2>{profile?.name || userString}</h2>
        {profile?.about && <p className="profile-about">{profile.about}</p>}

        {customFields.length > 0 && (
          <div className="profile-custom-fields">
            <h4>Additional Info</h4>
            {customFields.map(([key, value], index) => (
              <div key={index} className="custom-field-view">
                <span className="field-key">{key}:</span>
                <span className="field-value">{value}</span>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

export default Loader;
