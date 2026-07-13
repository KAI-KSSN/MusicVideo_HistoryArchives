-- MVHL Knowledge Graph Sprint 1
-- Source-backed, deliberately small relationship set for the 10 pilot works.
-- Lemon and One Last Kiss were reviewed but intentionally receive no graph
-- edges in this sprint because no useful classification met the evidence bar.

begin;

insert into public.sources (source_type, title, publisher, url, accessed_at, notes)
values
  ('label', 'a-ha reaches one billion views with Take On Me', 'Warner Music Norway',
   'https://www.mynewsdesk.com/no/wmgno/pressreleases/a-ha-naar-en-milliard-visninger-med-take-on-me-2973845',
   current_date, 'Warner Music describes the frame-by-frame rotoscoping process.'),
  ('publication', 'Virtual Insanity', 'VideoStatic',
   'https://www.videostatic.com/virtual-insanity', current_date,
   'Production explanation based on an interview with director Jonathan Glazer; distinguishes the fixed floor from the moving set and camera relationship.'),
  ('publication', 'Beyoncé Music Video Evolution: 5 Cinematography Lessons', 'New York Film Academy',
   'https://www.nyfa.edu/student-resources/beyonce-music-video-evolution-5-cinematography-lessons/', current_date,
   'Describes the limited cuts and continuous-take construction of Single Ladies.'),
  ('publication', 'Music Video: Childish Gambino — This Is America', 'Post Magazine',
   'https://www.postmagazine.com/Press-Center/Daily-News/2019/Music-Video-Childish-Gambino-I-This-is-America-I.aspx', current_date,
   'Editor interview describing long Steadicam shots and combined takes.'),
  ('publication', 'DP Larkin Seiple Breaks Down Every Shot from Childish Gambino’s This Is America', 'Filmmaker Magazine',
   'https://filmmakermagazine.com/105396-dp-larkin-seiple-breaks-down-every-shot-from-childish-gambinos-this-is-america/', current_date,
   'Cinematographer account of six Steadicam tracking shots.'),
  ('publication', 'Bonded by Friendship and Film: Hiro Murai and Larkin Seiple', 'Kodak',
   'https://www.kodak.com/en/motion/blog-post/hiro-murai-larkin-seiple/', current_date,
   'Production interview naming the Steadicam operator and long takes.'),
  ('production_company', 'Jamiroquai - Virtual Insanity', 'Academy Films',
   'https://usa.academyfilms.com/portfolio/jamiroquai-virtual-insanity-1', current_date,
   'Production-company portfolio entry for the official work.')
on conflict (url) do update set
  source_type = excluded.source_type,
  title = excluded.title,
  publisher = excluded.publisher,
  accessed_at = excluded.accessed_at,
  notes = excluded.notes;

-- Ensure newly added evidence is also attached to the relevant published work.
insert into public.work_sources (work_id, source_id, supports_fields, is_primary, notes)
select w.id, s.id, d.supports_fields, false, d.notes
from (values
  ('a-ha-take-on-me', 'https://www.mynewsdesk.com/no/wmgno/pressreleases/a-ha-naar-en-milliard-visninger-med-take-on-me-2973845', array['technology']::text[], 'Rotoscoping evidence.'),
  ('jamiroquai-virtual-insanity', 'https://www.videostatic.com/virtual-insanity', array['visual_language']::text[], 'Set and camera construction evidence.'),
  ('jamiroquai-virtual-insanity', 'https://usa.academyfilms.com/portfolio/jamiroquai-virtual-insanity-1', array['visual_language']::text[], 'Production-company portfolio.'),
  ('beyonce-single-ladies', 'https://www.nyfa.edu/student-resources/beyonce-music-video-evolution-5-cinematography-lessons/', array['visual_language']::text[], 'Continuous-shot construction evidence.'),
  ('childish-gambino-this-is-america', 'https://www.postmagazine.com/Press-Center/Daily-News/2019/Music-Video-Childish-Gambino-I-This-is-America-I.aspx', array['technology','visual_language']::text[], 'Editing and camera-movement evidence.'),
  ('childish-gambino-this-is-america', 'https://filmmakermagazine.com/105396-dp-larkin-seiple-breaks-down-every-shot-from-childish-gambinos-this-is-america/', array['technology','visual_language']::text[], 'Cinematographer technical breakdown.'),
  ('childish-gambino-this-is-america', 'https://www.kodak.com/en/motion/blog-post/hiro-murai-larkin-seiple/', array['technology']::text[], 'Production interview and Steadicam credit.')
) as d(work_slug, source_url, supports_fields, notes)
join public.works w on w.slug = d.work_slug
join public.sources s on s.url = d.source_url
on conflict (work_id, source_id) do update set
  supports_fields = (
    select array_agg(distinct value order by value)
    from unnest(work_sources.supports_fields || excluded.supports_fields) value
  ),
  notes = excluded.notes;

