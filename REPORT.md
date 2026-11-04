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
- Navy cops toward r2_c5 (e1f848a5): the limb ink fill and the patrol cap crown recoloured navy in D4 and D5
  (`masters:n5/cast/tools/cop_navy.py`; outline, hands and alpha kept). Every reaction family still reads, beside
  the target: `M/frames/cops-navy-vs-r2c5-64ppm.png`; lineup `M/frames/cop-navy-ab.png`; city on dark asphalt
  `M/frames/city-navy-ab-32ppm.png`; director reel unchanged in sim `M/frames/director-navy-ab-32ppm.png`
  (`M/cast-navy-director-32.mp4`, `M/cast-navy-city-32.mp4`).

### 3. Rivet as the hybrid (brief item 3), 516475c9 .. fa395f74
- Rig: size_k 0.97, lanky legs (leg_k 1.15, gait_k 1.15), arms 0.85 long; `FORM_STOCKY` keeps the old base for A/B
  and the Hauler tank hangs off `BODY_SIZE_K` 1.2, so the rig still scales up (the transform is not tonight's).
- Art: three Codex sheets from r2_c3 and the concept (body/helmet/collar, piston arms, piston legs), cut to the d4
  template cells with the bone lengths kept; provenance lines in `steam/ai-provenance/2026-11.jsonl`.
- Core sticker fix (fa395f74): the hybrid helmet and torso's seams aliased into ink specks at 32 px/m;
  `tools/art/rivet_seam_thin.py` quiets them under the sticker threshold: `M/frames/rivet-core-seams-ab.png`.
- Leg rim (85b912e5): a cream sticker halo under the piston legs at gameplay scale only, so they read on dark
  asphalt at 32 px/m: `M/frames/rivet-legrim-ab-32ppm.png`.
- Motion: `M/cast-hybrid-motion-48.mp4`, `M/frames/rivet-legs-motion-32ppm.png` (walk, faster sprint, claw combo).
- Close-up tone (5ae6aa3f, iteration 9): the hybrid art was already tan, but both part prints threw the hue away,
  so Rivet printed cream-white with violet-grey hatching. `BodyPlan.d5_warm` moves his D5 (56+ px/m) steel ramp to
  a warm tan halfway to r2_c3; at 32 px/m he stays cream as in r2_a5. Live city at 64 px/m, same ticks, beside r2_c3:
  `M/frames/rivet-warm-ab-vs-r2c3-64ppm.png` (clip `M/cast-warm-city-64.mp4`); director reel at 64 px/m
  `M/cast-warm-director-64.mp4` (claw 2/2, pistol 2/2, machine pistol 4/4, the same ticks as before). Call 5.
- Welder visor (0bcc34c6): a dark visor band with two cream eye slits on the helmet front, both tiers, alpha kept:
  `M/frames/rivet-visor-ab-64ppm.png`. It reads at 64 px/m and does not show at 32 px/m (the head is ~8 px).
- The D5 hit flash printed vermilion at 56+ px/m (missed when human-reactions moved print_part's flash to cream);
  now cream. React board at 64 px/m re-shot: 0 vermilion px over 481 frames, every family reads.
- The Hauler keeps its own body plan and size and plays on the hybrid base (transform, drive-through, stomp; 0
  script errors): `M/frames/hauler-on-hybrid-32ppm.png`.

### 4. The proof (brief item 5)
- Director reel, 32 px/m, main | n5-cast side by side: `M/cast-director-ab-32.mp4`, still
  `M/frames/director-final-ab-32ppm.png` (claw combo, pistol, machine pistol identical tick for tick).
- City block 15 s: `M/cast-city-ab-32.mp4`. 64 px/m close-up: `M/cast-hybrid-director-64.mp4`; with the navy cops
  `M/cast-navy-director-64.mp4` (still `M/frames/director-navy-64ppm.png`).
- Target composite: `M/frames/cast-ingame-vs-r2c6.png`.
- Every weapon (iteration 8): the full director reel WITH `--loadout=pistol` (the reel's documented args; my
  earlier checks lacked it, n5-look's note), 7200 ticks at 32 px/m: all 16 chapters n/n down, 0 script errors.
  One frame per chapter: `M/frames/director-loadout-16ch-32ppm.png`; clip of rocket .. katana
  `M/cast-loadout-weapons-32.mp4`.
- City block at 64 px/m on dark asphalt: `M/cast-navy-city-64.mp4` (15 s), still `M/frames/city-navy-64ppm.png`.
- Quest 1, Dock 9 fight on the cast rigs (`--rigs`, the dev flag): `M/cast-quest1-dock9-32.mp4`, still
  `M/frames/quest1-dock9-32ppm.png`, 0 script errors.
  At 64 px/m with the warm close-up Rivet and the visor (iteration 9): `M/cast-quest1-dock9-64.mp4`,
  `M/frames/quest1-dock9-64ppm.png`, 0 script errors.

### 5. The crowd (brief item 4)
- Footprint: the six pedestrian looks share one rig (`HumanPlan.ped`, size_k 1.25, span 0.83 m) and are the
  footprint's authority; cops sit at 0.90 m, Rivet at 1.00 m. No ped rig scale change was needed. In the live game
  (quest 1 `--rigs`, 48 px/m) the peds are about Rivet's core size: `M/frames/crowd-quest1-vs-r1c6-48ppm.png`
  (beside r1_c6, with the plan-view lineup).
- Open (iteration 10, diagnosed, not built): at 32 px/m every ped look prints as a dark mass, on slab and on
  asphalt (`M/frames/crowd-value-vs-r2a5.png`, from `cast_lineup.gd -- --crowd [--road]`, 2d6bb3b8). In r2_a5 and
  r2_c6 the peds are the palest figures (white shirts, pale coats, dark hair), so our peds and navy cops share one
  dark value at game zoom; only the cops' blue pads tell them apart. The cause is the ped art from above, not one
  print value, and it is not fully identified: two dark lobes ahead of the chest dominate the 32 px/m read.
  Part markers (one D4 ped part at a time recoloured vermilion, `M/frames/crowd-part-markers-32ppm.png`): the
  thighs show at the lobes' edges and the shoes at their tips, the upper arms end-on are the patches beside the
  head, the coat torso is only a rim around the head; forearm, pelvis, shin and foot_toeoff barely show. The lobes'
  dark interior is ped body art (all parts marked at once turn it red, `M/frames/crowd-part-markers-b-32ppm.png`) but
  no single part fills it: an overlap still to assign. Trials, each
  reverted: coat fill +42 L, a 0.72 head scale, straighter standing legs, a thinned coat outline, ped leg_w 0.7,
  all together (`M/frames/crowd-trials-32ppm.png`), and a new Codex ped sheet with a pale trench coat and smaller
  heads installed in D4 (`M/frames/crowd-sheet-trial-32ppm.png`, sheet `masters:n5/cast/gen/r4/out/ped_pale_a.png`,
  not shipped): all marginal. Next run: assign the lobe interior (the head and torso halos, the head part, the
  D5 thigh), fix that part (art or pose), then re-try the r4 sheet on top.

### Gates (iteration 9, `tools/evidence/run.mjs --no-bench` on 2f833a0b: lint 13/13, unit 940/1 where the 1 is the
known flake `test_noir_shadows` (2/2 alone, twice; the standalone suite on the same tree was 941/0), scenarios 46,
parity exact (mutation caught at 629), selftest look goldens 11/11 (worst 1.06), block 5/5, no re-bless.)
### Gates (iteration 7, `tools/evidence/run.mjs --no-bench` on cc4cb843: lint 13/13, unit 940/0, scenarios 46/0,
parity exact, selftest with look goldens 11/11 (worst 1.07) and block 5/5, no re-bless; iteration 6 on 850c543a:)
lint 13/13, unit 940/0, scenarios 46/0, parity exact (planted mutation caught at 629), look goldens junction 11/11
and block 5/5 (blocks re-blessed once at 618d6eb8 after a bisect against main; decisions line). Bench not run.

## What does not work / is open
- Fixed (85b912e5): Rivet's thin pale legs were faint on dark asphalt at 32 px/m (`M/frames/rivet-legs-motion-32ppm.png`).
  A cream leg rim at gameplay scale now carries them (`M/frames/rivet-legrim-ab-32ppm.png`); the arms keep their
  existing halo. A darker limb tone was tried and rejected (`M/frames/rivet-limb-tone-trial.png`, JOURNAL 18:40).
- Rivet came out at 1.20x the crowd's shoulder span (planned 1.1x): the hybrid shoulder plates are wide. Kept on
  purpose (Call 1, `M/frames/rivet-size-call-64ppm.png`).
- The cops match r2_c5's footprint, not its colour mass (`M/frames/cops-vs-r2c5-64ppm.png`): the target is navy
  all over (cap, sleeves, trousers); the game cop is black ink limbs, a cream cap disc and bright blue shoulder pads.
  Fixed in iteration 7 (e1f848a5), see section 2; the cap is now navy (Call 4).
- Gearbox was not filmed on the hybrid base. It has no body plan of its own (`powers.json`: a remote car hijack;
  Rivet stays on foot as the base plan, his move scaled by `rivet_move_k`), so it cannot break the rig.
- The crowd prints dark at 32 px/m against r2_a5's pale peds (section 5): diagnosed, needs a ped part sheet.
- The camera gap to r2_c6/r2_c7: the targets are 3/4 views with legs; the game is plan view.

## Calls for the owner
1. Rivet's size: A, as built, 1.20x the crowd's span (1.11x a cop's), his core clearly larger than a cop's as
   in `r1_c7`; or B, exactly 1.1x the crowd (`RivetPlan.FORM_TRIM`, size_k 0.89; switch with
   `FORMS[FORM_BASE].x` 0.97 -> 0.89). Still with the scale chart: `M/frames/rivet-size-call-64ppm.png`.
2. Limb weight at 32 px/m: A, as built (arm_w 0.9, leg_w 1.0), or B, heavier (`RivetPlan.FORM_HEAVY`: arm_w 1.0,
   leg_w 1.2; switch with `ARMS[FORM_BASE].z` 0.9 -> 1.0 and `LEGS[FORM_BASE].y` 1.0 -> 1.2, or render it with
   `cast_lineup.gd -- --form=heavy`). Walk and stand at 64 and 32 px/m: `M/frames/rivet-limb-call-ab.png`. B's
   legs reach a pedestrian's leg width; A keeps the lean pistons of r2_c3. Built: A (the owner asked for slimmer).
3. Held guns: n5-look answered my REQUEST (n5-look 01cd19f2, `rivet_arsenal.json held_size_ref` 1.2): after the
   merge the held gun follows `plan.size_k`, so this 0.97 Rivet carries 0.81x guns (their still
   `gtai-masters/n5/look/held-size-ab-cast-merge.png`; before: `M/cast-hybrid-director-64.mp4`). Off = 0.
4. The patrol cap and riot helmet crowns: navy as in r2_c5 (built, e1f848a5 and the helmet commit after it), or
   d5-cast's cream "T1" crowns, a stronger head mark at 32 px/m (`M/frames/city-navy-ab-32ppm.png`, left vs right;
   `M/frames/riot-helmet-navy-ab.png`). Revert = `git revert e1f848a5` (limbs too) or
   restore only `art/cop/head_cap.png` and `art/d5/cop/head_cap.png` from 29a853be.
   Option C, tried and not built (iteration 9): bright police-blue crowns as the helmets of r2_c6/r2_a5
   (`masters:n5/cast/tools/cop_crown_hi.py` on the pre-navy originals). At 32 px/m the bright crown merges with the
   bright upper-arm sleeves into one blue cluster, so the head stops being a distinct mark
   (`M/frames/cop-crown-trial-32ppm.png`). r2_c6's read (bright helmet over a navy body) would need navy sleeves too,
   and the targets disagree there (r2_c5 navy all over, r2_a5 bright shirts): your pick.
   Option D, also tried and not built: bright crowns AND navy upper-arm sleeves (the r2_c6 hierarchy, a bright head
   over a navy body): `M/frames/cop-crown-sleeve-trial-32ppm.png` (A | D, same ticks, beside r2_c6). D reads like
   r2_c6 but the cops get quieter on asphalt. Build = `cop_crown_hi.py` on the pre-navy crowns + the sleeve rule in
   JOURNAL 23:33 (D4 and D5 `upperarm`, `upperarm_endon`), then the react board and a golden check.

5. Rivet's close-up tone: A, warm tan metal at 56+ px/m (built, `RivetPlan.D5_WARM` 1.0, halfway to r2_c3's tan), or
   B, the d5 lane's violet-grey steel (`D5_WARM` 0.0; `cast_lineup.gd -- --warm=0` renders it). Same ticks in the
   city at 64 px/m beside r2_c3: `M/frames/rivet-warm-ab-vs-r2c3-64ppm.png`; on the pale slab
   `M/frames/rivet-warm-lineup-ab-64ppm.png`. A full r2_c3 tan (`D5_WARM` above 1 is not meaningful; edit WARM_* in
   `look_d5_part.gdshader`) would darken him further on asphalt. 32 px/m is unchanged either way.

## Next steps
See the last `NEXT` entry in `JOURNAL.md`.
