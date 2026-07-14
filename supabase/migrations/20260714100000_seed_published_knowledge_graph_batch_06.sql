-- MVHL Knowledge Graph Sprint 2 — published works batch 06
-- Individually reviewed, source-backed, and safely rerunnable.
begin;


insert into public.sources (source_type, title, publisher, url, accessed_at, notes)
values
  ('production_company', 'millennium parade — Fly with me', 'PERIMETRON', 'https://www.perimetron.jp/single-post/2020/06/01/millennium-parade-fly-with-me', current_date, 'Official credits identify motion capture, CG, and composite teams.')
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
    'ok-go-obsession',
    'none',
    'assigned',
    'プリンター壁の紙、色面、二人の位置と動きを同期し、印刷装置を巨大な動く背景へ変える。', 'Printer paper, color fields, and the two performers'' positions synchronize, turning the printer wall into a monumental moving backdrop.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'wednesday-campanella-baku',
    'none',
    'assigned',
    '人物、衣装、描画、物体の状態が連続的に置換され、実写と加工像の境界を安定させない。', 'Figures, costume, drawing, and object states continually replace one another, keeping the boundary between live action and treated image unstable.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'childish-gambino-this-is-america',
    'preserved',
    'preserved',
    'Pilot relationships preserved unchanged.', 'Pilot relationships preserved unchanged.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'kenshi-yonezu-lemon',
    'none',
    'none',
    '既存概念の中に、作品から別作品への移動を十分に改善する関係を確認できなかったため空欄を維持する。', 'No existing concept was found that materially improves movement from this work to other works, so it remains unlinked.',
    array['All current Technology and Visual Language concepts were considered; no public relationship met the usefulness threshold.']::text[], array[]::text[]
  ),
(
    'max-cooper-repetition',
    'none',
    'assigned',
    '都市、道路、構造物の反復像を奥行き方向へ継ぎ足し、終端のない成長を循環とズームとして経験させる。', 'Repeated images of cities, roads, and structures extend through depth, making endless growth perceptible as loop and zoom.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'millennium-parade-fly-with-me',
    'assigned',
    'assigned',
    'モーションキャプチャされた演技をCGキャラクターと複合的な都市空間へ移し、演奏をアニメーション世界の身体運動として再構成する。', 'Motion-captured performance is transferred to CG characters and a composite city, reconstructing musical performance as bodily movement in an animated world.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'the-weeknd-take-my-breath',
    'none',
    'assigned',
    'クラブ内の歌唱、群舞、接近するカメラを同期し、快楽と危険が反転するパフォーマンス空間を作る。', 'Club performance, ensemble movement, and an approaching camera synchronize into a performance space where pleasure turns to danger.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'tyler-the-creator-lumberjack',
    'none',
    'assigned',
    '正方形画面、平面的な色面、誇張された天候と小道具を組み、人物を短い不条理な場面の連鎖へ置く。', 'Square framing, flat color fields, exaggerated weather, and props place the performer in a chain of concise absurd scenes.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'hikaru-utada-one-last-kiss',
    'none',
    'none',
    '既存概念の中に、作品から別作品への移動を十分に改善する関係を確認できなかったため空欄を維持する。', 'No existing concept was found that materially improves movement from this work to other works, so it remains unlinked.',
    array['All current Technology and Visual Language concepts were considered; no public relationship met the usefulness threshold.']::text[], array[]::text[]
  ),
