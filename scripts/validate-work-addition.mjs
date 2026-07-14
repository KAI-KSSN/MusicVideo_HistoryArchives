import { readFile } from "node:fs/promises";

const manifestPath = process.argv[2];
if (!manifestPath) throw new Error("Usage: node scripts/validate-work-addition.mjs <research-manifest.json>");

const manifest = JSON.parse(await readFile(manifestPath, "utf8"));
const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
const key = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
if (!url || !key) throw new Error("NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY are required.");

const headers = { apikey: key, Authorization: `Bearer ${key}`, Accept: "application/json" };
async function read(table, query = "") {
  const response = await fetch(`${url}/rest/v1/${table}?${query}`, { headers });
  const body = await response.text();
  if (!response.ok) throw new Error(`${table} returned ${response.status}: ${body}`);
  return body ? JSON.parse(body) : [];
}
async function expectDenied(table, query = "select=*&limit=1") {
  const response = await fetch(`${url}/rest/v1/${table}?${query}`, { headers });
  if (response.ok) throw new Error(`Public client unexpectedly read protected data from ${table}.`);
}
function assert(condition, message) { if (!condition) throw new Error(message); }

const expected = manifest.work;
const slug = encodeURIComponent(expected.slug);
const [works, technologyEdges, visualEdges] = await Promise.all([
  read("archive_works", `select=*&slug=eq.${slug}&status=eq.published`),
  read("archive_work_technologies", `select=workId,workSlug,conceptSlug,relationshipRole,relevance,noteJa,noteEn&workSlug=eq.${slug}`),
  read("archive_work_visual_languages", `select=workId,workSlug,conceptSlug,relationshipRole,relevance,noteJa,noteEn&workSlug=eq.${slug}`),
]);

assert(works.length === 1, `Expected one published work for ${expected.slug}, found ${works.length}.`);
const work = works[0];
for (const [actual, value, label] of [
  [work.title, expected.title, "title"], [work.artist, expected.artist, "artist"],
  [work.release_year, expected.releaseYear, "release year"], [work.country_code, expected.countryCode, "country"],
  [work.director, expected.director, "director"], [work.production_company, expected.productionCompany, "production company"],
  [work.vfx_production, expected.vfxProduction, "VFX production"], [work.youtube_id, expected.youtubeId, "YouTube ID"],
  [work.official_release_url, expected.officialUrl, "official URL"], [work.thumbnail_url, expected.thumbnailUrl, "thumbnail URL"],
]) assert(actual === value, `Unexpected ${label}: ${actual}`);

assert(work.editorials?.ja && work.editorials?.en, "Bilingual editorial is incomplete.");
for (const locale of ["ja", "en"]) for (const field of ["shortSummary", "whyItMatters", "historicalContext", "keyInnovation"])
  assert(work.editorials[locale][field], `${locale}.${field} is empty.`);
assert(Array.isArray(work.sources) && work.sources.length >= manifest.minimumPublicSources,
  `Expected at least ${manifest.minimumPublicSources} public sources, found ${work.sources?.length ?? 0}.`);

function validateEdges(actual, expectedEdges, label) {
  assert(actual.length === expectedEdges.length, `Expected ${expectedEdges.length} ${label} edges, found ${actual.length}.`);
  for (const edge of expectedEdges) {
    const found = actual.find((item) => item.conceptSlug === edge.slug);
    assert(found, `${label} edge ${edge.slug} is missing.`);
    assert(found.relevance === edge.relevance, `${label} ${edge.slug} relevance is ${found.relevance}.`);
    assert(found.relationshipRole === edge.relationshipRole, `${label} ${edge.slug} role is ${found.relationshipRole}.`);
    assert(found.noteJa && found.noteEn, `${label} ${edge.slug} lacks bilingual notes.`);
  }
}
validateEdges(technologyEdges, manifest.expectedTechnology, "Technology");
validateEdges(visualEdges, manifest.expectedVisualLanguage, "Visual Language");
for (const rejected of manifest.rejectedConcepts)
  assert(!visualEdges.some((edge) => edge.conceptSlug === rejected.slug), `Rejected concept ${rejected.slug} is public.`);

await Promise.all([
  expectDenied("knowledge_graph_work_reviews"),
  expectDenied("work_technologies", "select=verification_notes&limit=1"),
  expectDenied("work_visual_languages", "select=verification_notes&limit=1"),
  expectDenied("work_technology_sources"),
  expectDenied("work_visual_language_sources"),
]);

console.log(JSON.stringify({
  status: "passed", workId: work.id, slug: work.slug, publicSources: work.sources.length,
  technology: technologyEdges.map((edge) => edge.conceptSlug),
  visualLanguage: visualEdges.map((edge) => edge.conceptSlug),
  awardsAdded: manifest.awardAudit.verifiedVideoResults.length,
  protectedResearchFields: "not publicly readable",
}, null, 2));
