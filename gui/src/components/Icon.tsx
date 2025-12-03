import { useTheme } from "@/styles/ThemeProvider";

import bellSvg from "@/assets/icons/bell.svg";
import cometSvg from "@/assets/icons/comet.svg";
import copySvg from "@/assets/icons/copy.svg";
import crowSvg from "@/assets/icons/crow.svg";
import emojiSvg from "@/assets/icons/emoji.svg";
import homeSvg from "@/assets/icons/home.svg";
import keySvg from "@/assets/icons/key.svg";
import messagesSvg from "@/assets/icons/messages.svg";
import nostrSvg from "@/assets/icons/nostr.svg";
import palsSvg from "@/assets/icons/pals.svg";
import profileSvg from "@/assets/icons/profile.svg";
import quoteSvg from "@/assets/icons/quote.svg";
import radioSvg from "@/assets/icons/radio.svg";
import replySvg from "@/assets/icons/reply.svg";
import repostSvg from "@/assets/icons/rt.svg";
import rumorsSvg from "@/assets/icons/rumors.svg";
import settingsSvg from "@/assets/icons/settings.svg";
import youtubeSvg from "@/assets/icons/youtube.svg";

export type IconName =
  | "bell"
  | "comet"
  | "copy"
  | "crow"
  | "emoji"
  | "home"
  | "key"
  | "messages"
  | "nostr"
  | "pals"
  | "profile"
  | "quote"
  | "radio"
  | "reply"
  | "repost"
  | "rumors"
  | "settings"
  | "youtube";

const iconMap: Record<IconName, string> = {
  bell: bellSvg,
  comet: cometSvg,
  copy: copySvg,
  crow: crowSvg,
  emoji: emojiSvg,
  home: homeSvg,
  key: keySvg,
  messages: messagesSvg,
  nostr: nostrSvg,
  pals: palsSvg,
  profile: profileSvg,
  quote: quoteSvg,
  radio: radioSvg,
  reply: replySvg,
  repost: repostSvg,
  rumors: rumorsSvg,
  settings: settingsSvg,
  youtube: youtubeSvg,
};

interface IconProps {
  name: IconName;
  size?: number;
  className?: string;
  title?: string;
  onClick?: (e: React.MouseEvent) => any;
  color?: "primary" | "text" | "textSecondary" | "textMuted" | "custom";
  customColor?: string;
}

const Icon: React.FC<IconProps> = ({
  name,
  className = "",
  title,
  onClick,
  color: _color = "text",
  customColor: _customColor,
}) => {
  const { theme } = useTheme();

  // Simple filter based on theme - icons should match text
  const getFilter = () => {
    // For dark themes, invert the black SVGs to white
    if (
      theme.name === "dark" ||
      theme.name === "noir" ||
      theme.name === "gruvbox"
    ) {
      return "invert(1)";
    }
    // For light themes with dark text, keep as is
    if (theme.name === "light") {
      return "none";
    }
    // For colored themes, adjust brightness/contrast
    if (theme.name === "sepia") {
      return "sepia(1) saturate(2) hue-rotate(20deg) brightness(0.8)";
    }
    if (theme.name === "ocean") {
      return "brightness(0) saturate(100%) invert(13%) sepia(95%) saturate(3207%) hue-rotate(195deg) brightness(94%) contrast(106%)";
    }
    if (theme.name === "forest") {
      return "brightness(0) saturate(100%) invert(24%) sepia(95%) saturate(1352%) hue-rotate(87deg) brightness(92%) contrast(96%)";
    }
    return "none";
  };

  const iconUrl = iconMap[name];

  if (!iconUrl) {
    console.error(`Icon "${name}" not found`);
    return null;
  }

  return (
    <img
      src={iconUrl}
      className={`icon ${className}`}
      onClick={onClick}
      title={title}
      alt={title || name}
      style={{
        display: "inline-block",
        cursor: onClick ? "pointer" : "default",
        filter: getFilter(),
        transition: "filter 0.2s ease",
      }}
    />
  );
};

export default Icon;
