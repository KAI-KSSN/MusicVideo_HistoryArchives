-- Release three previously held ★★★★★ Canon works after exact video identity resolution.
-- Optional runtime, VFX and other unverified fields remain NULL.

begin;

insert into public.taxonomy_categories (code,name,description,allows_multiple) values
  ('region','Region','Editorial browsing region.',false),
  ('era','Era','Release decade.',false),
  ('movement','Movement','Editorial movement from the approved Canon sheet.',true)
on conflict (code) do update set name=excluded.name,description=excluded.description,allows_multiple=excluded.allows_multiple;

insert into public.sources (source_type,title,publisher,url,accessed_at,notes) values
  ('director_portfolio','imai - Fly ft. 79, Kaho Nakamura','Baku Hashimoto','https://baku89.com/fly',current_date,'Verified Canon research source.'),
  ('director_portfolio','Making of “Fly”','Baku Hashimoto','https://baku89.com/ja/making-of/fly',current_date,'Verified Canon research source.'),
  ('official_video','imai / Fly feat.79, 中村佳穂','YouTube','https://www.youtube.com/watch?v=iQi3aMQXip8',current_date,'Video identity confirmed by YouTube oEmbed and the director official page embed.'),
  ('label','水曜日のカンパネラ Music Video','Warner Music Japan','https://wmg.jp/wedcamp/mv/',current_date,'Verified Canon research source.'),
  ('publication','水曜日のカンパネラ「バク」','Billboard Japan','https://www.billboard-japan.com/d_news/detail/49381/2',current_date,'Verified independent music-press source.'),
  ('publication','水曜日のカンパネラ、全編CGの新MV「バク」','音楽ナタリー','https://natalie.mu/music/news/226979',current_date,'Verified independent music-press source.'),
  ('official_video','水曜日のカンパネラ『バク』','YouTube','https://www.youtube.com/watch?v=mdEO6-Xv3O4',current_date,'Official artist-channel upload confirmed by YouTube oEmbed.'),
  ('artist_official','Yearning for the Infinite — Repetition','Max Cooper','https://www.yearningfortheinfinite.net/',current_date,'Official audiovisual project source.'),
  ('label','Yearning for the Infinite','Mesh','https://meshmeshmesh.net/yearning-for-the-infinite',current_date,'Official label release source.'),
  ('official_video','Max Cooper - Repetition (Official Video By Kevin McGloughlin)','YouTube','https://www.youtube.com/watch?v=nO9aot9RgQc',current_date,'Official artist-channel upload confirmed by YouTube oEmbed.'),
  ('award_archive','Winners of the Berlin Music Video Awards 2020','Berlin Music Video Awards','https://www.berlinmva.com/news/winners-berlin-music-video/',current_date,'Official result-level source.'),
  ('award_archive','Nominees 2020','Berlin Music Video Awards','https://www.berlinmva.com/bmva-nominees-2020/',current_date,'Official result-level source.'),
  ('award_archive','UKMVA 2020 winners & nominees','UK Music Video Awards','https://awards.ukmva.com/years/2020',current_date,'Official result-level source.')
on conflict (url) do update set source_type=excluded.source_type,title=excluded.title,publisher=excluded.publisher,accessed_at=excluded.accessed_at,notes=excluded.notes;

insert into public.awards (slug,name,official_name,country_code,region,organizer,website_url,official_url,scope,status) values
  ('berlin-music-video-awards','Berlin Music Video Awards','Berlin Music Video Awards','DE','International','Berlin Music Video Awards','https://www.berlinmva.com/','https://www.berlinmva.com/','dedicated_music_video','active'),
  ('uk-music-video-awards','UK Music Video Awards','UK Music Video Awards','GB','International','UK Music Video Awards','https://www.ukmva.com/','https://www.ukmva.com/','dedicated_music_video','active')
on conflict (slug) do update set name=excluded.name,official_name=excluded.official_name,organizer=excluded.organizer,website_url=excluded.website_url,official_url=excluded.official_url,scope=excluded.scope,status='active';

-- imai feat. 79, 中村佳穂 — Fly
insert into public.entities (slug,display_name,entity_type,country_code) values
  ('imai-feat-79-kaho-nakamura','imai feat. 79, 中村佳穂','other','JP'),
  ('baku-hashimoto','Baku Hashimoto','person',null)
on conflict (slug) do update set display_name=excluded.display_name;

