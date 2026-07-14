-- MVHL standard work-addition reference implementation:
-- Kylie Minogue — Come Into My World.
-- Safely rerunnable; all relationships use the resolved UUID and stable slugs.

begin;

create temporary table _mvhl_target_work (id uuid primary key) on commit drop;

do $$
declare
  v_count integer;
  v_work_id uuid;
  v_work_type_id bigint;
begin
  select count(distinct w.id)
    into v_count
  from public.works w
  where w.slug in ('kylie-minogue-come-into-my-world', 'come-into-my-world')
     or exists (
       select 1 from public.media_assets ma
       where ma.work_id = w.id
         and ma.platform = 'youtube'
         and ma.external_id = '63vqob-MljQ'
     )
     or (
       regexp_replace(lower(w.title), '[^a-z0-9]+', '', 'g') = 'comeintomyworld'
       and exists (
         select 1
         from public.work_credits wc
         join public.credit_roles cr on cr.id = wc.role_id and cr.code = 'artist'
         join public.entities e on e.id = wc.entity_id
         where wc.work_id = w.id
           and regexp_replace(lower(e.display_name), '[^a-z0-9]+', '', 'g') = 'kylieminogue'
       )
     );

  if v_count > 1 then
    raise exception 'Duplicate work candidates found for Come Into My World';
  end if;

  if v_count = 1 then
    select w.id into v_work_id
    from public.works w
    where w.slug in ('kylie-minogue-come-into-my-world', 'come-into-my-world')
       or exists (
         select 1 from public.media_assets ma
         where ma.work_id = w.id
           and ma.platform = 'youtube'
           and ma.external_id = '63vqob-MljQ'
       )
       or (
         regexp_replace(lower(w.title), '[^a-z0-9]+', '', 'g') = 'comeintomyworld'
         and exists (
           select 1
           from public.work_credits wc
           join public.credit_roles cr on cr.id = wc.role_id and cr.code = 'artist'
           join public.entities e on e.id = wc.entity_id
           where wc.work_id = w.id
             and regexp_replace(lower(e.display_name), '[^a-z0-9]+', '', 'g') = 'kylieminogue'
         )
       )
    limit 1;
  end if;

  if v_count = 0 then
    select id into v_work_type_id from public.work_types where code = 'music_video';
    if v_work_type_id is null then raise exception 'music_video work type is missing'; end if;

    insert into public.works (
      work_type_id, slug, title, original_title, release_year, country_code,
      language_code, status, is_canonical, verification_notes
    ) values (
      v_work_type_id, 'kylie-minogue-come-into-my-world', 'Come Into My World',
      'Come Into My World', 2002, 'AU', 'en', 'researching', false,
      'Standard work-addition workflow v1. Release date and unverified crew fields remain NULL. Award registry reviewed; no verified video-specific result found.'
    ) returning id into v_work_id;
  end if;

  insert into _mvhl_target_work(id) values (v_work_id);
end $$;

update public.works w set
  slug = 'kylie-minogue-come-into-my-world',
  title = 'Come Into My World',
  original_title = 'Come Into My World',
  release_date = null,
  release_year = 2002,
  country_code = 'AU',
  language_code = 'en',
  status = 'researching',
  is_canonical = false,
  verified_at = null,
  published_at = null,
  verification_notes = 'Standard work-addition workflow v1. Release date, cinematography, editing, choreography, production design, aspect ratio and original release format remain NULL. Complete MVHL award registry reviewed; no verified video-specific result found. Grammy Best Dance Recording and ARIA recording/artist results were excluded. Secondary-only VMAJ and UK CADS claims remain unresolved and were not registered.'
where w.id = (select id from _mvhl_target_work);

insert into public.entities (slug, display_name, entity_type, country_code, official_url) values
  ('kylie-minogue', 'Kylie Minogue', 'person', 'AU', 'https://www.kylie.com/'),
  ('michel-gondry', 'Michel Gondry', 'person', 'FR', 'https://partizan.com/director/michel-gondry/films-tv-series/'),
  ('partizan', 'Partizan', 'company', null, 'https://partizan.com/'),
  ('twisted-laboratories', 'Twisted Laboratories', 'company', null, null),
  ('olivier-gondry', 'Olivier Gondry', 'person', 'FR', null)
