const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
const key = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;

if (!url || !key) {
  throw new Error(
    "NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY are required.",
  );
}

const headers = {
  apikey: key,
  Authorization: `Bearer ${key}`,
  Accept: "application/json",
};

async function read(table, query) {
  const response = await fetch(`${url}/rest/v1/${table}?${query}`, { headers });
  const text = await response.text();
  if (!response.ok) {
    throw new Error(`${table} returned ${response.status}: ${text}`);
  }
  return text ? JSON.parse(text) : [];
}

const [works, technologies, visualLanguages] = await Promise.all([
  read(
    "archive_works",
    "select=id,slug,artist,title,release_year,status,official_release_url,youtube_id,director,production_company,vfx_production,editorials,tags,sources&status=eq.published&order=release_year.asc.nullslast,artist.asc,title.asc",
  ),
  read(
    "archive_work_technologies",
    "select=workId,conceptSlug,conceptName,relationshipRole,relevance&order=workSlug.asc,displayOrder.asc",
  ),
  read(
    "archive_work_visual_languages",
    "select=workId,conceptSlug,conceptName,relationshipRole,relevance&order=workSlug.asc,displayOrder.asc",
  ),
]);

const technologiesByWork = Map.groupBy(technologies, (relationship) => relationship.workId);
const visualLanguagesByWork = Map.groupBy(
  visualLanguages,
  (relationship) => relationship.workId,
);

const scope = works.map((work) => ({
  ...work,
  technologies: technologiesByWork.get(work.id) ?? [],
  visualLanguages: visualLanguagesByWork.get(work.id) ?? [],
}));

console.log(JSON.stringify({ totalPublishedWorks: scope.length, works: scope }, null, 2));
