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
- Hazard collar at 32 px/m (4f9a2ead, iteration 14): the collar's gameplay sticker was one flat vermilion ring
  (it read like a UI reticle); it now prints vermilion with 6 ink breaks round the ring, as r2_c6/r2_c7 draw the
  collar at game scale (an orange band with a few dark gaps). 48 px/m and up already print the art's 14 stripes.
  Director reel and city at 32 px/m, same ticks, before | after: `M/cast-collar-director-ab-32.mp4`,
  `M/cast-collar-city-ab-32.mp4`; still with the targets `M/frames/collar-hazard-ab-vs-r2c7-32ppm.png`; trials
  (6/8/14 breaks, the art's own stripes) `M/frames/collar-ticks-lineup-32ppm.png`, `M/frames/collar-trials-city-32ppm.png`.
- Welder visor at 32 px/m (26c1e08a, iteration 15): the helmet sticker prints an ink visor slot over the head's front,
  so Rivet's head carries r2_c7's dark slot and shows where he faces at game zoom (the 2 px art visor merged into the
  outline). 64 px/m is pixel-identical. `M/frames/rivet-visor-slot-ab-32ppm.png`, `M/cast-visor-director-ab-32.mp4`; quest 1
  Dock 9, same ticks: `M/frames/visor-slot-quest1-ab-32ppm.png`. Director reel 16/16 down, 0 script errors. Call 8.
- Tan work plates at 32 px/m (3ceb3e30, iteration 16-17; full tan 550b000d, iteration 18): Rivet's torso, pelvis and
  helmet stickers print r2_c3's tan (`PartMaterials.CORE_TAN` 1.0; 0.6 until iteration 18) instead of cream, toward the tan-grey Rivet of r2_c3/r2_c6/r2_c7. On the cream slab the
  cream core had vanished; on asphalt the change is quiet (warm beige for white). Rivet only (`BodyPlan.core_tan`); King
  keeps cream; 48 px/m and up pixel-identical. `M/frames/rivet-core-tan-ab-vs-targets-32ppm.png`,
  `M/frames/rivet-core-tan-director-crops-32ppm.png`, `M/cast-tan-director-ab-32.mp4`, `M/cast-tan-city-ab-32.mp4`.
  Quest 1 Dock 9, same ticks, lossless: `M/frames/rivet-core-tan-quest1-ab-32ppm.png`. Director reel 16/16 down, 0
  script errors. Iteration 18 moved 0.6 to 1.0 (Call 9 C, the measured closest colour): live city A | C, same ticks,
  `M/cast-tan-city-ac-32.mp4`, crops beside r2_c3 `M/frames/rivet-core-tan-city-ac-vs-r2c3-32ppm.png`; director reel
  16/16 down, 0 script errors. Call 9.
- Torch tip cream (iteration 14): Rivet's torch tip printed teal (teal is for souls only; r2_c3's tip is pale); now a
  cream ramp at its own value, D4 and D5: `M/frames/rivet-torch-cream-ab.png` (32/64 px/m, slab and road),
  `M/frames/rivet-torch-cream-director-32ppm.png`.
