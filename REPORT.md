# REPORT: d7-calls (day run 2026-11-05)

Lane `calls`: flip the defaults the owner changed on the Owner Calls page (2026-11-05 11:40-11:50) and build
the two unbuilt picks. Branch `d7-calls`, cut from main `1028c15d`. Evidence: `M` =
`C:\Users\kazda\kiro\gtai-masters\d7\calls\` (`frames.json` lists the stills and clips, newest first).
Every old default stays one flag or one data value away.

**Status (iteration 5, 17:17): complete.** Every call in the brief is built, gated and filmed; the exe is
exported. A later session only re-exports and re-gates if the branch moves.

## What works (with evidence)

| Call | Commit | New default | Old default back with | Evidence (M/) |
|---|---|---|---|---|
| cast-1 Rivet 1.1x the crowd | 16272697 | `RivetPlan.FORMS[FORM_BASE].x` 0.89 | `--rivet-form=wide` (or the value 0.97) | `frames/cast-1-8-9-city-ab-32-48ppm.png` |
| cast-8 plain head | 66bf4fbe | `PartMaterials.HEAD_LOD_FILL` 2 (no visor slot) | `--rivet-visor` | same still (32 px/m row) |
| cast-9 light tan | 66bf4fbe | `CORE_TAN` 0.6 | `--rivet-tan=1` | same still; quest 1 sprites re-captured: `frames/cast-quest1-*.png` |
| look-3 weapon FX in ink | 42feb65c | `weapon_art.json fx_colour_dir ""` | `--fx-colour=on` | `frames/look-3-12-14-reel-ab-32ppm.png`, `look-reel-{before,after}-32.mp4` |
| look-5 alley floor pale paper | 42feb65c | AlleyHook adds no print zone | `--alley-print=on` | `frames/look-5-alley-ab-48ppm.png`, `-32ppm.png` |
| look-7 pickups on the paper disc | 42feb65c | `PickupsView.disc` true | `--pickup-disc=off` | `frames/look-7-pickup-disc-ab-32ppm.png` (`--armory`) |
| look-12 shard lozenge | 42feb65c | `shard.png` | `weapon_art.json` art `shard_arrow.png` | `frames/look-12-shard-ab-32ppm.png` (range station, in flight) |
| look-14 flame tongues | 42feb65c | `projectile_fx flame` | `flame_cone` | `look-reel-after-32.mp4` |
| look-18 Gatling true width | 42feb65c | `cross_k` 1.0 | `cross_k` 1.3 | `frames/look-18-gatling-ab-32ppm.png` |
| ghost-powers-3 Dent steers from afar | e419a047 | `ghost_attacks.json dent.ride` 0, the car drives to the aimed point | `dent.ride` 1 | `frames/ghost-powers-3-dent-ride-ab-32ppm.png`, `dent-standoff-city-32ppm.mp4`, `-64ppm-halfspeed.mp4`, `frames/ghost-powers-3-dent-tether-32ppm.png` |
| ghost-powers-5 Dent locked until his act | e419a047 | `ghost_forms.json` `unlock` per ghost (dent `act_dent`); lock on only in quest 1; quest 1 `ghost_cars` [] | `--ghosts-free`; the old car list is `Quest1GhostStreet.CARS` | `frames/ghost-powers-5-quest1-live.png` + `quest1-dent-locked-live.mp4` (shipped quest 1, real input: G goes Tonnage -> Kerf, Dent's slot a padlock), `frames/ghost-powers-5-hud-lock-ab.png` (vs `--ghosts-free`); scenario `scenario_quest1_dent_lock` (planted `plant_ignore` caught), unit `test_ghost_locks` 6/6 |
| look-8 warm tan ink for held guns | 83fe0d5c | `PartKind.GUN`, `print_part gun_tan` 1, `gun_ink_hi` 0.90, `gun_edge` 2.2 px ink outline | `--gun-grey` | `frames/look-8-gun-tan-ab-32ppm.png`, `-ab-48ppm.png`, `look-8-gun-tan-closeup-steps.png`, `look-8-gun-tan-reel-32ppm.mp4` |

Combined clip: `M/today-defaults-city-32ppm.mp4` (28 s, city block, director reel, pistol to flamethrower).

Gates on 83fe0d5c (`node tools/evidence/run.mjs --no-bench`, `evidence/evidence-it5-look8.log`): lint 13/13,
unit 1097/0, scenarios 52/52, parity exact (planted caught at 629), look goldens 11/11 worst 0.27 + block 5/5
worst 0.22. No golden moved on any commit, so no re-bless was needed for any call (Rivet, held guns and FX are a
small part of the golden frames). Combat: the director reel brings down every
chapter (19/19 on e419a047 headless; 19/19 on 83fe0d5c in the city block at 32 px/m, 0 SCRIPT ERROR,
`evidence/reel-director-city-it5.log`).

Fix found late (2a28d331): `--ghosts-free` never reached quest 1 (`LaunchArgs.has()` answers only for
`KNOWN_FLAGS`); added it and the cast old-default flags, with a unit case that catches the fault (planted: 1
failing). Unit 1098/0, lint 13/13, scenarios 52/0 (`evidence/scenarios-it5-flags.log`).

## The exe (exported 17:22 on 2a28d331; re-export if the branch moves)
- Arena + city block: `build\export\windows\RTAI.exe` (preset `windows-showcase`; boots into the arena with the
  armory; headless boot tests 0 SCRIPT ERROR: no args, the director reel, the Dent city showcase).
  - Today's defaults in motion: `RTAI.exe -- --bot=reel --reel=director --loadout=pistol` (add `--arena=city`
    for the city block). The old look in one go: add `--rivet-form=wide --rivet-visor --rivet-tan=1 --gun-grey
    --fx-colour=on --pickup-disc=off` (shard, flame cone and Gatling width are data values, not flags).
  - Pickups on the disc: `RTAI.exe` (armory) vs `RTAI.exe -- --pickup-disc=off`.
  - Alley: `RTAI.exe -- --start=alley --ppm=48` vs `... --alley-print=on`.
  - Dent from afar: `RTAI.exe -- --arena=city --bot=ghosts --ghost=dent` (every ghost free in the arena).
- Quest 1 (Dent locked, no parked ghost cars): `build\export\windows-quest1\RTAI.exe` (preset `windows-slice`;
  boots to the title, 0 SCRIPT ERROR). Title -> Start, tap G: Dent is skipped and shows a padlock.
  `RTAI.exe -- --ghosts-free` = the old default (every ghost pickable).

## What does not work / not done
- The Gatling prints ink, not tan, at game zoom (call 8).
- Dent's 64 px/m close-up loses the ram and blast off frame by default (call 2; `--cam=car` fixes it, not the
  default).
- Bench not run (contended machine all day; no perf claim from this lane: every change is view or data only,
  except Dent's steer point, which is sim and covered by the quest 1 and ghost scenarios).

## Calls for the owner
1. **look-8 gun tan.** A (built): tan plates, ink grip/muzzle, 2.2 px ink outline. B: the old grey print
   (`--gun-grey`). C: more tan, less ink (`print_part.gdshader gun_ink_hi` 0.95: reads as a tan blob at 32 px/m,
   `M/frames/look-8-gun-tan-closeup-steps.png` middle column). See: `RTAI.exe -- --bot=reel --reel=director
   --loadout=pistol` vs the same `-- ... --gun-grey`.
2. **Dent's camera.** Steering from afar, the camera stays on Dent; at 64 px/m the seized car's ram and blast
   leave the frame (riding kept them in); at 32 px/m they stay in frame. A: as built (camera on Dent). B: the
   car camera that already exists as the dev flag `--cam=car` (frames Rivet and the seized car, holds 1 s on the
   blast; view only): tether, ram and blast stay in frame at 64 px/m. Making B the default for Dent is one line
   in `TonnageHook` (and quest 1 would need the same wiring). See `M/dent-standoff-city-64ppm-halfspeed.mp4` vs
   `M/dent-carcam-city-64ppm.mp4` (still `M/frames/ghost-powers-3-dent-carcam-64ppm.png`);
   `RTAI.exe -- --arena=city --bot=ghosts --ghost=dent --ppm=64` vs the same with `--cam=car`.
3. **Dent's steer point.** With `ride 0` and the old fixed 14 m point the car overshot its targets, so the car now
   drives to the point the cursor aims at (pad: 14 m). A: cursor reach (built). B: fixed 14 m (one line in
   `DentStage.drive`). See `RTAI.exe -- --arena=city --bot=ghosts --ghost=dent`.
4. **cast-8 "plain cream head".** Built as "no visor slot", and the head keeps the core's light tan (n5-cast's
   Call 9 A), because a cream head on a tan torso would be a third look nobody judged. B: a cream head
   (`PartMaterials` head kind out of the tan set, one line).
5. **Held gun length on the smaller Rivet** (cast-1): held guns follow `plan.size_k`, so they draw 0.74x the class
   size; the pistol still reads long against the smaller body at 32 px/m. The held lane owns held sizes.
6. **look-5 alley.** At 48 px/m (the alley's zoom) the lane prints as pale warm paper instead of mid concrete;
   cracks, splats, puddles and the cops read on both (`M/frames/look-5-alley-ab-48ppm.png`); at 32 px/m the step
   is small (`-32ppm.png`). A (built): pale paper. B: `--alley-print=on`. See
   `RTAI.exe -- --start=alley --ppm=48` vs `... --alley-print=on`.
7. **look-14 flame tongues** print vermilion + cream (fire is danger, on doctrine); the old colour cone was
   yellow-orange. See `M/look-reel-before-32.mp4` vs `M/look-reel-after-32.mp4` (flamethrower chapter).
8. **look-8 x the Gatling's small art.** Below 56 px/m a held gun is its pre-inked `parts.small`; the Gatling's
   is 63 % near-black, so it prints ink, not tan, at game zoom (`M/frames/look-18-gatling-ab-32ppm.png`); the
   pistol and rocket print tan. A (built): leave it (a heavy gun reads dark). B: re-tone `gatling/held_small.png`
   lighter (the held lane's `held_small.py`).

## Next steps
- The owner's verdicts on the calls above; each flips with the flag or value named there.
- If the owner keeps the tan guns: give the dark small held parts (Gatling first) a lighter re-tone so they print
  tan at game zoom too (held lane's `held_small.py`), or a per-weapon `gun_ink_hi`.
- When the act quests land, `Quest1Session.acts_done` comes from the save, not a static (ghost-powers-5 re-check).
- Bench the branch on an idle machine (every change here is view or data, except Dent's steer point).
