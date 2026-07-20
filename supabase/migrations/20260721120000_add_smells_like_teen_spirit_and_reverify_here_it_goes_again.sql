-- Standard work-addition workflow v1:
-- 1. Add Nirvana — Smells Like Teen Spirit.
-- 2. Reverify the already-published OK Go — Here It Goes Again without duplicating it.
-- Unknown production and VFX credits remain NULL. No Technology relationship is
-- published without source-backed evidence.

begin;

create temporary table _mvhl_work_additions (
  slug text primary key,
  id uuid not null
) on commit drop;

do $$
declare
  v_count integer;
  v_id uuid;
  v_type_id bigint;
begin
  select id into v_type_id from public.work_types where code = 'music_video';
  if v_type_id is null then raise exception 'music_video work type is missing'; end if;

  select count(distinct w.id)
    into v_count
  from public.works w
  where w.slug = 'nirvana-smells-like-teen-spirit'
     or exists (
       select 1 from public.media_assets ma
       where ma.work_id = w.id and ma.platform = 'youtube' and ma.external_id = 'hTWKbfoikeg'
     );
  if v_count > 1 then raise exception 'Duplicate candidates found for Smells Like Teen Spirit'; end if;
  if v_count = 1 then
    select w.id into v_id
    from public.works w
    where w.slug = 'nirvana-smells-like-teen-spirit'
       or exists (
         select 1 from public.media_assets ma
         where ma.work_id = w.id and ma.platform = 'youtube' and ma.external_id = 'hTWKbfoikeg'
       )
    limit 1;
  end if;
  if v_count = 0 then
    insert into public.works (
      work_type_id, slug, title, original_title, release_year, country_code,
      language_code, status, is_canonical, verification_notes
    ) values (
      v_type_id, 'nirvana-smells-like-teen-spirit', 'Smells Like Teen Spirit',
      'Smells Like Teen Spirit', 1991, 'US', 'en', 'researching', false,
      'Standard work-addition workflow v1. Unknown production, VFX and unverified crew fields remain NULL.'
    ) returning id into v_id;
  end if;
  insert into _mvhl_work_additions values ('nirvana-smells-like-teen-spirit', v_id);

  select count(distinct w.id)
    into v_count
  from public.works w
  where w.slug = 'ok-go-here-it-goes-again'
     or exists (
       select 1 from public.media_assets ma
       where ma.work_id = w.id and ma.platform = 'youtube' and ma.external_id = 'dTAAsCNK7RA'
     );
  if v_count <> 1 then raise exception 'Expected exactly one existing Here It Goes Again work, found %', v_count; end if;
  select w.id into v_id
  from public.works w
  where w.slug = 'ok-go-here-it-goes-again'
     or exists (
       select 1 from public.media_assets ma
       where ma.work_id = w.id and ma.platform = 'youtube' and ma.external_id = 'dTAAsCNK7RA'
     )
  limit 1;
  insert into _mvhl_work_additions values ('ok-go-here-it-goes-again', v_id);
end $$;

update public.works w set
  slug = 'nirvana-smells-like-teen-spirit', title = 'Smells Like Teen Spirit',
  original_title = 'Smells Like Teen Spirit', release_date = null, release_year = 1991,
  country_code = 'US', language_code = 'en', status = 'researching', is_canonical = false,
  verified_at = null, published_at = null,
  verification_notes = 'Standard work-addition workflow v1. Director, official media and bilingual editorial verified. Production company, VFX production, exact release date and unverified crew fields remain NULL. MTV VMA claims remain unresolved because no official result-level MTV archive was verified.'
where w.id = (select id from _mvhl_work_additions where slug = 'nirvana-smells-like-teen-spirit');

update public.works w set
  slug = 'ok-go-here-it-goes-again', title = 'Here It Goes Again',
  original_title = 'Here It Goes Again', release_date = null, release_year = 2006,
  country_code = 'US', language_code = 'en', status = 'researching', is_canonical = true,
  verified_at = null, published_at = null,
  verification_notes = 'Standard work-addition workflow v1 re-verification. Official media, directors, bilingual editorial and the 2007 GRAMMY result are verified. Production company and VFX production remain NULL. No Technology relationship is assigned.'
