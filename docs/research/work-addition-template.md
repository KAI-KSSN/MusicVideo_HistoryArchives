# MVHL Standard Work Addition Research Template

This document is mandatory for every new work added to MVHL. Complete it before a work moves from `researching` to `verified`, and run the publication validator before changing the status to `published`. Unknown facts remain `NULL`; an empty verified result is preferable to an unsupported claim.

## Identification

- Artist:
- Title:
- Official URL:
- YouTube ID:
- Existing work check:
  - Normalized artist/title:
  - YouTube ID:
  - Plausible slugs:
  - Existing people, companies, awards and concepts:
- Proposed slug:
- Existing UUID or new UUID:

## Core metadata

- Release date:
- Release year:
- Country:
- Director:
- Production:
- VFX / post:
- Cinematography:
- Editing:
- Choreography:
- Runtime:
- Label:
- Aspect ratio:
- Original release format:
- Unknown / deliberately empty fields:

Every populated factual field must name at least one source in the Sources section.

## Editorial

- Short Summary JA:
- Short Summary EN:
- Why It Matters JA:
- Why It Matters EN:
- Historical Context JA:
- Historical Context EN:
- Key Innovation JA:
- Key Innovation EN:
- Acquisition Reason:

Editorial writing must remain factual, restrained and museum-like. Do not use unsupported priority language such as “first ever.”

## Knowledge Graph — Technology

Repeat this block for every proposed relationship.

- Concept:
- Relevance:
- Relationship role:
- Verification status:
- Note JA:
- Note EN:
- Evidence:
- Source:
- Rejected alternatives:

Every public Technology relationship must have a stored source. A technique that merely seems likely must not be published.

## Knowledge Graph — Visual Language

Repeat this block for every proposed relationship.

- Concept:
- Relevance:
- Relationship role:
- Note JA:
- Note EN:
- Editorial rationale:
- Observation source:
- Rejected alternatives:

Publish only relationships that materially help a user move from the work to a useful concept and onward to another work.

## Awards

Complete the audit even when no result is found. A checked empty result is valid.

- Award:
- Year:
- Exact category:
- Result (winner / nominee / finalist / selection / craft recognition):
- Credited recipient:
- Source:
- Verification status:
- Exclusion or unresolved note:

Search the complete current MVHL award registry, plus relevant national and historical programs. Recording-only or artist-only results must not be stored as music-video results.

## Sources

Repeat for every source.

- URL:
- Title:
- Publisher:
- Accessed date:
- Source type:
- Supported fields:
- Primary source: Yes / No
- Notes:

Source order of preference: official artist or label; official production/post company; crew interview; recognized craft publication; reputable trade publication; institutional award archive. Wikipedia is discovery-only.

## Publication checklist

- [ ] Duplicate check completed
- [ ] Metadata verified
- [ ] Unknown metadata retained as `NULL`
- [ ] Bilingual editorial complete
- [ ] Technology reviewed
- [ ] Every published Technology edge has stored evidence
- [ ] Visual Language reviewed
- [ ] Rejected concept alternatives recorded
- [ ] Awards registry reviewed
- [ ] Sources attached
- [ ] Thumbnail valid
- [ ] Official Watch link valid
- [ ] Idempotent migration / seed created
- [ ] Migration assertions passed
- [ ] Public RLS confirmed
- [ ] Internal research notes remain private
- [ ] Home and detail page checked
- [ ] Technology and Visual Language concept pages checked
- [ ] JP / EN checked
- [ ] Light / Dark checked
- [ ] Desktop / mobile checked
- [ ] Production build successful
- [ ] Status changed `researching` → `verified` → `published`
- [ ] Git commit pushed
