-- MVHL Sprint 3 pilot: publish Thriller only after validation succeeds.

begin;

do $$
declare
  target_work_id uuid;
  target_status text;
begin
  select id, status
  into target_work_id, target_status
  from public.works
  where slug = 'michael-jackson-thriller';

  if target_work_id is null then
    raise exception 'Thriller pilot work does not exist.';
  end if;

  if target_status <> 'verified' then
    raise exception 'Thriller must be verified before publishing. Current status: %', target_status;
  end if;

  if not exists (
    select 1
    from public.works
    where id = target_work_id
      and title is not null
      and release_year is not null
      and country_code is not null
      and verified_at is not null
  ) then
    raise exception 'Thriller is missing required objective metadata.';
  end if;

  if (
    select count(distinct we.locale)
    from public.work_editorials we
    where we.work_id = target_work_id
      and we.locale in ('ja', 'en')
      and we.verification_status = 'verified'
      and we.why_it_matters is not null
      and we.historical_context is not null
      and we.key_innovation is not null
  ) <> 2 then
    raise exception 'Thriller requires verified Japanese and English editorial records.';
  end if;

  if not exists (
    select 1
    from public.work_credits wc
    join public.credit_roles cr on cr.id = wc.role_id
    where wc.work_id = target_work_id
      and cr.code = 'artist'
      and wc.verification_status = 'verified'
  ) then
    raise exception 'Thriller requires a verified artist credit.';
  end if;

  if not exists (
    select 1
    from public.work_credits wc
    join public.credit_roles cr on cr.id = wc.role_id
    where wc.work_id = target_work_id
      and cr.code = 'director'
      and wc.verification_status = 'verified'
  ) then
    raise exception 'Thriller requires a verified director credit.';
  end if;

  if not exists (
    select 1
    from public.media_assets ma
    where ma.work_id = target_work_id
      and ma.asset_type = 'full_video'
      and ma.is_official = true
      and ma.availability_status = 'available'
      and ma.url is not null
  ) then
    raise exception 'Thriller requires an available official video.';
  end if;

  if (
    select count(*)
    from public.work_sources ws
    where ws.work_id = target_work_id and ws.is_primary = true
  ) < 2 then
    raise exception 'Thriller requires at least two primary sources.';
  end if;

  update public.works
  set
    status = 'published',
    published_at = now(),
    last_reviewed_at = now()
  where id = target_work_id;
end
$$;

commit;
