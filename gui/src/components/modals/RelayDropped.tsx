import { GLOBAL_RELAY_URL } from "@/logic/constants";
import useLocalState from "@/state/state";
import triangles from "@/assets/triangles.svg";
import { useState } from "react";

export default function RelayDroppedDialog({ url }: { url: string }) {
  const { api } = useLocalState((s) => ({ api: s.api }));
  const [loading, setLoading] = useState(false);
  async function handleRetry(e: React.MouseEvent) {
    e.preventDefault();
    e.stopPropagation();
    const res = await api?.addRelay(url);
  }

  return (
    <div className="confirmation-dialog">
      {url === GLOBAL_RELAY_URL ? (
        <h3>Your connection to the global relay has dropped</h3>
      ) : (
        <h3>Your connection to the relay {url} has dropped</h3>
      )}
      {loading ? (
        <div className="loading-spinner">
          <img src={triangles} alt="Loading..." />
        </div>
      ) : (
        <div>
          <p>Reconnect?</p>
          <div className="confirmation-buttons">
            <button className="btn-confirm" onClick={handleRetry}>
              Yes
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
