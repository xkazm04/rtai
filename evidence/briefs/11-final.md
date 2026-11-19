# Package 11 (guns lane, n19): last package before the 07:30 freeze

Your 7b session hit the 75-min cap at 06:09 during the `rivet_mag_view.gd` mutate run (it was at 108/151; at least the line-135 `>=` -> `>` boundary survived). All four 7b commits are in (7a696962f electro, a5b02604b machine_pistol, 9bed8f09c hand_cannon, 00b00b7b9 mag view); I looked at every zoom sheet and accepted them. Holes 3 (the rifle rack, a Call).

**Hard stop: everything committed by 07:20.** Commit after each item; leave no uncommitted product file. Same law as before (lane APPDATA, `--position 0,1440` for windowed runs, staged per path, quick gate before each commit, `--no-godot` allowed only for the known standalone `Log` error, and say so).

Do in this order, skip what does not fit:
1. **Walk/run informational column** (brief 09 item 1, `evidence/briefs/09-polish.md`): `walk`/`run` per pitch in the audit txt+json, NOT in the ratcheted total, a separate `Informational gaps N` line; `evidence/arsenal/matrix_after_11.txt` (+ .json). Ratchet test stays green.
2. **Reload composite residue** (brief 10 item 4, `evidence/briefs/10-collar-bands.md`): the grey square behind the gun at the wrist on hand_cannon p55 reload 1 and machine_pistol p55 reload 1/7, the speck in machine_pistol p55 reload 5, the light smear on electro_gun p70 reload 7. Refill from the base reload figure's own pixels in `tools/art/reload_composite.py` (by script, byte-reproducible), re-cut, re-shoot the three weapons' `<gun>_<pitch>_reload_zoom.png`.
3. **Re-shoot off-centre turning clips** (brief 09 item 2) for assault_rifle, homing_shard, ray_gun, mini_nuke, rocket_launcher with the centred kit (32 px/m, p55, firing through all eight octants), replacing the old clip in each weapon's `frames.json`.
4. **Mutation**: `node tools/mutate/mutate.mjs --file=project/features/player/rivet_mag_view.gd --max=40` and a test that kills the line-135 boundary survivor; then brief 09 item 3 (`arsenal_turn.gd` 5/10, `rivet_gun_diag.gd` 7/8) only if before 07:10. Quote killed/(killed+survived) for each run you finish.

Collar bands (brief 10 items 1-3) are NOT in this package.

Report, short: commits, the matrix's hole and informational lines, which zoom sheets and clips to look at, mutate scores. If you are cut off, the commits speak for you: commit early.