-- Technology relationships: only techniques explicitly supported by production evidence.
insert into public.work_technologies (
  work_id, technology_id, usage_role, relevance, relationship_role,
  is_primary, confidence, assignment_method, verification_status,
  note_ja, note_en, display_order, reviewed_at
)
select
  w.id, t.id, d.usage_role, d.relevance, d.relationship_role,
  d.is_primary, d.confidence, 'editorial', 'verified',
  d.note_ja, d.note_en, d.display_order, now()
from (values
  ('a-ha-take-on-me', 'rotoscoping', 'primary', 'primary', 'defining_use', true, 1.000::numeric,
   '実写の動きを一コマずつ描き起こすロトスコープが、実写世界と鉛筆画の世界を接続する中心技術として使われている。',
   'Frame-by-frame rotoscoping is the central process connecting the live-action and pencil-drawn worlds.', 10),
  ('childish-gambino-this-is-america', 'steadicam', 'primary', 'significant', 'defining_use', true, 1.000::numeric,
   '長いステディカム移動が、演者のダンスと背景で進行する出来事を同じ空間内で連続的に追う。',
   'Long Steadicam movements hold the dance and the events unfolding in the background within one continuous spatial field.', 10)
) as d(work_slug, technology_slug, usage_role, relevance, relationship_role, is_primary, confidence, note_ja, note_en, display_order)
join public.works w on w.slug = d.work_slug
join public.technologies t on t.slug = d.technology_slug
on conflict (work_id, technology_id) do update set
  usage_role = excluded.usage_role,
  relevance = excluded.relevance,
  relationship_role = excluded.relationship_role,
  is_primary = excluded.is_primary,
  confidence = excluded.confidence,
  assignment_method = excluded.assignment_method,
  verification_status = excluded.verification_status,
  note_ja = excluded.note_ja,
  note_en = excluded.note_en,
  display_order = excluded.display_order,
  reviewed_at = excluded.reviewed_at;

-- Visual-language relationships: formal observations are sourced to the
-- official video; production sources are added where a construction claim is made.
insert into public.work_visual_languages (
  work_id, visual_language_id, prominence, relevance, relationship_role,
  is_primary, confidence, assignment_method, editorial_rationale,
  verification_status, note_ja, note_en, display_order, reviewed_at
)
select
  w.id, vl.id,
  case when d.is_primary then 'primary' else 'secondary' end,
  d.relevance, d.relationship_role, d.is_primary, d.confidence,
  'editorial', d.note_en, 'verified', d.note_ja, d.note_en,
  d.display_order, now()
