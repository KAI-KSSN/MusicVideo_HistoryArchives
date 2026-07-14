-- Private editorial audit ledger. This records that a published work was
-- individually reviewed even when no public graph relationship was warranted.
begin;

create table if not exists public.knowledge_graph_work_reviews (
  work_id uuid primary key references public.works(id) on delete cascade,
  sprint text not null,
  technology_outcome text not null check (technology_outcome in ('assigned','none','preserved')),
  visual_language_outcome text not null check (visual_language_outcome in ('assigned','none','preserved')),
  review_note_ja text not null,
  review_note_en text not null,
  deliberately_not_assigned text[] not null default '{}',
  unresolved_questions text[] not null default '{}',
  reviewed_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists knowledge_graph_work_reviews_set_updated_at on public.knowledge_graph_work_reviews;
create trigger knowledge_graph_work_reviews_set_updated_at
before update on public.knowledge_graph_work_reviews
for each row execute function public.set_updated_at();

alter table public.knowledge_graph_work_reviews enable row level security;
revoke all on table public.knowledge_graph_work_reviews from anon, authenticated;

comment on table public.knowledge_graph_work_reviews is
  'Private audit trail for individual Technology / Visual Language review, including valid no-classification outcomes.';

commit;
