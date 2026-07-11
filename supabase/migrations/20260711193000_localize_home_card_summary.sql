-- MVHL Home cards reuse the locale-specific short summary in work_editorials.
-- This keeps objective metadata, editorial interpretation, and viewing-lens
-- tags separate without introducing Home-only duplicate columns.

begin;

update public.work_editorials we
set
  short_summary = 'ドラマチックな物語、振付、特殊メイクを融合した長編形式のミュージックビデオ。',
  updated_at = now()
from public.works w
where we.work_id = w.id
  and w.slug = 'michael-jackson-thriller'
  and we.locale = 'ja';

update public.work_editorials we
set
  short_summary = 'A long-form music video combining dramatic narrative, choreography, make-up, and special effects.',
  updated_at = now()
from public.works w
where we.work_id = w.id
  and w.slug = 'michael-jackson-thriller'
  and we.locale = 'en';

commit;
