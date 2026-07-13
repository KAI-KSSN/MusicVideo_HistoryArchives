import fs from "node:fs/promises";

const manifest = JSON.parse(
  await fs.readFile("docs/research/canon/canon-5star-manifest.json", "utf8"),
);

if (manifest.count !== 98 || manifest.works.length !== 98) {
  throw new Error(`Expected 98 canonical candidates; received ${manifest.works.length}.`);
}

if (manifest.works.some((work) => work.priority !== "★★★★★")) {
  throw new Error("Manifest contains a non-five-star work.");
}

const identities = new Set();
for (const work of manifest.works) {
  const key = `${work.artist}\u0000${work.title}`.toLocaleLowerCase("ja");
  if (identities.has(key)) throw new Error(`Duplicate manifest identity: ${work.artist} — ${work.title}`);
  identities.add(key);
}

const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
const key = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
if (!url || !key) throw new Error("Supabase environment variables are missing.");

const response = await fetch(`${url}/rest/v1/archive_works?select=slug,title,artist,status`, {
  headers: { apikey: key, Authorization: `Bearer ${key}` },
});
if (!response.ok) throw new Error(`archive_works request failed (${response.status}).`);
const published = await response.json();

const normalize = (value) => value
  .normalize("NFKC")
  .toLocaleLowerCase("ja")
  .replace(/[’']/g, "")
  .replace(/[^\p{L}\p{N}]+/gu, " ")
  .trim();

const existing = [];
const newCandidates = [];
for (const work of manifest.works) {
  const match = published.find((row) =>
    normalize(row.artist) === normalize(work.artist) &&
    (normalize(row.title) === normalize(work.title) ||
      normalize(row.title).startsWith(normalize(work.title)) ||
      normalize(work.title).startsWith(normalize(row.title))),
  );
  (match ? existing : newCandidates).push(match ? { ...work, existingSlug: match.slug } : work);
}

const eras = Object.groupBy(manifest.works, (work) => work.era);
console.log(JSON.stringify({
  sourceSha256: manifest.sourceSha256,
  total: manifest.works.length,
  eraCounts: Object.fromEntries(Object.entries(eras).map(([era, works]) => [era, works.length])),
  existingCount: existing.length,
  existing: existing.map(({ artist, title, existingSlug }) => ({ artist, title, existingSlug })),
  newCount: newCandidates.length,
}, null, 2));
