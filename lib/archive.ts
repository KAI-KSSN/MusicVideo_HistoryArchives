import { cache } from "react";
import type { AwardResult, LocalizedText, MusicVideo } from "@/types/music-video";
import { decorateVideo, videos as jsonVideos } from "@/lib/videos";

type ArchiveEditorial = {
  shortSummary?: string | null;
  whyItMatters?: string | null;
  historicalContext?: string | null;
  keyInnovation?: string | null;
};

type ArchiveRow = {
  id: string;
  work_type: string;
  slug: string;
  title: string;
  release_year: number | null;
  country_code: string | null;
  status: MusicVideo["publicationStatus"];
  is_canonical: boolean;
  official_release_url: string | null;
  artist: string | null;
  director: string | null;
  production_company: string | null;
  vfx_production: string | null;
  youtube_id: string | null;
  thumbnail_url: string | null;
  awards: string | null;
  editorials: Record<"ja" | "en", ArchiveEditorial> | Partial<Record<"ja" | "en", ArchiveEditorial>>;
  tags: Array<{ name: string; category: string }>;
  sources: Array<{ title: string | null; publisher: string | null; url: string }>;
};

type ArchiveAwardRow = AwardResult & { workSlug: string };

const dataSource = process.env.MVHL_DATA_SOURCE ?? "supabase";
const allowJsonFallback = process.env.MVHL_JSON_FALLBACK === "true";

function localizedField(
  editorials: ArchiveRow["editorials"],
  field: keyof ArchiveEditorial,
): LocalizedText | undefined {
  const ja = editorials?.ja?.[field] ?? undefined;
  const en = editorials?.en?.[field] ?? undefined;

  return ja || en ? { ja: ja ?? undefined, en: en ?? undefined } : undefined;
}

function mapArchiveRow(row: ArchiveRow, awards: AwardResult[] = []): MusicVideo {
  const genre = row.tags.find((tag) => tag.category === "genre")?.name ?? "";
  const isDomestic = row.country_code === "JP";
  const summary = localizedField(row.editorials, "shortSummary");
  const whyItMatters = localizedField(row.editorials, "whyItMatters");
  const historicalContext = localizedField(row.editorials, "historicalContext");
  const keyInnovation = localizedField(row.editorials, "keyInnovation");

  return decorateVideo({
    id: row.id,
    slug: row.slug,
    title: row.title,
    artist: row.artist ?? "",
    year: row.release_year,
    decade: row.release_year ? Math.floor(row.release_year / 10) * 10 : null,
    director: row.director ?? "",
    productionCompany: row.production_company ?? "",
    vfxProduction: row.vfx_production ?? "",
    genre,
    region: isDomestic ? "Japan" : "Global",
    scope: isDomestic ? "Domestic" : "International",
    selectionBasis: whyItMatters?.en ?? whyItMatters?.ja ?? "",
    award: awards
      .map((result) => `${result.awardName} — ${result.categoryName} (${result.awardYear})`)
      .join("\n"),
    awards,
    referenceUrl: row.official_release_url ?? "",
    researchStatus: row.status ?? "published",
    priority: row.is_canonical ? 1 : 2,
    youtubeId: row.youtube_id ?? "",
    thumbnailUrl: row.thumbnail_url ?? undefined,
    shortSummary: summary?.en ?? summary?.ja,
    whyItMatters: whyItMatters?.en ?? whyItMatters?.ja,
    historicalContext: historicalContext?.en ?? historicalContext?.ja,
    keyInnovation: keyInnovation?.en ?? keyInnovation?.ja,
    shortSummaryI18n: summary,
    whyItMattersI18n: whyItMatters,
    historicalContextI18n: historicalContext,
    keyInnovationI18n: keyInnovation,
    workType: row.work_type,
    publicationStatus: row.status,
    tags: row.tags,
    sources: row.sources.map((source) => ({
      title: source.title ?? "Source",
      publisher: source.publisher ?? "",
      url: source.url,
    })),
  });
}

async function fetchArchiveAwards(slug?: string): Promise<ArchiveAwardRow[]> {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
  if (!url || !key) throw new Error("Supabase environment variables are missing.");

  const params = new URLSearchParams({ select: "*", order: "awardYear.desc,awardName,categoryName" });
  if (slug) params.set("workSlug", `eq.${slug}`);

  const response = await fetch(`${url}/rest/v1/archive_award_results?${params}`, {
    headers: { apikey: key, Authorization: `Bearer ${key}` },
    next: { revalidate: 60 },
  });
  if (!response.ok) throw new Error(`Supabase awards request failed (${response.status}).`);
  return (await response.json()) as ArchiveAwardRow[];
}

async function fetchArchiveRows(slug?: string): Promise<ArchiveRow[]> {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;

  if (!url || !key) {
    throw new Error("Supabase environment variables are missing.");
  }

  const params = new URLSearchParams({
    select: "*",
    order: "release_year.asc.nullslast,title.asc",
  });

  if (slug) params.set("slug", `eq.${slug}`);

  const response = await fetch(`${url}/rest/v1/archive_works?${params}`, {
    headers: {
      apikey: key,
      Authorization: `Bearer ${key}`,
    },
    next: { revalidate: 60 },
  });

  if (!response.ok) {
    throw new Error(`Supabase archive request failed (${response.status}).`);
  }

  return (await response.json()) as ArchiveRow[];
}

async function withFallback<T>(
  fromSupabase: () => Promise<T>,
  fromJson: () => T,
): Promise<T> {
  if (dataSource !== "supabase") return fromJson();

  try {
    return await fromSupabase();
  } catch (error) {
    if (!allowJsonFallback) throw error;
    console.warn("MVHL: Supabase unavailable; using explicit JSON fallback.", error);
    return fromJson();
  }
}

export const getPublishedWorks = cache(async (): Promise<MusicVideo[]> =>
  withFallback(
    async () => {
      const [rows, awardRows] = await Promise.all([fetchArchiveRows(), fetchArchiveAwards()]);
      const awardsBySlug = new Map<string, ArchiveAwardRow[]>();
      for (const award of awardRows) {
        awardsBySlug.set(award.workSlug, [...(awardsBySlug.get(award.workSlug) ?? []), award]);
      }
      return rows.map((row) => mapArchiveRow(row, awardsBySlug.get(row.slug) ?? []));
    },
    () => [...jsonVideos].sort((a, b) => {
      const yearA = a.year ?? Number.MAX_SAFE_INTEGER;
      const yearB = b.year ?? Number.MAX_SAFE_INTEGER;
      return yearA - yearB || a.title.localeCompare(b.title, "ja");
    }),
  ),
);

export const getPublishedWorkBySlug = cache(
  async (slug: string): Promise<MusicVideo | undefined> =>
    withFallback(
      async () => {
        const [[row], awards] = await Promise.all([fetchArchiveRows(slug), fetchArchiveAwards(slug)]);
        return row ? mapArchiveRow(row, awards) : undefined;
      },
      () => jsonVideos.find((video) => video.slug === slug),
    ),
);
