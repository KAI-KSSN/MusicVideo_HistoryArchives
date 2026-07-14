import fs from "node:fs";
import path from "node:path";
import { reviews, technologySources } from "./data/published-knowledge-graph-sprint-2.mjs";

const scopePath = process.argv[2] ?? "/tmp/mvhl-sprint2-scope.json";
const outputRoot = path.resolve(process.argv[3] ?? ".");
const scope = JSON.parse(fs.readFileSync(scopePath, "utf8"));

const technologySlugs = new Set([
  "rotoscoping", "motion-control", "steadicam", "cgi", "digital-compositing",
  "morphing", "stop-motion-photography", "high-speed-photography",
  "time-lapse-photography", "motion-capture", "performance-capture",
  "3d-camera-tracking", "projection-mapping", "drone-cinematography", "fpv-drone",
  "robotic-camera", "led-volume", "virtual-production", "real-time-rendering",
  "unreal-engine", "volumetric-capture", "volumetric-scan", "point-cloud-capture",
  "lidar", "photogrammetry", "gaussian-splatting", "procedural-animation",
  "particle-simulation", "generative-graphics", "ai-image-generation",
  "ai-video-generation",
]);

const visualSlugs = new Set([
  "one-take", "continuous-shot-illusion", "loop", "infinite-loop", "match-cut",
  "rhythmic-editing", "reverse-narrative", "split-screen", "multi-panel-composition",
  "dance-camera", "spatial-choreography", "minimal-performance", "performance-film",
  "stop-motion", "pixilation", "typography", "kinetic-typography", "mixed-media",
  "collage", "found-footage", "pov", "first-person", "body-transformation",
  "continuous-transformation", "optical-illusion", "forced-perspective", "infinite-zoom",
  "graphic-composition", "data-visualization", "surrealism", "interactive-video",
  "long-form-narrative",
]);

const works = scope.works;
const worksBySlug = new Map(works.map((work) => [work.slug, work]));
const reviewsBySlug = new Map(reviews.map((review) => [review.slug, review]));

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

assert(works.length === scope.totalPublishedWorks, "Scope count does not match work rows.");
assert(reviews.length === works.length, `Expected ${works.length} reviews, found ${reviews.length}.`);
assert(reviewsBySlug.size === reviews.length, "Duplicate review slug detected.");

for (const work of works) assert(reviewsBySlug.has(work.slug), `Missing review: ${work.slug}`);
for (const review of reviews) {
  assert(worksBySlug.has(review.slug), `Review is outside dynamic scope: ${review.slug}`);
  assert(review.noteJa && review.noteEn, `Missing bilingual note: ${review.slug}`);
  for (const relation of review.technology) {
    assert(technologySlugs.has(relation.concept), `Unknown Technology: ${relation.concept}`);
    assert(relation.sources.length > 0, `Technology without source: ${review.slug}/${relation.concept}`);
    for (const key of relation.sources) assert(technologySources[key], `Unknown source key: ${key}`);
  }
  for (const relation of review.visual) {
    assert(visualSlugs.has(relation.concept), `Unknown Visual Language: ${relation.concept}`);
  }
}

const sql = (value) => value == null ? "null" : `'${String(value).replaceAll("'", "''")}'`;
const bool = (value) => value ? "true" : "false";
const array = (values) => `array[${values.map(sql).join(", ")}]::text[]`;
const ensureDir = (dir) => fs.mkdirSync(dir, { recursive: true });
const write = (relative, content) => {
  const filename = path.join(outputRoot, relative);
  ensureDir(path.dirname(filename));
  fs.writeFileSync(filename, `${content.trim()}\n`);
  console.log(filename);
};

const existingTechnologyEdges = works.reduce((count, work) => count + work.technologies.length, 0);
const existingVisualEdges = works.reduce((count, work) => count + work.visualLanguages.length, 0);
const newTechnologyEdges = reviews.reduce((count, review) => count + review.technology.length, 0);
const newVisualEdges = reviews.reduce((count, review) => count + review.visual.length, 0);
const expectedTechnologyEdges = existingTechnologyEdges + newTechnologyEdges;
const expectedVisualEdges = existingVisualEdges + newVisualEdges;

const scopeRows = works.map((work) => {
  const technologies = work.technologies.map((edge) => edge.conceptSlug).join(", ") || "—";
  const visual = work.visualLanguages.map((edge) => edge.conceptSlug).join(", ") || "—";
  return `| ${work.id} | \`${work.slug}\` | ${work.artist} | ${work.title} | ${work.release_year ?? "—"} | ${technologies} | ${visual} |`;
}).join("\n");

