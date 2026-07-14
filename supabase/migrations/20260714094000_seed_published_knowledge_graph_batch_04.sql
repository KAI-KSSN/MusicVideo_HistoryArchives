-- MVHL Knowledge Graph Sprint 2 — published works batch 04
-- Individually reviewed, source-backed, and safely rerunnable.
begin;


insert into public.sources (source_type, title, publisher, url, accessed_at, notes)
values
  ('director_portfolio', 'Radiohead — House of Cards', 'Aaron Koblin', 'https://www.aaronkoblin.com/work/rh/index.html', current_date, 'The project page documents LiDAR, structured-light scanning, and particle-based 3D data.')
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
    'chemical-brothers-star-guitar',
    'none',
    'assigned',
    '通過する建物、柱、標識を音の周期へ対応させ、連続風景そのものを編集された譜面として見せる。', 'Passing buildings, poles, and signs correspond to musical cycles, making the continuous landscape read like an edited score.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'the-white-stripes-fell-in-love-with-a-girl',
    'none',
    'assigned',
    'ブロックの人物と楽器を一コマずつ置換し、演奏の衝動を楽曲速度に密着した粗い色面の運動へ変える。', 'Frame-by-frame block figures and instruments turn performance energy into coarse color movement tied tightly to the song''s speed.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'gorillaz-feel-good-inc',
    'none',
    'assigned',
    'アニメーションのバンドと実写の出演者、塔内と浮遊島の舞台を一曲の複合的なパフォーマンスへ束ねる。', 'Animated band, live performers, tower, and floating island are bound into one composite musical performance.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'sigur-ros-glosoli',
    'none',
    'assigned',
    '子どもたちが一人ずつ集まり、行進し、崖へ到達するまでを台詞のない一方向の旅として描く。', 'Children gather one by one, march, and reach the cliff in a wordless, one-directional journey.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'muse-knights-of-cydonia',
    'none',
    'assigned',
    '西部劇、SF、武術、演奏を一つの救出劇へ混在させ、ジャンルの衝突を物語の推進力にする。', 'Western, science fiction, martial arts, and performance collide within one rescue story, making genre collision the narrative engine.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'ok-go-here-it-goes-again',
    'none',
    'assigned',
    '固定された一続きの視点の中で、四人と八台のトレッドミルの位置、速度、乗り換えを振付として成立させる。', 'Within one fixed continuous view, four performers and eight treadmills are choreographed through position, speed, and transfers.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'the-knife-silent-shout',
    'none',
    'assigned',
    '暗い空間、発光する輪郭、正面の歌唱に要素を絞り、人物を光の図形として浮かび上がらせる。', 'Dark space, luminous outlines, and frontal performance reduce the figure to a graphic form made of light.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'battles-atlas',
    'none',
    'assigned',
    '白いスタジオと演奏するバンドへ要素を限定し、反復する身体運動と楽器配置を明確に観察させる。', 'A white studio and performing band reduce the image to essentials, making repeated bodily movement and instrument placement clearly observable.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'justice-d-a-n-c-e',
    'none',
    'assigned',
    '衣服上の文字と図像が身体の動きに合わせて連続変形し、歌詞、ロゴ、人物を一つの動く平面へ統合する。', 'Words and graphics on clothing transform with bodily movement, integrating lyrics, logos, and figures into one moving surface.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'kanye-west-stronger',
    'none',
    'assigned',
    '実写、アニメーション、字幕、医療表示を高速に重ね、人物と都市を密度の高いインターフェースとして構成する。', 'Live action, animation, captions, and medical displays are layered rapidly, composing performer and city as a dense interface.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'beyonce-single-ladies',
    'preserved',
    'preserved',
    'Pilot relationships preserved unchanged.', 'Pilot relationships preserved unchanged.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'radiohead-house-of-cards',
    'assigned',
    'assigned',
    'レーザーと構造化光で取得した三次元データを粒子像として可視化し、顔と空間を絶えず生成・崩壊する測定結果として見せる。', 'Laser and structured-light 3D data become particle images, presenting faces and spaces as measured forms in continual formation and collapse.',
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
  ('radiohead-house-of-cards', 'lidar', 'primary', 'defining_use', true, 'レーザーと構造化光で取得した三次元データを粒子像として可視化し、顔と空間を絶えず生成・崩壊する測定結果として見せる。', 'Laser and structured-light 3D data become particle images, presenting faces and spaces as measured forms in continual formation and collapse.', 10),
  ('radiohead-house-of-cards', 'point-cloud-capture', 'significant', 'defining_use', false, 'レーザーと構造化光で取得した三次元データを粒子像として可視化し、顔と空間を絶えず生成・崩壊する測定結果として見せる。', 'Laser and structured-light 3D data become particle images, presenting faces and spaces as measured forms in continual formation and collapse.', 20)
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
  ('radiohead-house-of-cards', 'lidar', 'https://www.aaronkoblin.com/work/rh/index.html', true, 'The project page documents LiDAR, structured-light scanning, and particle-based 3D data.'),
  ('radiohead-house-of-cards', 'point-cloud-capture', 'https://www.aaronkoblin.com/work/rh/index.html', true, 'The project page documents LiDAR, structured-light scanning, and particle-based 3D data.')
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
  ('chemical-brothers-star-guitar', 'match-cut', 'primary', 'defining_example', true, '通過する建物、柱、標識を音の周期へ対応させ、連続風景そのものを編集された譜面として見せる。', 'Passing buildings, poles, and signs correspond to musical cycles, making the continuous landscape read like an edited score.', 10),
  ('chemical-brothers-star-guitar', 'rhythmic-editing', 'primary', 'defining_example', true, '通過する建物、柱、標識を音の周期へ対応させ、連続風景そのものを編集された譜面として見せる。', 'Passing buildings, poles, and signs correspond to musical cycles, making the continuous landscape read like an edited score.', 20),
  ('the-white-stripes-fell-in-love-with-a-girl', 'stop-motion', 'primary', 'defining_example', true, 'ブロックの人物と楽器を一コマずつ置換し、演奏の衝動を楽曲速度に密着した粗い色面の運動へ変える。', 'Frame-by-frame block figures and instruments turn performance energy into coarse color movement tied tightly to the song''s speed.', 10),
  ('the-white-stripes-fell-in-love-with-a-girl', 'rhythmic-editing', 'significant', 'notable_example', false, 'ブロックの人物と楽器を一コマずつ置換し、演奏の衝動を楽曲速度に密着した粗い色面の運動へ変える。', 'Frame-by-frame block figures and instruments turn performance energy into coarse color movement tied tightly to the song''s speed.', 20),
  ('gorillaz-feel-good-inc', 'mixed-media', 'primary', 'notable_example', true, 'アニメーションのバンドと実写の出演者、塔内と浮遊島の舞台を一曲の複合的なパフォーマンスへ束ねる。', 'Animated band, live performers, tower, and floating island are bound into one composite musical performance.', 10),
  ('gorillaz-feel-good-inc', 'performance-film', 'significant', 'notable_example', false, 'アニメーションのバンドと実写の出演者、塔内と浮遊島の舞台を一曲の複合的なパフォーマンスへ束ねる。', 'Animated band, live performers, tower, and floating island are bound into one composite musical performance.', 20),
  ('sigur-ros-glosoli', 'long-form-narrative', 'primary', 'defining_example', true, '子どもたちが一人ずつ集まり、行進し、崖へ到達するまでを台詞のない一方向の旅として描く。', 'Children gather one by one, march, and reach the cliff in a wordless, one-directional journey.', 10),
  ('muse-knights-of-cydonia', 'long-form-narrative', 'primary', 'notable_example', true, '西部劇、SF、武術、演奏を一つの救出劇へ混在させ、ジャンルの衝突を物語の推進力にする。', 'Western, science fiction, martial arts, and performance collide within one rescue story, making genre collision the narrative engine.', 10),
  ('muse-knights-of-cydonia', 'surrealism', 'significant', 'notable_example', false, '西部劇、SF、武術、演奏を一つの救出劇へ混在させ、ジャンルの衝突を物語の推進力にする。', 'Western, science fiction, martial arts, and performance collide within one rescue story, making genre collision the narrative engine.', 20),
  ('ok-go-here-it-goes-again', 'one-take', 'primary', 'defining_example', true, '固定された一続きの視点の中で、四人と八台のトレッドミルの位置、速度、乗り換えを振付として成立させる。', 'Within one fixed continuous view, four performers and eight treadmills are choreographed through position, speed, and transfers.', 10),
  ('ok-go-here-it-goes-again', 'spatial-choreography', 'primary', 'defining_example', true, '固定された一続きの視点の中で、四人と八台のトレッドミルの位置、速度、乗り換えを振付として成立させる。', 'Within one fixed continuous view, four performers and eight treadmills are choreographed through position, speed, and transfers.', 20),
  ('the-knife-silent-shout', 'graphic-composition', 'primary', 'notable_example', true, '暗い空間、発光する輪郭、正面の歌唱に要素を絞り、人物を光の図形として浮かび上がらせる。', 'Dark space, luminous outlines, and frontal performance reduce the figure to a graphic form made of light.', 10),
  ('the-knife-silent-shout', 'minimal-performance', 'significant', 'notable_example', false, '暗い空間、発光する輪郭、正面の歌唱に要素を絞り、人物を光の図形として浮かび上がらせる。', 'Dark space, luminous outlines, and frontal performance reduce the figure to a graphic form made of light.', 20),
  ('battles-atlas', 'performance-film', 'primary', 'notable_example', true, '白いスタジオと演奏するバンドへ要素を限定し、反復する身体運動と楽器配置を明確に観察させる。', 'A white studio and performing band reduce the image to essentials, making repeated bodily movement and instrument placement clearly observable.', 10),
  ('battles-atlas', 'minimal-performance', 'significant', 'notable_example', false, '白いスタジオと演奏するバンドへ要素を限定し、反復する身体運動と楽器配置を明確に観察させる。', 'A white studio and performing band reduce the image to essentials, making repeated bodily movement and instrument placement clearly observable.', 20),
  ('justice-d-a-n-c-e', 'kinetic-typography', 'primary', 'defining_example', true, '衣服上の文字と図像が身体の動きに合わせて連続変形し、歌詞、ロゴ、人物を一つの動く平面へ統合する。', 'Words and graphics on clothing transform with bodily movement, integrating lyrics, logos, and figures into one moving surface.', 10),
  ('justice-d-a-n-c-e', 'mixed-media', 'significant', 'notable_example', false, '衣服上の文字と図像が身体の動きに合わせて連続変形し、歌詞、ロゴ、人物を一つの動く平面へ統合する。', 'Words and graphics on clothing transform with bodily movement, integrating lyrics, logos, and figures into one moving surface.', 20),
  ('kanye-west-stronger', 'mixed-media', 'primary', 'notable_example', true, '実写、アニメーション、字幕、医療表示を高速に重ね、人物と都市を密度の高いインターフェースとして構成する。', 'Live action, animation, captions, and medical displays are layered rapidly, composing performer and city as a dense interface.', 10),
  ('kanye-west-stronger', 'graphic-composition', 'significant', 'notable_example', false, '実写、アニメーション、字幕、医療表示を高速に重ね、人物と都市を密度の高いインターフェースとして構成する。', 'Live action, animation, captions, and medical displays are layered rapidly, composing performer and city as a dense interface.', 20),
  ('radiohead-house-of-cards', 'data-visualization', 'primary', 'defining_example', true, 'レーザーと構造化光で取得した三次元データを粒子像として可視化し、顔と空間を絶えず生成・崩壊する測定結果として見せる。', 'Laser and structured-light 3D data become particle images, presenting faces and spaces as measured forms in continual formation and collapse.', 10),
  ('radiohead-house-of-cards', 'continuous-transformation', 'significant', 'notable_example', false, 'レーザーと構造化光で取得した三次元データを粒子像として可視化し、顔と空間を絶えず生成・崩壊する測定結果として見せる。', 'Laser and structured-light 3D data become particle images, presenting faces and spaces as measured forms in continual formation and collapse.', 20)
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
where w.slug in ('chemical-brothers-star-guitar', 'the-white-stripes-fell-in-love-with-a-girl', 'gorillaz-feel-good-inc', 'sigur-ros-glosoli', 'muse-knights-of-cydonia', 'ok-go-here-it-goes-again', 'the-knife-silent-shout', 'battles-atlas', 'justice-d-a-n-c-e', 'kanye-west-stronger', 'radiohead-house-of-cards')
  and wvl.verification_status = 'verified'
on conflict (work_visual_language_id, source_id) do update set
  supports_fields = excluded.supports_fields,
  is_primary = excluded.is_primary,
  notes = excluded.notes;

commit;
