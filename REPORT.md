# REPORT - lane motion (n24, 2026-11-22) - DRAFT, finished at 01:40

Branch `n24-motion` in `C:\Users\kazda\kiro\gtai-wt\n23-controls`, cut from `main` `b3f4727c0`. Owner notes 8 ("Rivet is
now flying instead of using his legs") and 4b (dash on Shift). Films and stills:
`C:\Users\kazda\kiro\gtai-masters\n24\motion\` (`frames.json`, best first).

Gate: TODO `node tools/gate/run.mjs --rev=HEAD` line + `gate.json` path.

## What works

| Item | Evidence | Number |
|---|---|---|
| Slide confirmed on main | `evidence/n24-motion/slide_before.md`, `before/legs_32.mp4` | gloria, rocket_launcher, assault-rifle, chainsaw, electro_baton held one card (boot drift 2.39-2.41 m per second = the whole travel); bare hands and the five drawn weapons stepped. Second cause on hands: run frames hold 13-14 ticks (67 cm in-drawing excursion at 64 px/m) |
| Nothing slides: every weapon walks and runs (`8b5f4d96e`) | `evidence/n24-motion/slide_after.md`, `project/tests/unit/test_rivet_walk_every_weapon.gd` | every `rivet_arsenal.json` id gets a non-empty walk and run grid; a weapon without its own grid walks on the bare-claw legs with its held part on the painted palm (`rivet_motion.json` `walk_grid`) |
| Drawn grids, p70 | `evidence/n24-motion/grid_gloria.md`, `grid_rocket_launcher.md`, `grid_chainsaw.md`; `legs_game_32.mp4` | gloria `d50add33b` (walk cycle 86.7 cell px, RUN_ROW_K 0.98/0.97/0.92, sole drift walk 1.1 cm run 4.6-5.8 cm); rocket_launcher `4a8cfd7d4` (ARMED_CYCLE_CELL 84.0, RUN_ROW_K 0.91/0.94/0.93); chainsaw TODO; electro_baton TODO |
| Dash on Shift (`9f4ce27a9`, `099db00f4`) | `evidence/n24-motion/dash_dodge.md`, `dash_rocket_32.mp4`, `dash_chase_32.mp4` | 4.5 m in 10 ticks, cooldown 40 ticks, 0 i-frames; rocket at 5/8/12 m cleared by +1.30/+1.41/+1.41 m after a 15-tick reaction (standing: hit, 10 HP); war machine stomp cleared at 1.8-3.5 m; closes 10 m on a fleeing cop (3.2 m/s) in 0.95 s vs 3.02 s running |
| Dash trail (`b364b48e6`) | `dash_afterimage_64.png` | posed run-card copies in Rivet's own warm colours, no teal |
| `dashes` per gauntlet wave (`ca2ada5f2`) | `project/data/schemas/gauntlet_run.schema.json` | counted dash starts; omitted when unmeasured |
| Tapes byte-identical | dash wire bit 31, dash state written only once a dash was used | TODO quote unit/scenario/replay numbers from the gate |

## What does not
- p55 (tilt 55) grids stay on the fallback for every new weapon (gloria's p55 candidate drifted 9.1 cm walk / 18 cm run).
- TODO weapons still on the fallback at the freeze.
- `dash_take` / `legs_film` scenes are not in the repo yet (brief 04): TODO.

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
- TODO

## Astra ledger

| Call | Minutes | Result |
|---|---|---|
| legs (01) | 66 | accepted |
| dash (02) | 1 | bounced: schema bit cap |
| dash resume (02b) | 71 | accepted |
| grids (03) | 72 | accepted (gloria p70) |
| grids resume (03b) | TODO | TODO |

What I would brief differently: name the game-speed film in the first brief (the first films were a lab board); fill the input schema maxima in the dash brief.