from (values
  ('michael-jackson-thriller', 'long-form-narrative', 'primary', 'defining_example', true, 1.000::numeric,
   '楽曲の前後にドラマ場面を展開し、MVを長編の物語形式へ拡張している。',
   'Dramatic scenes before and around the song extend the music video into a long-form narrative.', 10),
  ('michael-jackson-thriller', 'dance-camera', 'significant', 'defining_example', true, 1.000::numeric,
   'カメラの距離と移動がゾンビ群舞の隊形変化に合わせて組み立てられている。',
   'Camera distance and movement are organized around the changing formations of the zombie choreography.', 20),
  ('michael-jackson-thriller', 'performance-film', 'significant', 'defining_example', false, 0.980::numeric,
   '物語の内部に大規模なダンスパフォーマンスを主要場面として組み込んでいる。',
   'A large-scale dance performance is embedded as a central scene within the narrative.', 30),

  ('a-ha-take-on-me', 'mixed-media', 'primary', 'defining_example', true, 1.000::numeric,
   '実写と鉛筆画アニメーションを明確に異なる世界として組み合わせる。',
   'Live action and pencil-drawn animation are combined as visibly distinct worlds.', 10),
  ('a-ha-take-on-me', 'continuous-transformation', 'significant', 'defining_example', true, 1.000::numeric,
   '人物と空間が実写と描画の状態を往復しながら連続的に変容する。',
   'Figures and spaces transform continuously between live-action and drawn states.', 20),

  ('jamiroquai-virtual-insanity', 'optical-illusion', 'primary', 'defining_example', true, 1.000::numeric,
   '床ではなく、カメラと壁面セットの相対運動によって空間が滑るような錯視を作る。',
   'Relative movement between the camera and mobile wall set, rather than a moving floor, creates the sliding-space illusion.', 10),
  ('jamiroquai-virtual-insanity', 'spatial-choreography', 'primary', 'defining_example', true, 1.000::numeric,
   '演者、家具、可動壁、カメラの位置関係そのものが振付として設計されている。',
   'The performer, furniture, moving walls and camera are choreographed as one spatial system.', 20),
  ('jamiroquai-virtual-insanity', 'dance-camera', 'significant', 'defining_example', false, 1.000::numeric,
   'カメラとセットの移動が、Jay Kayの身体運動に対する動的な舞台を形成する。',
   'Camera and set movement create a dynamic stage in direct relation to Jay Kay’s dancing.', 30),
  ('jamiroquai-virtual-insanity', 'continuous-shot-illusion', 'significant', 'notable_example', false, 0.950::numeric,
   '編集点を抑えた長い区間が、空間変化を一続きの出来事として知覚させる。',
   'Extended sections with restrained cutting make the spatial changes read as a continuous event.', 40),

  ('daft-punk-around-the-world', 'spatial-choreography', 'primary', 'defining_example', true, 1.000::numeric,
   '異なる演者群が音楽パートに対応し、円形舞台上を連動して移動する。',
   'Distinct performer groups correspond to musical parts and move as a coordinated system on a circular stage.', 10),
  ('daft-punk-around-the-world', 'graphic-composition', 'primary', 'defining_example', true, 1.000::numeric,
   '色、衣装、段差、反復隊形を明快なグラフィック構成として整理する。',
   'Color, costume, levels and repeated formations are organized as a clear graphic composition.', 20),
  ('daft-punk-around-the-world', 'performance-film', 'significant', 'defining_example', false, 1.000::numeric,
   '物語よりも、振付と音楽構造の可視化を中心に全編を構成している。',
   'The work is structured around choreography and the visualization of musical form rather than plot.', 30),
  ('daft-punk-around-the-world', 'loop', 'significant', 'notable_example', false, 0.980::numeric,
   '円運動と反復動作を、音楽の循環構造に対応する視覚単位として用いる。',
   'Circular paths and repeated gestures function as visual units corresponding to the music’s cyclic structure.', 40),

  ('beyonce-single-ladies', 'dance-camera', 'primary', 'defining_example', true, 1.000::numeric,
   'カメラの距離、パン、移動が三人の振付と密接に同期する。',
   'Camera distance, pans and movement are tightly synchronized with the three-performer choreography.', 10),
  ('beyonce-single-ladies', 'minimal-performance', 'primary', 'defining_example', true, 1.000::numeric,
   '限定された空間、出演者、色彩によって身体表現を前景化する。',
   'A restricted space, cast and palette place bodily performance at the foreground.', 20),
  ('beyonce-single-ladies', 'spatial-choreography', 'significant', 'defining_example', false, 1.000::numeric,
   '三人の位置関係とフォーメーション変化が画面全体の構図を作る。',
   'The performers’ spacing and formation changes generate the composition of the frame.', 30),
  ('beyonce-single-ladies', 'continuous-shot-illusion', 'significant', 'defining_example', false, 0.950::numeric,
   '少数の編集点を隠し、ほぼ一続きのダンスパフォーマンスとして見せる。',
   'A small number of edits are concealed so the dance reads as an almost uninterrupted performance.', 40),

  ('fatboy-slim-weapon-of-choice', 'performance-film', 'primary', 'defining_example', true, 1.000::numeric,
   'ホテルロビーを舞台に、一人の身体パフォーマンスを作品全体の中心に置く。',
   'A solo bodily performance in a hotel lobby forms the center of the entire work.', 10),
  ('fatboy-slim-weapon-of-choice', 'dance-camera', 'significant', 'defining_example', true, 1.000::numeric,
   'カメラが演者の移動、跳躍、静止に応じて距離と方向を変化させる。',
   'The camera changes distance and direction in response to the performer’s movement, leaps and pauses.', 20),
  ('fatboy-slim-weapon-of-choice', 'spatial-choreography', 'significant', 'notable_example', false, 1.000::numeric,
   '階段、廊下、手すり、吹き抜けを、ダンスの経路として組み込む。',
   'Stairs, corridors, rails and the atrium are incorporated as pathways for the choreography.', 30),

  ('childish-gambino-this-is-america', 'continuous-shot-illusion', 'primary', 'defining_example', true, 1.000::numeric,
   '複数の長いステディカムショットをパンや合成で接続し、連続する出来事として構成する。',
   'Multiple long Steadicam shots are joined through pans and combined takes to construct a continuous event.', 10),
  ('childish-gambino-this-is-america', 'dance-camera', 'significant', 'defining_example', true, 1.000::numeric,
   '前景のダンスと背景の出来事を、移動するカメラが同一の時間と空間に保持する。',
   'The moving camera holds foreground dance and background events within the same time and space.', 20),
  ('childish-gambino-this-is-america', 'spatial-choreography', 'significant', 'defining_example', false, 1.000::numeric,
   '演者、子どもたち、車両、群衆が倉庫空間を横断しながら多層の行動を形成する。',
   'Performers, children, vehicles and crowds form layered actions while crossing the warehouse space.', 30),

  ('sakanaction-shin-takarajima', 'performance-film', 'primary', 'notable_example', true, 1.000::numeric,
   'テレビ番組風のセットと進行の中で、バンド演奏を中心に構成する。',
   'The work centers the band performance within a staged television-program format.', 10),
  ('sakanaction-shin-takarajima', 'graphic-composition', 'significant', 'notable_example', false, 1.000::numeric,
   '正面性の強いセット、字幕、色面、反復ポーズを図案的に配置する。',
   'Frontal sets, captions, color fields and repeated poses are arranged in a strongly graphic manner.', 20)
) as d(work_slug, visual_language_slug, relevance, relationship_role, is_primary, confidence, note_ja, note_en, display_order)
join public.works w on w.slug = d.work_slug
join public.visual_languages vl on vl.slug = d.visual_language_slug
on conflict (work_id, visual_language_id) do update set
  prominence = excluded.prominence,
  relevance = excluded.relevance,
  relationship_role = excluded.relationship_role,
  is_primary = excluded.is_primary,
  confidence = excluded.confidence,
  assignment_method = excluded.assignment_method,
  editorial_rationale = excluded.editorial_rationale,
  verification_status = excluded.verification_status,
  note_ja = excluded.note_ja,
  note_en = excluded.note_en,
  display_order = excluded.display_order,
  reviewed_at = excluded.reviewed_at;