where w.id = (select id from _mvhl_work_additions where slug = 'ok-go-here-it-goes-again');

insert into public.entities (slug, display_name, entity_type, country_code, official_url) values
  ('nirvana', 'Nirvana', 'band', 'US', 'https://www.nirvana.com/'),
  ('samuel-bayer', 'Samuel Bayer', 'person', 'US', 'https://samuelbayer.com/'),
  ('ok-go', 'OK Go', 'band', 'US', 'https://okgo.net/'),
  ('damian-kulash-jr', 'Damian Kulash Jr.', 'person', 'US', 'https://okgo.net/'),
  ('trish-sie', 'Trish Sie', 'person', 'US', null)
on conflict (slug) do update set
  display_name = excluded.display_name,
  entity_type = excluded.entity_type,
  country_code = coalesce(public.entities.country_code, excluded.country_code),
  official_url = coalesce(public.entities.official_url, excluded.official_url);

insert into public.music_video_details (work_id, label, album, runtime_seconds, official_release_url)
select id, 'DGC Records', 'Nevermind', 278, 'https://www.youtube.com/watch?v=hTWKbfoikeg'
from _mvhl_work_additions where slug = 'nirvana-smells-like-teen-spirit'
on conflict (work_id) do update set
  label = excluded.label, album = excluded.album, runtime_seconds = excluded.runtime_seconds,
  official_release_url = excluded.official_release_url;

insert into public.music_video_details (work_id, label, album, runtime_seconds, official_release_url)
select id, 'Capitol', 'Oh No', 186, 'https://www.youtube.com/watch?v=dTAAsCNK7RA'
from _mvhl_work_additions where slug = 'ok-go-here-it-goes-again'
on conflict (work_id) do update set
  label = excluded.label, album = excluded.album, runtime_seconds = excluded.runtime_seconds,
  official_release_url = excluded.official_release_url;

insert into public.work_credits (work_id, entity_id, role_id, credit_order, verification_status, notes)
select t.id, e.id, r.id, d.credit_order, 'verified', d.notes
from _mvhl_work_additions t
join (values
  ('nirvana-smells-like-teen-spirit', 'nirvana', 'artist', 1, 'Official Nirvana video and artist archive.'),
  ('nirvana-smells-like-teen-spirit', 'samuel-bayer', 'director', 1, 'Confirmed by Samuel Bayer’s official biography and independent interview.'),
  ('ok-go-here-it-goes-again', 'ok-go', 'artist', 1, 'Official OK Go video and artist archive.'),
  ('ok-go-here-it-goes-again', 'damian-kulash-jr', 'director', 1, 'Existing verified credit, reconfirmed through the Recording Academy result.'),
  ('ok-go-here-it-goes-again', 'trish-sie', 'director', 2, 'Existing verified credit, reconfirmed through the Recording Academy result.')
) d(work_slug, entity_slug, role_code, credit_order, notes) on d.work_slug = t.slug
join public.entities e on e.slug = d.entity_slug
join public.credit_roles r on r.code = d.role_code
on conflict (work_id, entity_id, role_id) do update set
  credit_order = excluded.credit_order, verification_status = 'verified', notes = excluded.notes;

insert into public.work_editorials (
  work_id, locale, short_summary, why_it_matters, historical_context,
  key_innovation, editorial_notes, verification_status, reviewed_at
)
select t.id, d.locale, d.short_summary, d.why_it_matters, d.historical_context,
  d.key_innovation, d.editorial_notes, 'verified', now()
