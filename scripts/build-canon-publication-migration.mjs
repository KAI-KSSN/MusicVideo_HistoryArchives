import fs from "node:fs/promises";
import path from "node:path";

const repo = process.argv[2];
if (!repo) throw new Error("Usage: node build-canon-publication-migration.mjs <repo>");

const evidenceDir = path.join(repo, "docs/research/canon/evidence");
const manifestPath = path.join(repo, "docs/research/canon/canon-5star-manifest.json");
const migrationPath = path.join(repo, "supabase/migrations/20260713120000_publish_verified_canon_works.sql");
const reportPath = path.join(repo, "docs/research/canon/canon-publication-report.md");

const manifest = JSON.parse(await fs.readFile(manifestPath, "utf8"));
const manifestByIdentity = new Map(
  manifest.works.map((work) => [identity(work.artist, work.title), work]),
);

const evidence = [];
for (const file of (await fs.readdir(evidenceDir)).filter((name) => name.endsWith(".json")).sort()) {
  const record = JSON.parse(await fs.readFile(path.join(evidenceDir, file), "utf8"));
  for (const work of record.works ?? []) evidence.push({ ...work, evidenceFile: file });
}

const existingSlugOverrides = new Map([
  [identity("Michael Jackson", "Thriller"), "michael-jackson-thriller"],
  [identity("a-ha", "Take On Me"), "a-ha-take-on-me"],
  [identity("Jamiroquai", "Virtual Insanity"), "jamiroquai-virtual-insanity"],
  [identity("Daft Punk", "Around the World"), "daft-punk-around-the-world"],
  [identity("Fatboy Slim", "Weapon of Choice"), "fatboy-slim-weapon-of-choice"],
  [identity("Beyoncé", "Single Ladies"), "beyonce-single-ladies"],
  [identity("Childish Gambino", "This Is America"), "childish-gambino-this-is-america"],
  [identity("米津玄師", "Lemon"), "kenshi-yonezu-lemon"],
  [identity("宇多田ヒカル", "One Last Kiss"), "hikaru-utada-one-last-kiss"],
  [identity("サカナクション", "アルクアラウンド"), "sakanaction-aruku-around"],
  [identity("宇多田ヒカル", "Traveling"), "hikaru-utada-traveling"],
  [identity("millennium parade", "Fly with me"), "millennium-parade-fly-with-me"],
]);

const artistSlugOverrides = new Map([
  ["サカナクション", "sakanaction"],
  ["宇多田ヒカル", "hikaru-utada"],
  ["米津玄師", "kenshi-yonezu"],
  ["Beyoncé", "beyonce"],
  ["The Chemical Brothers", "chemical-brothers"],
  ["Chemical Brothers", "chemical-brothers"],
]);

const entitySlugOverrides = new Map([
  ["紀里谷和明", "kazuaki-kiriya"],
  ["関和亮", "kazuaki-seki"],
  ["田向潤", "jun-tamukai"],
  ["山田健人", "kento-yamada"],
  ["山田智和", "tomokazu-yamada"],
  ["庵野秀明", "hideaki-anno"],
  ["鎌谷聡次郎", "sojiro-kamatani"],
]);