on conflict (slug) do update set
  display_name = excluded.display_name,
  entity_type = excluded.entity_type,
  country_code = coalesce(public.entities.country_code, excluded.country_code),
  official_url = coalesce(public.entities.official_url, excluded.official_url);

insert into public.music_video_details (work_id, label, album, runtime_seconds, official_release_url)
select id, 'Parlophone', null, 255, 'https://www.youtube.com/watch?v=63vqob-MljQ'
from _mvhl_target_work
on conflict (work_id) do update set
  label = excluded.label,
  album = excluded.album,
  runtime_seconds = excluded.runtime_seconds,
  official_release_url = excluded.official_release_url;

insert into public.work_credits (work_id, entity_id, role_id, credit_order, verification_status, notes)
select tw.id, e.id, cr.id, d.credit_order, 'verified', d.notes
from _mvhl_target_work tw
join (values
  ('kylie-minogue', 'artist', 1, 'Official artist-channel video.'),
  ('michel-gondry', 'director', 1, 'Confirmed by the Partizan director portfolio and Directors’ Library.'),
  ('partizan', 'production_company', 1, 'The work is listed in Partizan’s Michel Gondry portfolio.'),
  ('twisted-laboratories', 'vfx_production', 1, 'Olivier Gondry identifies Twisted Laboratories as the post company.'),
  ('olivier-gondry', 'vfx_supervisor', 1, 'Crew interview identifies Olivier Gondry as leading the rotoscoping and compositing workflow.')
) d(entity_slug, role_code, credit_order, notes) on true
join public.entities e on e.slug = d.entity_slug
join public.credit_roles cr on cr.code = d.role_code
on conflict (work_id, entity_id, role_id) do update set
  credit_order = excluded.credit_order,
  verification_status = 'verified',
  notes = excluded.notes;

insert into public.work_editorials (
  work_id, locale, short_summary, why_it_matters, historical_context,
  key_innovation, editorial_notes, verification_status, reviewed_at
)
select tw.id, d.locale, d.short_summary, d.why_it_matters, d.historical_context,
  d.key_innovation, d.editorial_notes, 'verified', now()
from _mvhl_target_work tw
join (values
  ('ja',
    '同じ街区を巡る反復可能なカメラ移動の中で、人物と出来事が周回ごとに増殖していく長回し風のミュージックビデオ。',
    'モーションコントロール撮影とデジタル合成を、単なる特殊効果ではなく映像全体の時間構造へ組み込んだ、ループ表現の代表的作品。',
    '2000年代初頭、成熟しつつあったデジタル合成は、MVにおいて複雑な技術を明快な一つの発想へ集約するために用いられた。本作は、同一カメラ移動の反復と人物の増殖を組み合わせ、循環する時間を視覚的に理解できる構造へ変換している。',
    '同一のカメラ軌道を複数回反復し、各テイクをロトスコープとデジタル合成で重ねることで、現実の街路を時間の層が蓄積するループ空間へ変化させている。',
    'Acquisition reason: a source-supported reference work for motion control, compositing and loop-based visual structure.'),
  ('en',
    'A continuous-shot illusion in which repeated journeys around the same city block allow performers and events to multiply with each cycle.',
    'A defining music-video use of motion control and digital compositing, integrating repeated camera movement into the work’s entire temporal structure rather than treating it as a standalone visual effect.',
    'In the early 2000s, increasingly sophisticated digital compositing was often distilled into clear, singular concepts within music videos. This work combines repeatable camera movement with accumulating performers, turning cyclical time into a visually legible structure.',
    'Repeated passes along the same camera path are combined through rotoscoping and digital compositing, transforming an ordinary street into a looping space that accumulates layers of time.',
    'Acquisition reason: a source-supported reference work for motion control, compositing and loop-based visual structure.')
) d(locale, short_summary, why_it_matters, historical_context, key_innovation, editorial_notes) on true
on conflict (work_id, locale) do update set
  short_summary = excluded.short_summary,
  why_it_matters = excluded.why_it_matters,
  historical_context = excluded.historical_context,
  key_innovation = excluded.key_innovation,
  editorial_notes = excluded.editorial_notes,
  verification_status = 'verified',
  reviewed_at = excluded.reviewed_at;