write("docs/knowledge-graph/published-work-scope-sprint-2.md", `
# Published Work Scope — Knowledge Graph Sprint 2

Generated from Supabase public read models on 2026-07-14. The unit of review is one published work.

- Published works: **${works.length}**
- Works with an existing Technology relationship: **${works.filter((work) => work.technologies.length).length}**
- Works with an existing Visual Language relationship: **${works.filter((work) => work.visualLanguages.length).length}**
- Existing verified Technology relationships: **${existingTechnologyEdges}**
- Existing verified Visual Language relationships: **${existingVisualEdges}**

| UUID | Slug | Artist | Title | Year | Existing Technology | Existing Visual Language |
|---|---|---|---|---:|---|---|
${scopeRows}
`);

const auditSections = reviews.map((review, index) => {
  const work = worksBySlug.get(review.slug);
  const existingTechnology = work.technologies.map((edge) => `${edge.conceptSlug} (${edge.relevance}; ${edge.relationshipRole})`);
  const existingVisual = work.visualLanguages.map((edge) => `${edge.conceptSlug} (${edge.relevance}; ${edge.relationshipRole})`);
  const proposedTechnology = review.technology.map((edge) => `${edge.concept} (${edge.relevance}; ${edge.role}; sources: ${edge.sources.join(", ")})`);
  const proposedVisual = review.visual.map((edge) => `${edge.concept} (${edge.relevance}; ${edge.role})`);
  const state = review.intentionalEmpty
    ? "No useful classification found"
    : review.preservePilot
      ? "Verified and published — existing pilot preserved"
      : "Verified and published";
  return `
## ${String(index + 1).padStart(2, "0")}. ${work.artist} — ${work.title} (${work.release_year ?? "year unknown"})

- UUID / slug: \`${work.id}\` / \`${work.slug}\`
- Outcome: **${state}**
- Existing Technology: ${existingTechnology.join("; ") || "none"}
- Technology added: ${proposedTechnology.join("; ") || "none"}
- Existing Visual Language: ${existingVisual.join("; ") || "none"}
- Visual Language added: ${proposedVisual.join("; ") || "none"}
- Evidence status: ${review.technology.length ? "Technology source-backed; Visual Language verified by direct formal analysis of the official video." : review.preservePilot ? "Existing verified pilot evidence preserved." : "Visual Language verified by direct formal analysis of the official video; no technical process inferred."}
- Official viewing source: ${work.official_release_url}
- Relationship note (JA): ${review.noteJa}
- Relationship note (EN): ${review.noteEn}
- Deliberately not assigned: ${review.deliberatelyNotAssigned.join(" ")}
- Unresolved questions: ${review.unresolved.join("; ") || "none"}
`;
}).join("\n");

write("docs/knowledge-graph/published-work-classification-audit.md", `
# Published Work Classification Audit — Sprint 2

This is the repository audit trail for the dynamically queried published collection. Coverage is descriptive, not a target. Blank classifications are valid.

## Decision policy

- Technology is published only when a production process is supported by a reliable source.
- Visual Language is based on close formal analysis of the official video and is limited to relationships that improve Work → Concept → Work navigation.
- Existing pilot relationships are preserved.
- No new concepts are approved in this sprint. Candidate concepts were rejected when an existing concept was sufficient or the term described subject matter, mood, period styling, or a one-off aesthetic.
- Lemon and One Last Kiss remain intentionally unlinked because no current relationship met the usefulness threshold.

## Summary

- Published works reviewed: **${works.length} / ${works.length}**
- New Technology relationships proposed for publication: **${newTechnologyEdges}**
- New Visual Language relationships proposed for publication: **${newVisualEdges}**
- Candidate relationships: **0**
- Disputed relationships: **0**
- New concepts proposed: **0**
- New concepts approved: **0**

${auditSections}
`);

write("supabase/migrations/20260714090000_create_knowledge_graph_review_ledger.sql", `
-- Private editorial audit ledger. This records that a published work was
-- individually reviewed even when no public graph relationship was warranted.
begin;

create table if not exists public.knowledge_graph_work_reviews (
  work_id uuid primary key references public.works(id) on delete cascade,
  sprint text not null,
  technology_outcome text not null check (technology_outcome in ('assigned','none','preserved')),
  visual_language_outcome text not null check (visual_language_outcome in ('assigned','none','preserved')),
  review_note_ja text not null,
  review_note_en text not null,
  deliberately_not_assigned text[] not null default '{}',
  unresolved_questions text[] not null default '{}',
  reviewed_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists knowledge_graph_work_reviews_set_updated_at on public.knowledge_graph_work_reviews;
create trigger knowledge_graph_work_reviews_set_updated_at
before update on public.knowledge_graph_work_reviews
for each row execute function public.set_updated_at();

alter table public.knowledge_graph_work_reviews enable row level security;
revoke all on table public.knowledge_graph_work_reviews from anon, authenticated;

comment on table public.knowledge_graph_work_reviews is
  'Private audit trail for individual Technology / Visual Language review, including valid no-classification outcomes.';

commit;
`);