const awardPrograms = new Map([
  ["Grammy Awards", ["grammy-awards", "GRAMMY Awards", "US", "Recording Academy", "https://www.grammy.com/awards", "general_music"]],
  ["GRAMMY Awards", ["grammy-awards", "GRAMMY Awards", "US", "Recording Academy", "https://www.grammy.com/awards", "general_music"]],
  ["MTV Video Music Awards", ["mtv-video-music-awards", "MTV Video Music Awards", "US", "MTV", "https://www.mtv.com/vma", "dedicated_music_video"]],
  ["UK Music Video Awards", ["uk-music-video-awards", "UK Music Video Awards", "GB", "UK Music Video Awards", "https://www.ukmva.com/", "dedicated_music_video"]],
  ["D&AD Awards", ["d-and-ad-awards", "D&AD Awards", "GB", "D&AD", "https://www.dandad.org/awards/professional/", "advertising_creative"]],
  ["CICLOPE Awards", ["ciclope-awards", "CICLOPE Awards", "DE", "CICLOPE", "https://www.ciclopefestival.com/", "film_craft"]],
  ["CICLOPE Festival", ["ciclope-awards", "CICLOPE Awards", "DE", "CICLOPE", "https://www.ciclopefestival.com/", "film_craft"]],
  ["Clio Awards", ["clio-awards", "Clio Awards", "US", "Clio Awards", "https://clios.com/", "advertising_creative"]],
  ["Clio Music", ["clio-music", "Clio Music", "US", "Clio Awards", "https://clios.com/music/", "general_music"]],
  ["Clio Music Awards", ["clio-music", "Clio Music", "US", "Clio Awards", "https://clios.com/music/", "general_music"]],
  ["EnergaCAMERIMAGE", ["energacamerimage", "EnergaCAMERIMAGE", "PL", "Tumult Foundation", "https://camerimage.pl/en/", "film_craft"]],
  ["The One Show", ["the-one-show", "The One Show", "US", "The One Club for Creativity", "https://oneshow.org/", "advertising_creative"]],
  ["The Webby Awards", ["webby-awards", "The Webby Awards", "US", "IADAS", "https://www.webbyawards.com/", "platform_editorial"]],
  ["MTV VMAJ", ["mtv-video-music-awards-japan", "MTV Video Music Awards Japan", "JP", "MTV Japan", "https://www.vmaj.jp/", "dedicated_music_video"]],
  ["MUSIC AWARDS JAPAN", ["music-awards-japan", "MUSIC AWARDS JAPAN", "JP", "CEIPA", "https://www.musicawardsjapan.com/", "general_music"]],
  ["SPACE SHOWER MUSIC AWARDS", ["space-shower-music-awards", "SPACE SHOWER MUSIC AWARDS", "JP", "SPACE SHOWER NETWORKS", "https://awards.spaceshower.jp/", "dedicated_music_video"]],
  ["Japan Media Arts Festival", ["japan-media-arts-festival", "Japan Media Arts Festival", "JP", "Agency for Cultural Affairs", "https://j-mediaarts.jp/en/", "media_art"]],
  ["SXSW Film & TV Festival", ["sxsw-film-tv-festival", "SXSW Film & TV Festival", "US", "SXSW", "https://www.sxsw.com/festivals/film/", "festival"]],
  ["AICP Show", ["aicp-show", "AICP Show", "US", "AICP", "https://aicpawards.com/", "advertising_creative"]],
  ["Berlin Commercial", ["berlin-commercial", "Berlin Commercial", "DE", "Berlin Commercial", "https://berlincommercial.com/", "film_craft"]],
  ["British Arrows", ["british-arrows", "British Arrows", "GB", "British Arrows", "https://www.britisharrows.com/", "advertising_creative"]],
  ["Japan Gold Disc Award", ["japan-gold-disc-award", "Japan Gold Disc Award", "JP", "Recording Industry Association of Japan", "https://www.golddisc.jp/", "general_music"]],
]);

function identity(artist, title) {
  return `${artist}\u0000${title}`.normalize("NFKC").toLocaleLowerCase("ja");
}

