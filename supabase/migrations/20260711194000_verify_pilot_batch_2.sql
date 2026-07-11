-- MVHL pilot batch 2: verify three works without publishing them.
-- Unknown fields and unconfirmed award details intentionally remain empty.

begin;

insert into public.entities (slug, display_name, entity_type, country_code, official_url)
values
  ('academy-films', 'Academy Films', 'company', 'GB', 'https://www.academyfilms.com/'),
  ('partizan', 'Partizan', 'company', 'FR', 'https://partizan.com/')
on conflict (slug) do update set
  display_name = excluded.display_name,
  entity_type = excluded.entity_type,
  country_code = excluded.country_code,
  official_url = excluded.official_url;

insert into public.work_credits (work_id, entity_id, role_id, verification_status)
select w.id, e.id, r.id, 'verified'
from (values
  ('jamiroquai-virtual-insanity', 'academy-films'),
  ('daft-punk-around-the-world', 'partizan')
) as d(work_slug, entity_slug)
join public.works w on w.slug = d.work_slug
join public.entities e on e.slug = d.entity_slug
join public.credit_roles r on r.code = 'production_company'
on conflict (work_id, entity_id, role_id) do update set
  verification_status = excluded.verification_status;

update public.work_credits wc
set verification_status = 'verified'
from public.works w
where wc.work_id = w.id
  and w.slug in (
    'a-ha-take-on-me',
    'jamiroquai-virtual-insanity',
    'daft-punk-around-the-world'
  )
  and wc.role_id in (
    select id from public.credit_roles where code in ('artist', 'director')
  );

update public.works w
set
  release_year = d.release_year,
  country_code = d.country_code,
  language_code = 'en',
  status = 'verified',
  is_canonical = true,
  verified_at = now(),
  verification_notes = 'Core metadata, official video, editorials, and sources verified for MVHL pilot batch 2. Unknown fields remain empty.',
  short_summary = null,
  why_it_matters = null,
  historical_context = null,
  key_innovation = null,
  editorial_notes = null,
  published_at = null
from (values
  ('a-ha-take-on-me', 1985::smallint, 'GB'),
  ('jamiroquai-virtual-insanity', 1996::smallint, 'GB'),
  ('daft-punk-around-the-world', 1997::smallint, 'FR')
) as d(slug, release_year, country_code)
where w.slug = d.slug;

insert into public.music_video_details (work_id, official_release_url)
select w.id, d.url
from (values
  ('a-ha-take-on-me', 'https://www.youtube.com/watch?v=djV11Xbc914'),
  ('jamiroquai-virtual-insanity', 'https://www.youtube.com/watch?v=4JkIs37a2JE'),
  ('daft-punk-around-the-world', 'https://www.youtube.com/watch?v=K0HSD_i2DvA')
) as d(slug, url)
join public.works w on w.slug = d.slug
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
join (values
  (
    'a-ha-take-on-me',
    'en',
    'A live-action romance crosses into a pencil-drawn world through rotoscope animation.',
    'Take On Me remains a defining example of animation and live action functioning as one continuous narrative space.',
    'The widely recognized 1985 video was directed by Steve Barron and became central to the song’s international visual identity.',
    'Frame-by-frame rotoscope animation connects filmed performance and illustration without separating them into independent sections.'
  ),
  (
    'a-ha-take-on-me',
    'ja',
    '実写のロマンスが、ロトスコープによる鉛筆画の世界へと横断していくミュージックビデオ。',
    'アニメーションと実写を、ひとつの連続した物語空間として成立させた代表的作品です。',
    '広く知られる1985年版はSteve Barronが監督し、楽曲の国際的なビジュアルイメージを決定づけました。',
    'フレーム単位のロトスコープ表現によって、撮影映像とイラストレーションを分断せずに接続しています。'
  ),
  (
    'jamiroquai-virtual-insanity',
    'en',
    'A performance video built around an apparently shifting room, choreographed movement, and practical spatial illusion.',
    'Virtual Insanity is a benchmark for creating an unforgettable visual premise from a restrained set and tightly controlled performance.',
    'Released in 1996 and directed by Jonathan Glazer, the video became one of the defining music-video images of the decade.',
    'Coordinated set movement, camera framing, choreography, and selective object motion create the illusion of an unstable room.'
  ),
  (
    'jamiroquai-virtual-insanity',
    'ja',
    '移動して見える部屋、振付、実践的な空間トリックを軸に構成されたパフォーマンス映像。',
    '抑制されたセットと精密なパフォーマンスから、忘れがたい映像的アイデアを生み出した基準点です。',
    '1996年に公開され、Jonathan Glazerが監督した本作は、1990年代を象徴するMVイメージのひとつとなりました。',
    'セットの移動、カメラのフレーミング、振付、物体の動きを同期させ、不安定に変化する部屋の錯覚を作っています。'
  ),
  (
    'daft-punk-around-the-world',
    'en',
    'Costumed performers translate separate parts of the track into a precisely organized choreographic system.',
    'Around the World demonstrates how musical structure itself can become the narrative and organizing principle of a music video.',
    'Released in 1997 and directed by Michel Gondry, the video belongs to the director-driven music-video culture of the late 1990s.',
    'Distinct performer groups embody different musical components, turning repetition and arrangement into visible choreography.'
  ),
  (
    'daft-punk-around-the-world',
    'ja',
    '衣装をまとった複数のパフォーマーが、楽曲の各パートを精密な振付システムへ翻訳する作品。',
    '楽曲構造そのものを、MVの物語と構成原理へ変換できることを示した作品です。',
    '1997年に公開され、Michel Gondryが監督した本作は、1990年代後半の監督主導型MV文化を代表しています。',
    '異なるパフォーマー群が別々の音楽要素を担当し、反復とアレンジを視覚的な振付として可視化しています。'
  )
) as d(work_slug, locale, short_summary, why_it_matters, historical_context, key_innovation)
  on w.slug = d.work_slug
