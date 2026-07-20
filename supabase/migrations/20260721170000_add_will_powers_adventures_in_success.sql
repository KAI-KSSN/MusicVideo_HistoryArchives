-- Standard work-addition workflow v1: Will Powers — Adventures in Success.
-- The work is historically important as an early music-video use of 3D CGI,
-- but it is not described as the absolute first. Unknown values remain NULL.
-- Award claims without an official result-level archive remain audit notes only.

begin;

create temporary table _mvhl_target_work (
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

  select count(distinct w.id) into v_count
  from public.works w
  where w.slug = 'will-powers-adventures-in-success'
     or exists (
       select 1 from public.media_assets ma
       where ma.work_id = w.id and ma.platform = 'youtube' and ma.external_id = 'j5BLHeOdvYI'
     )
     or (lower(w.title) = lower('Adventures in Success') and exists (
       select 1 from public.work_credits wc
       join public.entities e on e.id = wc.entity_id
       join public.credit_roles cr on cr.id = wc.role_id and cr.code = 'artist'
       where wc.work_id = w.id and lower(e.display_name) = lower('Will Powers')
     ));

  if v_count > 1 then raise exception 'Duplicate candidates found for Adventures in Success'; end if;

  if v_count = 1 then
    select w.id into v_id
    from public.works w
    where w.slug = 'will-powers-adventures-in-success'
       or exists (
         select 1 from public.media_assets ma
         where ma.work_id = w.id and ma.platform = 'youtube' and ma.external_id = 'j5BLHeOdvYI'
       )
       or (lower(w.title) = lower('Adventures in Success') and exists (
         select 1 from public.work_credits wc
         join public.entities e on e.id = wc.entity_id
         join public.credit_roles cr on cr.id = wc.role_id and cr.code = 'artist'
         where wc.work_id = w.id and lower(e.display_name) = lower('Will Powers')
       ))
    limit 1;
  else
    insert into public.works (
      work_type_id, slug, title, original_title, release_year, country_code,
      language_code, status, is_canonical, verification_notes
    ) values (
      v_type_id, 'will-powers-adventures-in-success', 'Adventures in Success',
      'Adventures in Success', 1983, 'US', 'en', 'researching', false,
      'Standard work-addition workflow v1. Unknown exact release date, separate VFX company, aspect ratio and unverified crew fields remain NULL.'
    ) returning id into v_id;
  end if;

  insert into _mvhl_target_work values ('will-powers-adventures-in-success', v_id);
end $$;

update public.works w set
  slug = 'will-powers-adventures-in-success',
  title = 'Adventures in Success',
  original_title = 'Adventures in Success',
  release_date = null,
  release_year = 1983,
  country_code = 'US',
  language_code = 'en',
  status = 'researching',
  is_canonical = false,
  verified_at = null,
  published_at = null,
  verification_notes = 'Standard work-addition workflow v1. Official media, director, production lab, CGI use, bilingual editorial and source coverage verified. The public YouTube asset is 239 seconds; the director portfolio lists a 3:45 version. Separate VFX production and exact release date remain NULL. Award claims remain unresolved without an official result-level archive.'
where w.id = (select id from _mvhl_target_work);

insert into public.entities (slug, display_name, entity_type, country_code, official_url) values
  ('will-powers', 'Will Powers', 'other', 'US', null),
  ('rebecca-allen', 'Rebecca Allen', 'person', 'US', 'https://www.rebeccaallen.com/'),
  ('computer-graphics-laboratory-nyit', 'Computer Graphics Laboratory / NYIT', 'institution', 'US', 'https://www.nyit.edu/about/history/'),
  ('lynn-goldsmith', 'Lynn Goldsmith', 'person', 'US', 'https://lynngoldsmith.com/'),
  ('joshua-white', 'Joshua White', 'person', 'US', null),
  ('marc-m-chouaniere', 'Marc M. Chouaniere', 'person', null, null)
on conflict (slug) do update set
  display_name = excluded.display_name,
  entity_type = excluded.entity_type,
  country_code = coalesce(public.entities.country_code, excluded.country_code),
  official_url = coalesce(public.entities.official_url, excluded.official_url);

insert into public.music_video_details (work_id, label, album, runtime_seconds, official_release_url)
select id, 'Island Records', 'Dancing for Mental Health', 239,
  'https://www.youtube.com/watch?v=j5BLHeOdvYI'
from _mvhl_target_work
on conflict (work_id) do update set
  label = excluded.label,
  album = excluded.album,
  runtime_seconds = excluded.runtime_seconds,
  official_release_url = excluded.official_release_url;

insert into public.work_credits (work_id, entity_id, role_id, credit_order, verification_status, notes)
select t.id, e.id, r.id, d.credit_order, 'verified', d.notes
from _mvhl_target_work t
join (values
  ('will-powers', 'artist', 1, 'Will Powers is Lynn Goldsmith’s artist persona; identity and music credit verified through the director project page and licensed release credits.'),
  ('rebecca-allen', 'director', 1, 'Director credit verified through Rebecca Allen’s official project page and contemporary Billboard correction.'),
  ('computer-graphics-laboratory-nyit', 'production_company', 1, 'Official project page identifies the work as produced at the Computer Graphics Laboratory / NYIT.'),
  ('lynn-goldsmith', 'producer', 1, 'Producer credit verified through the director project page and contemporary Billboard correction.'),
  ('joshua-white', 'producer', 2, 'Producer credit verified through the director project page and contemporary Billboard correction.'),
  ('marc-m-chouaniere', 'editor', 1, 'Video Editor / Technical Director credit verified through the director project page.')
) d(entity_slug, role_code, credit_order, notes) on true
join public.entities e on e.slug = d.entity_slug
join public.credit_roles r on r.code = d.role_code
on conflict (work_id, entity_id, role_id) do update set
  credit_order = excluded.credit_order,
  verification_status = 'verified',
  notes = excluded.notes;

insert into public.work_editorials (
  work_id, locale, short_summary, why_it_matters, historical_context,
  key_innovation, editorial_notes, verification_status, reviewed_at
)
select t.id, d.locale, d.short_summary, d.why_it_matters, d.historical_context,
  d.key_innovation, d.editorial_notes, 'verified', now()
from _mvhl_target_work t
join (values
  ('ja',
   '2D・3Dデジタルアニメーション、実写、文字グラフィックをコラージュし、回転する顔のマスクと成功をめぐる記号をコミック的な画面へ組み込んだ作品。',
   '商用MVにおける3Dコンピューターアニメーションの早期例として、研究施設で開発されていた顔表現をMTV時代の大衆的なフォーマットへ接続した。',
   '1983年、Rebecca Allenがニューヨーク工科大学Computer Graphics Laboratoryで制作した。西村智弘のアニメーションMV史とOhio StateのCG史は、ともに1985年の「Money for Nothing」以前に位置する3D CGIの早期例として本作を記録している。',
   '回転するデジタルマスクに顔を与え、2Dアニメーション、実写、文字を同一のコラージュへ統合することで、研究段階の3D顔表現を反復可能な視覚モチーフへ変換した。',
   'Acquisition reason: an early, source-verified connection between computer-graphics research and the public music-video form. The work is not claimed as the absolute first CGI music video.'),
  ('en',
   'A comic-book-like moving collage combining 2D and 3D digital animation, live action and text graphics around rotating facial masks and symbols of success.',
   'As an early music-video use of 3D computer animation, it connected facial-animation research from a computer-graphics laboratory to the mass-distribution format of the MTV era.',
   'Made in 1983 by Rebecca Allen at the Computer Graphics Laboratory of the New York Institute of Technology, the work predates the more widely remembered CGI characters of Money for Nothing. Nishimura’s history of animated music video and Ohio State’s computer-graphics history both identify it as an early 3D-CGI music-video example.',
   'Digitally modeled rotating masks carry facial imagery while 2D animation, live action and text are assembled into one collage, turning experimental 3D facial work into a repeatable visual motif.',
   'Acquisition reason: an early, source-verified connection between computer-graphics research and the public music-video form. The work is not claimed as the absolute first CGI music video.')
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
  work_id, platform, asset_type, external_id, url, is_official, availability_status, last_checked_at
)
select id, 'youtube', 'full_video', 'j5BLHeOdvYI',
  'https://www.youtube.com/watch?v=j5BLHeOdvYI', true, 'available', now()
from _mvhl_target_work
on conflict (platform, external_id) where external_id is not null do update set
  work_id = excluded.work_id,
  url = excluded.url,
  is_official = true,
  availability_status = 'available',
  last_checked_at = excluded.last_checked_at;

insert into public.media_assets (
  work_id, platform, asset_type, external_id, url, is_official, availability_status, last_checked_at
)
select id, 'youtube', 'thumbnail', null,
  'https://i.ytimg.com/vi/j5BLHeOdvYI/maxresdefault.jpg', true, 'available', now()
from _mvhl_target_work
on conflict (work_id, url) do update set
  is_official = true,
  availability_status = 'available',
  last_checked_at = excluded.last_checked_at;

insert into public.sources (source_type, title, publisher, url, accessed_at, notes) values
  ('official_video', 'Will Powers “Adventures in Success” (Official Music Video)', 'Lynn Goldsmith / YouTube', 'https://www.youtube.com/watch?v=j5BLHeOdvYI', current_date, 'Artist-rightsholder upload; official title, media ID, public asset runtime and thumbnail verified.'),
  ('director_portfolio', 'Adventures in Success — 1983', 'Rebecca Allen', 'https://www.rebeccaallen.com/projects/adventures-in-success', current_date, 'Primary project record for director, production lab, visual methods, music and production credits. Portfolio duration is 3:45, while the public YouTube asset is 3:59.'),
  ('production_company', 'New York Tech History', 'New York Institute of Technology', 'https://www.nyit.edu/about/history/', current_date, 'Official institutional history confirming the Computer Graphics Laboratory and its early graphics work.'),
  ('publication', '3DCGのミュージックビデオ', '東京造形大学研究報', 'https://zokei.repo.nii.ac.jp/record/141/files/24-10nishimura.pdf', current_date, 'Nishimura identifies the 1983 work as an early music-video use of 3D CGI and describes facial CGI combined with live action and animation.'),
  ('publication', 'CGI and Effects in Films and Music Videos', 'The Ohio State University Pressbooks', 'https://ohiostate.pressbooks.pub/graphicshistory/chapter/14-2-cgi-and-effects-in-films-and-music-videos/', current_date, 'Institutional secondary history placing Allen’s 1983 CGI facial work before Money for Nothing.'),
  ('publication', 'Billboard, November 19, 1983', 'Billboard / World Radio History', 'https://www.worldradiohistory.com/Archive-All-Music/Billboard/80s/1983/BB-1983-11-19.pdf', current_date, 'Contemporary correction confirming director, producers and computer-animation credits; award nominations remain unresolved without official result-level category records.'),
  ('label', 'Adventures in Success', 'Sonar Kollektiv', 'https://sonarkollektiv.bandcamp.com/track/adventures-in-success', current_date, 'Licensed release page confirming Lynn Goldsmith production, Island Records 1983 phonographic credit and songwriting credits.'),
  ('director_portfolio', 'Rebecca Allen — Full CV', 'Rebecca Allen', 'https://assets.locomotive.works/sites/630ddaf4586d95007d5cf2e2/content_entry630ddb1c594da90081a56750/630de108594da9009ca567b1/files/Rebecca_Allen_Full_CV_5-26.pdf?1778881316=', current_date, 'Creator CV repeats historical award claims; retained for audit only because no official result-level award archive was verified.')
on conflict (url) do update set
  source_type = excluded.source_type,
  title = excluded.title,
  publisher = excluded.publisher,
  accessed_at = excluded.accessed_at,
  notes = excluded.notes;

insert into public.work_sources (work_id, source_id, supports_fields, is_primary, notes)
select t.id, s.id, d.fields, d.is_primary, d.notes
from _mvhl_target_work t
join (values
  ('https://www.youtube.com/watch?v=j5BLHeOdvYI', array['official_title','artist','runtime','youtube_id','thumbnail','visual_analysis']::text[], true, 'Official media identity and direct formal-analysis source.'),
  ('https://www.rebeccaallen.com/projects/adventures-in-success', array['release_year','director','production_company','label','production_credits','technology','visual_methods','historical_context']::text[], true, 'Primary creator project record.'),
  ('https://www.nyit.edu/about/history/', array['production_institution','historical_context']::text[], true, 'Official institutional context for the Computer Graphics Laboratory.'),
  ('https://zokei.repo.nii.ac.jp/record/141/files/24-10nishimura.pdf', array['historical_context','technology','early_cgi']::text[], false, 'Scholarly history; supports early adoption, not an absolute-first claim.'),
  ('https://ohiostate.pressbooks.pub/graphicshistory/chapter/14-2-cgi-and-effects-in-films-and-music-videos/', array['historical_context','technology','early_cgi']::text[], false, 'Independent institutional history.'),
  ('https://www.worldradiohistory.com/Archive-All-Music/Billboard/80s/1983/BB-1983-11-19.pdf', array['director','producer','computer_animation_credits','award_audit']::text[], false, 'Contemporary trade-publication correction; award categories remain audit-only.'),
  ('https://sonarkollektiv.bandcamp.com/track/adventures-in-success', array['label','release_year','producer','songwriting_credits']::text[], false, 'Licensed release metadata.'),
  ('https://assets.locomotive.works/sites/630ddaf4586d95007d5cf2e2/content_entry630ddb1c594da90081a56750/630de108594da9009ca567b1/files/Rebecca_Allen_Full_CV_5-26.pdf?1778881316=', array['award_audit']::text[], true, 'Creator CV retained only as unresolved award-audit evidence.')
) d(source_url, fields, is_primary, notes) on true
join public.sources s on s.url = d.source_url
on conflict (work_id, source_id) do update set
  supports_fields = excluded.supports_fields,
  is_primary = excluded.is_primary,
  notes = excluded.notes;

insert into public.taxonomy_terms (category_id, slug, name)
select c.id, d.slug, d.name
from public.taxonomy_categories c
join (values
  ('genre', 'electronic', 'Electronic'),
  ('region', 'international', 'International'),
  ('era', '1980s', '1980s'),
  ('movement', 'early-cgi', 'Early CGI')
) d(category_code, slug, name) on d.category_code = c.code
on conflict (category_id, slug) do update set name = excluded.name;

insert into public.work_taxonomy_terms (work_id, term_id, confidence, assignment_method, notes)
select t.id, tt.id, 1.000, 'editorial', 'Verified standard work-addition classification.'
from _mvhl_target_work t
join public.taxonomy_terms tt on tt.slug in ('electronic','international','1980s','early-cgi')
on conflict (work_id, term_id) do update set
  confidence = excluded.confidence,
  assignment_method = excluded.assignment_method,
  notes = excluded.notes;

delete from public.work_technologies where work_id = (select id from _mvhl_target_work);
delete from public.work_visual_languages where work_id = (select id from _mvhl_target_work);

insert into public.work_technologies (
  work_id, technology_id, usage_role, relevance, relationship_role,
  is_primary, confidence, assignment_method, verification_status,
  verification_notes, note_ja, note_en, display_order, reviewed_at
)
select t.id, tech.id, 'experimental', 'primary', 'early_adoption', true, 1.000,
  'editorial', 'verified',
  'Primary creator record plus two independent institutional histories verify 3D CGI use in 1983. Classified as early adoption, not the absolute earliest verified use.',
  '回転する顔のマスクに3Dコンピューターアニメーションを用い、1983年のMVへ研究段階のCGIを導入した早期例。絶対的な「最初」とは登録しない。',
  'Rotating facial masks use 3D computer animation, bringing research-stage CGI into a 1983 music video. The relationship is recorded as early adoption, not an absolute-first claim.',
  10, now()
from _mvhl_target_work t
join public.technologies tech on tech.slug = 'cgi' and tech.lifecycle_status = 'published' and tech.is_active
on conflict (work_id, technology_id) do update set
  usage_role = excluded.usage_role,
  relevance = excluded.relevance,
  relationship_role = excluded.relationship_role,
  is_primary = excluded.is_primary,
  confidence = excluded.confidence,
  assignment_method = excluded.assignment_method,
  verification_status = 'verified',
  verification_notes = excluded.verification_notes,
  note_ja = excluded.note_ja,
  note_en = excluded.note_en,
  display_order = excluded.display_order,
  reviewed_at = excluded.reviewed_at;

insert into public.work_technology_sources (work_technology_id, source_id, supports_fields, is_primary, notes)
select wt.id, s.id, array['technology','relationship_role']::text[], d.is_primary, d.notes
from _mvhl_target_work t
join public.work_technologies wt on wt.work_id = t.id
join (values
  ('https://www.rebeccaallen.com/projects/adventures-in-success', true, 'Primary creator record explicitly identifies 2D and 3D digital animation and the rotating digital masks.'),
  ('https://zokei.repo.nii.ac.jp/record/141/files/24-10nishimura.pdf', false, 'Scholarly history supports early 3D-CGI adoption in music video.'),
  ('https://ohiostate.pressbooks.pub/graphicshistory/chapter/14-2-cgi-and-effects-in-films-and-music-videos/', false, 'Independent institutional history corroborates the 1983 CGI facial work.')
) d(source_url, is_primary, notes) on true
join public.sources s on s.url = d.source_url
on conflict (work_technology_id, source_id) do update set
  supports_fields = excluded.supports_fields,
  is_primary = excluded.is_primary,
  notes = excluded.notes;

insert into public.work_visual_languages (
  work_id, visual_language_id, prominence, relevance, relationship_role,
  is_primary, confidence, assignment_method, editorial_rationale,
  verification_status, verification_notes, note_ja, note_en, display_order, reviewed_at
)
select t.id, vl.id, d.prominence, d.relevance, d.role, d.is_primary, 1.000,
  'editorial', d.note_en, 'verified',
  'Verified by the primary creator project record and direct analysis of the official video.',
  d.note_ja, d.note_en, d.display_order, now()
from _mvhl_target_work t
join (values
  ('mixed-media', 'primary', 'primary', 'defining_example', true,
   '2D・3Dデジタルアニメーション、実写、文字グラフィックを同一画面へ組み合わせ、媒体間の差異そのものを画面構成に用いる。',
   '2D and 3D digital animation, live action and text graphics share the same frame, making differences between media part of the composition.', 10),
  ('collage', 'primary', 'primary', 'defining_example', true,
   '顔、商品、身体、文字、抽象形態を断片として並置し、コミック的な「動くコラージュ」として成功をめぐる記号を組み立てる。',
   'Faces, products, bodies, text and abstract forms are juxtaposed as fragments, assembling symbols of success into a comic-book-like moving collage.', 20),
  ('optical-illusion', 'secondary', 'significant', 'notable_example', false,
   '回転するデジタルマスクへ顔の像を与え、立体形状と平面的な顔の知覚をずらす錯視を反復する。',
   'Facial imagery is mapped onto rotating digital masks, repeatedly unsettling the distinction between volumetric form and a flat perceived face.', 30)
) d(concept_slug, prominence, relevance, role, is_primary, note_ja, note_en, display_order) on true
join public.visual_languages vl on vl.slug = d.concept_slug and vl.lifecycle_status = 'published' and vl.is_active
on conflict (work_id, visual_language_id) do update set
  prominence = excluded.prominence,
  relevance = excluded.relevance,
  relationship_role = excluded.relationship_role,
  is_primary = excluded.is_primary,
  confidence = excluded.confidence,
  assignment_method = excluded.assignment_method,
  editorial_rationale = excluded.editorial_rationale,
  verification_status = 'verified',
  verification_notes = excluded.verification_notes,
  note_ja = excluded.note_ja,
  note_en = excluded.note_en,
  display_order = excluded.display_order,
  reviewed_at = excluded.reviewed_at;

insert into public.work_visual_language_sources (
  work_visual_language_id, source_id, supports_fields, is_primary, notes
)
select wvl.id, s.id, array['visual_language','relationship_role']::text[], d.is_primary, d.notes
from _mvhl_target_work t
join public.work_visual_languages wvl on wvl.work_id = t.id
join (values
  ('https://www.rebeccaallen.com/projects/adventures-in-success', true, 'Primary creator description names the moving collage, mixed media and optical illusion.'),
  ('https://www.youtube.com/watch?v=j5BLHeOdvYI', true, 'Official video used for direct formal analysis.')
) d(source_url, is_primary, notes) on true
join public.sources s on s.url = d.source_url
on conflict (work_visual_language_id, source_id) do update set
  supports_fields = excluded.supports_fields,
  is_primary = excluded.is_primary,
  notes = excluded.notes;

insert into public.knowledge_graph_work_reviews (
  work_id, sprint, technology_outcome, visual_language_outcome,
  review_note_ja, review_note_en, deliberately_not_assigned,
  unresolved_questions, reviewed_at
)
select id, 'work-addition-standard-v1', 'assigned', 'assigned',
  '公式制作記録、論文、研究機関資料、公式映像を照合し、CGI 1件と探索に有効な映像言語3件だけを採用した。',
  'The primary production record, scholarship, institutional history and official video were reviewed. One CGI relationship and three useful Visual Language paths were retained.',
  array[
    'Digital Compositing: mixed digital and live-action imagery is verified, but the compositing process itself is not documented.',
    'Typography: present but redundant beside Mixed Media and Collage.',
    'Body Transformation: rotating masks do not primarily organize the work as bodily metamorphosis.'
  ]::text[],
  array[
    '1984 Heavy Metal Music Video Awards Best Animation claim remains unresolved without an official result-level archive.',
    '1983 Billboard Video Music Awards nomination categories remain unresolved without an official result-level archive.',
    'The official YouTube asset runs 3:59 while the director portfolio lists a 3:45 version.'
  ]::text[], now()
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

-- No official result-level archive was verified for the award claims.
delete from public.work_award_results where work_id = (select id from _mvhl_target_work);

do $$
declare
  v_id uuid := (select id from _mvhl_target_work);
begin
  if (select count(*) from public.work_editorials where work_id = v_id and locale in ('ja','en') and verification_status = 'verified') <> 2 then
    raise exception 'Bilingual verified editorial is incomplete';
  end if;
  if (select count(*) from public.work_technologies where work_id = v_id and verification_status = 'verified') <> 1 then
    raise exception 'Expected exactly one verified Technology relationship';
  end if;
  if not exists (
    select 1 from public.work_technologies wt
    join public.technologies t on t.id = wt.technology_id
    where wt.work_id = v_id and t.slug = 'cgi' and wt.relationship_role = 'early_adoption'
  ) then raise exception 'Expected verified CGI early-adoption relationship'; end if;
  if exists (
    select 1 from public.work_technologies wt
    join public.technologies t on t.id = wt.technology_id
    where wt.work_id = v_id and t.slug = 'digital-compositing'
  ) then raise exception 'Digital Compositing must remain unassigned without process evidence'; end if;
  if (select count(*) from public.work_visual_languages where work_id = v_id and verification_status = 'verified') <> 3 then
    raise exception 'Expected exactly three verified Visual Language relationships';
  end if;
  if exists (
    select 1 from public.work_technologies wt
    where wt.work_id = v_id and wt.verification_status = 'verified'
      and not exists (select 1 from public.work_technology_sources s where s.work_technology_id = wt.id)
  ) then raise exception 'Every verified Technology relationship requires a source'; end if;
  if exists (
    select 1 from public.work_visual_languages wvl
    where wvl.work_id = v_id and wvl.verification_status = 'verified'
      and not exists (select 1 from public.work_visual_language_sources s where s.work_visual_language_id = wvl.id)
  ) then raise exception 'Every verified Visual Language relationship requires a source'; end if;
  if (select count(*) from public.work_sources where work_id = v_id) < 7 then
    raise exception 'Insufficient source coverage';
  end if;
  if exists (select 1 from public.work_award_results where work_id = v_id) then
    raise exception 'Unresolved award claims must not be registered';
  end if;
  if not exists (
    select 1 from public.media_assets
    where work_id = v_id and external_id = 'j5BLHeOdvYI' and availability_status = 'available'
  ) then raise exception 'Official video media is incomplete'; end if;
end $$;

update public.works set status = 'verified', verified_at = now(), last_reviewed_at = now()
where id = (select id from _mvhl_target_work);

update public.works set status = 'published', published_at = now()
where id = (select id from _mvhl_target_work) and status = 'verified' and verified_at is not null;

do $$
begin
  if not exists (
    select 1 from public.works
    where id = (select id from _mvhl_target_work) and status = 'published'
  ) then raise exception 'Publication gate did not complete'; end if;
end $$;

commit;
