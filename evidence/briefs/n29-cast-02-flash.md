# Brief n29-cast-02: the hit flash on the door carrier and robot gunner A

Lane `cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd), branch `n29-cast`. You are a builder sub-agent;
the director reviews your diffs and frames. **Hard stop 02:20 local** (check `date +%H:%M` often). **Commit the code by 01:55**
(25-40 minutes in), the stills and audit after. Never end before your finished work is committed. Then report and END.

## The owner's pick
"Add the hit flash to the door carrier and robot gunner." Today their impact row is 0 by construction: both are drawn as one
whole sprite (`CastFarCard` subclasses `project/features/combat/squad/foe_shield_card_view.gd` (door carrier,
`shield_robot`) and `project/features/combat/squad/foe_gunner_card_view.gd` (`robot_gunner`)) with the articulated robot rig
hidden, so the shared hit flash (`CutRig.set_tint`, `project/features/characters/cut_rig.gd:204`, driven by
`rig_clips.gd:150` `rig.set_tint(hit_t > HIT_TINT_FROM)`) tints only the hidden rig parts. The other cards (patrol, riot,
SWAT, the lancer `rocket_trooper`) show the flash because their parts take `PartMaterials.get_mat(kind, on, swap)`.
A head card does the same thing for its sprite: `project/features/characters/rig_head_card.gd:65,152-153`
(`card.material = PartMaterials.get_mat(PartMaterials.PartKind.PART, rig.is_tinted(), 0)`). That is the model.

## Do
1. In both views (or once in `project/features/characters/cast_far_card.gd` if both go through it and nothing else uses it
   in a way that breaks: check its other subclasses with grep and say), give the card sprite the tint material while its rig
   is tinted (`rig.is_tinted()`) and `null` (raw, as today) otherwise; only switch on change. Same timing as the rig flash
   (no new timer). Pass the rig in where it is needed (keep <= 5 params).
2. Unit test(s) in `project/tests/unit/test_cast_*.gd` (an existing file for these views if one exists, e.g. grep
   `FoeGunnerCardView`/`FoeShieldCardView` under `project/tests`): tinted rig -> card material is the tint material; untinted
   -> null. Run `node tools/tests/run_unit.mjs --changed` and quote its summary line. `node tools/gate/quick.mjs` before
   the commit. Commit.
3. Judge at 64 px/m, tilt 70 and p55 with the existing dev scene `project/dev/cast/cast_impact_edge.gd` (it already holds
   both cards in `SUBJECTS` and forces the flash on a frozen tick; env `GTAI_CAST_OUT`, absolute dir: use
   `build/look/n29-flash/after`). Render the BEFORE from a temp worktree at the base commit `c649a15d6`
   (`git worktree add <tmp under build/> c649a15d6`; it needs the native DLLs: copy `project/bin/*.dll` or what the base needs
   from this worktree's `project/` folder (not from any other lane), run its own `--import`; remove the worktree after with
   `git worktree remove`). If the before worktree costs more than 15 minutes, use the n28 numbers in `docs/art/cast-audit.md`
   (door and gunner pulse 0/0) as the before and say so.
   Bars: (a) the flashed cell visibly reads as the same flash as the lancer's (look at the lancer and both cards side by
   side at 64 px/m yourself with the Read tool on the PNGs, describe what you see); (b) flashed rim (dark px outside the
   silhouette, the scene's notes.json measure) at or under the shipped lancer's in the same harness (lancer n28: hit 482 at
   p70 / 596 at p55); calm cells stay 0; (c) no red, vermilion or teal px introduced (hue count on the figure).
4. Stills to `C:\Users\kazda\kiro\gtai-masters\n29\cast\`: `flash_door_gunner_before_after_64ppm_tilt70.png` (before left,
   after right, lancer as the reference column, same frozen tick) and the same at p55; one 1920x1080 32 px/m still or a
   10-20 s 1080p60 clip of a gunner and a door carrier being shot in the street (if the clip costs more than 15 min, the
   still only; say so). Check any clip with `ffprobe`.
5. Write the table (id | pitch | calm rim | flashed rim before | after | lancer | red/teal px | verdict) to
   `evidence/n29-cast/flash/README.md` (NOT to `docs/art/cast-audit.md`: another builder appends there now).
   After step 2's commit, mutate the changed file: `node tools/mutate/mutate.mjs --file=<the changed .gd> --max=20
   --lines=<your changed lines> --tests=<your test basenames>` (give it at most 12 min: run it in the background with a
   timeout and quote the killed/(killed+survived) score, or "not finished").

## Repo law (binding)
- Every Godot launch goes through `runGodot` (`tools/dev/run.mjs`, film tools); before it: `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/cast`
  and `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; rendering gets
  `--rendering-driver d3d12`; windowed runs `--position 0,1440` (never the main display).
- **Lane Godot lock**: another sub-agent works in this worktree. Before any Godot launch (unit tests, quick gate, dev scene,
  mutate, import), take the lock with `until mkdir build/lane-godot.lock 2>/dev/null; do sleep 15; done` (inside one bash
  command) and `rmdir build/lane-godot.lock` right after the run ends (also on failure). Never hold it while you think or
  edit. If it is older than 25 min it is stale: remove it. The other builder may hold it for a few minutes; that is normal.
- A `mem-budget: waiting` line means the machine is full: wait, do not kill.
- Typed GDScript, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`. Commit `.uid` with new `.gd`.
- Stage per path: `git add <path>` then commit only your paths (`git commit -m "..." -- <paths>`). Banned: `git add -A/./-u`,
  `git commit -a`, `git stash`, `reset --hard`, amend, rebase, switching branches. Never push.
- The pre-commit hook can take ~12 min on this machine; never skip it. If it fails on `tools/film/kill_reel_*.break.test.mjs`
  the class cache is stale: run an import and commit again.
- Fix lint and format findings in your own edit and go on.
- Commit messages end with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Allowlist (any other path: stop and report a NEED)
`project/features/combat/squad/foe_shield_card_view.gd`, `project/features/combat/squad/foe_gunner_card_view.gd`,
`project/features/characters/cast_far_card.gd`, `project/tests/unit/test_cast_*.gd` (and a new `test_cast_card_flash.gd` +
`.uid`), `project/dev/cast/cast_impact_edge.gd` (only if it needs a fix to read the new flash), `evidence/n29-cast/flash/**`,
scratch under `build/look/n29-flash/`, a temp worktree under `build/`, outputs in `C:\Users\kazda\kiro\gtai-masters\n29\cast\`.
Forbidden: `project/data/tables/cast_cards.json`, `docs/art/cast-audit.md`, `project/dev/cast/cast_size_beside.*` (the other
builder's), `cut_rig.gd`, `part_materials.gd`, `rig_clips.gd` (shared rig code: if the fix needs them, report a NEED),
`project/features/souls/**`, anything of another lane, `main`.

## Report (then END)
Files, commit shas, `run_unit.mjs --changed` summary line, quick gate line, the table, what you saw in the stills, mutate
score, what you could not do. Never guess a number.