on conflict (work_id, locale) do update set
  short_summary = excluded.short_summary,
  why_it_matters = excluded.why_it_matters,
  historical_context = excluded.historical_context,
  key_innovation = excluded.key_innovation,
  verification_status = excluded.verification_status,
  reviewed_at = excluded.reviewed_at;

insert into public.taxonomy_terms (category_id, slug, name)
select c.id, d.slug, d.name
from (values
  ('genre', 'pop', 'Pop'),
  ('genre', 'funk', 'Funk'),
  ('genre', 'electronic', 'Electronic'),
  ('technique', 'rotoscope-animation', 'Rotoscope / Live Action + Animation'),
  ('technique', 'practical-set-illusion', 'Practical Set Illusion'),
  ('performance', 'choreography', 'Choreography')
) as d(category_code, slug, name)
join public.taxonomy_categories c on c.code = d.category_code
on conflict (category_id, slug) do update set name = excluded.name;

insert into public.work_taxonomy_terms (work_id, term_id, assignment_method)
select w.id, t.id, 'editorial'
from (values
  ('a-ha-take-on-me', 'pop'),
  ('a-ha-take-on-me', 'rotoscope-animation'),
  ('a-ha-take-on-me', 'mixed-media'),
  ('jamiroquai-virtual-insanity', 'funk'),
  ('jamiroquai-virtual-insanity', 'practical-set-illusion'),
  ('jamiroquai-virtual-insanity', 'solo-performance'),
  ('daft-punk-around-the-world', 'electronic'),
  ('daft-punk-around-the-world', 'choreography')
) as d(work_slug, term_slug)
join public.works w on w.slug = d.work_slug
join public.taxonomy_terms t on t.slug = d.term_slug
on conflict (work_id, term_id) do update set
  assignment_method = excluded.assignment_method;

insert into public.media_assets (
  work_id, platform, asset_type, external_id, url,
  is_official, availability_status, last_checked_at
)
select
  w.id, 'youtube', 'full_video', d.youtube_id, d.url,
  true, 'available', now()
from (values
  ('a-ha-take-on-me', 'djV11Xbc914', 'https://www.youtube.com/watch?v=djV11Xbc914'),
  ('jamiroquai-virtual-insanity', '4JkIs37a2JE', 'https://www.youtube.com/watch?v=4JkIs37a2JE'),
  ('daft-punk-around-the-world', 'K0HSD_i2DvA', 'https://www.youtube.com/watch?v=K0HSD_i2DvA')
) as d(slug, youtube_id, url)
join public.works w on w.slug = d.slug
on conflict (work_id, url) do update set
  external_id = excluded.external_id,
  is_official = excluded.is_official,
  availability_status = excluded.availability_status,
  last_checked_at = excluded.last_checked_at;

insert into public.media_assets (
  work_id, platform, asset_type, external_id, url,
  is_official, availability_status, last_checked_at
)
select
  w.id, 'youtube', 'thumbnail', null,
  'https://i.ytimg.com/vi/' || d.youtube_id || '/maxresdefault.jpg',
  true, 'available', now()
