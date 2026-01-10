import "@/styles/s3.css";
import { useState, useEffect } from "react";
import useLocalState from "@/state/state";
import { S3Client, type S3Object } from "@bradenmacdonald/s3-lite-client";

import type { S3Config } from "@/types/urbit";
import spinner from "@/assets/triangles.svg";

interface S3BrowserProps {
  onSelect: (url: string) => void;
  onClose: () => void;
}

export default function S3Browser({ onSelect }: S3BrowserProps) {
  const { s3 } = useLocalState((s) => ({ s3: s.s3 }));
  const [objects, setObjects] = useState<Set<S3Object>>(new Set());
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
      const client = new S3Client({
        bucket: config.currentBucket,
        endPoint: config.endpoint,
        region: "us-east-1",
        accessKey: config.accessKeyId,
        secretKey: config.secretAccessKey,
      });
      // There seems to be some reduplication issues with this library so let's just do sets
      for await (const obj of client.listObjects()) {
        setObjects((s) => s.add(obj));
      }
    } catch (e: any) {
      console.error(e);
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div id="s3-browser">
      <div
        style={{
          textAlign: "center",
        }}
      >
        <h2>Choose Media</h2>
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
        <div className="image-grid">
          {[...objects].map((obj) => {
            const url = `${s3?.endpoint}/${s3?.currentBucket}/${obj.key}`;
            const isImg = obj.key.match(/\.(jpg|jpeg|png|gif|webp|svg)$/i);
            const isVid = obj.key.match(/\.(mp4|mkv|webm)$/i);
            return (
              <div
                className="entry"
                key={obj.key}
                onClick={() => onSelect(obj.key)}
              >
                {isImg ? (
                  <img src={url} loading="lazy" />
                ) : isVid ? (
                  <video src={url} />
                ) : null}
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
