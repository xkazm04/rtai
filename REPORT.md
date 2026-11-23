# REPORT - lane motion (n24, 2026-11-22)

Branch `n24-motion` in `C:\Users\kazda\kiro\gtai-wt\n23-controls`, cut from `main` `b3f4727c0`. Owner notes 8 ("Rivet is
now flying instead of using his legs") and 4b (dash on Shift). Films and stills:
`C:\Users\kazda\kiro\gtai-masters\n24\motion\` (`frames.json`, best first).

Gate on `441a8d5a3` (last code commit `789d67b1d`; later commits touch only JOURNAL, REPORT and briefs):
`node tools/gate/run.mjs --rev=HEAD` -> `gate: PASS; build/gate/441a8d5a36ed/gate.json` (lint 19/19 over 2052 files;
unit 3815 passed, 0 failed, 2 skipped; scenarios 67 passed; parity 1200 steps bit for bit, planted mutation caught at
step 629; selftest look goldens 11/11; export-audit 933 loaded, 0 failed).

Reels gate: `node tools/gate/run.mjs --rev=HEAD --reels` started 01:31 on `f223380ab` (inert commits only after the
gate above), log `build/gate-reels.log` (git-ignored). At 01:42 it had not reached its first kind (`build/gate/f223380ab3d2/evidence.log` not yet
written; the machine runs five lanes' gates): its verdict is NOT measured here; the Director reads the log's last line
before merging. Gate of record stays `441a8d5a3` above.

## What works

| Item | Evidence | Number |
|---|---|---|
| Slide confirmed on main | `evidence/n24-motion/slide_before.md`, `before/legs_32.mp4` | gloria, rocket_launcher, assault-rifle, chainsaw, electro_baton held one card (boot drift 2.39-2.41 m per second = the whole travel); bare hands and the five drawn weapons stepped. Second cause on hands: run frames hold 13-14 ticks (67 cm in-drawing excursion at 64 px/m) |
| Nothing slides: every weapon walks and runs (`8b5f4d96e`) | `evidence/n24-motion/slide_after.md`, `project/tests/unit/test_rivet_walk_every_weapon.gd` | every `rivet_arsenal.json` id gets a non-empty walk and run grid; a weapon without its own grid walks on the bare-claw legs with its held part on the painted palm (`rivet_motion.json` `walk_grid`) |
| Drawn grids, p70 | `evidence/n24-motion/grid_{gloria,rocket_launcher,chainsaw,electro_baton,assault_rifle,hand_cannon,machine_pistol}.md`, `grid_electro_baton_tone.png`; `legs_game_32.mp4` | gloria `d50add33b` (walk cycle 86.7 cell px, RUN_ROW_K 0.98/0.97/0.92, sole drift walk 1.1 cm run 4.6-5.8 cm); rocket_launcher `4a8cfd7d4` (ARMED_CYCLE_CELL 84.0, RUN_ROW_K 0.91/0.94/0.93); chainsaw `aa9c2bddb` (cycle 64.3, RUN_ROW_K 0.82-0.89, sole drift at 32 px/m walk 1.44 / run 3.89 cm mean); electro_baton `1990dddbb` + tone fix `b9a858c2d` (cycle 68.7, drift walk 4.02 / run 6.79 cm mean at 32 px/m; row tones even, mean RGB ~118/77/54 across turns, back-right sprint excursion 31 -> 19 px); assault_rifle `43e964b2c` (cycle 78.0); hand_cannon `0be2bb3e0` (cycle 69.7); machine_pistol `337f84d41` (cycle 73.7, walk drift 0.97 / 0.94 cm at 32 / 64 px/m); film `legs_game_32.mp4` 38.03 s 1080p60 with all seven, fallback beside drawn at the same tick |
| Dash on Shift (`9f4ce27a9`, `099db00f4`, tests `2c5b726b2`, `789d67b1d`) | `evidence/n24-motion/dash_dodge.md`, `dash_rocket_32.mp4`, `dash_chase_32.mp4` | 4.5 m in 10 ticks, cooldown 40 ticks, 0 i-frames; rocket at 5/8/12 m cleared by +1.30/+1.41/+1.41 m after a 15-tick reaction (standing: hit, 10 HP); war machine stomp cleared at 1.8-3.5 m; closes 10 m on a fleeing cop (3.2 m/s) in 0.95 s vs 3.02 s running; mutate `player_motion_dash.gd` 20/20 (was 15/20) |
| Dash trail (`b364b48e6`) | `dash_afterimage_64.png` | posed run-card copies in Rivet's own warm colours, no teal |
| `dashes` per gauntlet wave (`ca2ada5f2`) | `project/data/schemas/gauntlet_run.schema.json` | counted dash starts; omitted when unmeasured |
| Tapes byte-identical | dash wire bit 31, dash state written only once a dash was used | gate scenarios 67 passed (incl. the 60 s replay), parity 1200 steps bit for bit; no file under `project/tests/golden`, `scenarios`, `parity`, `saves` or `native/` differs from `b3f4727c0` |
| Mutation, `rivet_walk.gd` (after the gate, HEAD `441a8d5a3`) | `build/mutate-rivet-walk.log` (git-ignored) | 78.9 % = killed 15 / (15 + survived 4), 1 invalid, 20 sampled of 114. Survivors: the `armed` static default (line 82, tests set it), two boundaries on the moving threshold and the dip age (lines 88, 93: equal-value edges no test pins), `frame_of`'s `n - 1` clamp (line 156: unreachable while `fposmod < 1.0`, equivalent) |

## What does not
- p55 (tilt 55) grids stay on the fallback for every new weapon (gloria's p55 candidate drifted 9.1 cm walk / 18 cm run).
- On the fallback legs at p70 (they step, holding the thin held part, no slide): electro_gun, homing_shard, mini_nuke, molotov, plasma_sword, ray_gun. Drawn at p70: pistol, plasma_rifle, katana, gatling, flamethrower (shipped) + gloria, rocket_launcher, chainsaw, electro_baton, assault_rifle, hand_cannon, machine_pistol (tonight).
- The bare walk8/run8 body under the fallback is lighter and redder than the armed cards: a tone jump on start/stop for the six weapons above.
- The scenes that rendered the owner's films (`dash_take`, `legs_film`) are not in the repo: archived beside the masters in `capture-source/` (brief 04 item 2, skipped for time).

## What blocked or slowed you
- Brief 01 (legs) 66 min for one film pass and one rule; the first films ran a lab board at 2.4/3.2 m/s, not the game (re-filmed in the arena at 6.75/9.3 m/s).
- `tools/gate/quick.mjs` red on every file (`--check-only -s` registers no autoloads: `Log`, `LaunchArgs`), ~15 min.
- Image generation ~8 min per job, ~70 min per weapon at p70.

## Calls for the owner
- Dash trail strength: faint afterimage (`dash_afterimage_64.png`). Stronger first copy is one table value.
- Shift = dash, and holding Shift after the burst keeps the 9.3 m/s sprint (`rivet_motion.json` `dash.hold_sprints`; false = burst only).
- Tilt 55 on the fallback held part for the new weapons, or draw p55 too.

## Merge notes
- `input_actions.json`: `dash` row bit 18 / wire bit 31; ghost's `ghost_deploy` bit 19 / wire 32; schema maxima 19 / 32 identical to ghost's `d07607db6`; `TickInput` mask `& 0xFFFFFFFFFFFF` identical one-line edit.
- NEED ghost (open): `project/boot/collect_call/stage_pilot.gd:134` writes buttons with `put_32`, so wire bit 32 is not in that digest field.
- pressure merged `n24-motion` at `b0a9c4c09` (head `6ab9195d2`).
- Root `JOURNAL.md` / `REPORT.md`: add/add, keep each lane's own.

## Next steps
- Per-weapon stride numbers (`RUN_ROW_K`, `ARMED_CYCLE_CELL`, `WALK_PROFILE_TRAVEL`) out of `rivet_walk.gd` / `rivet_stride.gd` into a `grid_stride` block of `rivet_motion.json`, and restore the doc comments squeezed out to stay under 200 lines (brief `evidence/briefs/04-dash-close.md` item 0; deferred: too late for a safe change before the freeze).
- Draw the remaining six p70 grids (electro_gun, homing_shard, mini_nuke, molotov, plasma_sword, ray_gun), then p55 for every tonight weapon (~40-70 min each with image generation).
- Dash trail: a stronger newest copy behind a `rivet_motion.json` value if the owner asks (brief 04 item 4).
- Re-check the hand's run frames hold (13-14 ticks per frame, some in-step slide) found in step 1.

## Astra ledger

| Call | Minutes | Result |
|---|---|---|
| legs (01) | 66 | accepted |
| dash (02) | 1 | bounced: schema bit cap |
| dash resume (02b) | 71 | accepted |
| grids (03) | 72 | accepted (gloria p70) |
| grids resume (03b) | 54 | accepted (decision lines, rocket_launcher; chainsaw staged, stopped on a test NEED) |
| grids resume (03c) | 47 | accepted (chainsaw, electro_baton, assault_rifle, hand_cannon, six-weapon film, 19.4 GB scratch freed) |
| grids resume (03d) | 41 | accepted (baton tone `b9a858c2d`, machine_pistol `337f84d41`, film seven weapons, 10.3 GB scratch freed) |
| dashclose (04b) | 17 | accepted (mutate survivors killed, 20/20; film scenes skipped for time) |

What I would brief differently: name the game-speed film in the first brief (the first films were a lab board); fill the input schema maxima in the dash brief; give per-weapon calibration numbers a data table from the start (every new grid squeezed `rivet_walk.gd` doc comments to stay under 200 lines); resume one Astra thread per weapon family instead of one long thread (input tokens grew to 166 M by call 7).
