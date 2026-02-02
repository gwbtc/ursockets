import { useState } from "react";
import useLocalState from "@/state/state";
import Modal from "@/components/modals/Modal";
import { Plus, RefreshCw, Trash2, Radio, X } from "lucide-react";
import toast from "react-hot-toast";
import "./RelayDashboard.css";

export default function RelayDashboard() {
  const { relays, api, setModal } = useLocalState((s) => ({
    relays: s.relays,
    api: s.api,
    setModal: s.setModal,
  }));

  const [newRelayUrl, setNewRelayUrl] = useState("");
  const [isAdding, setIsAdding] = useState(false);
  const [isSyncing, setIsSyncing] = useState(false);
  const [showAddForm, setShowAddForm] = useState(false);

  const relayEntries = Object.entries(relays);

  const handleAddRelay = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!api || !newRelayUrl.trim()) return;

    // Basic validation
    if (!newRelayUrl.startsWith("wss://") && !newRelayUrl.startsWith("ws://")) {
      toast.error("Relay URL must start with wss:// or ws://");
      return;
    }

    setIsAdding(true);
    try {
      const res = await api.addRelay(newRelayUrl.trim());
      if ("ok" in res) {
        toast.success("Relay added");
        setNewRelayUrl("");
        setShowAddForm(false);
      } else {
        toast.error(res.error);
      }
    } catch (error) {
      toast.error("Failed to add relay");
    } finally {
      setIsAdding(false);
    }
  };

  const handleDeleteRelay = async (_url: string, wid: number) => {
    if (!api) return;

    try {
      const res = await api.deleteRelay(wid);
      if ("ok" in res) {
        toast.success("Relay removed");
      } else {
        toast.error(res.error);
      }
    } catch (error) {
      toast.error("Failed to remove relay");
    }
  };

  const handleSyncAll = async () => {
    if (!api) return;

    setIsSyncing(true);
    try {
      await api.syncRelays();
      toast.success("Sync initiated");
    } catch (error) {
      toast.error("Failed to sync");
    } finally {
      setIsSyncing(false);
    }
  };

  const formatUptime = (startTimestamp: number) => {
    if (!startTimestamp) return "Unknown";
    const now = Date.now();
    const start = startTimestamp * 1000; // Convert from seconds if needed
    const diff = now - start;

    if (diff < 0) return "Just started";

    const hours = Math.floor(diff / (1000 * 60 * 60));
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));

    if (hours > 24) {
      const days = Math.floor(hours / 24);
      return `${days}d ${hours % 24}h`;
    }
    if (hours > 0) return `${hours}h ${minutes}m`;
    return `${minutes}m`;
  };

  return (
    <Modal>
      <div className="relay-dashboard">
        <div className="relay-dashboard-header">
          <div className="relay-dashboard-title">
            <Radio size={20} />
            <h2>Relay Connections</h2>
          </div>
          <button
            className="relay-close-btn"
            onClick={() => setModal(null)}
            aria-label="Close"
          >
            <X size={20} />
          </button>
        </div>

        <div className="relay-dashboard-actions">
          <button
            className="relay-action-btn"
            onClick={handleSyncAll}
            disabled={isSyncing || relayEntries.length === 0}
          >
            <RefreshCw size={16} className={isSyncing ? "spinning" : ""} />
            {isSyncing ? "Syncing..." : "Sync All"}
          </button>
          <button
            className="relay-action-btn primary"
            onClick={() => setShowAddForm(!showAddForm)}
          >
            <Plus size={16} />
            Add Relay
          </button>
        </div>

        {showAddForm && (
          <form className="relay-add-form" onSubmit={handleAddRelay}>
            <input
              type="text"
              placeholder="wss://relay.example.com"
              value={newRelayUrl}
              onChange={(e) => setNewRelayUrl(e.target.value)}
              disabled={isAdding}
              autoFocus
            />
            <button type="submit" disabled={isAdding || !newRelayUrl.trim()}>
              {isAdding ? "Adding..." : "Add"}
            </button>
            <button
              type="button"
              className="cancel"
              onClick={() => {
                setShowAddForm(false);
                setNewRelayUrl("");
              }}
            >
              Cancel
            </button>
          </form>
        )}

        <div className="relay-list">
          {relayEntries.length === 0 ? (
            <div className="relay-empty">
              <Radio size={32} strokeWidth={1.5} />
              <p>No relays configured</p>
              <span>Add a relay to connect to the Nostr network</span>
            </div>
          ) : (
            relayEntries.map(([url, stats]) => (
              <div key={url} className="relay-item">
                <div className="relay-status-indicator connected" />
                <div className="relay-info">
                  <div className="relay-url">{url}</div>
                  <div className="relay-meta">
                    <span className="relay-stat">
                      Uptime: {formatUptime(stats.start)}
                    </span>
                    <span className="relay-stat">
                      Requests: {Object.keys(stats.reqs).length}
                    </span>
                  </div>
                </div>
                <button
                  className="relay-delete-btn"
                  onClick={() => handleDeleteRelay(url, stats.wid)}
                  title="Remove relay"
                >
                  <Trash2 size={16} />
                </button>
              </div>
            ))
          )}
        </div>

        <div className="relay-dashboard-footer">
          <span className="relay-count">
            {relayEntries.length} relay{relayEntries.length !== 1 ? "s" : ""}{" "}
            configured
          </span>
        </div>
      </div>
    </Modal>
  );
}
