# Pilot Awards Implementation Report

> Scope notice: schema normalization and validation are complete. The expanded
> award-research scope across every listed program is still in progress. The
> five public results are official-source-backed, but the absence of a result on
> the other works is not yet a completed negative finding.

## Existing schema

MVHL already had normalized `awards`, `award_categories`, and `work_award_results` tables. The earlier schema lacked factual award-program metadata, historical category metadata, credited recipients, ceremony numbers, and mandatory result-level sources.

## Schema changes

- Expanded `awards` with official name, region, organizer, website, scope, operational status, active years, notes, and update timestamp.
- Expanded `award_categories` with official and normalized names, category type, and validity years.
- Expanded `work_award_results` with direct award reference, ceremony number, credited recipient, mandatory source, verification notes, and audit timestamps.
- Expanded controlled result and verification values.
- Added a source-backed structured public view: `archive_award_results`.
- Kept the legacy display adapter in the frontend while making `MusicVideo.awards` the structured source.

## Migrations

- `20260711210000_normalize_awards_and_registry.sql`
- `20260711211000_expose_structured_award_results.sql`
- `20260711212000_assert_awards_integrity.sql`

## Award registry

Created or updated factual master records for 19 programs requested by the sprint. Registry presence does not imply a relationship to a pilot work.

## Currently verified pilot results

- Weapon of Choice: 1 verified result.
- Single Ladies (Put a Ring on It): 3 verified results.
- This Is America: 1 verified result.
- Thriller, Take On Me, Virtual Insanity, Around the World, 新宝島, Lemon, and One Last Kiss: no public award results at this stage. Expanded-scope research remains in progress.

See `pilot-awards-audit.md` for the work-by-work decisions and unresolved claims.

## Corrections

- No retained result was removed; all five had official awarding-organization evidence.
- All five were corrected from source-less rows to directly source-backed rows.
- Historical MTV category capitalization was preserved.
- Craft recipients were separated from the artist-level result.
- No GRAMMY award for the song, album, or the separate making-of work was attached to the Thriller MV.

## Source coverage

- Public award results: 5.
- Results with a direct stored official source: 5.
- Results using Wikipedia/search snippets as evidence: 0.
- Works currently left with an empty award history: 7. This is a publication-safety state, not a claim that exhaustive research found no recognition.

## Validation

The integrity migration completed with zero exceptions for:

- duplicate award slugs;
- duplicate category identities;
- source-less results;
- implausible years;
- duplicate work/category/year/result combinations;
- unverified results attached to published works;
- orphaned results.

The reusable queries are stored in `supabase/tests/awards_validation.sql`.

## Published-data safety

- `archive_works` continues to return only `status = 'published'` works.
- `archive_award_results` additionally requires `verified` or `cross_checked` results and an existing source.
- The public API returned 10 published pilot works and exactly 5 structured award results.
- JSON fallback was not made primary and no new dependency on `data/videos.json` was introduced.

## Reversibility

The implementation is isolated in timestamped migrations. Public consumers can revert to the legacy `archive_works.awards` adapter while the structured view is removed or revised in a follow-up migration; existing work records are otherwise unchanged.
