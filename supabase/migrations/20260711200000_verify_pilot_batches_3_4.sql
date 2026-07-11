-- MVHL pilot batches 3 and 4: verify the remaining six pilot works.
-- Unknown production details intentionally remain empty.

begin;

update public.work_credits wc
set verification_status = 'verified'
from public.works w
where wc.work_id = w.id
  and w.slug in (
    'fatboy-slim-weapon-of-choice',
    'beyonce-single-ladies',
    'childish-gambino-this-is-america',
    'sakanaction-shin-takarajima',
    'kenshi-yonezu-lemon',
    'hikaru-utada-one-last-kiss'
  )
  and wc.role_id in (
    select id from public.credit_roles where code in ('artist', 'director')
  );

update public.works w
set
  release_year = d.release_year,
  country_code = d.country_code,
  language_code = d.language_code,
  status = 'verified',
  is_canonical = true,
  verified_at = now(),
  verification_notes = 'Core metadata, official video, bilingual editorials, and sources verified for the MVHL pilot.',
  short_summary = null,
  why_it_matters = null,
  historical_context = null,
  key_innovation = null,
  editorial_notes = null,
  published_at = null
from (values
  ('fatboy-slim-weapon-of-choice', 2001::smallint, 'US', 'en'),
  ('beyonce-single-ladies', 2008::smallint, 'US', 'en'),
  ('childish-gambino-this-is-america', 2018::smallint, 'US', 'en'),
  ('sakanaction-shin-takarajima', 2015::smallint, 'JP', 'ja'),
  ('kenshi-yonezu-lemon', 2018::smallint, 'JP', 'ja'),
  ('hikaru-utada-one-last-kiss', 2021::smallint, 'JP', 'ja')
) as d(slug, release_year, country_code, language_code)
where w.slug = d.slug;

insert into public.music_video_details (work_id, official_release_url)
select w.id, d.url
from (values
  ('fatboy-slim-weapon-of-choice', 'https://www.youtube.com/watch?v=XQ7z57qrZU8'),
  ('beyonce-single-ladies', 'https://www.youtube.com/watch?v=4m1EFMoRFvY'),
  ('childish-gambino-this-is-america', 'https://www.youtube.com/watch?v=VYOjWnS4cMY'),
  ('sakanaction-shin-takarajima', 'https://www.youtube.com/watch?v=LIlZCmETvsY'),
  ('kenshi-yonezu-lemon', 'https://www.youtube.com/watch?v=SX_ViT4Ra7k'),
  ('hikaru-utada-one-last-kiss', 'https://www.youtube.com/watch?v=0Uhh62MUEic')
) as d(slug, url)
join public.works w on w.slug = d.slug
on conflict (work_id) do update set official_release_url = excluded.official_release_url;

insert into public.work_editorials (
  work_id, locale, short_summary, why_it_matters, historical_context,
  key_innovation, verification_status, reviewed_at
)
select w.id, d.locale, d.short_summary, d.why_it_matters,
       d.historical_context, d.key_innovation, 'verified', now()
