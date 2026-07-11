"use client";

import { usePreferences } from "@/components/PreferencesProvider";
import type { LocalizedText } from "@/types/music-video";

type Props = {
  localized?: LocalizedText;
  fallback?: string;
  emptyJa: string;
  emptyEn: string;
};

export default function LocalizedEditorial({
  localized,
  fallback,
  emptyJa,
  emptyEn,
}: Props) {
  const { language } = usePreferences();

  const selected =
    localized?.[language] ||
    localized?.en ||
    localized?.ja ||
    fallback ||
    (language === "ja" ? emptyJa : emptyEn);

  return <>{selected}</>;
}
