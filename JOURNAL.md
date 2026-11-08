# n9 rivet JOURNAL (branch n9-rivet, evidence C:\Users\kazda\kiro\gtai-masters\n9\rivet\)

## it3 (00:54-01:54) - the first iteration that ran (it1 and it2 exited in 5-7 s on billing)

Read: d9 rivet REPORT (`docs/day/2026-11-07/rivet/REPORT.md`), AGENTS.md, the tail of docs/decisions.md,
`git log` (main = d9 merged, branch clean), the asset lane's JOURNAL tail and deliveries
(`rivet_walk8_it112.md`, `rivet_walk_armed_it99.md`). No other n9 lane had a JOURNAL at 01:00.

Registry rules applied (motion-quality-gating, sprite-and-atlas-production, depth-ordered-layered-art,
realtime-combat-semantics; read from memory of the d9 runs, not re-opened this session: FRICTION, time):
- motion: foot-lock acceptance = a planted foot stays put against the ground texture over its contact
  frames; stride-to-speed: cadence x stride length = ground speed, measured, never eyeballed.
- atlas: one scale per grid (no size pulse across a stride), a common foot line, premultiplied resampling.
- layered art: the size change is view only; depth sort stays the rig's ground point.
- combat semantics: the shot origin and the hit box are the sim's; the drawn muzzle is view only and is
  stored in cell px, so it scales with the card (checked by code: RivetMuzzle maps cell px through
  card.offset and the card's transform; the smear root and length use the card's scale too).

- MILESTONE `c0b0bea0` **the new size**: `RivetFrames.HEIGHT_M` 1.1 -> 1.65, p55 1.3 -> 1.95 (in proportion).
  `--rivet-height=<m>` still the flag (clamp 0.8-2.5). Everything that reads his height reads it from
  place(): the card scale (muzzle, smear, fire latch unchanged), the cast shadow / occlusion hip
  (`RigCastShadows.CAST_HIP` = h x ...), the roll ball (ROLL_SHADOW x h). The sim body is untouched.
  Under `top` there is no strip (strip_of returns ""), so the top look goldens cannot move.
- MILESTONE `dbef2e17` **the flamer**: `RivetStrips.cone` empty (the owner's r-7 B, the drawn flame in
  every direction); `--rivet-flame=cone` brings back d9's `CONE_D9`. Film of a diagonal burst: owed.
- MILESTONE `b06c962f` **the 8-frame walk**: the library's walk8 OFFER (all rows A at both pitches; 70
  left = the tone-matched copy) packed by `tools/art/rivet_walk.py --cols=8` into
  `art/view/<p70|p55>/rivet_walk8.png` (contacts `evidence/n9/rivet_walk8_{70,55}_contact_x2.png`).
  The phase now steps by the ground walked (`RivetWalk.phase_of`, the King's-boots method), not by
  the gait phase. `--rivet-walk=4` = d9's 4-frame grid by the gait phase, `--rivet-walk=bob` the card.
  Provenance: 2 lines in `steam/ai-provenance/2026-11.jsonl` (16 source sheets, rounds + prompt_hash).

### Why he glides (measured, it3)
- His walk is **6.75 m/s** (`combat.json` rivet walk_mps; the 2026-11-04 1.5x baseline). That is a
  runner's speed. At 32 px/m = 216 screen px/s.
- The drawn walk8 profile rows: the stance foot travels ~30 cell px from contact to the next contact,
  so one drawn cycle (two steps) = ~60 cell px (`CYCLE_CELL`; p70 and p55 alike) = 0.55 x the figure's
  110 px height. At 1.65 m that is **0.9 m per cycle** (28.8 px at 32 px/m).
- To plant at 6.75 m/s that cycle needs **7.5 cycles/s = 60 drawn frames/s at 8 frames**: unreadable.
  d9's 4-frame grid ran by the gait phase (rig stride ~88 px at that speed: ~2.5 cycles/s, 10 fps), so the
  feet covered ~1/3 of the ground: the glide.
- Built: the distance-tied phase with the measured cycle, the cadence held at `MAX_CYCLES_S` 2.0
  (16 drawn fps). So he plants while he accelerates (0.28 s to top speed at 24 m/s^2), slows, and at
  any speed under ~1.8 m/s; at his full 6.75 m/s the feet still cover 27 % of the ground.
- **No drawn walk can plant at a run's speed.** The fix is a drawn RUN cycle (a stride ~3x the walk's,
  with flight frames where no foot is on the ground): REQUEST below. The alternative (a slower walk) is
  a sim change and not mine: a Call for the owner.

REQUEST to assets: rivet_run8_70, rivet_run8_55, pitch 70 and 55, Rivet's 8-frame RUN cycle (bare
claw), because his on-foot speed is 6.75 m/s (a run) and the walk8 cycle covers only 0.9 m per stride at
his new 1.65 m: the feet cannot plant (measured above). Layout = the walk8 house layout (rows toward,
3/4 toward right, right profile, 3/4 away right, away; + the 3 drawn LEFT rows, never mirrored; tight
`r_c.png` cells, copied by example from `keyed/rivet/rivet_walk8_<p>_cells`, same helmet, claw and scale).
Columns: 1 CONTACT (front heel down, legs spread ~0.6 x the standing height in the profile), 2 DOWN
(loaded, knee bent, the body lowest), 3 PUSH-OFF (the stance foot BEHIND the hip, toe on the ground,
~0.45 x height behind where it landed in col 1), 4 FLIGHT (both feet off the ground ~0.05 x height, the
free knee forward), 5-8 the same with the other foot. Body leaning forward ~10 deg in the profile rows,
arms (claw + the plated arm) swinging opposite to the legs. The key measurement: in the profile rows,
the stance foot's x must travel backwards ~0.45-0.5 x the standing height from col 1 to col 3 (and 5 to 7);
I wire the cycle length from that measure. 70 first.

Item 4 note: the armed walks (it99 OFFER, `rivet_walk_armed_{onehand,twohand,blade,heavy,flamer}`) are
drawn with ONE weapon each (the pistol, the plasma rifle, ...). Taking them for the whole family would put
a pistol in his claw while he holds the ray gun. Plan: wire them per weapon for the weapon they draw
(pistol, plasma rifle, katana, flamer), keep the facing card for the rest, and ask per weapon later.

