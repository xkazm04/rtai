# REPORT: night n15, lane combat (updated 06:10 by session 8)

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
| 2 ... and swat, capped ped, punk, jogger (it363): every kind with a burning figure ends drawn | `c11391625` | `--char-cells=off` | `evidence/n15-combat/char_cells_swat_cap_punk_jogger_ab_64ppm_t542-620.png`, `char_cells_punk_32ppm_t542-620.png` |
| 2 ... the burned SWAT man stands charred with EMPTY hands (it371 char_v2): his dropped carbine is the only gun | `406fb812e` | (the it363 sheet) | `evidence/n15-combat/swat_char_empty_hands_ab_64ppm_t545-620.png`, `swat_char_empty_hands_ab_64ppm_x3_t565-620.png` |
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
| 5 a body hit's ink burst on the body's front, riding the knock-back and the death's carry (no floor dots short of him) | `273bb2232`, `2f1ac74c8` | `--impact-follow=off` | `evidence/n15-combat/body_burst_on_body_ab_64_32ppm_t336-345.png` |
| 5 at contact Rivet draws over a cop standing behind him (the depth sort's box as tall as each drawn card, Rivet's x1.5 wide: `RigDepthBox`) | `ac7991f58` | (HEAD sorter) | `evidence/n15-combat/city_depth_rivet_over_cop_behind_ab_64ppm_t634-660.png`, 32 px/m `city_depth_fight_32ppm_t600-700.png` |
| 5 a thrown-back street man stands on his shadow (the contact shadow rides the hit card's push) | `b9544422e` | `--shadow-push=off` | `evidence/n15-combat/hit_shadow_rides_push_ab_64ppm_x2_t338-344.png`, `hit_shadow_rides_push_ab_32ppm_x3_t337-342.png` |
| 5 a later round's body burst rides the pushed hit card and returns to the body at the death (t339 dot ~0.2 m closer, no new dot at t344) | `61a2d3baa` | `--burst-push=off` | `evidence/n15-combat/burst_rides_push_ab_64ppm_x2_t338-344.png`, `burst_rides_push_ab_32ppm_x3_t338-344.png` |

Gates: full run with reels on `61a2d3baa` (session 8, 05:43-06:04, the last code commit; later commits are docs):
PASS lint 16/16, unit 2542/0/2, scenarios 55, parity bit-exact (mutation at 629), look goldens 11/11 worst 0.00, block
goldens 5/5 worst 0.69 (= this worktree's session-1 baseline), export-audit 674, reels top / tilt70 / combo OK. Also
PASS with reels on `f128a280e` and `ac7991f58` (session 7). Mutation: `rig_depth_box.gd` 100 % (8/8),
`gun_fx_follow.gd` 66.7 % (8/12, session 8; the 4 survivors are its two flag caches, equivalent without the flag).

## What does not work, or is not shown

- The p55 katana's RIGHT wind-up and strike cells draw larger than his facing (~1.2-1.4x); n13/n14 kept as built.
- The body-hit burst (fixed in large part, `273bb2232`, `61a2d3baa`): at t339 one dot still shows on the floor at
  the edge of the thrown-back cop's shadow. The burst is a floor print at his feet front and the drawn figure leans
  back off it; on the body the burst draws under his card.
- Metal impacts keep the cream strokes. The it317 sparks are packed (pulled half way to cream) but NOT shipped: no round
  on metal was filmed (a round on a metal dummy is a BODY hit; `GunFx.shield_test` is wired only in tests, so a round
  on a riot shield is ShieldSparks' white sparks, never a GunFx METAL). DECISION combat/metal-sparks-later.
  Rivet's plating keeps the strokes on purpose.
- The contractor's living hold (20 ticks) is not filmed (every Dock 9 hit in t13600-13838 was a kill).
- Charred cells: all 8 burnable kinds stand drawn; the lying char cells (`char_lying/`) are not wired. Not wired
  either: the worker and gang
  burn cells, the contractor's flinch/burn cells, the cultist (no fighter in the game).
- Drawn gib pieces for the thug and the hooded ped (it363 A) are not shipped: in the lone rocket shot they are rigs, not
  cards, so the card cut never reaches them. On a contractor's death the dropped carbine lies beside the one he holds.
- Casings: drawn per round by weapon-art (`WeaponCasings`); the asset lane's casing-litter decals (it313/it317
  `residue_casings_70`, an n12 battle-residue offer) are not wired.
- City street fight (32 px/m, `film.mjs city`): four cops seem to stand on top of the sidewalk wall from t250 to t1150.
  Their feet are at its north foot: pressed against the wall, their way to Rivet blocked (sim/AI path, not this lane),
  and the wall's cap does not hide them, so they read as standing on it (`evidence/n15-combat/city_fight_cops_on_wall_32ppm_t650.png`).
- A later round of a burst flies on through a fresh corpse; its ink tail crosses the falling body for 2 ticks (open, minor).
- Blade kills (katana, plasma sword): KillSplitFx's slash streak (a 1.7 m cream bar along the cut, 12 ticks) runs
  diagonally through the cop while Rivet's drawn swing sweeps level, so it reads as a white stick (t61-69,
  `evidence/n15-combat/katana_slash_streak_64ppm_t58-69.png`, an earlier build's film): Call (d).
- The flame jet's floor fire stacks into a column of starbursts (the sim's patches; colour is the owner's look-3 ink).
- Perf: `tools/perf/fight_gate.mjs` 06:08 (session 8, bench.lock held, 4 rounds, the code of `61a2d3baa`, befores =
  every tonight flag off): city block fight p50 +0.02 [-0.13,+0.11] ms, p99 -0.07 [-1.58,+0.65], cpu: all WASH against
  the A/A floor. Gatling horde p50, p99 and cpu WASH; the WORST frame is ~0.4 ms higher with tonight's work on
  (before - now -0.38 [-0.63,-0.02], 4/4 rounds; A/A worst [-0.32,+0.16]), both arms ~16 ms. 0 frames over 25 ms; 6 of
  24 runs CONTENDED (`build/perf/fight-gate/2026-11-11T05-08-07-904Z/gate.json`). Not measured: the load-time cost of
  the warmed strips (these scenes do not draw them).

## Calls for the owner

(a) p55 katana right wind-up/strike size: re-cut as the baton's (42c826289) or keep? Still: `evidence/n15-combat/boss_blade_katana_p55_64ppm_t306-326.png`.
(b) The rocket gib: drawn torn pieces (shipped, patrol + riot cop) or the straight cut of his card (`--gib-pieces=cut`)?
    `evidence/n15-combat/rocket_gib_drawn_pieces_ab_48ppm_x2_t349-368.png`. More kinds are drawn (thug, hood) and a riot
    shield piece is offered.
(c) The one upright frame between two blade swings (t308): hold the strike's recovery through short gaps?
(d) The blade kill's slash streak (lane brutality's split style): it crosses the cop diagonally while the drawn swing is
    level, a white stick for 9 ticks. Align the cut to the drawn swing, shorten/thin it (`KillSplitFx.STREAK_M` 1.7,
    width 0.11 m), or keep? `evidence/n15-combat/katana_slash_streak_64ppm_t58-69.png`.

## Merge notes

- `cast_view.gd` (boot) changes one line (StreetQuestHit.or_card). `street_hit.py` gained a contractor row, `--only=`,
  `SCALE_FROM`/`PAD_BELOW` (contractor v3). New packer `tools/art/gib_pieces.py`.
- Debt baseline raised twice with `--accept-regression` (blade boss bot dev_loc +55; quest1_clip flag +2).
- n15-tools serves this lane's REQUESTs on its own branch (compare --victim, extras chapters, --feel, test_quest_blade).
- Files this branch shares with the other lanes (`git diff --name-only 5c5c03611..n15-<lane>`, compared 06:12):
  with hero `project/boot/collect_call/view/cast_view.gd`, `project/features/characters/cast_flags.gd`,
  `project/features/characters/rivet_res.gd`, `tools/art/rivet_frames.json`; with tools `cast_flags.gd`,
  `project/dev/frames/quest1_clip.gd`; with both `docs/decisions.md` (append-only: keep every line),
  `tools/debt/baseline.json` (take either side, re-run `node tools/debt/debt.mjs --update`), and with hero
  `steam/ai-provenance/2026-11.jsonl` (union). `cast_flags.gd` is the flag list: union the flags.
  Tonight's late files (rig_carry, arena_rigs, gun_fx_follow, rig_cast_shadows, rig_depth_sort/box) are this lane's only.

## Next steps

1. The owner's Calls (a)-(d) above; each alternative is one flag or data value.
2. The t339 body-burst dot: the burst is a floor print at his feet front, and the thrown-back figure leans back off it.
   Lift a body hit's burst to the drawn body's height (an FX layer over the rigs for body hits), or let the hit cell
   carry its own drawn wound.
3. The cops at the sidewalk wall: nav (they never path round its end) and occlusion (the cap should hide a body behind
   it). Not this lane.
4. Metal impacts: wire `GunFx.shield_test` (or a metal prop target) so a round on metal can be filmed, then judge the
   packed it317 sparks.
5. The contractor: film his living hold (20 ticks); hold his dropped carbine back until his death cell lands (needs the
   drop's tick; `fx_ground.gd` is a file hero may touch).
6. The horde's worst frame is ~0.4 ms higher with tonight's work on (both ~16 ms): bisect it by flag with
   `fight_gate.mjs --scenes=horde` on a quiet machine.
