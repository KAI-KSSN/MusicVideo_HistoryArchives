-- MVHL Knowledge Graph Sprint 2 — published works batch 05
-- Individually reviewed, source-backed, and safely rerunnable.
begin;


insert into public.sources (source_type, title, publisher, url, accessed_at, notes)
values
  ('publication', 'Nowhere to Hide: The Mill’s See-Through VFX in Wide Open', 'Autodesk Community', 'https://forums.autodesk.com/t5/community-blog-m-e-english/nowhere-to-hide-the-mill-s-see-through-vfx-in-quot-wide-open/ba-p/13895649', current_date, 'The Mill team describes tracking, the fully CG lattice body, and compositing.'),
  ('publication', 'So just how was that Chemical Brothers video made?', 'fxguide', 'https://www.fxguide.com/fxfeatured/so-just-how-was-that-chemical-brothers-video-made/', current_date, 'The technical breakdown documents tracking, motion-capture data, clean plates, CG rendering, and compositing.'),
  ('director_portfolio', 'Making of Fly feat. 79, 中村佳穂', 'Baku Hashimoto', 'https://baku89.com/ja/making-of/fly', current_date, 'The director documents Dragonframe stop-motion capture and manually moved camera positions.')
on conflict (url) do update set
  source_type = excluded.source_type,
  title = excluded.title,
  publisher = excluded.publisher,
  accessed_at = excluded.accessed_at,
  notes = excluded.notes;

insert into public.knowledge_graph_work_reviews (
  work_id, sprint, technology_outcome, visual_language_outcome,
  review_note_ja, review_note_en, deliberately_not_assigned,
  unresolved_questions, reviewed_at
)
select w.id, 'knowledge-graph-sprint-2', d.technology_outcome,
  d.visual_outcome, d.note_ja, d.note_en, d.omissions, d.unresolved, now()
