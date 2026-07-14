-- MVHL Knowledge Graph Sprint 1
-- Extend the private v2.0 schema with controlled editorial metadata and safe
-- public read paths. Internal verification notes and source-link notes remain
-- inaccessible to anonymous clients.

begin;

alter table public.technologies
  add column if not exists aliases text[] not null default '{}',
  add column if not exists definition_source_url text,
  add column if not exists is_active boolean not null default true;

alter table public.visual_languages
  add column if not exists aliases text[] not null default '{}',
  add column if not exists definition_source_url text,
  add column if not exists is_active boolean not null default true;

alter table public.technologies
  drop constraint if exists technologies_lifecycle_status_check;
alter table public.technologies
  add constraint technologies_lifecycle_status_check check (
    lifecycle_status in ('draft', 'reviewed', 'verified', 'published', 'deprecated')
  );

alter table public.visual_languages
  drop constraint if exists visual_languages_lifecycle_status_check;
alter table public.visual_languages
  add constraint visual_languages_lifecycle_status_check check (
    lifecycle_status in ('draft', 'reviewed', 'verified', 'published', 'deprecated')
  );

alter table public.work_technologies
  add column if not exists relevance text not null default 'supporting',
  add column if not exists relationship_role text not null default 'standard_use',
  add column if not exists is_primary boolean not null default false,
  add column if not exists note_ja text,
  add column if not exists note_en text,
  add column if not exists display_order integer not null default 100;

alter table public.work_visual_languages
  add column if not exists relevance text not null default 'supporting',
  add column if not exists relationship_role text not null default 'notable_example',
  add column if not exists is_primary boolean not null default false,
  add column if not exists note_ja text,
  add column if not exists note_en text,
  add column if not exists display_order integer not null default 100;

alter table public.work_technologies
  drop constraint if exists work_technologies_verification_status_check,
  drop constraint if exists work_technologies_relevance_check,
  drop constraint if exists work_technologies_relationship_role_check,
  drop constraint if exists work_technologies_display_order_check;

alter table public.work_technologies
  add constraint work_technologies_verification_status_check check (
    verification_status in ('unverified', 'candidate', 'source_found', 'reviewed', 'verified', 'disputed')
  ),
  add constraint work_technologies_relevance_check check (
    relevance in ('primary', 'significant', 'supporting', 'incidental')
  ),
  add constraint work_technologies_relationship_role_check check (
    relationship_role in (
      'earliest_verified_adoption',
      'early_adoption',
      'breakthrough_use',
      'defining_use',
      'modern_evolution',
      'standard_use'
    )
  ),
  add constraint work_technologies_display_order_check check (display_order >= 0);

alter table public.work_visual_languages
  drop constraint if exists work_visual_languages_verification_status_check,
  drop constraint if exists work_visual_languages_relevance_check,
  drop constraint if exists work_visual_languages_relationship_role_check,
  drop constraint if exists work_visual_languages_display_order_check;

alter table public.work_visual_languages
  add constraint work_visual_languages_verification_status_check check (
    verification_status in ('unverified', 'candidate', 'source_found', 'reviewed', 'verified', 'disputed')
  ),
  add constraint work_visual_languages_relevance_check check (
    relevance in ('primary', 'significant', 'supporting', 'incidental')
  ),
  add constraint work_visual_languages_relationship_role_check check (
    relationship_role in ('pioneering_example', 'defining_example', 'notable_example', 'modern_evolution')
  ),
  add constraint work_visual_languages_display_order_check check (display_order >= 0);

create index if not exists technologies_public_idx
on public.technologies(lifecycle_status, is_active, slug);

create index if not exists visual_languages_public_idx
on public.visual_languages(lifecycle_status, is_active, slug);

create index if not exists work_technologies_public_idx
on public.work_technologies(verification_status, work_id, display_order);

create index if not exists work_visual_languages_public_idx
on public.work_visual_languages(verification_status, work_id, display_order);

drop policy if exists technologies_public_read on public.technologies;
create policy technologies_public_read
on public.technologies for select to anon, authenticated
using (lifecycle_status = 'published' and is_active);

