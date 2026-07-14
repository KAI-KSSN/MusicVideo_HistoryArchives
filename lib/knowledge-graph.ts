import { cache } from "react";
import { fetchSupabasePublic } from "@/lib/supabase-public";
import type {
  KnowledgeConcept,
  KnowledgeConceptType,
  KnowledgeGraphRelationship,
} from "@/types/music-video";

type TechnologyRow = {
  id: string;
  slug: string;
  name: string;
  name_ja: string | null;
  description: string | null;
  description_ja: string | null;
  technology_type: string;
};

type VisualLanguageRow = {
  id: string;
  slug: string;
  name: string;
  name_ja: string | null;
  description: string | null;
  description_ja: string | null;
  visual_language_type: string;
};

function supabaseConfig() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;

  if (!url || !key) {
    throw new Error("Supabase environment variables are missing.");
  }

  return { url, key };
}

async function publicRequest<T>(path: string, params: URLSearchParams): Promise<T> {
  const { url, key } = supabaseConfig();
  const response = await fetchSupabasePublic(`${url}/rest/v1/${path}?${params}`, {
    headers: { apikey: key, Authorization: `Bearer ${key}` },
    next: { revalidate: 60 },
  }, "Supabase knowledge-graph request");

  if (!response.ok) {
    throw new Error(`Supabase knowledge-graph request failed (${response.status}).`);
  }

  return (await response.json()) as T;
}

function mapTechnology(row: TechnologyRow): KnowledgeConcept {
  return {
    id: row.id,
    slug: row.slug,
    name: row.name,
    nameJa: row.name_ja ?? undefined,
    descriptionEn: row.description ?? undefined,
    descriptionJa: row.description_ja ?? undefined,
    family: row.technology_type,
    type: "technology",
  };
}

function mapVisualLanguage(row: VisualLanguageRow): KnowledgeConcept {
  return {
    id: row.id,
    slug: row.slug,
    name: row.name,
    nameJa: row.name_ja ?? undefined,
    descriptionEn: row.description ?? undefined,
    descriptionJa: row.description_ja ?? undefined,
    family: row.visual_language_type,
    type: "visual-language",
  };
}

async function fetchConcepts(type: KnowledgeConceptType, slug?: string) {
  const isTechnology = type === "technology";
  const params = new URLSearchParams({
    select: isTechnology
      ? "id,slug,name,name_ja,description,description_ja,technology_type"
      : "id,slug,name,name_ja,description,description_ja,visual_language_type",
    lifecycle_status: "eq.published",
    is_active: "eq.true",
    order: "name.asc",
  });
  if (slug) params.set("slug", `eq.${slug}`);

  if (isTechnology) {
    const rows = await publicRequest<TechnologyRow[]>("technologies", params);
    return rows.map(mapTechnology);
  }

  const rows = await publicRequest<VisualLanguageRow[]>("visual_languages", params);
  return rows.map(mapVisualLanguage);
}

async function fetchRelationships(
  type: KnowledgeConceptType,
  filter: { workSlug?: string; conceptSlug?: string } = {},
) {
  const params = new URLSearchParams({
    select: "*",
    order: "releaseYear.asc.nullslast,displayOrder.asc,workTitle.asc",
  });
  if (filter.workSlug) params.set("workSlug", `eq.${filter.workSlug}`);
  if (filter.conceptSlug) params.set("conceptSlug", `eq.${filter.conceptSlug}`);

  const view = type === "technology"
    ? "archive_work_technologies"
    : "archive_work_visual_languages";

  return publicRequest<KnowledgeGraphRelationship[]>(view, params);
}

export const getPublishedConcepts = cache(async (type: KnowledgeConceptType) =>
  fetchConcepts(type));

export const getPublishedConceptBySlug = cache(
  async (type: KnowledgeConceptType, slug: string) => {
    const [concepts, relationships] = await Promise.all([
      fetchConcepts(type, slug),
      fetchRelationships(type, { conceptSlug: slug }),
    ]);

    return concepts[0] ? { concept: concepts[0], relationships } : undefined;
  },
);

export const getWorkKnowledgeGraph = cache(async (workSlug: string) => {
  const [technologies, visualLanguages] = await Promise.all([
    fetchRelationships("technology", { workSlug }),
    fetchRelationships("visual-language", { workSlug }),
  ]);

  return { technologies, visualLanguages };
});
