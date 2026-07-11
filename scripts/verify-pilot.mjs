const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
const key = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
const expected = process.env.EXPECTED_PUBLISHED_SLUGS;

if (!url || !key) {
  throw new Error("Supabase environment variables are missing.");
}

const response = await fetch(
  `${url}/rest/v1/archive_works?select=*&order=release_year.asc.nullslast,title.asc`,
  {
    headers: {
      apikey: key,
      Authorization: `Bearer ${key}`,
    },
  },
);

if (!response.ok) {
  throw new Error(`Public archive request failed (${response.status}).`);
}

const works = await response.json();

for (let index = 1; index < works.length; index += 1) {
  const previous = works[index - 1].release_year ?? Number.MAX_SAFE_INTEGER;
  const current = works[index].release_year ?? Number.MAX_SAFE_INTEGER;

  if (previous > current) {
    throw new Error("Published works are not sorted oldest to newest.");
  }
}

if (works.some((work) => work.status !== "published")) {
  throw new Error("The public archive exposed a non-published work.");
}

const thriller = works.find((work) => work.slug === "michael-jackson-thriller");

if (thriller) {
  const requiredFields = [
    "title",
    "release_year",
    "country_code",
    "artist",
    "director",
    "production_company",
    "official_release_url",
    "youtube_id",
    "thumbnail_url",
  ];

  for (const field of requiredFields) {
    if (!thriller[field]) {
      throw new Error(`Published Thriller is missing required field: ${field}.`);
    }
  }

  for (const locale of ["ja", "en"]) {
    const editorial = thriller.editorials?.[locale];
    if (
      !editorial?.whyItMatters ||
      !editorial?.historicalContext ||
      !editorial?.keyInnovation
    ) {
      throw new Error(`Published Thriller is missing ${locale} editorial data.`);
    }
  }

  if (!Array.isArray(thriller.tags) || thriller.tags.length === 0) {
    throw new Error("Published Thriller has no viewing-lens tags.");
  }

  if (!Array.isArray(thriller.sources) || thriller.sources.length < 2) {
    throw new Error("Published Thriller requires at least two public sources.");
  }
}

if (expected !== undefined) {
  const expectedSlugs = expected
    .split(",")
    .map((slug) => slug.trim())
    .filter(Boolean)
    .sort();
  const actualSlugs = works.map((work) => work.slug).sort();

  if (JSON.stringify(expectedSlugs) !== JSON.stringify(actualSlugs)) {
    throw new Error(
      `Published slug mismatch. Expected ${JSON.stringify(expectedSlugs)}, received ${JSON.stringify(actualSlugs)}.`,
    );
  }
}

console.log(`Pilot verification passed: ${works.length} published work(s).`);
for (const work of works) {
  console.log(`- ${work.release_year ?? "Year unknown"} — ${work.title} (${work.slug})`);
}
