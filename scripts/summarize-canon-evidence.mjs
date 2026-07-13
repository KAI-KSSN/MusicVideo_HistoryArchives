import fs from "node:fs/promises";
import path from "node:path";

const evidenceDirectory = "docs/research/canon/evidence";
const outputPath = "docs/research/canon/canon-staging-report.md";
const files = (await fs.readdir(evidenceDirectory))
  .filter((file) => file.endsWith(".json"))
  .sort();
const works = [];

for (const file of files) {
  const record = JSON.parse(await fs.readFile(path.join(evidenceDirectory, file), "utf8"));
  for (const work of record.works ?? []) works.push({ ...work, evidenceFile: file });
}

const editorialComplete = (work) => ["ja", "en"].every((locale) =>
  ["shortSummary", "whyItMatters", "historicalContext", "keyInnovation"].every(
    (field) => Boolean(work.editorial?.[locale]?.[field]),
  ),
);
const ready = (work) =>
  !work.requiresIdentityResolution &&
  editorialComplete(work) &&
  work.awardAudit?.status === "complete" &&
  Array.isArray(work.sources) &&
  work.sources.length > 0 &&
  (work.publicationBlockers?.length ?? 0) === 0;

const sorted = works.sort((a, b) =>
  (a.metadata?.releaseYear ?? 9999) - (b.metadata?.releaseYear ?? 9999) ||
  a.artist.localeCompare(b.artist, "ja") ||
  a.title.localeCompare(b.title, "ja"),
);
const verifiedAwardResults = sorted.reduce(
  (total, work) => total + (work.awardAudit?.verifiedResults?.length ?? 0),
  0,
);
const completedEditorials = sorted.filter(editorialComplete).length;
const completedAwardAudits = sorted.filter((work) => work.awardAudit?.status === "complete").length;
const readyWorks = sorted.filter(ready);
const lines = [
  "# MVHL ★★★★★ Canon staging report",
  "",
  "> Generated from the committed evidence ledger. This is a staging report, not publication authorization.",
  "",
  "## Summary",
  "",
  `- Selected works: ${sorted.length}`,
  `- Works with complete bilingual editorial: ${completedEditorials}`,
  `- Works with complete award-scope audit: ${completedAwardAudits}`,
  `- Verified award result records: ${verifiedAwardResults}`,
  `- Works currently passing every publication gate: ${readyWorks.length}`,
  "",
  "## Work-by-work status",
  "",
  "| Work | Evidence | Missing / blockers | Awards added | Sources | Editorial | Published by this sprint |",
  "|---|---|---|---:|---:|---|---|",
];

for (const work of sorted) {
  const blockers = work.publicationBlockers?.length
    ? work.publicationBlockers.map((item) => `\`${item}\``).join("<br>")
    : "—";
  lines.push(
    `| ${work.artist} — ${work.title} | ${work.evidenceFile} | ${blockers} | ${work.awardAudit?.verifiedResults?.length ?? 0} | ${work.sources?.length ?? 0} | ${editorialComplete(work) ? "Complete" : "Incomplete"} | ${work.existingPublished && ready(work) ? "Yes; reconciled" : ready(work) ? "Eligible; not yet applied" : "No"} |`,
  );
}

lines.push(
  "",
  "## Gate rule",
  "",
  "A work remains unpublished when any blocker is present. An empty award list is valid, but the full award-scope audit must be complete before the award gate passes.",
);

await fs.writeFile(outputPath, `${lines.join("\n").trimEnd()}\n`);
console.log(JSON.stringify({ works: sorted.length, completedEditorials, completedAwardAudits, verifiedAwardResults, ready: readyWorks.length, outputPath }, null, 2));
