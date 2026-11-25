# Brief n29-combat-02c-red-electric: Mertz's tazer, the burst arcs and the TUCK-IN bolt from vermilion to amber current

Lane `combat`, branch `n29-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadline: see "Wall clock" at the end (binding). At the hard stop write your report and END, even
mid-task.** Never stop to ask: at a fork pick what best serves the owner's words, write it in your report, go on. Fix lint
and format findings in your own edit and go on. No amend, no rebase, no push. Read `AGENTS.md` (repo law) first, briefly.

## Why (owner, 2026-11-25)
"Repaint all the red the audit found: ... the tazer and burst arcs to amber current." Colour law: amber for fire, heat
and **electric current**; vermilion only for danger, objectives, Rivet's collar. Audit `evidence/n28/red/audit.md` rows
17, 18, 19 (rows 20-22 are danger/objective vermilion: keep, untouched). Code only, no art PNG.

## The look to match (already shipped and accepted)
`ElectricArc` (`project/features/combat/kills/electric_arc.gd`: `HALO` `#edab42` amber, `CORE` `#fffaf0`, 2 px core in a
4.5 px (a0.5) and 9 px (a0.18) halo, screen px, hashed kinks re-jagged every `JAG_TICKS`, no RNG) and its reuse in
`WeaponFxElectro.chain_plan` / `star_plan` / `_draw_plan` (`project/features/combat/weapons/art/weapon_fx_electro.gd`).
Reuse those (call them; add at most one small public helper in `weapon_fx_electro.gd` if the metre/px scale of the
collect_call view (`Ink.px`, `Ink.PX_PER_M` 48) needs it; never copy the maths).

