export type MusicVideo = {
  id: string; title: string; artist: string; year: number | null; decade: number | null;
  director: string; productionCompany: string; vfxProduction: string; genre: string;
  region: string; scope: "Domestic" | "International"; selectionBasis: string; award: string;
  referenceUrl: string; researchStatus: string; priority: number; youtubeId: string;
};
