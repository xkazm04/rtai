# REPORT: lane held (d7, 2026-11-05)

Branch `d7-held` (cut from main `1028c15d`; d7-calls merged four times, last `339397ef`).
Evidence: `C:\Users\kazda\kiro\gtai-masters\d7\held\` (`frames.json`) and `evidence/held-*.log`.
Exe: `build/export/windows/RTAI.exe`, exported 17:37 at `acb70e5f` (windows-showcase, boots into the arena).
Every A/B flag below was run in this exe (`--arena=city --rigs --loadout=plasma_rifle`, plain, `--torch-off-arm`,
`--gun-off-claw`): 0 script errors, no unknown-arg warning, and the frames differ from the default
(`evidence/held-it4-exe-flags-ab.png`: default | torch | gun off the claw).

## What works (with evidence)

1. **Hold classes as data.** `project/data/tables/held_classes.json` (+ schema, `HeldTable`): blade, sidearm,
   long_gun, tube, heavy, chainsaw, thrown. Per class: the RigGrip kind, its weapons, the gun and off claw places,
   the claw cell, the anchors (`fore_u`), `wrist_rad`, the walk (`stride_k`, `lean_px`), `two_claw_out`.
   `test_held_classes` (every arsenal weapon in exactly one class, every class has its anchors; 3 planted faults).
2. **Blade** (owner pick combat-notes-1 A, one claw): a low guard, the blade in line with the forearm, turned in
   0.45 rad at the wrist; the swing arc is measured from that line, so anticipation, smear and follow-through stay.
   **`--two-hand-grip` and all its code are deleted.** `blade_hold_ab_48ppm_target.png` (r2_w7 beside before/after),
   `blade_hold_ab_32ppm_city.mp4`, `blade_hold_ab_64ppm_slow.mp4`.
3. **The off claw on two-claw weapons** (owner note on cast-3): Rivet's off forearm is a welding torch whose art ran
   past the barrel. While a long gun, tube, Gatling or flamer is aimed, it swaps to a plain forearm and a closed claw
   clamps the barrel. `long_gun_offclaw_ab_64ppm_target.png`, `long_gun_offclaw_ab_32ppm_city.mp4`.
4. **The claws stay on the long gun** (iteration 3): the beside-the-helmet shift had moved every aimed rifle or tube
   15-18 px (128 px/m) off the gun claw; the claws now take the same shift. Gap 0-2 px on most frames.
   `long_gun_claw_follow_ab_64ppm_target.png`, `_32ppm_city.mp4`, `_64ppm_slow.mp4`.
5. **Class sizes on the 1.1x Rivet** (look-4 over cast-3: guns keep their class size, `held_size_ref 0`); sidearm
   `held_scale` 1.5 -> 1.2. `sizes_after_cast1_48ppm_sheet.png`, `sidearm_size_ab_48ppm_sheet.png`.
6. **The class walk**: heavy 0.85 strides and leans back 10 part px, chainsaw 0.9 / 6, long gun 0.95.
   `heavy_walk_ab_64ppm.mp4` (subtle). Heavy at the hip with the off claw: `gatling_hold_merged_48ppm_strip.png`.
7. **The whole arsenal in motion**, all 18 weapons, on the merged tree (look-8 tan guns):
   `arsenal_cycle_32ppm_city.mp4` (180 s, 32 px/m, nine `--bot=arsenal` runs on the city block, 0 script errors) and
   `arsenal_cycle_32ppm_sheet.png` (one row per run).
8. **Combat holds**: director reel (`--rigs --bot=reel --reel=director --loadout=pistol`) 19/19 chapters down,
   0 SCRIPT ERROR on every hold commit and on the final head (`evidence/held-it1..it4-reel-director.log`).
   Full evidence run on `65c15aa0` (`evidence/held-it4-evidence.log`): lint 13/13, unit 1110/0, scenarios 52/52,
   parity exact (planted caught at 629), look goldens 11/11 + block 5/5 within mean 4 (worst 0.27):
   **no golden moved, no re-bless**. (A scenario run made during filming had `scenario_rig_stress` 1.17 ms over its
   1.0 ms budget. That was contention: it passed alone and in the evidence run.)
9. **The A/B flags work in the exe** (`--torch-off-arm`, `--gun-off-claw`). They are now known launch flags, with a
   unit case and a planted fault caught.

## What does not work yet (said plainly)

- **The long gun is not yet the r2_w5 hold.** The target holds every gun ahead of the chest on the centre line; ours
  rides beside the gun shoulder. Moving the line forward with three numbers hung the gun off the body (rejected 16:19);
  it needs the carry and the helmet clearance reworked together.
- **The off claw is pale on a pale body**: at 32 px/m it is a few pixels. look-8's tan guns help a little. No new
  claw art was drawn (no Codex round this day; the mirrored existing claw stands in).
- **Chainsaw `two_claw_out`**: built and tested, but **no visible change** in the arena: the arena always feeds Rivet
  as aiming while a weapon is out, so the chainsaw was already in both claws (the 64 px/m A/B was pixel-identical; the hold as it is:
  `sidearm_chainsaw_hold_64ppm_slow.mp4`, right half).
  The same fact means the not-aiming carry (RivetCarryAngle) never shows in `--arena` / `--arena=city`.
- **Heavy walk**: the 10 px lean barely shows.
- **The off claw cannot read as gripping yet**: it is one sprite drawn over the weapon. The registry rule
  (`depth-ordered-layered-art`, "wrapping is the common cause") says a claw closed around a grip must be two layers,
  the back jaw under the weapon and the front jaw over it. The drawn grip art should come as that pair.
- **Not done**: an arena-pit segment in the whole-arsenal clip. Sidearm and chainsaw have 64 px/m after-clips
  (`sidearm_chainsaw_hold_64ppm_slow.mp4`), but no 32 px/m before/after clip.

## Calls for the owner

Each: options, the default built, how to see it. Exe lines assume `build/export/windows/RTAI.exe` (showcase preset,
boots into the arena; args after `--`). Rivet carries one weapon per slot (`rivet_arsenal.json` classes: 1 sidearm,
2 two-hand long, 3 heavy/shoulder/hip, 4 thrown; the katana goes in slot 2 and the rocket launcher in slot 3).
A loadout keeps the last weapon of each slot, and every other weapon lies on the arena hub floor (ArenaArmory).
Every line below was run in this exe at 17:58 (headless, 240 ticks): 0 script errors, no unknown-arg warning, and
Rivet carried the named weapons.

1. **Blade wrist angle.** A: 0.45 rad in toward the centre line (built). B: 0 (straight ahead along the forearm).
   One value: `held_classes.json blade.wrist_rad`. See `blade_hold_ab_48ppm_target.png`;
   `RTAI.exe -- --arena=city --rigs --loadout=katana`.
2. **look-4 over cast-3** (your 11:43 and 11:46 picks conflict). Built: look-4, guns keep class size
   (`held_size_ref` 0). Alternative: guns scale with Rivet (`held_size_ref` 1.2). `sizes_after_cast1_48ppm_sheet.png`.
3. **Sidearm size on the 1.1x Rivet.** A: `held_scale` 1.2 (built). B: 1.5 (the old one; as long as the forearm).
   `sidearm_size_ab_48ppm_sheet.png`; `RTAI.exe -- --arena=city --rigs --loadout=pistol`.
4. **The off claw on two-claw weapons.** A: plain forearm + closed claw on the barrel while aiming (built). B: the
   welding torch stays (`--torch-off-arm`). `long_gun_offclaw_ab_*`;
   `RTAI.exe -- --arena=city --rigs --loadout=plasma_rifle,gatling` (long slot + heavy slot) vs the same `--torch-off-arm`.
5. **The claws follow the long gun beside the helmet.** A: follow (built). B: the gun floats a claw-width off
   (`--gun-off-claw`). `long_gun_claw_follow_ab_*`;
   `RTAI.exe -- --arena=city --rigs --loadout=plasma_rifle,rocket_launcher` vs the same `--gun-off-claw`.
6. **Heavy walk strength.** Built: lean 10 part px, stride 0.85 (subtle). Stronger is one value (`heavy.lean_px` 25?).
   `heavy_walk_ab_64ppm.mp4`; `RTAI.exe -- --arena=city --rigs --loadout=gatling`.
7. **Next step for the long gun**: a drawn "claw closed around a grip" and a centre-line hold toward r2_w5 (new art
   through Codex + a carry rework), or keep the shoulder-side hold. Your pick sets tomorrow's first item.

## Next steps

- The centre-line long-gun hold (RivetCarryAngle + helmet clearance + `across`/`gun_reach` together).
- Drawn claw-around-grip part art (Codex, arms/claws only, under image.lock) as a back jaw (under the weapon) and
  front jaw (over it) pair, so the claw wraps the grip (registry `depth-ordered-layered-art`); a darker off-claw tone.
- 32 px/m before/after clips for sidearm and chainsaw, and an arena-pit segment in the whole-arsenal clip.
- A not-aiming carry in the arena feed (walk with the gun lowered), which would also make `two_claw_out` visible.
