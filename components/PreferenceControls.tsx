"use client";

import { usePreferences } from "@/components/PreferencesProvider";

export default function PreferenceControls() {
  const { theme, language, toggleTheme, setLanguage } = usePreferences();

  return (
    <div className="preference-controls" aria-label="Display preferences">
      <button
        className="theme-toggle"
        type="button"
        onClick={toggleTheme}
        aria-label={theme === "light" ? "Switch to dark theme" : "Switch to light theme"}
      >
        <span className="theme-toggle-dot" />
        <span>{theme === "light" ? "Dark" : "Light"}</span>
      </button>

      <div className="language-switch" aria-label="Detail language">
        <button
          type="button"
          className={language === "ja" ? "active" : ""}
          onClick={() => setLanguage("ja")}
          aria-pressed={language === "ja"}
        >
          JP
        </button>
        <button
          type="button"
          className={language === "en" ? "active" : ""}
          onClick={() => setLanguage("en")}
          aria-pressed={language === "en"}
        >
          EN
        </button>
      </div>
    </div>
  );
}
