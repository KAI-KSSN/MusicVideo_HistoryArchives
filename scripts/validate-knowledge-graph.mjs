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

async function read(table, query = "") {
  const response = await fetch(`${url}/rest/v1/${table}?${query}`, { headers });
  const body = await response.text();

  if (!response.ok) {
    throw new Error(`${table} returned ${response.status}: ${body}`);
  }

  return body ? JSON.parse(body) : [];
}

async function expectDenied(table, query) {
  const response = await fetch(`${url}/rest/v1/${table}?${query}`, { headers });

  if (response.ok) {
    throw new Error(`Public client unexpectedly read protected data from ${table}.`);
  }
}

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

const [technologies, visualLanguages, workTechnologies, workVisualLanguages] =
  await Promise.all([
    read("technologies", "select=slug,name,name_ja,description,description_ja&lifecycle_status=eq.published&is_active=eq.true"),
    read("visual_languages", "select=slug,name,name_ja,description,description_ja&lifecycle_status=eq.published&is_active=eq.true"),
    read("archive_work_technologies", "select=workSlug,conceptSlug"),
    read("archive_work_visual_languages", "select=workSlug,conceptSlug"),
  ]);

assert(technologies.length === 31, `Expected 31 technologies, found ${technologies.length}.`);
assert(visualLanguages.length === 32, `Expected 32 visual languages, found ${visualLanguages.length}.`);
assert(workTechnologies.length === 2, `Expected 2 technology edges, found ${workTechnologies.length}.`);
assert(workVisualLanguages.length === 25, `Expected 25 visual-language edges, found ${workVisualLanguages.length}.`);

for (const concept of [...technologies, ...visualLanguages]) {
  assert(
    concept.name && concept.name_ja && concept.description && concept.description_ja,
    `Concept ${concept.slug} is missing bilingual public metadata.`,
  );
}

const edges = [...workTechnologies, ...workVisualLanguages];
const edgeKeys = edges.map((edge) => `${edge.workSlug}:${edge.conceptSlug}`);
assert(new Set(edgeKeys).size === edgeKeys.length, "Duplicate public graph edge detected.");

for (const slug of ["kenshi-yonezu-lemon", "hikaru-utada-one-last-kiss"]) {
  assert(!edges.some((edge) => edge.workSlug === slug), `${slug} must remain intentionally unlinked.`);
}

await Promise.all([
  expectDenied("work_technologies", "select=verification_notes&limit=1"),
  expectDenied("work_visual_languages", "select=verification_notes&limit=1"),
  expectDenied("work_technology_sources", "select=*&limit=1"),
  expectDenied("work_visual_language_sources", "select=*&limit=1"),
]);

console.log(
  JSON.stringify(
    {
      status: "passed",
      concepts: {
        technologies: technologies.length,
        visualLanguages: visualLanguages.length,
      },
      publicRelationships: {
        technologies: workTechnologies.length,
        visualLanguages: workVisualLanguages.length,
      },
      intentionallyUnlinked: [
        "kenshi-yonezu-lemon",
        "hikaru-utada-one-last-kiss",
      ],
      protectedResearchFields: "not publicly readable",
    },
    null,
    2,
  ),
);
