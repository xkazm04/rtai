# Brief 04 (lane tonnage): finish the step films, then make him glow and arm earlier

You are continuing a killed session (brief `evidence/briefs/03-films.md`, read it first: its rules all still bind).
That session committed up to `d49632241` and left in `C:\Users\kazda\kiro\gtai-masters\n20\tonnage\`:
`tonnage_move_32.mp4/.jpg`, `tonnage_attack_32.mp4/.jpg` (5 s each, 1920x1080, two panels), the stills
`tonnage_plate_game_64.png`, `tonnage_pound_32.png`, `tonnage_raise_tilts_64.png`, `tonnage_raise_top_32.png`,
`tonnage_ram_lead_64.png` (tick 253), `tonnage_ram_contact_64.png` (tick 259), `tonnage_rest_tilts_64.png`,
`tonnage_south_32/64.png`, each with a `_legacy` twin, plus `build/tonnage03/` scratch. Its findings: POUND at tick 123,
first ram hit at tick 259, p70 spectral height 312 px vs legacy 313 px at 64 px/m. Reuse all of it; do not redo it.

Plate: `C:\Users\kazda\kiro\gtai-masters\n20\concepts\tonnage_b.png`. Look at it before item 2 and again at every still.

**Git: no `--amend`, no rebase, no squash, a fix is a new commit.** Stage per path; no stash, no `add -A`, no
`reset --hard`, never push. Merging `n20-flight` is allowed (only that branch); after a merge repeat 03 item 0 (one body).
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/tonnage`;
`GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`; `--rendering-driver d3d12`
for renders; windowed runs `--position 0,1440`; ONE Godot process at a time; free your own processes by PID, never by name.
Visual only: no sim, replay, parity or bake digest moves; `powers.json`/`ghost_attacks.json` and `GhostRecoil.LEAN_BY_FORM`
untouched. You may edit only `tonnage_*`, `hauler_*`, `ram_*`, `slam_debris.gd`, `plate_sparks.gd`, `art/tonnage/**`,
the Tonnage files under `art/view/`, tests named for them, and the `tonnage` row of `ghost_hover.json`.
Typed GDScript, files under 200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`.
`tools/godot/check.mjs` fails on unchanged files (known, not yours): use `node tools/tests/run_unit.mjs --changed` + `node tools/lint/lint.mjs`.

## 1. Finish 03 (do this first, commit nothing for it except docs if any)
- `tonnage_close_64.mp4` + poster `.jpg`: 5 s at 64 px/m, both panels (70 deg above, top view below), framed on him,
  covering the RAISE -> POUND -> LIFT of one slam. Same encoding as the others (H.264, yuv420p).
- `frames.json` (8 to 15 entries, best first, `[{ "file", "title", "ppm", "before", "note" }]`), the plate-beside-game
  still first, `before` = the `_legacy` twin's file name. Delete scratch renders frames.json does not reference
  (keep `masters/`, `scratch/rig-review/`).
- `node tools/mutate/mutate.mjs --file=project/features/souls/tonnage_pose.gd` (commit-first rule: it runs at HEAD).
  Report killed/(killed+survived). If the score is under 60%, add tests that kill the named survivors (commit them).

## 2. He must glow (the plate's body is lit from within; ours reads as opaque painted metal)
In the plate the torso and arms are luminous teal: bright inner light along hoses and plate edges, a soft teal haze
around the silhouette, the ink still crisp. In game (`tonnage_plate_game_64.png`) the cell reads as solid paint and the
`_glow` under it is invisible. In `tonnage_spectral.gd` (and `tonnage_rig.gd` for the top-view parts, same treatment):
- an additive light pass: a second draw of the same cell/parts with `CanvasItemMaterial.BLEND_MODE_ADD`, teal
  (`HaulerLook.TEAL`), low alpha, so fills brighten while the black ink stays black;
- the soft teal halo around the body clearly visible on asphalt at 32 and 64 px/m (raise its alpha/size until it is,
  but it must not wash out a guard standing next to him);
- keep the existing translucency (0.88; 0.55 during POUND/LIFT so victims show).
Put every value in one named const block (`GLOW_*`) so it is one-value tunable, and a dev A/B switch only if one already
exists in the rig (do not add a launch flag). Before/after: same tick, same zoom (rest tick 72, p70, 64 px/m, and top
view 32 px/m) as `tonnage_glow_64.png` / `tonnage_glow_64_before.png` (and `_top_32`). Check: guards beside him still
read; red blood still reads red, not brown; no teal on anything but him and his tail/pool.

## 3. The ram's armed fist must show well before contact
Today `TonnagePose.armed_k` follows `sample.ramming` (the sim's > 3 m/s state) at 0.25 per tick, so in the attack take
the armed pose is visible only 6 ticks (253) before the first ram hit (259): the bare minimum. Add a visual anticipation
that changes no sim value: start blending the armed pose in from the planar speed itself (say from 2.4 m/s, full at
3.0 m/s, consts `ARM_FROM_MPS`, `ARM_FULL_MPS`), and keep it full while `ramming`. Lean suppression (`lean_k`) must follow
the same armed state. Unit-test the ramp (below, mid, full, and hold while ramming). Then measure in the attack take:
the first tick the ARMED column shows vs the contact tick. Target >= 12 ticks. Stills: `tonnage_ram_lead_64.png`
re-rendered at contact-12 and contact-6, with legacy twins.

## 4. The recoil pop
03 noted the RECOIL column is drawn smaller than the CRUISE column. Measure the opaque bbox height of RECOIL vs CRUISE
for each facing row in both tilts (p70, p55). If a row is under 0.92 of CRUISE, compensate it with a per-column scale in
`tonnage_spectral.gd` (data, one const array), and show a before/after pair of a hit on him (cell CRUISE -> RECOIL)
at 64 px/m. Report the ratios.

## 5. Re-film
After 2-4, re-render `tonnage_move_32`, `tonnage_attack_32`, `tonnage_close_64` (+ posters) with
`--ghost-look=spectral`, and update frames.json. Run `node tools/tests/run_unit.mjs --changed` and `node tools/lint/lint.mjs`
before each commit; both green.

Report: commits (sha + one line), the mutate score, glow const values, armed lead ticks (first ARMED tick, contact tick),
recoil ratios per row, film/still paths, anything not done and why.
