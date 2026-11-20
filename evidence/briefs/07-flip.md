# Brief 07 (lane tonnage): the last package before the freeze: RamWake scope fix, leftovers, the look flip

HARD TIME LIMIT: everything committed by 06:00 (about 28 minutes). Stop at 05:58 whatever state you are in; a half item stays uncommitted
and is named in the report. Plate: `C:\Users\kazda\kiro\gtai-masters\n20\concepts\tonnage_b.png`.

All rules of briefs 03-06 still bind: no amend, no rebase, no squash, no stash, no `add -A/./-u`, no `reset --hard`, never push; a fix is a
NEW commit; stage per path; `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/tonnage`;
`GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`; `--rendering-driver d3d12` to render;
`--position 0,1440` on windowed runs; one Godot process at a time; kill only by PID; visual only (no powers.json number, hit box, reach,
sim/replay/parity/bake digest moves). Mutate `--max=40`, and only if time remains after item 3.

## 1. RamWake: gate it at the spectral body, not inside `strength()` (10 min)
Brief 06 put `SPECTRAL_GAIN` inside `RamWake.strength()`, keyed on `GhostLook.spectral(&"tonnage")`. But `RamWake.draw` has TWO callers:
`project/features/souls/tonnage_view.gd` (ghost arena, the spectral body with the armed fist) and
`project/boot/collect_call/view/cast_view.gd:202` (quest 1: the grown Rivet sprite, HaulerLook, no spectral body, no armed fist).
Once the tonnage row is flipped to spectral, quest 1 would lose its only ram tell. Fix: `strength()` back to look-blind; the spectral
gate moves to `TonnageView._draw` (`if not _spectral or RamWake.SPECTRAL_GAIN > 0.0:` around the `RamWake.draw` call, or pass a gain
argument; keep it one const to bring back). `cast_view.gd` is not ours: do not edit it. Tests: `test_ram_wake.gd` — strength is
look-blind (same value under SPECTRAL and LEGACY overrides); a TonnageView-level assert (or a small static helper
`TonnageView.wake_on(spectral) -> bool` you test) that spectral draws no wake and legacy does.

## 2. Leftovers from brief 06 (only those named here by the director, at launch time)
Do 1 and 3 FIRST; these two only if time remains after the flip commit (each its own commit):
a. Double ground glow (seen by flight): under spectral our `TonnageGlow` halo in `tonnage_rig.gd`/`tonnage_glow.gd` draws a ground
   glow ON TOP of flight's teal pool. Keep the body fill; drop or cut our GROUND halo to a value that leaves one pool (one const).
   Before/after still at tick 72, p70, 64 px/m: `C:/Users/kazda/kiro/gtai-masters/n20/tonnage/tonnage_glow_pool_64.png` / `_before.png`.
b. The morph film poster `tonnage_morph_32.jpg` shows only the burst ring (no golem). Re-cut the poster at a mid-IN tick where the
   golem is half risen (ffmpeg from the existing mp4; no re-film).

## 3. The look flip (the owner's rule: body, flight, all attacks complete in both tilts, filmed)
Set the `tonnage` row's `"look"` in `project/data/tables/ghost_forms.json` from `"legacy"` to `"spectral"`. Only that value. Then:
- `node tools/tests/run_unit.mjs` (FULL, not --changed: the default look changes what many tests see). Any test that assumed the legacy
  Tonnage by default: give it `GhostLook.override_for_test(GhostLook.LEGACY)` + `reset_for_test()` in after_each ONLY if the test is
  about the legacy body (that is ours to keep working); if it is another lane's or flight's test, do NOT edit it: write
  `NEED <lane>: <test file> <why>` in the report, revert the flip (a new commit) and stop.
- `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd` green (no digest moves; the flip is view-only).
- `node tools/lint/lint.mjs` green.
- Look goldens: if a look golden moves because of the flip, it is ours to re-bless ONLY if it shows Tonnage; name it in the report.
- One `docs/decisions.md` line (append): `- [2026-11-20] DECISION tonnage look: spectral Press Golem is the default (body, hover, smoke
  column, slam clap, armed ram, both tilts filmed); legacy stays one value away (ghost_forms.json tonnage look) and via --ghost-look=legacy.`
Commit the flip on its own: `Make the spectral Press Golem Tonnage's default look`.

## Report
Commits (sha + line), checks run and results (counts), NEED lines, what is not done. Keep it short.
