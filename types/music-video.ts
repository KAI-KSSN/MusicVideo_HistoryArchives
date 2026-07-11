export type LocalizedText = {
  ja?: string;
  en?: string;
};

export type MusicVideo = {
  id: string;
  slug?: string;
  title: string;
  artist: string;
  year: number | null;
  decade: number | null;
  director: string;
  productionCompany: string;
  vfxProduction: string;
  genre: string;
  region: string;
  scope: "Domestic" | "International";
  selectionBasis: string;
  award: string;
  referenceUrl: string;
  researchStatus: string;
  priority: number;
  youtubeId: string;
  thumbnailUrl?: string;

  shortSummary?: string;
  whyItMatters?: string;
  historicalContext?: string;
  keyInnovation?: string;

  shortSummaryI18n?: LocalizedText;
  whyItMattersI18n?: LocalizedText;
  historicalContextI18n?: LocalizedText;
  keyInnovationI18n?: LocalizedText;

  primaryColor?: string;
  secondaryColor?: string;

  workType?: string;
  publicationStatus?: "draft" | "candidate" | "researching" | "verified" | "published" | "archived" | "rejected";
  tags?: Array<{ name: string; category: string }>;
  sources?: Array<{ title: string; publisher: string; url: string }>;
};
