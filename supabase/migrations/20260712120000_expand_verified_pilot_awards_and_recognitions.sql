-- Add only official-source-backed pilot results. Festival and editorial
-- selections are deliberately stored outside work_award_results.

begin;

alter table public.work_award_results drop constraint if exists work_award_results_result_check;
alter table public.work_award_results add constraint work_award_results_result_check check (result in (
  'winner','nominee','finalist','shortlist','grand_prix','gold','silver','bronze',
  'special_jury','jury_selection','honorable_mention','official_selection',
  'peoples_voice_winner','other'
));

alter table public.awards drop constraint if exists awards_scope_check;
alter table public.awards add constraint awards_scope_check check (scope in (
  'dedicated_music_video','general_music','advertising_creative','film_craft',
  'post_production_craft','media_art','festival','platform_editorial'
));

insert into public.awards (
  slug,name,official_name,country_code,region,organizer,website_url,official_url,
  scope,status,established_year,notes
)
values
  ('mtv-europe-music-awards','MTV Europe Music Awards','MTV Europe Music Awards','GB','International','MTV','https://www.mtvema.com/','https://www.mtvema.com/','general_music','active',1994,null),
  ('clio-music','Clio Music','Clio Music','US','International','Clio Awards','https://clios.com/music/','https://clios.com/music/','general_music','active',2014,null),
  ('webby-awards','The Webby Awards','The Webby Awards','US','International','International Academy of Digital Arts and Sciences','https://www.webbyawards.com/','https://www.webbyawards.com/','platform_editorial','active',1996,null),
  ('energacamerimage','EnergaCAMERIMAGE','EnergaCAMERIMAGE','PL','International','Tumult Foundation','https://camerimage.pl/en/','https://camerimage.pl/en/','film_craft','active',1993,null),
  ('ciclope-awards','CICLOPE Awards','CICLOPE Awards','DE','International','CICLOPE','https://www.ciclopefestival.com/','https://www.ciclopefestival.com/','film_craft','active',2010,null),
  ('space-shower-music-awards','SPACE SHOWER MUSIC AWARDS','SPACE SHOWER MUSIC AWARDS','JP','Japan','SPACE SHOWER NETWORKS','https://awards.spaceshower.jp/','https://awards.spaceshower.jp/','dedicated_music_video','active',2016,'Kept separate from the earlier SPACE SHOWER MUSIC VIDEO AWARDS program.')
on conflict (slug) do update set
  name=excluded.name,official_name=excluded.official_name,country_code=excluded.country_code,
  region=excluded.region,organizer=excluded.organizer,website_url=excluded.website_url,
  official_url=excluded.official_url,scope=excluded.scope,status=excluded.status,
  established_year=excluded.established_year,notes=excluded.notes;

insert into public.sources (source_type,title,publisher,url,accessed_at,notes)
values
  ('award_archive','2018 winners','UK Music Video Awards','https://www.ukmva.com/192-2018',current_date,'Official 2018 winners archive.'),
  ('award_archive','This Is America','The Webby Awards','https://winners.webbyawards.com/2019/video/general-video/music-video/81551/this-is-america',current_date,'Official winner page; records both Webby Winner and People''s Voice Winner.'),
  ('award_archive','This Is America','Clio Music','https://clios.com/winners-gallery/details/72649',current_date,'Official 2018 Clio Music winner page.'),
  ('award_archive','2018 winners','CICLOPE Awards','https://awards.ciclopefestival.com/winners/2018',current_date,'Official 2018 winners archive.'),
  ('award_archive','EnergaCAMERIMAGE Winners Show 2019 program','EnergaCAMERIMAGE','https://archive.camerimage.pl/assets/uploads/2019/01/EnergaCAMERIMAGE-WINNERS-SHOW-2019-program.pdf',current_date,'Official archive program listing the 2018 music-video cinematography winner.'),
  ('award_archive','MTV announces 2018 VMAs nominations','MTV / Paramount','https://ir.paramount.com/news-releases/news-release-details/mtv-announces-2018-vmas-nominations',current_date,'Official nominations release.'),
  ('award_archive','SPACE SHOWER MUSIC AWARDS 2022 winners','SPACE SHOWER NETWORKS','https://awards.spaceshower.jp/2022/winners/index.html',current_date,'Official winners archive.'),
  ('artist_official','「新宝島」がSPACE SHOWER MUSIC AWARDS「BEST CONCEPTUAL VIDEO」を受賞','SAKANACTION','https://sakanaction.jp/news/detail.php?id=891&lang=en',current_date,'Official artist announcement identifying the MV and category.'),
  ('artist_official','「Lemon」MV、MTV VMAJ 2018にて2冠受賞','REISSUE RECORDS','https://reissuerecords.net/2018/10/10/%E3%80%8Cmtv-vmaj-2018%E3%80%8D%E5%8F%97%E8%B3%9E%EF%BC%81/',current_date,'Official artist announcement naming both MV awards.'),
  ('award_archive','2019 SXSW Film Festival archive','SXSW','https://www.sxsw.com/wp-content/uploads/2019/06/2019FilmArchive-1.pdf',current_date,'Official festival archive; selection only, not an award.'),
  ('publication','Best of Staff Picks: June 2018','Vimeo','https://vimeo.com/es/blog/post/best-of-staff-picks-june-2018',current_date,'Official Vimeo editorial selection; not an award.')
