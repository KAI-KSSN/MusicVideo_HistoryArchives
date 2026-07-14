-- MVHL Knowledge Graph Sprint 2 — published works batch 03
-- Individually reviewed, source-backed, and safely rerunnable.
begin;


insert into public.sources (source_type, title, publisher, url, accessed_at, notes)
values
  ('vfx_company', 'All Is Full of Love', 'Glassworks', 'https://www.glassworks.co.uk/content/all-full-love', current_date, 'The VFX-company case study credits the 3D and Flame teams.')
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
    'radiohead-karma-police',
    'none',
    'assigned',
    '車前方の視点を長く維持し、追跡から反転までをほぼ連続した最小限の物語として経験させる。', 'A sustained forward car view makes pursuit and reversal feel like a nearly continuous, minimal narrative.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'the-prodigy-smack-my-bitch-up',
    'none',
    'assigned',
    '視界と身体断片だけで夜を一人称として進め、最後の鏡像で想定していた人物像を再解釈させる。', 'Vision and body fragments carry the night in first person, with the final mirror forcing a reinterpretation of the assumed character.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'madonna-frozen',
    'none',
    'assigned',
    '身体が布、影、複数像、鳥へ変わり、無人の砂漠を物理法則から離れた儀式空間へ変える。', 'The body shifts through cloth, shadow, multiples, and birds, turning an empty desert into a ritual space outside ordinary physics.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'massive-attack-teardrop',
    'none',
    'assigned',
    '胎児の顔、呼吸、口の動きだけに限定し、不可能な歌唱を静かな最小の身体表現として提示する。', 'The frame is limited to a fetus''s face, breathing, and mouth, presenting impossible song as quiet minimal performance.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'bjork-all-is-full-of-love',
    'assigned',
    'assigned',
    '三次元ロボットと実写素材を白い環境に統合し、組立てられる身体と二体の接触を最小限の出来事へ絞る。', '3D robots and live-action material are integrated in a white space, reducing assembly and contact between two bodies to the central event.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'blur-coffee-and-tv',
    'none',
    'assigned',
    '行方不明者を探す牛乳パックの旅を、出発、遭遇、喪失、帰還まで一貫した物語として描く。', 'A milk carton''s search for a missing person unfolds as a complete story of departure, encounters, loss, and return.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'chemical-brothers-let-forever-be',
    'none',
    'assigned',
    '実景と万華鏡的な舞台を形と動きで接続し、人物と幾何学模様を切れ目なく置換する。', 'Shapes and movements connect real locations to kaleidoscopic stages while figures and geometric patterns replace one another continuously.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'red-hot-chili-peppers-californication',
    'none',
    'assigned',
    '実写演奏とゲーム世界を往復し、インターフェース、スコア、地形を画面を読む規則として用いる。', 'Live performance alternates with a game world whose interface, scores, and terrain become rules for reading the image.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'fatboy-slim-weapon-of-choice',
    'preserved',
    'preserved',
    'Pilot relationships preserved unchanged.', 'Pilot relationships preserved unchanged.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'hikaru-utada-traveling',
    'none',
    'assigned',
    '強い色面と反復図形が列車、宇宙、遊園地を接続し、旅を想像上の空間移動として見せる。', 'Strong color fields and repeated shapes connect train, space, and amusement park, presenting travel as imaginary spatial movement.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'coldplay-the-scientist',
    'none',
    'assigned',
    '結果から原因へ時間を逆行し、歩行、車内、事故を通して歌唱を記憶の移動として組み込む。', 'Time moves backward from consequence to cause, embedding performance as a journey through walking, the car, and the crash.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'royksopp-remind-me',
    'none',
    'assigned',
    '通勤、労働、消費、都市インフラを等角投影の情報図として示し、日常を可視化されたシステムとして読む。', 'Commuting, work, consumption, and infrastructure appear as isometric information graphics, reading everyday life as a visualized system.',
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
  ('bjork-all-is-full-of-love', 'cgi', 'primary', 'defining_use', true, '三次元ロボットと実写素材を白い環境に統合し、組立てられる身体と二体の接触を最小限の出来事へ絞る。', '3D robots and live-action material are integrated in a white space, reducing assembly and contact between two bodies to the central event.', 10),
  ('bjork-all-is-full-of-love', 'digital-compositing', 'significant', 'defining_use', false, '三次元ロボットと実写素材を白い環境に統合し、組立てられる身体と二体の接触を最小限の出来事へ絞る。', '3D robots and live-action material are integrated in a white space, reducing assembly and contact between two bodies to the central event.', 20)
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
  ('bjork-all-is-full-of-love', 'cgi', 'https://www.glassworks.co.uk/content/all-full-love', true, 'The VFX-company case study credits the 3D and Flame teams.'),
  ('bjork-all-is-full-of-love', 'digital-compositing', 'https://www.glassworks.co.uk/content/all-full-love', true, 'The VFX-company case study credits the 3D and Flame teams.')
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
  ('radiohead-karma-police', 'continuous-shot-illusion', 'primary', 'notable_example', true, '車前方の視点を長く維持し、追跡から反転までをほぼ連続した最小限の物語として経験させる。', 'A sustained forward car view makes pursuit and reversal feel like a nearly continuous, minimal narrative.', 10),
  ('radiohead-karma-police', 'long-form-narrative', 'significant', 'notable_example', false, '車前方の視点を長く維持し、追跡から反転までをほぼ連続した最小限の物語として経験させる。', 'A sustained forward car view makes pursuit and reversal feel like a nearly continuous, minimal narrative.', 20),
  ('the-prodigy-smack-my-bitch-up', 'pov', 'primary', 'defining_example', true, '視界と身体断片だけで夜を一人称として進め、最後の鏡像で想定していた人物像を再解釈させる。', 'Vision and body fragments carry the night in first person, with the final mirror forcing a reinterpretation of the assumed character.', 10),
  ('the-prodigy-smack-my-bitch-up', 'first-person', 'primary', 'defining_example', true, '視界と身体断片だけで夜を一人称として進め、最後の鏡像で想定していた人物像を再解釈させる。', 'Vision and body fragments carry the night in first person, with the final mirror forcing a reinterpretation of the assumed character.', 20),
  ('madonna-frozen', 'continuous-transformation', 'primary', 'notable_example', true, '身体が布、影、複数像、鳥へ変わり、無人の砂漠を物理法則から離れた儀式空間へ変える。', 'The body shifts through cloth, shadow, multiples, and birds, turning an empty desert into a ritual space outside ordinary physics.', 10),
  ('madonna-frozen', 'surrealism', 'significant', 'notable_example', false, '身体が布、影、複数像、鳥へ変わり、無人の砂漠を物理法則から離れた儀式空間へ変える。', 'The body shifts through cloth, shadow, multiples, and birds, turning an empty desert into a ritual space outside ordinary physics.', 20),
  ('massive-attack-teardrop', 'minimal-performance', 'primary', 'defining_example', true, '胎児の顔、呼吸、口の動きだけに限定し、不可能な歌唱を静かな最小の身体表現として提示する。', 'The frame is limited to a fetus''s face, breathing, and mouth, presenting impossible song as quiet minimal performance.', 10),
  ('massive-attack-teardrop', 'surrealism', 'significant', 'notable_example', false, '胎児の顔、呼吸、口の動きだけに限定し、不可能な歌唱を静かな最小の身体表現として提示する。', 'The frame is limited to a fetus''s face, breathing, and mouth, presenting impossible song as quiet minimal performance.', 20),
  ('bjork-all-is-full-of-love', 'body-transformation', 'primary', 'defining_example', true, '三次元ロボットと実写素材を白い環境に統合し、組立てられる身体と二体の接触を最小限の出来事へ絞る。', '3D robots and live-action material are integrated in a white space, reducing assembly and contact between two bodies to the central event.', 10),
  ('bjork-all-is-full-of-love', 'minimal-performance', 'significant', 'notable_example', false, '三次元ロボットと実写素材を白い環境に統合し、組立てられる身体と二体の接触を最小限の出来事へ絞る。', '3D robots and live-action material are integrated in a white space, reducing assembly and contact between two bodies to the central event.', 20),
  ('blur-coffee-and-tv', 'long-form-narrative', 'primary', 'defining_example', true, '行方不明者を探す牛乳パックの旅を、出発、遭遇、喪失、帰還まで一貫した物語として描く。', 'A milk carton''s search for a missing person unfolds as a complete story of departure, encounters, loss, and return.', 10),
  ('chemical-brothers-let-forever-be', 'match-cut', 'primary', 'defining_example', true, '実景と万華鏡的な舞台を形と動きで接続し、人物と幾何学模様を切れ目なく置換する。', 'Shapes and movements connect real locations to kaleidoscopic stages while figures and geometric patterns replace one another continuously.', 10),
  ('chemical-brothers-let-forever-be', 'continuous-transformation', 'significant', 'defining_example', true, '実景と万華鏡的な舞台を形と動きで接続し、人物と幾何学模様を切れ目なく置換する。', 'Shapes and movements connect real locations to kaleidoscopic stages while figures and geometric patterns replace one another continuously.', 20),
  ('red-hot-chili-peppers-californication', 'mixed-media', 'primary', 'notable_example', true, '実写演奏とゲーム世界を往復し、インターフェース、スコア、地形を画面を読む規則として用いる。', 'Live performance alternates with a game world whose interface, scores, and terrain become rules for reading the image.', 10),
  ('red-hot-chili-peppers-californication', 'graphic-composition', 'significant', 'notable_example', false, '実写演奏とゲーム世界を往復し、インターフェース、スコア、地形を画面を読む規則として用いる。', 'Live performance alternates with a game world whose interface, scores, and terrain become rules for reading the image.', 20),
  ('hikaru-utada-traveling', 'graphic-composition', 'primary', 'notable_example', true, '強い色面と反復図形が列車、宇宙、遊園地を接続し、旅を想像上の空間移動として見せる。', 'Strong color fields and repeated shapes connect train, space, and amusement park, presenting travel as imaginary spatial movement.', 10),
  ('hikaru-utada-traveling', 'surrealism', 'significant', 'notable_example', false, '強い色面と反復図形が列車、宇宙、遊園地を接続し、旅を想像上の空間移動として見せる。', 'Strong color fields and repeated shapes connect train, space, and amusement park, presenting travel as imaginary spatial movement.', 20),
  ('coldplay-the-scientist', 'reverse-narrative', 'primary', 'defining_example', true, '結果から原因へ時間を逆行し、歩行、車内、事故を通して歌唱を記憶の移動として組み込む。', 'Time moves backward from consequence to cause, embedding performance as a journey through walking, the car, and the crash.', 10),
  ('coldplay-the-scientist', 'long-form-narrative', 'significant', 'notable_example', false, '結果から原因へ時間を逆行し、歩行、車内、事故を通して歌唱を記憶の移動として組み込む。', 'Time moves backward from consequence to cause, embedding performance as a journey through walking, the car, and the crash.', 20),
  ('royksopp-remind-me', 'data-visualization', 'primary', 'defining_example', true, '通勤、労働、消費、都市インフラを等角投影の情報図として示し、日常を可視化されたシステムとして読む。', 'Commuting, work, consumption, and infrastructure appear as isometric information graphics, reading everyday life as a visualized system.', 10),
  ('royksopp-remind-me', 'graphic-composition', 'significant', 'notable_example', false, '通勤、労働、消費、都市インフラを等角投影の情報図として示し、日常を可視化されたシステムとして読む。', 'Commuting, work, consumption, and infrastructure appear as isometric information graphics, reading everyday life as a visualized system.', 20)
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
where w.slug in ('radiohead-karma-police', 'the-prodigy-smack-my-bitch-up', 'madonna-frozen', 'massive-attack-teardrop', 'bjork-all-is-full-of-love', 'blur-coffee-and-tv', 'chemical-brothers-let-forever-be', 'red-hot-chili-peppers-californication', 'hikaru-utada-traveling', 'coldplay-the-scientist', 'royksopp-remind-me')
  and wvl.verification_status = 'verified'
on conflict (work_visual_language_id, source_id) do update set
  supports_fields = excluded.supports_fields,
  is_primary = excluded.is_primary,
  notes = excluded.notes;

commit;