insert into public.media_assets (
  work_id, platform, asset_type, external_id, url, is_official,
  availability_status, last_checked_at
)
select id, 'youtube', 'full_video', '63vqob-MljQ',
  'https://www.youtube.com/watch?v=63vqob-MljQ', true, 'available', now()
from _mvhl_target_work
on conflict (platform, external_id) where external_id is not null do update set
  work_id = excluded.work_id,
  url = excluded.url,
  is_official = true,
  availability_status = 'available',
  last_checked_at = excluded.last_checked_at;

insert into public.media_assets (
  work_id, platform, asset_type, external_id, url, is_official,
  availability_status, last_checked_at
)
select id, 'youtube', 'thumbnail', null,
  'https://i.ytimg.com/vi/63vqob-MljQ/hqdefault.jpg', true, 'available', now()
from _mvhl_target_work
on conflict (work_id, url) do update set
  is_official = true,
  availability_status = 'available',
  last_checked_at = excluded.last_checked_at;

insert into public.sources (source_type, title, publisher, url, accessed_at, notes) values
  ('official_video', 'Kylie Minogue - Come Into My World (Official Video) [Full HD Remastered]', 'Kylie Minogue / YouTube', 'https://www.youtube.com/watch?v=63vqob-MljQ', current_date, 'Official artist-channel upload; identity, runtime and thumbnail verified.'),
  ('publication', 'Olivier Gondry on the making of Kylie Minogue’s Come Into My World', 'VFXBlog', 'https://vfxblog.com/2017/11/14/olivier-gondry-on-the-making-of-kylie-minogues-come-into-my-world/', current_date, 'Crew interview documenting motion control, choreography, rotoscoping, compositing, Twisted Laboratories and the 2002 release.'),
  ('production_company', 'Michel Gondry — Films & TV Series', 'Partizan', 'https://partizan.com/director/michel-gondry/films-tv-series/', current_date, 'Official production-company director portfolio listing the work.'),
  ('production_company', 'The 7 Uses of Motion Control', 'Mark Roberts Motion Control', 'https://www.mrmoco.com/the-7-uses-of-motion-control/', current_date, 'Official motion-control manufacturer account of the Milo repeated camera passes.'),
  ('publication', 'Come Into My World — Kylie Minogue', 'Directors’ Library', 'https://directorslibrary.com/2002/latest/music-videos/come-into-my-world-kylie-minogue/', current_date, 'Director and November 2002 listing.'),
  ('label', 'Come Into My World', 'Official Charts', 'https://www.officialcharts.com/songs/kylie-minogue-come-into-my-world/', current_date, 'Parlophone label and contemporary release context.'),
  ('other', 'Kylie Minogue', 'National Portrait Gallery, Australia', 'https://www.portrait.gov.au/people/kylie-minogue-1968', current_date, 'Institutional source for artist country.'),
  ('award_archive', 'ARIA Awards past winners 2003', 'ARIA', 'https://www.aria.com.au/awards/past-winners/2003', current_date, 'Official archive checked; recording/artist categories were excluded and the work is not listed for Best Video.'),
  ('award_archive', '46th Annual Grammy Awards', 'Recording Academy', 'https://www.grammy.com/awards/46th-annual-grammy-awards/', current_date, 'Official archive checked; Best Dance Recording is a recording result and was excluded from work_award_results.')
on conflict (url) do update set
  source_type = excluded.source_type,
  title = excluded.title,
  publisher = excluded.publisher,
  accessed_at = excluded.accessed_at,
  notes = excluded.notes;