insert into public.works (work_type_id,slug,title,original_title,release_year,country_code,status,is_canonical,verified_at,verification_notes)
select id,'imai-fly','Fly feat. 79, 中村佳穂','Fly feat. 79, 中村佳穂',2017,'JP','verified',true,now(),'Canon ★★★★★; exact video resolved from the director official page and matching YouTube upload; optional unknowns retained as NULL.'
from public.work_types where code='music_video'
on conflict (slug) do update set title=excluded.title,original_title=excluded.original_title,release_year=excluded.release_year,country_code=excluded.country_code,is_canonical=true,verified_at=excluded.verified_at,verification_notes=excluded.verification_notes;

insert into public.music_video_details (work_id,label,runtime_seconds,official_release_url)
select id,null,null,'https://www.youtube.com/watch?v=iQi3aMQXip8' from public.works where slug='imai-fly'
on conflict (work_id) do update set label=excluded.label,runtime_seconds=excluded.runtime_seconds,official_release_url=excluded.official_release_url;

insert into public.work_credits (work_id,entity_id,role_id,verification_status)
select w.id,e.id,r.id,'verified' from public.works w join public.entities e on e.slug='imai-feat-79-kaho-nakamura' join public.credit_roles r on r.code='artist' where w.slug='imai-fly'
on conflict (work_id,entity_id,role_id) do update set verification_status='verified';
insert into public.work_credits (work_id,entity_id,role_id,verification_status)
select w.id,e.id,r.id,'verified' from public.works w join public.entities e on e.slug='baku-hashimoto' join public.credit_roles r on r.code='director' where w.slug='imai-fly'
on conflict (work_id,entity_id,role_id) do update set verification_status='verified';

insert into public.work_editorials (work_id,locale,short_summary,why_it_matters,historical_context,key_innovation,editorial_notes,verification_status,reviewed_at)
select id,'ja','小さな餅や菓子をコマごとに並べ替え、顔、群衆、記号、リズミカルな変形を作るストップモーション作品。','身近な食品素材の中に完全なパフォーマンス語彙を見出し、小さなスケールと触覚的な不完全さを制約ではなく強みとして用いました。','imai『Fly feat. 79, 中村佳穂』のために橋本麦が監督・アニメーションを担当し、アルバム『PSEP』に関連して発表されました。','置き換えによる直接的なストップモーションで、形、質感、かじられた跡、配置を音楽的タイミングへ変え、食べ物をグラフィック・キャラクターとして動かしています。','Acquisition reason: Candidate representative work for Experimental Animation.','verified',now() from public.works where slug='imai-fly'
on conflict (work_id,locale) do update set short_summary=excluded.short_summary,why_it_matters=excluded.why_it_matters,historical_context=excluded.historical_context,key_innovation=excluded.key_innovation,editorial_notes=excluded.editorial_notes,verification_status='verified',reviewed_at=excluded.reviewed_at;
insert into public.work_editorials (work_id,locale,short_summary,why_it_matters,historical_context,key_innovation,editorial_notes,verification_status,reviewed_at)
select id,'en','Small pieces of mochi and confectionery are rearranged frame by frame into faces, crowds, symbols, and rhythmic transformations.','The video finds a complete performance vocabulary inside ordinary food materials, using modest scale and tactile imperfection as strengths rather than limitations.','Directed and animated by Baku Hashimoto for imai''s Fly feat. 79 and Kaho Nakamura, the work was released in connection with the album PSEP.','Direct stop-motion substitution turns shape, texture, bite marks, and placement into musical timing, allowing edible objects to behave as graphic characters.','Acquisition reason: Candidate representative work for Experimental Animation.','verified',now() from public.works where slug='imai-fly'
on conflict (work_id,locale) do update set short_summary=excluded.short_summary,why_it_matters=excluded.why_it_matters,historical_context=excluded.historical_context,key_innovation=excluded.key_innovation,editorial_notes=excluded.editorial_notes,verification_status='verified',reviewed_at=excluded.reviewed_at;

insert into public.media_assets (work_id,platform,asset_type,external_id,url,is_official,availability_status,last_checked_at)
select id,'youtube','full_video','iQi3aMQXip8','https://www.youtube.com/watch?v=iQi3aMQXip8',true,'available',now() from public.works where slug='imai-fly'
on conflict (work_id,url) do update set external_id=excluded.external_id,is_official=true,availability_status='available',last_checked_at=excluded.last_checked_at;
insert into public.media_assets (work_id,platform,asset_type,url,is_official,availability_status,last_checked_at)
select id,'youtube','thumbnail','https://i.ytimg.com/vi/iQi3aMQXip8/hqdefault.jpg',true,'available',now() from public.works where slug='imai-fly'
on conflict (work_id,url) do update set is_official=true,availability_status='available',last_checked_at=excluded.last_checked_at;

