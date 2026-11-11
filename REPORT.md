# REPORT - n17 rivet-strike (DRAFT, session 2; the final pass lands before 07:40)

Branch `n17-rivet-strike`, cut from `int-n16` at `87be8c7df`. Every change is render only and sits
behind its own before flag (CastFlags). No sim change: the replay and parity goldens are untouched.
Evidence: `evidence/n17-rivet-strike/` (same files and `frames.json` as `gtai-masters/n17/rivet-strike/`).
Defect log: `DEFECTS.md`.

Gates (session 2): `node tools/evidence/run.mjs --no-bench --no-release` on 8a47c51db: lint 19/19, unit 2786
passed 0 failed, scenarios 55/55, parity bit-exact, look goldens 11/11 and block goldens 5/5 (worst 0.00). Reel gate
on 48c91e944: top, tilt70, combo OK. Bench not run (CONTENDED machine; render-only lane).

## What works, with evidence

| Item | Commit | Before flag | Measured before -> after | Evidence |
|---|---|---|---|---|
| 1 HUD weapon slot (bottom right: showcase icon, `WEAPON__<id>` name, magazine) | bb09b7574 | `--hud-weapon=off` | none -> slot, cut swap, lifts over a subtitle | `hud_slot_1280x800_gloria.png`, `hud_slot_1280x800_rocket_launcher_line.png` |
| 2 lunge on the contact tick (`lunge_ticks`, katana_3 4, chainsaw_1 4) | 3abb72f83 | row without `lunge_ticks` | katana thrust: 1.25 m of 2.5 at contact + 1.04 m slid after -> 2.5 m at contact, 0 after | `test_melee_lunge_contact` |
| 2 strike lean about the feet (per weapon in `melee_weapons.json`) | 415dc9ad1 | `--rivet-lean=off` | upright -> katana/plasma 5 back / 9 in, baton 4/7, saw 3/6 | `katana_lean_strike_t64_32.png` |
| 2 strike cell planted (no gait bob on it) | fcd603180 | `--rivet-lean=off` | screen y 397.4-399.4 -> 400.0 every tick t55-71 | `katana_planted_t61_64.png` |
| 2 katana thrust drawn as a lunge (asset lane it454 cells) | f6d9588a5, c959761a0 | `--rivet-thrust=off` | 2.5 m dash on one wind-up cell -> thrust cell over lunge + contact (t83-91) | `thrust_katana_t82_92_64.png`, `_32.png`, `thrust_katana_cam_t80_90_32.png` |
| 3 blade strike cells on their boots (side + camera, p70 + p55) | 0e01165a3, 7b1f03b7c, 6bdb6dd4b | `--rivet-cell-feet=off` | katana side boots ~15 px over the walk line at 64 px/m -> ~4; camera cells a body height up -> on the line | `katana_cell_feet_boots_64.png`, `katana_cam_cell_feet_t66_64.png`, `katana_cell_feet_t64_32.png` |
| 4 no fire-cell flash after a turn | 6ae388e38, 6822e1036 | `--rivet-fire-turn=keep` | camera fire cell flashing t339-340 with no round -> none | `pistol_turn_noflash_t339_64.png` |
| 4 flash lasts the flare's ticks (flashless cells, 8 guns x 2 pitches) | e9c893e67 | `--rivet-noflash=off` | pistol painted flash t333-338 (6 ticks) -> t333-335 (gun_fx muzzle_ticks 3) | `noflash_pistol_t333_338_64.png` |
| 4 recoil kicks the body | 8a47c51db | `--rivet-kick=off` | one held pose -> hand cannon 4.8 deg back about the feet (top ~13 px at 64 px/m), pistol 3 deg | `kick_hand_cannon_64.png`, `kick_hand_cannon_32.png` |
| 5 gun camera fire cells on his boots | 9bac727e5 | `--rivet-cell-feet=off` | pistol shot tick: figure top 44 px higher -> the drawn crouch on the line | `camfire_pistol_t60_63_64.png` |

## What does not work yet (open in DEFECTS.md)

- #2 the claw's lunges still spread evenly (its rows feed the replay golden: a Call).
- #11 the shot's direction vs the drawn arm (~30 deg at the pistol's fire tick): unmeasured over a street fight.
- #13 size pop at the fire cell -> armed walk handover (placement, not drawing).
- #15 one tick of his front when he fires toward the camera with his back turned (kill lab).
- p55 camera strike cells not yet filmed in a boss arena; the armed HUD slot not yet filmed in game.

## Calls for the owner (draft)

- The claw's `lunge_ticks` (replay re-bless) - #2.
- Lean degrees (katana 5/9) and the kick (3 deg per unit of rig_kick): the stills above, each with its before.
- The unarmed HUD slot: hidden today; a claw icon + "UNARMED" is the alternative.

## Merge notes

- Touches `features/characters/` (Rivet's view), `features/hud/`, `data/tables/melee_weapons.json` (+schema),
  `dev/showcase/reel_chapters.gd` (two extra chapters), new strips under `art/view/<p70|p55>/`
  (`*_noflash.png`, `rivet_eq_katana_thrust.png`) with provenance lines.
- Debt: dev_loc +11 accepted (the thrust chapters).
