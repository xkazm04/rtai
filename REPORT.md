# REPORT: lane n5-cast (branch `n5-cast`), night run 2026-11-04 -> 11-05

**DRAFT written at 19:00 (iteration 6).** The REPORT phase rewrites this at 08:40; every number below was measured on
this branch by 09c6c6eb. Masters (clips, stills, `frames.json`, 15 entries) are in
`C:\Users\kazda\kiro\gtai-masters\n5\cast\`; `M/` below means that folder.

The owner's ask: "too heavy and thick main characters and cops which should be both closer to crowd in their default
state." Targets: r2_c3 (Rivet as the lanky + android hybrid), r2_c5 (cops), r1_c6/r1_c7 (one footprint, the size
ladder), r2_c6/r2_c7 (the cast at game scale).

## What works

### 1. One human footprint, measured (brief item 1)
`dev/bench/rig_footprint.gd` (plan view, idle stance), before at a1275c82 and after on the head
(`evidence/n5-cast/footprint-before.json`, `footprint-after.json`):

| who | shoulder span before -> after | bbox length x width after |
|---|---|---|
| ped (coat / jacket / hoodie), the authority | 0.83 m -> 0.83 m | 0.69 x 1.34 m |
| cop (patrol, riot, SWAT) | 1.31 m (1.58x ped) -> **0.90 m (1.08x)** | 1.01 x 1.45 m (riot 1.39 long with the shield) |
| Rivet | 1.14 m (1.37x ped) -> **1.00 m (1.20x ped, 1.11x cop)** | 1.47 x 1.51 m (1.04x a cop's width) |

DECISION (JOURNAL 17:05, `docs/decisions.md`): the crowd is the footprint authority; cops may run about 1.1x for kit;
Rivet is about 1.1x. Lineup dev scene: `dev/showcase/cast_lineup.gd` (32/64 px/m, `--walk`).
Evidence: `M/frames/lineup-slim-cops-ab-64ppm.png`, `M/frames/lineup-hybrid-ab-64ppm.png` (with r2_c3).

### 2. Slim cops (brief item 2), 28becde8
Cop size_k 1.45 -> 1.0, limbs at ped length (`COP_LIMB_K`); blue identity, riot shield and SWAT look kept. Every
reaction family and death still reads at the same frame as main: `M/frames/react-board-ab-64ppm.png`,
`M/cast-react-board-ab-64ppm.mp4`. The brutality chapters (burn, electro, katana and chainsaw splits on the slim
parts, the riot cop) are identical in sim and read: `M/frames/brutal-ab-64ppm.png`,
`M/cast-before-brutal-64.mp4` / `M/cast-hybrid-brutal-64.mp4`.

### 3. Rivet as the hybrid (brief item 3), 516475c9 .. fa395f74
- Rig: size_k 0.97, lanky legs (leg_k 1.15, gait_k 1.15), arms 0.85 long; `FORM_STOCKY` keeps the old base for A/B
  and the Hauler tank hangs off `BODY_SIZE_K` 1.2, so the rig still scales up (the transform is not tonight's).
- Art: three Codex sheets from r2_c3 and the concept (body/helmet/collar, piston arms, piston legs), cut to the d4
  template cells with the bone lengths kept; provenance lines in `steam/ai-provenance/2026-11.jsonl`.
- Core sticker fix (fa395f74): the hybrid helmet and torso's seams aliased into ink specks at 32 px/m;
  `tools/art/rivet_seam_thin.py` quiets them under the sticker threshold: `M/frames/rivet-core-seams-ab.png`.
- Motion: `M/cast-hybrid-motion-48.mp4`, `M/frames/rivet-legs-motion-32ppm.png` (walk, faster sprint, claw combo).
- The Hauler keeps its own body plan and size and plays on the hybrid base (transform, drive-through, stomp; 0
  script errors): `M/frames/hauler-on-hybrid-32ppm.png`.

### 4. The proof (brief item 5)
- Director reel, 32 px/m, main | n5-cast side by side: `M/cast-director-ab-32.mp4`, still
  `M/frames/director-final-ab-32ppm.png` (claw combo, pistol, machine pistol identical tick for tick).
- City block 15 s: `M/cast-city-ab-32.mp4`. 64 px/m close-up: `M/cast-hybrid-director-64.mp4`.
- Target composite: `M/frames/cast-ingame-vs-r2c6.png`.

### Gates (iteration 6, on 850c543a; only art and docs since)
lint 13/13, unit 940/0, scenarios 46/0, parity exact (planted mutation caught at 629), look goldens junction 11/11
and block 5/5 (blocks re-blessed once at 618d6eb8 after a bisect against main; decisions line). Bench not run.

## What does not work / is open
- Rivet's thin pale limbs are faint on dark asphalt at 32 px/m (`M/frames/rivet-legs-motion-32ppm.png`). A darker
  limb tone was tried and rejected (`M/frames/rivet-limb-tone-trial.png`, JOURNAL 18:40).
- Rivet came out at 1.20x the crowd's shoulder span (planned 1.1x): the hybrid shoulder plates are wide.
- Gearbox was not filmed on the hybrid base. It has no body plan of its own (`powers.json`: a remote car hijack;
  Rivet stays on foot as the base plan, his move scaled by `rivet_move_k`), so it cannot break the rig.
- The camera gap to r2_c6/r2_c7: the targets are 3/4 views with legs; the game is plan view.

## Calls for the owner
1. Rivet's size: A, as built, 1.20x the crowd's span (1.11x a cop's), his core clearly larger than a cop's as
   in `r1_c7`; or B, exactly 1.1x the crowd (`RivetPlan.FORM_TRIM`, size_k 0.89; switch with
   `FORMS[FORM_BASE].x` 0.97 -> 0.89). Still with the scale chart: `M/frames/rivet-size-call-64ppm.png`.
2. Limb weight at 32 px/m: as built, or heavier (`ARMS[FORM_BASE].z` 0.9 -> 1.0, `LEGS[FORM_BASE].y` 1.0 -> 1.2).
3. Held guns are sized in metres (the look lane's `weapon_art.json`), so they read large on the slimmer Rivet:
   `M/cast-hybrid-director-64.mp4`.

## Next steps
See the last `NEXT` entry in `JOURNAL.md`.