- The Hauler keeps its own body plan and size and plays on the hybrid base (transform, drive-through, stomp; 0
  script errors): `M/frames/hauler-on-hybrid-32ppm.png`. It carries the tan core too (Rivet's own rig, scaled):
  `M/frames/hauler-tan-core-32ppm.png`.

### 4. The proof (brief item 5)
- Director reel, 32 px/m, main | n5-cast side by side: `M/cast-director-ab-32.mp4`, still
  `M/frames/director-final-ab-32ppm.png` (claw combo, pistol, machine pistol identical tick for tick).
- City block 15 s: `M/cast-city-ab-32.mp4`. 64 px/m close-up: `M/cast-hybrid-director-64.mp4`; with the navy cops
  `M/cast-navy-director-64.mp4` (still `M/frames/director-navy-64ppm.png`).
- Target composite: `M/frames/cast-ingame-vs-r2c6.png` (re-shot on 550b000d with the full tan core, Call 9 C, from
  `M/cast-tan-city-ac-32.mp4`, tick 720, with a Rivet x4 inset).
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
- Built (iteration 11, 64efadb6): plan-view peds toward r2_a5. From straight above our ped art had 3/4-view
  proportions: heads about 0.75 of the shoulder span placed over the coat's front, standing knees bent forward and
  large shoes pushed ahead, and grey coat fills just under print_part's 32 px/m ink cut (lum ~0.58), so every ped
  printed as a dark mass. The ped plan now takes plan-view values together: head 0.62 (`BodyPlan.head_k`), placed
  0.12 of the depth forward, shoes 0.7 (`foot_k`) under the coat, straight standing legs (hip_z 0.98), and the D4
  coat, overalls, vest and grey sleeve fills lifted +42 L. Standing coat, hood, vest and overalls peds now read
  pale-topped with a small dark head on slab and asphalt; jacket and hoodie stay dark (a mixed crowd, as r2_a5's);
  walking peds are unchanged (dark trouser legs striding like r2_a5's runners). Before/after lineups at 32 px/m
  (slab, asphalt, walking) and 64 px/m beside r2_a5: `M/frames/crowd-planview-ab-vs-r2a5.png`. Reactions, deaths
  and corpses before/after on the react board at 64 px/m: `M/frames/react-board-planview-ab-64ppm.png`,
  `M/cast-react-board-planview-ab-64ppm.mp4` (0 script errors, cops unchanged). Render only, no sim change.
  The crowd's kill scene (`react_board_run.gd -- --board=street`, 64 px/m) before/after:
  `M/frames/street-board-planview-ab-64ppm.png`, `M/cast-street-board-planview-ab-64ppm.mp4` (flee, the kill and
  the corpse read as before). Live paths: the city block at 32 px/m (`M/frames/city-peds-ab-32ppm.png`,
  `M/cast-peds-city-ab-32.mp4`, same sim) and quest 1 `--rigs` at 48 px/m under r1_c6
  (`M/frames/quest1-peds-ab-48ppm-vs-r1c6.png`); director reel 16/16 chapters down; goldens re-blessed once
  (decisions, diff mask `M/frames/golden-diff-planview-peds.png`). Quest stills with moving peds show stray shoes:
  a capture artefact of stills mode, absent in a per-tick clip (`M/frames/quest1-ped-stills-artefact-48ppm.png`).
  The iteration 10 diagnosis and trials that led here: `M/frames/crowd-value-vs-r2a5.png`,
  `M/frames/crowd-part-markers-32ppm.png` (and `-b`, `-c`), `M/frames/crowd-package-trial-32ppm.png`.

- Built (iteration 12, f4910eca): a plan-view ped part sheet (Codex `ped_plan_a`, r2_a5 + r1_c6 refs): the coat and the
  jacket are drawn as shoulder ovals with a collar ring (no lapels or shirt front, nothing that faces a camera that is
  not there), a pale felt hat seen as two circles, a dark hair crown, a pale hood. Installed in D4 at the shipped
  torso width (the 0.83 m footprint kept); the five parts' D5 overlays dropped, so the close-up shows the new art too.
  The coat+hat ped is now a pale figure with a pale hat ring at 32 and 64 px/m; the jacket reads mid grey at 64 px/m.
  Lineups `M/frames/crowd-r5-ab-vs-r2a5.png`; react board `M/frames/react-board-r5peds-ab-64ppm.png`
  (`M/cast-react-board-r5peds-ab-64ppm.mp4`); street board `M/frames/street-board-r5peds-ab-64ppm.png`
  (`M/cast-street-board-r5peds-ab-64ppm.mp4`). An earlier front-facing redraw (r4) re-tried on the plan-view values
  read darker at 32 px/m and was not built (`M/frames/crowd-r4-sheet-retrial-ab.png`).
  Live city block at 32 px/m, same sim (`M/cast-r5peds-city-ab-32.mp4`, `M/frames/city-r5peds-ab-32ppm.png`); the
  director reel 16/16 chapters down, 0 script errors; look goldens within tolerance (no re-bless).
  Then (cc744d85, 0bcd2ce9) a second sheet r6 for the vest and overalls torsos and the beanie and cap heads (the
  vest ped now reads pale with a dark hair crown), every ped head kept at one scale; its charcoal hoodie was not built
  (it printed as a dark slab and lost the head mark). Three-way board: `M/frames/crowd-r6-ab-32-64ppm.png`; the react
  board clip and still above show the final parts.
  Then (1d9c3c53) a mid-grey hoodie with a cream hood ring (r7): the hoodie ped reads as pale shoulders with a dark
  head instead of a dark slab (`M/frames/crowd-r7-hoodie-ab.png`). Every ped torso is now plan-view art.
  Then (15feca4a, iteration 13) the hoodie wears the grey sleeves: its arms were near-ink, so the walking hoodie ped
  printed as one black mass in quest 1 at 48 px/m; now pale arms round a dark cap (`M/frames/quest1-hoodie-sleeve-ab-48ppm.png`,
  `M/cast-quest1-hoodie-sleeve-ab-48.mp4`, lineups `M/frames/crowd-hoodie-sleeve-ab.png`). The jacket stays the one dark look.
  Then (093f4b73) D5 close-up hatching for the ten plan-view parts: a Codex restyle of the installed D4 parts, cut back
  with the D4 alpha, value and chroma (a first cut kept Codex's warm fills and the hair printed vermilion; fixed, 0
  vermilion px). At 64 px/m the torsos and heads carry the limbs' lower-left hatching and grain instead of flat fill;
  32 px/m is unchanged (`M/frames/crowd-d5-hatch-ab-64ppm.png`). React and street boards before/after, every reaction,
  death and corpse identical in place: `M/frames/react-street-d5peds-ab-64ppm.png`,
  `M/cast-react-board-d5peds-ab-64ppm.mp4`, `M/cast-street-board-d5peds-ab-64ppm.mp4`.
  The bald head too (f5733b83, `M/frames/crowd-bald-d5-ab-64ppm.png`): every ped head and torso now has its D5 overlay.
  The hoodie's flat cap at the beanie head size (621c0d3f): more pale hoodie shows round a smaller dark head at 32 px/m
  (`M/frames/crowd-cap-size-ab.png`).
  Live city block on the final parts, same sim as e1f848a5: `M/frames/city-r7peds-ab-32ppm.png` (`M/cast-r7-city-32.mp4`);
  the target composite `M/frames/cast-ingame-vs-r2c6.png` is re-shot on them.

### Gates (iteration 18 final, `tools/evidence/run.mjs --no-bench` on 551ed9c6 (the dark hood): ALL PASS: lint 13/13,
unit 954/0, scenarios 46, parity exact (mutation at 629), look goldens 11/11 (worst 1.21), no re-bless.

### Gates (iteration 18, `tools/evidence/run.mjs --no-bench` on 0f6ce11a (the dark hat crown): lint 13/13,
scenarios 46, parity exact (mutation at 629), look goldens 11/11 (worst 1.13), no re-bless; unit 953/1 where the 1 is
the known flake `test_noir_shadows` ("Parameter t is null"), re-run twice standalone: 954/0 both times.

### Gates (iteration 18, final `tools/evidence/run.mjs --no-bench` on 550b000d (Call 9 C, CORE_TAN 1.0): ALL PASS:
lint 13/13, unit 954/0, scenarios 46, parity exact (mutation caught at 629), look goldens 11/11 (worst 1.22), no
re-bless. Bench skipped (shared machine, other lanes' Godot running). Director reel headless 16/16 down, 0 script errors.

### Gates (iteration 17, final `tools/evidence/run.mjs --no-bench` on 1474c61c (head; same code as 08b1f7bc, the tan core 3ceb3e30): ALL PASS:
lint 13/13, unit 954/0, scenarios 46, parity exact (mutation caught at 629), look goldens 11/11 (worst 1.22); no re-bless.
Director reel headless `--loadout=pistol` 16/16 chapters down, 0 script errors. Bench not run (other lanes' Godot
running: frame cost CONTENDED/unmeasured).
### Gates (iteration 15, final `tools/evidence/run.mjs --no-bench` on c3a9ebf2 (the visor slot scoped to Rivet, 18b74bd8):
ALL PASS: lint 13/13, unit 949/0, scenarios 46, parity exact, look goldens 11/11 (worst 1.22), block 5/5 (worst 1.38).
Before it, on e7c055be (the visor slot): ALL PASS: lint 13/13, unit 948/0,
scenarios 46, parity exact (mutation caught at 629), look goldens 11/11 (worst 1.22), block 5/5 (worst 1.38), world lock
holds; no re-bless. Director reel with `--loadout=pistol` 16/16 chapters down, 0 script errors.)
### Gates (iteration 14, final on f7cc15b5 (torch tip): ALL PASS: lint 13/13, unit 945/0, scenarios 46, parity exact,
look goldens 11/11 (worst 1.22), block 5/5 (worst 1.38), no re-bless. Before it, on 4f9a2ead (the hazard collar): lint 13/13,
unit 945/0, scenarios 46, parity exact (mutation caught at 629), look goldens 11/11 (worst 1.21), block 5/5 (worst
1.38), world lock holds; no re-bless. Director reel 16/16 down, 0 script errors.)
### Gates (iteration 13, final `tools/evidence/run.mjs --no-bench` on 621c0d3f (hoodie sleeves, r8/r8b D5 ped parts, cap size): all
PASS: lint 13/13, unit 942/0, scenarios 46, parity exact, look goldens 11/11 (worst 1.21), block goldens 5/5 within mean 4 (worst 1.38). Earlier on d6d89921: lint 13/13, unit
942/0, scenarios 46, parity exact (mutation caught at 629), look goldens 11/11 (worst 1.20) and block 5/5 (worst 1.36),
world lock holds, no re-bless. An earlier run on 5faaf0aa lost the look goldens to a transient exit after the first frame
(11/11 when re-run alone). Director reel with `--loadout=pistol`: 16/16 chapters down, 0 script errors.)
### Gates (iteration 12, final on 5cf7cafe (r7 hoodie): lint 13/13, unit 942/0, parity exact, look goldens 11/11
(worst 1.00) and block 5/5 (worst 1.08), no re-bless; scenarios 45/46 in the gate (`scenario_corpse_horde`, its
wall-clock early-vs-late step-cost check, CONTENDED: another lane's Godot was running), then 46/0 re-run alone.
Earlier `tools/evidence/run.mjs --no-bench` on eec9e750 (r5 + r6): lint 13/13, unit 942/0,
scenarios, parity exact, look goldens 11/11 (worst 0.92) and block 5/5 (worst 0.96) with no re-bless; on b722cb84 (r5
only) the same with worst 0.83 / 0.86. Director reel 16/16 chapters down on both.)
### Gates (iteration 11, `tools/evidence/run.mjs --no-bench` on 1d4abaa6: lint 13/13, unit 941/1 where the 1 is the
known flake `test_noir_shadows` (2/2 alone, twice), scenarios 46, parity exact (mutation caught at 629), selftest
look goldens 11/11 and block 5/5 (worst mean 0.00, after the one re-bless for the plan-view peds), world lock holds.)
### Gates (iteration 9, `tools/evidence/run.mjs --no-bench` on 2f833a0b: lint 13/13, unit 940/1 where the 1 is the
known flake `test_noir_shadows` (2/2 alone, twice; the standalone suite on the same tree was 941/0), scenarios 46,
parity exact (mutation caught at 629), selftest look goldens 11/11 (worst 1.06), block 5/5, no re-bless.)
### Gates (iteration 7, `tools/evidence/run.mjs --no-bench` on cc4cb843: lint 13/13, unit 940/0, scenarios 46/0,
parity exact, selftest with look goldens 11/11 (worst 1.07) and block 5/5, no re-bless; iteration 6 on 850c543a:)
lint 13/13, unit 940/0, scenarios 46/0, parity exact (planted mutation caught at 629), look goldens junction 11/11
and block 5/5 (blocks re-blessed once at 618d6eb8 after a bisect against main; decisions line). Bench not run.
- Built (iteration 18, 0f6ce11a): the coat-hat ped's hat crown prints dark (D4 and D5 `head_hat.png` crown x0.40,
  brim and ink ring kept). In the live city that ped had been a faint cream outline on the cream slab; it now carries
  a 3-4 px ink head mark at 32 px/m, the dark-head read of r1_c6, and a mid-grey hatched crown at 64 px/m:
  `M/frames/ped-hat-crown-ab-32ppm.png` (lineup slab/asphalt/64 px/m + live city, before | after),
  `M/cast-hat-city-ab-32.mp4`.