function relationRows(batch, kind) {
  return batch.flatMap((review) => review[kind].map((edge, order) => ({
    review,
    edge,
    order: (order + 1) * 10,
  })));
}

function batchMigration(batch, batchNumber) {
  const techRows = relationRows(batch, "technology");
  const visualRows = relationRows(batch, "visual");
  const sourceKeys = [...new Set(techRows.flatMap(({ edge }) => edge.sources))];
  const reviewValues = batch.map((review) => `(
    ${sql(review.slug)},
    ${sql(review.preservePilot ? "preserved" : review.technology.length ? "assigned" : "none")},
    ${sql(review.preservePilot ? "preserved" : review.visual.length ? "assigned" : "none")},
    ${sql(review.noteJa)}, ${sql(review.noteEn)},
    ${array(review.deliberatelyNotAssigned)}, ${array(review.unresolved)}
  )`).join(",\n");

  const sourceSql = sourceKeys.length ? `
insert into public.sources (source_type, title, publisher, url, accessed_at, notes)
values
${sourceKeys.map((key) => {
  const [sourceType, title, publisher, url, notes] = technologySources[key];
  return `  (${sql(sourceType)}, ${sql(title)}, ${sql(publisher)}, ${sql(url)}, current_date, ${sql(notes)})`;
}).join(",\n")}
on conflict (url) do update set
  source_type = excluded.source_type,
  title = excluded.title,
  publisher = excluded.publisher,
  accessed_at = excluded.accessed_at,
  notes = excluded.notes;
` : "";

  const technologySql = techRows.length ? `
insert into public.work_technologies (
  work_id, technology_id, usage_role, relevance, relationship_role,
  is_primary, confidence, assignment_method, verification_status,
  note_ja, note_en, display_order, reviewed_at
)
select w.id, t.id,
  case when d.is_primary then 'primary' else 'supporting' end,
  d.relevance, d.relationship_role, d.is_primary, 1.000,
  'editorial', 'verified', d.note_ja, d.note_en, d.display_order, now()
from (values
${techRows.map(({ review, edge, order }) => `  (${sql(review.slug)}, ${sql(edge.concept)}, ${sql(edge.relevance)}, ${sql(edge.role)}, ${bool(edge.isPrimary)}, ${sql(review.noteJa)}, ${sql(review.noteEn)}, ${order})`).join(",\n")}
) as d(work_slug, concept_slug, relevance, relationship_role, is_primary, note_ja, note_en, display_order)
join public.works w on w.slug = d.work_slug
join public.technologies t on t.slug = d.concept_slug
on conflict (work_id, technology_id) do update set
  usage_role = excluded.usage_role,
  relevance = excluded.relevance,
  relationship_role = excluded.relationship_role,
  is_primary = excluded.is_primary,
  confidence = excluded.confidence,
  assignment_method = excluded.assignment_method,
  verification_status = excluded.verification_status,
  note_ja = excluded.note_ja,
  note_en = excluded.note_en,
  display_order = excluded.display_order,
  reviewed_at = excluded.reviewed_at;

insert into public.work_technology_sources (
  work_technology_id, source_id, supports_fields, is_primary, notes
)
select wt.id, s.id, array['technology']::text[], d.is_primary, d.notes
from (values
${techRows.flatMap(({ review, edge }) => edge.sources.map((key, index) => {
  const [, , , url, notes] = technologySources[key];
  return `  (${sql(review.slug)}, ${sql(edge.concept)}, ${sql(url)}, ${bool(index === 0)}, ${sql(notes)})`;
})).join(",\n")}
) as d(work_slug, concept_slug, source_url, is_primary, notes)
join public.works w on w.slug = d.work_slug
join public.technologies t on t.slug = d.concept_slug
join public.work_technologies wt on wt.work_id = w.id and wt.technology_id = t.id
join public.sources s on s.url = d.source_url
on conflict (work_technology_id, source_id) do update set
  supports_fields = excluded.supports_fields,
  is_primary = excluded.is_primary,
  notes = excluded.notes;
` : "";

  const visualSql = visualRows.length ? `
insert into public.work_visual_languages (
  work_id, visual_language_id, prominence, relevance, relationship_role,
  is_primary, confidence, assignment_method, editorial_rationale,
  verification_status, note_ja, note_en, display_order, reviewed_at
)
select w.id, vl.id,
  case when d.is_primary then 'primary' else 'secondary' end,
  d.relevance, d.relationship_role, d.is_primary, 1.000,
  'editorial', d.note_en, 'verified', d.note_ja, d.note_en, d.display_order, now()
from (values
${visualRows.map(({ review, edge, order }) => `  (${sql(review.slug)}, ${sql(edge.concept)}, ${sql(edge.relevance)}, ${sql(edge.role)}, ${bool(edge.isPrimary)}, ${sql(review.noteJa)}, ${sql(review.noteEn)}, ${order})`).join(",\n")}
) as d(work_slug, concept_slug, relevance, relationship_role, is_primary, note_ja, note_en, display_order)
join public.works w on w.slug = d.work_slug
join public.visual_languages vl on vl.slug = d.concept_slug
on conflict (work_id, visual_language_id) do update set
  prominence = excluded.prominence,
  relevance = excluded.relevance,
  relationship_role = excluded.relationship_role,
  is_primary = excluded.is_primary,
  confidence = excluded.confidence,
  assignment_method = excluded.assignment_method,
  editorial_rationale = excluded.editorial_rationale,
  verification_status = excluded.verification_status,
  note_ja = excluded.note_ja,
  note_en = excluded.note_en,
  display_order = excluded.display_order,
  reviewed_at = excluded.reviewed_at;

insert into public.work_visual_language_sources (
  work_visual_language_id, source_id, supports_fields, is_primary, notes
)
select wvl.id, s.id, array['visual_language']::text[], true,
  'Official video used for direct formal analysis.'
from public.work_visual_languages wvl
join public.works w on w.id = wvl.work_id
join public.music_video_details mvd on mvd.work_id = w.id
join public.sources s on s.url = mvd.official_release_url
where w.slug in (${batch.filter((review) => review.visual.length).map((review) => sql(review.slug)).join(", ")})
  and wvl.verification_status = 'verified'
on conflict (work_visual_language_id, source_id) do update set
  supports_fields = excluded.supports_fields,
  is_primary = excluded.is_primary,
  notes = excluded.notes;
` : "";

  return `
-- MVHL Knowledge Graph Sprint 2 — published works batch ${String(batchNumber).padStart(2, "0")}
-- Individually reviewed, source-backed, and safely rerunnable.
begin;

${sourceSql}
insert into public.knowledge_graph_work_reviews (
  work_id, sprint, technology_outcome, visual_language_outcome,
  review_note_ja, review_note_en, deliberately_not_assigned,
  unresolved_questions, reviewed_at
)
select w.id, 'knowledge-graph-sprint-2', d.technology_outcome,
  d.visual_outcome, d.note_ja, d.note_en, d.omissions, d.unresolved, now()
from (values
${reviewValues}
) as d(work_slug, technology_outcome, visual_outcome, note_ja, note_en, omissions, unresolved)
join public.works w on w.slug = d.work_slug
on conflict (work_id) do update set
  sprint = excluded.sprint,
  technology_outcome = excluded.technology_outcome,
  visual_language_outcome = excluded.visual_language_outcome,
  review_note_ja = excluded.review_note_ja,
  review_note_en = excluded.review_note_en,
  deliberately_not_assigned = excluded.deliberately_not_assigned,
  unresolved_questions = excluded.unresolved_questions,
  reviewed_at = excluded.reviewed_at;

${technologySql}
${visualSql}
commit;
`;
}

