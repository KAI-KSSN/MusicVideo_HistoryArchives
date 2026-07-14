-- MVHL Knowledge Graph Sprint 2 — published works batch 01
-- Individually reviewed, source-backed, and safely rerunnable.
begin;


insert into public.sources (source_type, title, publisher, url, accessed_at, notes)
values
  ('publication', 'How Dire Straits Shattered the Music Video Mold with ‘Money for Nothing’', 'VICE', 'https://www.vice.com/en/article/dire-straits-money-for-nothing-video/', current_date, 'Director Steve Barron describes the computer-generated workers and digitally treated performance footage.')
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
    'queen-bohemian-rhapsody',
    'none',
    'assigned',
    '四人の顔を菱形に重ねた正面構図と演奏映像の往復が、楽曲の劇性を象徴的な図像へ変える。', 'The frontal diamond of four faces and the return to performance turn the song''s theatricality into an emblematic image.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'abba-take-a-chance-on-me',
    'none',
    'assigned',
    '四分割された画面とパネルの組み替えが、各メンバーの歌唱と声部の受け渡しを同時に整理する。', 'A four-way split and recombined panels organize each member''s performance and the exchange of vocal parts simultaneously.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'the-buggles-video-killed-the-radio-star',
    'none',
    'assigned',
    '演奏を中心に円形モニターと幾何学的セットを配置し、放送メディアを正面性の高い図像として見せる。', 'Performance, circular monitors, and geometric sets turn broadcast media into a highly frontal graphic image.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'the-clash-london-calling',
    'none',
    'assigned',
    '雨の夜の演奏という一つの状況に限定し、身体、楽器、天候の強度を前景化する。', 'The work stays within one rain-soaked night performance, foregrounding bodies, instruments, and weather.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'david-bowie-ashes-to-ashes',
    'none',
    'assigned',
    '海辺、白い部屋、道化師の身体を反転色と平面的な構図で接続し、因果から離れた夢の連鎖を作る。', 'Beach, white room, and Pierrot body are joined through inverted color and flattened composition as a dream sequence outside ordinary causality.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'herbie-hancock-rockit',
    'none',
    'assigned',
    '義肢、マネキン、機械装置の反復運動を室内に配し、空間全体を不穏な演奏体のように動かす。', 'Repeated motion by prostheses, mannequins, and machines turns the whole domestic space into an uncanny performing body.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'michael-jackson-thriller',
    'preserved',
    'preserved',
    'Pilot relationships preserved unchanged.', 'Pilot relationships preserved unchanged.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'duran-duran-the-wild-boys',
    'none',
    'assigned',
    '巨大な装置と群衆の中に演奏を組み込み、人物、群衆、可動セットを一つの儀式空間として配置する。', 'Performance, crowds, and monumental moving sets are arranged as one ritual space.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'a-ha-take-on-me',
    'preserved',
    'preserved',
    'Pilot relationships preserved unchanged.', 'Pilot relationships preserved unchanged.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'dire-straits-money-for-nothing',
    'assigned',
    'assigned',
    '初期CGの人物世界とデジタル処理された演奏映像を対置し、現実と消費社会のシミュレーションを往復する。', 'An early-CGI character world is set against digitally treated performance, moving between reality and a simulation of consumer culture.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'madonna-material-girl',
    'none',
    'assigned',
    '映画的な舞台で群舞と歌唱を展開し、全身像と寄りの切替でスター像を上演として構築する。', 'Ensemble dance and song unfold on a cinematic stage, with full figures and closer views constructing star image as performance.',
    array['No additional relationship was assigned from visual resemblance or unsupported technical inference.']::text[], array[]::text[]
  ),
