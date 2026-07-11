-- Publish the ten-work pilot only when every work passes the same minimum gate.

begin;

do $$
declare
  target_count integer;
  invalid_count integer;
begin
  select count(*) into target_count
  from public.works
  where slug in (
    'michael-jackson-thriller','a-ha-take-on-me',
    'jamiroquai-virtual-insanity','daft-punk-around-the-world',
    'fatboy-slim-weapon-of-choice','beyonce-single-ladies',
    'childish-gambino-this-is-america','sakanaction-shin-takarajima',
    'kenshi-yonezu-lemon','hikaru-utada-one-last-kiss'
  );

  if target_count <> 10 then
    raise exception 'Pilot publication requires exactly 10 works; found %.', target_count;
  end if;

  select count(*) into invalid_count
  from public.works w
  where w.slug in (
    'michael-jackson-thriller','a-ha-take-on-me',
    'jamiroquai-virtual-insanity','daft-punk-around-the-world',
    'fatboy-slim-weapon-of-choice','beyonce-single-ladies',
    'childish-gambino-this-is-america','sakanaction-shin-takarajima',
    'kenshi-yonezu-lemon','hikaru-utada-one-last-kiss'
  )
  and (
    w.status not in ('verified','published')
    or w.release_year is null
    or w.country_code is null
    or w.verified_at is null
    or (select count(distinct we.locale) from public.work_editorials we
        where we.work_id = w.id and we.locale in ('ja','en')
          and we.verification_status = 'verified'
          and we.why_it_matters is not null
          and we.historical_context is not null
          and we.key_innovation is not null) <> 2
    or not exists (select 1 from public.work_credits wc join public.credit_roles cr on cr.id=wc.role_id
                   where wc.work_id=w.id and cr.code='artist' and wc.verification_status='verified')
    or not exists (select 1 from public.work_credits wc join public.credit_roles cr on cr.id=wc.role_id
                   where wc.work_id=w.id and cr.code='director' and wc.verification_status='verified')
    or not exists (select 1 from public.media_assets ma where ma.work_id=w.id
                   and ma.asset_type='full_video' and ma.is_official=true
                   and ma.availability_status='available')
    or (select count(*) from public.work_sources ws where ws.work_id=w.id and ws.is_primary=true) < 2
  );

  if invalid_count <> 0 then
    raise exception 'Pilot publication gate failed for % work(s).', invalid_count;
  end if;

  update public.works
  set status='published', published_at=coalesce(published_at,now()), last_reviewed_at=now()
  where slug in (
    'michael-jackson-thriller','a-ha-take-on-me',
    'jamiroquai-virtual-insanity','daft-punk-around-the-world',
    'fatboy-slim-weapon-of-choice','beyonce-single-ladies',
    'childish-gambino-this-is-america','sakanaction-shin-takarajima',
    'kenshi-yonezu-lemon','hikaru-utada-one-last-kiss'
  );
end
$$;

commit;