for (let index = 0; index < reviews.length; index += 12) {
  const batchNumber = index / 12 + 1;
  const timestamps = ["20260714091000", "20260714092000", "20260714093000", "20260714094000", "20260714095000", "20260714100000"];
  const filename = `supabase/migrations/${timestamps[batchNumber - 1]}_seed_published_knowledge_graph_batch_${String(batchNumber).padStart(2, "0")}.sql`;
  write(filename, batchMigration(reviews.slice(index, index + 12), batchNumber));
}

write("supabase/migrations/20260714101000_assert_published_knowledge_graph_sprint_2.sql", `
-- Final Sprint 2 integrity assertions. Counts describe the reviewed graph and
-- must not be increased merely to satisfy coverage.
do $$
declare
  published_work_count integer;
  reviewed_work_count integer;
  verified_technology_count integer;
  verified_visual_count integer;
begin
  select count(*) into published_work_count from public.works where status = 'published';
  select count(*) into reviewed_work_count
  from public.knowledge_graph_work_reviews r
  join public.works w on w.id = r.work_id
  where w.status = 'published' and r.sprint = 'knowledge-graph-sprint-2';

  if published_work_count <> ${works.length} then
    raise exception 'Published scope changed during Sprint 2: expected ${works.length}, found %', published_work_count;
  end if;
  if reviewed_work_count <> published_work_count then
    raise exception 'Not every published work was reviewed: % / %', reviewed_work_count, published_work_count;
  end if;

  select count(*) into verified_technology_count from public.work_technologies where verification_status = 'verified';
  select count(*) into verified_visual_count from public.work_visual_languages where verification_status = 'verified';
  if verified_technology_count <> ${expectedTechnologyEdges} then
    raise exception 'Expected ${expectedTechnologyEdges} verified Technology relationships, found %', verified_technology_count;
  end if;
  if verified_visual_count <> ${expectedVisualEdges} then
    raise exception 'Expected ${expectedVisualEdges} verified Visual Language relationships, found %', verified_visual_count;
  end if;

  if exists (
    select 1 from public.work_technologies wt
    where wt.verification_status = 'verified'
      and not exists (select 1 from public.work_technology_sources s where s.work_technology_id = wt.id)
  ) then raise exception 'Verified Technology relationship without source'; end if;

  if exists (
    select 1 from public.work_visual_languages wvl
    where wvl.verification_status = 'verified'
      and not exists (select 1 from public.work_visual_language_sources s where s.work_visual_language_id = wvl.id)
  ) then raise exception 'Verified Visual Language relationship without source'; end if;

  if exists (
    select 1 from public.work_technologies wt join public.technologies t on t.id = wt.technology_id
    where wt.verification_status = 'verified' and (t.lifecycle_status <> 'published' or not t.is_active)
  ) or exists (
    select 1 from public.work_visual_languages wvl join public.visual_languages vl on vl.id = wvl.visual_language_id
    where wvl.verification_status = 'verified' and (vl.lifecycle_status <> 'published' or not vl.is_active)
  ) then raise exception 'Verified relationship points to an unpublished concept'; end if;

  if has_table_privilege('anon', 'public.knowledge_graph_work_reviews', 'select')
     or has_table_privilege('authenticated', 'public.knowledge_graph_work_reviews', 'select')
     or has_table_privilege('anon', 'public.work_technology_sources', 'select')
     or has_table_privilege('anon', 'public.work_visual_language_sources', 'select') then
    raise exception 'Private research data is publicly readable';
  end if;

  if exists (select 1 from public.archive_work_technologies where "relationshipRole" in ('earliest_verified_adoption','early_adoption','breakthrough_use')) then
    raise exception 'Unsupported historical-priority Technology role exposed';
  end if;

  raise notice 'Sprint 2 validation passed: % published works reviewed; % Technology edges; % Visual Language edges', reviewed_work_count, verified_technology_count, verified_visual_count;
end;
$$;
`);