on conflict (url) do update set
  source_type=excluded.source_type,title=excluded.title,publisher=excluded.publisher,
  accessed_at=excluded.accessed_at,notes=excluded.notes;

insert into public.award_categories (
  award_id,slug,name,official_name,normalized_name,category_type,valid_from_year,valid_to_year
)
select a.id,d.slug,d.official_name,d.official_name,d.normalized_name,d.category_type,d.valid_from,d.valid_to
from (values
  ('uk-music-video-awards','video-of-the-year','video of the year','Video of the Year','overall_video',2018::smallint,2018::smallint),
  ('uk-music-video-awards','best-urban-video-international','best urban video – international','Best Urban Video — International','genre',2018::smallint,2018::smallint),
  ('uk-music-video-awards','best-cinematography-in-a-video','best cinematography in a video','Best Cinematography in a Video','cinematography',2018::smallint,2018::smallint),
  ('webby-awards','music-video','Music Video','Music Video','overall_video',2019::smallint,2019::smallint),
  ('clio-music','film-music-videos','Music Videos','Music Videos','overall_video',2018::smallint,2018::smallint),
  ('ciclope-awards','music-videos','MUSIC VIDEOS','Music Videos','overall_video',2018::smallint,2018::smallint),
  ('energacamerimage','best-cinematography-in-a-music-video','Best Cinematography In A Music Video','Best Cinematography in a Music Video','cinematography',2018::smallint,2018::smallint),
  ('mtv-video-music-awards','video-with-a-message','VIDEO WITH A MESSAGE','Video with a Message','other',2018::smallint,2018::smallint),
  ('mtv-video-music-awards','best-cinematography','BEST CINEMATOGRAPHY','Best Cinematography','cinematography',2018::smallint,2018::smallint),
  ('mtv-video-music-awards','best-direction','BEST DIRECTION','Best Direction','direction',2018::smallint,2018::smallint),
  ('mtv-video-music-awards','best-art-direction','BEST ART DIRECTION','Best Art Direction','production_design',2018::smallint,2018::smallint),
  ('space-shower-music-awards','best-conceptual-video','BEST CONCEPTUAL VIDEO','Best Conceptual Video','concept',2016::smallint,null),
  ('mtv-video-music-awards-japan','best-male-video-japan','最優秀邦楽男性アーティストビデオ賞','Best Male Video -Japan-','regional',2018::smallint,2018::smallint),
  ('mtv-video-music-awards-japan','best-video-of-the-year','Best Video of the Year','Video of the Year','overall_video',2018::smallint,2018::smallint)
) as d(award_slug,slug,official_name,normalized_name,category_type,valid_from,valid_to)
join public.awards a on a.slug=d.award_slug
on conflict (award_id,slug) do update set
  name=excluded.name,official_name=excluded.official_name,normalized_name=excluded.normalized_name,
  category_type=excluded.category_type,valid_from_year=excluded.valid_from_year,
  valid_to_year=excluded.valid_to_year;

