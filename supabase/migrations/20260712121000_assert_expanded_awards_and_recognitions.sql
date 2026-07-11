-- Deployment gate for the expanded award and recognition model.

do $$
declare issues integer;
begin
  select count(*) into issues from public.work_award_results where source_id is null;
  if issues > 0 then raise exception 'Award results without sources: %',issues; end if;

  select count(*) into issues from public.work_award_results war
  join public.works w on w.id=war.work_id
  where w.status='published' and war.verification_status not in ('verified','cross_checked');
  if issues > 0 then raise exception 'Published unverified award results: %',issues; end if;

  select count(*) into issues from public.work_recognitions where source_id is null;
  if issues > 0 then raise exception 'Recognitions without sources: %',issues; end if;

  select count(*) into issues from public.work_recognitions wr
  join public.works w on w.id=wr.work_id
  where w.status='published' and wr.verification_status not in ('verified','cross_checked');
  if issues > 0 then raise exception 'Published unverified recognitions: %',issues; end if;

  select count(*) into issues from (
    select work_id,program_id,recognition_year,recognition_type,result
    from public.work_recognitions
    group by work_id,program_id,recognition_year,recognition_type,result
    having count(*) > 1
  ) q;
  if issues > 0 then raise exception 'Duplicate recognitions: %',issues; end if;

  select count(*) into issues from public.work_recognitions wr
  left join public.works w on w.id=wr.work_id
  left join public.recognition_programs rp on rp.id=wr.program_id
  left join public.sources s on s.id=wr.source_id
  where w.id is null or rp.id is null or s.id is null;
  if issues > 0 then raise exception 'Orphaned recognitions: %',issues; end if;
end
$$;
