import fs from "node:fs/promises";
import path from "node:path";

const directory = "docs/research/canon/batches";
const files = (await fs.readdir(directory)).filter((file) => file.endsWith(".json")).sort();
const identities = new Set();
let total = 0;

for (const file of files) {
  const batch = JSON.parse(await fs.readFile(path.join(directory, file), "utf8"));
  if (batch.count !== batch.works.length) throw new Error(`${file}: count mismatch`);

  for (const work of batch.works) {
    total += 1;
    if (work.priority !== "★★★★★") throw new Error(`${file}: non-five-star work`);
    const identity = `${work.artist}\u0000${work.title}`.normalize("NFKC").toLocaleLowerCase("ja");
    if (identities.has(identity)) throw new Error(`${file}: duplicate ${work.artist} — ${work.title}`);
    identities.add(identity);

    if (work.awardsAudit.length !== 23) {
      throw new Error(`${file}: ${work.artist} — ${work.title} has incomplete award scope`);
    }

    const completedAwardScope = work.awardsAudit.every((program) =>
      ["verified_results", "checked_no_result", "not_applicable"].includes(program.status),
    );
    if (work.publicationGate.awardScopeCompleted !== completedAwardScope) {
      throw new Error(`${file}: award gate disagrees with audit for ${work.artist} — ${work.title}`);
    }

    const calculatedReady =
      work.publicationGate.metadataVerified &&
      work.publicationGate.awardScopeCompleted &&
      work.publicationGate.editorialCompleted &&
      work.publicationGate.sourcesAttached;
    if (work.publicationGate.ready !== calculatedReady) {
      throw new Error(`${file}: publication gate is inconsistent for ${work.artist} — ${work.title}`);
    }
    if (work.publicationStatus === "published" && !calculatedReady) {
      throw new Error(`${file}: unsafe publication for ${work.artist} — ${work.title}`);
    }
  }
}

if (total !== 98) throw new Error(`Expected 98 works; found ${total}.`);
console.log(JSON.stringify({ files, total, uniqueWorks: identities.size, status: "valid" }, null, 2));
