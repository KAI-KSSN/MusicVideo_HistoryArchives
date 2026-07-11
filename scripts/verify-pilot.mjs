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

async function fetchPublicView(view) {
  const result = await fetch(`${url}/rest/v1/${view}?select=*`, {
    headers: { apikey: key, Authorization: `Bearer ${key}` },
  });
  if (!result.ok) throw new Error(`${view} request failed (${result.status}).`);
  return result.json();
}

const [awardResults, recognitions] = await Promise.all([
  fetchPublicView("archive_award_results"),
  fetchPublicView("archive_recognitions"),
]);

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
  const expectedSummaries = {
    ja: "ドラマチックな物語、振付、特殊メイクを融合した長編形式のミュージックビデオ。",
    en: "A long-form music video combining dramatic narrative, choreography, make-up, and special effects.",
  };
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

    if (editorial.shortSummary !== expectedSummaries[locale]) {
      throw new Error(`Published Thriller has an unexpected ${locale} card summary.`);
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

const requiredAwardResults = [
  ["sakanaction-shin-takarajima", "space-shower-music-awards", "winner"],
  ["kenshi-yonezu-lemon", "mtv-video-music-awards-japan", "winner"],
  ["hikaru-utada-one-last-kiss", "space-shower-music-awards", "winner"],
  ["childish-gambino-this-is-america", "uk-music-video-awards", "winner"],
  ["childish-gambino-this-is-america", "mtv-video-music-awards", "nominee"],
];

for (const [workSlug, awardSlug, outcome] of requiredAwardResults) {
  if (!awardResults.some((item) =>
    item.workSlug === workSlug && item.awardSlug === awardSlug && item.result === outcome
  )) {
    throw new Error(`Missing verified public award result: ${workSlug}/${awardSlug}/${outcome}.`);
  }
}

if (!recognitions.some((item) =>
  item.workSlug === "childish-gambino-this-is-america" &&
  item.recognitionType === "festival_selection" &&
  item.result === "competition_selection"
)) {
  throw new Error("Missing verified SXSW competition selection for This Is America.");
}

if (!recognitions.some((item) =>
  item.workSlug === "childish-gambino-this-is-america" &&
  item.recognitionType === "editorial_selection" &&
  item.result === "staff_pick"
)) {
  throw new Error("Missing verified Vimeo editorial selection for This Is America.");
}

console.log(`Pilot verification passed: ${works.length} published work(s).`);
for (const work of works) {
  console.log(`- ${work.release_year ?? "Year unknown"} — ${work.title} (${work.slug})`);
}
