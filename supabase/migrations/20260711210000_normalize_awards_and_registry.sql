-- Normalize award master data and make every public result source-backed.

begin;

alter table public.awards
  add column if not exists official_name text,
  add column if not exists region text,
  add column if not exists organizer text,
  add column if not exists website_url text,
  add column if not exists scope text,
  add column if not exists status text,
  add column if not exists established_year smallint,
  add column if not exists discontinued_year smallint,
  add column if not exists notes text,
  add column if not exists updated_at timestamptz not null default now();

update public.awards set
  official_name = coalesce(official_name, name),
  website_url = coalesce(website_url, official_url),
  scope = coalesce(scope, 'general_music'),
  status = coalesce(status, 'unknown');

alter table public.awards
  alter column official_name set not null,
  alter column scope set not null,
  alter column status set not null;

alter table public.awards drop constraint if exists awards_scope_check;
alter table public.awards add constraint awards_scope_check check (scope in (
  'dedicated_music_video','general_music','advertising_creative','film_craft',
  'post_production_craft','media_art','festival','platform_editorial'
));
alter table public.awards drop constraint if exists awards_status_check;
alter table public.awards add constraint awards_status_check
  check (status in ('active','inactive','discontinued','unknown'));

drop trigger if exists awards_set_updated_at on public.awards;
create trigger awards_set_updated_at before update on public.awards
for each row execute function public.set_updated_at();

alter table public.award_categories
  add column if not exists official_name text,
  add column if not exists normalized_name text,
  add column if not exists category_type text,
  add column if not exists valid_from_year smallint,
  add column if not exists valid_to_year smallint;

update public.award_categories set
  official_name = coalesce(official_name, name),
  normalized_name = coalesce(normalized_name, name),
  category_type = coalesce(category_type, 'other');

alter table public.award_categories
  alter column official_name set not null,
  alter column normalized_name set not null,
  alter column category_type set not null;

alter table public.award_categories drop constraint if exists award_categories_category_type_check;
alter table public.award_categories add constraint award_categories_category_type_check check (category_type in (
  'overall_video','direction','cinematography','editing','visual_effects','animation',
  'production_design','choreography','color_grading','performance','concept','genre',
  'regional','technical','other'
));

alter table public.work_award_results
  add column if not exists award_id uuid references public.awards(id),
  add column if not exists ceremony_number smallint,
  add column if not exists credited_entity_id uuid references public.entities(id),
  add column if not exists credited_name_text text,
  add column if not exists source_id uuid references public.sources(id),
  add column if not exists verification_notes text,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

update public.work_award_results war
set award_id = ac.award_id
from public.award_categories ac
where ac.id = war.award_category_id and war.award_id is null;

alter table public.work_award_results alter column award_id set not null;

alter table public.work_award_results drop constraint if exists work_award_results_result_check;
alter table public.work_award_results add constraint work_award_results_result_check check (result in (
  'winner','nominee','finalist','shortlist','grand_prix','gold','silver','bronze',
  'special_jury','jury_selection','honorable_mention','official_selection','other'
));

alter table public.work_award_results drop constraint if exists work_award_results_verification_status_check;
alter table public.work_award_results add constraint work_award_results_verification_status_check
  check (verification_status in ('unverified','source_found','cross_checked','verified','disputed'));

alter table public.work_award_results
  drop constraint if exists work_award_results_work_id_award_category_id_award_year_key;
alter table public.work_award_results
  drop constraint if exists work_award_results_unique_result;
alter table public.work_award_results add constraint work_award_results_unique_result
  unique (work_id, award_category_id, award_year, result);

drop trigger if exists work_award_results_set_updated_at on public.work_award_results;
create trigger work_award_results_set_updated_at before update on public.work_award_results
for each row execute function public.set_updated_at();

