import { AwsClient } from "aws4fetch";
import type { S3Config } from "@/state/state";

export async function uploadToS3(file: File, config: S3Config): Promise<string> {
  if (!config.accessKeyId || !config.secretAccessKey || !config.endpoint || !config.currentBucket) {
    throw new Error("Incomplete S3 configuration");
  }

  const client = new AwsClient({
    accessKeyId: config.accessKeyId,
    secretAccessKey: config.secretAccessKey,
    region: config.region || "us-east-1",
    service: "s3",
  });

  const timestamp = Date.now();
  const random = Math.random().toString(36).substring(2, 8);
  const ext = file.name.split(".").pop();
  const key = `${timestamp}-${random}.${ext}`;
  
  // Determine URL structure
  // If endpoint contains 'amazonaws.com', use virtual-hosted style if possible, but path style is safer for generic S3 compat (MinIO etc) unless subdomain is required.
  // Actually, aws4fetch handles signing, but we need to construct the URL.
  // Standard Urbit S3 providers often use path style: https://endpoint/bucket/key
  
  let url: string;
  let publicUrl: string;
  
  // Strip protocol from endpoint for cleaner handling
  const endpoint = config.endpoint.replace(/^https?:\/\//, "");
  const protocol = config.endpoint.startsWith("http:") ? "http://" : "https://";

  // Path-style URL construction (safest default for self-hosted/MinIO)
  url = `${protocol}${endpoint}/${config.currentBucket}/${key}`;
  publicUrl = url;

  // Perform Upload
  const res = await client.fetch(url, {
    method: "PUT",
    body: file,
    headers: {
      "Content-Type": file.type,
      "x-amz-acl": "public-read", // Try to make it public
    },
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`S3 Upload Failed: ${res.status} ${res.statusText} - ${text}`);
  }

  return publicUrl;
}
