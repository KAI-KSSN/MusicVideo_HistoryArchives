# Pilot Awards Implementation Report

> Scope notice: the expanded 10-work research checklist was completed on
> 2026-07-12. A missing public relationship remains a publication-safety state:
> it means no registrable official evidence was found, not that a result could
> never have existed.

## Existing schema

MVHL already had normalized `awards`, `award_categories`, and `work_award_results` tables. The earlier schema lacked factual award-program metadata, historical category metadata, credited recipients, ceremony numbers, and mandatory result-level sources.

## Schema changes

- Expanded `awards` with official name, region, organizer, website, scope, operational status, active years, notes, and update timestamp.
- Expanded `award_categories` with official and normalized names, category type, and validity years.
- Expanded `work_award_results` with direct award reference, ceremony number, credited recipient, mandatory source, verification notes, and audit timestamps.
- Expanded controlled result and verification values.
- Added a source-backed structured public view: `archive_award_results`.
- Added a separate `recognition_programs` / `work_recognitions` model and
  `archive_recognitions` view for festival and editorial selections.
- Kept the legacy display adapter while making structured award and recognition
  arrays the source for the Object Information layout.

## Migrations

- `20260711210000_normalize_awards_and_registry.sql`
- `20260711211000_expose_structured_award_results.sql`
- `20260711212000_assert_awards_integrity.sql`
- `20260712120000_expand_verified_pilot_awards_and_recognitions.sql`
- `20260712121000_assert_expanded_awards_and_recognitions.sql`
- `20260712122000_link_award_and_recognition_sources.sql`
- `20260712123000_fix_one_last_kiss_award_slug.sql`

## Award registry

Created or updated factual master records for 19 programs requested by the sprint. Registry presence does not imply a relationship to a pilot work.

## Verified public pilot results

- Weapon of Choice: 1 verified result.
- Single Ladies (Put a Ring on It): 3 verified results.
- This Is America: 16 verified award results (wins, medal/Grand Prix outcomes,
  and nominations kept distinct) plus 2 non-award recognitions.
- 新宝島: 1 verified MV award.
- Lemon: 2 verified MV awards.
- One Last Kiss: 1 verified MV award.
- Thriller, Take On Me, Virtual Insanity and Around the World: no public award
  rows because historical claims did not reach the official-source threshold.

See `pilot-awards-audit.md` for the work-by-work decisions and unresolved claims.

## Corrections

- No retained result was removed; all 24 public award relationships have a
  direct stored result source.
- Historical MTV category capitalization was preserved.
- Craft recipients were separated from the artist-level result.
- No GRAMMY award for the song, album, or the separate making-of work was attached to the Thriller MV.

## Source coverage

- Public award results: 24 across 6 works.
- Results with a direct stored official source: 24.
- Public festival/editorial recognitions: 2, both source-backed and separated
  from competitive awards.
- Results using Wikipedia/search snippets as evidence: 0.
- Works currently left with an empty award history: 4.

## Validation

The integrity migration completed with zero exceptions for:

- duplicate award slugs;
- duplicate category identities;
- source-less results;
- implausible years;
- duplicate work/category/year/result combinations;
- unverified results attached to published works;
- orphaned results.
- source-less, duplicate, unverified or orphaned recognition rows.

The reusable queries are stored in `supabase/tests/awards_validation.sql`.

## Published-data safety

- `archive_works` continues to return only `status = 'published'` works.
- `archive_award_results` additionally requires `verified` or `cross_checked` results and an existing source.
- `archive_recognitions` applies the same verified/cross-checked publication gate.
- The public API returned 10 published pilot works, 24 structured award results
  and 2 separately typed recognitions.
- The UI renders Awards, Nominations, Festival Selections and Editorial
  Recognition as distinct Object Information rows.
- JSON fallback was not made primary and no new dependency on `data/videos.json` was introduced.

## Reversibility

The implementation is isolated in timestamped migrations. Public consumers can revert to the legacy `archive_works.awards` adapter while the structured view is removed or revised in a follow-up migration; existing work records are otherwise unchanged.