(
    'kendrick-lamar-count-me-out',
    'none',
    'assigned',
    '対話する二人の現実場面から象徴的な群像へ移り、内面の葛藤を非現実的な出来事として展開する。', 'A two-person conversation opens into symbolic tableaux, externalizing inner conflict as unreal events.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'newjeans-ditto',
    'none',
    'assigned',
    '手持ち映像と録画画面を一人の観察者の記録として構成し、記憶、距離、集団への所属を物語化する。', 'Handheld and recorded images become one observer''s archive, narrating memory, distance, and belonging to a group.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'doja-cat-paint-the-town-red',
    'none',
    'assigned',
    '実写の身体、描画、彫刻的な像を往復し、人物を複数の怪物的・絵画的形態へ変換する。', 'Live body, drawing, and sculptural imagery alternate, transforming the performer across monstrous and painterly forms.',
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
  ('millennium-parade-fly-with-me', 'motion-capture', 'primary', 'defining_use', true, 'モーションキャプチャされた演技をCGキャラクターと複合的な都市空間へ移し、演奏をアニメーション世界の身体運動として再構成する。', 'Motion-captured performance is transferred to CG characters and a composite city, reconstructing musical performance as bodily movement in an animated world.', 10),
  ('millennium-parade-fly-with-me', 'cgi', 'significant', 'standard_use', false, 'モーションキャプチャされた演技をCGキャラクターと複合的な都市空間へ移し、演奏をアニメーション世界の身体運動として再構成する。', 'Motion-captured performance is transferred to CG characters and a composite city, reconstructing musical performance as bodily movement in an animated world.', 20),
  ('millennium-parade-fly-with-me', 'digital-compositing', 'significant', 'standard_use', false, 'モーションキャプチャされた演技をCGキャラクターと複合的な都市空間へ移し、演奏をアニメーション世界の身体運動として再構成する。', 'Motion-captured performance is transferred to CG characters and a composite city, reconstructing musical performance as bodily movement in an animated world.', 30)
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
  ('millennium-parade-fly-with-me', 'motion-capture', 'https://www.perimetron.jp/single-post/2020/06/01/millennium-parade-fly-with-me', true, 'Official credits identify motion capture, CG, and composite teams.'),
  ('millennium-parade-fly-with-me', 'cgi', 'https://www.perimetron.jp/single-post/2020/06/01/millennium-parade-fly-with-me', true, 'Official credits identify motion capture, CG, and composite teams.'),
  ('millennium-parade-fly-with-me', 'digital-compositing', 'https://www.perimetron.jp/single-post/2020/06/01/millennium-parade-fly-with-me', true, 'Official credits identify motion capture, CG, and composite teams.')
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
  ('ok-go-obsession', 'graphic-composition', 'primary', 'defining_example', true, 'プリンター壁の紙、色面、二人の位置と動きを同期し、印刷装置を巨大な動く背景へ変える。', 'Printer paper, color fields, and the two performers'' positions synchronize, turning the printer wall into a monumental moving backdrop.', 10),
  ('ok-go-obsession', 'spatial-choreography', 'significant', 'notable_example', false, 'プリンター壁の紙、色面、二人の位置と動きを同期し、印刷装置を巨大な動く背景へ変える。', 'Printer paper, color fields, and the two performers'' positions synchronize, turning the printer wall into a monumental moving backdrop.', 20),
  ('wednesday-campanella-baku', 'continuous-transformation', 'primary', 'notable_example', true, '人物、衣装、描画、物体の状態が連続的に置換され、実写と加工像の境界を安定させない。', 'Figures, costume, drawing, and object states continually replace one another, keeping the boundary between live action and treated image unstable.', 10),
  ('wednesday-campanella-baku', 'mixed-media', 'significant', 'notable_example', false, '人物、衣装、描画、物体の状態が連続的に置換され、実写と加工像の境界を安定させない。', 'Figures, costume, drawing, and object states continually replace one another, keeping the boundary between live action and treated image unstable.', 20),
  ('max-cooper-repetition', 'infinite-loop', 'primary', 'defining_example', true, '都市、道路、構造物の反復像を奥行き方向へ継ぎ足し、終端のない成長を循環とズームとして経験させる。', 'Repeated images of cities, roads, and structures extend through depth, making endless growth perceptible as loop and zoom.', 10),
  ('max-cooper-repetition', 'infinite-zoom', 'significant', 'notable_example', true, '都市、道路、構造物の反復像を奥行き方向へ継ぎ足し、終端のない成長を循環とズームとして経験させる。', 'Repeated images of cities, roads, and structures extend through depth, making endless growth perceptible as loop and zoom.', 20),
  ('millennium-parade-fly-with-me', 'performance-film', 'primary', 'notable_example', true, 'モーションキャプチャされた演技をCGキャラクターと複合的な都市空間へ移し、演奏をアニメーション世界の身体運動として再構成する。', 'Motion-captured performance is transferred to CG characters and a composite city, reconstructing musical performance as bodily movement in an animated world.', 10),
  ('millennium-parade-fly-with-me', 'mixed-media', 'significant', 'notable_example', false, 'モーションキャプチャされた演技をCGキャラクターと複合的な都市空間へ移し、演奏をアニメーション世界の身体運動として再構成する。', 'Motion-captured performance is transferred to CG characters and a composite city, reconstructing musical performance as bodily movement in an animated world.', 20),
  ('the-weeknd-take-my-breath', 'performance-film', 'primary', 'notable_example', true, 'クラブ内の歌唱、群舞、接近するカメラを同期し、快楽と危険が反転するパフォーマンス空間を作る。', 'Club performance, ensemble movement, and an approaching camera synchronize into a performance space where pleasure turns to danger.', 10),
  ('the-weeknd-take-my-breath', 'dance-camera', 'significant', 'notable_example', false, 'クラブ内の歌唱、群舞、接近するカメラを同期し、快楽と危険が反転するパフォーマンス空間を作る。', 'Club performance, ensemble movement, and an approaching camera synchronize into a performance space where pleasure turns to danger.', 20),
  ('tyler-the-creator-lumberjack', 'graphic-composition', 'primary', 'notable_example', true, '正方形画面、平面的な色面、誇張された天候と小道具を組み、人物を短い不条理な場面の連鎖へ置く。', 'Square framing, flat color fields, exaggerated weather, and props place the performer in a chain of concise absurd scenes.', 10),
  ('tyler-the-creator-lumberjack', 'surrealism', 'significant', 'notable_example', false, '正方形画面、平面的な色面、誇張された天候と小道具を組み、人物を短い不条理な場面の連鎖へ置く。', 'Square framing, flat color fields, exaggerated weather, and props place the performer in a chain of concise absurd scenes.', 20),
  ('kendrick-lamar-count-me-out', 'long-form-narrative', 'primary', 'notable_example', true, '対話する二人の現実場面から象徴的な群像へ移り、内面の葛藤を非現実的な出来事として展開する。', 'A two-person conversation opens into symbolic tableaux, externalizing inner conflict as unreal events.', 10),
  ('kendrick-lamar-count-me-out', 'surrealism', 'significant', 'notable_example', false, '対話する二人の現実場面から象徴的な群像へ移り、内面の葛藤を非現実的な出来事として展開する。', 'A two-person conversation opens into symbolic tableaux, externalizing inner conflict as unreal events.', 20),
  ('newjeans-ditto', 'found-footage', 'primary', 'defining_example', true, '手持ち映像と録画画面を一人の観察者の記録として構成し、記憶、距離、集団への所属を物語化する。', 'Handheld and recorded images become one observer''s archive, narrating memory, distance, and belonging to a group.', 10),
  ('newjeans-ditto', 'first-person', 'significant', 'notable_example', true, '手持ち映像と録画画面を一人の観察者の記録として構成し、記憶、距離、集団への所属を物語化する。', 'Handheld and recorded images become one observer''s archive, narrating memory, distance, and belonging to a group.', 20),
  ('newjeans-ditto', 'long-form-narrative', 'significant', 'notable_example', false, '手持ち映像と録画画面を一人の観察者の記録として構成し、記憶、距離、集団への所属を物語化する。', 'Handheld and recorded images become one observer''s archive, narrating memory, distance, and belonging to a group.', 30),
  ('doja-cat-paint-the-town-red', 'mixed-media', 'primary', 'notable_example', true, '実写の身体、描画、彫刻的な像を往復し、人物を複数の怪物的・絵画的形態へ変換する。', 'Live body, drawing, and sculptural imagery alternate, transforming the performer across monstrous and painterly forms.', 10),
  ('doja-cat-paint-the-town-red', 'body-transformation', 'significant', 'notable_example', false, '実写の身体、描画、彫刻的な像を往復し、人物を複数の怪物的・絵画的形態へ変換する。', 'Live body, drawing, and sculptural imagery alternate, transforming the performer across monstrous and painterly forms.', 20)
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
where w.slug in ('ok-go-obsession', 'wednesday-campanella-baku', 'max-cooper-repetition', 'millennium-parade-fly-with-me', 'the-weeknd-take-my-breath', 'tyler-the-creator-lumberjack', 'kendrick-lamar-count-me-out', 'newjeans-ditto', 'doja-cat-paint-the-town-red')
  and wvl.verification_status = 'verified'
on conflict (work_visual_language_id, source_id) do update set
  supports_fields = excluded.supports_fields,
  is_primary = excluded.is_primary,
  notes = excluded.notes;

commit;
