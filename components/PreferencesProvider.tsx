"use client";

import {
  createContext,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";

export type ThemeMode = "light" | "dark";
export type DetailLanguage = "ja" | "en";

type Preferences = {
  theme: ThemeMode;
  language: DetailLanguage;
  setTheme: (theme: ThemeMode) => void;
  setLanguage: (language: DetailLanguage) => void;
  toggleTheme: () => void;
};

const PreferencesContext = createContext<Preferences | null>(null);

export default function PreferencesProvider({
  children,
}: {
  children: ReactNode;
}) {
  const [theme, setThemeState] = useState<ThemeMode>("light");
  const [language, setLanguageState] = useState<DetailLanguage>("ja");
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    const savedTheme = window.localStorage.getItem("mvhl-theme");
    const savedLanguage = window.localStorage.getItem("mvhl-language");

    if (savedTheme === "light" || savedTheme === "dark") {
      setThemeState(savedTheme);
    } else if (window.matchMedia("(prefers-color-scheme: dark)").matches) {
      setThemeState("dark");
    }

    if (savedLanguage === "ja" || savedLanguage === "en") {
      setLanguageState(savedLanguage);
    }

    setMounted(true);
  }, []);

  useEffect(() => {
    if (!mounted) return;
    document.documentElement.dataset.theme = theme;
    document.documentElement.style.colorScheme = theme;
    window.localStorage.setItem("mvhl-theme", theme);
  }, [theme, mounted]);

  useEffect(() => {
    if (!mounted) return;
    document.documentElement.lang = language;
    window.localStorage.setItem("mvhl-language", language);
  }, [language, mounted]);

  const value = useMemo(
    () => ({
      theme,
      language,
      setTheme: setThemeState,
      setLanguage: setLanguageState,
      toggleTheme: () =>
        setThemeState((current) => (current === "light" ? "dark" : "light")),
    }),
    [theme, language],
  );

  return (
    <PreferencesContext.Provider value={value}>
      {children}
    </PreferencesContext.Provider>
  );
}

export function usePreferences() {
  const context = useContext(PreferencesContext);

  if (!context) {
    throw new Error("usePreferences must be used inside PreferencesProvider.");
  }

  return context;
}
