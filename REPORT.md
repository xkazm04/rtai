# REPORT - lane weapons (d8, 2026-11-06)

DRAFT written 17:25 (iteration 5). The freeze session updates the gate numbers, the exe line and the
branch head below.

Branch `d8-weapons` (cut from main `0bea8b93`). Evidence: `C:\Users\kazda\kiro\gtai-masters\d8\weapons\`
(`frames.json`, 15 entries, best first; `weapons_tilt_set_combined.mp4`, 79 s). Audit:
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

Gates (iteration 5, on a7f6e29d): the director reel headless went `top` 19/19 and `tilt` 19/19, every
chapter all down, 0 SCRIPT ERROR. Unit: 1409 passed, 0 failed. Lint: 15/15. Re-run on 81548c4e: see the
journal; FREEZE: put the final numbers and the evidence run here.

## What does not work / open
- **Electro baton:** none of the 55 parts beats the top-down part at 48 px/m. That is an owner call (below).
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
   Exe: `RTAI.exe -- --armory --ppm=48 --view=tilt --rigs` (+ `--shot-lift=off` for the before); smoke-run on the 17:13 export (16 weapons on the hub floor, 0 SCRIPT ERROR; that export predates the hover, so re-export).

## The exe
`build/export/windows/RTAI.exe` (windows-showcase preset, main scene = the arena). Command:
`APPDATA=C:/Users/kazda/kiro/gtai-d8/appdata/weapons "$GODOT_BIN" --headless --path project --export-release windows-showcase ../build/export/windows/RTAI.exe`.
FREEZE: re-export on the final head and name it here.

## Next steps
- Baton: a pale-wrap regeneration with a brass band, filmed in its chapter; or take the owner's pick.
- Molotov at 48: the bottle in the claw is small. Try size_k 1.2 on its row.
- Electro arc: score the shock's origin frame by frame in the electro_chain chapter.
