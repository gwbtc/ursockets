import type { Poast } from "@/types/trill";

export const versionNum = "0.1.0";
export const TIMEOUT = 15_000;

export const ChatPostCount = 50;
export const FeedPostCount = 50;
export const RumorShip = "~londev-dozzod-sortug";
export const RumorShip2 = "~paldev";

export function isRumor(poast: Poast) {
  return poast.author === RumorShip || poast.author === RumorShip2;
}

export const MOBILE_BROWSER_REGEX =
  /Android|webOS|iPhone|iPad|iPod|BlackBerry/i;
export const AUDIO_REGEX = new RegExp(/https:\/\/.+\.(mp3|wav|ogg)\b/gim);
export const VIDEO_REGEX = new RegExp(/https:\/\/.+\.(mov|mp4|ogv)\b/gim);
export const TWITTER_REGEX = new RegExp(
  /https:\/\/(twitter|x)\.com\/.+\/status\/\d+/gim,
);

export const REF_REGEX = new RegExp(
  /urbit:\/\/[a-z0-9-]+\/~[a-z-_]+\/[a-z0-9-_]+/gim,
);
export const RADIO_REGEX = new RegExp(/urbit:\/\/radio\/~[a-z-_]+/gim);

export const IMAGE_REGEX = new RegExp(
  /https:\/\/.+\.(jpg|img|png|gif|tiff|jpeg|webp|webm|svg)\b/gim,
);

export const SHIP_REGEX = new RegExp(/\B~[a-z-]+/);
export const HASHTAGS_REGEX = new RegExp(/#[a-z-]+/g);

export const DEFAULT_DATE = { year: 1970, month: 1, day: 1 };
export const RADIO = "📻";