from (values
  ('a-ha-take-on-me', 'djV11Xbc914'),
  ('jamiroquai-virtual-insanity', '4JkIs37a2JE'),
  ('daft-punk-around-the-world', 'K0HSD_i2DvA')
) as d(slug, youtube_id)
join public.works w on w.slug = d.slug
on conflict (work_id, url) do update set
  is_official = excluded.is_official,
  availability_status = excluded.availability_status,
  last_checked_at = excluded.last_checked_at;

insert into public.sources (source_type, title, publisher, url, notes)
values
  ('artist_official', 'a-ha Promo Videos', 'a-ha Discography', 'https://a-hadiscography.com/video.htm', 'Supports the 1985 version, Steve Barron direction, and semi-animated format.'),
  ('label', 'a-ha Videos', 'Warner Music Japan', 'https://wmg.jp/a-ha/mv/', 'Official label video listing.'),
  ('official_video', 'a-ha - Take On Me (Official Video) [4K]', 'a-ha / YouTube', 'https://www.youtube.com/watch?v=djV11Xbc914', 'Official video URL and YouTube identifier.'),
  ('production_company', 'Jamiroquai - Virtual Insanity', 'Academy Films', 'https://www.academyfilms.com/portfolio/jamiroquai-virtual-insanity', 'Supports Jonathan Glazer direction and Academy Films production attribution.'),
  ('database', 'Virtual Insanity', 'Official Charts', 'https://www.officialcharts.com/songs/jamiroquai-virtual-insanity/', 'Supports the 1996 release period.'),
  ('official_video', 'Jamiroquai - Virtual Insanity (Official Video)', 'Jamiroquai / YouTube', 'https://www.youtube.com/watch?v=4JkIs37a2JE', 'Official video URL and YouTube identifier.'),
  ('artist_official', 'Daft Punk - Homework', 'Daft Punk', 'https://www.daftpunk.com/homework/', 'Supports the 1997 release context and official Michel Gondry commentary listing.'),
  ('production_company', 'Michel Gondry - Around the World', 'Partizan', 'https://partizan.com/director/michel-gondry/commercials-branded/', 'Supports Michel Gondry direction and Partizan production attribution.'),
  ('official_video', 'Daft Punk - Around The World (Official Music Video Remastered)', 'Daft Punk / YouTube', 'https://www.youtube.com/watch?v=K0HSD_i2DvA', 'Official video URL and YouTube identifier.')
on conflict (url) do update set
  title = excluded.title,
  publisher = excluded.publisher,
  notes = excluded.notes,
  accessed_at = current_date;

insert into public.work_sources (work_id, source_id, supports_fields, is_primary)
select w.id, s.id, d.supports_fields, d.is_primary
from (values
  ('a-ha-take-on-me', 'https://a-hadiscography.com/video.htm', array['release_year','director','key_innovation']::text[], true),
  ('a-ha-take-on-me', 'https://wmg.jp/a-ha/mv/', array['official_video']::text[], true),
  ('a-ha-take-on-me', 'https://www.youtube.com/watch?v=djV11Xbc914', array['official_video_url','youtube_id','thumbnail']::text[], false),
  ('jamiroquai-virtual-insanity', 'https://www.academyfilms.com/portfolio/jamiroquai-virtual-insanity', array['director','production_company','why_it_matters']::text[], true),
  ('jamiroquai-virtual-insanity', 'https://www.officialcharts.com/songs/jamiroquai-virtual-insanity/', array['release_year']::text[], true),
  ('jamiroquai-virtual-insanity', 'https://www.youtube.com/watch?v=4JkIs37a2JE', array['official_video_url','youtube_id','thumbnail']::text[], false),
  ('daft-punk-around-the-world', 'https://www.daftpunk.com/homework/', array['release_year','historical_context']::text[], true),
  ('daft-punk-around-the-world', 'https://partizan.com/director/michel-gondry/commercials-branded/', array['director','production_company','key_innovation']::text[], true),
  ('daft-punk-around-the-world', 'https://www.youtube.com/watch?v=K0HSD_i2DvA', array['official_video_url','youtube_id','thumbnail']::text[], false)
) as d(work_slug, source_url, supports_fields, is_primary)
join public.works w on w.slug = d.work_slug
join public.sources s on s.url = d.source_url
on conflict (work_id, source_id) do update set
  supports_fields = excluded.supports_fields,
  is_primary = excluded.is_primary;

commit;
