-- Add verified pilot awards and expose them through archive_works.

begin;

insert into public.awards (slug, name, country_code, official_url)
values
  ('grammy-awards', 'GRAMMY Awards', 'US', 'https://www.grammy.com/awards'),
  ('mtv-video-music-awards', 'MTV Video Music Awards', 'US', 'https://www.mtv.com/vma')
on conflict (slug) do update set
  name = excluded.name,
  country_code = excluded.country_code,
  official_url = excluded.official_url;

insert into public.award_categories (award_id, slug, name)
select a.id, d.slug, d.name
from (values
  ('grammy-awards', 'best-music-video', 'Best Music Video'),
  ('mtv-video-music-awards', 'video-of-the-year', 'Video of the Year'),
  ('mtv-video-music-awards', 'best-choreography', 'Best Choreography'),
  ('mtv-video-music-awards', 'best-editing', 'Best Editing')
) as d(award_slug, slug, name)
join public.awards a on a.slug = d.award_slug
on conflict (award_id, slug) do update set name = excluded.name;

insert into public.work_award_results (
  work_id, award_category_id, award_year, result, verification_status
)
select w.id, ac.id, d.award_year, 'winner', 'verified'
from (values
  ('fatboy-slim-weapon-of-choice', 'grammy-awards', 'best-music-video', 2002::smallint),
  ('beyonce-single-ladies', 'mtv-video-music-awards', 'video-of-the-year', 2009::smallint),
  ('beyonce-single-ladies', 'mtv-video-music-awards', 'best-choreography', 2009::smallint),
  ('beyonce-single-ladies', 'mtv-video-music-awards', 'best-editing', 2009::smallint),
  ('childish-gambino-this-is-america', 'grammy-awards', 'best-music-video', 2019::smallint)
) as d(work_slug, award_slug, category_slug, award_year)
join public.works w on w.slug = d.work_slug
join public.awards a on a.slug = d.award_slug
join public.award_categories ac on ac.award_id = a.id and ac.slug = d.category_slug
on conflict (work_id, award_category_id, award_year) do update set
  result = excluded.result,
  verification_status = excluded.verification_status;

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
  (select string_agg(e.display_name, ' / ' order by wc.credit_order, e.display_name)
   from public.work_credits wc join public.credit_roles cr on cr.id=wc.role_id
   join public.entities e on e.id=wc.entity_id
   where wc.work_id=w.id and cr.code in ('artist','featured_artist')) as artist,
  (select string_agg(e.display_name, ' / ' order by wc.credit_order, e.display_name)
   from public.work_credits wc join public.credit_roles cr on cr.id=wc.role_id
   join public.entities e on e.id=wc.entity_id
   where wc.work_id=w.id and cr.code in ('director','co_director')) as director,
  (select string_agg(e.display_name, ' / ' order by wc.credit_order, e.display_name)
   from public.work_credits wc join public.credit_roles cr on cr.id=wc.role_id
   join public.entities e on e.id=wc.entity_id
   where wc.work_id=w.id and cr.code='production_company') as production_company,
  (select string_agg(e.display_name, ' / ' order by wc.credit_order, e.display_name)
   from public.work_credits wc join public.credit_roles cr on cr.id=wc.role_id
   join public.entities e on e.id=wc.entity_id
   where wc.work_id=w.id and cr.code='vfx_production') as vfx_production,
  (select ma.external_id from public.media_assets ma where ma.work_id=w.id
   and ma.platform='youtube' and ma.asset_type='full_video'
   and ma.availability_status='available'
   order by ma.is_official desc, ma.created_at limit 1) as youtube_id,
  (select ma.url from public.media_assets ma where ma.work_id=w.id
   and ma.asset_type='thumbnail' and ma.availability_status='available'
   order by ma.is_official desc, ma.created_at limit 1) as thumbnail_url,
  coalesce((select jsonb_object_agg(we.locale, jsonb_build_object(
    'shortSummary',we.short_summary,'whyItMatters',we.why_it_matters,
    'historicalContext',we.historical_context,'keyInnovation',we.key_innovation))
    from public.work_editorials we where we.work_id=w.id
    and we.verification_status='verified'),'{}'::jsonb) as editorials,
  coalesce((select jsonb_agg(jsonb_build_object('name',tt.name,'category',tc.code)
    order by tc.code,tt.name) from public.work_taxonomy_terms wtt
    join public.taxonomy_terms tt on tt.id=wtt.term_id
    join public.taxonomy_categories tc on tc.id=tt.category_id
    where wtt.work_id=w.id),'[]'::jsonb) as tags,
  coalesce((select jsonb_agg(jsonb_build_object('title',s.title,'publisher',s.publisher,'url',s.url)
    order by ws.is_primary desc,s.publisher,s.title) from public.work_sources ws
    join public.sources s on s.id=ws.source_id where ws.work_id=w.id),'[]'::jsonb) as sources,
  (select string_agg(
     a.name || ' — ' || ac.name || ' (' || war.award_year::text || ')', E'\n'
     order by war.award_year, a.name, ac.name)
   from public.work_award_results war
   join public.award_categories ac on ac.id=war.award_category_id
   join public.awards a on a.id=ac.award_id
   where war.work_id=w.id and war.result='winner'
     and war.verification_status='verified') as awards
from public.works w
join public.work_types wt on wt.id=w.work_type_id
left join public.music_video_details mvd on mvd.work_id=w.id
where w.status='published';

grant select on public.archive_works to anon, authenticated;

commit;