from public.works w
join (values
  ('fatboy-slim-weapon-of-choice','en','Christopher Walken dances alone through a hotel in a performance-led film directed by Spike Jonze.','Weapon of Choice shows how a single performer, a familiar location, and a clear physical premise can carry an entire music video.','Released in 2001, the video won the 2002 GRAMMY for Best Music Video and became one of Spike Jonze’s most widely recognized works.','Long takes, restrained visual effects, choreography, and wire-assisted movement turn an ordinary hotel into a continuous performance space.'),
  ('fatboy-slim-weapon-of-choice','ja','Christopher Walkenがホテルを一人で踊り進む、Spike Jonze監督のパフォーマンス映像。','一人の演者、身近なロケーション、明快な身体表現だけでMV全体を成立させた代表例です。','2001年に公開され、2002年のGRAMMY Best Music Videoを受賞。Spike Jonzeの代表作のひとつとなりました。','長回し、抑制されたVFX、振付、ワイヤーアクションによって、ホテル全体を連続した舞台へ変換しています。'),
  ('beyonce-single-ladies','en','Three dancers, a monochrome studio, and tightly synchronized choreography define a deliberately minimal performance video.','Single Ladies demonstrates how reduction can strengthen an image: choreography, silhouette, and repetition become the complete visual identity.','Released in 2008 and directed by Jake Nava, the video became a major reference point for choreography-led online circulation and imitation.','Long performance passages and a minimal seamless set keep attention on bodily precision, formation, and camera rhythm.'),
  ('beyonce-single-ladies','ja','3人のダンサー、モノクロのスタジオ、精密に同期した振付で構成されたミニマルなパフォーマンス映像。','要素を削ぎ落とすことで、振付、シルエット、反復そのものを作品の視覚的アイデンティティにした代表例です。','Jake Navaが監督した2008年の作品で、振付を軸とするオンライン上の模倣と拡散の基準点になりました。','長いパフォーマンス区間と簡潔な白ホリゾントにより、身体の精度、フォーメーション、カメラのリズムへ視線を集中させています。'),
  ('childish-gambino-this-is-america','en','A mobile camera follows Childish Gambino through a warehouse as performance and violence compete for attention.','This Is America uses the mechanics of spectacle itself to examine distraction, violence, race, and entertainment in the United States.','Released in 2018 and directed by Hiro Murai, the video became an immediate cultural discussion and won the 2019 GRAMMY for Best Music Video.','Foreground choreography and background incidents are staged in long moving passages, forcing viewers to choose where to look.'),
  ('childish-gambino-this-is-america','ja','移動するカメラが倉庫内のChildish Gambinoを追い、パフォーマンスと暴力が同時に注意を奪い合う作品。','スペクタクルそのものの仕組みを用いて、米国における注意の逸脱、暴力、人種、娯楽を扱った作品です。','Hiro Murai監督により2018年に公開され、直ちに大きな文化的議論を生み、2019年GRAMMY Best Music Videoを受賞しました。','前景の振付と背景の事件を長い移動ショット内で並行させ、観客に見る場所の選択を迫ります。'),
  ('sakanaction-shin-takarajima','en','Sakanaction reframe the visual language of Japanese retro television through choreography, sets, and practical gags.','Shin Takarajima is a prominent contemporary example of Japanese popular-media history being quoted, reorganized, and made newly legible.','Released in 2015 and directed by Yusuke Tanaka, the video draws openly on Showa-era music and variety television aesthetics.','Period-style framing, synchronized movement, graphic props, and practical stage devices recreate television memory without treating it as a literal replica.'),
  ('sakanaction-shin-takarajima','ja','昭和期の歌番組やバラエティ番組の視覚言語を、振付、セット、実践的な仕掛けで再構成した作品。','日本の大衆映像史を引用し、現代のMVとして読み替えた代表的な作品です。','田中裕介が監督し2015年に公開。昭和の歌番組やバラエティ番組へのオマージュを明確な基盤としています。','時代を想起させる構図、同期した動き、グラフィック、小道具、舞台装置により、テレビの記憶を単純な再現ではなく再編集しています。'),
  ('kenshi-yonezu-lemon','en','A restrained cinematic portrait combines performance, symbolic objects, and an uncanny interior atmosphere.','Lemon became one of the defining Japanese music videos of its period while maintaining a controlled, ambiguous visual language.','Released in 2018 and directed by Tomokazu Yamada, the video accompanied a song written for the television drama Unnatural and reached an exceptional audience through the official channel.','Measured camera movement, choreographed gesture, repeated symbolic objects, and muted production design sustain emotional ambiguity.'),
  ('kenshi-yonezu-lemon','ja','抑制された人物描写、象徴的なオブジェクト、現実からわずかにずれた室内空間を組み合わせた作品。','制御された曖昧な映像言語を保ちながら、同時代の日本を代表する規模で視聴されたMVです。','山田智和が監督し2018年に公開。ドラマ「アンナチュラル」のために書き下ろされた楽曲とともに広く浸透しました。','緩やかなカメラ移動、身振り、反復する象徴物、抑制された美術によって、感情を一義的に説明しない空気を維持しています。'),
  ('hikaru-utada-one-last-kiss','en','Fragmentary everyday images and direct-to-camera moments form an intimate digital portrait of Hikaru Utada.','One Last Kiss treats low-fi digital capture as an expressive language rather than a limitation, connecting private-scale imagery with a major film release.','Released in 2021 and directed by Hideaki Anno, the video was created in connection with Evangelion: 3.0+1.0 Thrice Upon a Time.','Mixed cameras, compressed textures, informal framing, and discontinuous fragments turn personal digital footage into a coherent music-video form.'),
  ('hikaru-utada-one-last-kiss','ja','日常の断片とカメラへ直接向けられた姿が、宇多田ヒカルの親密なデジタルポートレートを構成する作品。','ローファイなデジタル撮影を制約ではなく表現言語として扱い、私的な映像スケールと大作映画の公開を接続しました。','庵野秀明が手掛け、2021年に「シン・エヴァンゲリオン劇場版」と関連して公開されました。','複数の撮影機材、圧縮感のある質感、非形式的な構図、断片的な編集をひとつのMV表現へまとめています。')
) as d(work_slug, locale, short_summary, why_it_matters, historical_context, key_innovation)
  on w.slug = d.work_slug