-- Award-program registry. These are factual master records only; their presence
-- does not imply that any pilot work has a result at the program.
insert into public.awards (
  slug,name,official_name,country_code,region,organizer,website_url,official_url,
  scope,status,established_year,discontinued_year,notes
)
values
  ('grammy-awards','GRAMMY Awards','GRAMMY Awards','US','International','Recording Academy','https://www.grammy.com/awards','https://www.grammy.com/awards','general_music','active',1959,null,null),
  ('mtv-video-music-awards','MTV Video Music Awards','MTV Video Music Awards','US','International','MTV','https://www.mtv.com/vma','https://www.mtv.com/vma','dedicated_music_video','active',1984,null,null),
  ('uk-music-video-awards','UK Music Video Awards','UK Music Video Awards','GB','International','UK Music Video Awards','https://www.ukmva.com/','https://www.ukmva.com/','dedicated_music_video','active',2008,null,null),
  ('berlin-music-video-awards','Berlin Music Video Awards','Berlin Music Video Awards','DE','International','Berlin Music Video Awards','https://www.berlinmva.com/','https://www.berlinmva.com/','dedicated_music_video','active',2013,null,null),
  ('mtv-video-music-awards-japan','MTV Video Music Awards Japan','MTV Video Music Awards Japan','JP','Japan','MTV Japan','https://www.vmaj.jp/','https://www.vmaj.jp/','dedicated_music_video','active',2002,null,'Commonly styled MTV VMAJ.'),
  ('space-shower-music-video-awards','SPACE SHOWER MUSIC VIDEO AWARDS','SPACE SHOWER MUSIC VIDEO AWARDS','JP','Japan','SPACE SHOWER NETWORKS','https://awards.spaceshower.jp/','https://awards.spaceshower.jp/','dedicated_music_video','discontinued',1996,2015,'Later award naming and successor programs must be modeled separately when results are added.'),
  ('music-awards-japan','MUSIC AWARDS JAPAN','MUSIC AWARDS JAPAN','JP','Japan','Japan Culture and Entertainment Industry Promotion Association','https://www.musicawardsjapan.com/','https://www.musicawardsjapan.com/','general_music','active',2025,null,null),
  ('d-and-ad-awards','D&AD Awards','D&AD Awards','GB','International','D&AD','https://www.dandad.org/awards/professional/','https://www.dandad.org/awards/professional/','advertising_creative','active',1962,null,null),
  ('cannes-lions','Cannes Lions International Festival of Creativity','Cannes Lions International Festival of Creativity','FR','International','LIONS','https://www.canneslions.com/awards','https://www.canneslions.com/awards','advertising_creative','active',1954,null,null),
  ('ciclope-awards','CICLOPE Awards','CICLOPE Awards','DE','International','CICLOPE','https://www.ciclopefestival.com/','https://www.ciclopefestival.com/','film_craft','active',2010,null,null),
  ('aicp-post-awards','AICP Post Awards','AICP Post Awards','US','International','Association of Independent Commercial Producers','https://aicppostawards.com/','https://aicppostawards.com/','post_production_craft','active',2002,null,null),
  ('the-one-show','The One Show','The One Show','US','International','The One Club for Creativity','https://oneshow.org/','https://oneshow.org/','advertising_creative','active',1973,null,null),
  ('adc-annual-awards','ADC Annual Awards','ADC Annual Awards','US','International','The One Club for Creativity','https://adcawards.org/','https://adcawards.org/','advertising_creative','active',1921,null,null),
  ('clio-music','Clio Music','Clio Music','US','International','Clio Awards','https://clios.com/music/','https://clios.com/music/','general_music','active',2014,null,null),
  ('webby-awards','The Webby Awards','The Webby Awards','US','International','International Academy of Digital Arts and Sciences','https://www.webbyawards.com/','https://www.webbyawards.com/','platform_editorial','active',1996,null,null),
  ('sxsw-film-tv-festival','SXSW Film & TV Festival','SXSW Film & TV Festival','US','International','SXSW','https://www.sxsw.com/festivals/film/','https://www.sxsw.com/festivals/film/','festival','active',1994,null,'Music-video competition applies only in years where the official program confirms it.'),
  ('energacamerimage','EnergaCAMERIMAGE','EnergaCAMERIMAGE','PL','International','Tumult Foundation','https://camerimage.pl/en/','https://camerimage.pl/en/','film_craft','active',1993,null,'Music-video competition applies only where the official archive confirms it.'),
  ('japan-media-arts-festival','Japan Media Arts Festival','文化庁メディア芸術祭','JP','Japan','Agency for Cultural Affairs','https://j-mediaarts.jp/en/','https://j-mediaarts.jp/en/','media_art','discontinued',1997,2022,null),
  ('acc-tokyo-creativity-awards','ACC TOKYO CREATIVITY AWARDS','ACC TOKYO CREATIVITY AWARDS','JP','Japan','All Japan Confederation of Creativity','https://www.acc-awards.com/','https://www.acc-awards.com/','advertising_creative','active',1961,null,null)
