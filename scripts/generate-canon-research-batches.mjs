import fs from "node:fs/promises";
import path from "node:path";

const manifestPath = "docs/research/canon/canon-5star-manifest.json";
const outputDirectory = "docs/research/canon/batches";

const awardPrograms = [
  ["mtv-vma", "MTV Video Music Awards", "international"],
  ["ukmva", "UK Music Video Awards", "international"],
  ["grammy", "Grammy Awards", "international"],
  ["berlin-mva", "Berlin Music Video Awards", "international"],
  ["camerimage", "Camerimage", "international"],
  ["d-and-ad", "D&AD", "international"],
  ["cannes-lions", "Cannes Lions", "international"],
  ["clio", "Clio", "international"],
  ["adc", "ADC", "international"],
  ["the-one-show", "The One Show", "international"],
  ["ciclope", "CICLOPE", "international"],
  ["aicp", "AICP", "international"],
  ["webby", "Webby Awards", "international"],
  ["sxsw", "SXSW", "international"],
  ["mtv-vmaj", "MTV VMAJ", "japan"],
  ["space-shower-mva", "SPACE SHOWER MUSIC VIDEO AWARDS", "japan"],
  ["music-awards-japan", "MUSIC AWARDS JAPAN", "japan"],
  ["acc", "ACC", "japan"],
  ["media-arts-festival", "Japan Media Arts Festival", "japan"],
  ["jaa", "JAA", "japan"],
  ["short-shorts", "Short Shorts Film Festival & Asia", "japan"],
  ["image-forum", "Image Forum Festival", "japan"],
  ["tokyo-filmex", "TOKYO FILMeX", "japan"],
];

const awardCraftScopes = [
  "director",
  "editing",
  "cinematography",
  "production_design",
  "animation",
  "colour_grading",
  "vfx",
];

const manifest = JSON.parse(await fs.readFile(manifestPath, "utf8"));
if (manifest.count !== 98 || manifest.works.length !== 98) {
  throw new Error("The canonical manifest must contain exactly 98 works.");
}

await fs.mkdir(outputDirectory, { recursive: true });

for (const era of [...new Set(manifest.works.map((work) => work.era))]) {
  const outputPath = path.join(outputDirectory, `${era}.json`);
  const works = manifest.works
    .filter((work) => work.era === era)
    .map((work) => ({
      sourceRow: work.sourceRow,
      priority: work.priority,
      artist: work.artist,
      title: work.title,
      editorialMovement: work.movement || null,
      acquisitionReason: work.acquisitionReason || null,
      researchStatus: "pending",
      publicationStatus: "not_evaluated",
      metadata: {
        officialTitle: null,
        localTitle: null,
        englishTitle: null,
        releaseYear: null,
        countryCode: null,
        director: null,
        productionCompany: null,
        vfxProduction: null,
        label: null,
        youtubeUrl: null,
        youtubeId: null,
        thumbnailUrl: null,
        runtimeSeconds: null,
        genre: null,
      },
      editorial: {
        ja: { shortSummary: null, whyItMatters: null, historicalContext: null, keyInnovation: null },
        en: { shortSummary: null, whyItMatters: null, historicalContext: null, keyInnovation: null },
      },
      awardsAudit: awardPrograms.map(([code, name, region]) => ({
        code,
        name,
        region,
        status: "not_checked",
        officialArchiveUrl: null,
        checkedAt: null,
        verifiedResults: [],
        notes: null,
      })),
      awardCraftScopes,
      sources: [],
      tags: [],
      movements: work.movement ? [work.movement] : [],
      relationships: [],
      missingRequiredFields: [],
      publicationGate: {
        metadataVerified: false,
        awardScopeCompleted: false,
        editorialCompleted: false,
        sourcesAttached: false,
        ready: false,
      },
    }));

  const batch = {
    sourceFile: manifest.sourceFile,
    sourceSha256: manifest.sourceSha256,
    era,
    count: works.length,
    generatedAt: new Date().toISOString(),
    rules: {
      unknownValuesRemainNull: true,
      awardsRequireOfficialSource: true,
      noResultIsValidOnlyAfterProgramWasChecked: true,
      publishOnlyWhenGateIsReady: true,
    },
    works,
  };

  await fs.writeFile(outputPath, `${JSON.stringify(batch, null, 2)}\n`);
  console.log(`${era}: ${works.length} works -> ${outputPath}`);
}
