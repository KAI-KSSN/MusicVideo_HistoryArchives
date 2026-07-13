# Technology Taxonomy v2.0

Technology describes a production or post-production method that can be supported by a production credit, technical breakdown, interview, or other reliable source. It does not describe mood, composition, narrative form, or a merely visible effect.

## Inclusion rules

- Add a work relationship only when the technique is explicitly documented by a reliable source.
- Prefer primary sources: production companies, equipment makers, artists, directors, cinematographers, editors, and award archives.
- A visible resemblance is not enough to infer how an image was made.
- Use `defining_use` only when the technique materially structures the work. Use `notable_example` for a clearly documented but less central use.
- Keep uncertain or disputed research private. Public views expose only `verified` relationships.

## Historical-priority labels

Use `earliest_verified_adoption`, `early_adoption`, `breakthrough_use`, `defining_use`, `modern_evolution`, or `standard_use` only when the evidence supports that scope. Never publish “first ever” from absence of earlier examples. Sprint 1 uses only `defining_use` for its two Technology relationships.

## Controlled vocabulary

The database contains 31 published concepts with stable slugs, bilingual names, bilingual definitions, aliases, and a family field.

| Family | Concepts |
|---|---|
| Animation | Procedural Animation, Rotoscoping, Stop-Motion Photography |
| Camera | Drone Cinematography, FPV Drone, Motion Control, Robotic Camera, Steadicam |
| Capture | High-Speed Photography, LiDAR, Motion Capture, Performance Capture, Photogrammetry, Point Cloud Capture, Time-Lapse Photography, Volumetric Capture, Volumetric Scan |
| Display | LED Volume, Projection Mapping |
| Post-production | 3D Camera Tracking, Digital Compositing |
| Production | Unreal Engine, Virtual Production |
| VFX | AI Image Generation, AI Video Generation, CGI, Gaussian Splatting, Generative Graphics, Morphing, Particle Simulation, Real-Time Rendering |

## Important distinctions

### Motion Control vs camera movement

Motion Control requires a programmable or repeatable camera-motion system. A smooth dolly, crane, tracking shot, or coordinated set movement is not sufficient evidence.

### Volumetric Scan vs Volumetric Capture

- **Volumetric Scan**: a static or sequential 3D scan of a subject or space.
- **Volumetric Capture**: multi-view capture reconstructing performance over time.
- **LiDAR Scanning**: depth measurement by laser ranging.
- **Photogrammetry**: 3D reconstruction from overlapping photographs.
- **Point Cloud Capture**: recording surfaces or space as measured three-dimensional points; it may use LiDAR, photogrammetry, or another process.

These concepts may coexist, but one must not be inferred from another without evidence.

### AI Image Generation

Use only when a source explicitly identifies generative AI as part of the image-making process. Algorithmic animation, procedural graphics, machine vision, or neural post-processing are not automatically AI image generation.

## Pilot implementation

Sprint 1 intentionally publishes only two technology relationships:

- a-ha — Take On Me → Rotoscoping (`defining_use`)
- Childish Gambino — This Is America → Steadicam (`defining_use`)

All other pilot works remain unlinked at the Technology level until a suitable production source is available.
