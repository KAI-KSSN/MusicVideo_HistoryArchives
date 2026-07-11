# Sprint 3 — Supabase Migration (Pilot)

## Source modes

- `MVHL_DATA_SOURCE=json`: existing 1000-work candidate file.
- `MVHL_DATA_SOURCE=supabase`: public `archive_works` view.
- `MVHL_JSON_FALLBACK=true`: emergency-only fallback during local migration.

Public deployments should use Supabase with JSON fallback disabled. This prevents
unpublished JSON candidates from appearing during a database outage.

## Publishing workflow

1. Keep the pilot work at `researching` while gathering sources.
2. Set it to `verified` only after metadata, editorial copy, and sources are reviewed.
3. Confirm that the public API still returns no record for the work.
4. Create a separate publication migration that sets `status = 'published'` and
   `published_at = now()`.
5. Confirm that the public API returns only the newly published work.

## Pilot verification

Before publishing Thriller:

```bash
EXPECTED_PUBLISHED_SLUGS="" npm run verify:pilot
```

After publishing Thriller:

```bash
EXPECTED_PUBLISHED_SLUGS="michael-jackson-thriller" npm run verify:pilot
```

## Reversibility

To remove a work from the public archive without deleting research data, create a
new migration that changes its status from `published` back to `verified` and sets
`published_at = null`.

Never edit an already-applied migration.
