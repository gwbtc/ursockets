export type Ship = string;
export interface S3Bucket {
  accessKeyId: string;
  endpoint: string;
  secretAccessKey: string;
  bucket: string;
  region: string;
}