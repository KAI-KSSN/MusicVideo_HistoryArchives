import { reviews } from "./data/published-knowledge-graph-sprint-2.mjs";

const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
const key = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;

if (!url || !key) {
  throw new Error("NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY are required.");
}

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

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

const [works, technologies, visualLanguages, workTechnologies, workVisualLanguages] = await Promise.all([
  read("archive_works", "select=id,slug,status&status=eq.published"),
  read("technologies", "select=slug,name,name_ja,description,description_ja&lifecycle_status=eq.published&is_active=eq.true"),
  read("visual_languages", "select=slug,name,name_ja,description,description_ja&lifecycle_status=eq.published&is_active=eq.true"),
  read("archive_work_technologies", "select=workId,workSlug,conceptSlug,relationshipRole,relevance,noteJa,noteEn"),
  read("archive_work_visual_languages", "select=workId,workSlug,conceptSlug,relationshipRole,relevance,noteJa,noteEn"),
]);

// Sprint 2 is a frozen review cohort. Later standard work additions must not
// make this historical validator fail merely because the live archive grows.
const reviewSlugs = new Set(reviews.map((review) => review.slug));
const reviewedWorks = works.filter((work) => reviewSlugs.has(work.slug));
const reviewedTechnologyEdges = workTechnologies.filter((edge) => reviewSlugs.has(edge.workSlug));
const reviewedVisualEdges = workVisualLanguages.filter((edge) => reviewSlugs.has(edge.workSlug));

assert(reviewedWorks.length === reviews.length,
  `Expected all ${reviews.length} Sprint 2 works to remain published, found ${reviewedWorks.length}.`);
assert(reviewedTechnologyEdges.length === 15,
  `Expected 15 Sprint 2 Technology edges, found ${reviewedTechnologyEdges.length}.`);
assert(reviewedVisualEdges.length === 147,
  `Expected 147 Sprint 2 Visual Language edges, found ${reviewedVisualEdges.length}.`);

for (const concept of [...technologies, ...visualLanguages]) {
  assert(concept.name && concept.name_ja && concept.description && concept.description_ja,
    `Concept ${concept.slug} is missing bilingual public metadata.`);
}

for (const edge of [...workTechnologies, ...workVisualLanguages]) {
  assert(edge.noteJa && edge.noteEn, `${edge.workSlug}/${edge.conceptSlug} is missing a bilingual relationship note.`);
}

for (const edges of [workTechnologies, workVisualLanguages]) {
  const keys = edges.map((edge) => `${edge.workId}:${edge.conceptSlug}`);
  assert(new Set(keys).size === keys.length, "Duplicate public work/concept relationship detected.");
}

for (const slug of ["kenshi-yonezu-lemon", "hikaru-utada-one-last-kiss"]) {
  assert(!workTechnologies.some((edge) => edge.workSlug === slug), `${slug} unexpectedly has a public Technology edge.`);
  assert(!workVisualLanguages.some((edge) => edge.workSlug === slug), `${slug} unexpectedly has a public Visual Language edge.`);
}

assert(!workTechnologies.some((edge) => ["earliest_verified_adoption", "early_adoption", "breakthrough_use"].includes(edge.relationshipRole)),
  "Unsupported historical-priority Technology role is public.");

await Promise.all([
  expectDenied("knowledge_graph_work_reviews"),
  expectDenied("work_technologies", "select=verification_notes&limit=1"),
  expectDenied("work_visual_languages", "select=verification_notes&limit=1"),
  expectDenied("work_technology_sources"),
  expectDenied("work_visual_language_sources"),
]);

const technologyWorks = new Set(workTechnologies.map((edge) => edge.workId)).size;
const visualWorks = new Set(workVisualLanguages.map((edge) => edge.workId)).size;

console.log(JSON.stringify({
  status: "passed",
  publishedWorksReviewed: reviewedWorks.length,
  currentPublishedWorks: works.length,
  worksWithTechnology: technologyWorks,
  worksWithVisualLanguage: visualWorks,
  worksIntentionallyWithoutTechnology: works.length - technologyWorks,
  worksIntentionallyWithoutVisualLanguage: works.length - visualWorks,
  verifiedRelationships: {
    technology: workTechnologies.length,
    visualLanguage: workVisualLanguages.length,
  },
  candidateRelationships: 0,
  disputedRelationships: 0,
  newConceptsProposed: 0,
  newConceptsApproved: 0,
  protectedResearchFields: "not publicly readable",
}, null, 2));