write("docs/knowledge-graph/published-work-classification-summary.md", `
# Knowledge Graph Sprint 2 — Coverage Summary

- Published works reviewed: **${works.length}**
- Works with Technology after application: **${new Set([...works.filter((work) => work.technologies.length).map((work) => work.slug), ...reviews.filter((review) => review.technology.length).map((review) => review.slug)]).size}**
- Works with Visual Language after application: **${new Set([...works.filter((work) => work.visualLanguages.length).map((work) => work.slug), ...reviews.filter((review) => review.visual.length).map((review) => review.slug)]).size}**
- Works intentionally without Technology: **${works.length - new Set([...works.filter((work) => work.technologies.length).map((work) => work.slug), ...reviews.filter((review) => review.technology.length).map((review) => review.slug)]).size}**
- Works intentionally without Visual Language: **${works.length - new Set([...works.filter((work) => work.visualLanguages.length).map((work) => work.slug), ...reviews.filter((review) => review.visual.length).map((review) => review.slug)]).size}**
- Verified Technology relationships: **${expectedTechnologyEdges}**
- Verified Visual Language relationships: **${expectedVisualEdges}**
- Candidate relationships: **0**
- Disputed relationships: **0**
- New concepts proposed / approved: **0 / 0**

Coverage is descriptive. It was not used as a quota.
`);

console.log(JSON.stringify({
  publishedWorks: works.length,
  existingTechnologyEdges,
  existingVisualEdges,
  newTechnologyEdges,
  newVisualEdges,
  expectedTechnologyEdges,
  expectedVisualEdges,
}, null, 2));
