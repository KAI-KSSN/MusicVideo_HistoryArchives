import fs from "node:fs/promises";
import path from "node:path";

const batchDirectory = "docs/research/canon/batches";
const evidenceDirectory = "docs/research/canon/evidence";

function identityKey(artist, title) {
  return `${artist}\u0000${title}`;
}

async function readWorks(directory) {
  const files = (await fs.readdir(directory))
    .filter((file) => file.endsWith(".json"))
    .sort();
  const works = [];

  for (const file of files) {
    const record = JSON.parse(await fs.readFile(path.join(directory, file), "utf8"));
    for (const work of record.works ?? []) {
      works.push({ artist: work.artist, title: work.title, file });
    }
  }

  return { files, works };
}

function uniqueMap(works, label) {
  const result = new Map();
  for (const work of works) {
    const key = identityKey(work.artist, work.title);
    if (result.has(key)) {
      const previous = result.get(key);
      throw new Error(
        `${label}: duplicate identity ${work.artist} — ${work.title} in ${previous.file} and ${work.file}`,
      );
    }
    result.set(key, work);
  }
  return result;
}

const batches = await readWorks(batchDirectory);
const evidence = await readWorks(evidenceDirectory);
const batchMap = uniqueMap(batches.works, "batches");
const evidenceMap = uniqueMap(evidence.works, "evidence");

const missing = [...batchMap.entries()]
  .filter(([key]) => !evidenceMap.has(key))
  .map(([, work]) => work);
const unexpected = [...evidenceMap.entries()]
  .filter(([key]) => !batchMap.has(key))
  .map(([, work]) => work);

if (missing.length || unexpected.length) {
  throw new Error(
    `Canon coverage mismatch:\n${JSON.stringify({ missing, unexpected }, null, 2)}`,
  );
}

if (batchMap.size !== 98 || evidenceMap.size !== 98) {
  throw new Error(
    `Expected 98 unique Canon works; batches=${batchMap.size}, evidence=${evidenceMap.size}`,
  );
}

console.log(
  JSON.stringify(
    {
      batchFiles: batches.files.length,
      evidenceFiles: evidence.files.length,
      batchWorks: batchMap.size,
      evidenceWorks: evidenceMap.size,
      missing: 0,
      unexpected: 0,
      status: "complete_staging_coverage",
    },
    null,
    2,
  ),
);