-- Exact, official-source-backed award relationships.
insert into public.work_award_results (
  work_id,award_id,award_category_id,award_year,result,credited_name_text,
  source_id,verification_status,verification_notes
)
select w.id,a.id,ac.id,d.award_year,d.result,d.credited_name,s.id,'verified',d.notes
from (values
  ('childish-gambino-this-is-america','uk-music-video-awards','video-of-the-year',2018::smallint,'winner',null,'https://www.ukmva.com/192-2018','Official winners archive.'),
  ('childish-gambino-this-is-america','uk-music-video-awards','best-urban-video-international',2018::smallint,'winner','Hiro Murai / Jason Cole / Doomsday','https://www.ukmva.com/192-2018','Official archive identifies director, producer and production company.'),
  ('childish-gambino-this-is-america','uk-music-video-awards','best-cinematography-in-a-video',2018::smallint,'winner','Larkin Seiple','https://www.ukmva.com/192-2018','Craft recipient preserved.'),
  ('childish-gambino-this-is-america','webby-awards','music-video',2019::smallint,'winner',null,'https://winners.webbyawards.com/2019/video/general-video/music-video/81551/this-is-america','Webby Winner.'),
  ('childish-gambino-this-is-america','webby-awards','music-video',2019::smallint,'peoples_voice_winner',null,'https://winners.webbyawards.com/2019/video/general-video/music-video/81551/this-is-america','People''s Voice Winner; retained as a distinct official outcome.'),
  ('childish-gambino-this-is-america','clio-music','film-music-videos',2018::smallint,'gold',null,'https://clios.com/winners-gallery/details/72649','Clio Music Gold; Medium Film, Category Music Videos.'),
  ('childish-gambino-this-is-america','ciclope-awards','music-videos',2018::smallint,'grand_prix',null,'https://awards.ciclopefestival.com/winners/2018','Grand Prix in MUSIC VIDEOS.'),
  ('childish-gambino-this-is-america','energacamerimage','best-cinematography-in-a-music-video',2018::smallint,'winner','Larkin Seiple','https://archive.camerimage.pl/assets/uploads/2019/01/EnergaCAMERIMAGE-WINNERS-SHOW-2019-program.pdf','Craft recipient preserved.'),
  ('childish-gambino-this-is-america','mtv-video-music-awards','video-of-the-year',2018::smallint,'nominee',null,'https://ir.paramount.com/news-releases/news-release-details/mtv-announces-2018-vmas-nominations','Official nomination.'),
  ('childish-gambino-this-is-america','mtv-video-music-awards','video-with-a-message',2018::smallint,'nominee',null,'https://ir.paramount.com/news-releases/news-release-details/mtv-announces-2018-vmas-nominations','Official nomination.'),
  ('childish-gambino-this-is-america','mtv-video-music-awards','best-cinematography',2018::smallint,'nominee','Larkin Seiple','https://ir.paramount.com/news-releases/news-release-details/mtv-announces-2018-vmas-nominations','Official craft nomination.'),
  ('childish-gambino-this-is-america','mtv-video-music-awards','best-direction',2018::smallint,'nominee','Hiro Murai','https://ir.paramount.com/news-releases/news-release-details/mtv-announces-2018-vmas-nominations','Official craft nomination.'),
  ('childish-gambino-this-is-america','mtv-video-music-awards','best-art-direction',2018::smallint,'nominee','Jason Kisvarday','https://ir.paramount.com/news-releases/news-release-details/mtv-announces-2018-vmas-nominations','Official craft nomination.'),
  ('childish-gambino-this-is-america','mtv-video-music-awards','best-choreography',2018::smallint,'nominee','Sherrie Silver','https://ir.paramount.com/news-releases/news-release-details/mtv-announces-2018-vmas-nominations','Official craft nomination.'),
  ('childish-gambino-this-is-america','mtv-video-music-awards','best-editing',2018::smallint,'nominee','Ernie Gilbert','https://ir.paramount.com/news-releases/news-release-details/mtv-announces-2018-vmas-nominations','Official craft nomination.'),
  ('sakanaction-shin-takarajima','space-shower-music-awards','best-conceptual-video',2016::smallint,'winner',null,'https://sakanaction.jp/news/detail.php?id=891&lang=en','Official artist announcement identifies the MV.'),
  ('hikaru-utada-one-last-kiss','space-shower-music-awards','best-conceptual-video',2022::smallint,'winner','庵野秀明','https://awards.spaceshower.jp/2022/winners/index.html','Official winners archive identifies work and director.'),
  ('kenshi-yonezu-lemon','mtv-video-music-awards-japan','best-male-video-japan',2018::smallint,'winner',null,'https://reissuerecords.net/2018/10/10/%E3%80%8Cmtv-vmaj-2018%E3%80%8D%E5%8F%97%E8%B3%9E%EF%BC%81/','Official artist announcement.'),
  ('kenshi-yonezu-lemon','mtv-video-music-awards-japan','best-video-of-the-year',2018::smallint,'winner',null,'https://reissuerecords.net/2018/10/10/%E3%80%8Cmtv-vmaj-2018%E3%80%8D%E5%8F%97%E8%B3%9E%EF%BC%81/','Official artist announcement; second of two wins.')
) as d(work_slug,award_slug,category_slug,award_year,result,credited_name,source_url,notes)
join public.works w on w.slug=d.work_slug
join public.awards a on a.slug=d.award_slug
join public.award_categories ac on ac.award_id=a.id and ac.slug=d.category_slug
join public.sources s on s.url=d.source_url
on conflict (work_id,award_category_id,award_year,result) do update set
  award_id=excluded.award_id,credited_name_text=excluded.credited_name_text,
  source_id=excluded.source_id,verification_status=excluded.verification_status,
  verification_notes=excluded.verification_notes;

