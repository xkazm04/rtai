# n30 combat 05: a killed card foe falls on his own fall sheet

Brief: `evidence/briefs/n30-combat-05-card-fall.md` (owner verdict `docs/decisions.md:1598`).
Code `480268dcf`, test `0351c7020` (branch n30-combat).

## What the living death does, and what the kill now reuses

A card foe that dies with no kill style draws `CastCardPose.path_for` -> `sheets.fall`. `StreetWalkerCards._build`
gives that card `hframes` = `RigHeadCard.FRAMES` (5 facings), `vframes` = `StreetFallBetween.rows_of(path)` (3: the cast
sheets are not `_between_fall`), the feet at the cell centre (offset -cell/2), and `place` -> `is_fall_card` ->
`StreetWalkerFall.draw` sizes it at `HEIGHT_BY_ART[<sheet's art>] * PX_PER_M * k / STILL_PX` (k = `sheets.scale_of`,
`StreetFallFit.k` = 1 for these sheets), faces it by `RigHeadCard.frame_of(blow)` with `flip_h` on the mirrored
column, and steps rows by `fall_frame(progress, vframes)`. `CastFarCard._configure` uses the same `STILL_PX` for a
fall sheet. So the cast sheets' own cell sizes (mulroney p70 460x310, warden 490x440, trooper 796x388) are canvases
drawn at the 192 px still scale, and the generic grid's geometry in `KillFallCells.attach` (FRAMES across,
`rows_of` down, centred, `_scale` = the same formula with `victim_scale` = `scale_of`, `face`, `step`/`row_at`) is
already that geometry. Only the drawing changes: no new geometry.

`project/features/combat/kills/kill_card_fall.gd` (new, `KillCardFall`): `path_of(rig)` = the card foe's
`sheets.fall` as `<art>/<file>` when it exists under `StreetWalkerCards.DIR`, ends `_fall.png` and splits into 5 x
`rows_of`; else "". `KillFallCells.attach` takes it when the style has no cells for him.

### One routing call the brief did not foresee (judgement, please confirm)

The brief says "when the kill style has no own cells (`own` empty)". In practice `own` is never empty for the
filmed kill: the card foe's pooled rig keeps a street row (headless: `cop/head_swat`; in the reel the patrol row),
and the machine pistol stitch, molotov torch and pistol snap all have cells for that row
(`swat_smg_stitch.png`, `cop_patrol_smg_stitch.png`, ...). Those are another kind's drawn death: the n29 stills'
"generic cop" body was the patrol cop's own stitch cells, not the fall grid (`before` column below). So a card foe
now looks his cells up under `*` only (`KillCardFall.cells_row`): cells drawn for any victim (`claw_rake_kill`'s
`*`) are kept, street-row cells are not his, and he falls on his own sheet. `--kill-card-fall=grid` restores both
the street-row cells and the generic grid (the before). Street walkers are untouched (`cells_row("", row) == row`).

## Routing per card row (`test_every_card_row_has_a_usable_fall_sheet`, p70 and p55)

| row | enabled | p70 fall sheet | p55 fall sheet | route |
|---|---|---|---|---|
| sergeant_mulroney | yes (1.23) | `sergeant_mulroney_fall.png` 2300x930 | 2020x984 | own sheet |
| appliance_warden | yes (1.18) | `appliance_warden_fall.png` 2450x1320 | 2100x1320 | own sheet |
| contractor | yes (1.0) | `contractor_cast_fall.png` 1610x1320 | 2400x1320 | own sheet |
| rocket_trooper | yes (1.08) | `rocket_trooper_fall.png` 3980x1164 | 2510x1182 | own sheet |
| robot_thug | off (1.42) | `robot_thug_fall.png` 1550x1320 | 2110x1320 | own sheet once the cast lane turns it on |
| robot_gunner, shield_robot, war_machine, sentry_turret | machines | - | - | never reach it: FoeCastView skips machines, no `CastCardPose` on the rig head card |

Every row's sheet exists and splits into 5 x 3: no row keeps the generic grid, so no `NEED cast` from this lane.

## Tests and checks

- `node tools/tests/run_unit.mjs --select=test_kill_card_fall,test_kill_card_scale`: `unit-tests: 14 passed, 0 failed`
  (10 + 4). With `test_kill_new_styles,test_claw_card_victims` too: 25 passed, 0 failed (before the toggle test).
- `node tools/lint/lint.mjs`: `lint: all 19 checks pass over 2293 GDScript files` (the commit hook).
- `node tools/debt/debt.mjs --update --accept-regression="--kill-card-fall for n30 combat"` (launch_args 226 -> 227),
  then `debt-ratchet: ok`.
- Mutate (temp worktree `gtai-mutate-cardfall`, tests test_kill_card_fall + test_kill_card_scale):
  `kill_fall_cells.gd` lines 25-28: 2/2 = 100 %. `kill_card_fall.gd` lines 26-47: 5/5 killed, then an
  infrastructure failure on the line-47 modulo mutant (no test result: a GDScript parse failure, not a survivor);
  lines 48-68: 7/9 = 77.8 %, the 2 survivors on line 67 (the flag read: every test set the toggle). Commit
  `0351c7020` adds `test_the_toggle_reads_on_without_the_flag`, which reads the flag (fails both: `!=` gives off,
  `1 -> 0` gives off). Total 14/16 = 87.5 % before that test; the 2 are covered by it (not re-mutated).