-- 水曜日のカンパネラ — バク
insert into public.entities (slug,display_name,entity_type,country_code) values
  ('wednesday-campanella','水曜日のカンパネラ','other','JP'),
  ('sojiro-kamatani','鎌谷聡次郎','person',null)
on conflict (slug) do update set display_name=excluded.display_name;

insert into public.works (work_type_id,slug,title,original_title,release_year,country_code,status,is_canonical,verified_at,verification_notes)
select id,'wednesday-campanella-baku','バク','バク',2017,'JP','verified',true,now(),'Canon ★★★★★; exact video resolved from the official artist channel; optional unknowns retained as NULL.'
from public.work_types where code='music_video'
on conflict (slug) do update set title=excluded.title,original_title=excluded.original_title,release_year=excluded.release_year,country_code=excluded.country_code,is_canonical=true,verified_at=excluded.verified_at,verification_notes=excluded.verification_notes;

insert into public.music_video_details (work_id,label,runtime_seconds,official_release_url)
select id,'Warner Music Japan',null,'https://www.youtube.com/watch?v=mdEO6-Xv3O4' from public.works where slug='wednesday-campanella-baku'
on conflict (work_id) do update set label=excluded.label,runtime_seconds=excluded.runtime_seconds,official_release_url=excluded.official_release_url;

insert into public.work_credits (work_id,entity_id,role_id,verification_status)
select w.id,e.id,r.id,'verified' from public.works w join public.entities e on e.slug='wednesday-campanella' join public.credit_roles r on r.code='artist' where w.slug='wednesday-campanella-baku'
on conflict (work_id,entity_id,role_id) do update set verification_status='verified';
insert into public.work_credits (work_id,entity_id,role_id,verification_status)
select w.id,e.id,r.id,'verified' from public.works w join public.entities e on e.slug='sojiro-kamatani' join public.credit_roles r on r.code='director' where w.slug='wednesday-campanella-baku'
on conflict (work_id,entity_id,role_id) do update set verification_status='verified';

insert into public.work_editorials (work_id,locale,short_summary,why_it_matters,historical_context,key_innovation,editorial_notes,verification_status,reviewed_at)
select id,'ja','夢を食べる伝承上の獏を軸に、伸縮する身体、変形する建築、シュールな転換が連続するフルCGの夢世界。','ポップ・パフォーマンス全体を意図的に人工的なCG環境へ置き、アニメーションの自由度によって伝承と現代的な不条理表現を接続しました。','水曜日のカンパネラのために鎌谷聡次郎が監督した2017年の作品で、当時、同グループ初の全編CGミュージックビデオとして紹介されました。','通常のカット割りに代えて連続的な変容を用い、人物、小道具、建築の機能を同じアニメーション空間内で変化させ、変形そのものを物語の文法にしています。','Acquisition reason: Candidate representative work for Japanese Experimental.','verified',now() from public.works where slug='wednesday-campanella-baku'
on conflict (work_id,locale) do update set short_summary=excluded.short_summary,why_it_matters=excluded.why_it_matters,historical_context=excluded.historical_context,key_innovation=excluded.key_innovation,editorial_notes=excluded.editorial_notes,verification_status='verified',reviewed_at=excluded.reviewed_at;
insert into public.work_editorials (work_id,locale,short_summary,why_it_matters,historical_context,key_innovation,editorial_notes,verification_status,reviewed_at)
select id,'en','A fully computer-generated dream world follows a baku, the mythic eater of dreams, through elastic bodies, shifting architecture, and surreal transformations.','The video places an entire pop performance inside a deliberately synthetic CG environment, using the freedom of animation to connect folklore with contemporary visual absurdity.','Released in 2017 for Wednesday Campanella and directed by Sojiro Kamatani, the work was presented at the time as the group''s first music video made entirely with computer graphics.','Continuous metamorphosis replaces conventional cutting: characters, props, and architecture change function within the same animated space, making transformation the video''s narrative grammar.','Acquisition reason: Candidate representative work for Japanese Experimental.','verified',now() from public.works where slug='wednesday-campanella-baku'
on conflict (work_id,locale) do update set short_summary=excluded.short_summary,why_it_matters=excluded.why_it_matters,historical_context=excluded.historical_context,key_innovation=excluded.key_innovation,editorial_notes=excluded.editorial_notes,verification_status='verified',reviewed_at=excluded.reviewed_at;