from _mvhl_work_additions t
join (values
  ('nirvana-smells-like-teen-spirit', 'ja',
   '薄暗い高校体育館のペップラリーで演奏が始まり、無表情の観客、アナーキー記号のチアリーダー、清掃員を挟みながら、会場が破壊的な混乱へ移行するパフォーマンス映像。',
   'オルタナティブ・ロックの反商業的な身振りを、MTVで反復可能な強い映像記号へ変換し、楽曲とバンドの急速な大衆化に不可分の役割を果たした。',
   '1991年の『Nevermind』期に発表され、MTVで高頻度に放映された。本作はSamuel Bayerの初監督MVで、学校行事が崩壊する一つの場面にバンド演奏と若者の疎外・反抗を集約している。',
   '固定的なペップラリーの構図を、楽曲の強弱に合わせた照明、切り返し、身体の密度の増加によって変形し、演奏と観客の混乱を同じリズムの上で接続した。',
   'Acquisition reason: a canonical performance-film example whose formal escalation is inseparable from its historical circulation.'),
  ('nirvana-smells-like-teen-spirit', 'en',
   'A performance staged as a dim high-school pep rally, moving from restrained spectators, anarchist cheerleaders and a janitor to destructive collective release.',
   'It translated alternative rock’s anti-commercial posture into forceful images legible through repeated MTV broadcast, becoming inseparable from the song’s and band’s rapid mass visibility.',
   'Released in 1991 during the Nevermind campaign and placed in heavy MTV rotation, the work was Samuel Bayer’s first music-video direction. It condenses band performance and youth alienation into a single school event that progressively breaks down.',
   'The fixed pep-rally premise is transformed through lighting, cutting and increasing bodily density aligned to the song’s dynamic shifts, joining band performance and crowd disorder within the same rhythmic escalation.',
   'Acquisition reason: a canonical performance-film example whose formal escalation is inseparable from its historical circulation.'),
  ('ok-go-here-it-goes-again', 'ja',
   '4人のメンバーと8台のトレッドミルによる振付を、固定された正面視点のワンテイクで見せる作品。',
   '小規模な制作条件、明快な身体的発想、オンラインでの流通が結びつき、2000年代のMVがテレビ放送とは異なる経路で世界規模の観客へ届く可能性を示した。',
   '2006年に公開され、YouTube時代初期の代表的MVとなった。翌年、第49回グラミー賞のBest Music Videoを受賞し、OK Goの映像制作を継続的な創作実践として定着させた。',
   'カメラを固定し、装置を隠さず、位置・速度・乗り換えを一続きの身体振付として構成することで、編集やVFXに依存しない視覚的な複雑さを作った。',
   'Reverified under the standard work-addition workflow; existing Canon editorial retained and normalized.'),
  ('ok-go-here-it-goes-again', 'en',
   'Four band members perform with eight treadmills in a single continuous frontal view.',
   'Its modest production conditions, clear physical premise and online circulation demonstrated how a music video could reach a global audience through routes distinct from television broadcast.',
   'Released in 2006, it became an emblematic early-YouTube music video. Its Best Music Video win at the 49th GRAMMY Awards helped establish video-making as a sustained part of OK Go’s creative practice.',
   'A locked camera, visible apparatus and choreography built from position, speed and transfers create visual complexity without relying on editing or VFX.',
   'Reverified under the standard work-addition workflow; existing Canon editorial retained and normalized.')
) d(work_slug, locale, short_summary, why_it_matters, historical_context, key_innovation, editorial_notes)
  on d.work_slug = t.slug
on conflict (work_id, locale) do update set
  short_summary = excluded.short_summary, why_it_matters = excluded.why_it_matters,
  historical_context = excluded.historical_context, key_innovation = excluded.key_innovation,
  editorial_notes = excluded.editorial_notes, verification_status = 'verified', reviewed_at = excluded.reviewed_at;

