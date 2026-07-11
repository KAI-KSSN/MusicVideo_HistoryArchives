-- Correct the One Last Kiss work slug used by the initial audit migration.

begin;

insert into public.work_award_results (
  work_id,award_id,award_category_id,award_year,result,credited_name_text,
  source_id,verification_status,verification_notes
)
select w.id,a.id,ac.id,2022::smallint,'winner','庵野秀明',s.id,'verified',
  'Official winners archive identifies work and director.'
from public.works w
join public.awards a on a.slug='space-shower-music-awards'
join public.award_categories ac on ac.award_id=a.id and ac.slug='best-conceptual-video'
join public.sources s on s.url='https://awards.spaceshower.jp/2022/winners/index.html'
where w.slug='hikaru-utada-one-last-kiss'
on conflict (work_id,award_category_id,award_year,result) do update set
  award_id=excluded.award_id,credited_name_text=excluded.credited_name_text,
  source_id=excluded.source_id,verification_status=excluded.verification_status,
  verification_notes=excluded.verification_notes;

insert into public.work_sources (work_id,source_id,supports_fields,is_primary,notes)
select w.id,s.id,array['award']::text[],false,'Official result-level source.'
from public.works w
join public.sources s on s.url='https://awards.spaceshower.jp/2022/winners/index.html'
where w.slug='hikaru-utada-one-last-kiss'
on conflict (work_id,source_id) do update set
  supports_fields=(select array_agg(distinct value)
    from unnest(public.work_sources.supports_fields || excluded.supports_fields) value),
  notes=coalesce(public.work_sources.notes,excluded.notes);

commit;