insert into public.media_assets (work_id,platform,asset_type,external_id,url,is_official,availability_status,last_checked_at)
select id,'youtube','full_video','mdEO6-Xv3O4','https://www.youtube.com/watch?v=mdEO6-Xv3O4',true,'available',now() from public.works where slug='wednesday-campanella-baku'
on conflict (work_id,url) do update set external_id=excluded.external_id,is_official=true,availability_status='available',last_checked_at=excluded.last_checked_at;
insert into public.media_assets (work_id,platform,asset_type,url,is_official,availability_status,last_checked_at)
select id,'youtube','thumbnail','https://i.ytimg.com/vi/mdEO6-Xv3O4/hqdefault.jpg',true,'available',now() from public.works where slug='wednesday-campanella-baku'
on conflict (work_id,url) do update set is_official=true,availability_status='available',last_checked_at=excluded.last_checked_at;

-- Max Cooper — Repetition
insert into public.entities (slug,display_name,entity_type,country_code) values
  ('max-cooper','Max Cooper','other','GB'),
  ('kevin-mcgloughlin','Kevin McGloughlin','person',null),
  ('hinterland-films','Hinterland Films','company',null)
on conflict (slug) do update set display_name=excluded.display_name;

insert into public.works (work_type_id,slug,title,original_title,release_year,country_code,status,is_canonical,verified_at,verification_notes)
select id,'max-cooper-repetition','Repetition',null,2019,'GB','verified',true,now(),'Canon ★★★★★; exact identity resolved from the artist official audiovisual project and official YouTube channel; optional unknowns retained as NULL.'
from public.work_types where code='music_video'
on conflict (slug) do update set title=excluded.title,original_title=excluded.original_title,release_year=excluded.release_year,country_code=excluded.country_code,is_canonical=true,verified_at=excluded.verified_at,verification_notes=excluded.verification_notes;

insert into public.music_video_details (work_id,label,runtime_seconds,official_release_url)
select id,'Mesh',null,'https://www.youtube.com/watch?v=nO9aot9RgQc' from public.works where slug='max-cooper-repetition'
on conflict (work_id) do update set label=excluded.label,runtime_seconds=excluded.runtime_seconds,official_release_url=excluded.official_release_url;

insert into public.work_credits (work_id,entity_id,role_id,verification_status)
select w.id,e.id,r.id,'verified' from public.works w join public.entities e on e.slug='max-cooper' join public.credit_roles r on r.code='artist' where w.slug='max-cooper-repetition'
on conflict (work_id,entity_id,role_id) do update set verification_status='verified';
insert into public.work_credits (work_id,entity_id,role_id,verification_status)
select w.id,e.id,r.id,'verified' from public.works w join public.entities e on e.slug='kevin-mcgloughlin' join public.credit_roles r on r.code='director' where w.slug='max-cooper-repetition'
on conflict (work_id,entity_id,role_id) do update set verification_status='verified';
insert into public.work_credits (work_id,entity_id,role_id,verification_status)
select w.id,e.id,r.id,'verified' from public.works w join public.entities e on e.slug='hinterland-films' join public.credit_roles r on r.code='production_company' where w.slug='max-cooper-repetition'
on conflict (work_id,entity_id,role_id) do update set verification_status='verified';

