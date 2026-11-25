# Brief n29-combat-02e-amber-on-screen: make quest 1's electric current and the tazer stripe print amber

Lane `combat`, branch `n29-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadline: see "Wall clock" at the end (binding).** Never stop to ask; fix lint/format findings in
your own edit and go on. No amend, no rebase, no push. Read `AGENTS.md` briefly.

## Where it stands
- c2a (`evidence/n29/red/fire.md`): the look prints every non-ink colour to its nearest palette ink, and amber's nearest
  is vermilion. Fix shipped for the FX view only: `PrintStage.fx_material()` (`project/core/render/print_stage.gd`), the
  `amber_ink` uniform in `project/assets/shaders/look_d4_item.gdshader`, off switch `look_profiles.json` `fx_amber_ink`.
- c2c (`evidence/n29/red/electric.md`, commits 330ad6592, f99ec6736): `CurrentLook`
  (`project/boot/collect_call/view/current_look.gd`) draws Mertz's tazer prongs (cast_view) and the burst arcs (fx_view)
  as ElectricArc strokes, the stripe flat `Ink.AMBER`. On screen (48 px/m stills `red_elec_*_pair_64.png`) the current
  prints CREAM (the a0.5 / a0.18 amber halo strokes are lost in the print; only the cream core survives) and the barrel
  stripe still prints VERMILION (cast_view is under the plain item print, no amber ink).

## What
A. **Amber reaches the screen, narrowest scope.** (1) The cast view (Mertz's stripe, prongs): give it the amber ink the
   same way as the FX view (its own print copy, or the existing amber-ink material if the view can take it), behind the
   same or a sibling `look_profiles.json` switch. Prove with a pixel diff of the same frames (tazer 15874, burst 16132,
   tuckin 16393, + one frame with Rivet's collar and a cop in shot) that nothing outside the electric boxes changed:
   Rivet's collar, cops, pickups, Mertz's gloves must not move (they are the cast lane's art). (2) The halo: on a printed
   view a translucent halo dissolves; give `CurrentLook` (and only it) an opaque amber mid stroke (alpha 1.0, between core
   and the 4.5 px width) so the current prints cream core + amber body. Keep ElectricArc's own look untouched elsewhere.
   Tests in `project/tests/unit/test_collect_call_current.gd`: the plan has an opaque amber stroke wider than the core.
   `run_unit.mjs --changed` green, quick gate, commit with ONE decisions line.
B. **After2 stills** at the same three ticks with c2c's grabber (`evidence/n29/red/electric_*.txt`, `build/n29elec/`),
   pairs before|after2, reddish px table column in `evidence/n29/red/electric.md`; LOOK: prongs and arcs amber+cream,
   stripe amber. Commit.
C. **Film** `C:/Users/kazda/kiro/gtai-masters/n29/combat/films/red_elec_mertz_after.mp4` 1920x1080 60 fps 15-40 s
   (ffprobe), frames.json entries (re-read before writing). Mutate `--file=project/boot/collect_call/view/current_look.gd
   --max=12 --tests=test_collect_call_current` (10 min budget). Fold the copied `_serial` back to one source if cheap.
D. `StageView._bolt_robot` has no caller (TUCK-IN on screen is the `tuckin_crate` PNG, a dark bolt): list in the note;
   do not delete code that is not yours to delete unless lint flags it.

## Repo law, allowlist
APPDATA `C:/Users/kazda/kiro/gtai-n29/appdata/combat`, `GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`,
`GTAI_GODOT_EST_MB=1000` (600 headless), d3d12, windowed only at `--position 0,1440`, Godot only through runGodot, one
Godot for the lane, never kill what you did not start. Quick gate before commits; hook up to ~12 min; kill_reel break
test fail = Godot `--import`, commit again; never skip the hook. Typed GDScript, ~200 lines, functions <= 40 lines.
Stage per path; banned: stash, `add -A/./-u`, `commit -a`, `reset --hard`, amend, rebase, push. Trailer
`Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>` (or Opus if you are Opus).
Allowlist: `project/boot/collect_call/view/{current_look,cast_view,collect_call_view}.gd`, `project/core/render/print_stage.gd`,
`project/assets/shaders/look_d4_item.gdshader` (no change to the default when the switch is off),
`project/core/render/look_profiles.gd`, `project/data/tables/look_profiles.json` + schema (one key), tests under
`project/tests/unit/`, `docs/decisions.md` (one line), `evidence/n29/red/**`, `build/**`, `C:/Users/kazda/kiro/gtai-masters/n29/combat/`.
Forbidden: every PNG, other tables, `ink.gd`, the HUD files, `project/boot/prologue/**`, quest 1 scripts/rules/tapes,
other worktrees, root `JOURNAL.md` / `REPORT.md`.

## Report and END (short)
Commits; the ink scope; the diff counts outside the boxes; px table; pairs/film + ffprobe; mutate; what was left.
