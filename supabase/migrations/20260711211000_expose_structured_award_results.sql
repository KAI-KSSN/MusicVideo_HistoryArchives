-- Public, structured award response. Only published works and source-backed,
-- verified/cross-checked results are exposed.

begin;

create or replace view public.archive_award_results
with (security_invoker = true)
as
select
  w.slug as "workSlug",
  a.official_name as "awardName",
  a.slug as "awardSlug",
  war.award_year as "awardYear",
  ac.official_name as "categoryName",
  ac.category_type as "categoryType",
  war.result,
  coalesce(e.display_name, war.credited_name_text) as "creditedName",
  a.website_url as "officialUrl",
  jsonb_build_array(jsonb_build_object(
    'title', s.title,
    'publisher', s.publisher,
    'url', s.url
  )) as sources
from public.work_award_results war
join public.works w on w.id=war.work_id
join public.awards a on a.id=war.award_id
join public.award_categories ac on ac.id=war.award_category_id
join public.sources s on s.id=war.source_id
left join public.entities e on e.id=war.credited_entity_id
where w.status='published'
  and war.verification_status in ('verified','cross_checked');

grant select on public.archive_award_results to anon, authenticated;

commit;