- Built (iteration 18, 551ed9c6): the coat-hood ped's hood prints dark too (D4 and D5 `head_hood.png`, mean L 140 -> 75),
  so every ped look now carries a dark (or, bald, grey) head from above, as in r1_c6. Lossless lineup before | after
  beside r1_c6: `M/frames/ped-hood-dark-ab-vs-r1c6.png` (no coat-hood ped was on screen in the city clip).

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
- The crowd: standing peds read pale since iteration 11 (section 5); jacket and hoodie looks stay dark, and the ped
  every ped torso and the hat, hair, hood, beanie and cap heads are plan-view redraws since iteration 12; the
  bald head and the shoes were judged plan-view already (a skull disc with ears and a nose nub; a capsule shoe); every ped head and torso has D5 hatching since 093f4b73 / f5733b83.
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

6. The crowd's value at game zoom: A, pale-topped standing peds (built in iteration 11, plan-view values and a
   +42 L fill lift; four looks pale, jacket and hoodie dark), or B, the earlier dark crowd (the five
   `HumanPlan.PED_*` constants back, see the decisions line, and the ped art from 9f2aac24; `git revert 1d9c3c53 0bcd2ce9 cc744d85 f4910eca` first for the plan-view parts). Before/after beside
   r2_a5: `M/frames/crowd-planview-ab-vs-r2a5.png`. With B, the navy cops and the peds share one dark value at
   32 px/m and only the cops' blue pads tell them apart.
   The cost of A, seen in the live city (iteration 18): on the cream slab a standing pale-topped ped is a faint
   cream shape held only by its ink outline, where r2_a5/r2_c6 keep the peds' dark trousers and hair visible
   (`M/frames/ped-pale-on-slab-city-32ppm.png`). On asphalt A reads well. There is no middle value at
   32 px/m: the print is two-tone there (a fill below lum ~0.58 prints ink, `ped_pale.py`'s note), so the choice is
   pale or a dark blob. Walking peds already show dark legs (the walking row of `M/frames/crowd-planview-ab-vs-r2a5.png`);
   a standing ped is all coat from above. Built in iteration 18: the coat-hat look, the faintest, now prints a dark
   hat crown (0f6ce11a, `M/frames/ped-hat-crown-ab-32ppm.png`), and coat-hood a dark hood (551ed9c6,
   `M/frames/ped-hood-dark-ab-vs-r1c6.png`): the pale coats stay, every head reads dark. Revert = the four PNGs from 550b000d.

7. Rivet's collar at 32 px/m: A, vermilion with 6 ink hazard breaks (built, `PartMaterials.COLLAR_LOD_FILL` 3,
   `print_part.gdshader` `collar_stripes` 6 / `collar_ink` 0.3), or B, the flat vermilion ring (`COLLAR_LOD_FILL`
   1), the stronger single mark at a glance but read as a target reticle. Same ticks, before | after:
   `M/frames/collar-hazard-ab-vs-r2c7-32ppm.png`, `M/cast-collar-director-ab-32.mp4`.
   In quest 1 the objective marker is itself a flat vermilion ring, so B is the same mark as an objective:
   `M/frames/collar-vs-objective-quest1-32ppm.png` (Dock 9, ticks 13600-13720).
   Tried and not built: a thinner band (the ring's inner part dropped or inked): the vermilion thins to 1-2 px and
   specks at 1x, and the drop shows the torso's outline, not the body (`M/frames/collar-thin-trial-32ppm.png`).

8. Rivet's welder visor at 32 px/m: B built (26c1e08a, iteration 15): below the sticker threshold the helmet prints
   an ink visor slot over its front (`PartMaterials.HEAD_LOD_FILL` 4, print_part `visor_x0` 0.66 / `visor_hy` 0.25),
   r2_c7's dark slot and a facing mark at game zoom. A, the plain cream head whose 2 px art visor merges into the
   outline (`HEAD_LOD_FILL` 2.0; the visor then reads from 48 px/m up, `M/frames/rivet-visor-ab-64ppm.png`); C, a
   larger head, tied to Call 1's size. Same ticks, before | after, lineup and live reel beside r2_c7:
   `M/frames/rivet-visor-slot-ab-32ppm.png`, `M/cast-visor-director-ab-32.mp4`; the iteration 14 print-only trial
   that changed nothing: `M/frames/visor-sticker-trial-32ppm.png`.
   Rivet only (`BodyPlan.head_visor`): King's symmetric star crown, built on Rivet's plan, keeps the plain head.
   Tried and not built: two 1 px cream eye glints in the slot (r2_c3's slits): eyes at x7, speckle at 1x
   (`M/frames/visor-glint-trial-32ppm.png`).

9. Rivet's body tone at 32 px/m. **C is built since iteration 18 (550b000d, `CORE_TAN` 1.0)**; A was built before it.
   A, tan work plates (3ceb3e30, iteration 16-17): below the sticker threshold
   his torso, pelvis and helmet print `mix(CREAM, TAN, PartMaterials.CORE_TAN)` with CORE_TAN 0.6 (`PartKind.TAN_CORE`,
   Rivet only via `BodyPlan.core_tan`; King keeps cream), toward the tan-grey Rivet of r2_c3/r2_c6/r2_c7; or B, the
   cream core (`CORE_TAN` 0.0), which vanishes on the cream slab and reads as a white dot on asphalt; or C, the full
   tan (`CORE_TAN` 1.0), the closest colour to r2_c3/r2_c7 (the iteration 16 note that it goes muddy on asphalt came
   from compressed mp4 crops; lossless quest 1 frames do not show it, C reads cleanly: a real contender). The limbs stay cream rods
   (the lanky read); 48 px/m and up is pixel-identical (the art tier, Call 5 governs it). Same ticks, B | A | C
   beside the targets: `M/frames/rivet-core-tan-ab-vs-targets-32ppm.png`; lineup slab and road at 0 / 0.5 / 1.0:
   `M/frames/rivet-core-tan-lineup-32ppm.png`; live A/B: `M/cast-tan-director-ab-32.mp4`, `M/cast-tan-city-ab-32.mp4`.
   Quest 1 Dock 9: `M/frames/rivet-core-tan-quest1-ab-32ppm.png`; B | A | C lossless beside r2_c3:
   `M/frames/rivet-core-tan-call9-3way-32ppm.png` (C is one constant: `PartMaterials.CORE_TAN` 1.0).
   On the director reel's grey concrete A and C differ only slightly (C a touch warmer):
   `M/frames/rivet-core-tan-director-a-vs-c-32ppm.png`.
   Measured: r2_c3's lit shoulder plates sample about RGB (189,156,128), saturation 0.32; A prints (219,200,172), 0.21;
   C prints (204,178,144), 0.29. C is the closer colour; A is lighter so the body holds on the dark asphalt (the
   target's own ground is a mid value, about (133,117,103), which our asphalt and slab are not).
   Why C now: no owner pick by iteration 18, and C is the closer colour. In motion in the live city, A and C differ only
   slightly (C warmer) and neither muddies: `M/cast-tan-city-ac-32.mp4` (A | C, same ticks),
   `M/frames/rivet-core-tan-city-ac-vs-r2c3-32ppm.png`; lossless (Godot PNG-sequence capture) on the director reel's
   claw combo: `M/frames/rivet-core-tan-director-ac-lossless-32ppm.png`, clip x4 `M/cast-tan-director-ac-lossless-x4-32.mkv`.
   Back to A = `CORE_TAN` 0.6, to B = 0.0.

## Next steps
See the last `NEXT` entry in `JOURNAL.md`.

Merge note for the Director (trial `git merge-tree` of n5-cast 02a1d172+ with n5-look cb34af73, 2026-11-05 04:50):
every code, data and art path merges clean. The conflicts are the lane docs (`JOURNAL.md`, `REPORT.md`, add/add) and
16 look goldens under `project/tests/golden/look/`, which both lanes re-blessed for their own changes (cast:
92e8c3fb, 618d6eb8, 91aac1aa; look: its own re-bless lines in `docs/decisions.md`). Take either side's PNGs, then run
`tools/evidence/run.mjs --no-bench` on the merged tree and re-bless once, with one dated decisions line naming both
lanes' changes (cast: slim cops, hybrid Rivet, plan-view peds, the 32 px/m collar, visor and tan core stickers).
Against d6-combat-notes (17414367), d6-perf-city (e723c25e), n6-ghost-powers (708d5672) and n6-ghost-forms
(91b6b866) only the lane docs conflict. Semantic check: n6's `DentPlan` builds from `RivetPlan.build()` but sets
`collar_part = ""` and `raw_parts`, so it cannot pick up cast's collar-core stickers (visor slot, tan core: both need the
collar core); n6's `cut_rig.set_tint` edit keeps `PartMaterials.get_mat(kind, ...)`, which takes the new `TAN_CORE`.