insert into public.work_sources (work_id, source_id, supports_fields, is_primary, notes)
select tw.id, s.id, d.supports_fields, d.is_primary, d.notes
from _mvhl_target_work tw
join (values
  ('https://www.youtube.com/watch?v=63vqob-MljQ', array['official_title','artist','runtime','youtube_id','thumbnail']::text[], true, 'Official video identity and media metadata.'),
  ('https://vfxblog.com/2017/11/14/olivier-gondry-on-the-making-of-kylie-minogues-come-into-my-world/', array['release_year','production_method','vfx_production','vfx_supervisor','motion_control','digital_compositing','rotoscoping']::text[], true, 'Direct crew interview.'),
  ('https://partizan.com/director/michel-gondry/films-tv-series/', array['director','production_company']::text[], true, 'Official production-company portfolio.'),
  ('https://www.mrmoco.com/the-7-uses-of-motion-control/', array['motion_control','production_method']::text[], true, 'Official equipment manufacturer account.'),
  ('https://directorslibrary.com/2002/latest/music-videos/come-into-my-world-kylie-minogue/', array['director','release_year']::text[], false, 'Independent director archive.'),
  ('https://www.officialcharts.com/songs/kylie-minogue-come-into-my-world/', array['label','release_context']::text[], false, 'Official chart archive.'),
  ('https://www.portrait.gov.au/people/kylie-minogue-1968', array['country']::text[], false, 'Institutional artist source.'),
  ('https://www.aria.com.au/awards/past-winners/2003', array['award_audit']::text[], true, 'Checked negative/excluded video-award result.'),
  ('https://www.grammy.com/awards/46th-annual-grammy-awards/', array['award_audit']::text[], true, 'Recording-only result excluded from MV award data.')
) d(source_url, supports_fields, is_primary, notes) on true
join public.sources s on s.url = d.source_url
on conflict (work_id, source_id) do update set
  supports_fields = excluded.supports_fields,
  is_primary = excluded.is_primary,
  notes = excluded.notes;

insert into public.work_taxonomy_terms (work_id, term_id, confidence, assignment_method, notes)
select tw.id, tt.id, 1.000, 'editorial', 'Verified work-addition classification.'
from _mvhl_target_work tw
join public.taxonomy_terms tt on tt.slug in ('pop', 'international', '2000s', 'editing-loop')
join public.taxonomy_categories tc on tc.id = tt.category_id
  and tc.code in ('genre', 'region', 'era', 'movement')
on conflict (work_id, term_id) do update set
  confidence = excluded.confidence,
  assignment_method = excluded.assignment_method,
  notes = excluded.notes;

insert into public.knowledge_graph_work_reviews (
  work_id, sprint, technology_outcome, visual_language_outcome,
  review_note_ja, review_note_en, deliberately_not_assigned,
  unresolved_questions, reviewed_at
)
select id, 'work-addition-standard-v1', 'assigned', 'assigned',
  '制作スタッフの記録と公式映像を照合し、探索に有効な技術3件・映像言語3件だけを採用した。',
  'Crew documentation and the official video were reviewed; only three useful Technology and three Visual Language relationships were retained.',
  array['Graphic Composition: redundant for this work’s principal navigation paths.', 'Dance Camera: camera movement is organized around a repeatable spatial circuit rather than a camera/dance partnership.']::text[],
  array['VMAJ and UK CADS claims remain secondary-only and are not registered.']::text[], now()
from _mvhl_target_work
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
  verification_notes, note_ja, note_en, display_order, reviewed_at
)
select tw.id, t.id, d.usage_role, d.relevance, d.relationship_role,
  d.is_primary, 1.000, 'editorial', 'verified', d.evidence,
  d.note_ja, d.note_en, d.display_order, now()
