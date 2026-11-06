# REPORT - lane weapons (d8, 2026-11-06)

Final, written in the freeze session (iteration 6). Code head `6533af0e` (the back-tank fix), which is
the exported exe; the commits after it touch docs and the journal only.

Branch `d8-weapons` (cut from main `0bea8b93`). Evidence: `C:\Users\kazda\kiro\gtai-masters\d8\weapons\`
(`frames.json`, 15 entries, best first; `weapons_tilt_set_combined.mp4`, 83 s). Audit:
`docs/polish/weapons-tilt.md`. Every change is selected by the view (the `55` pitch row of
`project/data/tables/weapon_held_pitch.json`, or the view's lift via `ShotLift`). Under `top` the art and
FX are today's (unit tests), and `--held-pitch=off` / `--shot-lift=off` give the before under `tilt`.

## What works (with its evidence)
All judged under `--view=tilt` (55 degrees) in the live arena, at 32 and 48 px/m (some at 64), with the
same seed and bot for before and after.

1. **Held art for the angle (all 18 weapons).** Three-quarter "55" held parts (gen55b-h, generated
   fresh from the shipped pickups; tan steel, ink outline, ink grip) for sidearms, long guns, blades,
   heavy, tubes and thrown. They stand up on screen and turn edge-on toward the camera
   (`HeldPitchArt.stand`), get WeaponArt's paper rim and print prep, and have small cells below 56 px/m
   (two-tone for the long guns and the homing shard at 32). The tubes have spent `empty` parts.
   Stills: `tubes_tilt_48`, `blades_tilt_48`, `heavy_tilt_48`, `gatling_tilt_48_regen`,
   `ray_gun_tilt_64`, `plasma_rifle_tilt_64`, `longguns_tilt_32_twotone`, `homing_shard_tilt_32_twotone`.
2. **FX at height (ShotLift).** Rounds fly and hit at gun height with a ground shadow; body hits land
   on the chest, dust stays on the ground (`pistol_tilt_48_shot_lift`). The flame jet leaves the drawn
   wand tip (`flamethrower_tilt_48_jet`). The electro charge gathers on the coil tip
   (`electro_gun_tilt_48_charge`). The reload ring floats above the head (`reload_ring_tilt_48`).
3. **Melee smear in the tilted plane (iteration 5, a7f6e29d).** Under tilt a cut's smear is a pale
   crescent with an inked swept edge, not a faint grey wedge. Katana, plasma sword, chainsaw and baton
   were filmed in their director chapters (`melee_smear_tilt_48_crescent_before_after.png`, plus 64 px/m
   in the combined clip).
4. **Floor pickups (iteration 5, 81548c4e).** Under tilt the gun hovers 0.35 m over its disc, stood up
   for the raised camera, with an ink shadow (`pickups_tilt_48_hover_before_after.png`, 48 + 32 px/m).

Gates. Final evidence run `node tools/evidence/run.mjs --no-bench` on `9b6c1d7a` (code = `6533af0e`), 18:24,
every check PASS: lint 15/15 over 1095 files; unit 1429 passed, 0 failed, 0 skipped; scenarios 52 passed
(headless); parity native == GDScript bit for bit over 1200 steps, planted mutation caught at step 629;
selftest look goldens 11/11 (worst 0.27) and block goldens 5/5 (worst 0.22) within mean 4, no new
off-doctrine accents; export audit release-compile 541 loaded, 0 failed. So `top` did not move. Director
reel headless on `6533af0e`: `top` 19/19 and `tilt` 19/19, every chapter all down, 0 SCRIPT ERROR. Bench
skipped (`--no-bench`): unmeasured.

5. **Molotov (iteration 5, cddcc340):** the 55 bottle is drawn at 1.2x; at 1x it read tiny in the claw at
   48 px/m, and at 1.35x it read as a club (`molotov_tilt_48_size_k.png`).
6. **Every gun at 64 px/m, the close-combat zoom (iteration 6):** aimed and carried, each in the claw
   with grip, body and tip readable (`held_all_tilt_64_aimed.png`, `held_all_tilt_64_carry.png`). The
   sheet found one fault, fixed in `6533af0e`: facing the camera, the flame wand's back tank drew over
   Rivet's visor. It now draws under the rig under tilt (`flamethrower_tilt_64_tank_behind_before_after.png`,
   `--shot-lift=off` = the before; top unchanged). The Gatling ammo box no longer covers the collar either
   (`gatling_tilt_64_box_behind_before_after.png`).
7. **Electro chain arc (iteration 6, scored, no change needed):** in the `electro_chain` chapter the bolt
   leaves the coil tip at gun height and the hop arcs run cop to cop at chest height
   (`electro_chain_tilt_48_arc_before_after.png`).

## What does not work / open
- **Electro baton:** none of the 55 parts beats the top-down part at 48 px/m. That is an owner call (below).
  A third try in the freeze session (pale cream wrap, brass band, no red; gen55i) printed the same as the
  shipped 55 part in its chapter: at 48 px/m the print flattens the band and the wrap into tan and ink.
  Rejected, not committed (`electro_baton_tilt_48_try3_rejected.png`, top row = shipped).
- **Long guns at 32 px/m:** the two-tone cells are better than the re-tone, but still larger than the
  slim top-down silhouette.
- **HUD icons:** not changed. The HUD shows the pickup art, which this lane did not change.
- **Kerf and the 70 sample:** out of scope for this lane. The 55 art is keyed by the pitch row, so a
  `70` row can sit beside it.

## What blocked me
- The image lock was shared with the asset lane. The image.want + lock protocol worked; no waits over
  10 min.
- My private app data's `export_templates` was an empty folder, not a junction, so the first export
  failed. It is fixed: a junction to the shared templates (journal, 17:13).

## Calls for the owner
1. **Gatling under tilt:** the regenerated 55 part (the default) vs the top-down part (`enabled: false`
   on the gatling row of `weapon_held_pitch.json`). See `gatling_tilt_48_regen_before_after.png`.
   Exe: `RTAI.exe -- --weapon=gatling --bot=gunplay --lone --cam=fight --ppm=48 --view=tilt --rigs`
   (+ `--held-pitch=off` for the before). Smoke-run on the 17:13 export: a lone kill, 0 SCRIPT ERROR.
2. **Long guns at 32 px/m:** two-tone small cells (the default) vs the re-tone (drop the ids from
   TWO_TONE in `tools/art/held_pitch_small.py` and re-run it). See `longguns_tilt_32_twotone_before_after.png`.
   Exe: `RTAI.exe -- --weapon=plasma_rifle --bot=gunplay --lone --cam=fight --ppm=32 --view=tilt --rigs`.
3. **Electro baton under tilt:** the 55 cells (the default) vs the top-down part (`enabled: false` on the
   baton row). See `electro_baton_tilt_48_topdown_vs_55.png`.
   Exe: `RTAI.exe -- --bot=reel --reel=director --chapter=electro_baton --loadout=pistol --ppm=48 --view=tilt --rigs`
   (+ `--held-pitch=off`).
4. **Floor pickups:** hover 0.35 m (the default) vs lying stood-up on the disc (`PickupsView.HOVER_M` 0).
   See `pickups_tilt_48_hover_before_after.png`.
   Exe: `RTAI.exe -- --armory --ppm=48 --view=tilt --rigs` (+ `--shot-lift=off` for the before); smoke-run on the 17:34 export, 0 SCRIPT ERROR.

## The exe
`build/export/windows/RTAI.exe` (windows-showcase preset, main scene = the arena). Command:
`APPDATA=C:/Users/kazda/kiro/gtai-d8/appdata/weapons "$GODOT_BIN" --headless --path project --export-release windows-showcase ../build/export/windows/RTAI.exe`.
Exported on `6533af0e` at 18:06 (exit 0, 247 MB + `gtai_sim.windows.template_release.x86_64.dll`); every
item above is in it. Smoke: `RTAI.exe --quit-after 400 -- --weapon=flamethrower --bot=gunplay --lone
--cam=fight --ppm=64 --view=tilt --rigs` exit 0, 0 SCRIPT ERROR. The exe lines in Calls for the owner were
smoke-run on the 17:13/17:34 exports, and the code they exercise did not change after that.

## Next steps
- Baton: tried three times; take the owner's pick (top-down part or the 55 cells).
- The flamer's hose still draws over the body when the tank goes behind (it rides the held view's z).
- The 70 row: the parts are keyed by the pitch row (`weapon_held_pitch.json`), so `view70` (or the next
  run) can add `held_70/` beside `held_55/`; the hover, the lift and the crescent already read the view.
- Long guns at 32 px/m: a slimmer re-cut (fewer side-body px) if the owner keeps two-tone.