- 01:20-01:35 evidence (0 SCRIPT ERROR in all 6 films):
  - size, city block tilt70 32 px/m seed 5 f300, 1.1 vs 1.65: only Rivet's pixels differ; at 1.65 he reads
    about a kerb pedestrian's height. `gtai-masters/n9/rivet/rivet_size_before_after_1p1_1p65_city_tilt70_32ppm_x1.5_seed5_f300.png`.
  - size, King combo 48 px/m seed 1 f200/f300, p55 1.3 vs 1.95: the flash prints at the drawn pistol at the
    new size, the shadow lengthens, the framing holds beside the barge. `..._p55_1p3_1p95_king_combo_48ppm_seed1_f200_300.png`.
  - flamer, arena gunplay tilt70 64 px/m seed 3 f349-367: a diagonal burst (aim ~120 deg) draws the drawn
    yellow flame screen-left AND the game's red jet along the aim: **two flames** (as Call 5 of d9 warned).
    `..._flamer_every_direction_before_after_diagonal_two_flames_..._f349_358_367.png`.
- FRICTION (~3 min): `--boss=king` is an arena flag: the first King film ran the city block (unknown arg
  warnings). Boss fights: `res://dev/arena/arena.tscn -- --boss=king --bot=boss --view=combo ...`.
- Gates it3: unit full 1816/0 (on b06c962f); lint 15/15; director reel (`res://dev/arena/arena.tscn --quit-after 20000
  -- --bot=reel --reel=director --loadout=pistol --rigs --view=<v>`, headless, on 620bd6f7) 19/19 chapters fully
  down in tilt70, combo and top, 0 SCRIPT ERROR, exit 0 (`evidence/n9/reel-director-it3-<view>.log`).
  Evidence run --no-bench on 493d0483 (01:41-01:51): PASS lint, scenarios 54, parity, unit 1816/0 but the stage
  FAILED on "tree changed during run" (my JOURNAL commits mid-run: re-run it4 with the tree still), selftest (look
  goldens 11/11 + block 5/5 within mean 4: top did not move), release-compile 614/0.

REQUEST to assets: rivet_eq_flamethrower_fire_diag_70 and _55, pitch 70 and 55, the flamer's FIRE cells at
the four diagonals (3/4 toward right, 3/4 away right, and the drawn 3/4 toward left / 3/4 away left, never
mirrored; the left ones with the nozzle in his right claw as the drawn left views), the flame drawn ALONG
the diagonal (toward the camera-right / away-right on the ground plane, ~1.6 m long at 70), copied by
example from rivet_eq_flamethrower_70 A's side fire cell (same tank, hose, nozzle, flame shape and colours),
because the owner picked the drawn flame in every direction and a diagonal burst now draws the side flame
beside the game's jet (two flames, still above). One strip of 4 cells per pitch, the house cell size.

NEXT (it4):
1. Film the size: before (`--rivet-height=1.1`) / after at 32 px/m tilt70 beside a cop, a ped, a car;
   King and Servo in combo at 48 px/m; check the ghost swap back, the roll ball, the death sprawl length.
2. Film the flamer diagonal burst (64 px/m), check one coherent flame with the game jet.
3. Film the walk8 at 64 px/m in quest 1 frame by frame (accelerating steps = planted; top speed = the cap).
4. Wire the armed walks per weapon (item 4); gates (unit full, lint, reel x3, evidence --no-bench).
5. Film Servo combo 48 at 1.95 m, the roll ball and the death sprawl at size.
6. Read world's JOURNAL for the knock signal; wire the knock-down strip when assets serve a usable sheet.
7. Check the asset lane for rivet_run8 and the diagonal flamer fire cells (REQUESTed it3).

### Calls drafted for REPORT (it3)
1. **His walk speed vs a planted foot.** His walk is 6.75 m/s (a run). Built: the 8-frame walk by distance
   with the cadence held at 2 cycles/s: planted while he starts, stops and turns; at top speed the feet cover
   27 % of the ground. Options: (a) a drawn run cycle (REQUEST rivet_run8, the default path), (b) a slower
   walk (sim: combat.json walk_mps, the owner's 2026-11-04 baseline; not this lane's), (c) the cap value
   (`RivetWalk.MAX_CYCLES_S`, one data value: 3.0 = a scuttle, more planted, busier legs).
2. **The flamer's diagonal.** Built: the owner's r-7 B; a diagonal burst draws two flames (still in
   frames.json). Options: wait for the drawn diagonal fire cells (REQUESTed), or `--rivet-flame=cone` meanwhile.
3. **1.65 m framing**: no scene broke at 32 (city) or 48 (King combo); Servo not yet filmed.

ANSWER to world (its REQUEST to rivet: a drawn knock-down at his n9 size, p70/p55): accepted. The asset lane is
already drawing it (its JOURNAL 00:43-01:00: rivet_knockdown_70/_b and _55, 5 throw directions x 4 frames
impact / tumble / slide / down, B with a direction fault (every row slides picture-right), re-tested one
direction per sheet in round 20261108-0105; rivet_getup_70 B, _55 queued). I wire it as a RivetFrames strip
keyed by art key (`rivet_knock.png`, the throw row picked by the car heading in screen space, the column by the
time since the hit) as soon as a usable sheet is served. What I need from world: the view-readable signal
(proposed: the rig's react/knock state Rivet already uses for a shove, or a rig meta `rivet_knock` =
Vector3(heading x, heading y, start tick) set by the view from the hit Event). Tell me the field you land and I
read it; until then your hit frame + slide stands.

## it4 (01:53-02:53)

Read: JOURNAL it3, git log, the other lanes' journals (world: REQUEST to rivet = the knock-down, answered it3,
no new field named yet; perf / handheld: no REQUEST to rivet; handheld notes Rivet looked small at 40 px/m in
the King stills: that was before or after c0b0bea0? their branch is cut from main, so d9's 1.3 m: expected), the
asset lane's JOURNAL tail and deliveries (`rivet_down_it118.md`, `rivet_walk_armed_it99.md`). rivet_run8: 70 row 3
B (stance travel 0.62 x height, flight 0.16 x), fixes + all 55 rows in rounds 20261108-0155/-0200: NOT delivered yet.
Registry rules applied: sprite-and-atlas (one scale per grid, a common foot line, and NEW: one tone per figure
across the strips it swaps between: a per-channel mean/spread match to the strip it swaps with); motion-quality
(a still card that translates = a glide; the acceptance is legs that alternate in step with the ground walked);
realtime-combat-semantics (the fire latch takes the equipped strip's fire cell, so the drawn muzzle and the flash
root are the measured ones: the walk grid never fires).

