# REPORT - lane cast, run n28 (2026-11-24)

Branch `n28-cast` from `main` `d0ab9d03a`, worktree `gtai-wt/n23-prologue`. Director: Claude Opus 5.5. Builder: Claude
Sonnet 5.5 through `gtai-n28/tools/builder.mjs` for the first two calls; from 18:04 the builder account was out (weekly
limit, all lanes), so every later call was an **in-session Sonnet subagent** directed by the same brief files (DECISION
18:05 in `JOURNAL.md`). Owner's order: gunner A on, door carrier and pile-driver feet + the impact-outline check, the
contractor (white hat, pale lemon vest, 8-drawing walk), robot thug A. Films and stills:
`C:\Users\kazda\kiro\gtai-masters\n28\cast\` (`frames.json` there, best first). IMAGES 2/25 (both gunner fall edits).

**Gate: not green on a finished run.** The final gate on `becf3bf68` (code = `35485d368`) ended `gate: UNVERIFIABLE; build/gate/becf3bf68208/gate.json`: it was killed at its 45 min timeout (23:31) after waiting on `mem-budget` at the start, with scenarios 68/68 ok in its log and the run parked in the CONTENDED re-run wait for rig_stress; lint, unit, parity, selftest and export-audit wrote no result. The builder's direct runs on `35485d368`: unit 4211 passed 0 failed, scenarios 68 passed. A re-run, `node tools/gate/run.mjs --rev=a6a9ab234 --timeout=60` (inert docs on top of the same code), started 00:11 on a quiet machine (2.2 GB used), detached: its verdict lands in `build/gate-final2.out` and `build/gate/a6a9ab234*/gate.json` after this session ends (~00:40). The Director reads it before merging. No `--reels` run: it does not fit before 00:40.

## What works

| Item | Evidence | Number |
|---|---|---|
| **Robot gunner A card ON** (`dc4064265`; fall cells body only `4960c33d6`; p70 chest rifle removed `cacff1b4b`; p55 hand rifle removed `913de450d`) | `gunner_close_64.mp4`, `gunner_fight_32.mp4` (1920x1080, 60/1, 20.0 s each), `gunner_beside_64ppm_tilt70.png`, `gunner_rim_64.png`, `gunner_fall55_64.png`; audit rows "Robot gunner A, n28" in `docs/art/cast-audit.md` | live 64 px/m rim 0 on walk, attack, hit, fall (70 and 55); ink runs 1-2 px (70) / 1-4 px (55) vs patrol 3,3,4 / 3,3,3; shadow toggle 210-243 px (bar 150-350); lens tell 0.9 s before the first round; one rifle at every rest (the game's pickup) |
| **Door carrier walk on an anchored placement** (`89ac6ff8f`, test re-pin `bc3c1ceea`, film tool `5efc41081`), shipped four drawings, no new art | `feet_door_before_after_64ppm_tilt70.png`, `feet_door_32.mp4` (1920x1080 60/1 25.8 s) | body jump 13.29 -> 5.51 (70 R), 11.95 -> 5.93 (55 R), 13.23 -> 10.82 / 11.80 -> 9.82 (down-right), bar 12 PASS; sole slide 7.35 -> 5.74 (70), 6.64 -> 3.98 (55), bar 2 still FAILS (see below) |
| **Impact-outline check** at 64 px/m, flash on / off, seven cards (`36da28e80`) | `impact_edge_64.png` | dark px outside the silhouette, pulse / calm: patrol 1/0, riot 6/0, SWAT 7/0, lancer, door, warden, gunner 0/0 (Mulroney was 354/462 before n27's fix): no teeth anywhere |
| **Contractor cut and wired** (`930b3b9f3` ten sheets both pitches, hat toned off-white; `c6792df55` row + anchors; `cd738c9a6` card path test; `337bb3144` WALK_STEP_M 0.30; `5df931099` transitions; `33adcae5c` checklist) | `contractor_beside_64ppm_tilt70.png`; audit "Contractor, n28" tables | 10.00 drawings/s at 3 m/s; sole 0.00 px; jump 3.7-9.6 px over walk/stop/turn/reversal; hat S 0.05-0.08 V 0.86-0.90; vest hue median 45.8-51.0; shadow 159-284 px; 56/58 px at 32 px/m 70 (patrol 43/44, Rivet 77/73) |
| **Contractor card ON** (`b813492e4` attack/hit cells padded like his walk; `35485d368` row on, test flipped, decision line, fight scene + film tool) | `contractor_close_64.mp4`, `contractor_fight_32.mp4` (1920x1080, 60/1, 20.02 s each); audit "Contractor, n28" tables and "live height vs the lineup" (`7a4e3ee45`) | size jump fixed: 64 px/m 70 stand 86, tell 63 -> 85, fire 64 -> 86, hit 55 -> 82; 55 stand 88, tell 66 -> 88, fire 68 -> 91, hit_1 53 -> 83 (-5.7 %, a drawn flinch, accepted), hit_4 66 -> 87; calm rim 0, flashed rim 289 / 403 (lancer 482 / 596), fall cell 0 604 / 720 (lancer 1161 / 1079); one rifle (the pickup) at every rest, 3 bodies / 3 rifles in the fight; unit 4211 passed, scenarios 68 |

## What does not

- **Pile-driver feet: not wired** (`6664ed8f8`): at p70 one pad tilts twice and the other never lifts, so no sole table can
  carry a ground point; sole/jump unchanged (p70 unmeasurable / 17.8 px, p55 29.1 / 11.9). Needs a redrawn walk with an
  exchange of support (new art).
- **Door carrier sole slide 4-6 px** (bar 2): the shipped four-drawing walk has two contacts with different drawn advance; the
  anchored placement halves the body jump but cannot plant both. Needs an 8-drawing door walk (new art).
- **Robot thug A: not started.** Brief ready: `evidence/briefs/n28-cast-04-thug.md` (with the "Added" lessons).
- Mutate: no score on `foe_gunner_card_view.gd` or `cast_door_anchors.gd` (both runs cut at their 10-13 min budget).
- **The contractor beside still is not the live game** (`contractor_beside_64ppm_tilt70.png`, from `project/dev/cast/cast_contractor_lineup.gd`): it shows him 111 px against the patrol cop's 87 at 64 px/m; the live close film measures him 78-88 against the spawned cop's 112 (Rivet 149 in both). Cause not found (likely card vs rig path in the lineup); do not quote that still for size.

## What blocked or slowed you (minutes each)

- **Memory cap, 40 min** (16:21-17:01): the first builder call died (0xC0000409) when the run passed 8 GB (peak 9082 MB);
  pose launches then waited 30 min on `mem-budget: waiting` and one died with 0xC0000005.
- **Builder account out, ~20 min** (17:45-18:05): `builder.mjs` hit the weekly limit for every lane; switched to in-session
  subagents.
- **quick.mjs cascade, ~10 min**: `quick.mjs --files=<characters/*.gd>` fails with ~200 "Failed to compile depended
  scripts" even on `death_pose.gd` (unchanged since main): environment, not this branch; GUT and the hook pass.
- **A test missed by a call, 10 min**: `test_cast_door.gd:40` went red in `89ac6ff8f` (the hook does not run GUT); re-pinned
  in `bc3c1ceea`. Since then every brief requires `run_unit.mjs --changed` quoted in the report.
- **Builder claims vs frames, ~30 min**: twice a call reported "one rifle at the rest" when the frames showed two (the drawn
  fall rifle and the game's pickup); found by looking at the films myself.

## Calls for the owner

1. **Contractor height beside a live patrol cop**: in the game he draws 78-88 px at 64 px/m (39-44 at 32), the checklist's
   patrol reference (43 / 45 at 32, the card measure), but the spawned patrol cop is a full rig at 112 px, so beside him the
   contractor reads 0.70 of the cop (`contractor_close_64.mp4`, 3-9 s). Keep, or scale his card up toward the rig cop (one
   value)? The same may hold for every card foe beside a rig cop (not measured tonight).
2. **Door carrier and gunner take no hit-flash tint** (their impact row is 0 by construction): add a flash for readability,
   or keep the plain hit drawing?
3. **New walk art** for the door carrier (8 drawings: sole 4-6 px today) and the pile-driver (an exchange of support), and
   the **war_machine** card, which is `enabled: true` on main with a walk that fails the feet bar.
4. **Flashed-cell rim bar** (DECISION 22:03): cells drawn while the shared hit flash is lit are judged against the shipped
   lancer (hit 482 / 596, fall 1161 / 1079 dark px), not 0; the flash's dark halo itself is a combat-lane look question.

## Merge notes

- Owned files only: `cast_cards.json` rows (gunner on, contractor on), `project/features/characters/cast_*`,
  `project/features/combat/squad/foe_gunner_card_view.gd` (n27's file), `project/dev/cast/**`, `tools/art/cast_*`,
  `tools/film/cast_*`, `docs/art/cast-*.md`, tests `test_cast_*`. Quest 1's `contractor_hit/fall.png` are untouched (his
  card ships `contractor_cast_hit/fall.png`).
- Shared appends: `docs/decisions.md` (gunner on; contractor lines), `tools/debt/baseline.json` (dev_loc accepted twice through
  the debt tool: door feet, contractor feet scene). Root `JOURNAL.md` / `REPORT.md`: keep this lane's on an add/add conflict.
- **NEED Director (keys/weapon art)**: the GroundRifle pickup (`ground_rifle_70.png`) reads mauve-pink on asphalt in the
  1080p films (43 px with R > G+60 and R > B+40 in a 90x40 crop at 64 px/m; partly yuv420 chroma): a lossless check and a
  browner stock by its owner ("red is blood only").

## Next steps

1. Robot thug A: `evidence/briefs/n28-cast-04-thug.md` (gunner model; check existing `robot_thug_*` names before writing).
2. New walk art (owner's pick): door carrier 8 drawings, pile-driver exchange of support, war_machine.
3. Mutate scores for `foe_gunner_card_view.gd`, `cast_door_anchors.gd`, `cast_contractor_anchors.gd` with `--tests=` and a
   budget.
4. Re-take the contractor lineup through the fight scene's spawn path and find why `cast_contractor_lineup.gd` draws him 1.35x and the cop 0.78x of the live sizes; then measure every card foe against the rig patrol cop.

## Builder ledger

| call | min | cost | verdict | what |
|---|---|---|---|---|
| gunner-on (builder.mjs) | 32 | n/a | abandoned | node died at the 8 GB cap; nothing committed |
| gunner-on2 (builder.mjs) | 40 | $0.49 | abandoned | weekly limit; pose frames rendered |
| gunner-fall | 8 | in-session | accepted | rim/shadow rows, p70 fall edit |
| gunner-films | 16 | in-session | bounced-partial | films + on; claimed one rifle, frames showed two |
| gunner-one-rifle | 7 | in-session | accepted-partial | fall cells body only |
| gunner-p55 | 14 | in-session | accepted | p55 hand rifle edit |
| door-feet | 16 | in-session | accepted-partial | anchored door walk; left a red test |
| door-pile-edge | 33 | in-session | accepted | door films, pile verdict, impact table |
| contractor-cut | 7 | in-session | accepted | ten sheets, hat tone |
| contractor-wire | 13 | in-session | accepted-partial | row off, anchors |
| door-test-repin | 6 | in-session | accepted | test re-pin |
| contractor-card1 | 2 | in-session | accepted | card path test |
| contractor-cadence | 7 | in-session | accepted | WALK_STEP_M 0.30 |
| feet-scene-commit | 2 | in-session | accepted | dev scene commit |
| contractor-check | 87 | in-session | accepted-partial | transitions + checklist; found the size jump |
| contractor-pad | 41 | in-session | accepted | padded fix, films, on |
| size-truth | 4 | in-session | accepted | live height vs lineup |

17 calls, about 335 minutes; 2 abandoned (cap, account), 1 bounced. In-session subagent costs are not metered separately.
Brief differently: require `run_unit.mjs --changed` from the first call (a red test slipped once); ask every film call to
measure each figure's height in the delivered film against its neighbours, not in a separate lineup (the lineup lied about
the contractor's size); keep each call to one checklist point when a measurement can fail, so a fail does not eat 87 min.
