# REPORT: ghost-powers lane (branch `n6-ghost-powers`), night 2026-11-04/05 (DRAFT, iteration 2)

`M` = `C:\Users\kazda\kiro\gtai-masters\n6\ghost-powers`. `E` = `evidence/` in this worktree.
(This file replaces n5-cast's REPORT that arrived with the n5-cast fast-forward; take n5-cast's on merge.)

## What works (with evidence)
| Claim | Evidence |
|---|---|
| **Tonnage** (from Hauler): plates take 0.3 of every hit; the press slam after a 0.5 s telegraph (a teal-edged die-plate footprint) lands 0.9 m ahead, flattens humans within 2 m (new signature style `crush`), throws the 4 m ring, wrecks every car within 3.4 m, cracks the street; the ram throws its kill aside | `M/tonnage-arena-32ppm.mp4` (16 s: 10/10 down, 2 slams, 2 cars), `M/tonnage-slam-64ppm-halfspeed.mp4`, `M/frames/tonnage-slam-vs-target-64ppm.png`; `E/ghosts-tonnage-32.json`; unit `test_tonnage_attacks` |
| Dent's car bomb: amber ink-rimmed fireball (before: a pale disc) | `M/frames/dent-blast-ab-32ppm.png` |
| **Dent** (from Gearbox): G seizes the car nearest the aim line (teal tether, soul plate), the car drives where Rivet aims and throws whoever it hits, heats amber to white, blows on impact once armed (car-bomb gib); walls stop it | `M/dent-arena-32ppm.mp4` (5/5 down), `M/frames/dent-vs-target.png`; `E/ghosts-dent-32.json` |
| **Kerf** (new): Q takes the soul (walk x1.5); melee blinks along a straight teal line to behind the target in a 35 deg cone (9 m, clear line) and slices it: humans one-shot (split with a teal-white cauterised edge, new row field `edge: soul`), robots 4; no target = a 4 m dash; chain of 3, one charge back per 1 s; the cut line hangs 0.6 s | `M/kerf-arena-32ppm.mp4` (5/5: 4 split, robot in 2 cuts), `M/kerf-64ppm-halfspeed.mp4`, `M/frames/kerf-vs-target.png`, `M/frames/kerf-beat-32ppm.png`; `E/ghosts-kerf-32.json`; unit `test_kerf_attacks` 3/3 |
| **Ohm** (new): Q takes the soul; melee throws a forked teal bolt from the fingertips every 0.5 s (30 deg, 11 m, 2 forks within 3 m), each body stunned 1.2 s, humans 0.5 (electro X-ray kill), robots 6 (machine_k 3), cars burn 20 per bolt; mass arc = upgrade_tier 1 data hook | `M/ohm-arena-32ppm.mp4` (5/5 + cruiser wrecked, Rivet untouched), `M/ohm-64ppm-halfspeed.mp4`, `M/frames/ohm-vs-target.png`; `E/ghosts-ohm-32.json`; unit `test_ohm_attacks` 2/2 |
| Determinism: all four beats replay identically and give one state per seed; planted faults (Tonnage crush_m 0, Dent blast_damage 0, Kerf human_damage 0, Ohm machine_k 0) are caught | `scenario_ghost_attacks` -> `E/ghost-attacks.json`, `E/scenario-ghost-attacks.log` |
| Roles and TTK table | `docs/ghosts/ghost-attacks.md` |
| Gates (iteration 2 head): lint 13/13 on every commit; unit 960/0 (ef3a186a); scenarios 47 ran / 0 failed (incl. scenario_ghost_attacks, four ghosts); director reel 16/16 chapters down, 0 script errors (after the split-edge change) | `E/unit-it2.log`, `E/scenarios-it2.log`, `E/director-reel-it2.log` |
| City block: Kerf (4/5 of its beat; the chain also cuts the block's own cops) and Ohm (5/5 + car bolts) in `--arena=city` | `M/kerf-city-32ppm.mp4`, `M/ohm-city-32ppm.mp4`, `M/frames/kerf-ohm-city-32ppm.png`; `E/ghosts-kerf-city-32.json`, `E/ghosts-ohm-city-32.json` |
| The reel of all four attack sets (40 s, labelled) | `M/ghost-attacks-reel-32ppm.mp4` |
| Ohm's bolt heavier for game zoom (before / after, same tick) | `M/frames/ohm-bolt-ab-city-32ppm.png` |
| `--gore=reduced`: Kerf's victims fall whole (0 signature kills); `--reduced-motion`: no afterimages, no flicker | `E/ghosts-kerf-reduced-32.json`, `E/kerf-reduced-run.log` |

## What does not work yet
- The ghosts still use base Rivet's body in my clips (the forms lane's bodies merge in; their StagePilot hookup is REQUEST 2).
- No robot fighter exists in the arena: Kerf and Ohm hit the quest boss's brain as a stand-in (drawn as a cop, dies with the standard red splat; Ohm's beat holds it exposed). The robot numbers are real, the robot look is not.
- Dent's 64 px/m camera does not follow the car (the strikes and blast leave the close-up frame).
- Tonnage and Dent have no city-block clip yet. Under `--gore=reduced` Kerf's victims take the standard death, which leaves a red pool (odd for a cauterising beam; the death pipeline is shared and approved). Kerf and Ohm take Q only when the reel sets them (the forms lane's switch selects them later, REQUEST 3).

## Calls for the owner
- Ohm's bolt colour: teal (the souls rule, built) vs the target sheet's cream-yellow bolts: `M/frames/ohm-vs-target.png`. One constant (`OhmView.TEAL`).
- Kerf's slice: only the target is cut (assassin) vs every body on the blink path (crowd tool): built as target-only.
- (to come: the Tonnage crush vs the standard pile at 32 px/m, with a side-by-side)