## Evidence (64 px/m, same seed 20261109, kill on tick 174 in all six reels)

    node tools/film/kill_reel.mjs --out=build/n30/cardfall/<arm>_<foe> --rev=HEAD --weapons=machine_pistol --ppm=32,64 --dirs=90 --clips --keep-frames -- --controls=legacy --foe-mix=<foe> [--kill-card-fall=grid]

after = no flag, before = `--kill-card-fall=grid`, both films of snapshot `480268dc`; all 12 films PASS, kill at 174.
The reel's clip window starts at the kill, so the tick before it comes from one more film per foe (pre-kill frames
are the same in both arms: the flag only changes the kill's body copy):

    node tools/film/film.mjs kill:machine_pistol --out=build/n30/cardfall/pre_<foe> --rev=HEAD --ppm=64 --lock=spawn --stills=170-176 --on=kill:1+40 --feel=off -- --sig-dir=90 --controls=legacy --foe-mix=<foe>

(snapshot `42e7af75`: the other builder's electro commits only; its t174 is 0 px different from the reel's.)

Stills `C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/card_fall_<foe>_pair_64.png` (before left, rows t173
before the kill, t196 falling, t214 lying). Film `films/card_fall_32.mp4` (per foe before|after at 32 px/m shown
x2.5, then t174-t211 again at quarter speed; Mulroney, warden, trooper):
`stream|width=1920|height=1080|r_frame_rate=60/1|nb_frames=909`, `format|duration=15.150000`.

### Sizes (figure blob bbox, `build/n30/cardfall/measure.py`: saturated or ink px, blood and crosswalk cream out)

| foe | t173 living card | t174 before (street-row cells) | t174 after (own sheet) | t214 before | t214 after |
|---|---|---|---|---|---|
| sergeant_mulroney | 80x115, feet y 490 | 155x108, feet 490 | 119x99, feet 495 | 138x76 | 170x70 |
| appliance_warden | ~85 px tall by eye, feet 490 | 149x103, feet 490 | 106x96, feet 490 | 128x73 | 140x64 |
| rocket_trooper | see below | 129x88, feet 490 | 145x105, feet 490 | 89x88 | 132x60 |

Mulroney at the switch (t173 -> t174, after): the cap is 30 px wide 6 px under the top in both frames (no size
jump on the head); the feet drop 5 px (490 -> 495, 0.08 m); the bbox grows wider and shorter because the buckle
row is drawn hunched, arms flung up, side-on bulk, where the walk is a slim back view. The living death of a card
foe (no kill style) makes the same switch with the same numbers, as this path reuses its geometry.

Warden at the switch (t173 -> t174, after; crops 2x in `build/n30/cardfall/probe_frames/switch_w.png`): the feet
stay at y 490, the height is about the same (~85 -> ~90 px, by eye), but the head is visibly bigger: the
helmet/cap is ~22 px wide on the walk and ~33 px on the fall sheet's buckle row (the mask catches only part of the
low-saturation tan walk, 53x74, so this is read off the 2x crop). That is a size pop of about 1.4-1.5x on the
head at the switch. It is not from this change: the warden's living death draws the same sheet at the same
`STILL_PX` scale, while his walk is a padded 256 px cell (`CastCardKinds.padded`, `cell_ratio`). Mulroney's
does not pop (cap 30 = 30). **NEED cast**: the warden fall sheet is drawn larger than his walk at the shared
192 px still scale (a per-row fit like `StreetFallFit.FIT_K` for `p70/appliance_warden_fall.png`, or a redraw);
it shows in his living death too.

### What I saw

- Mulroney (after): from t174 the body is his fall sheet: the pump shotgun flies off up-right, chevrons on the
  sleeve, by t196 he lies on his back with the cap knocked off by his head and the shotgun on the ground past his
  boots; t214 he lies long across the shot (170 px). Before: the patrol cop's own stitch cells (bare arms, no
  shotgun, no cap flying, no chevrons), curled on his side, 138 px.
- Warden (after): his tan hazard suit, the noose pole and the rifle fly as he buckles; he lies on his back with
  the cap off to the side. Before: the same patrol cop stitch body as Mulroney's.
- Trooper (after): blue armour with the rocket pack; the launcher stays drawn in his hands through the buckle and
  flies free as he drops; lies on his back. Before: the SWAT stitch body (helmet, grey-blue).
- The after bodies lie on the other side of the shot than the befores (the street-row cells face the shooter,
  `KillDeathCells.face_of`; the grid faces the fall vector and the stitch whirl, `KillStitchArt.facing`), as a
  generic grid victim always did.
- The loose rifle lying right of the body in both arms is the game's weapon drop, not kill art.
