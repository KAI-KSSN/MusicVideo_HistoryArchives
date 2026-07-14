-- MVHL Knowledge Graph Sprint 2 — published works batch 02
-- Individually reviewed, source-backed, and safely rerunnable.
begin;


insert into public.sources (source_type, title, publisher, url, accessed_at, notes)
values
  ('artist_official', 'Sledgehammer', 'Peter Gabriel', 'https://petergabriel.com/release/sledgehammer/', current_date, 'The official release page credits Aardman Animations and the frame-animation team.')
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
    'peter-gabriel-sledgehammer',
    'assigned',
    'assigned',
    '身体、粘土、人形、日用品をコマ撮りで連続的に置換し、音のアクセントを触覚的な変形へ変える。', 'Frame-by-frame substitutions across body, clay, puppets, and objects turn musical accents into tactile transformation.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'madonna-like-a-prayer',
    'none',
    'assigned',
    '目撃、逃走、祈り、救済を歌唱と結び、パフォーマンスを倫理的な物語の内部へ置く。', 'Witnessing, flight, prayer, and rescue bind performance to an ethical narrative.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'guns-n-roses-november-rain',
    'none',
    'assigned',
    '結婚式、演奏会、死と葬儀を長尺で結び、私的な喪失と公共的なスペクタクルを往復する。', 'Wedding, concert, death, and funeral form a long structure moving between private loss and public spectacle.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'bjork-big-time-sensuality',
    'none',
    'assigned',
    '移動するトラック上の一人の歌唱に要素を絞り、都市の流れと身体の即興性を近い距離で保つ。', 'A solo performance on a moving truck keeps bodily spontaneity and the passing city in close relation.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'beastie-boys-sabotage',
    'none',
    'assigned',
    '架空の刑事番組として追跡と対決を連ね、急なズーム、走行、転倒の編集で楽曲の切迫感を増幅する。', 'A fictional police-show narrative uses abrupt zooms, running, falls, and collision cuts to amplify the song''s urgency.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'nine-inch-nails-closer',
    'none',
    'assigned',
    '医学、宗教、機械、動物の像を悪夢的に連ね、振動と瞬間的暗転を音の脈動へ結び付ける。', 'Medical, religious, mechanical, and animal images form a nightmare sequence whose vibration and black frames bind image to pulse.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'soundgarden-black-hole-sun',
    'none',
    'assigned',
    '郊外の顔と身体を過度に変形し、穏やかな日常を終末的で不穏な寓話へ反転する。', 'Excessive deformation of suburban faces and bodies reverses calm everyday life into an uncanny apocalyptic fable.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'jamiroquai-virtual-insanity',
    'preserved',
    'preserved',
    'Pilot relationships preserved; Motion Control remains deliberately unassigned.', 'Pilot relationships preserved; Motion Control remains deliberately unassigned.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'aphex-twin-come-to-daddy',
    'none',
    'assigned',
    '子どもたちの顔を同一の成人男性へ置き換え、団地での発見と襲撃を怪物譚として進める。', 'Replacing the children''s faces with the same adult man turns discovery and assault on the estate into a monster narrative.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'daft-punk-around-the-world',
    'preserved',
    'preserved',
    'Pilot relationships preserved unchanged.', 'Pilot relationships preserved unchanged.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'foo-fighters-everlong',
    'none',
    'assigned',
    '巨大化した手と歪んだ室内で夢の身体感覚を示し、眠り、侵入、変身、覚醒を複数の筋へ組む。', 'Enlarged hands and distorted rooms render dreamlike bodily scale within intersecting stories of sleep, intrusion, transformation, and waking.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'missy-elliott-the-rain-supa-dupa-fly',
    'none',
    'assigned',
    '魚眼的な近接、黒い膨張スーツ、鮮明な背景が人物の存在感を単純で強い形へ押し広げる。', 'Fisheye proximity, the inflated black suit, and vivid backgrounds expand the performer''s presence into simple, forceful shapes.',
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
  ('peter-gabriel-sledgehammer', 'stop-motion-photography', 'primary', 'defining_use', true, '身体、粘土、人形、日用品をコマ撮りで連続的に置換し、音のアクセントを触覚的な変形へ変える。', 'Frame-by-frame substitutions across body, clay, puppets, and objects turn musical accents into tactile transformation.', 10)
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
  ('peter-gabriel-sledgehammer', 'stop-motion-photography', 'https://petergabriel.com/release/sledgehammer/', true, 'The official release page credits Aardman Animations and the frame-animation team.')
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
  ('peter-gabriel-sledgehammer', 'stop-motion', 'primary', 'defining_example', true, '身体、粘土、人形、日用品をコマ撮りで連続的に置換し、音のアクセントを触覚的な変形へ変える。', 'Frame-by-frame substitutions across body, clay, puppets, and objects turn musical accents into tactile transformation.', 10),
  ('peter-gabriel-sledgehammer', 'continuous-transformation', 'significant', 'notable_example', false, '身体、粘土、人形、日用品をコマ撮りで連続的に置換し、音のアクセントを触覚的な変形へ変える。', 'Frame-by-frame substitutions across body, clay, puppets, and objects turn musical accents into tactile transformation.', 20),
  ('madonna-like-a-prayer', 'long-form-narrative', 'primary', 'notable_example', true, '目撃、逃走、祈り、救済を歌唱と結び、パフォーマンスを倫理的な物語の内部へ置く。', 'Witnessing, flight, prayer, and rescue bind performance to an ethical narrative.', 10),
  ('madonna-like-a-prayer', 'performance-film', 'significant', 'notable_example', false, '目撃、逃走、祈り、救済を歌唱と結び、パフォーマンスを倫理的な物語の内部へ置く。', 'Witnessing, flight, prayer, and rescue bind performance to an ethical narrative.', 20),
  ('guns-n-roses-november-rain', 'long-form-narrative', 'primary', 'defining_example', true, '結婚式、演奏会、死と葬儀を長尺で結び、私的な喪失と公共的なスペクタクルを往復する。', 'Wedding, concert, death, and funeral form a long structure moving between private loss and public spectacle.', 10),
  ('guns-n-roses-november-rain', 'performance-film', 'significant', 'notable_example', false, '結婚式、演奏会、死と葬儀を長尺で結び、私的な喪失と公共的なスペクタクルを往復する。', 'Wedding, concert, death, and funeral form a long structure moving between private loss and public spectacle.', 20),
  ('bjork-big-time-sensuality', 'minimal-performance', 'primary', 'defining_example', true, '移動するトラック上の一人の歌唱に要素を絞り、都市の流れと身体の即興性を近い距離で保つ。', 'A solo performance on a moving truck keeps bodily spontaneity and the passing city in close relation.', 10),
  ('bjork-big-time-sensuality', 'dance-camera', 'significant', 'notable_example', false, '移動するトラック上の一人の歌唱に要素を絞り、都市の流れと身体の即興性を近い距離で保つ。', 'A solo performance on a moving truck keeps bodily spontaneity and the passing city in close relation.', 20),
  ('beastie-boys-sabotage', 'long-form-narrative', 'primary', 'notable_example', true, '架空の刑事番組として追跡と対決を連ね、急なズーム、走行、転倒の編集で楽曲の切迫感を増幅する。', 'A fictional police-show narrative uses abrupt zooms, running, falls, and collision cuts to amplify the song''s urgency.', 10),
  ('beastie-boys-sabotage', 'rhythmic-editing', 'significant', 'defining_example', true, '架空の刑事番組として追跡と対決を連ね、急なズーム、走行、転倒の編集で楽曲の切迫感を増幅する。', 'A fictional police-show narrative uses abrupt zooms, running, falls, and collision cuts to amplify the song''s urgency.', 20),
  ('nine-inch-nails-closer', 'surrealism', 'primary', 'defining_example', true, '医学、宗教、機械、動物の像を悪夢的に連ね、振動と瞬間的暗転を音の脈動へ結び付ける。', 'Medical, religious, mechanical, and animal images form a nightmare sequence whose vibration and black frames bind image to pulse.', 10),
  ('nine-inch-nails-closer', 'rhythmic-editing', 'significant', 'notable_example', false, '医学、宗教、機械、動物の像を悪夢的に連ね、振動と瞬間的暗転を音の脈動へ結び付ける。', 'Medical, religious, mechanical, and animal images form a nightmare sequence whose vibration and black frames bind image to pulse.', 20),
  ('soundgarden-black-hole-sun', 'body-transformation', 'primary', 'defining_example', true, '郊外の顔と身体を過度に変形し、穏やかな日常を終末的で不穏な寓話へ反転する。', 'Excessive deformation of suburban faces and bodies reverses calm everyday life into an uncanny apocalyptic fable.', 10),
  ('soundgarden-black-hole-sun', 'surrealism', 'significant', 'notable_example', false, '郊外の顔と身体を過度に変形し、穏やかな日常を終末的で不穏な寓話へ反転する。', 'Excessive deformation of suburban faces and bodies reverses calm everyday life into an uncanny apocalyptic fable.', 20),
  ('aphex-twin-come-to-daddy', 'body-transformation', 'primary', 'defining_example', true, '子どもたちの顔を同一の成人男性へ置き換え、団地での発見と襲撃を怪物譚として進める。', 'Replacing the children''s faces with the same adult man turns discovery and assault on the estate into a monster narrative.', 10),
  ('aphex-twin-come-to-daddy', 'long-form-narrative', 'significant', 'notable_example', false, '子どもたちの顔を同一の成人男性へ置き換え、団地での発見と襲撃を怪物譚として進める。', 'Replacing the children''s faces with the same adult man turns discovery and assault on the estate into a monster narrative.', 20),
  ('foo-fighters-everlong', 'forced-perspective', 'primary', 'notable_example', true, '巨大化した手と歪んだ室内で夢の身体感覚を示し、眠り、侵入、変身、覚醒を複数の筋へ組む。', 'Enlarged hands and distorted rooms render dreamlike bodily scale within intersecting stories of sleep, intrusion, transformation, and waking.', 10),
  ('foo-fighters-everlong', 'long-form-narrative', 'significant', 'notable_example', false, '巨大化した手と歪んだ室内で夢の身体感覚を示し、眠り、侵入、変身、覚醒を複数の筋へ組む。', 'Enlarged hands and distorted rooms render dreamlike bodily scale within intersecting stories of sleep, intrusion, transformation, and waking.', 20),
  ('missy-elliott-the-rain-supa-dupa-fly', 'performance-film', 'primary', 'defining_example', true, '魚眼的な近接、黒い膨張スーツ、鮮明な背景が人物の存在感を単純で強い形へ押し広げる。', 'Fisheye proximity, the inflated black suit, and vivid backgrounds expand the performer''s presence into simple, forceful shapes.', 10),
  ('missy-elliott-the-rain-supa-dupa-fly', 'graphic-composition', 'significant', 'notable_example', false, '魚眼的な近接、黒い膨張スーツ、鮮明な背景が人物の存在感を単純で強い形へ押し広げる。', 'Fisheye proximity, the inflated black suit, and vivid backgrounds expand the performer''s presence into simple, forceful shapes.', 20)
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
where w.slug in ('peter-gabriel-sledgehammer', 'madonna-like-a-prayer', 'guns-n-roses-november-rain', 'bjork-big-time-sensuality', 'beastie-boys-sabotage', 'nine-inch-nails-closer', 'soundgarden-black-hole-sun', 'aphex-twin-come-to-daddy', 'foo-fighters-everlong', 'missy-elliott-the-rain-supa-dupa-fly')
  and wvl.verification_status = 'verified'
on conflict (work_visual_language_id, source_id) do update set
  supports_fields = excluded.supports_fields,
  is_primary = excluded.is_primary,
  notes = excluded.notes;

commit;
