-- Backfill result sources into work_sources for public source RLS.

begin;

insert into public.work_sources (work_id,source_id,supports_fields,is_primary,notes)
select distinct war.work_id,war.source_id,array['award']::text[],false,
  'Official result-level source.'
from public.work_award_results war
where war.source_id is not null
on conflict (work_id,source_id) do update set
  supports_fields=(select array_agg(distinct value)
    from unnest(public.work_sources.supports_fields || excluded.supports_fields) value),
  notes=coalesce(public.work_sources.notes,excluded.notes);

insert into public.work_sources (work_id,source_id,supports_fields,is_primary,notes)
select distinct wr.work_id,wr.source_id,array['recognition']::text[],false,
  'Official recognition-level source.'
from public.work_recognitions wr
on conflict (work_id,source_id) do update set
  supports_fields=(select array_agg(distinct value)
    from unnest(public.work_sources.supports_fields || excluded.supports_fields) value),
  notes=coalesce(public.work_sources.notes,excluded.notes);

commit;