insert into public.media_assets (
  work_id, platform, asset_type, external_id, url, is_official, availability_status, last_checked_at
)
select t.id, 'youtube', 'full_video', d.youtube_id, d.url, true, 'available', now()
from _mvhl_work_additions t
join (values
  ('nirvana-smells-like-teen-spirit', 'hTWKbfoikeg', 'https://www.youtube.com/watch?v=hTWKbfoikeg'),
  ('ok-go-here-it-goes-again', 'dTAAsCNK7RA', 'https://www.youtube.com/watch?v=dTAAsCNK7RA')
) d(work_slug, youtube_id, url) on d.work_slug = t.slug
on conflict (platform, external_id) where external_id is not null do update set
  work_id = excluded.work_id, url = excluded.url, is_official = true,
  availability_status = 'available', last_checked_at = excluded.last_checked_at;

insert into public.media_assets (
  work_id, platform, asset_type, external_id, url, is_official, availability_status, last_checked_at
)
select t.id, 'youtube', 'thumbnail', null, d.url, true, 'available', now()
from _mvhl_work_additions t
join (values
  ('nirvana-smells-like-teen-spirit', 'https://i.ytimg.com/vi/hTWKbfoikeg/maxresdefault.jpg'),
  ('ok-go-here-it-goes-again', 'https://i.ytimg.com/vi/dTAAsCNK7RA/maxresdefault.jpg')
) d(work_slug, url) on d.work_slug = t.slug
on conflict (work_id, url) do update set
  is_official = true, availability_status = 'available', last_checked_at = excluded.last_checked_at;

insert into public.sources (source_type, title, publisher, url, accessed_at, notes) values
  ('official_video', 'Nirvana - Smells Like Teen Spirit (Official Music Video)', 'Nirvana / YouTube', 'https://www.youtube.com/watch?v=hTWKbfoikeg', current_date, 'Official artist-channel upload; title, artist, runtime, media ID and thumbnail verified.'),
  ('official_video', 'Nirvana — Smells Like Teen Spirit official video', 'Nirvana', 'https://www.nirvana.com/video/nirvana-smells-like-teen-spirit-official-music-video/', current_date, 'Official artist archive confirming the work and official video.'),
  ('artist_official', 'Nirvana timeline', 'Nirvana', 'https://www.nirvana.com/timelines/', current_date, 'Official artist timeline for 1991 release context and MTV circulation.'),
  ('director_portfolio', 'About Samuel Bayer', 'Samuel Bayer', 'https://samuelbayer.com/about-me/', current_date, 'Official director biography confirming his directorial debut with the work.'),
  ('publication', 'Samuel Bayer', 'Interview Magazine', 'https://www.interviewmagazine.com/art/samuel-bayer/', current_date, 'Independent interview confirming the work as Bayer’s first music video.'),
  ('publication', 'Smells Like Nirvana', 'Recording Academy', 'https://www.grammy.com/news/smells-like-nirvana/?quicktabs_featured_news=1', current_date, 'Recording Academy editorial for historical context; recording nominations are not stored as video awards.'),
  ('award_archive', 'Sidelines, September 10, 1992', 'Middle Tennessee State University Digital Collections', 'https://digital.mtsu.edu/digital/api/collection/sidelines/id/17775/download', current_date, 'Contemporary VMA coverage reviewed. Without an official MTV result-level archive, the reported video wins remain unresolved and are not registered.'),
  ('official_video', 'OK Go - Here It Goes Again (Official Music Video)', 'OK Go / YouTube', 'https://www.youtube.com/watch?v=dTAAsCNK7RA', current_date, 'Official artist-channel upload; title, artist, runtime, media ID and thumbnail verified.'),
  ('artist_official', 'Here It Goes Again — Official Video', 'OK Go', 'https://okgo.net/2006/07/31/here-it-goes-again-official-video/', current_date, 'Official artist archive confirming the title and 2006 release context.'),
  ('award_archive', 'OK Go — GRAMMY Awards and Nominations', 'Recording Academy', 'https://www.grammy.com/artists/ok-go/17689/', current_date, 'Official result-level source for the 2007 Best Music Video win.'),
  ('award_archive', 'Trish Sie — GRAMMY Awards and Nominations', 'Recording Academy', 'https://www.grammy.com/artists/trish-sie/6352/', current_date, 'Official result-level source supporting Trish Sie’s association with the winning work.'),
  ('publication', 'How OK Go Has Revolutionized the Music Video', 'Smithsonian Magazine', 'https://www.smithsonianmag.com/videos/how-ok-go-has-revolutionized-the-music-video/', current_date, 'Institutional editorial source for historical context.'),
  ('label', 'Here It Goes Again', 'Official Charts', 'https://www.officialcharts.com/songs/ok-go-here-it-goes-again/', current_date, 'Official chart archive for title, year and label context.')