insert into public.work_editorials (work_id,locale,short_summary,why_it_matters,historical_context,key_innovation,editorial_notes,verification_status,reviewed_at)
select id,'ja','都市構造、道路、風力タービン、身体が幾何学的に増殖し、画面の外まで伸び続けるように構成された作品。','反復を主題であると同時に制作方法として用い、現代社会の成長規模を連続するオーディオビジュアル・システムへ変換しました。','Kevin McGloughlinがMax Cooperの2019年のオーディオビジュアル・プロジェクト『Yearning for the Infinite』のために制作した作品で、技術、成長、無限を求める人間の営みを扱うBarbicanの委嘱を背景にしています。','再帰的なコンポジット、パララックス、鏡像化された建築、音楽と同期する蓄積によって、現実の都市映像を終わりのない空間構造へ変形しています。','Acquisition reason: Candidate representative work for Generative / Experimental.','verified',now() from public.works where slug='max-cooper-repetition'
on conflict (work_id,locale) do update set short_summary=excluded.short_summary,why_it_matters=excluded.why_it_matters,historical_context=excluded.historical_context,key_innovation=excluded.key_innovation,editorial_notes=excluded.editorial_notes,verification_status='verified',reviewed_at=excluded.reviewed_at;
insert into public.work_editorials (work_id,locale,short_summary,why_it_matters,historical_context,key_innovation,editorial_notes,verification_status,reviewed_at)
select id,'en','Urban structures, roads, turbines, and bodies multiply into layered geometries that appear to extend beyond the frame.','The film makes repetition both its subject and its construction method, translating the scale of modern growth into a continuous audiovisual system.','Created by Kevin McGloughlin for Max Cooper''s 2019 audiovisual project Yearning for the Infinite, the work was developed within a Barbican commission concerned with technology, growth, and the human pursuit of the unbounded.','Recursive compositing, parallax, mirrored architecture, and precisely timed accumulation transform documentary images of the built environment into apparently endless spatial structures.','Acquisition reason: Candidate representative work for Generative / Experimental.','verified',now() from public.works where slug='max-cooper-repetition'
on conflict (work_id,locale) do update set short_summary=excluded.short_summary,why_it_matters=excluded.why_it_matters,historical_context=excluded.historical_context,key_innovation=excluded.key_innovation,editorial_notes=excluded.editorial_notes,verification_status='verified',reviewed_at=excluded.reviewed_at;

insert into public.media_assets (work_id,platform,asset_type,external_id,url,is_official,availability_status,last_checked_at)
select id,'youtube','full_video','nO9aot9RgQc','https://www.youtube.com/watch?v=nO9aot9RgQc',true,'available',now() from public.works where slug='max-cooper-repetition'
on conflict (work_id,url) do update set external_id=excluded.external_id,is_official=true,availability_status='available',last_checked_at=excluded.last_checked_at;
insert into public.media_assets (work_id,platform,asset_type,url,is_official,availability_status,last_checked_at)
select id,'youtube','thumbnail','https://i.ytimg.com/vi/nO9aot9RgQc/hqdefault.jpg',true,'available',now() from public.works where slug='max-cooper-repetition'
on conflict (work_id,url) do update set is_official=true,availability_status='available',last_checked_at=excluded.last_checked_at;

-- Shared taxonomy assignments.
insert into public.taxonomy_terms (category_id,slug,name)
select id,'japan','Japan' from public.taxonomy_categories where code='region' on conflict (category_id,slug) do update set name=excluded.name;
insert into public.taxonomy_terms (category_id,slug,name)
select id,'international','International' from public.taxonomy_categories where code='region' on conflict (category_id,slug) do update set name=excluded.name;
insert into public.taxonomy_terms (category_id,slug,name)
select id,'2010s','2010s' from public.taxonomy_categories where code='era' on conflict (category_id,slug) do update set name=excluded.name;
insert into public.taxonomy_terms (category_id,slug,name)
select id,'electronic-stop-motion','Electronic / Stop Motion' from public.taxonomy_categories where code='genre' on conflict (category_id,slug) do update set name=excluded.name;
insert into public.taxonomy_terms (category_id,slug,name)
select id,'j-pop-full-cg-animation','J-Pop / Full CG Animation' from public.taxonomy_categories where code='genre' on conflict (category_id,slug) do update set name=excluded.name;
insert into public.taxonomy_terms (category_id,slug,name)
select id,'electronic-generative-visuals','Electronic / Generative Visuals' from public.taxonomy_categories where code='genre' on conflict (category_id,slug) do update set name=excluded.name;
insert into public.taxonomy_terms (category_id,slug,name)
select id,'experimental-animation','Experimental Animation' from public.taxonomy_categories where code='movement' on conflict (category_id,slug) do update set name=excluded.name;
insert into public.taxonomy_terms (category_id,slug,name)
select id,'japanese-experimental','Japanese Experimental' from public.taxonomy_categories where code='movement' on conflict (category_id,slug) do update set name=excluded.name;
insert into public.taxonomy_terms (category_id,slug,name)
select id,'generative-experimental','Generative / Experimental' from public.taxonomy_categories where code='movement' on conflict (category_id,slug) do update set name=excluded.name;

