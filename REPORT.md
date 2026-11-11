# REPORT: night n15, lane combat (DRAFT, updated 02:40 by session 5; the last session finishes it)

Branch `n15-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n15-combat`, cut from main `5c5c03611`.
Every change has a before flag on the same build and a same-tick before/after film under `evidence/n15-combat/`
(best ones in `C:\Users\kazda\kiro\gtai-masters\n15\combat\frames.json`). Defects found by eye: `DEFECTS.md`.

## What works, with its evidence

| Item | Commit | Before flag | Evidence |
|---|---|---|---|
| 1 c-2: the thrown-back hit cells at the walk camera, 9 kinds (+ SWAT v4, elder v3), FILL re-measured | `1ede2ce03`, `13a74d4dd` | `street_hit.py VERSIONS` line removed | `evidence/n15-combat/c2_hit_walkcam_ab_*_64ppm_t338-350.png` |
| 2 the burning figures' second flail frame (8 kinds) | `709321330`, `261669f02` | `StreetWalkerHit.FLAIL_FRAMES` | see JOURNAL session 1 |
| 2/3 a stunned cop drops his own navy pistol (it325) | `b8da0a47f` | `--dropped-gun=pale` | JOURNAL session 1 |
| 2 quest 1's contractor thrown back by a blow (it321 stagger v2) | `302a0d670` | `--quest-hit=off` | `evidence/n15-combat/contractor_hit_stagger_ab_48ppm_x2_t13708-13726.png` |
| 2 ... and he staggers holding his long dock carbine (it359 v3, hat-registered at v2's scale) | `51034570a` | (the v2 grid) | `evidence/n15-combat/contractor_hit_v3_carbine_ab_48ppm_x3_t13710-13722.png` |
| 2 a fire death stands as the drawn charred figure: patrol cop (it272), thug, hooded ped, riot cop (it359) | `8eb67bc62`, `63811e09c` | `--char-cells=off` | `evidence/n15-combat/char_cells_cop_ab_64ppm_x2_t542-620.png`, `char_cells_thug_hood_riot_ab_64ppm_t542-620.png` |
| 3 p55 baton strike re-cut at the facings' size | `42c826289` | (re-cut) | `evidence/n15-combat/baton_p55_strike_recut_ab_32ppm_x2_t54-70.png` |
| 3 the baton's drawn left strike (it334) | `a76c26f9a`, `6486e5e59` | `--rivet-left-strike=off` | `evidence/n15-combat/baton_left_strike_ab_p70_32ppm_t52-110.png` |
| 3 katana / plasma sword / chainsaw turned left: drawn left set (it338/342/346) | `15c8abbcc` | `--rivet-blade-left=off` | `evidence/n15-combat/katana_left_set_ab_64ppm_t56-76.png`, `boss_katana_left_set_p55_ab_64ppm_t306-326.png` |
| 3 the body-hit ink disc 0.12 m | `07bb047cf` | `--body-ink=n7` | `evidence/n15-combat/body_ink_disc_ab_64_32ppm_t334-342.png` |
| 3 the dev arena's combat lights age out | `5bdad7a0c` | (none: a bug) | `evidence/n15-combat/arena_lights_age_out_ab_32ppm_t1410-1700.png` |
| 3 a blade boss bot (dev) | `b6443d22e` | `--boss-blade` absent | `evidence/n15-combat/boss_blade_katana_p55_64ppm_t306-326.png` |
| 4 the rocket gib flies in six pieces of the drawn card | `324927f99` | `--gib-card=whole` | `evidence/n15-combat/rocket_gib_card_pieces_ab_48ppm_x1.5_t347-372.png` |
| 4 ... drawn torn pieces (cap, torso, arms, legs) for the patrol and riot cop (it359/it363) | `11a460e80` | `--gib-pieces=cut` | `evidence/n15-combat/rocket_gib_drawn_pieces_ab_48ppm_x2_t349-368.png` |
| 4 a round in the ground: the drawn concrete dust (it317) | `19e7768ff` | `--impact-fx=shapes` | `evidence/n15-combat/impact_dust_drawn_ab_48ppm_x3_t352-363.png` |
| 4 sustained flame jet filmed at combo (not changed) | | | `evidence/n15-combat/flame_jet_sustained_combo_32ppm_t48-192.png` |
| 4 vehicle shadows judged (no defect) | | | `evidence/n15-combat/vehicle_shadows_combo_64_32ppm.png` |
| 5 the melee smear: one crescent, no white hexagon ring | `9f966271e` | `--melee-smear=n7` | `evidence/n15-combat/melee_smear_span_ab_baton_left_32ppm_t58-96.png` |
| 5 the city street fight draws no range-target rings | `54297457d` | `--target-rings=on` | `evidence/n15-combat/city_target_rings_ab_32ppm_t200_600.png` |

Gates: last full run PASS on `54297457d` (00:29; lint, unit 2512/0/2, scenarios 55, parity bit-exact, look goldens
11/11 worst 0.00, block goldens worst 0.69 = this worktree's session-1 baseline, export-audit, reels). TO DO: the
final commit's gate line.

## What does not work, or is not shown

- The p55 katana's RIGHT wind-up and strike cells draw larger than his facing (~1.2-1.4x); n13/n14 kept as built.
- The body-hit burst stays at the world point while the dying body is carried ~0.5 m (view-only rig carry).
- Metal impacts keep the cream strokes. The it317 sparks are packed (pulled half way to cream) but NOT shipped: no round
  on metal was filmed (a round on a metal dummy is a BODY hit; a riot cop's rounds hit his body, not the shield).
  Rivet's plating keeps the strokes on purpose.
- The contractor's living hold (20 ticks) is not filmed (every Dock 9 hit in t13600-13838 was a kill).
- Charred cells: the patrol, thug, hood and riot cop stand drawn; swat, ped_cap, ped_punk, ped_jogger keep the char
  print (no drawn cells); the lying char cells (`char_lying/`) are not wired. Not wired either: the worker and gang
  burn cells, the contractor's flinch/burn cells, the cultist (no fighter in the game).
- Drawn gib pieces for the thug and the hooded ped (it363 A) are not shipped: in the lone rocket shot they are rigs, not
  cards, so the card cut never reaches them. On a contractor's death the dropped carbine lies beside the one he holds.
- The flame jet's floor fire stacks into a column of starbursts (the sim's patches; colour is the owner's look-3 ink).
- Perf: `tools/perf/fight_gate.mjs` 01:15 (bench.lock held, 4 rounds, befores = every tonight flag off): city block fight
  p50 -0.46 [-1.88,+1.93] ms, p99 -0.58 [-2.87,+3.31]; Gatling horde p50 -0.20 [-0.72,+0.68], p99 +0.71 [-0.38,+2.57]:
  all WASH against the A/A floor; 0 frames over 25 ms; 21 of 24 runs CONTENDED. Not re-run after session 5's art
  (char cells x3, gib pieces, contractor v3: load-time textures, drawn only at a kill).

## Calls for the owner

(a) p55 katana right wind-up/strike size: re-cut as the baton's (42c826289) or keep? Still: `evidence/n15-combat/boss_blade_katana_p55_64ppm_t306-326.png`.
(b) The rocket gib: drawn torn pieces (shipped, patrol + riot cop) or the straight cut of his card (`--gib-pieces=cut`)?
    `evidence/n15-combat/rocket_gib_drawn_pieces_ab_48ppm_x2_t349-368.png`. More kinds are drawn (thug, hood) and a riot
    shield piece is offered.
(c) The one upright frame between two blade swings (t308): hold the strike's recovery through short gaps?

## Merge notes

- `cast_view.gd` (boot) changes one line (StreetQuestHit.or_card). `street_hit.py` gained a contractor row, `--only=`,
  `SCALE_FROM`/`PAD_BELOW` (contractor v3). New packer `tools/art/gib_pieces.py`.
- Debt baseline raised twice with `--accept-regression` (blade boss bot dev_loc +55; quest1_clip flag +2).
- n15-tools serves this lane's REQUESTs on its own branch (compare --victim, extras chapters, --feel, test_quest_blade).

## Next steps

See the last NEXT line in `JOURNAL.md`.
