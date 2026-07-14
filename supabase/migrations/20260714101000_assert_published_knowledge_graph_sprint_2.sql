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

  if published_work_count <> 72 then
    raise exception 'Published scope changed during Sprint 2: expected 72, found %', published_work_count;
  end if;
  if reviewed_work_count <> published_work_count then
    raise exception 'Not every published work was reviewed: % / %', reviewed_work_count, published_work_count;
  end if;

  select count(*) into verified_technology_count from public.work_technologies where verification_status = 'verified';
  select count(*) into verified_visual_count from public.work_visual_languages where verification_status = 'verified';
  if verified_technology_count <> 15 then
    raise exception 'Expected 15 verified Technology relationships, found %', verified_technology_count;
  end if;
  if verified_visual_count <> 147 then
    raise exception 'Expected 147 verified Visual Language relationships, found %', verified_visual_count;
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
