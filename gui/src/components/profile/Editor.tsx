import { useState } from "react";
import type { UserProfile, UserType } from "@/types/nostrill";
import useLocalState from "@/state/state";
import Icon from "@/components/Icon";
import toast from "react-hot-toast";
import Avatar from "../Avatar";
import FeedSettings from "./FeedSettings";

interface ProfileEditorProps {
  user: UserType;
  userString: string;
  profile: UserProfile | undefined;
  onSave?: () => void;
}

const ProfileEditor: React.FC<ProfileEditorProps> = ({
  user,
  profile,
  userString,
  onSave,
}) => {
  const { api, profiles } = useLocalState((s) => ({
    api: s.api,
    pubkey: s.pubkey,
    profiles: s.profiles,
  }));

  // Initialize state with existing profile or defaults
  const [name, setName] = useState(profile?.name || userString);
  const [picture, setPicture] = useState(profile?.picture || "");
  const [about, setAbout] = useState(profile?.about || "");
  const [customFields, setCustomFields] = useState<
    Array<{ key: string; value: string }>
  >(
    Object.entries(profile?.other || {}).map(([key, value]) => ({
      key,
      value,
    })),
  );
  const [isEditing, setIsEditing] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [showFeedSettings, setShowFeedSettings] = useState(false);

  const handleAddCustomField = () => {
    setCustomFields([...customFields, { key: "", value: "" }]);
  };

  const handleUpdateCustomField = (
    index: number,
    field: "key" | "value",
    newValue: string,
  ) => {
    const updated = [...customFields];
    updated[index][field] = newValue;
    setCustomFields(updated);
  };

  const handleRemoveCustomField = (index: number) => {
    setCustomFields(customFields.filter((_, i) => i !== index));
  };

  const handleSave = async () => {
    setIsSaving(true);
    try {
      // Convert custom fields array to object
      const other: Record<string, string> = {};
      customFields.forEach(({ key, value }) => {
        if (key.trim()) {
          other[key.trim()] = value;
        }
      });

      const nprofile: UserProfile = {
        name,
        picture,
        about,
        other,
      };

      // Call API to save profile
      if (api && typeof api.createProfile === "function") {
        await api.createProfile(nprofile);
      } else {
        throw new Error("Profile update API not available");
      }

      toast.success("Profile updated successfully");
      setIsEditing(false);
      onSave?.();
    } catch (error) {
      toast.error("Failed to update profile");
      console.error("Failed to save profile:", error);
    } finally {
      setIsSaving(false);
    }
  };

  const handleCancel = () => {
    // Reset to original values
    const profile = profiles.get(userString);
    if (profile) {
      setName(profile.name || userString);
      setPicture(profile.picture || "");
      setAbout(profile.about || "");
      setCustomFields(
        Object.entries(profile.other || {}).map(([key, value]) => ({
          key,
          value,
        })),
      );
    }
    setIsEditing(false);
  };
  console.log({ profile });
  console.log({ name, picture, customFields });

  return (
    <div className="profile-editor">
      <div className="profile-header">
        <h2>Edit Profile</h2>
        {!isEditing && (
          <button onClick={() => setIsEditing(true)} className="edit-btn">
            <Icon name="settings" size={16} />
            Edit
          </button>
        )}
      </div>

      {isEditing ? (
        <div className="profile-form">
          <div className="form-group">
            <label htmlFor="name">Display Name</label>
            <input
              id="name"
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Your display name"
            />
          </div>

          <div className="form-group">
            <label htmlFor="picture">Profile Picture URL</label>
            <input
              id="picture"
              type="url"
              value={picture}
              onChange={(e) => setPicture(e.target.value)}
              placeholder="https://example.com/avatar.jpg"
            />
            <div className="picture-preview">
              {picture ? (
                <img src={picture} />
              ) : (
                <Avatar
                  user={user}
                  profile={profile}
                  size={120}
                  picOnly={true}
                />
              )}
            </div>
          </div>

          <div className="form-group">
            <label htmlFor="about">About</label>
            <textarea
              id="about"
              value={about}
              onChange={(e) => setAbout(e.target.value)}
              placeholder="Tell us about yourself..."
              rows={4}
            />
          </div>

          <div className="form-group custom-fields">
            <label>Custom Fields</label>
            {customFields.map((field, index) => (
              <div key={index} className="custom-field-row">
                <input
                  type="text"
                  value={field.key}
                  onChange={(e) =>
                    handleUpdateCustomField(index, "key", e.target.value)
                  }
                  placeholder="Field name"
                  className="field-key-input"
                />
                <input
                  type="text"
                  value={field.value}
                  onChange={(e) =>
                    handleUpdateCustomField(index, "value", e.target.value)
                  }
                  placeholder="Field value"
                  className="field-value-input"
                />
                <button
                  onClick={() => handleRemoveCustomField(index)}
                  className="remove-field-btn"
                  title="Remove field"
                >
                  ×
                </button>
              </div>
            ))}
            <button onClick={handleAddCustomField} className="add-field-btn">
              + Add Custom Field
            </button>
          </div>

          <div className="form-actions">
            <button
              onClick={handleSave}
              disabled={isSaving}
              className="save-btn"
            >
              {isSaving ? "Saving..." : "Save Profile"}
            </button>
            <button
              onClick={handleCancel}
              disabled={isSaving}
              className="cancel-btn"
            >
              Cancel
            </button>
          </div>
        </div>
      ) : (
        <div className="profile-view">
          <div className="profile-picture">
            <Avatar
              user={user}
              profile={profile}
              size={120}
              picOnly={true}
            />
          </div>

          <div className="profile-info">
            <h3>{name}</h3>
            {about && <p className="profile-about">{about}</p>}

            {customFields.length > 0 && (
              <div className="profile-custom-fields">
                <h4>Additional Info</h4>
                {customFields.map(({ key, value }, index) => (
                  <div key={index} className="custom-field-view">
                    <span className="field-key">{key}:</span>
                    <span className="field-value">{value}</span>
                  </div>
                ))}
              </div>
            )}
          </div>
          
          <div style={{ marginTop: "20px" }}>
             <button 
                onClick={() => setShowFeedSettings(!showFeedSettings)}
                style={{ 
                    background: "transparent", 
                    border: "1px solid #444", 
                    color: "#aaa", 
                    padding: "8px 12px",
                    cursor: "pointer",
                    borderRadius: "4px",
                    display: "flex",
                    alignItems: "center",
                    gap: "8px"
                }}
             >
                <Icon name="settings" size={14} />
                {showFeedSettings ? "Hide Feed Settings" : "Feed Settings"}
             </button>
             
             {showFeedSettings && <FeedSettings />}
          </div>
        </div>
      )}
    </div>
  );
};

export default ProfileEditor;
