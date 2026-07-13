-- MVHL v2.0: Technology / Visual Language research schema
-- These tables are intentionally private until the v2.0 UI and publication
-- rules are implemented. No vocabulary values or work assignments are seeded.

begin;

create table if not exists public.technologies (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  name_ja text,
  description text,
  description_ja text,
  technology_type text not null default 'other' check (
    technology_type in (
      'capture',
      'camera',
      'lighting',
      'production',
      'post_production',
      'vfx',
      'animation',
      'display',
      'delivery',
      'other'
    )
  ),
  parent_id uuid references public.technologies(id) on delete set null,
  lifecycle_status text not null default 'draft' check (
    lifecycle_status in ('draft', 'reviewed', 'approved', 'deprecated')
  ),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (slug = lower(slug)),
  check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  check (parent_id is null or parent_id <> id)
);

create index if not exists technologies_type_status_idx
on public.technologies(technology_type, lifecycle_status);

create index if not exists technologies_parent_idx
on public.technologies(parent_id)
where parent_id is not null;

drop trigger if exists technologies_set_updated_at on public.technologies;
create trigger technologies_set_updated_at
before update on public.technologies
for each row execute function public.set_updated_at();

create table if not exists public.visual_languages (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  name_ja text,
  description text,
  description_ja text,
  visual_language_type text not null default 'other' check (
    visual_language_type in (
      'composition',
      'camera_language',
      'lighting',
      'color',
      'editing',
      'narrative',
      'performance',
      'space',
      'image_treatment',
      'motion',
      'other'
    )
  ),
  parent_id uuid references public.visual_languages(id) on delete set null,
  lifecycle_status text not null default 'draft' check (
    lifecycle_status in ('draft', 'reviewed', 'approved', 'deprecated')
  ),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (slug = lower(slug)),
  check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  check (parent_id is null or parent_id <> id)
);

create index if not exists visual_languages_type_status_idx
on public.visual_languages(visual_language_type, lifecycle_status);

create index if not exists visual_languages_parent_idx
on public.visual_languages(parent_id)
where parent_id is not null;

drop trigger if exists visual_languages_set_updated_at on public.visual_languages;
create trigger visual_languages_set_updated_at
before update on public.visual_languages
for each row execute function public.set_updated_at();

create table if not exists public.work_technologies (
  id uuid primary key default gen_random_uuid(),
  work_id uuid not null references public.works(id) on delete cascade,
  technology_id uuid not null references public.technologies(id) on delete restrict,
  usage_role text not null default 'supporting' check (
    usage_role in ('primary', 'supporting', 'experimental', 'background', 'unknown')
  ),
  confidence numeric(4,3) check (confidence is null or confidence between 0 and 1),
  assignment_method text not null default 'editorial' check (
    assignment_method in ('editorial', 'imported', 'automated')
  ),
  verification_status text not null default 'unverified' check (
    verification_status in ('unverified', 'source_found', 'verified', 'disputed')
  ),
  verification_notes text,
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (work_id, technology_id)
);

create index if not exists work_technologies_work_idx
on public.work_technologies(work_id);

create index if not exists work_technologies_technology_idx
on public.work_technologies(technology_id);

create index if not exists work_technologies_verification_idx
on public.work_technologies(verification_status);

drop trigger if exists work_technologies_set_updated_at on public.work_technologies;
create trigger work_technologies_set_updated_at
before update on public.work_technologies
for each row execute function public.set_updated_at();

create table if not exists public.work_visual_languages (
  id uuid primary key default gen_random_uuid(),
  work_id uuid not null references public.works(id) on delete cascade,
  visual_language_id uuid not null references public.visual_languages(id) on delete restrict,
  prominence text not null default 'secondary' check (
    prominence in ('primary', 'secondary', 'detail', 'unknown')
  ),
  confidence numeric(4,3) check (confidence is null or confidence between 0 and 1),
  assignment_method text not null default 'editorial' check (
    assignment_method in ('editorial', 'imported', 'automated')
  ),
  editorial_rationale text,
  verification_status text not null default 'unverified' check (
    verification_status in ('unverified', 'source_found', 'verified', 'disputed')
  ),
  verification_notes text,
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (work_id, visual_language_id)
);

create index if not exists work_visual_languages_work_idx
on public.work_visual_languages(work_id);

create index if not exists work_visual_languages_language_idx
on public.work_visual_languages(visual_language_id);

create index if not exists work_visual_languages_verification_idx
on public.work_visual_languages(verification_status);

drop trigger if exists work_visual_languages_set_updated_at on public.work_visual_languages;
create trigger work_visual_languages_set_updated_at
before update on public.work_visual_languages
for each row execute function public.set_updated_at();

create table if not exists public.work_technology_sources (
  work_technology_id uuid not null references public.work_technologies(id) on delete cascade,
  source_id uuid not null references public.sources(id) on delete restrict,
  supports_fields text[] not null default array['technology']::text[],
  is_primary boolean not null default false,
  notes text,
  created_at timestamptz not null default now(),
  primary key (work_technology_id, source_id)
);

create index if not exists work_technology_sources_source_idx
on public.work_technology_sources(source_id);

create table if not exists public.work_visual_language_sources (
  work_visual_language_id uuid not null references public.work_visual_languages(id) on delete cascade,
  source_id uuid not null references public.sources(id) on delete restrict,
  supports_fields text[] not null default array['visual_language']::text[],
  is_primary boolean not null default false,
  notes text,
  created_at timestamptz not null default now(),
  primary key (work_visual_language_id, source_id)
);

create index if not exists work_visual_language_sources_source_idx
on public.work_visual_language_sources(source_id);

comment on table public.technologies is
  'MVHL v2.0 controlled vocabulary for production and image-making technologies.';
comment on table public.visual_languages is
  'MVHL v2.0 controlled vocabulary for visual-language and formal characteristics.';
comment on table public.work_technologies is
  'Private v2.0 staging assignments between works and verified technologies.';
comment on table public.work_visual_languages is
  'Private v2.0 staging assignments between works and visual-language terms.';
comment on table public.work_technology_sources is
  'Source evidence for a work-to-technology assignment.';
comment on table public.work_visual_language_sources is
  'Source evidence for a work-to-visual-language assignment.';

-- Keep the v2.0 research schema inaccessible to the public API until the UI,
-- publication rules, and approved vocabulary are ready.
alter table public.technologies enable row level security;
alter table public.visual_languages enable row level security;
alter table public.work_technologies enable row level security;
alter table public.work_visual_languages enable row level security;
alter table public.work_technology_sources enable row level security;
alter table public.work_visual_language_sources enable row level security;

revoke all on table public.technologies from anon, authenticated;
revoke all on table public.visual_languages from anon, authenticated;
revoke all on table public.work_technologies from anon, authenticated;
revoke all on table public.work_visual_languages from anon, authenticated;
revoke all on table public.work_technology_sources from anon, authenticated;
revoke all on table public.work_visual_language_sources from anon, authenticated;

do $$
begin
  if to_regclass('public.technologies') is null
     or to_regclass('public.visual_languages') is null
     or to_regclass('public.work_technologies') is null
     or to_regclass('public.work_visual_languages') is null
     or to_regclass('public.work_technology_sources') is null
     or to_regclass('public.work_visual_language_sources') is null then
    raise exception 'MVHL v2.0 Technology / Visual Language schema creation failed';
  end if;
end;
$$;

commit;