function asciiSlug(value) {
  const slug = value.normalize("NFKD").replace(/[\u0300-\u036f]/g, "")
    .replace(/&/g, " and ").replace(/['’]/g, "").toLowerCase()
    .replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
  if (!slug) throw new Error(`Cannot produce ASCII slug for ${value}`);
  return slug;
}

function workSlug(work) {
  return existingSlugOverrides.get(identity(work.artist, work.title))
    ?? `${artistSlug(work.artist)}-${asciiSlug(work.metadata.officialTitle)}`;
}

function artistSlug(name) {
  return artistSlugOverrides.get(name) ?? asciiSlug(name);
}

function entitySlug(name) {
  return entitySlugOverrides.get(name) ?? asciiSlug(name);
}

function sql(value) {
  if (value === null || value === undefined) return "null";
  return `'${String(value).replaceAll("'", "''")}'`;
}

function sqlArray(values) {
  if (!values?.length) return "array[]::text[]";
  return `array[${values.map(sql).join(",")}]::text[]`;
}

function editorialComplete(work) {
  return ["ja", "en"].every((locale) =>
    ["shortSummary", "whyItMatters", "historicalContext", "keyInnovation"]
      .every((field) => Boolean(work.editorial?.[locale]?.[field])),
  );
}

function hasOfficialVideo(work) {
  return work.sources?.some((source) => source.type === "official_video")
    && Boolean(work.metadata?.youtubeId)
    && Boolean(work.metadata?.youtubeUrl);
}

function publicationDecision(work) {
  const reasons = [];
  if (work.requiresIdentityResolution) reasons.push("work_identity_unresolved");
  if (!work.metadata?.officialTitle) reasons.push("official_title_unverified");
  if (!work.metadata?.releaseYear) reasons.push("release_year_unverified");
  if (!work.metadata?.countryCode) reasons.push("country_unverified");
  if (!work.metadata?.directors?.length) reasons.push("director_unverified");
  if (!hasOfficialVideo(work)) reasons.push("official_video_unresolved");
  if (!editorialComplete(work)) reasons.push("bilingual_editorial_incomplete");
  if (work.awardAudit?.status !== "complete") reasons.push("award_scope_incomplete");
  if (!work.sources?.length) reasons.push("sources_missing");
  return { publish: reasons.length === 0, reasons };
}

function storableAwardResults(work) {
  // The normalized award table requires an award year. A program archive entry
  // without a year is retained in the evidence ledger, not coerced into a
  // fabricated year and not registered as an award result.
  return (work.awardAudit?.verifiedResults ?? []).filter((result) => Number.isInteger(result.year));
}

function sourceType(type) {
  if (type === "official_video" || type === "artist_official" || type === "director_portfolio" || type === "production_company") return type;
  if (type.includes("award") || type.includes("festival") || type.includes("aicp")) return "award_archive";
  if (type.includes("director") || type.includes("technology")) return "director_portfolio";
  if (type.includes("production") || type.includes("software_platform")) return "production_company";
  if (type.includes("label") || type.includes("music_service") || type.includes("music_platform")) return "label";
  if (type.includes("artist") || type.includes("creator_upload") || type.includes("platform_video")) return "artist_official";
  if (type.includes("archive") || type.includes("museum") || type.includes("library") || type.includes("registry")) return "database";
  return "publication";
}

function publisherForUrl(url) {
  try { return new URL(url).hostname.replace(/^www\./, ""); } catch { return "Official source"; }
}

function resultCode(result) {
  const value = result.toLowerCase();
  if (value.includes("people's voice")) return "peoples_voice_winner";
  if (value === "winner" || value === "webby winner") return "winner";
  if (value === "nominee") return "nominee";
  if (value.includes("shortlist")) return "shortlist";
  if (value === "finalist") return "finalist";
  if (value === "grand prix" || value === "grand") return "grand_prix";
  if (value === "gold" || value === "gold award") return "gold";
  if (value === "silver") return "silver";
  if (value === "bronze" || value === "bronze pencil") return "bronze";
  if (value === "honoree") return "honorable_mention";
  if (value.includes("selection")) return "official_selection";
  return "other";
}

function categoryType(category) {
  const value = category.toLowerCase();
  if (value.includes("cinemat")) return "cinematography";
  if (value.includes("direction")) return "direction";
  if (value.includes("edit")) return "editing";
  if (value.includes("visual effect") || value.includes("vfx")) return "visual_effects";
  if (value.includes("animation")) return "animation";
  if (value.includes("production design") || value.includes("art direction")) return "production_design";
  if (value.includes("choreograph")) return "choreography";
  if (value.includes("color") || value.includes("colour")) return "color_grading";
  if (value.includes("video of the year") || value === "music video" || value.includes("best music video")) return "overall_video";
  return "other";
}

const decisions = evidence.map((work) => ({ work, ...publicationDecision(work) }));
const publishable = decisions.filter((item) => item.publish).map((item) => item.work)
  .sort((a, b) => a.metadata.releaseYear - b.metadata.releaseYear || a.artist.localeCompare(b.artist, "ja"));
const held = decisions.filter((item) => !item.publish);

if (evidence.length !== 98) throw new Error(`Expected 98 evidence works; found ${evidence.length}`);
if (publishable.length !== 68) throw new Error(`Expected reviewed publication set of 68; found ${publishable.length}`);

const sources = new Map();
for (const work of publishable) {
  for (const source of work.sources ?? []) sources.set(source.url, source);
  for (const result of storableAwardResults(work)) {
    if (!sources.has(result.source)) sources.set(result.source, { type: "award_archive_official", url: result.source, supports: ["awardOutcome"] });
  }
}

const lines = [
  "-- Generated from the committed ★★★★★ evidence ledger.",
  "-- Unknown optional production, VFX, label and runtime values remain NULL.",
  "-- Publication requires exact identity, official video, release year, country, director,",
  "-- complete JA/EN editorial, completed full award audit and attached sources.",
  "", "begin;", "",
  "insert into public.taxonomy_categories (code,name,description,allows_multiple) values",
  "  ('region','Region','Editorial browsing region.',false),",
  "  ('era','Era','Release decade.',false),",
  "  ('movement','Movement','Editorial movement from the approved Canon sheet.',true)",
  "on conflict (code) do update set name=excluded.name,description=excluded.description,allows_multiple=excluded.allows_multiple;", "",
];

for (const [url, source] of sources) {
  lines.push(
    `insert into public.sources (source_type,title,publisher,url,accessed_at,notes) values (${sql(sourceType(source.type))},${sql(publisherForUrl(url))},${sql(publisherForUrl(url))},${sql(url)},current_date,${sql("Verified Canon research source.")}) on conflict (url) do update set source_type=excluded.source_type,accessed_at=excluded.accessed_at;`,
  );
}
lines.push("");

for (const [, data] of new Map(publishable.flatMap((work) => storableAwardResults(work).map((result) => {
  const mapped = awardPrograms.get(result.program);
  if (!mapped) throw new Error(`No award program mapping for ${result.program}`);
  return [result.program, mapped];
})))) {
  const [slug, officialName, country, organizer, url, scope] = data;
  lines.push(`insert into public.awards (slug,name,official_name,country_code,region,organizer,website_url,official_url,scope,status) values (${sql(slug)},${sql(officialName)},${sql(officialName)},${sql(country)},${sql(country === "JP" ? "Japan" : "International")},${sql(organizer)},${sql(url)},${sql(url)},${sql(scope)},'active') on conflict (slug) do update set name=excluded.name,official_name=excluded.official_name,organizer=excluded.organizer,website_url=excluded.website_url,official_url=excluded.official_url,scope=excluded.scope;`);
}
lines.push("");

for (const work of publishable) {
  const slug = workSlug(work);
  const manifestWork = manifestByIdentity.get(identity(work.artist, work.title));
  if (!manifestWork) throw new Error(`Missing manifest row for ${work.artist} — ${work.title}`);
  const artistEntitySlug = artistSlug(work.artist);
  const originalTitle = /[^\x00-\x7F]/.test(work.metadata.officialTitle) ? work.metadata.officialTitle : null;

  lines.push(`-- ${work.artist} — ${work.metadata.officialTitle}`);
  lines.push(`insert into public.entities (slug,display_name,entity_type,country_code) values (${sql(artistEntitySlug)},${sql(work.artist)},'other',${sql(work.metadata.countryCode)}) on conflict (slug) do update set display_name=excluded.display_name;`);
  for (const director of work.metadata.directors) {
    lines.push(`insert into public.entities (slug,display_name,entity_type) values (${sql(entitySlug(director))},${sql(director)},'person') on conflict (slug) do update set display_name=excluded.display_name;`);
  }
  for (const [name] of [[work.metadata.productionCompany, "production_company"], [work.metadata.vfxProduction, "vfx_production"]]) {
    if (name) lines.push(`insert into public.entities (slug,display_name,entity_type) values (${sql(entitySlug(name))},${sql(name)},'company') on conflict (slug) do update set display_name=excluded.display_name;`);
  }
  lines.push(`insert into public.works (work_type_id,slug,title,original_title,release_year,country_code,status,is_canonical,verified_at,verification_notes) select id,${sql(slug)},${sql(work.metadata.officialTitle)},${sql(originalTitle)},${work.metadata.releaseYear},${sql(work.metadata.countryCode)},'verified',true,now(),${sql(`Canon ★★★★★; evidence ${work.evidenceFile}; optional unknowns retained as NULL after review.`)} from public.work_types where code='music_video' on conflict (slug) do update set title=excluded.title,original_title=excluded.original_title,release_year=excluded.release_year,country_code=excluded.country_code,is_canonical=true,verified_at=coalesce(public.works.verified_at,excluded.verified_at),verification_notes=excluded.verification_notes,status=case when public.works.status='published' then 'published' else 'verified' end;`);
  lines.push(`insert into public.music_video_details (work_id,label,runtime_seconds,official_release_url) select id,${sql(work.metadata.label)},${work.metadata.runtimeSeconds ?? "null"},${sql(work.metadata.youtubeUrl)} from public.works where slug=${sql(slug)} on conflict (work_id) do update set label=excluded.label,runtime_seconds=excluded.runtime_seconds,official_release_url=excluded.official_release_url;`);

  const credits = [[artistEntitySlug, "artist"], ...work.metadata.directors.map((name) => [entitySlug(name), "director"]), ...(work.metadata.productionCompany ? [[entitySlug(work.metadata.productionCompany), "production_company"]] : []), ...(work.metadata.vfxProduction ? [[entitySlug(work.metadata.vfxProduction), "vfx_production"]] : [])];
  for (const [entitySlug, role] of credits) lines.push(`insert into public.work_credits (work_id,entity_id,role_id,verification_status) select w.id,e.id,r.id,'verified' from public.works w join public.entities e on e.slug=${sql(entitySlug)} join public.credit_roles r on r.code=${sql(role)} where w.slug=${sql(slug)} on conflict (work_id,entity_id,role_id) do update set verification_status='verified';`);

  for (const locale of ["ja", "en"]) {
    const e = work.editorial[locale];
    lines.push(`insert into public.work_editorials (work_id,locale,short_summary,why_it_matters,historical_context,key_innovation,editorial_notes,verification_status,reviewed_at) select id,${sql(locale)},${sql(e.shortSummary)},${sql(e.whyItMatters)},${sql(e.historicalContext)},${sql(e.keyInnovation)},${sql(`Acquisition reason: ${manifestWork.acquisitionReason ?? "Not supplied"}`)},'verified',now() from public.works where slug=${sql(slug)} on conflict (work_id,locale) do update set short_summary=excluded.short_summary,why_it_matters=excluded.why_it_matters,historical_context=excluded.historical_context,key_innovation=excluded.key_innovation,editorial_notes=excluded.editorial_notes,verification_status='verified',reviewed_at=excluded.reviewed_at;`);
  }

  lines.push(`insert into public.media_assets (work_id,platform,asset_type,external_id,url,is_official,availability_status,last_checked_at) select id,'youtube','full_video',${sql(work.metadata.youtubeId)},${sql(work.metadata.youtubeUrl)},true,'available',now() from public.works where slug=${sql(slug)} on conflict (work_id,url) do update set external_id=excluded.external_id,is_official=true,availability_status='available',last_checked_at=excluded.last_checked_at;`);
  lines.push(`insert into public.media_assets (work_id,platform,asset_type,url,is_official,availability_status,last_checked_at) select id,'youtube','thumbnail',${sql(work.metadata.thumbnailUrl)},true,'available',now() from public.works where slug=${sql(slug)} on conflict (work_id,url) do update set is_official=true,availability_status='available',last_checked_at=excluded.last_checked_at;`);

  const tags = [["region", work.metadata.countryCode === "JP" ? "Japan" : "International"], ["era", `${Math.floor(work.metadata.releaseYear / 10) * 10}s`], ...(work.metadata.genre ? [["genre", work.metadata.genre]] : []), ...(manifestWork.movement ? [["movement", manifestWork.movement]] : [])];
  for (const [category, name] of tags) {
    const termSlug = asciiSlug(name);
    lines.push(`insert into public.taxonomy_terms (category_id,slug,name) select id,${sql(termSlug)},${sql(name)} from public.taxonomy_categories where code=${sql(category)} on conflict (category_id,slug) do update set name=excluded.name;`);
    lines.push(`insert into public.work_taxonomy_terms (work_id,term_id,assignment_method,notes) select w.id,t.id,'editorial',${sql(category === "movement" ? "From the approved ★★★★★ editorial sheet." : "Verified or derived from verified metadata.")} from public.works w join public.taxonomy_categories c on c.code=${sql(category)} join public.taxonomy_terms t on t.category_id=c.id and t.slug=${sql(termSlug)} where w.slug=${sql(slug)} on conflict (work_id,term_id) do update set notes=excluded.notes;`);
  }

  for (const source of work.sources) {
    lines.push(`insert into public.work_sources (work_id,source_id,supports_fields,is_primary,notes) select w.id,s.id,${sqlArray(source.supports ?? [])},${source.type === "official_video" ? "true" : "false"},${sql(`Evidence ledger: ${work.evidenceFile}`)} from public.works w join public.sources s on s.url=${sql(source.url)} where w.slug=${sql(slug)} on conflict (work_id,source_id) do update set supports_fields=excluded.supports_fields,is_primary=excluded.is_primary,notes=excluded.notes;`);
  }

  for (const result of storableAwardResults(work)) {
    const [awardSlug] = awardPrograms.get(result.program);
    const categorySlug = asciiSlug(result.category);
    const normalizedResult = resultCode(result.result);
    lines.push(`insert into public.award_categories (award_id,slug,name,official_name,normalized_name,category_type,valid_from_year,valid_to_year) select id,${sql(categorySlug)},${sql(result.category)},${sql(result.category)},${sql(result.category)},${sql(categoryType(result.category))},${result.year},${result.year} from public.awards where slug=${sql(awardSlug)} on conflict (award_id,slug) do update set name=excluded.name,official_name=excluded.official_name,normalized_name=excluded.normalized_name,category_type=excluded.category_type;`);
    lines.push(`insert into public.work_award_results (work_id,award_id,award_category_id,award_year,result,credited_name_text,source_id,verification_status,verification_notes) select w.id,a.id,ac.id,${result.year},${sql(normalizedResult)},${sql((result.creditedNames ?? []).join(" / ") || null)},s.id,'verified',${sql(`Official result label: ${result.result}${result.notes ? `; ${result.notes}` : ""}`)} from public.works w join public.awards a on a.slug=${sql(awardSlug)} join public.award_categories ac on ac.award_id=a.id and ac.slug=${sql(categorySlug)} join public.sources s on s.url=${sql(result.source)} where w.slug=${sql(slug)} on conflict (work_id,award_category_id,award_year,result) do update set award_id=excluded.award_id,credited_name_text=excluded.credited_name_text,source_id=excluded.source_id,verification_status='verified',verification_notes=excluded.verification_notes;`);
    lines.push(`insert into public.work_sources (work_id,source_id,supports_fields,is_primary,notes) select w.id,s.id,array['award']::text[],false,'Official result-level source.' from public.works w join public.sources s on s.url=${sql(result.source)} where w.slug=${sql(slug)} on conflict (work_id,source_id) do update set supports_fields=(select array_agg(distinct value) from unnest(public.work_sources.supports_fields || excluded.supports_fields) value);`);
  }
  lines.push("");
}

lines.push("-- Publish only after all dependent rows have been inserted successfully in this transaction.");
lines.push(`update public.works set status='published',published_at=coalesce(published_at,now()),verified_at=coalesce(verified_at,now()) where slug in (${publishable.map((work) => sql(workSlug(work))).join(",")});`);
lines.push("", "commit;", "");

await fs.writeFile(migrationPath, lines.join("\n"));

const totalAwardResults = publishable.reduce((sum, work) => sum + storableAwardResults(work).length, 0);
const report = [
  "# MVHL ★★★★★ Canon publication report",
  "",
  `- Editorial source: \`${manifest.sourceFile}\``,
  `- Source SHA-256: \`${manifest.sourceSha256}\``,
  `- Selected: ${evidence.length}`,
  `- Publication packet: ${publishable.length} (existing 9 + new ${publishable.length - 9})`,
  `- Held for essential evidence: ${held.length}`,
  `- Verified award result rows in publication packet: ${totalAwardResults}`,
  "- Optional unknown Production/VFX/Label/Runtime fields: retained as NULL",
  "- Relationships: left empty unless a direct historical relationship is source-backed",
  "",
  "## Publication packet",
  "",
  "| Work | Year | Awards | Evidence |",
  "|---|---:|---:|---|",
  ...publishable.map((work) => `| ${work.artist} — ${work.metadata.officialTitle} | ${work.metadata.releaseYear} | ${storableAwardResults(work).length} | ${work.evidenceFile} |`),
  "",
  "## Held works",
  "",
  "| Work | Essential blockers |",
  "|---|---|",
  ...held.map(({ work, reasons }) => `| ${work.artist} — ${work.title} | ${reasons.map((reason) => `\`${reason}\``).join("<br>")} |`),
  "",
  "Awards with no verified result remain empty. No negative award finding is stored as a result.",
  "The AICP Show archive entry for Nine Inch Nails — Closer remains evidence-only because the official public record does not expose an award year; no year was invented.",
  "",
];
await fs.writeFile(reportPath, report.join("\n"));

console.log(JSON.stringify({ selected: evidence.length, publishable: publishable.length, held: held.length, totalAwardResults, migrationPath, reportPath }, null, 2));
