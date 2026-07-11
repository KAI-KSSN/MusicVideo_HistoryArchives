-- MVHL Sprint 3 pilot: verify Thriller without publishing it.
-- Unknown Production/VFX/Award fields intentionally remain empty.

begin;

insert into public.entities (slug, display_name, entity_type, country_code)
values ('optimum-productions', 'Optimum Productions', 'company', 'US')
on conflict (slug) do update set
  display_name = excluded.display_name,
  entity_type = excluded.entity_type,
  country_code = excluded.country_code;

insert into public.work_credits (
  work_id,
  entity_id,
  role_id,
  verification_status
)
select w.id, e.id, r.id, 'verified'
from public.works w
join public.entities e on e.slug = 'optimum-productions'
join public.credit_roles r on r.code = 'production_company'
where w.slug = 'michael-jackson-thriller'
on conflict (work_id, entity_id, role_id) do update set
  verification_status = excluded.verification_status;

update public.work_credits wc
set verification_status = 'verified'
from public.works w
where wc.work_id = w.id
  and w.slug = 'michael-jackson-thriller'
  and wc.role_id in (
    select id from public.credit_roles where code in ('artist', 'director')
  );

update public.works
set
  title = 'Thriller',
  original_title = 'Michael Jackson''s Thriller',
  release_year = 1983,
  country_code = 'US',
  language_code = 'en',
  status = 'verified',
  is_canonical = true,
  verified_at = now(),
  verification_notes = 'Core metadata verified against the Library of Congress catalog and National Film Registry. Unknown fields remain empty.',
  short_summary = null,
  why_it_matters = null,
  historical_context = null,
  key_innovation = null,
  editorial_notes = null,
  published_at = null
where slug = 'michael-jackson-thriller';

insert into public.music_video_details (work_id, official_release_url)
select id, 'https://www.youtube.com/watch?v=sOnqjkJTMaA'
from public.works
where slug = 'michael-jackson-thriller'
on conflict (work_id) do update set
  official_release_url = excluded.official_release_url;

insert into public.work_editorials (
  work_id,
  locale,
  short_summary,
  why_it_matters,
  historical_context,
  key_innovation,
  verification_status,
  reviewed_at
)
select
  w.id,
  d.locale,
  d.short_summary,
  d.why_it_matters,
  d.historical_context,
  d.key_innovation,
  'verified',
  now()
from public.works w
cross join (values
  (
    'en',
    'A long-form music video combining dramatic narrative, choreography, make-up, and special effects.',
    'Thriller is a landmark example of the music video expanding into cinematic, long-form storytelling.',
    'Released in 1983, the film was also shown theatrically in 35mm and was selected for the U.S. National Film Registry in 2009.',
    'It integrates narrative filmmaking, choreography, make-up, and special effects within an extended music-video format.'
  ),
  (
    'ja',
    'ドラマ的な物語、振付、特殊メイク、特殊効果を組み合わせた長編形式のミュージックビデオ。',
    'ミュージックビデオを映画的な長編ストーリーテリングへ拡張した代表的作品です。',
    '1983年に公開され、35mmフィルムによる劇場上映も行われました。2009年には米国国立フィルム登録簿に選定されています。',
    '物語演出、振付、特殊メイク、特殊効果を長編形式のミュージックビデオへ統合しています。'
  )
) as d(locale, short_summary, why_it_matters, historical_context, key_innovation)
where w.slug = 'michael-jackson-thriller'
on conflict (work_id, locale) do update set
  short_summary = excluded.short_summary,
  why_it_matters = excluded.why_it_matters,
  historical_context = excluded.historical_context,
  key_innovation = excluded.key_innovation,
  verification_status = excluded.verification_status,
  reviewed_at = excluded.reviewed_at;

insert into public.taxonomy_terms (category_id, slug, name)
select id, 'pop', 'Pop'
from public.taxonomy_categories
where code = 'genre'
on conflict (category_id, slug) do update set name = excluded.name;

insert into public.work_taxonomy_terms (work_id, term_id, assignment_method)
select w.id, t.id, 'editorial'
from public.works w
join public.taxonomy_terms t on t.slug = 'pop'
join public.taxonomy_categories c on c.id = t.category_id and c.code = 'genre'
where w.slug = 'michael-jackson-thriller'
on conflict (work_id, term_id) do update set
  assignment_method = excluded.assignment_method;

insert into public.media_assets (
  work_id,
  platform,
  asset_type,
  external_id,
  url,
  is_official,
  availability_status,
  last_checked_at
)
select
  id,
  'youtube',
  'full_video',
  'sOnqjkJTMaA',
  'https://www.youtube.com/watch?v=sOnqjkJTMaA',
  true,
  'available',
  now()
from public.works
where slug = 'michael-jackson-thriller'
on conflict (work_id, url) do update set
  external_id = excluded.external_id,
  is_official = excluded.is_official,
  availability_status = excluded.availability_status,
  last_checked_at = excluded.last_checked_at;

insert into public.media_assets (
  work_id,
  platform,
  asset_type,
  external_id,
  url,
  is_official,
  availability_status,
  last_checked_at
)
select
  id,
  'youtube',
  'thumbnail',
  null,
  'https://i.ytimg.com/vi/sOnqjkJTMaA/maxresdefault.jpg',
  true,
  'available',
  now()
from public.works
where slug = 'michael-jackson-thriller'
on conflict (work_id, url) do update set
  is_official = excluded.is_official,
  availability_status = excluded.availability_status,
  last_checked_at = excluded.last_checked_at;

insert into public.sources (source_type, title, publisher, url, notes)
values
  (
    'database',
    'Michael Jackson''s Thriller',
    'Library of Congress',
    'https://www.loc.gov/item/86708393/',
    'Catalog record supporting title, year, country, director, production company, and production characteristics.'
  ),
  (
    'award_archive',
    '2009 National Film Registry',
    'Library of Congress',
    'https://www.loc.gov/item/prn-09-250/',
    'Supports the 2009 National Film Registry selection and historical context.'
  ),
  (
    'official_video',
    'Michael Jackson - Thriller (Official 4K Video)',
    'Michael Jackson / YouTube',
    'https://www.youtube.com/watch?v=sOnqjkJTMaA',
    'Official public video URL and YouTube identifier.'
  )
on conflict (url) do update set
  title = excluded.title,
  publisher = excluded.publisher,
  notes = excluded.notes,
  accessed_at = current_date;

insert into public.work_sources (
  work_id,
  source_id,
  supports_fields,
  is_primary
)
select
  w.id,
  s.id,
  case s.url
    when 'https://www.loc.gov/item/86708393/' then array[
      'title', 'release_year', 'country_code', 'director',
      'production_company', 'short_summary', 'key_innovation'
    ]::text[]
    when 'https://www.loc.gov/item/prn-09-250/' then array[
      'historical_context', 'why_it_matters', 'registry_selection'
    ]::text[]
    else array['official_video_url', 'youtube_id', 'thumbnail']::text[]
  end,
  s.url <> 'https://www.youtube.com/watch?v=sOnqjkJTMaA'
from public.works w
join public.sources s on s.url in (
  'https://www.loc.gov/item/86708393/',
  'https://www.loc.gov/item/prn-09-250/',
  'https://www.youtube.com/watch?v=sOnqjkJTMaA'
)
where w.slug = 'michael-jackson-thriller'
on conflict (work_id, source_id) do update set
  supports_fields = excluded.supports_fields,
  is_primary = excluded.is_primary;

commit;