on conflict (url) do update set
  source_type = excluded.source_type, title = excluded.title, publisher = excluded.publisher,
  accessed_at = excluded.accessed_at, notes = excluded.notes;

insert into public.work_sources (work_id, source_id, supports_fields, is_primary, notes)
select t.id, s.id, d.fields, d.is_primary, d.notes
from _mvhl_work_additions t
join (values
  ('nirvana-smells-like-teen-spirit', 'https://www.youtube.com/watch?v=hTWKbfoikeg', array['official_title','artist','runtime','youtube_id','thumbnail','visual_analysis']::text[], true, 'Official video identity and formal-analysis source.'),
  ('nirvana-smells-like-teen-spirit', 'https://www.nirvana.com/video/nirvana-smells-like-teen-spirit-official-music-video/', array['official_video_identity']::text[], true, 'Official artist archive.'),
  ('nirvana-smells-like-teen-spirit', 'https://www.nirvana.com/timelines/', array['release_year','historical_context','mtv_circulation']::text[], true, 'Official artist timeline.'),
  ('nirvana-smells-like-teen-spirit', 'https://samuelbayer.com/about-me/', array['director','director_debut']::text[], true, 'Official director biography.'),
  ('nirvana-smells-like-teen-spirit', 'https://www.interviewmagazine.com/art/samuel-bayer/', array['director','director_debut']::text[], false, 'Independent director interview.'),
  ('nirvana-smells-like-teen-spirit', 'https://www.grammy.com/news/smells-like-nirvana/?quicktabs_featured_news=1', array['historical_context','excluded_recording_awards']::text[], false, 'Recording Academy context; no video award registered.'),
  ('nirvana-smells-like-teen-spirit', 'https://digital.mtsu.edu/digital/api/collection/sidelines/id/17775/download', array['award_audit']::text[], false, 'Contemporary coverage retained as unresolved audit evidence only.'),
  ('ok-go-here-it-goes-again', 'https://www.youtube.com/watch?v=dTAAsCNK7RA', array['official_title','artist','runtime','youtube_id','thumbnail','visual_analysis']::text[], true, 'Official video identity and formal-analysis source.'),
  ('ok-go-here-it-goes-again', 'https://okgo.net/2006/07/31/here-it-goes-again-official-video/', array['official_title','release_year']::text[], true, 'Official artist archive.'),
  ('ok-go-here-it-goes-again', 'https://www.grammy.com/artists/ok-go/17689/', array['director','award_program','award_year','award_category','award_outcome']::text[], true, 'Official result-level source.'),
  ('ok-go-here-it-goes-again', 'https://www.grammy.com/artists/trish-sie/6352/', array['director','award_outcome']::text[], true, 'Official result-level source.'),
  ('ok-go-here-it-goes-again', 'https://www.smithsonianmag.com/videos/how-ok-go-has-revolutionized-the-music-video/', array['historical_context']::text[], false, 'Institutional editorial source.'),
  ('ok-go-here-it-goes-again', 'https://www.officialcharts.com/songs/ok-go-here-it-goes-again/', array['label','release_year']::text[], false, 'Official chart archive.')
) d(work_slug, source_url, fields, is_primary, notes) on d.work_slug = t.slug
join public.sources s on s.url = d.source_url
on conflict (work_id, source_id) do update set
  supports_fields = excluded.supports_fields, is_primary = excluded.is_primary, notes = excluded.notes;

