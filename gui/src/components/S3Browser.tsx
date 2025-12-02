import { useState, useEffect } from "react";
import useLocalState from "@/state/state";
import { AwsClient } from "aws4fetch";
import type { S3Config } from "@/state/state";
import spinner from "@/assets/triangles.svg";
import Icon from "@/components/Icon";
import Modal from "@/components/modals/Modal";

interface S3BrowserProps {
  onSelect: (url: string) => void;
  onClose: () => void;
}

interface S3Object {
  key: string;
  lastModified: string;
  size: number;
  url: string;
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
      const client = new AwsClient({
        accessKeyId: config.accessKeyId,
        secretAccessKey: config.secretAccessKey,
        service: "s3",
        region: config.region || "us-east-1",
      });

      // Construct list URL (path style)
      const endpoint = config.endpoint.replace(/^https?:\/\//, "");
      const protocol = config.endpoint.startsWith("http:") ? "http://" : "https://";
      const url = `${protocol}${endpoint}/${config.currentBucket}?list-type=2`;

      const res = await client.fetch(url);
      if (!res.ok) throw new Error(`Failed to list objects: ${res.status}`);
      
      const text = await res.text();
      const parser = new DOMParser();
      const xml = parser.parseFromString(text, "text/xml");
      
      const contents = xml.getElementsByTagName("Contents");
      const parsed: S3Object[] = [];
      
      for (let i = 0; i < contents.length; i++) {
        const item = contents[i];
        const key = item.getElementsByTagName("Key")[0]?.textContent;
        const lastModified = item.getElementsByTagName("LastModified")[0]?.textContent;
        const size = parseInt(item.getElementsByTagName("Size")[0]?.textContent || "0");
        
        if (key) {
            // Construct public URL
            const publicUrl = `${protocol}${endpoint}/${config.currentBucket}/${key}`;
            parsed.push({
                key,
                lastModified: lastModified || "",
                size,
                url: publicUrl
            });
        }
      }
      
      // Sort by new
      parsed.sort((a, b) => new Date(b.lastModified).getTime() - new Date(a.lastModified).getTime());
      
      setObjects(parsed);
    } catch (e: any) {
      console.error(e);
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="s3-browser" style={{ padding: "20px", color: "#fff", width: "80vw", height: "80vh", display: "flex", flexDirection: "column" }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "20px" }}>
        <h2>Your Media Library</h2>
        <button onClick={onClose} style={{ background: "transparent", border: "none", color: "#fff", cursor: "pointer" }}>
            <Icon name="settings" size={24} /> {/* Using settings as close replacement if X not available, logic elsewhere uses text usually */}
            X
        </button>
      </div>

      {loading ? (
        <div style={{ display: "flex", justifyContent: "center", alignItems: "center", flex: 1 }}>
            <img src={spinner} />
        </div>
      ) : error ? (
        <div style={{ textAlign: "center", color: "red" }}>
            <p>Error: {error}</p>
            <p>Please check your S3 configuration in Settings.</p>
        </div>
      ) : (
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(150px, 1fr))", gap: "16px", overflowY: "auto", flex: 1 }}>
            {objects.map(obj => {
                const isImg = obj.key.match(/\.(jpg|jpeg|png|gif|webp|svg)$/i);
                return (
                    <div 
                        key={obj.key} 
                        onClick={() => onSelect(obj.url)}
                        style={{ 
                            border: "1px solid #333", 
                            borderRadius: "8px", 
                            overflow: "hidden", 
                            cursor: "pointer", 
                            position: "relative",
                            aspectRatio: "1"
                        }}
                    >
                        {isImg ? (
                            <img src={obj.url} style={{ width: "100%", height: "100%", objectFit: "cover" }} loading="lazy" />
                        ) : (
                            <div style={{ width: "100%", height: "100%", display: "flex", alignItems: "center", justifyContent: "center", background: "#222" }}>
                                <span style={{ fontSize: "0.8em", padding: "10px", wordBreak: "break-all" }}>{obj.key}</span>
                            </div>
                        )}
                        <div style={{ 
                            position: "absolute", 
                            bottom: 0, 
                            left: 0, 
                            right: 0, 
                            background: "rgba(0,0,0,0.7)", 
                            padding: "4px", 
                            fontSize: "0.7em", 
                            whiteSpace: "nowrap", 
                            overflow: "hidden", 
                            textOverflow: "ellipsis" 
                        }}>
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