-- Technical evidence links.
insert into public.work_technology_sources (
  work_technology_id, source_id, supports_fields, is_primary, notes
)
select wt.id, s.id, array['technology','relationship_role']::text[], d.is_primary, d.notes
from (values
  ('a-ha-take-on-me', 'rotoscoping', 'https://www.mynewsdesk.com/no/wmgno/pressreleases/a-ha-naar-en-milliard-visninger-med-take-on-me-2973845', true, 'Warner Music explicitly identifies the frame-by-frame rotoscoping process.'),
  ('childish-gambino-this-is-america', 'steadicam', 'https://www.postmagazine.com/Press-Center/Daily-News/2019/Music-Video-Childish-Gambino-I-This-is-America-I.aspx', true, 'Trade interview identifies long Steadicam shots.'),
  ('childish-gambino-this-is-america', 'steadicam', 'https://filmmakermagazine.com/105396-dp-larkin-seiple-breaks-down-every-shot-from-childish-gambinos-this-is-america/', false, 'Cinematographer describes the six Steadicam tracking shots.'),
  ('childish-gambino-this-is-america', 'steadicam', 'https://www.kodak.com/en/motion/blog-post/hiro-murai-larkin-seiple/', false, 'Production interview names the Steadicam operator and long takes.')
) as d(work_slug, technology_slug, source_url, is_primary, notes)
join public.works w on w.slug = d.work_slug
join public.technologies t on t.slug = d.technology_slug
join public.work_technologies wt on wt.work_id = w.id and wt.technology_id = t.id
join public.sources s on s.url = d.source_url
on conflict (work_technology_id, source_id) do update set
  supports_fields = excluded.supports_fields,
  is_primary = excluded.is_primary,
  notes = excluded.notes;

