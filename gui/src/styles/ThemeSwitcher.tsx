import React, { useState } from "react";
import { useTheme, type ThemeName } from "../styles/ThemeProvider";
import "./ThemeSwitcher.css";

interface ThemeSwitcherProps {
  variant?: "dropdown" | "buttons" | "compact";
  showLabel?: boolean;
}

const themeIcons: Record<ThemeName, string> = {
  light: "☀️",
  dark: "🌙",
  sepia: "📜",
  noir: "⚫",
  ocean: "🌊",
  forest: "🌲",
  gruvbox: "🍂",
  christmas: "🎄",
};

const themeLabels: Record<ThemeName, string> = {
  light: "Light",
  dark: "Dark",
  sepia: "Sepia",
  noir: "Noir",
  ocean: "Ocean",
  forest: "Forest",
  gruvbox: "Gruvbox",
  christmas: "Christmas",
};

export const ThemeSwitcher: React.FC<ThemeSwitcherProps> = ({
  variant = "dropdown",
  showLabel = true,
}) => {
  const { themeName, setTheme, availableThemes } = useTheme();
  const [isOpen, setIsOpen] = useState(false);

  const handleThemeChange = (theme: ThemeName) => {
    setTheme(theme);
    setIsOpen(false);
  };

  const cycleTheme = () => {
    const currentIndex = availableThemes.indexOf(themeName);
    const nextIndex = (currentIndex + 1) % availableThemes.length;
    setTheme(availableThemes[nextIndex]);
  };

  if (variant === "compact") {
    return (
      <button
        className="theme-switcher-compact"
        onClick={cycleTheme}
        title={`Current theme: ${themeLabels[themeName]}. Click to switch.`}
        aria-label="Switch theme"
      >
        <span className="theme-icon">{themeIcons[themeName]}</span>
        {showLabel && (
          <span className="theme-label">{themeLabels[themeName]}</span>
        )}
      </button>
    );
  }

  if (variant === "buttons") {
    return (
      <div className="theme-switcher-buttons">
        {showLabel && <span className="theme-label">Theme:</span>}
        <div className="theme-buttons-group">
          {availableThemes.map((theme) => (
            <button
              key={theme}
              className={`theme-button ${themeName === theme ? "active" : ""}`}
              onClick={() => handleThemeChange(theme)}
              title={themeLabels[theme]}
              aria-label={`Switch to ${themeLabels[theme]} theme`}
              aria-pressed={themeName === theme}
            >
              <span className="theme-icon">{themeIcons[theme]}</span>
              {showLabel && (
                <span className="theme-name">{themeLabels[theme]}</span>
              )}
            </button>
          ))}
        </div>
      </div>
    );
  }

  // Default dropdown variant
  return (
    <div className="theme-switcher-dropdown">
      <button
        className="theme-dropdown-toggle"
        onClick={() => setIsOpen(!isOpen)}
        aria-haspopup="true"
        aria-expanded={isOpen}
      >
        <span className="theme-icon">{themeIcons[themeName]}</span>
        {showLabel && (
          <span className="theme-label">{themeLabels[themeName]}</span>
        )}
        <span className="dropdown-arrow">▼</span>
      </button>

      {isOpen && (
        <>
          <div
            className="theme-dropdown-backdrop"
            onClick={() => setIsOpen(false)}
            aria-hidden="true"
          />
          <div className="theme-dropdown-menu" role="menu">
            {availableThemes.map((theme) => (
              <button
                key={theme}
                className={`theme-dropdown-item ${themeName === theme ? "active" : ""}`}
                onClick={() => handleThemeChange(theme)}
                role="menuitem"
                aria-selected={themeName === theme}
              >
                <span className="theme-icon">{themeIcons[theme]}</span>
                <span className="theme-name">{themeLabels[theme]}</span>
                {themeName === theme && <span className="checkmark">✓</span>}
              </button>
            ))}
          </div>
        </>
      )}
    </div>
  );
};
