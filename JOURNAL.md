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
