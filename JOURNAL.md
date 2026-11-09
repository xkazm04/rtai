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
