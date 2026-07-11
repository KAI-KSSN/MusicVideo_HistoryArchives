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

### Extensible taxonomy

New technologies and visual techniques should be added as taxonomy terms rather than new database columns.

Examples:

- rotoscope
- motion control
- virtual production
- generative AI
- volumetric capture
- Gaussian splatting

### Source-first verification

Important facts should be connected to source records whenever possible.