(
    'genesis-land-of-confusion',
    'none',
    'assigned',
    '政治家やバンドの人形を悪夢的な出来事へ投入し、時事像を誇張された寓話へ変える。', 'Puppets of politicians and the band are placed in nightmare events, turning current affairs into an exaggerated allegory.',
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
  ('dire-straits-money-for-nothing', 'cgi', 'primary', 'defining_use', true, '初期CGの人物世界とデジタル処理された演奏映像を対置し、現実と消費社会のシミュレーションを往復する。', 'An early-CGI character world is set against digitally treated performance, moving between reality and a simulation of consumer culture.', 10)
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
  ('dire-straits-money-for-nothing', 'cgi', 'https://www.vice.com/en/article/dire-straits-money-for-nothing-video/', true, 'Director Steve Barron describes the computer-generated workers and digitally treated performance footage.')
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
  ('queen-bohemian-rhapsody', 'graphic-composition', 'primary', 'defining_example', true, '四人の顔を菱形に重ねた正面構図と演奏映像の往復が、楽曲の劇性を象徴的な図像へ変える。', 'The frontal diamond of four faces and the return to performance turn the song''s theatricality into an emblematic image.', 10),
  ('queen-bohemian-rhapsody', 'performance-film', 'significant', 'notable_example', false, '四人の顔を菱形に重ねた正面構図と演奏映像の往復が、楽曲の劇性を象徴的な図像へ変える。', 'The frontal diamond of four faces and the return to performance turn the song''s theatricality into an emblematic image.', 20),
  ('abba-take-a-chance-on-me', 'split-screen', 'primary', 'defining_example', true, '四分割された画面とパネルの組み替えが、各メンバーの歌唱と声部の受け渡しを同時に整理する。', 'A four-way split and recombined panels organize each member''s performance and the exchange of vocal parts simultaneously.', 10),
  ('abba-take-a-chance-on-me', 'multi-panel-composition', 'significant', 'notable_example', false, '四分割された画面とパネルの組み替えが、各メンバーの歌唱と声部の受け渡しを同時に整理する。', 'A four-way split and recombined panels organize each member''s performance and the exchange of vocal parts simultaneously.', 20),
  ('the-buggles-video-killed-the-radio-star', 'performance-film', 'primary', 'notable_example', true, '演奏を中心に円形モニターと幾何学的セットを配置し、放送メディアを正面性の高い図像として見せる。', 'Performance, circular monitors, and geometric sets turn broadcast media into a highly frontal graphic image.', 10),
  ('the-buggles-video-killed-the-radio-star', 'graphic-composition', 'significant', 'notable_example', false, '演奏を中心に円形モニターと幾何学的セットを配置し、放送メディアを正面性の高い図像として見せる。', 'Performance, circular monitors, and geometric sets turn broadcast media into a highly frontal graphic image.', 20),
  ('the-clash-london-calling', 'performance-film', 'primary', 'notable_example', true, '雨の夜の演奏という一つの状況に限定し、身体、楽器、天候の強度を前景化する。', 'The work stays within one rain-soaked night performance, foregrounding bodies, instruments, and weather.', 10),
  ('david-bowie-ashes-to-ashes', 'surrealism', 'primary', 'defining_example', true, '海辺、白い部屋、道化師の身体を反転色と平面的な構図で接続し、因果から離れた夢の連鎖を作る。', 'Beach, white room, and Pierrot body are joined through inverted color and flattened composition as a dream sequence outside ordinary causality.', 10),
  ('david-bowie-ashes-to-ashes', 'graphic-composition', 'significant', 'notable_example', false, '海辺、白い部屋、道化師の身体を反転色と平面的な構図で接続し、因果から離れた夢の連鎖を作る。', 'Beach, white room, and Pierrot body are joined through inverted color and flattened composition as a dream sequence outside ordinary causality.', 20),
  ('herbie-hancock-rockit', 'spatial-choreography', 'primary', 'defining_example', true, '義肢、マネキン、機械装置の反復運動を室内に配し、空間全体を不穏な演奏体のように動かす。', 'Repeated motion by prostheses, mannequins, and machines turns the whole domestic space into an uncanny performing body.', 10),
  ('herbie-hancock-rockit', 'surrealism', 'significant', 'notable_example', false, '義肢、マネキン、機械装置の反復運動を室内に配し、空間全体を不穏な演奏体のように動かす。', 'Repeated motion by prostheses, mannequins, and machines turns the whole domestic space into an uncanny performing body.', 20),
  ('duran-duran-the-wild-boys', 'performance-film', 'primary', 'notable_example', true, '巨大な装置と群衆の中に演奏を組み込み、人物、群衆、可動セットを一つの儀式空間として配置する。', 'Performance, crowds, and monumental moving sets are arranged as one ritual space.', 10),
  ('duran-duran-the-wild-boys', 'spatial-choreography', 'significant', 'notable_example', false, '巨大な装置と群衆の中に演奏を組み込み、人物、群衆、可動セットを一つの儀式空間として配置する。', 'Performance, crowds, and monumental moving sets are arranged as one ritual space.', 20),
  ('dire-straits-money-for-nothing', 'mixed-media', 'primary', 'defining_example', true, '初期CGの人物世界とデジタル処理された演奏映像を対置し、現実と消費社会のシミュレーションを往復する。', 'An early-CGI character world is set against digitally treated performance, moving between reality and a simulation of consumer culture.', 10),
  ('madonna-material-girl', 'performance-film', 'primary', 'notable_example', true, '映画的な舞台で群舞と歌唱を展開し、全身像と寄りの切替でスター像を上演として構築する。', 'Ensemble dance and song unfold on a cinematic stage, with full figures and closer views constructing star image as performance.', 10),
  ('madonna-material-girl', 'dance-camera', 'significant', 'notable_example', false, '映画的な舞台で群舞と歌唱を展開し、全身像と寄りの切替でスター像を上演として構築する。', 'Ensemble dance and song unfold on a cinematic stage, with full figures and closer views constructing star image as performance.', 20),
  ('genesis-land-of-confusion', 'surrealism', 'primary', 'defining_example', true, '政治家やバンドの人形を悪夢的な出来事へ投入し、時事像を誇張された寓話へ変える。', 'Puppets of politicians and the band are placed in nightmare events, turning current affairs into an exaggerated allegory.', 10),
  ('genesis-land-of-confusion', 'performance-film', 'supporting', 'notable_example', false, '政治家やバンドの人形を悪夢的な出来事へ投入し、時事像を誇張された寓話へ変える。', 'Puppets of politicians and the band are placed in nightmare events, turning current affairs into an exaggerated allegory.', 20)
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
where w.slug in ('queen-bohemian-rhapsody', 'abba-take-a-chance-on-me', 'the-buggles-video-killed-the-radio-star', 'the-clash-london-calling', 'david-bowie-ashes-to-ashes', 'herbie-hancock-rockit', 'duran-duran-the-wild-boys', 'dire-straits-money-for-nothing', 'madonna-material-girl', 'genesis-land-of-confusion')
  and wvl.verification_status = 'verified'
on conflict (work_visual_language_id, source_id) do update set
  supports_fields = excluded.supports_fields,
  is_primary = excluded.is_primary,
  notes = excluded.notes;

commit;
