import type { Gate, Lock } from "@/types/trill";
import LockEditor from "./LockEditor";

interface GateEditorProps {
  gate: Gate;
  onChange: (gate: Gate) => void;
  label?: string;
}

export default function GateEditor({ gate, onChange, label }: GateEditorProps) {
  const handleLockChange = (newLock: Lock) => {
    onChange({ ...gate, lock: newLock });
  };

  const handleMuteChange = (newMute: Lock) => {
    onChange({ ...gate, mute: newMute });
  };

  return (
    <div
      className="gate-editor"
      style={{
        padding: "10px",
        border: "1px solid #444",
        borderRadius: "8px",
        margin: "10px 0",
      }}
    >
      {label && <h3>{label}</h3>}

      <LockEditor
        lock={gate.lock}
        onChange={handleLockChange}
        label="Access Policy (Who can view)"
      />

      <LockEditor
        lock={gate.mute}
        onChange={handleMuteChange}
        label="Write/Mute Policy (Who is restricted)"
      />

      <div
        className="gate-options"
        style={{
          marginTop: "10px",
          display: "flex",
          gap: "20px",
          alignItems: "center",
        }}
      >
        <label>
          <input
            type="checkbox"
            checked={gate.manual}
            onChange={(e) => onChange({ ...gate, manual: e.target.checked })}
          />
          Manual Approval
        </label>

        <label>
          Backlog Size:
          <input
            type="number"
            value={gate.backlog}
            onChange={(e) =>
              onChange({ ...gate, backlog: parseInt(e.target.value) || 0 })
            }
            style={{ width: "60px", marginLeft: "8px" }}
          />
        </label>
      </div>
    </div>
  );
}
