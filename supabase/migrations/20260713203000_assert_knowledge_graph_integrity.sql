-- MVHL Knowledge Graph Sprint 1 integrity and public-exposure assertions.

begin;

do $$
declare
  technology_count integer;
  visual_language_count integer;
  technology_edge_count integer;
  visual_language_edge_count integer;
begin
  select count(*) into technology_count
  from public.technologies
  where lifecycle_status = 'published' and is_active;

  select count(*) into visual_language_count
  from public.visual_languages
  where lifecycle_status = 'published' and is_active;

  select count(*) into technology_edge_count
  from public.work_technologies
  where verification_status = 'verified';

  select count(*) into visual_language_edge_count
  from public.work_visual_languages
  where verification_status = 'verified';

  if technology_count < 31 then
    raise exception 'Expected at least 31 published technologies, found %', technology_count;
  end if;

  if visual_language_count < 31 then
    raise exception 'Expected at least 31 published visual languages, found %', visual_language_count;
  end if;

  if technology_edge_count <> 2 then
    raise exception 'Expected exactly 2 verified pilot technology relationships, found %', technology_edge_count;
  end if;

  if visual_language_edge_count <> 25 then
    raise exception 'Expected exactly 25 verified pilot visual-language relationships, found %', visual_language_edge_count;
  end if;

  if exists (
    select slug from public.technologies group by slug having count(*) > 1
  ) then
    raise exception 'Duplicate technology slug detected';
  end if;

  if exists (
    select slug from public.visual_languages group by slug having count(*) > 1
  ) then
    raise exception 'Duplicate visual-language slug detected';
  end if;

  if exists (
    select work_id, technology_id
    from public.work_technologies
    group by work_id, technology_id
    having count(*) > 1
  ) then
    raise exception 'Duplicate work/technology relationship detected';
  end if;

  if exists (
    select work_id, visual_language_id
    from public.work_visual_languages
    group by work_id, visual_language_id
    having count(*) > 1
  ) then
    raise exception 'Duplicate work/visual-language relationship detected';
  end if;

  if exists (
    select 1
    from public.work_technologies wt
    join public.technologies t on t.id = wt.technology_id
    where wt.verification_status = 'verified'
      and (t.lifecycle_status <> 'published' or not t.is_active)
  ) then
    raise exception 'Verified technology relationship points to an unpublished concept';
  end if;

  if exists (
    select 1
    from public.work_visual_languages wvl
    join public.visual_languages vl on vl.id = wvl.visual_language_id
    where wvl.verification_status = 'verified'
      and (vl.lifecycle_status <> 'published' or not vl.is_active)
  ) then
    raise exception 'Verified visual-language relationship points to an unpublished concept';
  end if;

  if exists (
    select 1
    from public.work_technologies wt
    where wt.verification_status = 'verified'
      and not exists (
        select 1 from public.work_technology_sources wts
        where wts.work_technology_id = wt.id
      )
  ) then
    raise exception 'Verified technology relationship without a source';
  end if;

  if exists (
    select 1
    from public.work_visual_languages wvl
    where wvl.verification_status = 'verified'
      and not exists (
        select 1 from public.work_visual_language_sources wvls
        where wvls.work_visual_language_id = wvl.id
      )
  ) then
    raise exception 'Verified visual-language relationship without a source';
  end if;

  if exists (
    select 1 from public.technologies
    where nullif(btrim(description), '') is null
      and nullif(btrim(description_ja), '') is null
  ) then
    raise exception 'Technology without an English or Japanese description';
  end if;

  if exists (
    select 1 from public.visual_languages
    where nullif(btrim(description), '') is null
      and nullif(btrim(description_ja), '') is null
  ) then
    raise exception 'Visual language without an English or Japanese description';
  end if;

  if exists (
    select 1
    from public.works w
    where w.slug in ('kenshi-yonezu-lemon', 'hikaru-utada-one-last-kiss')
      and (
        exists (select 1 from public.work_technologies wt where wt.work_id = w.id)
        or exists (select 1 from public.work_visual_languages wvl where wvl.work_id = w.id)
      )
  ) then
    raise exception 'Deferred pilot work received an unsupported relationship';
  end if;

  if has_column_privilege('anon', 'public.work_technologies', 'verification_notes', 'select')
     or has_column_privilege('authenticated', 'public.work_technologies', 'verification_notes', 'select')
     or has_column_privilege('anon', 'public.work_visual_languages', 'verification_notes', 'select')
     or has_column_privilege('authenticated', 'public.work_visual_languages', 'verification_notes', 'select') then
    raise exception 'Internal verification notes are publicly readable';
  end if;

  if has_table_privilege('anon', 'public.work_technology_sources', 'select')
     or has_table_privilege('authenticated', 'public.work_technology_sources', 'select')
     or has_table_privilege('anon', 'public.work_visual_language_sources', 'select')
     or has_table_privilege('authenticated', 'public.work_visual_language_sources', 'select') then
    raise exception 'Internal relationship-source tables are publicly readable';
  end if;

  if exists (
    select 1 from public.archive_work_technologies awt
    join public.work_technologies wt on wt.id = (
      select inner_wt.id
      from public.work_technologies inner_wt
      join public.works inner_w on inner_w.id = inner_wt.work_id
      join public.technologies inner_t on inner_t.id = inner_wt.technology_id
      where inner_w.slug = awt."workSlug"
        and inner_t.slug = awt."conceptSlug"
      limit 1
    )
    where wt.verification_status = 'disputed'
  ) then
    raise exception 'Public technology view exposes a disputed relationship';
  end if;

  if exists (
    select 1 from public.archive_work_visual_languages awvl
    join public.work_visual_languages wvl on wvl.id = (
      select inner_wvl.id
      from public.work_visual_languages inner_wvl
      join public.works inner_w on inner_w.id = inner_wvl.work_id
      join public.visual_languages inner_vl on inner_vl.id = inner_wvl.visual_language_id
      where inner_w.slug = awvl."workSlug"
        and inner_vl.slug = awvl."conceptSlug"
      limit 1
    )
    where wvl.verification_status = 'disputed'
  ) then
    raise exception 'Public visual-language view exposes a disputed relationship';
  end if;

  raise notice 'Knowledge graph validation passed: % technologies, % visual languages, % technology edges, % visual-language edges',
    technology_count, visual_language_count, technology_edge_count, visual_language_edge_count;
end;
$$;

commit;