-- Separate, typed recognition model for selections that are not award results.
create table if not exists public.recognition_programs (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  official_name text not null,
  organizer text not null,
  official_url text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.work_recognitions (
  id uuid primary key default gen_random_uuid(),
  work_id uuid not null references public.works(id) on delete cascade,
  program_id uuid not null references public.recognition_programs(id),
  recognition_year smallint not null check (recognition_year between 1900 and 2200),
  recognition_type text not null check (recognition_type in (
    'festival_selection','jury_selection','editorial_selection','platform_recognition'
  )),
  result text not null check (result in (
    'official_selection','competition_selection','screening','staff_pick','staff_pick_premiere','best_of_year','other'
  )),
  category_name text,
  credited_name_text text,
  source_id uuid not null references public.sources(id),
  verification_status text not null default 'verified' check (verification_status in ('source_found','cross_checked','verified','disputed')),
  verification_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (work_id,program_id,recognition_year,recognition_type,result)
);

insert into public.recognition_programs (slug,official_name,organizer,official_url)
values
  ('sxsw-film-festival','SXSW Film Festival','SXSW','https://www.sxsw.com/festivals/film/'),
  ('vimeo-staff-picks','Vimeo Staff Picks','Vimeo','https://vimeo.com/channels/staffpicks')
on conflict (slug) do update set official_name=excluded.official_name,
  organizer=excluded.organizer,official_url=excluded.official_url;

insert into public.work_recognitions (
  work_id,program_id,recognition_year,recognition_type,result,category_name,
  source_id,verification_status,verification_notes
)
select w.id,rp.id,d.recognition_year,d.recognition_type,d.result,d.category_name,
  s.id,'verified',d.notes
from (values
  ('childish-gambino-this-is-america','sxsw-film-festival',2019::smallint,'festival_selection','competition_selection','Music Video Competition','https://www.sxsw.com/wp-content/uploads/2019/06/2019FilmArchive-1.pdf','Official festival archive; not an award win.'),
  ('childish-gambino-this-is-america','vimeo-staff-picks',2018::smallint,'editorial_selection','staff_pick','Best of Staff Picks: June 2018','https://vimeo.com/es/blog/post/best-of-staff-picks-june-2018','Official Vimeo editorial selection; not an award.')
) as d(work_slug,program_slug,recognition_year,recognition_type,result,category_name,source_url,notes)
join public.works w on w.slug=d.work_slug
join public.recognition_programs rp on rp.slug=d.program_slug
join public.sources s on s.url=d.source_url
on conflict (work_id,program_id,recognition_year,recognition_type,result) do update set
  category_name=excluded.category_name,source_id=excluded.source_id,
  verification_status=excluded.verification_status,verification_notes=excluded.verification_notes;

alter table public.recognition_programs enable row level security;
alter table public.work_recognitions enable row level security;

drop policy if exists recognition_programs_public_read on public.recognition_programs;
create policy recognition_programs_public_read on public.recognition_programs
for select to anon,authenticated using (true);

drop policy if exists work_recognitions_public_read on public.work_recognitions;
create policy work_recognitions_public_read on public.work_recognitions
for select to anon,authenticated using (
  exists (select 1 from public.works w where w.id=work_recognitions.work_id and w.status='published')
);

create or replace view public.archive_recognitions
with (security_invoker=true)
as
select
  w.slug as "workSlug",rp.official_name as "programName",rp.slug as "programSlug",
  wr.recognition_year as "recognitionYear",wr.recognition_type as "recognitionType",
  wr.result,wr.category_name as "categoryName",wr.credited_name_text as "creditedName",
  rp.official_url as "officialUrl",
  jsonb_build_array(jsonb_build_object('title',s.title,'publisher',s.publisher,'url',s.url)) as sources
from public.work_recognitions wr
join public.works w on w.id=wr.work_id
join public.recognition_programs rp on rp.id=wr.program_id
join public.sources s on s.id=wr.source_id
where w.status='published' and wr.verification_status in ('verified','cross_checked');

grant select on public.recognition_programs,public.work_recognitions,public.archive_recognitions to anon,authenticated;

-- Result sources must also be attached to the work so the existing source RLS
-- can expose them through the security-invoker public views.
insert into public.work_sources (work_id,source_id,supports_fields,is_primary,notes)
select distinct war.work_id,war.source_id,array['award']::text[],false,
  'Official result-level source.'
from public.work_award_results war
where war.source_id is not null
on conflict (work_id,source_id) do update set
  supports_fields=(select array_agg(distinct value)
    from unnest(public.work_sources.supports_fields || excluded.supports_fields) value),
  notes=coalesce(public.work_sources.notes,excluded.notes);

insert into public.work_sources (work_id,source_id,supports_fields,is_primary,notes)
select distinct wr.work_id,wr.source_id,array['recognition']::text[],false,
  'Official recognition-level source.'
from public.work_recognitions wr
on conflict (work_id,source_id) do update set
  supports_fields=(select array_agg(distinct value)
    from unnest(public.work_sources.supports_fields || excluded.supports_fields) value),
  notes=coalesce(public.work_sources.notes,excluded.notes);

commit;