from _mvhl_target_work tw
join (values
  ('motion-control', 'primary', 'primary', 'defining_use', true,
   '反復可能な同一カメラ移動を複数回撮影し、周回ごとに増える人物と出来事を同じ空間へ配置している。',
   'Repeatable camera passes allow performers and events from multiple cycles to occupy the same spatial composition.',
   'VFXBlog crew interview and Mark Roberts Motion Control official account.', 10),
  ('digital-compositing', 'supporting', 'significant', 'defining_use', false,
   '複数の撮影テイクを一つの連続した街路空間へ統合し、人物の増殖と時間の重なりを成立させている。',
   'Multiple filmed passes are integrated into one continuous streetscape, creating the accumulation of performers and overlapping time.',
   'VFXBlog crew interview.', 20),
  ('rotoscoping', 'supporting', 'supporting', 'standard_use', false,
   '各テイクの人物を精密に分離し、反復する街路の合成へ組み込むためにロトスコープが用いられた。',
   'Rotoscoping isolates performers from each pass so they can be integrated into the repeated streetscape.',
   'VFXBlog crew interview describes Olivier Gondry’s rotoscoping workflow.', 30)
) d(concept_slug, usage_role, relevance, relationship_role, is_primary, note_ja, note_en, evidence, display_order) on true
join public.technologies t on t.slug = d.concept_slug and t.lifecycle_status = 'published' and t.is_active
on conflict (work_id, technology_id) do update set
  usage_role = excluded.usage_role,
  relevance = excluded.relevance,
  relationship_role = excluded.relationship_role,
  is_primary = excluded.is_primary,
  confidence = excluded.confidence,
  assignment_method = excluded.assignment_method,
  verification_status = excluded.verification_status,
  verification_notes = excluded.verification_notes,
  note_ja = excluded.note_ja,
  note_en = excluded.note_en,
  display_order = excluded.display_order,
  reviewed_at = excluded.reviewed_at;

insert into public.work_technology_sources (work_technology_id, source_id, supports_fields, is_primary, notes)
select wt.id, s.id, array['technology','production_method']::text[], d.is_primary, d.notes
from _mvhl_target_work tw
join (values
  ('motion-control', 'https://vfxblog.com/2017/11/14/olivier-gondry-on-the-making-of-kylie-minogues-come-into-my-world/', true, 'Direct crew account.'),
  ('motion-control', 'https://www.mrmoco.com/the-7-uses-of-motion-control/', true, 'Official motion-control manufacturer account.'),
  ('digital-compositing', 'https://vfxblog.com/2017/11/14/olivier-gondry-on-the-making-of-kylie-minogues-come-into-my-world/', true, 'Direct crew account.'),
  ('rotoscoping', 'https://vfxblog.com/2017/11/14/olivier-gondry-on-the-making-of-kylie-minogues-come-into-my-world/', true, 'Direct crew account documenting the rotoscoping workflow.')
) d(concept_slug, source_url, is_primary, notes) on true
join public.technologies t on t.slug = d.concept_slug
join public.work_technologies wt on wt.work_id = tw.id and wt.technology_id = t.id
join public.sources s on s.url = d.source_url
on conflict (work_technology_id, source_id) do update set
  supports_fields = excluded.supports_fields,
  is_primary = excluded.is_primary,
  notes = excluded.notes;

insert into public.work_visual_languages (
  work_id, visual_language_id, prominence, relevance, relationship_role,
  is_primary, confidence, assignment_method, editorial_rationale,
  verification_status, verification_notes, note_ja, note_en,
  display_order, reviewed_at
)
select tw.id, vl.id, d.prominence, d.relevance, d.relationship_role,
  d.is_primary, 1.000, 'editorial', d.note_en, 'verified',
  'Formal analysis of the official video, supported by documented production structure.',
  d.note_ja, d.note_en, d.display_order, now()
