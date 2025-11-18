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
  console.log({ profiles });

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
          <Avatar
            user={user}
            userString={userString}
            size={120}
            picOnly={true}
            profile={profile}
          />
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
              const isURL = URL.parse(value);
              return (
                <div key={index} className="custom-field-view">
                  <span className="field-key">{key}:</span>
                  {isURL ? (
                    <a className="field-value" href={value} target="_blank">
                      {value}
                    </a>
                  ) : (
                    <span className="field-value">{value}</span>
                  )}
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