- MILESTONE `2c46aeb4` **weapon-out walks (item 4)**: the library's armed walks wired per weapon each draws:
  pistol (one-hand, drawn left rows v5 / 55 left), plasma rifle (two-hand, left v3 / 55 left v4), katana (blade,
  left v3 / 55 left v4), gatling (heavy, left v3 / 55 mirrored), flamethrower (flamer v2, mirrored left: no drawn
  left exists). Packed by `tools/art/rivet_walk.py` (new `mirror` left source) into `rivet_walk_eq_<weapon>.png`.
  `RivetWalk.path_of` takes it while moving with that weapon out and no fire latch (`RivetStrips.fire_latched`:
  recoil, the FIRE latch, a strike), so a shot swaps to the equipped strip's fire cell and its measured muzzle.
  `RivetFrames.owns_weapon` is true on an armed grid (the held part stays hidden). The left-view override no longer
  replaces an armed grid (the grid has its own left rows). `--rivet-walk-armed=off` = d9's facing card.
  Provenance: 10 lines (spliced left grids name both rounds and prompt hashes from the it99/it105 delivery).
- MILESTONE `9bfc3cf3` **tone match**: the armed sheets read 10-20 levels lighter than the equipped strips (p70
  pistol R 115 vs 95): a visible pop on every shot. `rivet_walk.py --tone=<ref>` matches the opaque pixels'
  per-channel mean and spread to the weapon's own equipped strip; now within ~2 levels.
- FRICTION (~2 min): a static func named `firing` shadowed `draws_fire`'s `firing` parameter -> the script
  failed to compile and every caller reported "nonexistent function"; renamed `fire_latched`.
- FRICTION (~1 min): the pre-commit debt ratchet counts dev LOC: adding the flag to quest1_clip's own list grew
  dev/frames by 1 line; dropped (film the armed walk in the arena).
- Evidence (0 SCRIPT ERROR in all films): pistol before/after at 64 and 32 px/m, plasma rifle at 64 (tilt70 arena
  gunplay seed 3), in `gtai-masters/n9/rivet/` + frames.json. The katana is not a gunplay weapon (the arena keeps
  Gloria): film it in the reel or quest 1 next.
- Seen in the films: the walk family draws his free arm as the cable SPIKE where the equipped strips draw the
  CLAW (an identity swap on the fire latch, d9's walk has it too vs the base): a Call, or a REQUEST for the claw in
  the armed walks. The armed figure reads a touch narrower than the equipped card at the same height.
- Gates it4: unit full 1818/0 (on 9bfc3cf3); lint 15/15.
- Evidence run --no-bench on a4aceb8c (02:21-02:30, the tree held still): ALL PASS: lint, unit 1818/0, scenarios 54,
  parity, selftest (look goldens 11/11 worst 0.27, block 5/5: nothing moved), release-compile 614/0.
- Reels it4 on a4aceb8c: 19/19 fully down in tilt70, combo, top, 0 SCRIPT ERROR (`evidence/n9/reel-director-it4-<v>.log`).
- Filmed gatling + flamer armed walks (64 px/m): both stride, the 3/4-away rows turn with him. Walk -> stop swap on
  the pistol's drawn left rows (f286-304): hand, gun and tone carry across. frames.json now 7 entries.
- MILESTONE `567c1128` **the drawn run at 70 (item 3, the glide at speed)**: the asset lane served rivet_run8_70 (02:30,
  `deliveries/rivet_run8_it121.md`: rows A 5 / B 3; profile travel 0.60-0.63 x H per step). Packed at walk8's scales
  (`rivet_walk.py --k=0.6433,0.6471`: the cells are scaled by dome width to the walk8 rows) + tone-matched to walk8.
  Above `RUN_FROM_MPS` 2.5 he runs: cycle `RUN_CYCLE_CELL` 136 cell px (2 x 0.62 x 110), cap 3.5 cycles/s. At 6.75 m/s
  one cycle = 136/110 x 1.65 m = 2.04 m -> 3.3 cycles/s = 26 drawn fps: under the cap, so **the run plants at top
  speed** (by the numbers; NOT YET FILMED). `--rivet-walk=walk8` = before. p55: row 4 not served, walk8 stays.
  Provenance line: prompt_hash owed (no catalog entry yet; rounds 20261108-0140/-0155 named by job).
- Unit full on 567c1128: 1819/0. Lint 15/15.
- Measured (crude foot-band, profile rows): the armed sheets' contact spread reads ~1.3-1.5x walk8's; they use the
  walk8 CYCLE_CELL 60 now. Only matters under ~1.8 m/s (the cap rules above); a per-strip cycle is a follow-up.
- FRICTION (~3 min): the gunplay bot keeps the gun out, so a bare-claw run never shows in it: film the run in the reel's
  bare chapters or quest 1 (`dev/frames/quest1_clip.gd`, it has `--rivet-walk`).

REQUEST to assets: rivet_walk_armed_onehand_70 and the other armed walks (twohand, blade, heavy, flamer) at 70 and 55, the
free arm as the CLAW (pincer on the plated arm, as `rivet_eq_<weapon>_70` A draws it), because the armed walks draw the free
arm as the cable SPIKE while the equipped strips draw the claw: on every shot the figure swaps arms (filmed it4,
`gtai-masters/n9/rivet/rivet_armed_walk_pistol_before_after_arena_tilt70_64ppm_seed3_f60_81.png`). Copy by example
from the delivered pick cells, arms only, legs untouched. One-hand pistol 70 first. Also: rivet_run8_55 row 4 (the cut).

### Calls drafted for REPORT (it4 additions)
4. **Weapon-out walk: replace or blend.** Built: replace the facing card with the drawn armed walk while moving (until a
   shot), for the 5 weapons that have one; the 12 others keep the card. Option: `--rivet-walk-armed=off`.
5. **Armed walk's free arm** (spike vs the equipped strip's claw): REQUESTed the claw; meanwhile the swap shows on a shot.
6. **The run threshold** (2.5 m/s) and its cap (3.5 cycles/s): data values in `RivetWalk`.

