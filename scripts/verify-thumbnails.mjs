const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error(
    "Supabase environment variables are required.",
  );
}

const archiveResponse = await fetch(
  `${supabaseUrl}/rest/v1/archive_works?select=slug,title,thumbnail_url&order=slug`,
  {
    headers: {
      apikey: supabaseKey,
      Authorization: `Bearer ${supabaseKey}`,
    },
    cache: "no-store",
  },
);

if (!archiveResponse.ok) {
  throw new Error(
    `Public archive request failed (${archiveResponse.status}): ${await archiveResponse.text()}`,
  );
}

const data = await archiveResponse.json();

const failures = [];

for (const work of data ?? []) {
  if (!work.thumbnail_url) {
    failures.push({ ...work, reason: "missing URL" });
    continue;
  }

  const response = await fetch(work.thumbnail_url, {
    method: "HEAD",
    redirect: "follow",
  });

  if (!response.ok) {
    failures.push({ ...work, reason: `HTTP ${response.status}` });
  }
}

if (failures.length > 0) {
  console.error("Thumbnail verification failed:");
  console.table(failures);
  process.exit(1);
}

console.log(`Verified ${(data ?? []).length} published thumbnails.`);
