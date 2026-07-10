-- Ten-work pilot dataset. Run schema.sql first.
-- All records remain in researching state until sources and credits are verified.

begin;

insert into public.entities (slug, display_name, entity_type, country_code)
values
  ('michael-jackson','Michael Jackson','person','US'),
  ('a-ha','a-ha','band','NO'),
  ('jamiroquai','Jamiroquai','band','GB'),
  ('daft-punk','Daft Punk','artist_group','FR'),
  ('fatboy-slim','Fatboy Slim','person','GB'),
  ('beyonce','Beyoncé','person','US'),
  ('childish-gambino','Childish Gambino','person','US'),
  ('sakanaction','サカナクション','band','JP'),
  ('kenshi-yonezu','米津玄師','person','JP'),
  ('hikaru-utada','宇多田ヒカル','person','JP'),
  ('john-landis','John Landis','person','US'),
  ('steve-barron','Steve Barron','person','IE'),
  ('jonathan-glazer','Jonathan Glazer','person','GB'),
  ('michel-gondry','Michel Gondry','person','FR'),
  ('spike-jonze','Spike Jonze','person','US'),
  ('jake-nava','Jake Nava','person','GB'),
  ('hiro-murai','Hiro Murai','person','US'),
  ('yusuke-tanaka','田中裕介','person','JP'),
  ('tomokazu-yamada','山田智和','person','JP'),
  ('hideaki-anno','庵野秀明','person','JP')
on conflict (slug) do update set display_name = excluded.display_name, entity_type = excluded.entity_type, country_code = excluded.country_code;

with mv_type as (
  select id from public.work_types where code = 'music_video'
)
insert into public.works (
  work_type_id, slug, title, release_year, country_code, status, is_canonical,
  short_summary, why_it_matters, key_innovation
)
select mv_type.id, data.slug, data.title, data.release_year, data.country_code,
       'researching', true, data.short_summary, data.why_it_matters, data.key_innovation
from mv_type cross join (values
  ('michael-jackson-thriller','Thriller',1983,'US','Long-form narrative music video pilot entry.','Tests historical context, credits, media, and curriculum ordering.','Long-form narrative, choreography, and cinematic production.'),
  ('a-ha-take-on-me','Take On Me',1985,'NO','Live action and illustrated animation pilot entry.','Tests mixed-media technique classification.','Live action combined with rotoscope-style animation.'),
  ('jamiroquai-virtual-insanity','Virtual Insanity',1996,'GB','Performance and practical-set illusion pilot entry.','Tests practical technique and performance tags.','Set movement and controlled camera illusion.'),
  ('daft-punk-around-the-world','Around the World',1997,'FR','Choreographic visualization of musical structure.','Tests choreography and conceptual structure.','Different performers visualize different musical parts.'),
  ('fatboy-slim-weapon-of-choice','Weapon of Choice',2001,'GB','Single-location dance-performance pilot entry.','Tests performance, location, and curriculum data.','Character-driven dance performance in a real location.'),
  ('beyonce-single-ladies','Single Ladies (Put a Ring on It)',2008,'US','Minimal performance and choreography pilot entry.','Tests iconic choreography and monochrome visual style.','Minimal environment focused on synchronized choreography.'),
  ('childish-gambino-this-is-america','This Is America',2018,'US','Long-take social commentary pilot entry.','Tests historical context and social narrative.','Layered foreground performance and background action.'),
  ('sakanaction-shin-takarajima','新宝島',2015,'JP','Japanese retro television and choreography pilot entry.','Tests domestic historical context and cultural impact.','Reinterpretation of Japanese television aesthetics.'),
  ('kenshi-yonezu-lemon','Lemon',2018,'JP','Japanese cinematic portrait pilot entry.','Tests contemporary Japanese direction and visual mood.','Symbolic production design and restrained cinematic portraiture.'),
  ('hikaru-utada-one-last-kiss','One Last Kiss',2021,'JP','Intimate digital-image pilot entry.','Tests contemporary capture formats and personal visual language.','Lo-fi digital intimacy and fragmentary everyday imagery.')
) as data(slug,title,release_year,country_code,short_summary,why_it_matters,key_innovation)
on conflict (slug) do update set
  title = excluded.title,
  release_year = excluded.release_year,
  country_code = excluded.country_code,
  status = excluded.status,
  is_canonical = excluded.is_canonical,
  short_summary = excluded.short_summary,
  why_it_matters = excluded.why_it_matters,
  key_innovation = excluded.key_innovation;