## What (all in `project/boot/collect_call/view/`, presentation only)
A. **Before stills first** (current tree): the collect_call fight (quest 1's Mertz fight) at a tick where (1) Mertz's
   tazer is CHARGING (prong sparks, `cast_view.gd` `_tazer_charge`), (2) a burst arc is up (`fx_view.gd` `_arcs`, arena
   `burst_arcs`), (3) the TUCK-IN stencil (`stage_view.gd` `_bolt_robot`) is on screen. Tools:
   `project/dev/frames/collect_call_frames.gd` (+ `frame_grabber.gd`, `frame_shot.gd`), `node tools/dev/run.mjs <entry> --dry-run`.
   Save 64 px/m (or the view's closest zoom: say which; the collect_call view draws at `Ink.PX_PER_M`, scale the camera if
   the tool allows) stills + crops to `C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/red_elec_<tazer|burst|tuckin>_before_64.png`;
   the commands + ticks into `evidence/n29/red/electric.md`. Count reddish px per crop with `python -I evidence/n28/red/count_red.py`
   (a crop-mode copy under `evidence/n29/red/` if needed; c2a may have made one: reuse it).
B. **Repaint.**
   - `cast_view.gd` `_mertz`: the 4 px barrel stripe `Ink.VERMILION` -> amber; `_tazer_charge` prong sparks: the three
     `Ink.zigzag(..., Ink.VERMILION)` -> live current (`WeaponFxElectro.chain_plan`-style strokes from muzzle to tip,
     re-jag on the 3-tick cell, phase from `tazer.ticks + k`). Update the `##` comment ("spark vermilion" -> amber current).
   - `fx_view.gd` `_arcs`: the vermilion + cream zigzag pair -> one live-current stroke per segment (same 40-tick life).
   - `stage_view.gd` `_bolt_robot`: the 3 px bolt polyline `Ink.VERMILION` -> amber (a glyph: a flat amber line is fine).
   - Amber: `Ink.AMBER` if it exists by then (another call may add it), otherwise `ElectricArc.HALO`. Do NOT edit `ink.gd`.
   - The old look one flag away is NOT needed (colour-law fix the owner picked); say so in the decisions line.
   - Quest 1's script, rules, tapes and checkpoints must not change: view code only, no sim state. Run
     `node tools/tests/test_map.mjs <each file>` and the tests/scenarios it maps; collect_call frame goldens that move
     only because of this repaint: re-pin and list each.
   Tests: pin in a unit test (e.g. `project/tests/unit/test_collect_call_current.gd`) that none of the three draws use
   `Ink.VERMILION` any more where it can be made a plan/colour query without a CanvasItem (if the draw cannot be tested
   without a canvas, extract the colour choice / plan into a static func and test that). `run_unit.mjs --changed` green,
   `node tools/gate/quick.mjs` green. Commit B with ONE appended `docs/decisions.md` line:
   `- [2026-11-25] DECISION n29 combat: Mertz's tazer stripe and prong sparks, the arena burst arcs and the TUCK-IN bolt glyph drawn amber (prongs and arcs as ElectricArc live current) instead of vermilion (red audit rows 17-19; electric current is amber). No flag: a colour-law fix.`
C. **After stills** at the same ticks + pairs `red_elec_<x>_pair_64.png` (before left, labelled), px table in
   `evidence/n29/red/electric.md`. LOOK at each pair yourself at full size. Commit C.
D. **Film**: 32 px/m (or the view's zoom: say which), 1920x1080, 60 fps, 15-40 s of the Mertz fight with the tazer
   charging and a burst arc: `C:/Users/kazda/kiro/gtai-masters/n29/combat/films/red_elec_mertz_after.mp4` (ffprobe).
   Add entries to `C:/Users/kazda/kiro/gtai-masters/n29/combat/frames.json` (re-read just before writing; keep entries).
   Mutate: `node tools/mutate/mutate.mjs --file=<the main changed file> --max=12 --lines=<changed lines> --tests=<your test>`
   (budget 10 min); quote the score.

## Repo law (binding)
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe GTAI_GODOT_EST_MB=1000` (600 headless).
  `--rendering-driver d3d12` for renders; windowed runs at `--position 0,1440`, never the main display. Godot only
  through `tools/dev/run.mjs` / `runGodot` / film tools; one Godot at a time for the whole lane (another builder of this
  lane may be running one: you queue); never kill a process you did not start, never by name. `mem-budget: waiting` =
  the 16 GB cap: wait.
- `node tools/gate/quick.mjs` before every commit; the pre-commit hook takes up to ~12 min. If it fails on
  `tools/film/kill_reel_*.break.test.mjs`, run a Godot `--import` and commit again. Never skip the hook.
- Typed GDScript, files ~200 lines (hard 300: `cast_view.gd` may be near it; extract to a new file + `.uid` if needed),
  functions <= 40 lines, <= 5 params, `Log` not print. `.uid` with every new `.gd`, Godot `--import` after new scripts.
  Stage per path. Banned: `git stash`, `git add -A/./-u`, `git commit -a`, `reset --hard`, amend, rebase, push.
  Commit trailer: `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Allowlist (any other path: stop that part and report `NEED <what>`)
`project/boot/collect_call/view/cast_view.gd`, `fx_view.gd`, `stage_view.gd` (+ one new helper file beside them with
`.uid`), `project/features/combat/weapons/art/weapon_fx_electro.gd` (one small public helper only), new/changed unit
tests under `project/tests/unit/` (+ `.uid`), pure-consequence re-pins of collect_call frame goldens, `docs/decisions.md`
(one line), `evidence/n29/red/**`, `build/**`, `C:/Users/kazda/kiro/gtai-masters/n29/combat/`.
Forbidden: `ink.gd`, every PNG, every table, `project/boot/prologue/**`, quest 1 scripts/rules/tapes, the HUD files,
other worktrees, root `JOURNAL.md` / `REPORT.md`.

## Report and END (short)
Commits; what each draw is now (colours, widths); px table; still/pair/film paths + ffprobe; how they read; unit/quick
gate; mutate score; re-pins; what was left.

## Director note (01:52): the item print snaps colours
Call c2a found (`evidence/n29/red/fire.md`, "What the pairs show") that weapon FX drawn under the item print snap
every non-ink colour to the nearest palette ink, and amber's nearest ink is vermilion; c2a may be adding an amber ink
right now. Check in your after stills whether your amber draws reach the screen as amber; if they snap to vermilion,
say so with the pixel colours and do not try to change the print yourself (not your files).

## Wall clock (binding)
You die with the director's session at 02:35. **Before stills by 02:02. Commit B by 02:14** (the hook takes minutes:
start the quick gate by 02:08). After stills + pairs, commit C by 02:22. **HARD STOP 02:25: report and END** (film D
and mutate only if time is left; list them otherwise). Another builder (c2a, fire/print) runs until 02:22: one Godot
for the lane, you may queue behind it.
