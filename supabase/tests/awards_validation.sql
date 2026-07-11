-- Returns zero rows/counts for a clean awards dataset.

select slug, count(*) from public.awards group by slug having count(*) > 1;

select award_id, slug, valid_from_year, valid_to_year, count(*)
from public.award_categories
group by award_id, slug, valid_from_year, valid_to_year having count(*) > 1;

select id from public.work_award_results where source_id is null;
select id from public.work_award_results where award_category_id is null;

select id, result from public.work_award_results where result not in (
  'winner','nominee','finalist','shortlist','grand_prix','gold','silver','bronze',
  'special_jury','jury_selection','honorable_mention','official_selection','other'
);

select id, award_year from public.work_award_results
where award_year < 1900 or award_year > extract(year from current_date)::int + 2;

select work_id, award_category_id, award_year, result, count(*)
from public.work_award_results
group by work_id, award_category_id, award_year, result having count(*) > 1;

select war.id from public.work_award_results war
join public.works w on w.id=war.work_id
where w.status='published' and war.verification_status not in ('verified','cross_checked');

select ac.id from public.award_categories ac
left join public.awards a on a.id=ac.award_id where a.id is null;

select war.id from public.work_award_results war
left join public.works w on w.id=war.work_id
left join public.award_categories ac on ac.id=war.award_category_id
left join public.awards a on a.id=war.award_id
left join public.sources s on s.id=war.source_id
where w.id is null or ac.id is null or a.id is null or s.id is null;
