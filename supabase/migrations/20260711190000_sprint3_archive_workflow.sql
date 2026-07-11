-- MVHL Sprint 3: establish the editorial publishing workflow.

begin;

-- MVHL is a reference archive, not a curriculum product.
drop table if exists public.curriculum_items cascade;
drop table if exists public.curricula cascade;

delete from public.work_taxonomy_terms
where term_id in (
  select t.id
  from public.taxonomy_terms t
  join public.taxonomy_categories c on c.id = t.category_id
  where c.code = 'curriculum_topic'
);

delete from public.taxonomy_terms
where category_id in (
  select id from public.taxonomy_categories where code = 'curriculum_topic'
);

delete from public.taxonomy_categories where code = 'curriculum_topic';

alter table public.works
  add column if not exists verified_at timestamptz,
  add column if not exists verification_notes text;

alter table public.works
  drop constraint if exists works_publication_state_check;

alter table public.works
  add constraint works_publication_state_check check (
    (status not in ('verified', 'published') or verified_at is not null)
    and (status <> 'published' or published_at is not null)
  );

-- Objective metadata remains on works/details/credits. Curated interpretation
-- lives here and is versioned by locale.
create table if not exists public.work_editorials (
  id uuid primary key default gen_random_uuid(),
  work_id uuid not null references public.works(id) on delete cascade,
  locale text not null check (locale in ('ja', 'en')),
  short_summary text,
  why_it_matters text,
  historical_context text,
  key_innovation text,
  editorial_notes text,
  verification_status text not null default 'draft'
    check (verification_status in ('draft', 'reviewed', 'verified')),
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (work_id, locale)
);

drop trigger if exists work_editorials_set_updated_at on public.work_editorials;
create trigger work_editorials_set_updated_at
before update on public.work_editorials
for each row execute function public.set_updated_at();

alter table public.work_editorials enable row level security;

drop policy if exists "Public can read published work editorials"
  on public.work_editorials;
create policy "Public can read published work editorials"
on public.work_editorials for select to anon, authenticated
using (
  exists (
    select 1 from public.works w
    where w.id = work_editorials.work_id and w.status = 'published'
  )
);

-- Sources were protected by RLS but had no public read policy in v1.
drop policy if exists "Public can read published work sources"
  on public.work_sources;
create policy "Public can read published work sources"
on public.work_sources for select to anon, authenticated
using (
  exists (
    select 1 from public.works w
    where w.id = work_sources.work_id and w.status = 'published'
  )
);

drop policy if exists "Public can read sources for published works"
  on public.sources;
create policy "Public can read sources for published works"
on public.sources for select to anon, authenticated
using (
  exists (
    select 1
    from public.work_sources ws
    join public.works w on w.id = ws.work_id
    where ws.source_id = sources.id and w.status = 'published'
  )
);

-- Stable read model for the public archive. The view is deliberately generic:
-- work-type-specific metadata stays in its own detail table while the public UI
-- receives a consistent work record.
create or replace view public.archive_works
with (security_invoker = true)
as
select
  w.id,
  wt.code as work_type,
  w.slug,
  w.title,
  w.original_title,
  w.release_year,
  w.country_code,
  w.language_code,
  w.status,
  w.is_canonical,
  mvd.official_release_url,
  (
    select string_agg(e.display_name, ' / ' order by wc.credit_order, e.display_name)
    from public.work_credits wc
    join public.credit_roles cr on cr.id = wc.role_id
    join public.entities e on e.id = wc.entity_id
    where wc.work_id = w.id and cr.code in ('artist', 'featured_artist')
  ) as artist,
  (
    select string_agg(e.display_name, ' / ' order by wc.credit_order, e.display_name)
    from public.work_credits wc
    join public.credit_roles cr on cr.id = wc.role_id
    join public.entities e on e.id = wc.entity_id
    where wc.work_id = w.id and cr.code in ('director', 'co_director')
  ) as director,
  (
    select string_agg(e.display_name, ' / ' order by wc.credit_order, e.display_name)
    from public.work_credits wc
    join public.credit_roles cr on cr.id = wc.role_id
    join public.entities e on e.id = wc.entity_id
    where wc.work_id = w.id and cr.code = 'production_company'
  ) as production_company,
  (
    select string_agg(e.display_name, ' / ' order by wc.credit_order, e.display_name)
    from public.work_credits wc
    join public.credit_roles cr on cr.id = wc.role_id
    join public.entities e on e.id = wc.entity_id
    where wc.work_id = w.id and cr.code = 'vfx_production'
  ) as vfx_production,
  (
    select ma.external_id
    from public.media_assets ma
    where ma.work_id = w.id
      and ma.platform = 'youtube'
      and ma.asset_type = 'full_video'
      and ma.availability_status = 'available'
    order by ma.is_official desc, ma.created_at
    limit 1
  ) as youtube_id,
  (
    select ma.url
    from public.media_assets ma
    where ma.work_id = w.id
      and ma.asset_type = 'thumbnail'
      and ma.availability_status = 'available'
    order by ma.is_official desc, ma.created_at
    limit 1
  ) as thumbnail_url,
  coalesce(
    (
      select jsonb_object_agg(
        we.locale,
        jsonb_build_object(
          'shortSummary', we.short_summary,
          'whyItMatters', we.why_it_matters,
          'historicalContext', we.historical_context,
          'keyInnovation', we.key_innovation
        )
      )
      from public.work_editorials we
      where we.work_id = w.id and we.verification_status = 'verified'
    ),
    '{}'::jsonb
  ) as editorials,
  coalesce(
    (
      select jsonb_agg(
        jsonb_build_object('name', tt.name, 'category', tc.code)
        order by tc.code, tt.name
      )
      from public.work_taxonomy_terms wtt
      join public.taxonomy_terms tt on tt.id = wtt.term_id
      join public.taxonomy_categories tc on tc.id = tt.category_id
      where wtt.work_id = w.id
    ),
    '[]'::jsonb
  ) as tags,
  coalesce(
    (
      select jsonb_agg(
        jsonb_build_object(
          'title', s.title,
          'publisher', s.publisher,
          'url', s.url
        )
        order by ws.is_primary desc, s.publisher, s.title
      )
      from public.work_sources ws
      join public.sources s on s.id = ws.source_id
      where ws.work_id = w.id
    ),
    '[]'::jsonb
  ) as sources
from public.works w
join public.work_types wt on wt.id = w.work_type_id
left join public.music_video_details mvd on mvd.work_id = w.id
where w.status = 'published';

grant select on public.archive_works to anon, authenticated;

commit;
