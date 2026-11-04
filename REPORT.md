# REPORT: ghost-powers lane (branch `n6-ghost-powers`), night 2026-11-04/05 (DRAFT, iteration 1)

`M` = `C:\Users\kazda\kiro\gtai-masters\n6\ghost-powers`. `E` = `evidence/` in this worktree.
(This file replaces n5-cast's REPORT that arrived with the n5-cast fast-forward; take n5-cast's on merge.)

## What works (with evidence)
| Claim | Evidence |
|---|---|
| **Tonnage** (from Hauler): plates take 0.3 of every hit; the press slam after a 0.5 s telegraph (a teal-edged die-plate footprint) lands 0.9 m ahead, flattens humans within 2 m (new signature style `crush`), throws the 4 m ring, wrecks every car within 3.4 m, cracks the street; the ram throws its kill aside | `M/tonnage-arena-32ppm.mp4` (16 s: 10/10 down, 2 slams, 2 cars), `M/tonnage-slam-64ppm-halfspeed.mp4`, `M/frames/tonnage-slam-vs-target-64ppm.png`; `E/ghosts-tonnage-32.json`; unit `test_tonnage_attacks` |
| Dent's car bomb: amber ink-rimmed fireball (before: a pale disc) | `M/frames/dent-blast-ab-32ppm.png` |
| **Dent** (from Gearbox): G seizes the car nearest the aim line (teal tether, soul plate), the car drives where Rivet aims and throws whoever it hits, heats amber to white, blows on impact once armed (car-bomb gib); walls stop it | `M/dent-arena-32ppm.mp4` (5/5 down), `M/frames/dent-vs-target.png`; `E/ghosts-dent-32.json` |
| Determinism: both beats replay identically and give one state per seed; planted faults (crush_m 0, blast_damage 0) are caught | `scenario_ghost_attacks` -> `E/ghost-attacks.json`, `E/scenario-ghost-attacks.log` |
| Roles and TTK table | `docs/ghosts/ghost-attacks.md` |
| Gates: lint 13/13; unit 954/0 on the merged head (38bcc40c); scenarios 46/0 (Tonnage head), final head see JOURNAL; director reel 7/7 chapters run headless all down | `E/unit-it1-merged.log`, `E/scenarios-it1.log`, `E/scenarios-it1-final.log`, `E/director-reel-it1.log` |

## What does not work yet
- The ghosts still use base Rivet's body in my clips (the forms lane's bodies merge in; their StagePilot hookup is REQUEST 2).
- No robot fighter exists in the arena, so no clip shows a robot victim.
- Dent's 64 px/m camera does not follow the car (the strikes and blast leave the close-up frame).
- Kerf and Ohm not started. No city-block clips yet. Director reel only 7 of 16 chapters checked.

## Calls for the owner
- (none yet; the Tonnage crush vs the standard pile at 32 px/m will be one, with a side-by-side)