insert into public.work_taxonomy_terms (work_id,term_id,assignment_method,notes)
select w.id,t.id,'editorial','Verified or derived from verified metadata.' from public.works w join public.taxonomy_terms t on true join public.taxonomy_categories c on c.id=t.category_id where w.slug='imai-fly' and ((c.code='region' and t.slug='japan') or (c.code='era' and t.slug='2010s') or (c.code='genre' and t.slug='electronic-stop-motion') or (c.code='movement' and t.slug='experimental-animation'))
on conflict (work_id,term_id) do update set notes=excluded.notes;
insert into public.work_taxonomy_terms (work_id,term_id,assignment_method,notes)
select w.id,t.id,'editorial','Verified or derived from verified metadata.' from public.works w join public.taxonomy_terms t on true join public.taxonomy_categories c on c.id=t.category_id where w.slug='wednesday-campanella-baku' and ((c.code='region' and t.slug='japan') or (c.code='era' and t.slug='2010s') or (c.code='genre' and t.slug='j-pop-full-cg-animation') or (c.code='movement' and t.slug='japanese-experimental'))
on conflict (work_id,term_id) do update set notes=excluded.notes;
insert into public.work_taxonomy_terms (work_id,term_id,assignment_method,notes)
select w.id,t.id,'editorial','Verified or derived from verified metadata.' from public.works w join public.taxonomy_terms t on true join public.taxonomy_categories c on c.id=t.category_id where w.slug='max-cooper-repetition' and ((c.code='region' and t.slug='international') or (c.code='era' and t.slug='2010s') or (c.code='genre' and t.slug='electronic-generative-visuals') or (c.code='movement' and t.slug='generative-experimental'))
on conflict (work_id,term_id) do update set notes=excluded.notes;

-- Work/source links.
insert into public.work_sources (work_id,source_id,supports_fields,is_primary,notes)
select w.id,s.id,v.fields,v.primary_source,'Evidence ledger hold release.' from (values
  ('imai-fly','https://baku89.com/fly',array['officialTitle','director','animationCredit','album','productionConcept']::text[],false),
  ('imai-fly','https://baku89.com/ja/making-of/fly',array['releaseYear','director','animationCredit','productionConcept']::text[],false),
  ('imai-fly','https://www.youtube.com/watch?v=iQi3aMQXip8',array['officialTitle','artist','youtubeId','thumbnailUrl']::text[],true),
  ('wednesday-campanella-baku','https://wmg.jp/wedcamp/mv/',array['artist','label','officialVideoCatalogue']::text[],false),
  ('wednesday-campanella-baku','https://www.billboard-japan.com/d_news/detail/49381/2',array['officialTitle','releaseYear','director','fullCgProductionConcept']::text[],false),
  ('wednesday-campanella-baku','https://natalie.mu/music/news/226979',array['officialTitle','releaseYear','director','fullCgProductionConcept']::text[],false),
  ('wednesday-campanella-baku','https://www.youtube.com/watch?v=mdEO6-Xv3O4',array['officialTitle','artist','youtubeId','thumbnailUrl']::text[],true),
  ('max-cooper-repetition','https://www.yearningfortheinfinite.net/',array['officialTitle','artist','director','projectContext','historicalContext','visualConcept']::text[],false),
  ('max-cooper-repetition','https://meshmeshmesh.net/yearning-for-the-infinite',array['releaseYear','label','album','commissionContext']::text[],false),
  ('max-cooper-repetition','https://www.youtube.com/watch?v=nO9aot9RgQc',array['officialTitle','artist','director','youtubeId','thumbnailUrl']::text[],true),
  ('max-cooper-repetition','https://www.berlinmva.com/news/winners-berlin-music-video/',array['awardOutcome','director','productionCompany','label']::text[],false),
  ('max-cooper-repetition','https://www.berlinmva.com/bmva-nominees-2020/',array['awardNomination','director']::text[],false),
  ('max-cooper-repetition','https://awards.ukmva.com/years/2020',array['awardShortlist','director','productionCompany']::text[],false)
) as v(work_slug,source_url,fields,primary_source)
join public.works w on w.slug=v.work_slug join public.sources s on s.url=v.source_url
on conflict (work_id,source_id) do update set supports_fields=excluded.supports_fields,is_primary=excluded.is_primary,notes=excluded.notes;