from (values
(
    'sakanaction-aruku-around',
    'none',
    'assigned',
    '一続きの移動と遠近法を用い、空間内の文字、演者、カメラ位置を同期させて歌詞を物理的な経路へ変える。', 'One continuous move and perspective align text, performer, and camera positions, turning lyrics into a physical route through space.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'ok-go-needing-getting',
    'none',
    'assigned',
    '走行する車が道沿いの楽器と接触する出来事を音のタイミングへ対応させ、移動そのものを演奏へ変える。', 'A moving car strikes roadside instruments in musical time, turning travel itself into performance.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'pharrell-williams-happy',
    'none',
    'assigned',
    '異なる時刻と場所のパフォーマンスを連続閲覧可能な一日の構造へ束ね、個々のダンスを参加型の長い体験へ広げる。', 'Performances across times and places form a navigable day, extending individual dances into a participatory long-duration experience.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'flying-lotus-never-catch-me',
    'none',
    'assigned',
    '葬儀から抜け出す二人の子どもの身体をダンスで語り、カメラが解放の運動を物語として追う。', 'Dance tells the story of two children leaving their funeral, while the camera follows bodily release as narrative.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'sia-chandelier',
    'none',
    'assigned',
    '一人のダンサーと荒れた室内に集中し、部屋の境界、家具、カメラ距離を身体運動の経路として用いる。', 'A single dancer and damaged interior concentrate attention on boundaries, furniture, and camera distance as routes for movement.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'tame-impala-let-it-happen',
    'none',
    'assigned',
    '空港での転倒、機内、空中落下が反復と変形を重ね、危機の時間を抜け出せない循環として見せる。', 'Collapse in the airport, flight, and falling recur and transform, presenting crisis time as a loop that cannot be escaped.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'the-weeknd-cant-feel-my-face',
    'none',
    'assigned',
    '小さなクラブでの歌唱が観客の拒絶から炎上と熱狂へ変わり、パフォーマンス自体を短い転換物語にする。', 'A small-club performance moves from rejection to fire and acclaim, making the performance itself a concise reversal narrative.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'sakanaction-shin-takarajima',
    'preserved',
    'preserved',
    'Pilot relationships preserved unchanged.', 'Pilot relationships preserved unchanged.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'radiohead-daydreaming',
    'none',
    'assigned',
    '人物が扉を通るたび異なる場所へ接続し、移動の連続性を保ったまま空間と時間を跳躍する。', 'Each doorway connects the figure to a different location, leaping through space and time while preserving continuity of movement.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'chemical-brothers-wide-open',
    'assigned',
    'assigned',
    '長いダンス撮影を追跡し、身体を実写から格子状のCGへ徐々に置換することで、変身を連続した物理的出来事として保つ。', 'Tracking a long dance performance while replacing the body with a CG lattice keeps transformation legible as one continuous physical event.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'bonobo-no-reason',
    'none',
    'assigned',
    '同じ室内が段階的に縮小するセットを連続移動で接続し、人物の尺度と空間の関係を反転させる。', 'A continuous move joins progressively smaller versions of one room, reversing the relation between human scale and space.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'imai-fly',
    'assigned',
    'assigned',
    '手動で動かしたカメラ位置とコマ撮りの物体変化を音へ同期し、机上の素材を高速な空間変形へ変える。', 'Manually shifted camera positions and stop-motion object changes synchronize to sound, turning tabletop materials into rapid spatial transformation.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  )
) as d(work_slug, technology_outcome, visual_outcome, note_ja, note_en, omissions, unresolved)
join public.works w on w.slug = d.work_slug
on conflict (work_id) do update set
  sprint = excluded.sprint,
  technology_outcome = excluded.technology_outcome,
  visual_language_outcome = excluded.visual_language_outcome,
  review_note_ja = excluded.review_note_ja,
  review_note_en = excluded.review_note_en,
  deliberately_not_assigned = excluded.deliberately_not_assigned,
  unresolved_questions = excluded.unresolved_questions,
  reviewed_at = excluded.reviewed_at;


insert into public.work_technologies (
  work_id, technology_id, usage_role, relevance, relationship_role,
  is_primary, confidence, assignment_method, verification_status,
  note_ja, note_en, display_order, reviewed_at
)
select w.id, t.id,
  case when d.is_primary then 'primary' else 'supporting' end,
  d.relevance, d.relationship_role, d.is_primary, 1.000,
  'editorial', 'verified', d.note_ja, d.note_en, d.display_order, now()
from (values
  ('chemical-brothers-wide-open', 'cgi', 'primary', 'defining_use', true, '長いダンス撮影を追跡し、身体を実写から格子状のCGへ徐々に置換することで、変身を連続した物理的出来事として保つ。', 'Tracking a long dance performance while replacing the body with a CG lattice keeps transformation legible as one continuous physical event.', 10),
  ('chemical-brothers-wide-open', '3d-camera-tracking', 'significant', 'standard_use', false, '長いダンス撮影を追跡し、身体を実写から格子状のCGへ徐々に置換することで、変身を連続した物理的出来事として保つ。', 'Tracking a long dance performance while replacing the body with a CG lattice keeps transformation legible as one continuous physical event.', 20),
  ('chemical-brothers-wide-open', 'motion-capture', 'significant', 'standard_use', false, '長いダンス撮影を追跡し、身体を実写から格子状のCGへ徐々に置換することで、変身を連続した物理的出来事として保つ。', 'Tracking a long dance performance while replacing the body with a CG lattice keeps transformation legible as one continuous physical event.', 30),
  ('imai-fly', 'stop-motion-photography', 'primary', 'defining_use', true, '手動で動かしたカメラ位置とコマ撮りの物体変化を音へ同期し、机上の素材を高速な空間変形へ変える。', 'Manually shifted camera positions and stop-motion object changes synchronize to sound, turning tabletop materials into rapid spatial transformation.', 10)
) as d(work_slug, concept_slug, relevance, relationship_role, is_primary, note_ja, note_en, display_order)
join public.works w on w.slug = d.work_slug
join public.technologies t on t.slug = d.concept_slug
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

insert into public.work_technology_sources (
  work_technology_id, source_id, supports_fields, is_primary, notes
)
select wt.id, s.id, array['technology']::text[], d.is_primary, d.notes
from (values
  ('chemical-brothers-wide-open', 'cgi', 'https://forums.autodesk.com/t5/community-blog-m-e-english/nowhere-to-hide-the-mill-s-see-through-vfx-in-quot-wide-open/ba-p/13895649', true, 'The Mill team describes tracking, the fully CG lattice body, and compositing.'),
  ('chemical-brothers-wide-open', 'cgi', 'https://www.fxguide.com/fxfeatured/so-just-how-was-that-chemical-brothers-video-made/', false, 'The technical breakdown documents tracking, motion-capture data, clean plates, CG rendering, and compositing.'),
  ('chemical-brothers-wide-open', '3d-camera-tracking', 'https://forums.autodesk.com/t5/community-blog-m-e-english/nowhere-to-hide-the-mill-s-see-through-vfx-in-quot-wide-open/ba-p/13895649', true, 'The Mill team describes tracking, the fully CG lattice body, and compositing.'),
  ('chemical-brothers-wide-open', '3d-camera-tracking', 'https://www.fxguide.com/fxfeatured/so-just-how-was-that-chemical-brothers-video-made/', false, 'The technical breakdown documents tracking, motion-capture data, clean plates, CG rendering, and compositing.'),
  ('chemical-brothers-wide-open', 'motion-capture', 'https://www.fxguide.com/fxfeatured/so-just-how-was-that-chemical-brothers-video-made/', true, 'The technical breakdown documents tracking, motion-capture data, clean plates, CG rendering, and compositing.'),
  ('imai-fly', 'stop-motion-photography', 'https://baku89.com/ja/making-of/fly', true, 'The director documents Dragonframe stop-motion capture and manually moved camera positions.')
) as d(work_slug, concept_slug, source_url, is_primary, notes)
join public.works w on w.slug = d.work_slug
join public.technologies t on t.slug = d.concept_slug
join public.work_technologies wt on wt.work_id = w.id and wt.technology_id = t.id
join public.sources s on s.url = d.source_url
on conflict (work_technology_id, source_id) do update set
  supports_fields = excluded.supports_fields,
  is_primary = excluded.is_primary,
  notes = excluded.notes;


insert into public.work_visual_languages (
  work_id, visual_language_id, prominence, relevance, relationship_role,
  is_primary, confidence, assignment_method, editorial_rationale,
  verification_status, note_ja, note_en, display_order, reviewed_at
)
select w.id, vl.id,
  case when d.is_primary then 'primary' else 'secondary' end,
  d.relevance, d.relationship_role, d.is_primary, 1.000,
  'editorial', d.note_en, 'verified', d.note_ja, d.note_en, d.display_order, now()
from (values
  ('sakanaction-aruku-around', 'one-take', 'primary', 'defining_example', true, '一続きの移動と遠近法を用い、空間内の文字、演者、カメラ位置を同期させて歌詞を物理的な経路へ変える。', 'One continuous move and perspective align text, performer, and camera positions, turning lyrics into a physical route through space.', 10),
  ('sakanaction-aruku-around', 'typography', 'significant', 'defining_example', true, '一続きの移動と遠近法を用い、空間内の文字、演者、カメラ位置を同期させて歌詞を物理的な経路へ変える。', 'One continuous move and perspective align text, performer, and camera positions, turning lyrics into a physical route through space.', 20),
  ('sakanaction-aruku-around', 'spatial-choreography', 'significant', 'notable_example', false, '一続きの移動と遠近法を用い、空間内の文字、演者、カメラ位置を同期させて歌詞を物理的な経路へ変える。', 'One continuous move and perspective align text, performer, and camera positions, turning lyrics into a physical route through space.', 30),
  ('ok-go-needing-getting', 'rhythmic-editing', 'primary', 'notable_example', true, '走行する車が道沿いの楽器と接触する出来事を音のタイミングへ対応させ、移動そのものを演奏へ変える。', 'A moving car strikes roadside instruments in musical time, turning travel itself into performance.', 10),
  ('ok-go-needing-getting', 'performance-film', 'significant', 'notable_example', false, '走行する車が道沿いの楽器と接触する出来事を音のタイミングへ対応させ、移動そのものを演奏へ変える。', 'A moving car strikes roadside instruments in musical time, turning travel itself into performance.', 20),
  ('pharrell-williams-happy', 'interactive-video', 'primary', 'defining_example', true, '異なる時刻と場所のパフォーマンスを連続閲覧可能な一日の構造へ束ね、個々のダンスを参加型の長い体験へ広げる。', 'Performances across times and places form a navigable day, extending individual dances into a participatory long-duration experience.', 10),
  ('pharrell-williams-happy', 'dance-camera', 'significant', 'notable_example', false, '異なる時刻と場所のパフォーマンスを連続閲覧可能な一日の構造へ束ね、個々のダンスを参加型の長い体験へ広げる。', 'Performances across times and places form a navigable day, extending individual dances into a participatory long-duration experience.', 20),
  ('flying-lotus-never-catch-me', 'long-form-narrative', 'primary', 'defining_example', true, '葬儀から抜け出す二人の子どもの身体をダンスで語り、カメラが解放の運動を物語として追う。', 'Dance tells the story of two children leaving their funeral, while the camera follows bodily release as narrative.', 10),
  ('flying-lotus-never-catch-me', 'dance-camera', 'significant', 'notable_example', false, '葬儀から抜け出す二人の子どもの身体をダンスで語り、カメラが解放の運動を物語として追う。', 'Dance tells the story of two children leaving their funeral, while the camera follows bodily release as narrative.', 20),
  ('sia-chandelier', 'dance-camera', 'primary', 'defining_example', true, '一人のダンサーと荒れた室内に集中し、部屋の境界、家具、カメラ距離を身体運動の経路として用いる。', 'A single dancer and damaged interior concentrate attention on boundaries, furniture, and camera distance as routes for movement.', 10),
  ('sia-chandelier', 'spatial-choreography', 'significant', 'notable_example', false, '一人のダンサーと荒れた室内に集中し、部屋の境界、家具、カメラ距離を身体運動の経路として用いる。', 'A single dancer and damaged interior concentrate attention on boundaries, furniture, and camera distance as routes for movement.', 20),
  ('tame-impala-let-it-happen', 'loop', 'primary', 'notable_example', true, '空港での転倒、機内、空中落下が反復と変形を重ね、危機の時間を抜け出せない循環として見せる。', 'Collapse in the airport, flight, and falling recur and transform, presenting crisis time as a loop that cannot be escaped.', 10),
  ('tame-impala-let-it-happen', 'continuous-transformation', 'significant', 'notable_example', false, '空港での転倒、機内、空中落下が反復と変形を重ね、危機の時間を抜け出せない循環として見せる。', 'Collapse in the airport, flight, and falling recur and transform, presenting crisis time as a loop that cannot be escaped.', 20),
  ('the-weeknd-cant-feel-my-face', 'performance-film', 'primary', 'notable_example', true, '小さなクラブでの歌唱が観客の拒絶から炎上と熱狂へ変わり、パフォーマンス自体を短い転換物語にする。', 'A small-club performance moves from rejection to fire and acclaim, making the performance itself a concise reversal narrative.', 10),
  ('the-weeknd-cant-feel-my-face', 'long-form-narrative', 'significant', 'notable_example', false, '小さなクラブでの歌唱が観客の拒絶から炎上と熱狂へ変わり、パフォーマンス自体を短い転換物語にする。', 'A small-club performance moves from rejection to fire and acclaim, making the performance itself a concise reversal narrative.', 20),
  ('radiohead-daydreaming', 'match-cut', 'primary', 'defining_example', true, '人物が扉を通るたび異なる場所へ接続し、移動の連続性を保ったまま空間と時間を跳躍する。', 'Each doorway connects the figure to a different location, leaping through space and time while preserving continuity of movement.', 10),
  ('radiohead-daydreaming', 'continuous-shot-illusion', 'significant', 'defining_example', true, '人物が扉を通るたび異なる場所へ接続し、移動の連続性を保ったまま空間と時間を跳躍する。', 'Each doorway connects the figure to a different location, leaping through space and time while preserving continuity of movement.', 20),
  ('chemical-brothers-wide-open', 'body-transformation', 'primary', 'defining_example', true, '長いダンス撮影を追跡し、身体を実写から格子状のCGへ徐々に置換することで、変身を連続した物理的出来事として保つ。', 'Tracking a long dance performance while replacing the body with a CG lattice keeps transformation legible as one continuous physical event.', 10),
  ('chemical-brothers-wide-open', 'continuous-shot-illusion', 'significant', 'notable_example', false, '長いダンス撮影を追跡し、身体を実写から格子状のCGへ徐々に置換することで、変身を連続した物理的出来事として保つ。', 'Tracking a long dance performance while replacing the body with a CG lattice keeps transformation legible as one continuous physical event.', 20),
  ('bonobo-no-reason', 'forced-perspective', 'primary', 'defining_example', true, '同じ室内が段階的に縮小するセットを連続移動で接続し、人物の尺度と空間の関係を反転させる。', 'A continuous move joins progressively smaller versions of one room, reversing the relation between human scale and space.', 10),
  ('bonobo-no-reason', 'continuous-shot-illusion', 'significant', 'notable_example', false, '同じ室内が段階的に縮小するセットを連続移動で接続し、人物の尺度と空間の関係を反転させる。', 'A continuous move joins progressively smaller versions of one room, reversing the relation between human scale and space.', 20),
  ('imai-fly', 'stop-motion', 'primary', 'defining_example', true, '手動で動かしたカメラ位置とコマ撮りの物体変化を音へ同期し、机上の素材を高速な空間変形へ変える。', 'Manually shifted camera positions and stop-motion object changes synchronize to sound, turning tabletop materials into rapid spatial transformation.', 10),
  ('imai-fly', 'rhythmic-editing', 'significant', 'notable_example', false, '手動で動かしたカメラ位置とコマ撮りの物体変化を音へ同期し、机上の素材を高速な空間変形へ変える。', 'Manually shifted camera positions and stop-motion object changes synchronize to sound, turning tabletop materials into rapid spatial transformation.', 20)
) as d(work_slug, concept_slug, relevance, relationship_role, is_primary, note_ja, note_en, display_order)
join public.works w on w.slug = d.work_slug
join public.visual_languages vl on vl.slug = d.concept_slug
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

insert into public.work_visual_language_sources (
  work_visual_language_id, source_id, supports_fields, is_primary, notes
)
select wvl.id, s.id, array['visual_language']::text[], true,
  'Official video used for direct formal analysis.'
from public.work_visual_languages wvl
join public.works w on w.id = wvl.work_id
join public.music_video_details mvd on mvd.work_id = w.id
join public.sources s on s.url = mvd.official_release_url
where w.slug in ('sakanaction-aruku-around', 'ok-go-needing-getting', 'pharrell-williams-happy', 'flying-lotus-never-catch-me', 'sia-chandelier', 'tame-impala-let-it-happen', 'the-weeknd-cant-feel-my-face', 'radiohead-daydreaming', 'chemical-brothers-wide-open', 'bonobo-no-reason', 'imai-fly')
  and wvl.verification_status = 'verified'
on conflict (work_visual_language_id, source_id) do update set
  supports_fields = excluded.supports_fields,
  is_primary = excluded.is_primary,
  notes = excluded.notes;

commit;
