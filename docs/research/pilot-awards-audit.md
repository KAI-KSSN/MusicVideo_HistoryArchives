# Pilot Awards Audit

Status: baseline audit completed before the structured-awards migration.

## Rules

- An empty award history is valid.
- Search snippets and Wikipedia are discovery aids only.
- A result is retained only when an official award archive or awarding organization identifies the work, year, category, and outcome.
- Awards for a song, album, making-of documentary, artist career, or unrelated work are not attached to the music video.
- Nominations, selections, and wins remain distinct.
- Every public result must link directly to a stored source.

## Current database baseline

Five `winner` rows currently exist across three works. They were inserted before result-level source links existed:

| Work | Current record | Baseline decision |
|---|---|---|
| Weapon of Choice | GRAMMY Awards — Best Music Video (2002), winner | Retain after linking the GRAMMY official archive directly to the result. |
| Single Ladies (Put a Ring on It) | MTV Video Music Awards — Video of the Year (2009), winner | Retain after linking the official MTV/Paramount winners release. |
| Single Ladies (Put a Ring on It) | MTV Video Music Awards — Best Choreography (2009), winner | Retain; credit JaQuel Knight and Frank Gatson Jr. in `credited_name_text`. |
| Single Ladies (Put a Ring on It) | MTV Video Music Awards — Best Editing (2009), winner | Retain; credit Jarrett Fijal in `credited_name_text`. |
| This Is America | GRAMMY Awards — Best Music Video (2019), winner | Retain after linking the GRAMMY official archive directly to the result. |

## Work-by-work audit

### Michael Jackson — Thriller

- Current award data: none.
- Proposed public data: none at this stage.
- Add/remove/modify: no result row.
- Official findings: GRAMMY sources distinguish the song and album awards from `Making Michael Jackson's Thriller`, a separate making-of work that won the historical video-album/music-film category. The National Film Registry entry is a preservation selection, not an award win.
- Sources:
  - https://www.grammy.com/awards/26th-annual-grammy-awards/
  - https://www.grammy.com/awards/27th-annual-grammy-awards/
  - https://www.loc.gov/item/prn-09-250/
- Verification: verified absence of a GRAMMY music-video win for the MV itself within the checked official records.
- Unresolved: historical MTV VMA craft results require a sufficiently explicit official archive before insertion.

### a-ha — Take On Me

- Current award data: none.
- Proposed public data: none until an official historical result page is stored.
- Add/remove/modify: no result row.
- Verification: unresolved.
- Unresolved: frequently reported historical MTV VMA results were not accepted from secondary summaries.

### Jamiroquai — Virtual Insanity

- Current award data: none.
- Proposed public data: none until an official historical result page is stored.
- Add/remove/modify: no result row.
- Verification: unresolved.
- Unresolved: frequently reported MTV VMA results require official archive confirmation.

### Daft Punk — Around the World

- Current award data: none.
- Proposed public data: none.
- Add/remove/modify: no result row.
- Verification: no trustworthy award result accepted during this pass.
- Unresolved: historical nominations may exist, but no relationship is inserted without an official result.

### Beyoncé — Single Ladies (Put a Ring on It)

- Current award data: three MTV VMA winner rows.
- Proposed corrected data:
  - MTV Video Music Awards — `VIDEO OF THE YEAR` — winner — 2009 — credited recipient: Beyoncé.
  - MTV Video Music Awards — `BEST CHOREOGRAPHY` — winner — 2009 — credited recipients: JaQuel Knight & Frank Gatson Jr.
  - MTV Video Music Awards — `BEST EDITING` — winner — 2009 — credited recipient: Jarrett Fijal.
- Add/remove/modify: retain all three; add direct source and credited-recipient fields; preserve official uppercase category labels.
- Official source: https://ir.paramount.com/news-releases/news-release-details/beyonce-green-day-lady-gaga-lead-way-three-moonmen-2009-video
- Verification: verified.
- Unresolved: other award programs are outside the accepted set until independently audited.

### Fatboy Slim — Weapon of Choice

- Current award data: one GRAMMY winner row.
- Proposed corrected data:
  - GRAMMY Awards — `Best Music Video` — winner — 2002 — credited recipient: Spike Jonze.
- Add/remove/modify: retain; add direct official source, ceremony number, and credited entity.
- Official source: https://www.grammy.com/artists/spike-jonze/9835/
- Verification: verified.
- Unresolved: MTV VMA craft wins are not inserted in this pass without an accepted official historical result record.

### Childish Gambino — This Is America

- Current award data: one GRAMMY winner row.
- Proposed corrected data:
  - GRAMMY Awards — `Best Music Video` — winner — 2019 — credited recipient: Hiro Murai.
- Add/remove/modify: retain; add direct official source, ceremony number, and credited entity.
- Official source: https://www.grammy.com/artists/hiro-murai/243444/
- Verification: verified.
- Unresolved: other wins and nominations require separate official-result review.

### サカナクション — 新宝島

- Current award data: none.
- Proposed public data: none.
- Add/remove/modify: no result row.
- Verification: no exact official award result accepted during this pass.
- Unresolved: historical SPACE SHOWER and MTV VMAJ archives require exact work/category/result confirmation.

### 米津玄師 — Lemon

- Current award data: none.
- Proposed public data: none.
- Add/remove/modify: no result row.
- Verification: no exact official music-video award result accepted during this pass.
- Unresolved: song-level and artist-level honors must not be attached to the video.

### 宇多田ヒカル — One Last Kiss

- Current award data: none.
- Proposed public data: none.
- Add/remove/modify: no result row.
- Verification: no exact official music-video award result accepted during this pass.
- Unresolved: MUSIC AWARDS JAPAN entry lists are not treated as wins, and the 2021 work predates that award program.

## Planned corrections

1. Add factual master-data fields to `awards` and `award_categories`.
2. Add `award_id`, result-level `source_id`, credited recipient, ceremony number, and audit timestamps to `work_award_results`.
3. Expand controlled result and verification values without collapsing historical outcomes.
4. Backfill direct sources and credited recipients for the five retained results.
5. Publicly expose only results with `verified` or `cross_checked` status and a source.
6. Return a structured awards array while retaining a temporary string adapter for the current Object Information layout.

## Source coverage

- Retained results: 5
- Retained results with official awarding-organization evidence: 5
- Pilot works intentionally left without award rows after this pass: 7
- Results based only on Wikipedia, search snippets, fan sites, or generated databases: 0