insert into public.music_video_details (work_id)
select id from public.works where slug in (
  'michael-jackson-thriller','a-ha-take-on-me','jamiroquai-virtual-insanity',
  'daft-punk-around-the-world','fatboy-slim-weapon-of-choice','beyonce-single-ladies',
  'childish-gambino-this-is-america','sakanaction-shin-takarajima',
  'kenshi-yonezu-lemon','hikaru-utada-one-last-kiss'
)
on conflict (work_id) do nothing;

insert into public.work_credits (work_id, entity_id, role_id, verification_status)
select w.id, e.id, r.id, 'source_found'
from (values
  ('michael-jackson-thriller','michael-jackson','artist'),
  ('michael-jackson-thriller','john-landis','director'),
  ('a-ha-take-on-me','a-ha','artist'),
  ('a-ha-take-on-me','steve-barron','director'),
  ('jamiroquai-virtual-insanity','jamiroquai','artist'),
  ('jamiroquai-virtual-insanity','jonathan-glazer','director'),
  ('daft-punk-around-the-world','daft-punk','artist'),
  ('daft-punk-around-the-world','michel-gondry','director'),
  ('fatboy-slim-weapon-of-choice','fatboy-slim','artist'),
  ('fatboy-slim-weapon-of-choice','spike-jonze','director'),
  ('beyonce-single-ladies','beyonce','artist'),
  ('beyonce-single-ladies','jake-nava','director'),
  ('childish-gambino-this-is-america','childish-gambino','artist'),
  ('childish-gambino-this-is-america','hiro-murai','director'),
  ('sakanaction-shin-takarajima','sakanaction','artist'),
  ('sakanaction-shin-takarajima','yusuke-tanaka','director'),
  ('kenshi-yonezu-lemon','kenshi-yonezu','artist'),
  ('kenshi-yonezu-lemon','tomokazu-yamada','director'),
  ('hikaru-utada-one-last-kiss','hikaru-utada','artist'),
  ('hikaru-utada-one-last-kiss','hideaki-anno','director')
) as d(work_slug, entity_slug, role_code)
join public.works w on w.slug = d.work_slug
join public.entities e on e.slug = d.entity_slug
join public.credit_roles r on r.code = d.role_code
on conflict (work_id, entity_id, role_id) do update set verification_status = excluded.verification_status;

insert into public.taxonomy_terms (category_id, slug, name)
select c.id, d.slug, d.name
from (values
  ('technique','rotoscope-animation','Rotoscope / Live Action + Animation'),
  ('technique','practical-set-illusion','Practical Set Illusion'),
  ('technique','long-take','Long Take'),
  ('technique','mixed-media','Mixed Media'),
  ('performance','choreography','Choreography'),
  ('performance','solo-performance','Solo Performance'),
  ('visual_style','monochrome','Monochrome'),
  ('visual_style','retro-television','Retro Television'),
  ('visual_style','cinematic-portrait','Cinematic Portrait'),
  ('visual_style','lo-fi-digital','Lo-Fi Digital'),
  ('narrative','social-commentary','Social Commentary'),
  ('narrative','long-form-narrative','Long-form Narrative'),
  ('location','single-location','Single Location'),
  ('curriculum_topic','mtv-era','MTV Era'),
  ('curriculum_topic','director-driven-1990s','Director-driven 1990s'),
  ('curriculum_topic','contemporary-japanese-mv','Contemporary Japanese MV')
) as d(category_code,slug,name)
join public.taxonomy_categories c on c.code = d.category_code
on conflict (category_id, slug) do update set name = excluded.name;

