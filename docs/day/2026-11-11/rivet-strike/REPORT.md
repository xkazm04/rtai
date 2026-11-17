# REPORT - n17 rivet-strike (DRAFT, session 3; the final pass lands before 07:40)

Branch `n17-rivet-strike`, cut from `int-n16` at `87be8c7df`. Every change is render only and sits
behind its own before flag (CastFlags). No sim change: the replay and parity goldens are untouched.
Evidence: `evidence/n17-rivet-strike/` (same files and `frames.json` as `gtai-masters/n17/rivet-strike/`).
Defect log: `DEFECTS.md`.

Gates (session 4, 03b46390d, `evidence/run.mjs --no-bench --no-release`): lint 19/19, unit 2801 passed 0 failed, scenarios 55/55, parity bit-exact (mutation caught at 629), look goldens 11/11 + block 5/5 (worst 0.00): no golden moved.

Gates (session 2): `node tools/evidence/run.mjs --no-bench --no-release` on 8a47c51db: lint 19/19, unit 2786
passed 0 failed, scenarios 55/55, parity bit-exact, look goldens 11/11 and block goldens 5/5 (worst 0.00). Reel gate
on 690bfa2a6 (session 4): top, tilt70, combo OK. Planted faults: `rivet_thrust.gd` 75 % (6/8), `rivet_no_flash.gd` 77.8 % (7/9), `rivet_gun_diag.gd` 80 % (8/10); every survivor equivalent on today's data. Bench not run (CONTENDED machine; render-only lane).

## What works, with evidence

| Item | Commit | Before flag | Measured before -> after | Evidence |
|---|---|---|---|---|
| 1 HUD weapon slot (bottom right: showcase icon, `WEAPON__<id>` name, magazine) | bb09b7574 | `--hud-weapon=off` | none -> slot, cut swap, lifts over a subtitle | in game (quest 1, katana): `hud_slot_ingame_q1_t700_1920x1080.png`, `hud_slot_ingame_q1_t700_1280x800.png`; board: `hud_slot_1280x800_gloria.png`, `hud_slot_1280x800_rocket_launcher_line.png` |
| 2 lunge on the contact tick (`lunge_ticks`, katana_3 4, chainsaw_1 4) | 3abb72f83 | row without `lunge_ticks` | katana thrust: 1.25 m of 2.5 at contact + 1.04 m slid after -> 2.5 m at contact, 0 after | `test_melee_lunge_contact` |
| 2 strike lean about the feet (per weapon in `melee_weapons.json`) | 415dc9ad1 | `--rivet-lean=off` | upright -> katana/plasma 5 back / 9 in, baton 4/7, saw 3/6 | `katana_lean_strike_t64_32.png` |
| 2 strike cell planted (no gait bob on it) | fcd603180 | `--rivet-lean=off` | screen y 397.4-399.4 -> 400.0 every tick t55-71 | `katana_planted_t61_64.png` |
| 2 katana thrust drawn as a lunge (asset lane it454 cells) | f6d9588a5, c959761a0 | `--rivet-thrust=off` | 2.5 m dash on one wind-up cell -> thrust cell over lunge + contact (t83-91) | `thrust_katana_t82_92_64.png`, `_32.png`, `thrust_katana_cam_t80_90_32.png` |
| 3 blade strike cells on their boots (side + camera, p70 + p55) | 0e01165a3, 7b1f03b7c, 6bdb6dd4b | `--rivet-cell-feet=off` | katana side boots ~15 px over the walk line at 64 px/m -> ~4; camera cells a body height up -> on the line | `katana_cell_feet_boots_64.png`, `katana_cam_cell_feet_t66_64.png`, `katana_cell_feet_t64_32.png` |
| 4 no fire-cell flash after a turn | 6ae388e38, 6822e1036 | `--rivet-fire-turn=keep` | camera fire cell flashing t339-340 with no round -> none | `pistol_turn_noflash_t339_64.png` |
| 4 flash lasts the flare's ticks (flashless cells, 8 guns x 2 pitches) | e9c893e67 | `--rivet-noflash=off` | pistol painted flash t333-338 (6 ticks) -> t333-335 (gun_fx muzzle_ticks 3) | `noflash_pistol_t333_338_64.png` |
| 4 recoil kicks the body | 8a47c51db | `--rivet-kick=off` | one held pose -> hand cannon 4.8 deg back about the feet (top ~13 px at 64 px/m), pistol 3 deg | `kick_hand_cannon_64.png`, `kick_hand_cannon_32.png` |
| 3 katana thrust recovery drawn (asset lane it458 cells), no slash arc after a straight thrust | 77b991075 | `--rivet-thrust-recover=off` | slash cell + cream arc 22 ticks, figure top 24 px under the thrust -> blade drawn back level, boots on the line, top 8 px over (64 px/m) | `thrust_recover_t90_119_64.png`, `thrust_recover_cam_t88_118_32.png`, `thrust_recover_t90_119_32.png` |
| 4 diagonal shot draws a diagonal gun (all 8 guns at p70 and p55, it458/it462/it463) | 67f4343a6, 4fc5137dc, 7b4d3201b, fc0fa83ad, 9cefa9505 | `--rivet-gun-diag=off` | arm level 0 deg vs aim -19..-35 deg, flash star off the gun -> the drawn barrel along the round (+-5 deg by eye), flash/arc/comet/rocket from the drawn muzzle; pistol figure 117 -> 150 px tall (walk 160) at 64 px/m | `gun_diag_pistol_64.png`, `gun_diag_pistol_32.png`, `gun_diag_p70_rifles_64.png`, `gun_diag_p70_launchers_64.png`, `gun_diag_gatling_64.png`, `gun_diag_p55_64.png` |
| 3 wind-up / left strike cells on the walk's boot line (plasma, baton, chainsaw, plasma left, baton left) | 991c71bd4, 68193fd42 | `--rivet-cell-feet=off` | boot line vs the walk's at 64 px/m: plasma wind-up 4 px low, baton 7, chainsaw 4, plasma left 4/3, baton left 5/7 -> each within 1 px; 32 px/m plasma 3 -> 1, baton left strike 3 -> 0 | `plasma_windup_feet_64_32.png`, `windup_feet_blades_64.png`, `baton_left_strike_feet_32_x6.png` |
| 5 gun camera fire cells on his boots | 9bac727e5 | `--rivet-cell-feet=off` | pistol shot tick: figure top 44 px higher -> the drawn crouch on the line | `camfire_pistol_t60_63_64.png` |