on conflict (work_id, locale) do update set
  short_summary = excluded.short_summary,
  why_it_matters = excluded.why_it_matters,
  historical_context = excluded.historical_context,
  key_innovation = excluded.key_innovation,
  verification_status = excluded.verification_status,
  reviewed_at = excluded.reviewed_at;

insert into public.media_assets (
  work_id, platform, asset_type, external_id, url,
  is_official, availability_status, last_checked_at
)
select w.id, 'youtube', 'full_video', d.youtube_id, d.url, true, 'available', now()
from (values
  ('fatboy-slim-weapon-of-choice','XQ7z57qrZU8','https://www.youtube.com/watch?v=XQ7z57qrZU8'),
  ('beyonce-single-ladies','4m1EFMoRFvY','https://www.youtube.com/watch?v=4m1EFMoRFvY'),
  ('childish-gambino-this-is-america','VYOjWnS4cMY','https://www.youtube.com/watch?v=VYOjWnS4cMY'),
  ('sakanaction-shin-takarajima','LIlZCmETvsY','https://www.youtube.com/watch?v=LIlZCmETvsY'),
  ('kenshi-yonezu-lemon','SX_ViT4Ra7k','https://www.youtube.com/watch?v=SX_ViT4Ra7k'),
  ('hikaru-utada-one-last-kiss','0Uhh62MUEic','https://www.youtube.com/watch?v=0Uhh62MUEic')
) as d(slug, youtube_id, url)
join public.works w on w.slug = d.slug
on conflict (work_id, url) do update set
  external_id = excluded.external_id, is_official = true,
  availability_status = 'available', last_checked_at = now();

insert into public.media_assets (
  work_id, platform, asset_type, url, is_official, availability_status, last_checked_at
)
select w.id, 'youtube', 'thumbnail',
       'https://i.ytimg.com/vi/' || d.youtube_id || '/maxresdefault.jpg',
       true, 'available', now()
from (values
  ('fatboy-slim-weapon-of-choice','XQ7z57qrZU8'),
  ('beyonce-single-ladies','4m1EFMoRFvY'),
  ('childish-gambino-this-is-america','VYOjWnS4cMY'),
  ('sakanaction-shin-takarajima','LIlZCmETvsY'),
  ('kenshi-yonezu-lemon','SX_ViT4Ra7k'),
  ('hikaru-utada-one-last-kiss','0Uhh62MUEic')
) as d(slug, youtube_id)
join public.works w on w.slug = d.slug
on conflict (work_id, url) do update set
  is_official = true, availability_status = 'available', last_checked_at = now();

