# REPORT - n17 npc-react (DRAFT, iteration 6, 23:00; finished at 07:40)

Branch `n17-npc-react` from `int-n16` `87be8c7df`. Evidence: `C:\Users\kazda\kiro\gtai-masters\n17\npc-react\` (`frames.json`). Defects list: `DEFECTS.md`. Log: `JOURNAL.md`.

## What works (with its number)

| # | Owner's defect / brief item | Before -> after (measured) | Commit | Evidence |
|---|---|---|---|---|
| 1 | "Policemen are changing sizes on hit": thrown-back hit grids | 1.05-1.23 x the walk's height -> within 0.4 % (12 kinds, `street_hit_size.py --check`) | dd0bf749b | lineup build/m/lineup_after.png |
| 1 | the cops' pistol snap death (n16 own cells) | first frame 1.2-1.3 x and 0.12-0.32 m low -> walk size on the point | 48b27b933, da6a10d9c, 5ca55758c | d1_*_pistol_death_ab_64ppm |
| 1 | machine pistol stitch, gatling shred openings | head ~38 / ~35 px -> ~30 px (walk ~30) at 64 px/m | baa4079ba, 90536a561 | d1_stitch_*, d1_gatling_shred_* |
| 1 | baton overload, nail pin, claw throw openings | 1.1-1.3 x (nail pin cap ~30 -> ~36 px) -> at the walk | 0736a54f7, 195ec32ad | d1_baton_overload_*, d1_nail_pin_claw_throw_* |
| 1 | own-cell deaths' colour pop (SWAT, riot) | SWAT value x0.56-0.76, riot hue +11..+18 deg, SWAT helmet grey-violet -> walk blue | 349703b72, db7bb404d | d4_rig_order_kill_tick_double_and_tone_* |
| 2 | "Dead bodies are moving after killed" | rocket gibs' turning tail +56..+150: 127 -> 1 changed px | 8887337c4 | d2_rocket_gib_rest_spin_ab |
| 3 | "Weapons after kill are not wrapped in showcase" | lying-rifle sheet, heading hashed from position -> WeaponShowcase drawing, muzzle along the shot, latched spot | 068c2c937, 439416663, bcc952e70, 0a655d597 | d3_drop_* |
| 4 | hit -> first reaction frame | katana wound: 3 ticks -> 1 (hit_now) -> 0 (rig order); kill tick: two figures -> one | 82520c012, 0f9081b17 | d4_wound_on_hit_tick, d4_rig_order_* |
| 5 | every hit class reads differently | melee/shock wounds were one shoved walk -> jab / heavy / shock cells for cops, thug and nine peds (hat, elder, shopper: no shock drawn) | a2ee5b849, b537d056a, 7a362d1d4 | d5_* |
| 5 | a living knockdown | upright, then popped lying -> standing -> falls in ~5 ticks, lies, gets up through the fall grid | c3b1e746f, 6fc1166b9 | d5_knockdown_* |

## What does not (open)

- DEFECTS 7b: katana/chainsaw halves slide ~60 ticks (GibSim linear drag: sim, a Call).
- DEFECTS 8: the snap corpse lies ~1.15-1.25 x the walk's bulk (owner n11: bodies keep their length; a Call).
- DEFECTS 13: fitted and filmed at 64 px/m; the 32 px/m pairs are still to film.
- The kill lab's ped victim walks as a navy cop body (lab only): ped class-cell films pop costume against a walk he never has (REQUEST tools).
- DEFECTS 17/18: the gatling shred's feet ~0.23 m high (the track's lift); the walk's ground shadow vanishes on an own-cell kill tick.

## Calls for the owner

(to be filled with 32 + 64 px/m before/after per change)

## Merge notes

- `RigTickOrder` (0f9081b17) sets the arena/quest-1 World's process_priority to -2: the rig feed reads the frame's own sim tick. View order only. `--rig-order=before` is the old order.
- Re-packing the n16 own cells (`kill_cells_pack.py`) must be followed by `tools/art/kill_cells_tone.py --write`.
