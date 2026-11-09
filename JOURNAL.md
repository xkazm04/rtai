# JOURNAL: night n11, lane combat

Branch `n11-combat`, cut from main `812a0b06`. Evidence: `C:\Users\kazda\kiro\gtai-masters\n11\combat\`.
Capture helper (not in git): `C:\Users\kazda\kiro\gtai-n11\tmp\combat\run.sh <label> <frames> <args>`, arena at combo, 64 px/m, with the body probe.

## Iteration 1 (2026-11-09, from 19:27)

- 19:29 Read `STANDARDS.md`, `AGENTS.md`, the corpse code paths and n10 world's REPORT. No `REQUEST combat:` lines yet (hero lane has no journal so far).
- Suspects for item 1, from reading only (nothing reproduced yet):
  - Size: the lying art is drawn long on purpose (`StreetWalkerFall.LONG_FALLS` "1.4-1.7x of standing", `StreetDeadPlan.HEAD_K`: "the longest pose: 1.4 x standing"), and `LAND_SCALE` 1.05.
  - Moving: `StreetDeadPlan.draw` reads `rig.facing` (a spring) for the blow every frame; `StreetQuestDeadPush.push_of` calls `reset()` at 256 entries, which re-solves every lying body; the far crowd draws at its sim point, which keeps sliding on `v_`.
  - Collision: `ArenaBodies.resolve` and the sim's `body_resolve` both skip the dead; a knocked-down person (`M_DOWN`) still pushes. No path found yet.
- Added the dev probe `dev/frames/dead_body_probe.gd` (`--body-probe=<json>`).
- 19:35 MILESTONE reproduced in the arena (`--bot=pit --horde --seed=7`, combo, 2400-3000 frames, probe in `C:\Users\kazda\kiro\gtai-masters\n11\combat\body_probe_before_hop_fix.json`): sim points moved 0.0 m, drawn bodies moved up to 0.8 m after settling; worst body's drawn path 71.7 m. Layer check: actor canvas vs ground 0.0 px, so it is not a camera or layer lag.
- 19:42 CAUSE (hop): the drawn corpse is a child of the rig; the death slide is added in `HumanReact.pre` on a pose step; `RigInput.apply` resets the rig to its sim point every tick. A rig past the full-rate ranks skips poses, so the body flipped between two points 0.5 m apart. Two steps in a frame doubled the slide. Fixed `c7a045d5` (`RigCarry`), test `test_corpse_rests_steady` red first (12.6 px, 64 px).
- 19:50 CAUSE (sink drift): pelvis offset and slide both scaled with the decay's sink. Fixed `0da58aed`, `ee0905f4`.
- 19:58 CAUSE (size): plan poses are 1.0-1.41 x the standing card; in a live frame a dead riot cop read about 1.8 x a living one (by eye on a 4x crop). `LYING_K` 0.72, `1d5879cb`, on near rigs, far crowd and quest 1. Test `test_dead_body_size` red first at 1.0.
- 20:05 CAUSE (glide): the push off neighbours (up to 2.4 m) was paid in 8 ticks, so a body shot about 3 m in 0.2 s. `SPACE_M` 1.5, `PUSH_MAX_M` 1.8, eased over the rest of the death, `ceed87d2`. Path of the worst body after: 2.92 m (was 71.7 m). Includes the fall itself.
- 20:11 City (`--arena=city`, seed 7): only 3 bodies in 2100 frames. Largest step after settling 0.5 px, drift 0.07 m, lying length 50-52 px against 56 px standing. Thin sample.
- DECISION corpse size: `StreetDeadPlan.LYING_K` 0.72 (1.0 = before). Rejected a per-pose scale: head sizes would differ across a heap. Heads now read smaller than a standing head, because a standing head is seen from above.
- DECISION push: `SPACE_M` 1.5, `PUSH_MAX_M` 1.8. Tighter caps left bodies overlapping in the one-spot crowd test (`PUSH_MAX_M` 1.4 and 1.6 both failed it).
- FRICTION: `--write-movie` ran at about 1.5 fps on this machine; a 3000-frame film is about 30 min. Use `tmp/combat/probe.sh` (no movie) and `shot.sh` (one still).
- FRICTION: `node tools/godot/check.mjs` reports `rig_carry.gd` and `human_react.gd` FAIL ("Failed to compile depended scripts") while the same code runs under GUT and the game. Not investigated; the release-compile gate has not been run on this branch yet.

CRITIQUE (item 1, hostile pass on the stills I have):
- Heads on the dead are now visibly smaller than on the living.
- A body still travels 1.2-1.5 m net in about 0.4 s at the landing; peak about 5 px per tick at 32 px/m. Better than before; not yet "falls where it stood".
- Dropped rifles lie as flat black bars beside the bodies, off the pose.
- Top-right riot cop in `dead_size_ab_crop.png` is inked to near-black while still looking freshly dead (decay ink reads as a black blob).
- Not looked at in motion yet: everything above is from stills and probe numbers.

NOT DONE on item 1 (do not close):
- Collision: NOT reproduced. Tried: `ArenaBodies.resolve` and the sim's `body_resolve` both skip the dead by reading; `test_dead_bodies_walkable` (dev arena, Rivet walks over a shot guard) passes against a no-body baseline to 0.001 m, uncommitted. Unmeasured: the city and quest 1 paths. Best lead: a knocked-down living person still blocks (`down()` calls `body_push`, `body_resolve` only skips `M_DEAD`, `ArenaBodies` only skips `not alive()`), and a downed person looks like a body. A native change would need both DLLs rebuilt and likely a parity re-bless.
- Quest 1 not run with the probe. The far crowd's baked corpses are not measured by the probe (it reads hostiles only), so the owner's note may still hold there.
- No before/after clip of the hop yet, only probe numbers.
- Gates: only selected unit suites and lint so far; full unit run started 20:12; scenarios, evidence, reel not run.

NEXT: (1) read the full-unit result in `build/test-results/`. (2) Item 1: collision on the city and in quest 1, with the knocked-down lead; probe the far crowd (read the feed's DEAD rows); clip of the hop before/after; run the scenarios (decay and replay touch these paths). (3) Commit `test_dead_bodies_walkable.gd` with the collision work. (4) Item 2: ground pickups x2 in `features/player/pickups_view.gd` (`DISC_M`, the span in `_rebuild`, `HOVER_M`), crates `LONG_M`, then check spacing of the arena's pickup row. (5) Items 3 to 6 in brief order. Seen in passing for item 5: dumpsters and crates cast long dark shadows in the arena at combo, against the standing owner note (`dead_size_before.png`).

## Iteration 1, last entries (20:17)

- 20:14 Scenarios `corpse_horde, brutality_kills, arena_pit, crowd_react, city_replay`: 5 passed (selected only, not the full suite).
- 20:17 MILESTONE item 2, ground pickups only: `GROUND_K` 2.0 on span and disc (`c7450890`); the pickup reach is unchanged. Before/after at tick 170, 48 px/m: `pickups_ground_before.png`, `pickups_ground_after.png`. The Gatling is now about 150 px, wider than Rivet.
- CRITIQUE item 2: only one pickup was in frame, so spacing between pickups is unjudged; not checked on the city or at 32 px/m. At x2 a long gun out-spans the person who picks it up; the hero lane's 150 % Rivet will close part of that.
- OPEN item 2: the owner's "weapon showcase avatars/icons" may mean the hub's weapon wall (`WeaponRackView`). It is unchanged: x2 needs a new layout (the board is 17 guns wide at `GAP_M` 1.0). Do it next.
- `test_dead_bodies_walkable` committed as a regression guard for the dev arena only. It does not close the collision note.

NEXT (replaces the list above): (1) item 1 collision on the city and in quest 1, starting from the knocked-down lead; probe the far crowd's corpses; quest 1 probe; a before/after clip of the hop. (2) Item 2 hub wall x2, pickup spacing, city, 32 px/m. (3) Full gates: scenarios (whole suite), `tools/evidence/run.mjs`, reels, none run on the whole branch yet; check `release_compile.mjs` given the `check.mjs` oddity. (4) Items 3 to 6 in brief order.

## Iteration 2 (2026-11-09, from 20:20)

- 20:26 Full unit from it1: 2211 tests, 0 failures (junit read).
- 20:29 CAUSE (collision, knocked down): `test_downed_person_walkable` red first: Rivet's sprint path bent 0.232 m by a downed person, and walking over them shoved them. `M_DOWN` no longer blocks and is no longer shoved, in `sim_body.gd` and `body.cpp` (`50b47690`). Both DLLs rebuilt. Parity exact, `city_replay` identical.
- 20:33 CAUSE (bodies jump in a long fight): `StreetQuestDeadPush` wiped every push at 256 entries, so each body still lying re-solved; red first, one test moved 64 px, 84 px. Now the oldest push only (`0965bc3a`).
- 20:35 Guards (`6539dc94`): the city's dead keep their row exactly while Rivet crosses the heap (`test_sim_corpse_rests`, 240 ticks, 12 bodies); quest 1's `ArenaBodies` skips the dead.
- 20:40 MILESTONE item 3 (`80b8c621`): no paper; 4 avatars on their own silhouettes, ink rim, teal rim for the current form, teal arc while cooling, ink silhouette and padlock when locked. 244 x 128 px against 360 x 158. Judged: state sheet on bright and dark ground (`hud_ghost_states_after.png`, compact too) and the arena (`hud_ghosts_before.png`, `hud_ghosts_after.png`). The sheet script is out of the repo (debt ratchet): `gtai-n11/tmp/combat/ghost_hud_sheet.gd`.
- 20:49 MILESTONE item 4 (`d25fafb1`): hardware cursor per weapon class and per ghost form, drawn in code (`tools/art/cursor_draw.py`). Sheet: `cursors_sheet.png` (flame, melee and kerf were redrawn after the first sheet). NOT seen in a live window: a capture does not include the mouse. Only the mapping tests and a live run with no error.
- 20:51 MILESTONE item 5 shadows, first pass (`4007f09b`): `cast_k` 0.35 on combo and tilt70, soft contact ellipse under standing figures. Before/after at tick 260, 64 px/m: `shadow_city_before.png`, `shadow_city_after.png`, crop `shadow_city_ab_crop.png`; arena `shadow_arena_after.png` (before is `hud_ghosts_before.png`).
- DECISION item 2: the arena hub's weapon wall (`WeaponRackView`) is not "on ground": left as is. Floor pickups and crates are the x2 (`c7450890`). If the owner meant the wall too, it needs a new layout.

CRITIQUE (items 3, 4, 5 so far):
- Rivet's contact ellipse sits a few px below his drawn feet; cops look anchored. Depends on his size change in the hero lane, so re-check after that merges.
- Vehicles and the city's building casts not looked at under the new `cast_k`.
- Body contact shadows vs the new standing ones not compared side by side.
- The cursor has never been seen on a real mouse. 48 px may be small at 1440p and up.
- HUD name "Tonnage" starts 9 px from the screen edge. Acceptable, tight.
- 20:56 Gates on `4007f09b`: unit 2224/2224; scenarios 55/55. `evidence/run.mjs` and the reels have NOT been run on this branch.
- 21:01 CORRECTION to the item 2 decision above: the on-ground showcase is `ArenaArmory` (hub floor), drawn by `PickupsView`, so the x2 did reach it, and piled it into one heap (`armory_x2_before_spacing.png`). Grid 3.15 x 1.8 m, 5 per row, long guns capped at 2.6 m, ring `DISC_K` 1.3 (`88d07829`, `armory_x2_after.png`). The hanging wall (`WeaponRackView`) is unchanged and goes to Calls for the owner.
- 21:03 MILESTONE item 5 projectiles, first change only (`shot_trail_ab_crop.png`): the hit streak tapers, flash x1.45.

CRITIQUE (projectiles, reactions; hostile pass at 1:1 from `tmp/combat/fight/`, one still per weapon):
- Only the machine pistol has been judged at a firing frame. The pistol, rocket and plasma stills caught no round in flight (tick 420 is between shots; `--bot=range` does not fire by tick 214). Rockets and plasma are unjudged.
- The plasma bolt is a small paper-white teardrop; reads weakly against the concrete.
- The flash cell's hot core is orange-red: check against the colour law (red is blood only; those cells are from an approved night, so unchanged).
- Casings on the floor are flat cream chips that do not look like brass.
- The flame puffs read well, but in the one still they are detached from the nozzle: a gap between the gun and the fire.
- Reactions: NOT looked at this session. Melee hits do reach the reaction layer now (`CombatArena.wounded`, `ReactLink`), so the 2026-11-04 "open" note on `struck` is stale.

NOT DONE: reel gate; evidence run; before/after clips (only stills so far); quest 1 probe for corpses (quest paths are covered by unit guards only, not a frame); far-crowd baked corpses not measured in a live run; a firing-frame capture method is still missing (next line).
FRICTION: `--shot-tick` needs a tick where something fires, and nothing says when that is. Each guess costs one Godot start. `--write-movie` runs at about 1.5 fps.
REQUEST tools: a way to capture N consecutive ticks from one run (`--shot-range=A:B`, or `--shot-on-fire=<n>`: save the frame on Rivet's nth shot and the k frames after it), and the same for kills, so a firing or dying frame takes one run.
- 21:12 Gates on the tree just before the last move of `FLASH_K` (no behaviour change): unit 2225/2225, scenarios 55/55, `release_compile` 643 loaded, 0 failed. So the `check.mjs` FAIL noted in iteration 1 is not a release problem. After the move: lint 15/15, `test_muzzle_k` and the trail tests 12/12. Shot streak commit `86267667`.

NEXT: (1) Gates still owed on this branch: `tools/evidence/run.mjs` and the reels (`--views=top,tilt70,combo`), neither run yet; the combo `cast_k` and the HUD will likely move look goldens, so re-bless deliberately with a dated line. Rebuild both DLLs after any merge (they are untracked; `body.cpp` changed). (2) Item 5, in order: get firing frames (see the `REQUEST tools:` line, or guess ticks with `--bot=gunplay` around tick 420); judge rocket, plasma, electro, flame and impacts by surface; then reactions (hit direction, flinch, deaths) against the 2026-11-04 reports. (3) Shadows: vehicles and buildings under `cast_k` 0.35; Rivet's contact ellipse sits a few px low, re-check after the hero lane's 150 % size. (4) Item 1 still owes a live quest 1 frame and the far crowd's baked corpses in a real run, and a hop before/after clip: only stills and probe numbers exist. (5) Cursor: look at it on a real mouse, consider scaling above 1080p. (6) Item 6 loop. No clips exist yet for anything that moves. Calls for the owner so far: the hanging weapon wall at x2 (needs a longer board than the 18 m hub); the Madness bar kept under the avatars.

## Iteration 6 (2026-11-09, from 21:14)

- 21:20 Film kit in my tree (not committed): `gtai-n11/tmp/combat/probe.sh on|off` puts the tools lane's `FilmProbe` and the one hook line in and takes them out; it must be off to commit (debt ratchet) and for gates. With it on: `node ../n11-tools/tools/film/film.mjs weapon:<id> --tree=. --out=<dir> --ticks=900 --on=fire:1+6,kill:1+14 --no-movie`. Serves the iteration 2 `REQUEST tools:` line: one run per weapon, about 25 s. Contact sheets: `tmp/combat/vsheet.py <filmdir> <out.png> [crop] [scale] [cols]` (kill frames round the victim).
- 21:27 All 13 weapons filmed, fire and kill, 48 px/m, city, `film/<id>/`.
- 21:30 MILESTONE a defect nobody had seen, and the likeliest source of the owner's "size gets increased": at combo every near corpse was DRAWN TWICE, a navy fall frame and the light-blue lying pose on the same spot. Seen in the machine pistol and pistol kill sheets, 10 ticks after each kill, the two bodies in the same relation.
- CAUSE: `ViewPitchEase` runs `ViewPitchCards.dress` every frame at combo, and it set `card.self_modulate.a = 1.0` on a card `StreetDeadPlan.draw` had just hidden. Only combo runs that pass, so tilt70 and top never showed it. How I got there: a sprite dump over the corpse showed the card at alpha 0 when written; the write after it was the only remaining suspect. Red first `test_view_pitch_dead_card` (2 of 3). Fixed `a9849869`. Before/after, same tick: `corpse_double_ab.png`, `corpse_double_pistol_ab.png`.
- This also corrects iteration 1: `LYING_K` 0.72 was judged on doubled bodies. With one body per corpse it may now be too small. NOT re-measured yet.
- 21:33 CAUSE (blood reads as square chips): `BloodBatch.drops` drew each drop in the air as one `draw_multiline` bar, square-ended. Now two crossed bars for the head, a neck and a thin tail, antialiased, still bucketed by width (`0942f011`). `blood_drop_ab.png`. No riot frame measurement yet: UNMEASURED, it writes up to 4x the segments.
- DECISION corpse shirt: `dead70_cop_patrol.png` was lighter and greyer than the falling cop (median 72,97,119 against 51,65,97), a shade jump at the hand-over. Retoned only the uniform blue with `tools/art/dead70_shirt_tone.py` (idempotent), provenance line updated. Rejected a tint on the sprite: it darkens the skin too.
- 21:38 Unit on `0942f011`: 2231 tests, 0 failures.
- ANSWER to hero's `REQUEST combat:` (contact shadow and `PlayerScale`): my ellipse takes `RigCastShadows.hip_px(rig)`, which reads the `CAST_HIP` meta the hero lane publishes from the drawn height, so it should follow the 1.5 size with no change here. Not confirmed in a frame on a merged tree.
- `--feel=off` is in every film the kit makes: no hit-stop, no shot trail, no shake in those frames. Judge those on a run with feel on.
- 21:46 CAUSE (the black bar beside every body): `FxGround` draws `CombatArena.rifle_drops` as one 0.8 m ink line at a fixed angle, labelled placeholder in its own file header. Every non-boss kill adds one, so the arena and the city get it too, not only quest 1. My iteration 1 critique called these "dropped rifles", without finding where they came from. Now `GroundRifle` (`e96d52e1`): one mesh, 1.05 m, beside the body, turned by the spot, culled at 24 m. `ground_rifle_ab.png`.
- 21:50 Shirt tone committed `33f6e7a5`, seen in the game frame (same pair): the shirt is now the falling cop's navy.

CRITIQUE (kills and shots, hostile pass on the 13 weapon films, all shot BEFORE the fixes above except where a crop says otherwise):
- The rifle is a code drawing at 3x: it reads as a gun, but in this frame it lies half under the legs, and it is the same gun for a cop who was holding a pistol. `BESIDE_M` is sideways from the gun, not away from the body, which the drop does not know.
- The blood is better but now reads as round blobs of one size. No fine spatter, no streaks along the blow in flight.
- Fall to lying is still a pose pop at about 10 ticks: the arms and the head jump. The colour no longer does.
- The hand cannon's blood is one hard red star shape, drawn flat. It looks stamped on.
- Rocket blast debris: grey quads with an ink edge, they read as paper squares.
- Blast victim stands upright inside the fireball for several ticks, with three round red beads on him.
- Energy rounds have no colour of their own: the plasma comet is a charcoal needle like a bullet. Colour law leaves little room; owner call weapon-art-3 from 2026-11-04 is still open. Goes to Calls for the owner.
- Electro: the X-ray skeleton and the standing cop alternate after the flash. Not judged at speed, could be intended strobe from the approved brutality night.
- All of this is from stills with `--feel=off`. Nothing here was watched moving, and no clip exists yet.

NOT DONE (item 5 and before): reactions on a hit that does NOT kill were not filmed at all (the lone guard dies to the first hit or two). Shadows on vehicles and buildings under `cast_k` 0.35 unjudged. Quest 1 and the far crowd's baked corpses: still no live frame. No riot frame cost measured for the 4x drop segments or the rifle meshes. Reel gate and `tools/evidence/run.mjs` have still never run on this branch.
REQUEST assets: a guard's rifle lying on the ground, seen from the 70-degree combo camera: 8 headings (or 3 plus mirrors), plain matte gunmetal and worn wood in the game's ink style, no brand or real maker, about 256 px long on a transparent background, one sheet. Put it under `keyed/props/ground_rifle_70/`. It replaces the code drawing `features/combat/weapons/art/ground_rifle.gd`.
REQUEST assets: hit and death cells for the patrol cop at 70 degrees, 8 facings, about 192 px tall on the fall grid's layout (`art/view/p70/cop_patrol_long_fall.png`): 3 cells of a flinch from a shot (chest, shoulder, gut), and 2 in-between cells from falling to lying, so the hand-over to `dead70_cop_patrol.png` stops popping. Put them under `keyed/street/cop_patrol_hit_70_cells/`.
- 22:07 Gates on `33f6e7a5`: unit 2236 tests, 0 failures, exit 0; lint 15/15 (the commit hook). Scenarios: the run on `0942f011` ended at 21:45, but my `tail` kept only exit noise, so that verdict is LOST, not green. A second run on `33f6e7a5` was started at about 21:57 and had not finished at 22:07. Verdict file, if it finished: `gtai-n11/tmp/combat/gates_it6b.txt`. Treat scenarios as NOT RUN for this iteration unless a later line says otherwise.
- FRICTION: `run_scenarios.gd` took more than 10 minutes on the shared machine tonight, and nothing shows progress. Piping it through `tail` loses the verdict; send it to a file and grep `run_scenarios:` (printed to stderr).
- FRICTION: to film my own uncommitted tree with the kit I had to add the probe by hand, and the debt ratchet then failed the commit. `probe.sh off` before every commit, `on` to film.

NEXT: (0) Read `gtai-n11/tmp/combat/gates_it6b.txt`; if it has no `scenarios exit` line, run the scenarios to a file before anything else. The probe is OFF at the end of this session. (1) Owed gates, never run on this branch: `tools/evidence/run.mjs`, the reels `--views=top,tilt70,combo`. The corpse fix changes every combo frame with a body, so look goldens will likely move: re-bless once, deliberately, with a dated line. (2) A riot frame cost under the bench lock for the 4x blood segments and the rifle meshes; both are UNMEASURED. (3) Item 5 reactions: film hits that do NOT kill (`--bot=pit --horde` at feel on), direction, flinch, stagger; the `REQUEST assets:` cells feed this. Also the fall to lying pop. (4) From the critique, in order: fine blood spatter and streaks, the hand cannon's stamped red star, blast debris quads, the victim upright in the fireball. (5) Re-judge `LYING_K` 0.72: it was chosen on doubled bodies. Measure alive and dead in one frame now there is one body. (6) Shadows on vehicles and buildings; quest 1 and far-crowd corpses in a live frame; first clips of anything moving: every judgement tonight is from stills. (7) Calls for the owner so far: the hanging weapon wall at x2; the Madness bar under the avatars; an accent colour for energy rounds (weapon-art-3, plasma reads like a bullet).
- 22:10 CORRECTION to the 22:07 line and NEXT (0): the scenarios on `33f6e7a5` finished: 55 ran, 0 failed, exit 0 (`gates_it6b.txt`). So lint, unit and scenarios are green on the last code commit. Evidence run and reels are still owed.
