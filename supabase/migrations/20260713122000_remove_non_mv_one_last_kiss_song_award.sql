-- BEST MOVIE SONG is a recording/song result, not a music-video result.
-- Preserve the official BEST CONCEPTUAL VIDEO work-level result only.

begin;

delete from public.work_award_results war
using public.works w, public.award_categories ac, public.awards a
where war.work_id = w.id
  and war.award_category_id = ac.id
  and war.award_id = a.id
  and w.slug = 'hikaru-utada-one-last-kiss'
  and a.slug = 'space-shower-music-awards'
  and ac.slug = 'best-movie-song'
  and war.award_year = 2022;

do $$
begin
  if (
    select count(*)
    from public.work_award_results war
    join public.works w on w.id = war.work_id
    join public.award_categories ac on ac.id = war.award_category_id
    join public.awards a on a.id = war.award_id
    where w.slug = 'hikaru-utada-one-last-kiss'
      and a.slug = 'space-shower-music-awards'
      and ac.slug = 'best-conceptual-video'
      and war.award_year = 2022
      and war.result = 'winner'
      and war.verification_status = 'verified'
  ) <> 1 then
    raise exception 'One Last Kiss work-level award reconciliation failed';
  end if;
end
$$;

commit;