insert into public.taxonomy_terms (category_id, slug, name)
select c.id, d.slug, d.name
from public.taxonomy_categories c
join (values
  ('genre','alternative-rock','Alternative Rock'),
  ('region','international','International'),
  ('era','1990s','1990s'),
  ('era','2000s','2000s'),
  ('movement','one-take','One Take')
) d(category_code, slug, name) on d.category_code = c.code
on conflict (category_id, slug) do update set name = excluded.name;

insert into public.work_taxonomy_terms (work_id, term_id, confidence, assignment_method, notes)
select t.id, tt.id, 1.000, 'editorial', 'Verified standard work-addition classification.'
from _mvhl_work_additions t
join (values
  ('nirvana-smells-like-teen-spirit','alternative-rock'),
  ('nirvana-smells-like-teen-spirit','international'),
  ('nirvana-smells-like-teen-spirit','1990s'),
  ('ok-go-here-it-goes-again','alternative-rock'),
  ('ok-go-here-it-goes-again','international'),
  ('ok-go-here-it-goes-again','2000s'),
  ('ok-go-here-it-goes-again','one-take')
) d(work_slug, term_slug) on d.work_slug = t.slug
join public.taxonomy_terms tt on tt.slug = d.term_slug
on conflict (work_id, term_id) do update set
  confidence = excluded.confidence, assignment_method = excluded.assignment_method, notes = excluded.notes;

-- A valid Technology review may result in zero published relationships.
delete from public.work_technologies wt
where wt.work_id in (select id from _mvhl_work_additions);

-- Keep only the deliberately selected, useful Visual Language paths.
delete from public.work_visual_languages wvl
where wvl.work_id = (select id from _mvhl_work_additions where slug = 'nirvana-smells-like-teen-spirit');
delete from public.work_visual_languages wvl
using public.visual_languages vl
where wvl.visual_language_id = vl.id
  and wvl.work_id = (select id from _mvhl_work_additions where slug = 'ok-go-here-it-goes-again')
  and vl.slug not in ('one-take','spatial-choreography');

insert into public.work_visual_languages (
  work_id, visual_language_id, prominence, relevance, relationship_role,
  is_primary, confidence, assignment_method, editorial_rationale,
  verification_status, verification_notes, note_ja, note_en, display_order, reviewed_at
)
select t.id, vl.id, d.prominence, d.relevance, d.role, d.is_primary, 1.000,
  'editorial', d.note_en, 'verified', 'Direct formal analysis of the official video.',
  d.note_ja, d.note_en, d.display_order, now()
from _mvhl_work_additions t
join (values
  ('nirvana-smells-like-teen-spirit','performance-film','primary','primary','defining_example',true,
   '高校のペップラリーという一つの状況に演奏、観客、チアリーダー、清掃員を集約し、会場の崩壊をパフォーマンスの強度として見せる。',
   'Band, spectators, cheerleaders and janitor are concentrated within one high-school pep rally, making the venue’s breakdown part of the performance’s force.',10),
  ('nirvana-smells-like-teen-spirit','rhythmic-editing','secondary','significant','notable_example',false,
   '静かな導入から激しいサビへ向かう楽曲の強弱に、切り返し、照明、群衆の密度を対応させ、混乱を段階的に増幅する。',
   'Cutting, lighting and crowd density follow the song’s dynamic shifts from restrained verses to explosive choruses, escalating disorder in stages.',20),
  ('ok-go-here-it-goes-again','one-take','primary','primary','defining_example',true,
   '固定された一続きの視点の中で、四人と八台のトレッドミルの位置、速度、乗り換えを振付として成立させる。',
   'Within one fixed continuous view, four performers and eight treadmills are choreographed through position, speed and transfers.',10),
  ('ok-go-here-it-goes-again','spatial-choreography','primary','primary','defining_example',true,
   'トレッドミルの二列配置と移動方向を身体の経路として用い、装置と演者を一つの運動システムへ統合する。',
   'Two rows of treadmills and their opposing directions become bodily pathways, integrating apparatus and performers into one movement system.',20)
) d(work_slug, concept_slug, prominence, relevance, role, is_primary, note_ja, note_en, display_order)
  on d.work_slug = t.slug
