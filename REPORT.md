# REPORT - lane keys (n27, 2026-11-24)

Branch `n27-keys`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls`, cut from `main` `a3b3f1466`. Code head `7159beb90` (later commits touch only `JOURNAL.md` and `REPORT.md`).
Gate: TODO_GATE
Films and stills: `C:\Users\kazda\kiro\gtai-masters\n27\keys\` (`frames.json`, best first). Evidence notes: `evidence/n27-keys/`.
Director: Opus; builder: Claude Sonnet 5.5 (high), 9 calls, ledger at the end. IMAGES 8/15.

## What works

### 1. Ghost order on the number keys: 1 Dent, 2 Tonnage, 3 Kerf, 4 Ohm (owner's pick)
- `e1c4b73d9` (`MILESTONE keys-order` at 03:14): `ghost_forms.json` top-level `deploy_slots: ["dent","tonnage","kerf","ohm"]`,
  schema-checked (4 unique known ids; a bad list is a load error). `GhostNumberKeys` reads it; the HUD strip, the chip numbers,
  the deploy bot and the keys film follow it. Action bits `ghost_deploy_1..4` (20-23) unchanged. The pad / G cycle `order` is a
  separate list and is unchanged (owner: "Pad: keep as it is"). Key 1 beside a car still enters the car (filmed).
- Tests: `test_each_number_deploys_the_named_ghost_through_the_real_press_path`, `test_bad_deploy_slots_are_load_errors`;
  unit run 4086 passed / 0 failed. Mutate `ghost_number_keys.gd` 5 killed / 6 (83.3 %); the survivor is the car-door look-ahead
  radius (`:48`), which existed before tonight and is not slot logic.
- Tape identity: 68 of 68 scenarios ok, including `replay_60s`, `city_replay`, `moves_replay`, `quest1_input` and the four
  quest 1 ghost scenarios; the quest 1 replays press no bits 20-23 (decoded). Table: `evidence/n27-keys/order.md`.
  Gauntlet seed 7 pilot (`f6f9ee387`, `evidence/n27-keys/pilot_identity.md`): the result JSON is byte-identical under the new and
  the old slot order (data toggle, restored), greedy pick (9 waves, 10 deploys) and random pick (10 waves, 12 deploys, Tonnage and
  Ohm, the two forms that swap keys). Last night's "11 deploys, 9 waves" used flags nobody recorded, so it is not compared.
- Film: `ghost_order_keys_32.mp4` (39.73 s, 1920x1080, 60/1) with the key-cap overlay: 1/2/3/4 deploy Dent / Tonnage / Kerf / Ohm
  at ticks 394 / 874 / 1354 / 1954, then 1 beside the sedan enters it at 2117 and leaves at 2357. I looked at frames at
  6.6 / 14.6 / 22.6 / 32.6 / 37.5 s: the strip reads 1 2 3 4 = Dent Tonnage Kerf Ohm in every frame. Still `ghost_order_before_after.png`.

### 2. Larger numbers on the ghost chips
- `403a31a8f`: a small ink plate with a paper digit at each chip's lower-left rim (`ghost_chip_number.gd`, font 30 on desktop, 24 on
  handheld). The digit is **22 px tall at 1080p, up from 14-15 px**, and the old number sat half under the ghost's face.
  Test `test_chip_number_is_much_larger_than_the_old_label_and_fits_the_chip_cell`; `3f2bb5c2e` fixes a hint test that only
  passed by accident under the old order.
- Stills: `chip_numbers_before_after_1080.png` (strip crop at 2x), `chip_numbers_after_1080.png` (full frame).

### 3. The six 70 degree weapons: the electro gun on its own drawn grids
- `9b11bc8b6`: the electro gun walks (4 columns) and runs (8 columns) on its own drawn p70 grids, picked up from the n26 round.
  16 rows, two hands on the gun in every row, a rigid collar throughout; run factor k per profile row from measured soles
  (0.86-0.93 on the profile rows). Table: `evidence/n27-keys/grid_electro_gun.md`.
- Stills / clip: `grid_electro_gun_64.png`, `grid_electro_gun_32.png` (stop-gap | own grid), `grid_electro_gun_32.mp4`.
- `six_weapons_walk_run_32.mp4` (36.0 s, 1920x1080, 60/1): each of the six walks 6.75 and sprints 9.3 m/s in four directions,
  captioned `own grid` / `stop-gap` (`evidence/n27-keys/six_weapons.md`). I looked at one sprint frame of each: every weapon is in
  the hand; the electro gun's two-handed grid reads as carried, while the five stop-gaps show a gun stuck on a bare-stride palm.

### 4. Gloria redrawn as a compact one-hand nail gun (owner's pick)
- Concept: two takes as image edits of the shipped pistol row (`gloria_concepts_ab.png`: pistol, old Gloria, take A, take B).
  **Take A won** (straight nail strip, cream riveted plate, short ribbed nose, a comb of nails under the barrel). B's coil drum
  blurred at 32 px/m.
- p70, `17d909ebd`: held strips (main, diag, left) are image edits of the pistol strips, so her body is the pistol's
  (head/torso IoU 0.94-0.99 in all 15 cells); the flash is the pistol's own drawn flash moved to her muzzle; muzzle, diag and
  feet data re-measured; the two-handed `left_fire` strip is gone; pickup / held / icon cut from the concept.
- p70 walk and run, `de294053e`: the bare stride with the compact gun in the palm (see Calls). One value brings the old grids back.
- p55, `2a9630ecb`: the same redraw at the 55 degree camera (IoU 0.91-0.98, the p55 pistol's flash, `weapon_held_pitch.json`
  gloria p55 re-measured). Standing height mean of 8 octants: old 153.5 px, new 153.9, pistol 153.4.
- Mutate `rivet_frames_grids.gd` 5 / 5 after a cold-start test was added (4 / 5 before it).
- Stills / clips: `gloria_before_after_64.png` (old | new | pistol, p70; the old column rendered from the old art, long gun in all
  6 panels), `gloria_fire_tick_64.png`, `gloria_walk_fallback_64.png`, `gloria_p55_before_after_64.png`, `gloria_p55_walk_64.png`,
  `gloria_p55_walk_run_32.mp4` (16.02 s, 1920x1080, 60/1).
  p70 clip `gloria_walk_run_32.mp4` (20.0 s, 1920x1080, 60/1): walking, sprinting and firing; I looked at 4 frames, the compact gun is in
  hand in each.

### 5. The 55 degree camera: Gloria first
- Gloria's held strips are done at p55 (item 4); she walks there on the stop-gap, like every weapon without a p55 grid (p55 has
  drawn walk/run grids for five: flamethrower, gatling, katana, pistol, plasma rifle, all from n26). No second weapon was started
  at p55: a grid is 16 images. The ranked list of which p55 strips a grid transplant could start from is in
  `evidence/n27-keys/gloria_p55.md` (hand cannon first, gatling last).

### 6. The p55 bare sprint drift
- `c7cb687bf`: `rivet_motion.json` `grid_stride.run_row_k` `p55/sprint/2` and `/6` = 0.98, faded in by speed in
  `RivetGridStride.sprint_k()` (factor 1 at the 6.75 m/s walk, full at the 9.3 m/s sprint), bare run only. The p55 sprint profile
  drift at 32 px/m goes **8.53 -> 2.66 cm** (limit 7); 64 px/m 8.14 -> 3.83 cm. The p55 walk and both p70 rows measure the same as before, at both zooms (table
  `evidence/n27-keys/p55_sprint_drift.md`); the shortest drawing hold is 3 ticks (bar 2). Scenarios 68 passed; unit 4094 / 0.
  A flat factor at both speeds was rejected because it made the walk worse (2.29 -> 2.76 cm at best).
- `p55_sprint_before_after_32.mp4` (12.43 s, 1920x1080, 60/1), `p55_sprint_before_after_64.png` (looked at: same pose, the boot
  holds its place).

## What does not
- **Five p70 weapons are still on the stop-gap legs** (homing shard, mini-nuke, molotov, plasma sword, ray gun): the bare stride
  with the held part on the palm. A drawn grid is 16 generated rows (8 walk + 8 run), one image each, so five would take 80 images
  against tonight's cap of 15 per lane. The electro gun shipped because its 16 rows came from n26.
- The stop-gap carries the gun on the back-swinging hand in some frames (seen at p55 walk octant 0: the gun behind the helmet,
  pointing back). It affects every weapon on the stop-gap, not only Gloria.
- Gloria's weapon icon / pickup are soft: cut from a 139 px gun in the concept, with a flat left edge and no visible grip.
- The first chip's number plate pokes about 4 px past the strip's dark panel on the left.
- The long-gun Gloria grids could not be re-gunned: matching the new gun onto the old grid rows scored 0.27-0.54 (the grid poses
  differ from the held cells), so the transplant was dropped after two tries (about 35 min).
- The p55 sprint fix is a narrow optimum, not a robust one: the drift on a 4-stance take is quantised by the 15.5 cm a sprint tick
  covers, so 0.97 gives 6.56 cm and 0.99 gives 5.03 (the factor scan in `p55_sprint_drift.md`). It holds at 0.98 at both zooms; a
  change to the run8 sheet or to the sprint speed needs a re-scan.
- Chip numbers mutation: `ghost_chip_number.gd` 33 % (4 of 12) at first, then 12 of 12 on the plate size and centre lines once
  `c966e5f8f` pinned them. Still alive: the draw body (border width, the digit's x origin) and `ghost_form_hud.gd:90`, the plate's
  offset from the chip (1 of 4 killed). Killing those needs a draw-capture test or the offset moved into a function.
- The stop-gap legs' foot slide was not measured for the five stop-gap weapons (the film shows them, no number).

## What blocked or slowed you
- Gloria part B transplant, two tries: about 35 min of builder time, abandoned for the fallback.
- A bounced before/after (the old column was first rendered from the changed tree): about 15 min to re-render from the old art.
- Builder account warning at 05:38 (seven-day use 0.87): nothing stopped, but every later brief asked for earlier commits.
- Resuming one long builder session three times made each call dearer ($4.27 -> $6.63 -> $9.27): the whole context is re-read.
  The p55 drift call ran as a fresh session on purpose.
- Final gate: I killed my first gate run to relaunch it detached, then relaunched while the snapshot removal was still running (my
  error); the removal ate the new checkout. About 10 minutes lost; the gate started at 08:01.
- `tools/godot/check.mjs` fails on the untouched `cut_rig.gd` in this worktree; `run_unit.mjs --changed` served as the compile check (about 5 min).
- The dev `arsenal_turn` recorder does not equip a weapon in this worktree, so every weapon still came from a copy of the n24
  `grid_arena_film` scene kept outside the repo (about 10 min).

## Calls for the owner
1. **Gloria's walk and run at p70: the bare stride with the compact gun in the palm (shipped) or a newly drawn grid later.** The old
   long-gun grids would show the old gun while walking. `rivet_motion.json` `walk_grid.by_weapon.gloria = "bare_claw_p70"`; set it
   to `"gloria"` to bring the old grids back. See `gloria_walk_fallback_64.png` beside `gloria_before_after_64.png`.
2. **Concept A or B** (`gloria_concepts_ab.png`). A ships.
3. **At 64 px/m the compact Gloria reads close to the pistol**: the cream plate and the nail comb are what set her apart
   (`gloria_p55_before_after_64.png`, right two columns). If she should read further apart, a redraw with a larger nail strip or a
   brass body (amber is allowed for heat only, so brass, not amber).
4. **Chip number plate at the chip's lower-left rim** (`chip_numbers_before_after_1080.png`), or under the chip.

## Merge notes
- `ghost_forms.json`: melee already merged `e1c4b73d9` into `n27-melee` (`4a3ff4b04`, conflict in `doc` only, solved by hand). At the
  Director's merge, keep melee's bond values and doc text plus the `deploy_slots` key.
- `docs/decisions.md`: four keys lines appended (`d8b3654a2`) plus the sprint factor line; append-only, keep both sides.
- `tools/debt/baseline.json` and `launch_args.gd` `KNOWN_FLAGS`: untouched by this lane. `steam/ai-provenance/2026-11.jsonl`:
  21 lines appended (append-only, keep both sides).
- `rivet_strips.gd` `ONE_HAND` gains `&"gloria"` (one line outside the brief's list; needed so she turns left on her own drawn strip).
- Root `JOURNAL.md` / `REPORT.md`: add/add with other lanes, keep each lane's own (file under `docs/day/2026-11-24/n27-keys/`).

## Next steps
1. The five stop-gap weapons: one drawn 16-row round each (80 images). Cheaper route to test first: an image edit of the plasma
   rifle's walk/run sheets with the weapon swapped (as Gloria's strips were made from the pistol's), so the legs and stride data
   are the donor's by construction.
2. Gloria's own p70 grid by the same route from the pistol's walk/run (the pistol has its own grids), then flip the one value.
3. The stop-gap back-swing: keep the held part on the front hand when the back arm swings behind the helmet.
4. Redraw Gloria's icon and pickup at full size.
5. Check the bare p55 run8 sheet's collar: in `p55_sprint_before_after_64.png` the orange and black band reads as a twisted rope
   in the profile sprint (shipped n26 art, untouched tonight). The rule says a rigid hazard collar; redraw those rows if the owner agrees.
6. Move the chip plate offset (`ghost_form_hud.gd:90`) into a `GhostFormLayout` function with a test, and fix the 4 px overhang of the first plate in the same change.

## Builder ledger
| # | tag | session | minutes | cost | verdict |
|---:|---|---|---:|---:|---|
| 1 | order | new | 65 | $2.22 | accepted (`e1c4b73d9`, `3f2bb5c2e`, `403a31a8f`, `877bb2ac1`) |
| 2 | order-film | resume | 7 | $2.78 | accepted (`4cc476ca8`) |
| 3 | electro | new | 33 | $1.63 | accepted (`9b11bc8b6`) |
| 4 | gloria-p70 | new | 54 | $4.27 | part A accepted (`17d909ebd`, `d4fb0ccb3`); part B (transplant) not shipped; the before/after bounced |
| 5 | gloria-fix | resume | 25 | $6.63 | accepted (`de294053e`: fallback walk, true before render) |
| 6 | gloria-p55 | resume | 31 | $9.27 | accepted (`2a9630ecb`, `e338dfc40`, `d8b3654a2`) |
| 7 | p55-drift | new | 60 | $1.96 | accepted (`c7cb687bf`, `b4b158a5a`, `44142eae5`, `05e73eb64`, `5d05dccc5`); part 3 (chip mutate) not done |
| 8 | pilot-identity | new | 3 | $0.45 | accepted (`f6f9ee387`) |
| 9 | chip-mutate | new | 22 | $0.35 | accepted (`c966e5f8f`, `7159beb90`) |

Total: 9 calls, 300 minutes, $29.56. All accepted, apart from call 4's part B (not shipped) and its first before/after (bounced).

What I would brief differently:
- Never resume a long session for a new item: calls 5 and 6 cost $6.63 and $9.27 for 25 and 31 minutes, because the whole
  context is re-read each turn; a fresh session with a tight brief did 60 minutes for $1.96.
- Give the art calls a written fallback from the start (the bare stride + the new held art), with a time cap on the clever route.
  The transplant cost about 35 minutes before the fallback was ordered.
- Put the capture kit in the repo (a dev scene that equips a weapon and walks a beat list). Every call copied the n24
  `grid_arena_film` into `project/dev/motion` and deleted it again, and the brief had to say where it lived.
- Ask for the before render from a temp worktree from the first call (call 6 did it right; call 4 rendered the "before" from the changed tree).

