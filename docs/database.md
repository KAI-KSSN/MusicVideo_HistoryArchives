# Database Design

## Design Goals

The database should support:

- Music video history
- Detailed production credits
- Awards
- Technical and visual tags
- Historical context
- External media availability
- Future film and commercial expansion

## Core Model

- works
- work_types
- music_video_details
- entities
- credit_roles
- work_credits
- taxonomy_categories
- taxonomy_terms
- work_taxonomy_terms
- awards
- award_categories
- work_award_results
- media_assets
- sources
- work_sources
- work_relationships

## Key Design Decisions

### Works as the core entity

`works` is intentionally broader than `music_videos`.

This allows future support for:

- commercials
- films
- title sequences
- fashion films

### Shared entity system

People, artists, companies, agencies, studios, and collectives are stored as entities.

Their relationship to a work is defined through credits.

### Technology / Visual Language knowledge graph (v2.0)

Technology and Visual Language use dedicated controlled taxonomies rather than the legacy generic tag table.

- `technologies` and `visual_languages` hold bilingual concept definitions, aliases, families, lifecycle state, and stable slugs.
- `work_technologies` and `work_visual_languages` are evidence-bearing relationships with relevance, role, bilingual notes, verification state, and display order.
- source-association tables preserve evidence without exposing verification notes or research internals to public clients.
- `archive_work_technologies` and `archive_work_visual_languages` are the public, RLS-safe read models used by the frontend.

Only `published` concepts and `verified` relationships connected to `published` works can be returned publicly. An empty relationship set is valid and preferred over an unsupported classification.

The generic taxonomy remains available for legacy metadata, but it is not the canonical model for v2.0 Technology or Visual Language.

### Source-first verification

Important facts should be connected to source records whenever possible.