join public.visual_languages vl on vl.slug = d.concept_slug and vl.lifecycle_status = 'published' and vl.is_active
on conflict (work_id, visual_language_id) do update set
  prominence = excluded.prominence, relevance = excluded.relevance,
  relationship_role = excluded.relationship_role, is_primary = excluded.is_primary,
  confidence = excluded.confidence, assignment_method = excluded.assignment_method,
  editorial_rationale = excluded.editorial_rationale, verification_status = 'verified',
  verification_notes = excluded.verification_notes, note_ja = excluded.note_ja,
  note_en = excluded.note_en, display_order = excluded.display_order, reviewed_at = excluded.reviewed_at;

insert into public.work_visual_language_sources (
  work_visual_language_id, source_id, supports_fields, is_primary, notes
)
select wvl.id, s.id, array['visual_language']::text[], true, 'Official video used for direct formal analysis.'
from _mvhl_work_additions t
join public.work_visual_languages wvl on wvl.work_id = t.id
join public.sources s on s.url = case t.slug
  when 'nirvana-smells-like-teen-spirit' then 'https://www.youtube.com/watch?v=hTWKbfoikeg'
  else 'https://www.youtube.com/watch?v=dTAAsCNK7RA' end
on conflict (work_visual_language_id, source_id) do update set
  supports_fields = excluded.supports_fields, is_primary = excluded.is_primary, notes = excluded.notes;

insert into public.knowledge_graph_work_reviews (
  work_id, sprint, technology_outcome, visual_language_outcome,
  review_note_ja, review_note_en, deliberately_not_assigned,
  unresolved_questions, reviewed_at
)
select t.id, 'work-addition-standard-v1', 'none', 'assigned',
  d.note_ja, d.note_en, d.rejected, d.unresolved, now()
from _mvhl_work_additions t
join (values
  ('nirvana-smells-like-teen-spirit',
   '公式映像と監督資料を照合した。制作技術は根拠不足のため0件、探索に有効な映像言語2件だけを採用した。',
   'The official video and director sources were reviewed. No Technology relationship met the evidence threshold; only two useful Visual Language paths were retained.',
   array['Spatial Choreography: staged movement is present but not the most useful primary path.','Long-form Narrative: the work develops a performance situation rather than an extended narrative.','Steadicam: no authoritative production source verified the technology.']::text[],
   array['1992 MTV VMA claims remain unresolved without an official result-level MTV archive.']::text[]),
  ('ok-go-here-it-goes-again',
   '既存公開作品を標準ワークフローで再検証した。制作技術は0件のまま、ワンテイクと空間振付の2関係を維持した。',
   'The published work was reverified under the standard workflow. Technology remains a valid zero-result review; One Take and Spatial Choreography were preserved.',
   array['Dance Camera: the locked camera records rather than actively partners the dance.','Performance Film: redundant beside the two more precise navigation paths.']::text[],
   array[]::text[])
) d(work_slug, note_ja, note_en, rejected, unresolved) on d.work_slug = t.slug
on conflict (work_id) do update set
  sprint = excluded.sprint, technology_outcome = excluded.technology_outcome,
  visual_language_outcome = excluded.visual_language_outcome,
  review_note_ja = excluded.review_note_ja, review_note_en = excluded.review_note_en,
  deliberately_not_assigned = excluded.deliberately_not_assigned,
  unresolved_questions = excluded.unresolved_questions, reviewed_at = excluded.reviewed_at;

-- Do not register unresolved Nirvana award claims.
delete from public.work_award_results
where work_id = (select id from _mvhl_work_additions where slug = 'nirvana-smells-like-teen-spirit');

insert into public.award_categories (
  award_id, slug, name, official_name, normalized_name, category_type, valid_from_year, valid_to_year
)
select id, 'best-music-video', 'Best Music Video', 'Best Music Video',
  'Best Music Video', 'overall_video', 2007, 2007
