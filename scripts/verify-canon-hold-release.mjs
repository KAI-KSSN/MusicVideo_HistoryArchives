const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
const key = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
if (!url || !key) throw new Error("Supabase environment variables are missing");

const expected = new Map([
  ["imai-fly", { year: 2017, youtubeId: "iQi3aMQXip8", director: "Baku Hashimoto", awards: 0 }],
  ["wednesday-campanella-baku", { year: 2017, youtubeId: "mdEO6-Xv3O4", director: "鎌谷聡次郎", awards: 0 }],
  ["max-cooper-repetition", { year: 2019, youtubeId: "nO9aot9RgQc", director: "Kevin McGloughlin", awards: 3 }],
]);

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

for (const [slug, expectedWork] of expected) {
  const work = works.find((candidate) => candidate.slug === slug);
  if (!work) throw new Error(`Published work is missing: ${slug}`);
  if (work.release_year !== expectedWork.year) throw new Error(`${slug}: release year mismatch`);
  if (work.youtube_id !== expectedWork.youtubeId) throw new Error(`${slug}: YouTube ID mismatch`);
  if (work.director !== expectedWork.director) throw new Error(`${slug}: director mismatch`);
  for (const locale of ["ja", "en"]) {
    for (const field of ["shortSummary", "whyItMatters", "historicalContext", "keyInnovation"]) {
      if (!work.editorials?.[locale]?.[field]) throw new Error(`${slug}: missing ${locale}.${field}`);
    }
  }
  if (!work.sources?.length) throw new Error(`${slug}: no public sources`);
  if (!work.tags?.some((tag) => tag.category === "movement")) throw new Error(`${slug}: no movement tag`);
  const workAwards = awards.filter((award) => award.workSlug === slug);
  if (workAwards.length !== expectedWork.awards) {
    throw new Error(`${slug}: expected ${expectedWork.awards} award rows, got ${workAwards.length}`);
  }
}

const repetitionAwards = awards.filter((award) => award.workSlug === "max-cooper-repetition");
const exactResults = new Set(repetitionAwards.map((award) => `${award.awardName}|${award.categoryName}|${award.result}`));
for (const result of [
  "Berlin Music Video Awards|Best Experimental|winner",
  "Berlin Music Video Awards|Best Director|nominee",
  "UK Music Video Awards|Best Animation in a Video|shortlist",
]) {
  if (!exactResults.has(result)) throw new Error(`Missing exact Repetition result: ${result}`);
}

console.log(JSON.stringify({
  publicWorks: works.length,
  resolvedCanonWorksPublished: expected.size,
  remainingHeldCanonWorks: 27,
  repetitionAwardResults: repetitionAwards.length,
  status: "verified_live_hold_release",
}, null, 2));
