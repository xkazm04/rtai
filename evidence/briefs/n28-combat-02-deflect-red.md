# Brief n28-combat-02-deflect-red: no red in the deflect spark; a list of every non-blood red in combat effects

Lane `combat`, branch `n28-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadline: see the end of this brief (wall clock). At the hard stop write your report and END, even
mid-task.** Never stop to ask: at a fork pick what best serves the owner's words, write it in your report, go on. Fix lint
and format findings in your own edit and go on. No amend, no rebase.

## Why (owner, 2026-11-24)
"Fix the red fleck in the deflect spark: no red outside blood." Colour law: red is blood only; vermilion only for danger,
objectives and Rivet's collar; amber for fire, heat and electric current; teal only for souls; cops blue.
The fleck is visible in `C:/Users/kazda/kiro/gtai-masters/n27/pressure/guard_return_64.png` at about (870, 540): a cream
paper starburst with a vermilion-red core, a few px from the returned round, beside the cream "spider" spark.

## What the director already found (verify, do not trust)
- A deflect is `PlayerDeflect` (`project/features/player/player_deflect.gd:46-70`): it turns the round (`s.from_rivet =
  true`, `s.origin = s.pos`), calls `_spark` (two short `chain_arcs` drawn by `WeaponFxElectro.chain`: the cream arc + the
  `spark` cell, the "spider"), and emits `arena.deflected` (heard by `DeflectMarks` `project/features/combat/react/deflect_marks.gd`,
  cream fill + ink ring, and `MeleeFeel`). None of those has red.
- Red-cored cells exist: `project/features/combat/weapons/art/fx/flash_pistol_*.png`, `flash_smg_*.png`, `flash_tube_*.png`
  (cream star, vermilion core) and `fx_atlas.png` cells 0-2 (fx.json kind `muzzle`), 8-12 (`explosion`). Guess: the turned
  round is drawn as a fresh Rivet shot and gets a muzzle flash at its new origin. Find the real source with a one-flag
  or one-line still before you change anything (last run, two restyles hit the wrong glyph because nobody checked).
- Director, 18:20, from a 3x crop of the n27 still (`guard_return_64.png` box 660,360-960,620; 539 px with R>170,G<110,B<90
  in the whole frame, most at (720-800, 400-480) = Rivet's collar, allowed, and ~170 at (860-900, 520-560) = the fleck):
  the fleck's SHAPE is `DeflectMarks._burst` (8 long/short rays, cream fill at alpha 1-t^2, 3 px ink ring,
  `project/features/combat/react/deflect_marks.gd:61-74`) with `_streak` (ink 7 px + cream 3 px line) as its tail. The
  burst itself draws no red. So the red blob inside it comes from (a) another draw at the bat point on the same frame:
  `MeleeFeel._on_deflected` -> `cam.hit(&"plasma_deflect", ...)` (`project/features/combat/react/melee_feel.gd:50`; check
  whether the hit feel spawns a flash/impact cell with a core, e.g. a `fx_atlas` `muzzle`/`explosion` cell or a
  `flash_*` cell), or (b) the FX print pass: `look_d5_print` / the d4 item print snaps colours to the vermilion plate
  ("its normal item print maps deep amber back to vermilion", `project/features/combat/shot_draw.gd:3`), so any amber or
  orange drawn on the normal item (not the round canvas) at that spot prints vermilion. Bisect with flags first:
  `--feel=off` (drops DeflectMarks AND the deflect feel), then each alone if you can; the n27 take is the same scene.
- Guard returns go through `PlayerGuard.deflect` (`project/features/player/player_guard.gd:66`) ->
  `PlayerDeflect.send_back`; sword returns through `PlayerDeflect.bat`. Both emit `arena.deflected`.

## What
A. **Before** (on the current tree, before any edit): 64 px/m stills of a guard return and a plasma sword return at
   fixed ticks, from the n27 pressure takes (`project/dev/gauntlet/**`, `tools/gauntlet/pressure_films.mjs`; the n27
   stills `guard_return_64.png`, `blade_struck_64.png` came from there; `evidence/n27-pressure/` says how). Save as
   `C:/Users/kazda/kiro/gtai-masters/n28/combat/stills/deflect_guard_before_64.png` and `deflect_blade_before_64.png`,
   plus a 4x crop of the spark (`..._crop.png`).
B. **Find and fix.** Identify the draw call that puts the red there (file:line in your report). Remove the red from the
   deflect only: e.g. the turned round draws no muzzle flash, or a core-less flash (`flash_energy_*` is cream-only), or
   its core is drawn cream/amber. Pick what keeps the bat's punch and say why. Normal gunfire of Rivet and the cops is NOT
   changed (its muzzle flash is not this pick). Presentation only: the sim, the 60 s replay and parity must not move.
   If the turned round's sim state (`from_rivet`, `origin`) is what the view keys on, add a view-side test (e.g. a
   `deflected` meta or the round's tick), never change the sim. A unit test pins that a deflected round draws no
   red-cored cell (or whatever your fix makes testable). Commit by the commit deadline with ONE appended
   `docs/decisions.md` line: `- [2026-11-24] DECISION n28 combat: the deflect spark draws no red (<what drew it, what replaced it>); red is blood only (owner).`
C. **After**: the same two stills at the same ticks: `deflect_guard_after_64.png`, `deflect_blade_after_64.png` (+ crops).
   Check every pixel of the spark region: report the count of pixels with R > 170, G < 110, B < 90 in the crop before and
   after (after should be 0 unless it is blood on a hit shooter; say which). Look at them yourself.
D. **The red audit (list only, fix nothing else).** Search every combat effect for red or vermilion that is not blood:
   `project/features/combat/**` colours (`Color(...)`, hex), the cells under `project/features/combat/weapons/art/fx/`
   and `project/features/fx/art/fx_atlas.png` (count reddish pixels per cell with the same threshold), `fx.json`,
   `gun_fx.json`, `fx_triggers.json`, the kill art (`KillMarkArt.BLOOD` uses are blood: fine). Write
   `evidence/n28/red/audit.md`: one row per source (file or cell, what it shows in the game, reddish pixels or the colour,
   blood / danger (vermilion allowed) / fire (should be amber) / other, a one-line suggestion). Include a contact sheet
   `evidence/n28/red/cells.png` of the flagged cells. Commit.
E. **Film** (32 px/m, 1920x1080, 60 fps, 15-40 s): re-take `deflect_6m_32.mp4` on the fixed tree to
   `C:/Users/kazda/kiro/gtai-masters/n28/combat/films/deflect_6m_32.mp4` in ONE encode from the master (n27's was a
   second-generation crf 26 re-encode; keep it under ~40 MB with the crf you pick, say which). `ffprobe` it. Add the
   stills and the film to `C:/Users/kazda/kiro/gtai-masters/n28/combat/frames.json` (keep existing entries; `before` =
   the n27 file or your before still).

## Checks
`node tools/tests/run_unit.mjs --changed` green; `node tools/gate/quick.mjs` before every commit; budget about 12 min
for the pre-commit hook. If it fails on `tools/film/kill_reel_*.break.test.mjs`, run a Godot `--import` and commit again
(never skip the hook). Mutate after the fix commit: `node tools/mutate/mutate.mjs --file=<the file you fixed> --max=12
--lines=<your changed lines> --tests=<the test you added and its neighbours>` (budget 10 min), quote the score.

## Repo law (binding)
- Memory budget: the lane sessions hold the 8 GB cap near 6.2 GB, so the default 1200 MB estimate waits up to 30 min a run. Export `GTAI_GODOT_EST_MB=600` for headless runs and `GTAI_GODOT_EST_MB=1000` for rendered runs (measured in call 01b, `evidence/n28/bond/memory.txt`). A `mem-budget: waiting` line is still not a hang: wait; never bypass the cap.
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
  `--rendering-driver d3d12` for renders; any windowed run at `--position 0,1440`, never the main display. One Godot
  process at a time; kill only your own PIDs, never by name. 8 GB machine cap: `mem-budget: waiting` is not a hang.
- Typed GDScript, ~200 lines a file (hard 300), functions <= 40 lines, <= 5 params, `Log` not print, `.uid` with every
  new `.gd`, Godot `--import` after new scripts before committing. Stage per path; banned: `git stash`, `add -A/./-u`,
  `commit -a`, `reset --hard`, amend, rebase, push.

## Allowlist (any other path: stop that part and report `NEED <what>`)
The deflect VFX: `project/features/player/player_deflect.gd` (view-side spark code only), `project/features/combat/react/**`,
the gun-flash view code that draws the fleck (`project/features/combat/weapons/**` view files, `gun_fx*.gd`, `FightAreasArt`
if that is the drawer: only the deflect branch), `project/tests/unit/test_*deflect*.gd`, `test_gun_fx*.gd` (+ `.uid`),
`project/dev/gauntlet/**`, `tools/gauntlet/**`, `docs/decisions.md` (one appended line), `evidence/n28/**`,
`C:/Users/kazda/kiro/gtai-masters/n28/combat/`.
Forbidden: art PNGs (no repaint in this call), `rivet_motion.json`, `input_actions.json`, player movement/input files,
`cast_cards.json`, character art, `project/boot/prologue/**`, other worktrees, root `JOURNAL.md` / `REPORT.md`.

## Report and END (short)
Commits; the draw call that made the red (file:line) and the fix; reddish pixel counts before/after; still/film paths +
ffprobe; audit rows count and the three worst; unit + quick gate lines; mutate score; what was left.

## Wall clock (call 1 of this brief, in-session builder)
**HARD STOP 19:20: report and END, even mid-task. Commit the fix (B) by 19:10.** Order for this call: A (before stills,
the two guard/blade ones only), the bisect, B (fix + test + decisions line + commit), C (after stills + pixel counts) if
time remains. D (audit) and E (film) are left for the next call: do not start them. The memory cap had room at 18:40;
headless runs `GTAI_GODOT_EST_MB=600`, renders `1000`. Mutate is left for the next call too.