from public.awards where slug = 'grammy-awards'
on conflict (award_id, slug) do update set
  name = excluded.name, official_name = excluded.official_name,
  normalized_name = excluded.normalized_name, category_type = excluded.category_type;

insert into public.work_award_results (
  work_id, award_id, award_category_id, award_year, result,
  credited_name_text, source_id, verification_status, verification_notes
)
select t.id, a.id, c.id, 2007, 'winner', 'OK Go / Damian Kulash Jr. / Trish Sie',
  s.id, 'verified', 'Official Recording Academy result: winner.'
from _mvhl_work_additions t
join public.awards a on a.slug = 'grammy-awards'
join public.award_categories c on c.award_id = a.id and c.slug = 'best-music-video'
join public.sources s on s.url = 'https://www.grammy.com/artists/ok-go/17689/'
where t.slug = 'ok-go-here-it-goes-again'
on conflict (work_id, award_category_id, award_year, result) do update set
  award_id = excluded.award_id, credited_name_text = excluded.credited_name_text,
  source_id = excluded.source_id, verification_status = 'verified', verification_notes = excluded.verification_notes;

do $$
declare
  n_id uuid := (select id from _mvhl_work_additions where slug = 'nirvana-smells-like-teen-spirit');
  o_id uuid := (select id from _mvhl_work_additions where slug = 'ok-go-here-it-goes-again');
begin
  if (select count(*) from public.work_editorials where work_id in (n_id,o_id) and locale in ('ja','en') and verification_status = 'verified') <> 4 then
    raise exception 'Bilingual verified editorial is incomplete';
  end if;
  if exists (select 1 from public.work_technologies where work_id in (n_id,o_id) and verification_status = 'verified') then
    raise exception 'No verified Technology relationship is expected for either work';
  end if;
  if (select count(*) from public.work_visual_languages where work_id = n_id and verification_status = 'verified') <> 2 then
    raise exception 'Expected exactly two verified Nirvana Visual Language relationships';
  end if;
  if (select count(*) from public.work_visual_languages where work_id = o_id and verification_status = 'verified') <> 2 then
    raise exception 'Expected exactly two verified OK Go Visual Language relationships';
  end if;
  if exists (
    select 1 from public.work_visual_languages wvl
    where wvl.work_id in (n_id,o_id) and wvl.verification_status = 'verified'
      and not exists (select 1 from public.work_visual_language_sources s where s.work_visual_language_id = wvl.id)
  ) then raise exception 'Every verified Visual Language relationship requires a stored source'; end if;
  if (select count(*) from public.work_sources where work_id = n_id) < 5
     or (select count(*) from public.work_sources where work_id = o_id) < 5 then
    raise exception 'Insufficient source coverage';
  end if;
  if exists (select 1 from public.work_award_results where work_id = n_id) then
    raise exception 'Unresolved Nirvana award claims must not be registered';
  end if;
  if (select count(*) from public.work_award_results where work_id = o_id and verification_status = 'verified') <> 1 then
    raise exception 'Expected exactly one verified OK Go video award result';
  end if;
  if not exists (select 1 from public.media_assets where work_id = n_id and external_id = 'hTWKbfoikeg' and availability_status = 'available')
     or not exists (select 1 from public.media_assets where work_id = o_id and external_id = 'dTAAsCNK7RA' and availability_status = 'available') then
    raise exception 'Official video media is incomplete';
  end if;
end $$;

update public.works set status = 'verified', verified_at = now(), last_reviewed_at = now()
where id in (select id from _mvhl_work_additions);

update public.works set status = 'published', published_at = now()
where id in (select id from _mvhl_work_additions) and status = 'verified' and verified_at is not null;

do $$
begin
  if (select count(*) from public.works where id in (select id from _mvhl_work_additions) and status = 'published') <> 2 then
    raise exception 'Publication gate did not complete for both works';
  end if;
end $$;

commit;
