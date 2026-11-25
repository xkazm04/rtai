# REPORT - lane cast, run n29 (2026-11-25)

Branch `n29-cast` from `main` `c649a15d6`, worktree `gtai-wt/n23-prologue`. Director: Claude Opus 5.5 (five sessions).
Builders: in-session Claude sub-agents (Sonnet 5.5 for most calls, Opus 5.5 for the cut/placement/measurement calls),
each from a brief under `evidence/briefs/n29-cast-*.md`. Owner's order: (1) measure every card foe against the full-rig
patrol cop, then one scale value each; (2) hit flash on the door carrier and robot gunner; (3) robot thug A; (4) new walk
art for the door carrier (8 drawings), the pile-driver and the war machine. Films and stills:
`C:\Users\kazda\kiro\gtai-masters\n29\cast\` (`frames.json` there, best first). IMAGES 21/60.

**Gate: green.** `node tools/gate/run.mjs --rev=HEAD` on `42ac8613b` (the last code commit; every later commit is docs, journal, report or the python art tool `tools/art/cast_film_heights.py`), started 06:48 and finished 07:06: `gate: PASS; build/gate/42ac8613b0be/gate.json`. Lint 19/19 checks over 2282 files, unit 4252 passed / 0 failed / 2 skipped, scenarios 68 (corpse_horde missed its budget under contention and passed when re-judged alone), parity bit for bit over 1200 steps with the planted mutation caught, selftest, export-audit 1000 loaded / 0 failed. The `--reels` gate on `9a99caebb` (07:06, detached, `build/gate-reels.out`) is quoted below when it ends: REELS PENDING.

## What works

| Item | Evidence | Number |
|---|---|---|
| **Card foe size measured beside the spawned full-rig patrol cop, then one value each** (`f4bf378ea` table + cause, `31df5170f` code/data/tests, `51de13fb6` applied + re-measured) | `size_before_64.png` / `size_after_64.png` (and 32 px/m), `size_beside_32.mp4` (1920x1080 60 fps 33.75 s, three cops, Rivet); `docs/art/cast-audit.md` "Card foes beside the rig patrol cop, n29" | unjittered cop 100.6 px at 64 px/m, Rivet 154. After: warden 101 (x1.18), contractor 100 (x1.00), gunner 110 (x1.10), lancer 100 (x1.08), turret 107 (unchanged), Mulroney 106 (x1.23), door carrier 111 (x1.03), war machine 130 (x0.84, was 155 = Rivet-tall). Every row within 4 % of its target at 64 and 32 |
| **Why the lineup lied (1.35x contractor, 0.78x cop)**: the per-actor build jitter `StreetCrowdCards.body_scale(actor_id)` (1 +- 0.16, hash of the fighter id) with ids swapped between the lineup and the fight scene; card foes now drop it (`cast_cards.json` `build_jitter` 0; 0.16 restores) | same table, "Jitter proof" | contractor ids 3/10/11 (old jitter 1.03/0.85/1.10) all 100 px; gunner ids 4/12/13 all 110 |
| **Hit flash on the door carrier and robot gunner, live** (`7ca036a93` `CastFarCard.sync_tint`, `c0a1b816e` `ArenaRobotRigs._react` lights `RigClips.flash()`, film `8d665f61e`) | `flash_live_64.png`, `flash_street_32.mp4` (1920x1080 60 fps 25.02 s), `flash_door_gunner_before_after_64ppm_tilt{70,55}.png` | 20 flashes door / 20 gunner in 25 s on the live path; red 0 -> 0, teal adds none; mutate `arena_robot_rigs` 5/6 = 83.3 % |
| **Door carrier walk re-plant** (`61c383438`: `FoeShieldCardView._rescale` keeps the anchored sole through the height rescale) | `docs/art/cast-audit.md` "Re-plant shipped, n29" | shipped four, sole/jump (32 px/m unit): 70 right 5.08/6.04 -> 2.42/4.34, 55 right 3.29/6.29 -> 2.03/5.09; mutate 4/4 on the height formula lines |
| **Door carrier eight-drawing walk: cut, one value away** (`073321ae7`, `f867fd556` redrawn p70 right drawing 7, `62aa13f5a` one-value `CastDoorAnchors.WALK`) | `door8_walk_32.mp4` (25.85 s, staged copy with EIGHT), `door8_feet_before_after_64.png` | eight 70 right 2.04/6.47, 70 dr 1.39/12.21, 55 right 2.16/9.61, 55 dr 3.45/13.28: body jump worse than the four in every facing, so WALK stays FOUR |
| **Robot thug A: cut, card row (off, one value), foot line, poses, fight, checklist** (`75b0374d0`, `19c72dfdb`, `588c7b706`, `a679e3fa5`, `c8b794054`, `d9bfe36a7`, `839ce02d8`, `1115a7e30`, `b15cd2909`, `804e5c0c8`) | `thug_beside_64ppm_tilt70.png`, `thug_poses_64ppm_tilt70.png`, `thug_fight_32.mp4` (20.02 s), `thug_stop_after_64.png`; `evidence/n29/thug/checklist.md`, `checklist_b.md`, `fixes.md` | size 0.98 / 0.97 of Rivet at 55, 0.92 / 0.91 at 70 (64 / 32 px/m, body_scale 1.42); walk sole 0.00, jump <= 9.60; stop: soles 1 / 0.5 px from the ground row at 70 (was 4), 2 / 1 at 55; contact ring on the ground point (was 25 px below at 64); palette PASS (strict red <= 60 px of 867k, teal 6); shadow 394 px (patrol 161); live 64 px/m rim 0 on walk/attack/hit/fall, both pitches |
| **Pile-driver eight drawings: cut, measured, one value away** (`996160bb4` cut, `20be6ffaa` one-value `CastWarAnchors.WALK`, `bd0638f78` feet table + tools, `480975cdd` placement revert) | `war8_feet_before_after_64.png` (four left, eight right, same tick), `war8_walk_32.mp4` (staged preview of the eight, 25.85 s); `docs/art/cast-audit.md` "Pile-driver on eight drawings, n29" | sole / jump (32 px/m unit), four -> eight on the held-foot view: 70 R 12.50/16.82 -> 18.16/10.73, 70 DR 18.86/12.87 -> 27.45/10.37, 55 R 21.94/11.78 -> 20.91/10.74, 55 DR 18.64/12.87 -> 23.86/9.93. The eight passes the jump bar (12) everywhere, the four nowhere; the eight slides more in 3 of 4. WALK stays FOUR (owner call) |

## What does not

- **Robot thug A is not switched on.** Ink runs fail on the numbers: at y 75 five of eight 55-degree drawings carry a 6-13 px run (patrol 3,3,3), where the contour crosses the dark hose rubber (the cause the gunner's n28 row accepted). Live, the outline reads closed and even at 32 and 64 px/m (`build/look/n29-thug/ink/live_32_64_x4.png`). Every other point passes. See Calls for the owner.
- **Pile-driver feet fail every bar** with either walk (sole <= 2: none; the four's jump > 12 in every facing). The per-contact pad placement I ordered (`5d8e4b6f8`) made the shipped four worse (jump 70 R 16.82 -> 23.80, 70 DR 12.87 -> 28.77, 55 R 11.78 -> 32.50, 55 DR 12.87 -> 27.19) and was reverted (`480975cdd`, diff to `20be6ffaa` empty, the four re-measured equal). The art's support exchange is uneven (p70 right planted pad per drawing R R L L R R R L).
- **Door carrier eight**: body jump worse than the four in every facing even after the re-plant and the redrawn drawing 7; stays one value away.
- **The war machine is on in the game and still walks the four** (fails the feet rule, as before tonight); the eight is the one-value alternative.
- Turret and war machine views have no hit flash (`sync_tint`): outside the owner's item, not done.
- `size_beside_32.mp4` shows nominal labels on screen (50 px x actor scale). The heights were then measured in its frames (`ff06ff086`, median of 50 frames): warden 51, contractor 50, gunner 55, Mulroney 54, lancer 48 (walk cell; still 51 in the aim cell), cops unjittered 50.0 / 48.2 / 48.6 (stills 50.3), Rivet 80 (77). The door carrier reads 63 against 56 in the stills. The cause is facing (`a36fab587`): side-on 55, walking down 62, walking up 69 with the door held over his head, against Rivet's 81.5 in that facing. The turret could not be separated from its label. The war machine reads 64-68 by eye (still 65).
- `war8_walk_32.mp4` and `door8_walk_32.mp4` are feet-harness takes on the grey plate (contact boxes per step), not street takes.

## What blocked or slowed you (minutes each)

- Image copy stall, ~50 min (session 1): every `gen.mjs` job hung to its 900 s timeout after the image existed; collected by hand (`foes-n29/collect2.py`).
- Withdrawn scale rule, ~30 min (session 1): my first rule aimed at Rivet's x1.5 visual height and made giants; reverted (`f1ee4718b`, void line in `docs/decisions.md`).
- Hook `step_guard.break.test.mjs` load flakes, ~10 min across sessions (passes alone).
- `quick.mjs` Godot parse step fails on untouched files in this checkout ("Failed to compile depended scripts"): builders ran `--no-godot` + GUT.

## Calls for the owner

- **Robot thug A: switch him on?** Every checklist point passes except the ink numbers on the dark hose (see above); the switch is one value (`cast_cards.json` `robot_thug.enabled`). Stills `thug_beside_64ppm_tilt70.png`, `thug_poses_64ppm_tilt70.png`, `thug_stop_after_64.png`, film `thug_fight_32.mp4` (forced preview row).
- **Pile-driver: the eight (even body, sliding pads) or the four (sliding pads, jumping body)?** One value, `CastWarAnchors.WALK` (generator line in `tools/art/cast_war_soles.py`). `war8_feet_before_after_64.png`, `war8_walk_32.mp4`.
- **Door carrier eight**: ships with one value (`CastDoorAnchors.WALK = EIGHT`); measured worse body jump than the four, so it is off. Still `door8_feet_before_after_64.png`.
- **The patrol cop keeps the crowd's +-16 % jitter** (no card row), so a card foe can stand beside a smaller cop (86 px in the stills against the unjittered 100.6).

## Merge notes

- NEED combat (open): `project/features/combat/kills/kill_fall_cells.gd` sizes a killed card foe with the crowd jitter only, not `CastCards.Sheets.scale_of`, so a kill draws a card foe at 0.84-1.16 of its card size.
- `tools/debt/baseline.json` carries several accepted rises for this lane (films, war eight, thug): take the looser side with `node tools/debt/merge_baseline.mjs`.
- Root `JOURNAL.md` / `REPORT.md`: keep each lane's own.

## Next steps

1. Owner's two one-value calls: robot thug A on (`robot_thug.enabled`), then re-film `thug_fight_32.mp4` with the row on in the live game (no forced preview); pile-driver `WALK` FOUR or EIGHT.
2. Pile-driver feet: register one pad window per contact (the pad planted through all of that contact's drawings) and carry the body across the contact boundary instead of snapping to the fighter's ground; measure in the same call with `tools/film/cast_war_films.mjs ... feet` before committing. The art's uneven exchange (p70 right R R L L R R R L) may still need one-row image edits (drawings 3-4 and 7-8).
3. Door carrier eight: the edits named in `docs/art/cast-audit.md` "Door eight with the redrawn drawing 7" (p55 drawing 8 right and down-right, p70 down-right drawing 1), one row per job.
4. Hit flash on the turret and the war machine views (`sync_tint`), if the owner wants every robot to flash.
5. NEED combat: `kill_fall_cells.gd` card scale (see Merge notes).
6. Thug ink: if the owner wants the numbers, a cut pass that lifts the hose rubber's edge off the outline (matte), re-measured with `tools/art/cast_thug_ink.py`.

## Builder ledger

25 calls, about 600 builder minutes, none abandoned. Minutes are wall clock from launch to report.

| Call | Model | Min | Result |
|---|---|---:|---|
| 01 size (table + cause) | opus | 66 | accepted-partial: table and cause kept, part B made under my withdrawn rule, reverted |
| 02 flash | sonnet | 64 | accepted-partial: `sync_tint`, harness left staged |
| 04 cleanup | sonnet | 11 | accepted-partial: void line; hook `tool-tests` flake blocked the rest |
| 05 flash finish | sonnet | 48 | accepted-partial: no mutate score (import timeout under load) |
| 01b scale | opus | 51 | accepted |
| 03a thug cut | sonnet | 10 | accepted |
| 03b thug card | opus | 26 | accepted |
| 06 door eight | opus | 38 | accepted (eight measured worse, off) |
| 08 films | sonnet | 44 | accepted-partial: size film labels nominal |
| 09 door re-plant | opus | 29 | accepted |
| 10 flash live | sonnet | 23 | accepted |
| 03c thug foot line | opus | 38 | accepted |
| 11 door eight f7 | opus | 24 | accepted |
| 07 war eight p1 / p2a | opus | 4 / 12 | accepted |
| 03d-B thug checklist | sonnet | 17 | accepted (two fails found) |
| 03e thug fixes x2 | sonnet | 4 / 15 | accepted (size; ring), soles left open |
| 12 decisions | sonnet | 1 | accepted |
| 07b step 1 pad placement | opus | 9 | accepted, then reverted by 07b steps 2-3 (it made the four worse) |
| 03f thug soles | sonnet | 12 | accepted |
| 07b steps 2-3 feet table + revert | opus | 24 | accepted |
| 03d-A thug ink + rim | sonnet | 17 | accepted (ink FAIL on numbers) |
| 13 decisions + size film heights | sonnet | 10 | accepted |
| 14 door height film vs stills | sonnet | 7 | accepted (cause: facing) |

What I would brief differently: (1) measure before building a placement: 07b step 1 shipped a pad placement whose feet table came one call later and showed a regression; the measurement belongs in the same call, before the commit. (2) Write the size rule against the measured unjittered cop from the start (my first rule used Rivet's x1.5 visual height and cost a revert). (3) Give every film call "labels measured in the frames, never nominal" in the first brief. (4) Short calls (10-25 min, one point each) were the best value tonight; the 60+ min calls all ended partial.