-- Every published visual-language edge is grounded in the official video.
insert into public.work_visual_language_sources (
  work_visual_language_id, source_id, supports_fields, is_primary, notes
)
select
  wvl.id, s.id, array['visual_language']::text[], true,
  'Official video used for direct formal analysis.'
from public.work_visual_languages wvl
join public.works w on w.id = wvl.work_id
join public.music_video_details mvd on mvd.work_id = w.id
join public.sources s on s.url = mvd.official_release_url
where w.slug in (
  'michael-jackson-thriller',
  'a-ha-take-on-me',
  'jamiroquai-virtual-insanity',
  'daft-punk-around-the-world',
  'beyonce-single-ladies',
  'fatboy-slim-weapon-of-choice',
  'childish-gambino-this-is-america',
  'sakanaction-shin-takarajima'
)
on conflict (work_visual_language_id, source_id) do update set
  supports_fields = excluded.supports_fields,
  is_primary = excluded.is_primary,
  notes = excluded.notes;

-- Additional evidence for relationships whose construction is not fully
-- established by viewing the finished work alone.
insert into public.work_visual_language_sources (
  work_visual_language_id, source_id, supports_fields, is_primary, notes
)
select wvl.id, s.id, array['visual_language','construction']::text[], false, d.notes
from (values
  ('jamiroquai-virtual-insanity', 'optical-illusion', 'https://www.videostatic.com/virtual-insanity', 'Director-derived production explanation of the moving set and fixed floor.'),
  ('jamiroquai-virtual-insanity', 'continuous-shot-illusion', 'https://www.videostatic.com/virtual-insanity', 'Production explanation used to qualify the spatial continuity claim.'),
  ('beyonce-single-ladies', 'continuous-shot-illusion', 'https://www.nyfa.edu/student-resources/beyonce-music-video-evolution-5-cinematography-lessons/', 'Secondary educational source identifies the limited cuts.'),
  ('childish-gambino-this-is-america', 'continuous-shot-illusion', 'https://www.postmagazine.com/Press-Center/Daily-News/2019/Music-Video-Childish-Gambino-I-This-is-America-I.aspx', 'Editor interview explains combined takes and transitions.'),
  ('childish-gambino-this-is-america', 'continuous-shot-illusion', 'https://filmmakermagazine.com/105396-dp-larkin-seiple-breaks-down-every-shot-from-childish-gambinos-this-is-america/', 'Cinematographer breakdown confirms multiple long tracking shots.')
) as d(work_slug, visual_language_slug, source_url, notes)
join public.works w on w.slug = d.work_slug
join public.visual_languages vl on vl.slug = d.visual_language_slug
join public.work_visual_languages wvl on wvl.work_id = w.id and wvl.visual_language_id = vl.id
join public.sources s on s.url = d.source_url
on conflict (work_visual_language_id, source_id) do update set
  supports_fields = excluded.supports_fields,
  notes = excluded.notes;

commit;