## What does not work yet (open in DEFECTS.md)

- #2 the claw's lunges still spread evenly (its rows feed the replay golden: a Call).
- #11 the shot's direction vs the drawn arm: fixed on the diagonals for all 8 guns at both pitches; a side-octant shot
  20-30 deg off still draws the side cell (the facing/aim gap itself is unmeasured over a street fight).
- #19 the p55 rocket launcher's diagonal cells draw no back-blast (its side cell does).
- #13 also: the katana's x1.5 camera cells hand over to the walk grid with an ~8 px figure-top pop at 32 px/m.
- #13 size pop at the fire cell -> armed walk handover (placement, not drawing).
- #15 one tick of his front when he fires toward the camera with his back turned (kill lab).
- p55 camera strike cells not yet filmed in a boss arena; the camera wind-up / strike cells not yet measured against the walk's boot line (#20 covers the side and left cells).

## Calls for the owner (draft)

- The claw's `lunge_ticks` (replay re-bless) - #2.
- Lean degrees (katana 5/9) and the kick (3 deg per unit of rig_kick): the stills above, each with its before.
- The unarmed HUD slot: hidden today; a claw icon + "UNARMED" is the alternative.
- The diagonal fire cells show his back on the away diagonals (the drawn 3/4 away pose) where the side cell showed
  his visor: `gun_diag_pistol_64.png` (before top, after bottom). Alternative: keep the side cell on the away
  diagonals only (one data row in `RivetGunDiag.DEG`).
- The asset lane's it463 v2/v3 redraws of the gloria, gatling and electro gun diagonals aim steeper (35-45 deg by
  eye against v1's 20-30) but draw a smaller figure (a bigger pose-height pop at the handover). Shipped: v1
  (`gun_diag_p70_rifles_64.png`, `gun_diag_p55_64.png`); the alternative is a file copy from `alt_it463/` plus a
  re-measure of the rows. Boards: `gtai-art/library/evidence/it463/*_diag_*_v2_board.png`.
- #19: the rocket launcher's diagonal cells draw no back-blast (`gun_diag_p55_64.png`, row 3): ask the asset lane for
  the exhaust behind him, or keep it as drawn.
- #20 seats the wind-up / left strike cells on each weapon's armed-walk boot line (that walk line sits 4-12 px over
  his ground point, by weapon). The alternative, re-seating the walk grids on the ground point, moves every cell
  tuned to them: not taken (`windup_feet_blades_64.png`).

## Merge notes

- Touches `features/characters/` (Rivet's view), `features/hud/`, `data/tables/melee_weapons.json` (+schema),
  `dev/showcase/reel_chapters.gd` (two extra chapters), new strips under `art/view/<p70|p55>/`
  (`*_noflash.png`, `rivet_eq_katana_thrust.png`, `rivet_eq_katana_thrust_recover.png`, p70
  `rivet_eq_<gun>_diag{,_noflash}.png` for 8 guns at p70 (7 on the asset lane's TALL cut, +60 rows) and p55) with
  provenance lines; `data/tables/rivet_muzzle.json` (+16 rows, pinned in `tools/art/rivet_muzzle.py` DIAG_PINNED).
- Debt: dev_loc +11 accepted (the thrust chapters).
