import useLocalState from "@/state/state";
import { useState } from "react";
import toast from "react-hot-toast";
import { ThemeSwitcher } from "@/styles/ThemeSwitcher";
import Icon from "@/components/Icon";
import "@/styles/Settings.css";
import WebSocketWidget from "@/components/WsWidget";
import type { RelayStats } from "@/types/nostrill";
import { WS_URL } from "@/logic/api";

function Settings() {
  const { key, relays, api, sets } = useLocalState((s) => ({
    key: s.pubkey,
    relays: s.relays,
    api: s.api,
    sets: s.uiSettings,
  }));
  const [newRelay, setNewRelay] = useState("");
  const [isAddingRelay, setIsAddingRelay] = useState(false);
  const [isCyclingKey, setIsCyclingKey] = useState(false);
  const [backlogSize, setBacklogSize] = useState<number>(
    sets?.relay?.["backlog-size"] || 24,
  );
  const [backlogUnit, setBacklogUnit] = useState<"hours" | "days">("hours");

  async function removeRelay(_url: string, relay: RelayStats) {
    try {
      await api?.deleteRelay(relay.wid);
      toast.success("Relay removed");
    } catch (error) {
      console.log("WS_URL", WS_URL);
      toast.error("Failed to remove relay");
      console.error("Remove relay error:", error);
    }
  }

  async function addNewRelay() {
    if (!newRelay.trim()) {
      toast.error("Please enter a relay URL");
      return;
    }

    setIsAddingRelay(true);
    try {
      const valid = ["wss:", "ws:"];
      const url = new URL(newRelay);
      if (!valid.includes(url.protocol)) {
        toast.error("Invalid Relay URL - must use wss:// or ws://");
        return;
      }

      await api?.addRelay(newRelay);
      toast.success("Relay added");
      setNewRelay("");
    } catch (error) {
      toast.error("Invalid relay URL or failed to add relay");
      console.error("Add relay error:", error);
    } finally {
      setIsAddingRelay(false);
    }
  }

  async function cycleKey() {
    setIsCyclingKey(true);
    try {
      await api?.cycleKeys();
      toast.success("Key cycled successfully");
    } catch (error) {
      toast.error("Failed to cycle key");
      console.error("Cycle key error:", error);
    } finally {
      setIsCyclingKey(false);
    }
  }

  async function saveBacklogSize() {
    const hours = backlogUnit === "days" ? backlogSize * 24 : backlogSize;
    setMisc("relay", "backlog-size", hours);
  }
  async function setMisc(bucket: string, entry: string, value: any) {
    try {
      await api?.setSettings(bucket, entry, value);
      toast.success("Setting saved");
    } catch (e) {
      toast.error("Failed to save setting");
      console.error("settings save error:", e);
    }
  }

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === "Enter") {
      addNewRelay();
    }
  };

  return (
    <div className="settings-page">
      <div className="settings-header">
        <h1>Settings</h1>
        <p>Manage your Trill configuration and preferences</p>
      </div>

      <div className="settings-content">
        <WebSocketWidget url={`${WS_URL}/nostrill-ui`} />

        {/* Identity Section */}
        <div className="settings-section">
          <div className="section-header">
            <Icon name="key" size={20} />
            <h2>Identity</h2>
          </div>
          <div className="section-content">
            <div className="setting-item">
              <div className="setting-info">
                <label>Nostr Public Key</label>
                <p>Your unique identifier on the Nostr network</p>
              </div>
              <div className="setting-control">
                <div className="key-display">
                  <code className="pubkey">{key || "No key generated"}</code>
                  <button
                    onClick={cycleKey}
                    disabled={isCyclingKey}
                    className="cycle-btn"
                    title="Generate new key pair"
                  >
                    {isCyclingKey ? (
                      <Icon name="settings" size={16} />
                    ) : (
                      <Icon name="settings" size={16} />
                    )}
                    {isCyclingKey ? "Cycling..." : "Cycle Key"}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Nostr Relays Section */}
        <div className="settings-section">
          <div className="section-header">
            <Icon name="nostr" size={20} />
            <h2>Nostr Relays</h2>
          </div>
          <div className="section-content">
            <div className="setting-item">
              <div className="setting-info">
                <label>Connected Relays</label>
                <p>Manage your Nostr relay connections</p>
              </div>
              <div className="setting-control">
                <div className="relay-list">
                  {Object.keys(relays).length === 0 ? (
                    <div className="no-relays">
                      <Icon name="nostr" size={24} color="textMuted" />
                      <p>No relays configured</p>
                    </div>
                  ) : (
                    Object.entries(relays).map(([url, relay]) => (
                      <div key={url} className="relay-item">
                        <div className="relay-info">
                          <span className="relay-url">{url}</span>
                          <span className="relay-status">Connected</span>
                        </div>
                        <button
                          onClick={() => removeRelay(url, relay)}
                          className="remove-relay-btn"
                          title="Remove relay"
                        >
                          ×
                        </button>
                      </div>
                    ))
                  )}

                  <div className="add-relay-form">
                    <div className="relay-input-group">
                      <input
                        type="text"
                        value={newRelay}
                        onChange={(e) => setNewRelay(e.target.value)}
                        onKeyPress={handleKeyPress}
                        placeholder="wss://relay.example.com"
                        className="relay-input"
                      />
                      <button
                        onClick={addNewRelay}
                        disabled={isAddingRelay || !newRelay.trim()}
                        className="add-relay-btn"
                      >
                        {isAddingRelay ? (
                          <>
                            <Icon name="settings" size={16} />
                            Adding...
                          </>
                        ) : (
                          <>
                            <Icon name="settings" size={16} />
                            Add Relay
                          </>
                        )}
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div className="section-content">
              <div className="setting-item">
                <div className="setting-info">
                  <label>Backlog Size</label>
                  <p>
                    Choose how much content to fetch when you sync data from the
                    relay
                  </p>
                </div>
                <div className="setting-control">
                  <input
                    type="number"
                    min={1}
                    value={backlogSize}
                    onChange={(e) =>
                      setBacklogSize(Math.max(1, parseInt(e.target.value) || 1))
                    }
                    className="backlog-input"
                  />
                  <select
                    value={backlogUnit}
                    onChange={(e) =>
                      setBacklogUnit(e.target.value as "hours" | "days")
                    }
                    className="backlog-unit"
                  >
                    <option value="hours">Hours</option>
                    <option value="days">Days</option>
                  </select>
                  <button onClick={saveBacklogSize} className="add-relay-btn">
                    Save
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
export default Settings;
