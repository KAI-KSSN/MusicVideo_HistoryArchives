import fs from "node:fs/promises";

const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
const key = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
if (!url || !key) throw new Error("Supabase environment variables are missing");

const migration = await fs.readFile(
  "supabase/migrations/20260713120000_publish_verified_canon_works.sql",
  "utf8",
);
const publicationStatement = migration.match(
  /update public\.works set status='published'.*?where slug in \((.*?)\);/s,
);
if (!publicationStatement) throw new Error("Could not locate Canon publication slug list");
const expectedSlugs = new Set(
  [...publicationStatement[1].matchAll(/'([^']+)'/g)].map((match) => match[1]),
);

const headers = { apikey: key, Authorization: `Bearer ${key}` };
async function get(resource) {
  const response = await fetch(`${url}/rest/v1/${resource}`, { headers, cache: "no-store" });
  if (!response.ok) throw new Error(`${resource}: ${response.status} ${await response.text()}`);
  return response.json();
}

const [works, awards] = await Promise.all([
  get("archive_works?select=*&order=release_year.asc,title.asc"),
  get("archive_award_results?select=*&order=awardYear.asc,awardName,categoryName"),
]);

if (expectedSlugs.size !== 68) throw new Error(`Expected 68 publication slugs; got ${expectedSlugs.size}`);
for (const slug of expectedSlugs) {
  const work = works.find((candidate) => candidate.slug === slug);
  if (!work) throw new Error(`Published Canon work is missing: ${slug}`);
  for (const field of ["title", "release_year", "country_code", "artist", "director", "youtube_id"]) {
    if (!work[field]) throw new Error(`${slug}: missing required public field ${field}`);
  }
  for (const locale of ["ja", "en"]) {
    for (const field of ["shortSummary", "whyItMatters", "historicalContext", "keyInnovation"]) {
      if (!work.editorials?.[locale]?.[field]) throw new Error(`${slug}: missing ${locale}.${field}`);
    }
  }
  if (!work.sources?.length) throw new Error(`${slug}: no public sources`);
  if (!work.tags?.some((tag) => tag.category === "movement")) throw new Error(`${slug}: no approved movement tag`);
}

const canonAwards = awards.filter((award) => expectedSlugs.has(award.workSlug));
if (canonAwards.length !== 86) throw new Error(`Expected 86 verified Canon award rows; got ${canonAwards.length}`);

const oneLastKissAwards = awards.filter((award) => award.workSlug === "hikaru-utada-one-last-kiss");
if (oneLastKissAwards.length !== 1 || oneLastKissAwards[0].categoryName !== "BEST CONCEPTUAL VIDEO") {
  throw new Error("One Last Kiss must expose only the verified work-level BEST CONCEPTUAL VIDEO result");
}

console.log(JSON.stringify({
  publicWorks: works.length,
  verifiedCanonWorks: expectedSlugs.size,
  newCanonWorks: expectedSlugs.size - 9,
  heldCanonWorks: 30,
  verifiedCanonAwardResults: canonAwards.length,
  status: "verified_live_publication",
}, null, 2));