-- Exact official award results for Repetition.
insert into public.award_categories (award_id,slug,name,official_name,normalized_name,category_type,valid_from_year,valid_to_year)
select id,'best-experimental','Best Experimental','Best Experimental','Best Experimental','other',2020,2020 from public.awards where slug='berlin-music-video-awards'
on conflict (award_id,slug) do update set name=excluded.name,official_name=excluded.official_name,normalized_name=excluded.normalized_name,category_type=excluded.category_type;
insert into public.award_categories (award_id,slug,name,official_name,normalized_name,category_type,valid_from_year,valid_to_year)
select id,'best-director','Best Director','Best Director','Best Director','direction',2020,2020 from public.awards where slug='berlin-music-video-awards'
on conflict (award_id,slug) do update set name=excluded.name,official_name=excluded.official_name,normalized_name=excluded.normalized_name,category_type=excluded.category_type;
insert into public.award_categories (award_id,slug,name,official_name,normalized_name,category_type,valid_from_year,valid_to_year)
select id,'best-animation-in-a-video','Best Animation in a Video','Best Animation in a Video','Best Animation in a Video','animation',2020,2020 from public.awards where slug='uk-music-video-awards'
on conflict (award_id,slug) do update set name=excluded.name,official_name=excluded.official_name,normalized_name=excluded.normalized_name,category_type=excluded.category_type;

insert into public.work_award_results (work_id,award_id,award_category_id,award_year,result,credited_name_text,source_id,verification_status,verification_notes)
select w.id,a.id,ac.id,2020,'winner','Kevin McGloughlin',s.id,'verified','Official result label: 1st Place' from public.works w join public.awards a on a.slug='berlin-music-video-awards' join public.award_categories ac on ac.award_id=a.id and ac.slug='best-experimental' join public.sources s on s.url='https://www.berlinmva.com/news/winners-berlin-music-video/' where w.slug='max-cooper-repetition'
on conflict (work_id,award_category_id,award_year,result) do update set award_id=excluded.award_id,credited_name_text=excluded.credited_name_text,source_id=excluded.source_id,verification_status='verified',verification_notes=excluded.verification_notes;
insert into public.work_award_results (work_id,award_id,award_category_id,award_year,result,credited_name_text,source_id,verification_status,verification_notes)
select w.id,a.id,ac.id,2020,'nominee','Kevin McGloughlin',s.id,'verified','Official result label: Nominee' from public.works w join public.awards a on a.slug='berlin-music-video-awards' join public.award_categories ac on ac.award_id=a.id and ac.slug='best-director' join public.sources s on s.url='https://www.berlinmva.com/bmva-nominees-2020/' where w.slug='max-cooper-repetition'
on conflict (work_id,award_category_id,award_year,result) do update set award_id=excluded.award_id,credited_name_text=excluded.credited_name_text,source_id=excluded.source_id,verification_status='verified',verification_notes=excluded.verification_notes;
insert into public.work_award_results (work_id,award_id,award_category_id,award_year,result,credited_name_text,source_id,verification_status,verification_notes)
select w.id,a.id,ac.id,2020,'shortlist','Kevin McGloughlin',s.id,'verified','Official result label: Shortlist; credited as animator and director; production company Hinterland Films.' from public.works w join public.awards a on a.slug='uk-music-video-awards' join public.award_categories ac on ac.award_id=a.id and ac.slug='best-animation-in-a-video' join public.sources s on s.url='https://awards.ukmva.com/years/2020' where w.slug='max-cooper-repetition'
on conflict (work_id,award_category_id,award_year,result) do update set award_id=excluded.award_id,credited_name_text=excluded.credited_name_text,source_id=excluded.source_id,verification_status='verified',verification_notes=excluded.verification_notes;

update public.works
set status='published',published_at=coalesce(published_at,now()),verified_at=coalesce(verified_at,now())
where slug in ('imai-fly','wednesday-campanella-baku','max-cooper-repetition');

do $$ begin
  if (select count(*) from public.works where slug in ('imai-fly','wednesday-campanella-baku','max-cooper-repetition') and status='published') <> 3 then
    raise exception 'Three resolved Canon works were not published';
  end if;
  if (select count(*) from public.work_award_results war join public.works w on w.id=war.work_id where w.slug='max-cooper-repetition' and war.verification_status='verified') <> 3 then
    raise exception 'Repetition exact award results were not fully inserted';
  end if;
end $$;

commit;
