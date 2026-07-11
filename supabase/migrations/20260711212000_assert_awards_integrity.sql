-- Abort deployment if the normalized awards dataset violates audit rules.

do $$
declare issues integer;
begin
  select count(*) into issues from (
    select slug from public.awards group by slug having count(*) > 1
  ) q;
  if issues > 0 then raise exception 'Duplicate award slugs: %', issues; end if;

  select count(*) into issues from (
    select award_id,slug,valid_from_year,valid_to_year from public.award_categories
    group by award_id,slug,valid_from_year,valid_to_year having count(*) > 1
  ) q;
  if issues > 0 then raise exception 'Duplicate award categories: %', issues; end if;

  select count(*) into issues from public.work_award_results where source_id is null;
  if issues > 0 then raise exception 'Award results without sources: %', issues; end if;

  select count(*) into issues from public.work_award_results
  where award_year < 1900 or award_year > extract(year from current_date)::int + 2;
  if issues > 0 then raise exception 'Implausible award years: %', issues; end if;

  select count(*) into issues from (
    select work_id,award_category_id,award_year,result from public.work_award_results
    group by work_id,award_category_id,award_year,result having count(*) > 1
  ) q;
  if issues > 0 then raise exception 'Duplicate award results: %', issues; end if;

  select count(*) into issues from public.work_award_results war
  join public.works w on w.id=war.work_id
  where w.status='published' and war.verification_status not in ('verified','cross_checked');
  if issues > 0 then raise exception 'Published works with unverified award results: %', issues; end if;

  select count(*) into issues from public.work_award_results war
  left join public.works w on w.id=war.work_id
  left join public.awards a on a.id=war.award_id
  left join public.award_categories ac on ac.id=war.award_category_id
  left join public.sources s on s.id=war.source_id
  where w.id is null or a.id is null or ac.id is null or s.id is null;
  if issues > 0 then raise exception 'Orphaned award results: %', issues; end if;
end
$$;