on conflict (slug) do update set
  name=excluded.name, official_name=excluded.official_name,
  country_code=excluded.country_code, region=excluded.region,
  organizer=excluded.organizer, website_url=excluded.website_url,
  official_url=excluded.official_url, scope=excluded.scope, status=excluded.status,
  established_year=excluded.established_year,
  discontinued_year=excluded.discontinued_year, notes=excluded.notes;

-- Preserve the exact historical category labels used by the official results.
update public.award_categories ac set
  official_name = case
    when a.slug='mtv-video-music-awards' and ac.slug='video-of-the-year' then 'VIDEO OF THE YEAR'
    when a.slug='mtv-video-music-awards' and ac.slug='best-choreography' then 'BEST CHOREOGRAPHY'
    when a.slug='mtv-video-music-awards' and ac.slug='best-editing' then 'BEST EDITING'
    else ac.official_name end,
  normalized_name = case
    when ac.slug='video-of-the-year' then 'Video of the Year'
    when ac.slug='best-choreography' then 'Best Choreography'
    when ac.slug='best-editing' then 'Best Editing'
    else ac.normalized_name end,
  category_type = case
    when ac.slug in ('best-music-video','video-of-the-year') then 'overall_video'
    when ac.slug='best-choreography' then 'choreography'
    when ac.slug='best-editing' then 'editing'
    else ac.category_type end
from public.awards a
where a.id=ac.award_id;

-- Link each retained result to the official source and credited recipient.
update public.work_award_results war set
  source_id=s.id, award_id=a.id, ceremony_number=44,
  credited_entity_id=e.id, verification_status='verified',
  verification_notes='Confirmed in the official GRAMMY artist archive.'
from public.works w, public.award_categories ac, public.awards a,
     public.sources s, public.entities e
where war.work_id=w.id and war.award_category_id=ac.id and ac.award_id=a.id
  and w.slug='fatboy-slim-weapon-of-choice'
  and a.slug='grammy-awards' and ac.slug='best-music-video' and war.award_year=2002
  and s.url='https://www.grammy.com/artists/spike-jonze/9835/'
  and e.slug='spike-jonze';

update public.work_award_results war set
  source_id=s.id, award_id=a.id, ceremony_number=61,
  credited_entity_id=e.id, verification_status='verified',
  verification_notes='Confirmed in the official GRAMMY artist archive.'
from public.works w, public.award_categories ac, public.awards a,
     public.sources s, public.entities e
where war.work_id=w.id and war.award_category_id=ac.id and ac.award_id=a.id
  and w.slug='childish-gambino-this-is-america'
  and a.slug='grammy-awards' and ac.slug='best-music-video' and war.award_year=2019
  and s.url='https://www.grammy.com/artists/hiro-murai/243444/'
  and e.slug='hiro-murai';

update public.work_award_results war set
  source_id=s.id, award_id=a.id, ceremony_number=26,
  credited_entity_id=case when ac.slug='video-of-the-year' then e.id else null end,
  credited_name_text=case
    when ac.slug='best-choreography' then 'JaQuel Knight & Frank Gatson Jr.'
    when ac.slug='best-editing' then 'Jarrett Fijal'
    else null end,
  verification_status='verified',
  verification_notes='Confirmed in the official MTV/Paramount 2009 winners release.'
from public.works w, public.award_categories ac, public.awards a,
     public.sources s, public.entities e
where war.work_id=w.id and war.award_category_id=ac.id and ac.award_id=a.id
  and w.slug='beyonce-single-ladies' and a.slug='mtv-video-music-awards'
  and ac.slug in ('video-of-the-year','best-choreography','best-editing')
  and war.award_year=2009
  and s.url='https://ir.paramount.com/news-releases/news-release-details/beyonce-green-day-lady-gaga-lead-way-three-moonmen-2009-video'
  and e.slug='beyonce';

-- Result-level sources are mandatory after the audited backfill.
alter table public.work_award_results alter column source_id set not null;

commit;