from _mvhl_target_work tw
join (values
  ('loop', 'primary', 'primary', 'defining_example', true,
   '同じ街区を巡る移動を反復し、周回ごとの差分を蓄積することで、ループそのものを物語と画面構成の中心にしている。',
   'Repeated circuits around the same city block accumulate differences between each cycle, making the loop the central narrative and compositional device.', 10),
  ('continuous-shot-illusion', 'primary', 'primary', 'defining_example', true,
   '一続きの長回しに見える映像を、反復撮影と合成によって構築している。',
   'Repeated photography and compositing construct the appearance of one uninterrupted take.', 20),
  ('spatial-choreography', 'secondary', 'significant', 'defining_example', false,
   '歩行者、車両、演者の動線が、同じ街路空間の中で周回ごとに増えながら精密に配置される。',
   'Pedestrians, vehicles and performers are precisely arranged within the same streetscape as each cycle adds new activity.', 30)
) d(concept_slug, prominence, relevance, relationship_role, is_primary, note_ja, note_en, display_order) on true
join public.visual_languages vl on vl.slug = d.concept_slug and vl.lifecycle_status = 'published' and vl.is_active
on conflict (work_id, visual_language_id) do update set
  prominence = excluded.prominence,
  relevance = excluded.relevance,
  relationship_role = excluded.relationship_role,
  is_primary = excluded.is_primary,
  confidence = excluded.confidence,
  assignment_method = excluded.assignment_method,
  editorial_rationale = excluded.editorial_rationale,
  verification_status = excluded.verification_status,
  verification_notes = excluded.verification_notes,
  note_ja = excluded.note_ja,
  note_en = excluded.note_en,
  display_order = excluded.display_order,
  reviewed_at = excluded.reviewed_at;

insert into public.work_visual_language_sources (
  work_visual_language_id, source_id, supports_fields, is_primary, notes
)
select wvl.id, s.id, array['visual_language']::text[], true,
  'Official video used for direct formal analysis.'
from _mvhl_target_work tw
join public.work_visual_languages wvl on wvl.work_id = tw.id
join public.sources s on s.url = 'https://www.youtube.com/watch?v=63vqob-MljQ'
on conflict (work_visual_language_id, source_id) do update set
  supports_fields = excluded.supports_fields,
  is_primary = excluded.is_primary,
  notes = excluded.notes;

do $$
declare
  v_work_id uuid := (select id from _mvhl_target_work);
begin
  if (select count(*) from public.work_editorials where work_id = v_work_id and verification_status = 'verified' and locale in ('ja','en')) <> 2 then
    raise exception 'Bilingual verified editorial is incomplete';
  end if;
  if (select count(*) from public.work_technologies where work_id = v_work_id and verification_status = 'verified') <> 3 then
    raise exception 'Expected exactly three verified Technology relationships';
  end if;
  if exists (
    select 1 from public.work_technologies wt
    where wt.work_id = v_work_id and wt.verification_status = 'verified'
      and not exists (select 1 from public.work_technology_sources wts where wts.work_technology_id = wt.id)
  ) then raise exception 'Every verified Technology relationship requires a stored source'; end if;
  if (select count(*) from public.work_visual_languages where work_id = v_work_id and verification_status = 'verified') <> 3 then
    raise exception 'Expected exactly three verified Visual Language relationships';
  end if;
  if exists (
    select 1 from public.work_visual_languages wvl
    join public.visual_languages vl on vl.id = wvl.visual_language_id
    where wvl.work_id = v_work_id and vl.slug in ('graphic-composition','dance-camera')
  ) then raise exception 'Rejected Visual Language alternative was assigned'; end if;
  if (select count(*) from public.work_sources where work_id = v_work_id) < 7 then
    raise exception 'Insufficient source coverage';
  end if;
  if exists (select 1 from public.work_award_results where work_id = v_work_id) then
    raise exception 'No video-specific award result is verified for this work';
  end if;
  if not exists (
    select 1 from public.media_assets where work_id = v_work_id and asset_type = 'full_video'
      and external_id = '63vqob-MljQ' and availability_status = 'available'
  ) or not exists (
    select 1 from public.media_assets where work_id = v_work_id and asset_type = 'thumbnail'
      and availability_status = 'available'
  ) then raise exception 'Official video or thumbnail is incomplete'; end if;
end $$;

update public.works
set status = 'verified', verified_at = now(), last_reviewed_at = now()
where id = (select id from _mvhl_target_work);

update public.works
set status = 'published', published_at = now()
where id = (select id from _mvhl_target_work)
  and status = 'verified'
  and verified_at is not null;

do $$
begin
  if not exists (
    select 1 from public.works
    where id = (select id from _mvhl_target_work)
      and slug = 'kylie-minogue-come-into-my-world'
      and status = 'published'
  ) then raise exception 'Publication gate did not complete'; end if;
end $$;

commit;
