import fs from "node:fs/promises";
import path from "node:path";

const directory = "docs/research/canon/evidence";
const files = (await fs.readdir(directory)).filter((file) => file.endsWith(".json")).sort();
let works = 0;

for (const file of files) {
  const record = JSON.parse(await fs.readFile(path.join(directory, file), "utf8"));
  if (record.publicationAllowed !== false) {
    throw new Error(`${file}: evidence staging files must not authorize publication`);
  }

  for (const work of record.works) {
    works += 1;
    if (!work.requiresIdentityResolution) {
      for (const locale of ["ja", "en"]) {
        for (const field of ["shortSummary", "whyItMatters", "historicalContext", "keyInnovation"]) {
          if (!work.editorial?.[locale]?.[field]) {
            throw new Error(`${file}: missing ${locale}.${field} for ${work.artist} — ${work.title}`);
          }
        }
      }
    } else if (!work.publicationBlockers?.includes("work_identity_unresolved")) {
      throw new Error(`${file}: unresolved identity is not represented in publication blockers`);
    }
    const hasOfficialVideoSource = work.sources?.some((source) => source.type === "official_video");
    const officialVideoIsExplicitlyUnresolved =
      work.officialVideoUnresolved === true &&
      work.publicationBlockers?.includes("official_video_unresolved");

    if (!hasOfficialVideoSource && !officialVideoIsExplicitlyUnresolved) {
      throw new Error(
        `${file}: no official video source or explicit unresolved-video blocker for ${work.artist} — ${work.title}`,
      );
    }
    if (work.awardAudit?.status === "complete" && !Array.isArray(work.awardAudit.checkedPrograms)) {
      throw new Error(`${file}: completed award audit lacks checkedPrograms`);
    }
    if (!work.publicationBlockers?.length && work.existingPublished !== true) {
      throw new Error(`${file}: staged evidence unexpectedly has no publication blocker`);
    }
  }
}

console.log(JSON.stringify({ files, works, status: "valid_staging_evidence" }, null, 2));
