# MVHL Database v1

## Files

- `schema.sql`: Supabase/PostgreSQL schema, RLS, and base dictionaries.
- `seed_10.sql`: Ten-work pilot dataset. It stays in `researching` status.

## Apply in Supabase

1. Open **SQL Editor**.
2. Paste and run `schema.sql`.
3. Create another query.
4. Paste and run `seed_10.sql`.

## Confirm in Table Editor

- `works`: 10 rows
- `entities`: 20 rows
- `work_credits`: 20 rows
- `curricula`: 1 row
- `curriculum_items`: 10 rows

## Publish one test work

```sql
update public.works
set status = 'published',
    published_at = now(),
    last_reviewed_at = now()
where slug = 'a-ha-take-on-me';
```

RLS allows browser users to read only `published` works. No browser-side write policy is created yet.

## Design summary

- `works`: reusable core for future MV, commercial, film, and title-sequence records.
- `music_video_details`: MV-only fields.
- `entities + credit_roles + work_credits`: artists, directors, companies, VFX studios, agencies, and future roles.
- `taxonomy_*`: new techniques and technologies without schema changes.
- `sources + work_sources`: evidence and verification.
- `curricula + curriculum_items`: “five works a day” textbook mode.
- `media_assets`: supports removed, archived, region-locked, or metadata-only assets.