drop policy if exists visual_languages_public_read on public.visual_languages;
create policy visual_languages_public_read
on public.visual_languages for select to anon, authenticated
using (lifecycle_status = 'published' and is_active);

drop policy if exists work_technologies_public_read on public.work_technologies;
create policy work_technologies_public_read
on public.work_technologies for select to anon, authenticated
using (
  verification_status = 'verified'
  and exists (
    select 1 from public.works w
    where w.id = work_technologies.work_id and w.status = 'published'
  )
  and exists (
    select 1 from public.technologies t
    where t.id = work_technologies.technology_id
      and t.lifecycle_status = 'published'
      and t.is_active
  )
);

drop policy if exists work_visual_languages_public_read on public.work_visual_languages;
create policy work_visual_languages_public_read
on public.work_visual_languages for select to anon, authenticated
using (
  verification_status = 'verified'
  and exists (
    select 1 from public.works w
    where w.id = work_visual_languages.work_id and w.status = 'published'
  )
  and exists (
    select 1 from public.visual_languages vl
    where vl.id = work_visual_languages.visual_language_id
      and vl.lifecycle_status = 'published'
      and vl.is_active
  )
);

grant select on public.technologies, public.visual_languages to anon, authenticated;

grant select (
  id, work_id, technology_id, usage_role, relevance, relationship_role,
  is_primary, confidence, verification_status, note_ja, note_en,
  display_order, created_at, updated_at
) on public.work_technologies to anon, authenticated;

grant select (
  id, work_id, visual_language_id, prominence, relevance, relationship_role,
  is_primary, confidence, verification_status, note_ja, note_en,
  display_order, created_at, updated_at
) on public.work_visual_languages to anon, authenticated;

create or replace view public.archive_work_technologies
with (security_invoker = true)
as
select
  aw.id as "workId",
  aw.slug as "workSlug",
  aw.title as "workTitle",
  aw.artist,
  aw.release_year as "releaseYear",
  aw.youtube_id as "youtubeId",
  aw.thumbnail_url as "thumbnailUrl",
  t.id as "conceptId",
  t.slug as "conceptSlug",
  t.name as "conceptName",
  t.name_ja as "conceptNameJa",
  t.description as "descriptionEn",
  t.description_ja as "descriptionJa",
  t.technology_type as "conceptFamily",
  wt.relevance,
  wt.relationship_role as "relationshipRole",
  wt.is_primary as "isPrimary",
  wt.note_ja as "noteJa",
  wt.note_en as "noteEn",
  wt.display_order as "displayOrder"
from public.archive_works aw
join public.work_technologies wt on wt.work_id = aw.id
join public.technologies t on t.id = wt.technology_id
where wt.verification_status = 'verified'
  and t.lifecycle_status = 'published'
  and t.is_active;

create or replace view public.archive_work_visual_languages
with (security_invoker = true)
as
select
  aw.id as "workId",
  aw.slug as "workSlug",
  aw.title as "workTitle",
  aw.artist,
  aw.release_year as "releaseYear",
  aw.youtube_id as "youtubeId",
  aw.thumbnail_url as "thumbnailUrl",
  vl.id as "conceptId",
  vl.slug as "conceptSlug",
  vl.name as "conceptName",
  vl.name_ja as "conceptNameJa",
  vl.description as "descriptionEn",
  vl.description_ja as "descriptionJa",
  vl.visual_language_type as "conceptFamily",
  wvl.relevance,
  wvl.relationship_role as "relationshipRole",
  wvl.is_primary as "isPrimary",
  wvl.note_ja as "noteJa",
  wvl.note_en as "noteEn",
  wvl.display_order as "displayOrder"
from public.archive_works aw
join public.work_visual_languages wvl on wvl.work_id = aw.id
join public.visual_languages vl on vl.id = wvl.visual_language_id
where wvl.verification_status = 'verified'
  and vl.lifecycle_status = 'published'
  and vl.is_active;

grant select on public.archive_work_technologies to anon, authenticated;
grant select on public.archive_work_visual_languages to anon, authenticated;

comment on view public.archive_work_technologies is
  'Safe public graph edges: published works to published, verified technologies.';
comment on view public.archive_work_visual_languages is
  'Safe public graph edges: published works to published, verified visual-language concepts.';

commit;
