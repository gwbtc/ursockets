import { useState, useEffect } from "react";
import useLocalState from "@/state/state";
import { S3Client, type S3Object } from "@bradenmacdonald/s3-lite-client";

import type { S3Config } from "@/state/state";
import spinner from "@/assets/triangles.svg";
import Icon from "@/components/Icon";

interface S3BrowserProps {
  onSelect: (url: string) => void;
  onClose: () => void;
}

export default function S3Browser({ onSelect, onClose }: S3BrowserProps) {
  const { s3 } = useLocalState((s) => ({ s3: s.s3 }));
  const [objects, setObjects] = useState<S3Object[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!s3) {
      setError("S3 not configured");
      setLoading(false);
      return;
    }
    fetchObjects(s3);
  }, [s3]);

  async function fetchObjects(config: S3Config) {
    try {
      console.log({ config });
      const client = new S3Client({
        bucket: config.currentBucket,
        endPoint: config.endpoint,
        region: "us-east-1",
        accessKey: config.accessKeyId,
        secretKey: config.secretAccessKey,
      });
      // const res = await client.list();
      for await (const obj of client.listObjects()) {
        console.log({ obj });
        setObjects((s) => [...s, obj]);
      }
    } catch (e: any) {
      console.error(e);
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div
      className="s3-browser"
      style={{
        padding: "20px",
        color: "#fff",
        width: "80vw",
        height: "80vh",
        display: "flex",
        flexDirection: "column",
      }}
    >
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          marginBottom: "20px",
        }}
      >
        <h2>Your Media Library</h2>
        <button
          onClick={onClose}
          style={{
            background: "transparent",
            border: "none",
            color: "#fff",
            cursor: "pointer",
          }}
        >
          <Icon name="settings" size={24} />{" "}
          {/* Using settings as close replacement if X not available, logic elsewhere uses text usually */}
          X
        </button>
      </div>

      {loading ? (
        <div
          style={{
            display: "flex",
            justifyContent: "center",
            alignItems: "center",
            flex: 1,
          }}
        >
          <img src={spinner} />
        </div>
      ) : error ? (
        <div style={{ textAlign: "center", color: "red" }}>
          <p>Error: {error}</p>
          <p>Please check your S3 configuration in Settings.</p>
        </div>
      ) : (
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fill, minmax(150px, 1fr))",
            gap: "16px",
            overflowY: "auto",
            flex: 1,
          }}
        >
          {objects.map((obj) => {
            const isImg = obj.key.match(/\.(jpg|jpeg|png|gif|webp|svg)$/i);
            const url = `${s3?.endpoint}/${s3?.currentBucket}/${obj.key}`;
            console.log({ url });
            return (
              <div
                key={obj.key}
                onClick={() => onSelect(obj.key)}
                style={{
                  border: "1px solid #333",
                  borderRadius: "8px",
                  overflow: "hidden",
                  cursor: "pointer",
                  position: "relative",
                  aspectRatio: "1",
                }}
              >
                {isImg ? (
                  <img
                    src={url}
                    style={{
                      width: "100%",
                      height: "100%",
                      objectFit: "cover",
                    }}
                    loading="lazy"
                  />
                ) : (
                  <div
                    style={{
                      width: "100%",
                      height: "100%",
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      background: "#222",
                    }}
                  >
                    <span
                      style={{
                        fontSize: "0.8em",
                        padding: "10px",
                        wordBreak: "break-all",
                      }}
                    >
                      {obj.key}
                    </span>
                  </div>
                )}
                <div
                  style={{
                    position: "absolute",
                    bottom: 0,
                    left: 0,
                    right: 0,
                    background: "rgba(0,0,0,0.7)",
                    padding: "4px",
                    fontSize: "0.7em",
                    whiteSpace: "nowrap",
                    overflow: "hidden",
                    textOverflow: "ellipsis",
                  }}
                >
                  {obj.key}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
