-- Replace unavailable YouTube max-resolution thumbnails with verified variants.
begin;

update public.media_assets ma
set url=replacement.thumbnail_url, availability_status='available', last_checked_at=now()
from public.works w
join (values
  ('queen-bohemian-rhapsody','https://i.ytimg.com/vi/fJ9rUzIMcZQ/hqdefault.jpg'),
  ('bjork-big-time-sensuality','https://i.ytimg.com/vi/75WFTHpOw8Y/hqdefault.jpg'),
  ('aphex-twin-come-to-daddy','https://i.ytimg.com/vi/TZ827lkktYs/sddefault.jpg'),
  ('royksopp-remind-me','https://i.ytimg.com/vi/1Xhdy9zBEws/hqdefault.jpg'),
  ('muse-knights-of-cydonia','https://i.ytimg.com/vi/G_sBOsh-vyI/sddefault.jpg'),
  ('the-knife-silent-shout','https://i.ytimg.com/vi/mWzZnxPAQhs/sddefault.jpg'),
  ('battles-atlas','https://i.ytimg.com/vi/IpGp-22t0lU/hqdefault.jpg'),
  ('sakanaction-aruku-around','https://i.ytimg.com/vi/vS6wzjpCvec/hqdefault.jpg'),
  ('millennium-parade-fly-with-me','https://i.ytimg.com/vi/fuXZMQAD9vU/sddefault.jpg')
) as replacement(slug,thumbnail_url) on replacement.slug=w.slug
where ma.work_id=w.id and ma.platform='youtube' and ma.asset_type='thumbnail';

do $$ begin
  if (select count(*) from public.media_assets ma join public.works w on w.id=ma.work_id
      where w.slug in ('queen-bohemian-rhapsody','bjork-big-time-sensuality','aphex-twin-come-to-daddy','royksopp-remind-me','muse-knights-of-cydonia','the-knife-silent-shout','battles-atlas','sakanaction-aruku-around','millennium-parade-fly-with-me')
      and ma.platform='youtube' and ma.asset_type='thumbnail' and ma.availability_status='available') <> 9 then
    raise exception 'Expected nine repaired YouTube thumbnails';
  end if;
end $$;

commit;