insert into public.work_taxonomy_terms (work_id, term_id, assignment_method)
select w.id, t.id, 'editorial'
from (values
  ('michael-jackson-thriller','long-form-narrative'),('michael-jackson-thriller','choreography'),('michael-jackson-thriller','mtv-era'),
  ('a-ha-take-on-me','rotoscope-animation'),('a-ha-take-on-me','mixed-media'),('a-ha-take-on-me','mtv-era'),
  ('jamiroquai-virtual-insanity','practical-set-illusion'),('jamiroquai-virtual-insanity','solo-performance'),('jamiroquai-virtual-insanity','director-driven-1990s'),
  ('daft-punk-around-the-world','choreography'),('daft-punk-around-the-world','director-driven-1990s'),
  ('fatboy-slim-weapon-of-choice','solo-performance'),('fatboy-slim-weapon-of-choice','single-location'),
  ('beyonce-single-ladies','choreography'),('beyonce-single-ladies','monochrome'),
  ('childish-gambino-this-is-america','long-take'),('childish-gambino-this-is-america','social-commentary'),
  ('sakanaction-shin-takarajima','retro-television'),('sakanaction-shin-takarajima','choreography'),('sakanaction-shin-takarajima','contemporary-japanese-mv'),
  ('kenshi-yonezu-lemon','cinematic-portrait'),('kenshi-yonezu-lemon','contemporary-japanese-mv'),
  ('hikaru-utada-one-last-kiss','lo-fi-digital'),('hikaru-utada-one-last-kiss','contemporary-japanese-mv')
) as d(work_slug,term_slug)
join public.works w on w.slug = d.work_slug
join public.taxonomy_terms t on t.slug = d.term_slug
on conflict (work_id, term_id) do nothing;

insert into public.curricula (slug,title,description,level,status,estimated_days,items_per_day)
values ('mv-history-pilot-10','MV History Pilot: 10 Essential Works','Pilot curriculum for validating ordering and lesson UI.','beginner','draft',2,5)
on conflict (slug) do update set title = excluded.title, description = excluded.description, level = excluded.level, status = excluded.status, estimated_days = excluded.estimated_days, items_per_day = excluded.items_per_day;

insert into public.curriculum_items (curriculum_id, work_id, sequence_number, day_number, lesson_title)
select c.id, w.id, d.sequence_number, d.day_number, d.lesson_title
from (values
  ('michael-jackson-thriller',1,1,'The cinematic expansion of music video'),
  ('a-ha-take-on-me',2,1,'Live action meets illustration'),
  ('jamiroquai-virtual-insanity',3,1,'Practical illusion and performance'),
  ('daft-punk-around-the-world',4,1,'Visualizing musical structure'),
  ('fatboy-slim-weapon-of-choice',5,1,'Character and choreography'),
  ('beyonce-single-ladies',6,2,'Minimalism and iconic movement'),
  ('childish-gambino-this-is-america',7,2,'Foreground, background, and social context'),
  ('sakanaction-shin-takarajima',8,2,'Reframing Japanese television history'),
  ('kenshi-yonezu-lemon',9,2,'Contemporary Japanese cinematic portraiture'),
  ('hikaru-utada-one-last-kiss',10,2,'Digital intimacy and personal imagery')
) as d(work_slug,sequence_number,day_number,lesson_title)
join public.curricula c on c.slug = 'mv-history-pilot-10'
join public.works w on w.slug = d.work_slug
on conflict (curriculum_id, work_id) do update set sequence_number = excluded.sequence_number, day_number = excluded.day_number, lesson_title = excluded.lesson_title;

commit;
