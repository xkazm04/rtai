# Brief n29-combat-02a-red-fire: the fire cells repainted from red to amber (red audit, fire group)

Lane `combat`, branch `n29-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadline: see "Wall clock" at the end (binding). At the hard stop write your report and END, even
mid-task.** Never stop to ask: at a fork pick what best serves the owner's words, write it in your report, go on. Fix lint
and format findings in your own edit and go on. No amend, no rebase, no push. Read `AGENTS.md` (repo law) first, briefly.

## Why (owner, 2026-11-25)
"Repaint all the red the audit found: fire and muzzle cores to amber, ..." Colour law: red is blood only; vermilion only
for danger, objectives and Rivet's collar; **amber for fire, heat and electric current**. The audit is
`evidence/n28/red/audit.md` (read it whole; counter `evidence/n28/red/count_red.py`: reddish = R>170, G<110, B<90,
alpha>0). This call is the **fire group** only: rows 1, 2, 3, 4, 13, 14 (26 = keep, say so). Other groups (muzzle cores
rows 5-10, electric rows 17-19, the sword hilt row 15) are later calls: do not touch them.

## Decision already taken by the director: how to repaint
Recolour, do not redraw: the shipped cells' shapes, strokes, alpha and light are accepted art; only the hue breaks the
law. Write ONE deterministic script `evidence/n29/red/recolour.py` (Python, `python -I`, Pillow if present, else write
your own PNG IO; run from the repo root) that, per pixel, maps the reddish / vermilion / orange-red range (define it from
the counter's gate, widened to the hue band about 345..25 degrees with saturation > 0.35 so the anti-aliased fringe moves
too) onto the amber hue of `ElectricArc.HALO` (`#edab42`, ~37 degrees), keeping each pixel's alpha, and its value
(lightness) so the cream core and ink rim are untouched and the fire keeps its light-to-dark ramp. Pixels already amber
/ cream / ink / grey stay byte-identical. Print per file: reddish px before -> after (count_red's gate), changed px.
Rejected: the image tool (would redraw the shapes and spend rolls; IMAGES stay 0) and code tint (the cells are drawn in
many paths). Say this in your report and in the decisions line. If amber at the same value reads too pale on cream at
32 px/m, darken the remapped pixels by at most 15 % and say so.

## What
A. **Before stills first (on the current tree, before any edit).** For each effect, a 64 px/m in-game still at a fixed
   tick, and a crop around the effect: (1) rocket blast fireball (`blast_0/1`, `WeaponFxArt` BLAST_FRAMES); (2) the
   flamethrower flame + flame cone (`flame_*`, `colour/flame_cone_*`, `colour/flame_*`); (3) burning ground
   (`ground_fire.png`, the molotov / flame ground); (4) the `explosion` kind cloud (`fx_atlas.png` cells 9-12, `fx.json`);
   (5) the molotov rag lighting star (`project/features/player/rag_light.gd:29`) and the mini-nuke tip
   (`project/features/combat/weapons/fight_nuke_art.gd:32`) if a take shows them. Find takes with what is there: the
   dev arena / showcase scenes under `project/dev/` (`node tools/dev/run.mjs <name> --dry-run` lists flags), the kill
   reel (`tools/film/kill_reel.mjs`), `tools/film/arsenal_turn.mjs`, `tools/film/owner_takes.mjs`,
   `evidence/n27/films/films.md`, `evidence/n28/electric/notes.md`. Write the exact command + tick per still into
   `evidence/n29/red/fire.md` so the after is the same frame. Save to
   `C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/red_fire_<effect>_before_64.png` (+ `_crop`). Count reddish
   px in each crop with `count_red.py` (extend it with a crop mode in a copy `evidence/n29/red/count_red.py` if needed).
B. **Repaint.** Run `recolour.py` on: `project/features/combat/weapons/art/fx/blast_0.png`, `blast_1.png`,
   `flame_0..2.png`, `colour/flame_cone_0..2.png`, `colour/flame_0..2.png`, `ground_fire.png` (wherever it lives; the
   audit says `colour/`), and the **explosion cells 9, 10, 11, 12 only** of `project/features/fx/art/fx_atlas.png`
   (32 cells; find the grid from `fx.json`/the loader; cells 0-2, 8, 13, 14 are the muzzle group's: leave them
   byte-identical, and prove it in your report by hashing those cells before/after). Code: `rag_light.gd:29` and
   `fight_nuke_art.gd:32` draw `Ink.VERMILION` for a flame/glow: switch them to amber. If an amber constant does not
   exist where they can reach it, use `ElectricArc.HALO` or add ONE `const AMBER: Color = Color("#edab42")` to
   `project/boot/collect_call/view/ink.gd` and use it (say which). Then run a Godot `--import` (the PNGs changed),
   `node tools/tests/test_map.mjs <each changed file>` and run what it maps (`run_unit.mjs --select=...`), plus
   `node tools/tests/run_unit.mjs --changed`. Watch for tests/goldens that hash these PNGs or count accent pixels
   (`project/dev/selftest/accent_audit.gd`, look goldens, d4 manifests, `art_src/*.manifest.json`): re-pin what is a
   pure consequence of this repaint and list each re-pin. Commit B (PNGs + script + code + re-pins) with ONE appended
   `docs/decisions.md` line:
   `- [2026-11-25] DECISION n29 combat: fire cells (blast, flame, flame cone, ground fire, explosion atlas cells 9-12) and the rag/nuke-tip glow repainted from red/vermilion to amber (#edab42 hue) by a deterministic hue remap of the shipped pixels (evidence/n29/red/recolour.py) keeping strokes, alpha and value; red audit rows 1-4, 13, 14. Rejected: image-tool redraws (shape drift, rolls) and a draw-time tint.`
C. **After stills** at the same commands and ticks: `..._after_64.png` (+ `_crop`), and a side-by-side per effect
   `red_fire_<effect>_pair_64.png` (before left, labelled). Reddish px per crop before -> after into `evidence/n29/red/fire.md`
   as a table (effect, file(s), cells px before -> after, crop px before -> after). LOOK at every pair yourself at full
   size; the fire must still read as fire (amber/orange-yellow, light core, ink rim), never pink, never brown mud.
   Commit C (evidence md) right away.
D. **Film**: one 32 px/m clip, 1920x1080, 60 fps, 15-40 s, of a fight with the rocket blast and fire after the repaint
   (`C:/Users/kazda/kiro/gtai-masters/n29/combat/films/red_fire_after_32.mp4`; ffprobe it), and if cheap the same take
   on the before tree is not possible (PNGs changed): instead put the before stills in `before`. Add stills/film to
   `C:/Users/kazda/kiro/gtai-masters/n29/combat/frames.json` (JSON array of `{ "file", "title", "ppm", "before", "note" }`,
   `file` relative to that folder; create if missing; keep other entries; another builder may add entries too: re-read
   just before you write).

## Repo law (binding)
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe GTAI_GODOT_EST_MB=1000` (600 headless).
  `--rendering-driver d3d12` for renders; any windowed run at `--position 0,1440`, never the main display. Only Godot
  through `tools/dev/run.mjs` / `runGodot` / the film tools; **one Godot at a time for the whole lane**: another builder
  of this lane runs short headless bond measurements (~15 s each) until about 02:00; if a Godot of theirs is running,
  your launch queues; never kill a process you did not start, never by name. `mem-budget: waiting` = the 16 GB cap
  queueing you: wait.
- `node tools/gate/quick.mjs` before every commit; the pre-commit hook takes up to ~12 min. If it fails on
  `tools/film/kill_reel_*.break.test.mjs`, run a Godot `--import` and commit again. Never skip the hook.
- Typed GDScript, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not print. Stage per path;
  commit `.import` files if Godot changed them. Banned: `git stash`, `git add -A/./-u`, `git commit -a`, `reset --hard`,
  amend, rebase, push. Commit trailer: `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Presentation only: no sim state; the 60 s replay and parity must not move.

## Allowlist (any other path: stop that part and report `NEED <what>`)
The fire PNGs named in B (+ their `.import`), `project/features/fx/art/fx_atlas.png` cells 9-12 only,
`project/features/player/rag_light.gd` (the one colour), `project/features/combat/weapons/fight_nuke_art.gd` (the one
colour), `project/boot/collect_call/view/ink.gd` (one appended const), pins/goldens that are a pure consequence
(`project/tests/**`, `art_src/*manifest*`), `docs/decisions.md` (one line), `evidence/n29/red/**`, `build/**`,
`C:/Users/kazda/kiro/gtai-masters/n29/combat/`.
Forbidden: `ghost_forms.json` and every table (another builder), muzzle `flash_*` PNGs, fx_atlas cells other than 9-12,
`weapons/art/molotov/**` and every held/pickup/icon art (keys' lane: write `NEED keys` for the molotov rag, audit row 12),
`weapon_fx_electro.gd`, `cast_view.gd`, `fx_view.gd`, `stage_view.gd`, plasma sword art, the HUD files, character art,
`project/boot/prologue/**`, other worktrees, root `JOURNAL.md` / `REPORT.md`.

## Report and END (short)
Commits; the remap (hue band, target, value rule) in numbers; the px table; still/pair/film paths + ffprobe; how each
pair reads; unit/quick gate lines; re-pins; what was left.

## Wall clock (binding)
You die with the director's session at 02:35. **Before stills by 01:40. Commit B by 02:00.** Commit C by 02:12.
**HARD STOP 02:22: report and END** (film D only if time is left; list it otherwise).
