import fs from "node:fs/promises";
import path from "node:path";

const repo = process.argv[2];
if (!repo) throw new Error("Usage: node build-award-result-fidelity.mjs <repo>");

const evidenceDir = path.join(repo, "docs/research/canon/evidence");
const output = path.join(repo, "supabase/migrations/20260713121000_preserve_exact_award_result_levels.sql");

const workSlugOverrides = new Map([
  ["Michael Jackson\u0000Thriller", "michael-jackson-thriller"],
  ["a-ha\u0000Take On Me", "a-ha-take-on-me"],
  ["Jamiroquai\u0000Virtual Insanity", "jamiroquai-virtual-insanity"],
  ["Daft Punk\u0000Around the World", "daft-punk-around-the-world"],
  ["Fatboy Slim\u0000Weapon of Choice", "fatboy-slim-weapon-of-choice"],
  ["Beyoncé\u0000Single Ladies", "beyonce-single-ladies"],
  ["Childish Gambino\u0000This Is America", "childish-gambino-this-is-america"],
  ["米津玄師\u0000Lemon", "kenshi-yonezu-lemon"],
  ["宇多田ヒカル\u0000One Last Kiss", "hikaru-utada-one-last-kiss"],
  ["サカナクション\u0000アルクアラウンド", "sakanaction-aruku-around"],
  ["宇多田ヒカル\u0000Traveling", "hikaru-utada-traveling"],
  ["millennium parade\u0000Fly with me", "millennium-parade-fly-with-me"],
]);

const artistOverrides = new Map([
  ["サカナクション", "sakanaction"], ["宇多田ヒカル", "hikaru-utada"],
  ["米津玄師", "kenshi-yonezu"], ["Beyoncé", "beyonce"],
  ["The Chemical Brothers", "chemical-brothers"], ["Chemical Brothers", "chemical-brothers"],
]);

const awardSlugs = new Map([
  ["D&AD Awards", "d-and-ad-awards"],
  ["Japan Media Arts Festival", "japan-media-arts-festival"],
]);

function slug(value) {
  const result = value.normalize("NFKD").replace(/[\u0300-\u036f]/g, "")
    .replace(/&/g, " and ").replace(/['’]/g, "").toLowerCase()
    .replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
  if (!result) throw new Error(`Cannot slug ${value}`);
  return result;
}

function workSlug(work) {
  return workSlugOverrides.get(`${work.artist}\u0000${work.title}`)
    ?? `${artistOverrides.get(work.artist) ?? slug(work.artist)}-${slug(work.metadata.officialTitle)}`;
}

function sql(value) {
  if (value === null || value === undefined) return "null";
  return `'${String(value).replaceAll("'", "''")}'`;
}

function exactResult(value) {
  if (value.startsWith("Black Pencil")) return "black_pencil";
  if (value.startsWith("Yellow Pencil")) return "yellow_pencil";
  if (value.startsWith("Graphite Pencil")) return "graphite_pencil";
  if (value.startsWith("Wood Pencil")) return "wood_pencil";
  if (value === "Excellence Award") return "excellence_award";
  return null;
}

function coreReady(work) {
  return !work.requiresIdentityResolution && work.metadata?.officialTitle && work.metadata?.releaseYear
    && work.metadata?.countryCode && work.metadata?.directors?.length
    && work.sources?.some((source) => source.type === "official_video")
    && work.metadata?.youtubeId && work.metadata?.youtubeUrl
    && ["ja", "en"].every((locale) => ["shortSummary", "whyItMatters", "historicalContext", "keyInnovation"].every((field) => work.editorial?.[locale]?.[field]))
    && work.awardAudit?.status === "complete" && work.sources?.length;
}

const exact = [];
for (const file of (await fs.readdir(evidenceDir)).filter((name) => name.endsWith(".json"))) {
  const record = JSON.parse(await fs.readFile(path.join(evidenceDir, file), "utf8"));
  for (const work of record.works ?? []) {
    if (!coreReady(work)) continue;
    for (const result of work.awardAudit?.verifiedResults ?? []) {
      const code = exactResult(result.result);
      if (code) exact.push({ work, result, code });
    }
  }
}

const lines = [
  "-- Preserve official D&AD pencil levels and Japan Media Arts Festival Excellence.",
  "-- The prior normalized 'other' rows are removed only for these exact official labels.",
  "", "begin;", "",
  "alter table public.work_award_results drop constraint if exists work_award_results_result_check;",
  "alter table public.work_award_results add constraint work_award_results_result_check check (result in (",
  "  'winner','nominee','finalist','shortlist','grand_prix','gold','silver','bronze',",
  "  'special_jury','jury_selection','honorable_mention','official_selection',",
  "  'peoples_voice_winner','black_pencil','yellow_pencil','graphite_pencil',",
  "  'wood_pencil','excellence_award','other'",
  "));", "",
  "delete from public.work_award_results",
  "where result='other' and (",
  "  verification_notes like 'Official result label: Black Pencil%' or",
  "  verification_notes like 'Official result label: Yellow Pencil%' or",
  "  verification_notes like 'Official result label: Graphite Pencil%' or",
  "  verification_notes like 'Official result label: Wood Pencil%' or",
  "  verification_notes like 'Official result label: Excellence Award%'",
  ");", "",
];

for (const { work, result, code } of exact) {
  const awardSlug = awardSlugs.get(result.program);
  if (!awardSlug) throw new Error(`No award mapping for ${result.program}`);
  lines.push(`insert into public.work_award_results (work_id,award_id,award_category_id,award_year,result,credited_name_text,source_id,verification_status,verification_notes) select w.id,a.id,ac.id,${result.year},${sql(code)},${sql((result.creditedNames ?? []).join(" / ") || null)},s.id,'verified',${sql(`Official result label: ${result.result}${result.notes ? `; ${result.notes}` : ""}`)} from public.works w join public.awards a on a.slug=${sql(awardSlug)} join public.award_categories ac on ac.award_id=a.id and ac.slug=${sql(slug(result.category))} join public.sources s on s.url=${sql(result.source)} where w.slug=${sql(workSlug(work))} on conflict (work_id,award_category_id,award_year,result) do update set credited_name_text=excluded.credited_name_text,source_id=excluded.source_id,verification_status='verified',verification_notes=excluded.verification_notes;`);
}

lines.push("", `do $$ begin if (select count(*) from public.work_award_results where result in ('black_pencil','yellow_pencil','graphite_pencil','wood_pencil','excellence_award')) < ${exact.length} then raise exception 'Exact award result levels were not fully inserted'; end if; end $$;`, "", "commit;", "");
await fs.writeFile(output, lines.join("\n"));
console.log(JSON.stringify({ exactResults: exact.length, output }, null, 2));