NEXT (it5):
1. (done 02:43) it4b reels on 567c1128 (the run): 19/19 fully down in tilt70, combo, top, 0 SCRIPT ERROR (committed).
2. FILM the run: 64 px/m frame by frame, a planted foot against the asphalt (the acceptance), before `--rivet-walk=walk8`;
   in quest 1 or the reel's bare-claw chapters; 32 px/m before/after. The walk8 at low speed too (owed since it3).
3. Read the asset lane for run8 70 v3 fixes (row 5 arms, L1 slots 7-8) and run8 55 row 4: re-pack (`--k` = the 55
   walk8 scales from `evidence/n9/rivet_walk8_55.json`) and add `RUN_CYCLE_CELL["p55"]` (2 x 0.50 x 110 = 110).
4. Film the katana armed walk (reel blade chapter) and the plasma rifle/pistol at 55 in a boss fight (combo 48).
5. Size: Servo combo 48 at 1.95 m, the roll ball and death sprawl at size, beside a car (owed since it3).
6. world's knock-down field: read their JOURNAL; wire `rivet_knock` when a usable sheet + signal exist.
7. A per-strip cycle for the armed grids (measure the profile contact travel properly, as walk8's measure).

## it5 (02:45-03:45)

Read: JOURNAL it4, git log, the other journals (world: the knock field ANSWERED to rivet = `Events.rivet_knocked(heading,
speed_mps)` + rig meta `rivet_knock` = Vector3(hx, hy, tick), its sim half in progress, nothing sets it yet; perf / handheld:
no REQUEST to rivet), the asset lane (it124: SERVED rivet_eq_flamethrower_fire_diag 70 v2 A + 55 A; run8 70 rows 5 and L1 v3
B; run8 55 row 4 still regenerating, row 5 fix queued). Registry rules applied: sprite-and-atlas (one scale per figure: the
diagonal fire cells sized by the library's house rule, the side-fire robot, not the facings; a common foot line, here held
above the cell bottom because the flame reaches under it); motion-quality (judge a stride in WORLD space: crops registered on
the asphalt, a stance foot must hold between pose switches; the cycle length comes from the drawn stance travel per frame
step); realtime-combat-semantics (the jet's root = the drawn nozzle, measured per diagonal cell).

- MILESTONE `5ea8e2ae` run8 70 re-packed with the library's rows 5 and L1 v3 (the away arms pump, the 3/4-left arms);
  provenance names the 0215 jobs.
- MILESTONE `6d0b1a29` **the flamer's drawn diagonal fire cells (item 2 done as the owner picked)**: `rivet_eq_flamethrower_diag.png`
  at p70/p55 (tools/art/rivet_flame_diag.py: 4 cells by octant, side-fire robot height 82/84 px, foot line 35/15 px above the
  cell bottom = `RivetStrips.DIAG_FOOT_PX`), `RivetStrips.diag_or` swaps it in while a shot latches at a diagonal octant;
  `rivet_muzzle.py measure_diag` measured the 8 nozzles (looked at them: all on the nozzle ring). `--rivet-flame=side` = it3.
  Film (64 px/m tilt70 arena gunplay seed 3, f348-366, 0 SCRIPT ERROR): the drawn flame now leaves the nozzle down-left with
  the jet instead of screen-left beside it. Residual: drawn ~35 deg vs the jet ~60 deg on this aim (inside octant 3).
  `gtai-masters/n9/rivet/rivet_flamer_diagonal_cells_before_after_arena_tilt70_64ppm_seed3_f348_366.png`.
- FRICTION (~8 min): my first flame mask kept the flame's ink outline (the robot read as the whole cell), and the game's
  side-fire cell is a crouch (83 px vs 110 for the facings): took the library's own measure (tallest non-flame columns).
- MILESTONE `f727612d` **the run's cycle fixed (item 3)**: measured in the game grid's profile rows, the stance foot moves
  62-67 cell px from contact to push-off = TWO frame steps, so a cycle is 8 x ~32 = 258 cell px (3.87 m). it4 wired 136 (I
  read the travel as a half cycle): at the 6.75 m/s run the legs churned 1.9x and the stance foot slid backwards. walk8's 60
  re-checked the same way: right (~7.5 px per step, the foot on the ground the whole step).
- Measured in quest 1 (64 px/m tilt70, every tick, crops registered on the asphalt by phase correlation): he SPRINTS there,
  ~14.5 px/tick = 13.6 m/s; at that speed the 3.5/s cap gives a 3.9 m cycle, within 1 % of the drawn 3.87 m, so the sprint
  was already near-planted and stays so. A held pose still slides ~15 px (0.23 m) with the body for its ~2 ticks, then the
  switch puts the stance boot back (the 8-frame sawtooth). The walk8 before: one pose rides the body. Still:
  `gtai-masters/n9/rivet/rivet_run_footlock_world_before_after_quest1_tilt70_64ppm_t383_398.png` (frames.json now 9).
- FRICTION (~10 min): no scene I tried shows the bare-claw RUN at 6.75 m/s for long: the arena hub (`--bot=rivet`,
  `--bot=forms`) hands him a gun (armed walk), gunplay keeps the gun out, quest 1 opens with a 15-tick dash then sprints.
  The 6.75 m/s run is still UNFILMED; the fix there is by measure + unit test only.
- Gates it5: unit select 23/23 + 25/25; lint 15/15 on every commit; director reel on f727612d 19/19 fully down in top,
  tilt70, combo, 0 SCRIPT ERROR (`evidence/n9/reel-director-it5-<v>.log`, `05dd6fa0`).

### Calls drafted for REPORT (it5 additions)
7. **The diagonal flame vs the jet angle**: the drawn diagonal is ~35 deg; the jet follows the aim anywhere inside the octant
   (up to 22 deg off). Options: keep (built), hide the jet's first metre while the drawn flame shows, or ask the library for a
   steeper second diagonal. `--rivet-flame=side|cone` are the befores.
8. **The sprint sawtooth**: 8 poses per 3.87 m at 13.6 m/s = a new pose every ~2 ticks; between them a pose slides 0.23 m.
   Options: keep (built), a 12-16-frame sprint (REQUEST), or a slower sprint (sim, not this lane's).
- Unit full on 05dd6fa0: **1824/0**. Flamer diagonal at 32 px/m filmed (before `--rivet-flame=side` / after, f351-366,
  0 SCRIPT ERROR): `gtai-masters/n9/rivet/rivet_flamer_diagonal_cells_before_after_arena_tilt70_32ppm_x2_seed3_f351_366.png`;
  frames.json now 10.

NEXT (it6):
1. Evidence run --no-bench on this branch (started 03:28 on the JOURNAL commit; check its result in `build/evidence/`).
2. FILM the bare-claw RUN at 6.75 m/s (the it5 cycle fix): find or add a bare-claw path (the reel's claw chapters with
   `--loadout=` empty? the city block with no weapon? a `--weapon=none` in the gunplay bot?), world-registered crops
   (`gtai-n9/tmp/rivet/scripts/footlock.py` + `worldstrip.py`: copy them into tools/ if they stay).
3. run8 55: when the library serves row 4 (and the row 5 fix), pack with `--k` = the 55 walk8 scales
   (`evidence/n9/rivet_walk8_55.json`) and add `RUN_CYCLE_CELL["p55"]` measured the same way as it5 (profile stance foot
   travel per frame step x 8), NOT 2 x travel.
4. world's knock: wire `rivet_knock` (Vector3 hx, hy, tick) to the knock-down strip once world lands the field and the
   library serves rivet_knockdown_70/_55.
5. Armed walks: the per-strip cycle (measure each armed grid's profile stance travel per frame step like it5); the claw
   REQUEST (the spike vs claw swap on a shot).
6. Size films owed: Servo combo 48 at 1.95 m, the roll ball and the death sprawl at size, beside a car.
- Evidence run --no-bench on 37c891de (03:28-03:37, the tree held still): PASS lint, unit 1824/0, parity, selftest (look goldens
  11/11 worst 0.27, block 5/5 worst 0.22: nothing moved), release-compile 614/0; scenarios 53/54: FAIL scenario_corpse_horde
  (a wall-clock check: "the step grew with the dead 1082 -> 2668 us", not a rivet path; the shared machine was busy).
  Re-run alone at 03:39: `run_scenarios.mjs --only=scenario_corpse_horde` PASS. Read as contention; re-check in it6's evidence run.
- it6 lead for the 6.75 m/s run film: the reel's `claw_combo` chapter (dev/showcase/reel_chapters.gd l.41, mode `claw`).

## it6 (03:39-04:39)

Read: JOURNAL it5, git log, the other journals (world: ANSWER to rivet, the knock field landed at 0c04d16b on n9-world:
`CityCharacters.KNOCK_META` = `&"rivet_knock"` Vector3(hx, hy, tick) on Rivet's CutRig while down 1.2 s, plus
RigFeed.Flag.DOWN -> rig.dead (the death sprawl shows meanwhile); film with `res://dev/showcase/car_knock_clip.tscn --
--out=<dir> --view=tilt70 --zoom=2`, hit at tick 196. perf / handheld: no REQUEST to rivet), the asset lane (SERVED
it124 `rivet_walk_armed_claw_it124.md`: all 20 claw armed walks, 19 A / 1 B; run8 70 rows 4 v3 / 5 v4 A (the limp and
same-side contacts fixed), run8 55 row 4 v5 B: the 55 run COMPLETE; knockdown sheets still in redraw: away v4 04:11,
left/right v2 03:55). Registry rules applied: sprite-and-atlas (one scale per figure: the claw grids packed at the
it4 scales within 1 %, one tone per figure swap: tone-matched to the equipped strip again); motion-quality (a stride's
cycle is the drawn stance travel per frame step, measured per grid, never shared between grids drawn by different
rounds); realtime-combat-semantics (the shot still swaps to the equipped strip's fire cell and its measured muzzle:
nothing in the fire path moved).

- MILESTONE `f2e05223` **the armed walks draw the claw (my it4 REQUEST, served)**: 10 grids re-packed from the claw
  cells (`rivet_walk.py`, --tone to each equipped strip). The gatling 55 and the flamer keep mirrored lefts (their
  equipped strips mirror: a drawn left would put the weapon in the other hand on every shot; DECISION rivet/armed-claw).
  Looked at the pistol 70, katana 55 and flamer 70 grids: the pincer on the free arm in every cell.
  Film: pistol before (it4 spike) / after (claw), arena gunplay seed 3, tilt70, 64 and 32 px/m, f60-102, 0 SCRIPT
  ERROR; at 55 in the King fight (combo 48, seed 1): left-profile armed walk with the claw, the shot, the roll.
  `gtai-masters/n9/rivet/rivet_armed_walk_claw_*` (frames.json now 13).
- MILESTONE `8fc2314a` **the run at 55** (the library's run8_55, all 8 rows) + run8 70 rows 4 v3 / 5 v4: packed at the
  walk8 scales (`--k`), tone-matched to walk8. `RUN_CYCLE_CELL["p55"]` = 212, measured as it5 (profile stance boot ~53
  cell px over two frame steps; the same probe gives 64.6 -> 258 at p70, it5's value). Unit test: every run strip has a
  measured cycle. Looked at the 55 grid: rows alternate; nits as the library lists (row 2's black stub in 5/6/8; row 1
  reads the leg swap weakly).
- MILESTONE `e4e150ec` **each armed walk on its own cycle** (`ARMED_CYCLE_CELL`, 66-81 cell px; flamer keeps 60):
  measured on the profile rows (`evidence/n9/rivet_walk_armed_cycle.md`); the shared 60 churned the armed legs 10-35 %
  fast. Below the cap only: at his 6.75 m/s the 2/s cap gives 3.4 m per cycle against a ~1.1 m drawn armed stride =
  **the armed walk still glides at top speed** (needs a drawn armed run: REQUEST below).
- Gates it6: unit select 26/26, 20/20, 24/24; lint 15/15 on every commit; director reel 19/19 fully down in top,
  tilt70, combo, 0 SCRIPT ERROR on 8fc2314a (`reel-director-it6-<v>.log`) and on the armed cycles (`it6b`).
- FRICTION (~8 min): the before film. `git show HEAD~1:<png>` writes the Git LFS POINTER (104 SCRIPT ERRORs: a null
  texture); use `git show ... | git lfs smudge`. And a running game does not re-import: swap the PNG, `--import`, film,
  restore, `touch`, `--import` again (check the `.godot/imported/*.md5` source_md5 against `md5sum`).
- FRICTION (~3 min): the reel's katana chapter (`--chapter=katana`) is a dash-in, it never shows the armed walk long
  enough to judge; the katana claw walk is unfilmed (looked at its grid only).

REQUEST to assets: rivet_run8_armed_onehand_70 (then twohand, blade, heavy at 70, then 55): Rivet's 8-frame RUN with a
weapon out, because the armed walk (4 frames, ~1.1 m a cycle) glides at his 6.75 m/s top speed (the 2/s cadence cap
covers 3.4 m per cycle). Layout exactly as rivet_run8 (5 right rows x 8 + 3 left rows x 8, contact, down, passing, up,
contact other foot, down, passing, up; the same foot line and dome width as the run8 cells), LEGS copied by example from
the delivered run8 rows (their stance travel 0.60-0.63 x height per step is what plants), ARMS and weapon copied from the
claw armed walk (`rivet_walk_armed_onehand_70_claw_cells`, the gun forward in the hand side it draws, the claw free arm).
One-hand pistol 70 first.

### Calls drafted for REPORT (it6 additions)
9. **Mirrored lefts on the gatling 55 and the flamer armed walks**: the library drew claw lefts; wiring them makes the
   weapon change hands on a shot until the equipped strips get drawn lefts. Built: mirrored (consistent). Option: one
   argument to `rivet_walk.py` (the drawn left folder) + the equipped strips' drawn lefts (REQUEST).
10. **The armed walk at top speed**: still a glide (cadence cap). Options: an armed run (REQUESTed, built ahead: the
    cycle table takes a new grid by name), or raise `MAX_CYCLES_S` for armed grids (4 frames at ~6/s: planted but a
    scuttle).

NEXT (it7):
1. The knock-down: wire `rivet_knock` (Vector3 hx, hy, tick; `CityCharacters.KNOCK_META` on n9-world, absent here:
   read it with a default) to a RivetFrames strip `rivet_knock.png` per art key, the row by the car heading in screen
   space (toward/away/left/right), the column by ticks since the hit; it must win over the DOWN sprawl while set. The
   library's sheets: `keyed/rivet/rivet_knockdown_{toward,away,left,right}_{70,55}[_vN].png` (check its JOURNAL for the
   picks; away 70 v4 at 04:11). Film with world's `car_knock_clip.tscn` once world merges or on a scratch merge.
2. Full unit run result of it6 (started 04:16, `gtai-n9/tmp/rivet/unit_it6.log`); the evidence run --no-bench.
3. The bare-claw run at 6.75 m/s still unfilmed (it5 NEXT 2): a `--weapon=none` path or the city block bare.
4. The armed run when the library serves it (pack like run8, add `ARMED_CYCLE_CELL` entries from its profile rows).
5. Size films owed: Servo combo 48 at 1.95 m, the roll ball and the death sprawl at size, beside a car.
- Unit full on e4e150ec's code: **1826/0**. Evidence run --no-bench on 7a746165 (04:18-04:32, tree held still): ALL PASS:
  lint 15/15, unit 1826/0, scenarios 54 (city_chase nav budget CONTENDED: 2 other runs, not judged), parity, selftest
  (look goldens 11/11 worst 0.27, block 5/5 worst 0.22: nothing moved), release-compile 614/0.
- it7 prep for the knock-down (NEXT 1): every strip is now A in the library (JOURNAL 04:15): p70 = toward_70,
  away_70_v4, right_70_v2, left_70_v2; p55 = toward_55_v2, away_55_v3, right_55, left_55. Each is 1 x 4 (impact,
  tumble, slide, down) on a 2172 px sheet: cut by QUARTER columns (543 px; some 55 figures touch). Scale: the lying
  frame's dome is ~178 px vs walk8's profile dome ~92 px -> k ~ 0.52 x walk8's 0.6433 = ~0.33 at p70 (FIRST ESTIMATE:
  the library says away v4 is ~1.2x the toward strip: measure each strip). Draft packer (not in the repo):
  `gtai-n9/tmp/rivet/scripts/rivet_knock_draft.py` (make it premultiplied like rivet_walk.py before it lands).
  `rivet_frames.gd` is at 199 lines: the knock goes in a new `RivetKnock` class, hooked at the DEATH branch (l.101):
  while the rig has `rivet_knock` meta, the knock strip wins over the DOWN sprawl.

## it7 (04:34-05:34)

Read: JOURNAL it6 NEXT, git log, the other journals (world: no new REQUEST to rivet, its knock field at 0c04d16b is the
ANSWER I wire; perf / handheld: none to rivet), the asset lane (it128: every knock-down strip A, away 70 v4 the pick;
run8 55 row 4 v6 / L1 v6 A, re-pack; the armed run onehand 70 rows in progress for my it6 REQUEST, row 1 A, row 3 v2
and row 2 v2 fixes running; a 12-frame sprint OFFER for Call 8). Registry rules applied: sprite-and-atlas (one scale per
figure: each knock strip scaled by its down frame's length so its dome matches walk8's, tone-matched to walk8; figures
split by alpha blob, never by a fixed cut), motion-quality (judged in motion frame by frame at 64 and 32 px/m on the real
city with a sim car; a pop between states is a defect: found and fixed the sprawl tail), depth-ordered (the lying figure
centred on his ground point, so it sorts with the car by his body, not by a foot line half a body away).

- MILESTONE `a4656a3e`+`f28589e8` **the drawn knock-down** (it5 NEXT 4): `tools/art/rivet_knock.py` packs the library's
  8 one-direction sheets into `rivet_knock.png` (4 x 4) at p70 and p55; `RivetKnock` (new class, rivet_frames.gd stays
  at 200 lines) swaps it in while world's `rivet_knock` meta is set: row by the car heading's dominant screen axis,
  column by pose time since the hit (impact 0, tumble 6, slide 24, down 54 ticks), lying cells turned onto diagonals.
  `--rivet-knock=off` keeps the sprawl. Unit test `test_rivet_knock` (7). DECISION rivet/knock.
- MILESTONE `4e4a0bf3` the down cell holds through the rig's rise tail: the first film showed the upright DEATH sprawl
  pop in t273-291 (~0.33 s) between lying and standing (rig.dead outlives the knock meta).
- Film (scratch worktree `gtai-n9/tmp/rivet/knockwt` = 4e4a0bf3 + n9-world merged, world's native DLLs; world's
  `car_knock_clip.tscn -- --view=tilt70 --zoom=2|1 --every=1`, 0 SCRIPT ERROR, knocks=1 hit=196; before = the same with
  RivetKnock.enabled false): `gtai-masters/n9/rivet/rivet_knockdown_before_after_city_car_tilt70_{64,32}ppm_t198_294.png`
  + `rivet_knockdown_city_car_tilt70_64ppm_t150_350.mp4` and its BEFORE mp4. Looked at every row: impact t198 (right
  row, helmet leading), tumble t204-216, the slide along the car's nose t222-252, down t258-291, standing t294.
- FRICTION (~4 min): the library catalog ids drop the pitch (`rivet_knockdown_toward` + "pitch": 70); match by `keyed`.
  The first provenance append wrote 2 lines with empty references: removed before any commit.
- FRICTION (~2 min): a scratch worktree shares core.hooksPath: its merge commit ran lint and failed on my unfixed line.
- Re-pack run8 55 (it128: row 4 v6, L1 v6, both A) at the it6 --k scales; looked at both rows before/after.
- Gates: director reel on 4e4a0bf3's code (`reel-director-it7-<v>.log`): 19/19 fully down in top, tilt70, combo, 0 SCRIPT
  ERROR, exit 0 (commit adcb725b). Unit select 29/29 (walk, frames, knock); lint 15/15 on every commit.
- MILESTONE `425ad75d` **the get-up kneel** (the library's rivet_getup_70/_55 kneel column, B: rows toward / away / right
  profile, the left throw mirrors the right profile; dome-matched to walk8 (k 0.53 / 0.55), feet on his ground point):
  the knock grid is 5 x 4 now; once the rise passes 0.6 of the sprawl the kneel shows. Film (64 px/m): lying to t276,
  kneel t279-291, standing t294; masters' knock sheets and the 64 mp4 re-made with it.
- MILESTONE `4c315b3d` run8 55 re-packed (row 4 v6, L1 v6), looked at both rows; provenance for it + the kneel column.
- MILESTONE `b31577a4` **the drawn armed run at 70** (my it6 REQUEST, the library delivered one-hand 7 A / 1 B and
  two-hand 8 A at 05:13): `rivet_run8_eq_pistol.png`, `rivet_run8_eq_plasma_rifle.png` (rivet_walk.py --cols=8 --k =
  run8 70's, --tone = the equipped strip); `RivetWalk` takes them above RUN_FROM_MPS (`ARMED_RUN`, `is_run`: the run's
  cycle, the same legs). Unit test (armed runs at p70, katana falls back to its armed walk, the fire latch). Film:
  arena gunplay pistol seed 3, tilt70 64 px/m, 200 frames each, 0 SCRIPT ERROR: before (`--rivet-walk=walk8`) one pose
  for many frames, after open running strides, the pistol forward, the claw free
  (`gtai-masters/n9/rivet/rivet_armed_run_pistol_before_after_arena_gunplay_tilt70_64ppm_seed3_f20_176.png` + mp4).
  DECISION rivet/armed-run. frames.json 14.
- Reels it7b (`reel-director-it7b-<v>.log`): top ran on 4c315b3d; tilt70 and combo started after rivet_walk.gd changed
  (b31577a4's code, before gdformat's whitespace): 19/19 fully down, 0 SCRIPT ERROR, exit 0 in all three; top re-run
  on b31577a4 (`reel-director-it7c-top.log`, 05:21-05:24): 19/19 fully down, 0 SCRIPT ERROR, exit 0. So every view
  has a green reel on the armed-run head.
- OWED: the armed-run provenance lines carry no prompt_hash (the rows are not in catalog.json or metrics.jsonl yet at
  05:14; refs name the cell folders + row ids): fill them when the library's catalog lists them.
- FRICTION (~3 min): deleted the knock clip frame dirs while cleaning (the masters keep the sheets and both mp4s).

### Calls drafted for REPORT (it7 additions)
11. **The knock-down** (cars knock him down): built = the drawn knock strip (4 throw axes, diagonals by turning the
    lying cells) + the get-up kneel; option `--rivet-knock=off` = the d9 DOWN sprawl. Open: the left kneel is the right
    profile MIRRORED (claw and cable swap sides for ~12 ticks); a drawn left kneel is one REQUEST.
12. **Knock scale**: each strip's down frame = 1.2 (p70) / 1.45 (p55) standing figures (`--len`), chosen so the dome
    matches the walk; the lying body reads ~1.3x his standing height at 64 px/m. Option: one value per art key.

NEXT (it8):
1. (done in it7: the reels are green on b31577a4 in all three views.)
2. Armed runs as the library serves them: twohand/blade/heavy at 70 then 55: pack each like b31577a4 (one grid per
   weapon name; blade -> katana, heavy -> gatling; check each grid's legs travel = run8's before reusing RUN_CYCLE_CELL).
3. Film the knock's other rows (toward / away / left): world's clip has one car heading; a scratch drive with the car
   turned, or wait for world's real-city clip on main.
4. (it7: full unit on 4b912de0 = **1834/0**, 05:25-05:27.) The evidence run --no-bench on the it7 head.
5. Size films owed: Servo combo 48 at 1.95 m, the roll ball and the death sprawl at size, beside a car.

## it8 (05:28-06:28)

Read: JOURNAL it7 NEXT, git log, the other journals (world it16: no REQUEST to rivet, it reads RivetKnock as specified;
perf / handheld: none to rivet; handheld notes Rivet ~35 px at 40 px/m on main, his 1.65 m is on this branch), the asset
lane (it131: DELIVERED the blade and heavy armed runs at 70, 7 A / 1 B each; the 55s in rounds 0605-0620). Registry rules
applied: sprite-and-atlas (one scale per figure: the armed runs packed at run8 70's --k, never re-measured per row; a
re-delivered row checked against the shipped one before re-packing), motion-quality (judged frame by frame at 64 px/m on
the real reel chapter, before/after from the same build with the toggle off).

- MILESTONE `4b06fbdf` **the drawn katana run at 70** (the library's blade run, rows 1-5 A, L2 v2 / L3 v2 A, L1 v2 B):
  `rivet_run8_eq_katana.png` (rivet_walk.py --cols=8 --k=0.6433,0.6471 --tone=rivet_eq_katana.png); the unit test now
  runs pistol, rifle and katana drawn, the flamer falls back to its armed walk. Select 29/29, lint 15/15.
  Film: the reel's katana chapter (`arena.tscn -- --bot=reel --reel=director --chapter=katana --loadout=pistol --rigs
  --view=tilt70 --ppm=64`, 200 frames, 0 SCRIPT ERROR; before `--rivet-walk=walk8`): the run-in to the cop f50-58,
  before = the armed walk's short steps sliding, after = open run strides, fist on the hilt, claw free.
  `gtai-masters/n9/rivet/rivet_armed_run_katana_before_after_reel_katana_tilt70_64ppm_f46_62.png` + both half-speed mp4s;
  frames.json 15. Seen: the run figure reads a touch warmer than the armed walk cell before it (tone ref = the equipped
  strip, not the walk).
- FOUND: the library re-delivered blade L1 as **v3** after my pack (its cells at 05:32+): packed, row 6 comes out at
  ~0.6x the other rows (the raised free fist beside the dome widened the dome band the library scales by, as its heavy
  row 2). Kept the shipped v2 row (B: the tip near the free forearm). REQUEST below.
- Packed the heavy (gatling) run (`gtai-n9/tmp/rivet/it8/rivet_run8_eq_gatling.png`, looked at all 64 cells: coherent,
  the pack shows, the back row hides the gun); L2 v2 is B (stride -0.55/-0.52 vs run8's 0.60: ~12 % slide on the left
  profile only on one cycle). Installed after the evidence run (the tree is held still for it).

REQUEST to assets: rivet_run8_armed_blade_70_left_row1_v3 (pitch 70): the assembled `rivet_run8_armed_blade_70_left_cells`
row 1 (v3) is scaled ~0.6x the other rows (the raised free fist beside the dome widens the dome band, as heavy row 2);
please re-assemble it with a hand scale like heavy row 2's `--scale2` (row 2's or row 3's dome ratio), so the figure
matches L2/L3. Until then rivet ships v2. And heavy L2 v3 (pitch 70) if a run lands at 0.60 x H stride (you offered it):
the left profile slides ~12 % on the grid's one cycle.
REQUEST to assets: rivet_run8_armed_flamer_70 then _55 (pitch 70 / 55), after the queued 55 runs: the 8-frame RUN with the
flamethrower out, the run8 layout (5 right rows + 3 drawn left rows x 8, run8 order), LEGS by example from the run8 picks,
ARMS + flamer + tank from the flamer armed walk rows (`rivet_walk_eq_flamethrower.png` at 70: its lefts are mirrored, so draw
the lefts with the nozzle still in the claw's hand as the right rows; the tank on the back in the away rows); profile travel
0.60-0.63 x H like run8 so one cycle fits. Why: the flamer is the last 70 weapon with a drawn walk that still glides at the
6.75 m/s run (pistol, rifle, katana, gatling now run drawn).
- Gates on 4b06fbdf (the katana run): director reel `reel-director-it8-<v>.log` 19/19 fully down in top, tilt70, combo, 0
  SCRIPT ERROR, exit 0 (commit 0d39f360). Evidence run --no-bench on 4b06fbdf (05:42-05:50): lint PASS, unit **1834/0**
  but flagged FAIL "tree changed during run" (my JOURNAL edit + the combo reel log landing mid-run: my error, the tests
  themselves all passed), scenarios 54 PASS, parity PASS, selftest PASS (look goldens 11/11 worst 0.27, block 5/5 worst
  0.22: nothing moved), release-compile 615/0.
- Size film owed since it6 (it7 NEXT 5, part): **Servo combo at 48 px/m, p55 1.3 -> 1.95 m** (`--boss=servo --bot=boss
  --view=combo --ppm=48 --seed=1 --loadout=pistol --rigs`, before `--rivet-height=1.1`, f150/f250, 0 SCRIPT ERROR both):
  at 1.95 m he stands about two crates tall, sorts in front of the crate stack by his feet, the shadow lengthens with him,
  the van and Servo stay in frame: no framing Call. `gtai-masters/n9/rivet/rivet_size_before_after_p55_1p3_1p95_servo_combo_48ppm_x1.5_seed1_f150_250.png`.
- MILESTONE `1f067f92` **the drawn gatling run at 70** (the library's heavy run, 7 A / 1 B) + `RivetWalk.RUN_ROW_K`
  ("<art>/<weapon>/<octant>"): a drawn run row with a shorter stride steps on a shorter cycle. Unit test (row_k: left
  profile only, the bare run 1). Select 34/34, lint 15/15. Film (arena gunplay gatling seed 3, tilt70 64 px/m, 0 SCRIPT
  ERROR; before `--rivet-walk=walk8`): before the legs barely move while he covers ground, after the toward row strides
  (`rivet_armed_run_gatling_before_after_arena_gunplay_tilt70_64ppm_seed3_f40_72.png` + half-speed mp4s; it replaces the
  it6 gatling/flamer still in frames.json, 15).
- MEASURED (tmp `it8/travel_grid.py`, the library's cells_travel maths on my packed grids, absolute cell px at one scale):
  left profile (row 6) run8 -62/-64, pistol -62/-64, rifle -62/-62, katana -63/-64, **gatling -60/-58**; 3/4 rows equal
  within 4 px. So the gatling L2 is 59/63 = **0.94** of run8, not the 0.88 I took from the library's x H ratios (the heavy
  figure with the pack is taller: H 110 vs 104, so its x H travel reads short). Fix: RUN_ROW_K 0.94.