insert into public.sources (source_type, title, publisher, url, notes)
values
  ('award_archive', 'Spike Jonze GRAMMY history', 'GRAMMY', 'https://www.grammy.com/artists/spike-jonze/9835/', 'Confirms Weapon of Choice and its 2002 Best Music Video recognition.'),
  ('artist_official', 'Weapon of Choice', 'Fatboy Slim', 'https://www.fatboyslim.net/songs/weapon-of-choice/', 'Official artist page for the work.'),
  ('award_archive', '2009 Video Music Awards results', 'Paramount / MTV', 'https://ir.paramount.com/news-releases/news-release-details/beyonce-green-day-lady-gaga-lead-way-three-moonmen-2009-video', 'Confirms Jake Nava direction and Anonymous Content production.'),
  ('official_video', 'Beyoncé - Single Ladies', 'Beyoncé / YouTube', 'https://www.youtube.com/watch?v=4m1EFMoRFvY', 'Official video.'),
  ('award_archive', 'Hiro Murai GRAMMY history', 'GRAMMY', 'https://www.grammy.com/artists/hiro-murai/243444/', 'Confirms This Is America and Best Music Video win.'),
  ('label', 'Childish Gambino releases This Is America', 'Sony Music UK', 'https://www.sonymusic.co.uk/childish-gambino-releases-this-is-america-video/', 'Confirms Hiro Murai direction and official release context.'),
  ('artist_official', '新宝島 10周年記念', 'サカナクション', 'https://sakanaction.jp/news/detail/3085?categoryId=1,2&lang=en', 'Confirms Yusuke Tanaka direction and retro television references.'),
  ('official_video', 'サカナクション / 新宝島', 'サカナクション / YouTube', 'https://www.youtube.com/watch?v=LIlZCmETvsY', 'Official video.'),
  ('label', '米津玄師 profile', 'Sony Music Japan', 'https://www.sonymusic.co.jp/artist/kenshiyonezu/profile/', 'Confirms the exceptional official-viewing history of Lemon.'),
  ('label', 'Lemon discography', 'Sony Music Japan', 'https://www.sonymusic.co.jp/artist/kenshiyonezu/discography/buy/SRCL-9749', 'Confirms 2018 release context.'),
  ('label', 'One Last Kiss music video news', 'Sony Music Japan', 'https://www.sonymusic.co.jp/artist/utadahikaru/info/528047', 'Confirms Hideaki Anno direction and release context.'),
  ('official_video', '宇多田ヒカル - One Last Kiss', 'Hikaru Utada / YouTube', 'https://www.youtube.com/watch?v=0Uhh62MUEic', 'Official video.')
on conflict (url) do update set
  title = excluded.title, publisher = excluded.publisher,
  notes = excluded.notes, accessed_at = current_date;

insert into public.work_sources (work_id, source_id, supports_fields, is_primary)
select w.id, s.id, d.fields, true
from (values
  ('fatboy-slim-weapon-of-choice','https://www.grammy.com/artists/spike-jonze/9835/',array['director','award','release_year']::text[]),
  ('fatboy-slim-weapon-of-choice','https://www.fatboyslim.net/songs/weapon-of-choice/',array['artist','official_work']::text[]),
  ('beyonce-single-ladies','https://ir.paramount.com/news-releases/news-release-details/beyonce-green-day-lady-gaga-lead-way-three-moonmen-2009-video',array['director','production_company','award']::text[]),
  ('beyonce-single-ladies','https://www.youtube.com/watch?v=4m1EFMoRFvY',array['official_video_url','youtube_id','thumbnail']::text[]),
  ('childish-gambino-this-is-america','https://www.grammy.com/artists/hiro-murai/243444/',array['director','award']::text[]),
  ('childish-gambino-this-is-america','https://www.sonymusic.co.uk/childish-gambino-releases-this-is-america-video/',array['release_year','director','official_video']::text[]),
  ('sakanaction-shin-takarajima','https://sakanaction.jp/news/detail/3085?categoryId=1,2&lang=en',array['director','historical_context','key_innovation']::text[]),
  ('sakanaction-shin-takarajima','https://www.youtube.com/watch?v=LIlZCmETvsY',array['official_video_url','youtube_id','thumbnail']::text[]),
  ('kenshi-yonezu-lemon','https://www.sonymusic.co.jp/artist/kenshiyonezu/profile/',array['artist','cultural_impact']::text[]),
  ('kenshi-yonezu-lemon','https://www.sonymusic.co.jp/artist/kenshiyonezu/discography/buy/SRCL-9749',array['release_year','release_context']::text[]),
  ('hikaru-utada-one-last-kiss','https://www.sonymusic.co.jp/artist/utadahikaru/info/528047',array['director','release_year','historical_context']::text[]),
  ('hikaru-utada-one-last-kiss','https://www.youtube.com/watch?v=0Uhh62MUEic',array['official_video_url','youtube_id','thumbnail']::text[])
) as d(slug, url, fields)
join public.works w on w.slug = d.slug
join public.sources s on s.url = d.url
on conflict (work_id, source_id) do update set
  supports_fields = excluded.supports_fields, is_primary = excluded.is_primary;

commit;
