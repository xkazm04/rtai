# REPORT lane keys, run n28 (2026-11-24 16:40 to 00:40)

DRAFT written in session 4 (20:58); sessions 5/6 finish every section marked TODO.

Branch `n28-keys` from `main` `d0ab9d03a`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls`. Final gate: TODO
(`node tools/gate/run.mjs --rev=HEAD` line and `gate.json` path). Films and stills: `C:\Users\kazda\kiro\gtai-masters\n28\keys\`
(`frames.json`). Builder: in-session Sonnet subagents from 18:03 (builder.mjs's account hit its weekly limit at 17:44).

## What works

1. **Shorter dash cooldown** `dash.cooldown_ticks` 40 -> 24 (`64004a59d`, MILESTONE keys-dash 17:37). Dash 10 ticks + 24 =
   34 ticks press to press, under the shortest 36-tick gap between two troopers' rockets; pinned by
   `test_player_motion_dash.gd::test_shortest_press_to_press_gap_is_burst_plus_cooldown_and_covers_a_rocket_pair`.
   HP lost after 10 s in `pair_dash`: seed 3 48.5 -> 2.7, seed 5 40.5 -> 1.5, seed 1 3.4 -> 3.4
   (`evidence/n28-keys/dash_trace_after.md`). Combat's re-take (film `gtai-masters/n28/combat/films/trooper_pair_32.mp4`,
   1920x1080 60/1 25.0 s, n27 | n28 side by side): at the end n27 HP 49.1 (lost 51, one direct hit) vs n28 HP 94.9 (lost 5).
   Tapes: the scenario suite at 24 ran 68/68 ok (`node tools/tests/run_scenarios.mjs`, 22:25; only a CONTENDED rig_stress
   wall-clock budget under load): no shipped tape or replay moved, nothing re-pinned.
2. **Weapons on their own p70 walk and run grids, edited from the plasma rifle's sheets** (legs and soles the donor's):
   - homing shard `3ea5cf48c` / `6d27d55a0`: 2 images, 16/16 rows raw; foot_slide 32 px/m walk 1.09 / run 5.44 cm.
   - mini-nuke `2f5dde79d` / `82760ae9e`: 2 images; walk 1.52/1.76, run 7.62/8.15 cm (bar 7; see Calls).
   - ray gun `011e504f6` / `7e6918fd3`: walk 0.39/1.56, run 6.35/8.26 cm (plasma rifle 0.60/1.56, 6.69/8.93).
   - molotov, walk only: `347783a4c` / `64b5d9570`: walk hold 0.43/1.56 cm (plasma rifle 0.60/1.56); the sprint answers
     on the stop-gap's bare run through a small `RivetWalk.path_of` fallback (a walk sheet without a run8 sprints on its
     fallback), pinned by `test_rivet_walk_sprint_fallback.gd`; mutate `rivet_walk.gd` lines 59-62: 4/5 killed (80 %).
   Stills `grid_<weapon>_64.png` / `_32.png` (stop-gap | new | plasma rifle). One 32 px/m clip with all five at the same
   tick: `gtai-masters/n28/keys/weapons_grids_32.mp4` (1920x1080, 60/1, 991 frames, 16.5 s; six 640x540 tiles cropped
   1:1 from the captures: homing shard, mini-nuke, ray gun, molotov, the plasma rifle donor, a plasma sword stop-gap tile).
3. **Gloria in brass with a longer nail strip, one-handed** (`e0a82abf0`): concept from n27's A
   (`gtai-masters/n28/keys/gloria_concept_n28.png`: old long | n27 | n28 | pistol); nail strip about 2x n27's, length
   1.20x / 1.33x the pistol's, median gun hue 38.5 deg vs the pistol's 27.5 (brass, not amber); p70 held strips (main,
   diag, left, noflash), held/held_small/icon/pickup, showcase icon and p70, `rivet_muzzle.json` p70 gloria.
   One claw holds it in all 8 facings, the other is free; flash amber/yellow only.

## What does not

- **The p55 sprint collar is not redrawn.** Audit of `p55/rivet_run8.png`: rows 1, 2, 5 draw the rigid collar; rows 3, 4,
  6, 7, 8 (40 cells) draw a twisted rope. Two image edits (n28-09b, 22:11-22:29): the whole-sheet edit moved arms and
  strides and blurred; a five-row edit still drew a twisted rope, softer, with yellow at the visor. The neck-only
  composite kept every pixel outside the masks identical (0 px), but the inside failed the bar, so nothing was committed
  (`evidence/n28-keys/collar_p55.md`, crop `gtai-masters/n28/keys/collar_p55_rows_crop.png`). Drift unchanged (3.83 cm at
  64, n27). A script repaint of the stripes was rejected: character art is generated, never drawn from script shapes.

- Plasma sword: no grid this run (not started; stop-gap).
- Molotov run: three routes failed the look or the stride (full-sheet edit draws run row 1 ~30 % short, foot_slide 10.8 cm;
  a one-row edit fixed the legs but leans the body 6-24 % off the soles; a donor-leg composite leaves a seam, rifle-hand
  remnants and a doubled collar). The run stays on the stop-gap (shipped that way in `347783a4c`).
- Gloria's own walk and run grid (image edits of the pistol's sheets) was not started: she walks on the bare stride with
  the brass gun in the palm (the owner's interim rule). The p55 Gloria held strips are still n27's; only p70 is brass.
- Gloria's left p70 strip: in cells 2 and 3 the muzzle is clipped flat by the cell edge (a few px; fix = wider left cells).
- In-game stills of the brass Gloria at 64 and 32 px/m beside the pistol: TODO (after the gate).

## What blocked or slowed you (minutes each)

- mem-budget wait 53 min (16:44-17:37): every Godot run of the first call waited on the 8 GB cap.
- builder.mjs out of account at 17:44 (weekly limit to Nov 25 22:00): in-session subagents instead, which die with the
  director session, so about one call per 90-minute session.
- Image tool: a job writes its png after 4-6 min but never copies it to `out/` nor exits (hand copy every time); the
  full-sheet ray gun walk returned nothing twice (12-15 min each, ~27 min lost).
- Molotov run: about 40 min across six short calls for a run that does not ship.
- p55 collar: 18 min and 2 images, nothing shipped.
- The Gloria commit's pre-commit hook failed once on `tools/merge/clash.test.mjs` under load (7/7 alone): about 15 min.
- Final gate restarted once (plain -> `--reels`): 2 min.

## Calls for the owner

- Mini-nuke run foot_slide 7.62 cm against a 7 cm bar, accepted: legs are the donor's; on the rig's 3.2 m/s lane the donor
  itself peaks at 7.69. One value puts it back: `walk_grid.by_weapon.mini_nuke: "bare_claw"`. Still: `grid_mini_nuke_64.png`; clip: `weapons_grids_32.mp4`.
- Ray gun shipped with leg IoU 0.80-0.84 on five rows against a 0.85 bar (sole y exact on 96/96 cells, foot_slide better
  than the donor). One value puts it back: `walk_grid.by_weapon.ray_gun`.
- Molotov walks on its own grid and sprints on the stop-gap (three run routes failed). If the owner prefers one look for
  both gaits, one value puts it all back on the stop-gap: `walk_grid.by_weapon.molotov: "bare_claw"`. Still: `grid_molotov_64.png`.
- p70 back rows (facings 4, 7) of the shipped plasma rifle sheet draw the collar with spiral-looking stripes and every edit
  copies them; the owner's pick named p55 only.

## Merge notes

- Chip 1's plate sits on the left screen edge (souls/**, combat's this run); combat's "ATTACK CLAW" box is the bot film's
  dev caption, not the game. For the Director.
- Keys' tables touched: `rivet_motion.json` (`dash.cooldown_ticks` 24, `grid_stride` rows for the new grids),
  `rivet_muzzle.json` (p70 gloria). Code: `rivet_walk.gd` (`RivetWalk.path_of` sprint fallback). Shared, append-only:
  `docs/decisions.md` (dash line), `steam/ai-provenance/2026-11.jsonl`. No `KNOWN_FLAGS` change.
- Root `JOURNAL.md` / `REPORT.md`: keep keys' own on an add/add conflict.

## Next steps

1. **p55 collar**: one facing row per image job at full scale (rows 3, 4, 6, 7, 8: 5 jobs), the p70 bare run row of the
   same facing as image 2, neck-only composite as n28-09b (`gtai-art/rivet-n28/collar_p55/STATE.md`, briefs
   `evidence/briefs/n28-09-collar-p55-sheet.md`, `n28-09b-collar-now.md`).
2. **Plasma sword** grid by the same route (`evidence/briefs/n28-06-molotov-sword.md`); a sword held in one claw may need
   the katana's sheets as donor rather than the plasma rifle's.
3. **Gloria's own walk and run grid** by image edits of the pistol's sheets, then `walk_grid.by_weapon.gloria` -> `gloria`;
   her p55 held strips in brass; the left p70 strip's cells 2, 3 widened (muzzle clipped flat).
4. **Molotov run**: a one-row-per-job edit with the donor's soles fixed by registration (three routes failed; see JOURNAL
   20:18-20:39).
5. **GroundRifle pickup** `ground_rifle_70.png` reads mauve-pink on asphalt in 1080p films (cast's NEED 18:40): a lossless
   check, then one image edit to a browner stock.
6. Item 5 of the brief (not started): the stop-gap back-swing with the held part on the front hand; Gloria's icon and
   pickup at full size; the first chip plate's 4 px overhang (souls/** is combat's file this run: Director).

## Builder ledger

| call | minutes | cost | result |
|---|---|---|---|
| n28-01-dash (builder.mjs) | 69 | $0.59 | accepted (value, test, decision line) |
| n28-02-homing-shard (builder.mjs) | 6 | $0.64 | abandoned: the Sonnet account's weekly limit at 17:44 |
| n28-02b-homing-shard-finish (in-session Sonnet) | 21 | n/a | accepted (grids + evidence) |
| n28-03-nuke-ray | 42 | n/a | accepted-partial (mini-nuke) |
| n28-03c-ray-prep | 15 | n/a | accepted (prep) |
| n28-07-ray-molotov | 47 | n/a | accepted-partial (ray gun) |
| n28-07b..g molotov run (6 short calls) | 35 | n/a | 3 bounced, 3 accepted prep/diagnosis; the run did not ship |
| n28-08-molotov-walk-gloria | 73 | n/a | accepted (molotov walk + fallback code, Gloria brass staged; I re-ran the commit after a load flake) |
| n28-09b-collar-now | 18 | n/a | bounced (art bars) |

Images: 21/60. What I would brief differently: give an art call one row per job from the start (whole-sheet edits moved
poses twice tonight); set a hard "two failed routes = stop" for one weapon instead of six short molotov calls; keep the
in-session builder to one item per session, since it dies with the director's session.
