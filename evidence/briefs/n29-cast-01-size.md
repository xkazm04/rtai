# Brief n29-cast-01: every card foe measured beside the spawned rig patrol cop, then one scale value each

Lane `cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd), branch `n29-cast`. You are a builder sub-agent;
the director reviews your diffs and frames. **Hard stop 02:20 local** (check `date +%H:%M` often). **Commit part A by 01:50**,
part B by 02:15. Never end before your last finished part is committed: an uncommitted sub-agent loses its work. Then report
and END.

## The owner's words
"Measure every card foe against the full-rig patrol cop first, then scale with one value each." And: "we should be careful
with too large bosses and enemies to avoid very heavy and slow opponents very easy to beat by just moving ... humongous main
bosses ... should not be example for majority." Most enemies near Rivet's size and dangerous to a moving player.

## What we know
- Card foes = rows of `project/data/tables/cast_cards.json` (`archetypes`): appliance_warden (body_scale 1.1), contractor,
  robot_gunner (1), rocket_trooper (the lancer), sentry_turret, sergeant_mulroney (1.11), shield_robot (the door carrier),
  war_machine; all `enabled: true`. The one value per foe is the existing optional `body_scale` (read in
  `project/features/characters/cast_cards.gd:45`, applied in `cast_far_card.gd:71` and maybe elsewhere: find every reader).
- n28 measured in the LIVE fight film `C:\Users\kazda\kiro\gtai-masters\n28\cast\contractor_close_64.mp4` (64 px/m, tilt 70,
  1920x1080): Rivet 149 px, spawned patrol cop 112 px (a full rig, spawned with `squad_ai.spawn_member(..., &"patrol_cop")`,
  `project/dev/cast/cast_contractor_fight.gd:74`), contractor 78 px standing (0.70 of the cop). The lineup still
  (`project/dev/cast/cast_contractor_lineup.gd` via `cast_lineup.gd` `_portrait` + `cast_plate.gd`) said contractor 111,
  cop 87: 1.35x and 0.78x the live sizes. Cause NOT found (suspects: a different representation, card vs rig, in the lineup's
  idle MARK layout; `arena_wave_cards.gd:62-80` scales cards by `StreetWalkerCards.HEIGHT_BY_ART` and `fill_of`;
  `arena_rigs.gd:14` FOCUS_REACH_M). See `docs/art/cast-audit.md` paragraph "Contractor, n28: live height vs the lineup".

## Part A (measure, commit by 01:50)
1. Write ONE dev scene `project/dev/cast/cast_size_beside.gd` + `.tscn` (model: `cast_contractor_fight.gd`, same street,
   `ViewMode.select("combo")`, pitch 70, `art = "p70"`, HUD and light layers hidden, 1920x1080 window, content scale disabled)
   that in ONE Godot process, for each enabled card foe id in turn: spawns it with `spawn_member` (the game's path) beside a
   spawned `patrol_cop` and Rivet, all three standing (idle, upright, facing the camera-ish, same facing for all), lets 40+
   ticks settle, and saves a viewport PNG at 64 px/m and at 32 px/m to `build/look/n29-size/<id>_<ppm>.png`; also
   `patrol_only_<ppm>.png` (background plate) if it helps segmentation. Enable cards the way the fight scenes do
   (`CastMulroneyPreview.enable(...)` or whatever the game does for an enabled row; prefer the game's real path: if
   `enabled: true` already means the arena spawns the card, use that, and say which). Declare `const RUN_TICKS` and any
   flags in `KNOWN_FLAGS` the dev runner expects. Run it through `node tools/dev/run.mjs` (never bare Godot).
2. Measure in those delivered PNGs (python + PIL/numpy under `build/look/`, script committed under `tools/art/cast_size_measure.py`):
   silhouette height in screen px (top of head/hat to lowest foot px; shadow excluded; weapon below feet excluded),
   per figure, at both ppm. Cross-check one number by eye against a crop (open the crop PNG with the Read tool).
3. Reproduce the lineup: launch `cast_contractor_lineup` once (`node tools/dev/run.mjs cast_contractor_lineup ...`, see the
   scene for its env) and find WHY it drew the contractor 111 / cop 87 vs live 78 / 112. Name the code path with file:line
   (e.g. the lineup draws the cop as a card and the contractor at a different scale, or a different cell). One paragraph.
4. Table, appended to `docs/art/cast-audit.md` as "Card foes beside the rig patrol cop, n29": id | current body_scale |
   height 64 px/m | 32 px/m | / cop | / Rivet | notes. Plus the cause paragraph. Commit (scene, .uid, tool, doc), one commit.
   Stills: a 1920x1080 contact image of all foes beside the cop at 64 px/m and one at 32 px/m to
   `C:\Users\kazda\kiro\gtai-masters\n29\cast\size_before_64.png` / `size_before_32.png`.

## Part B (scale, commit by 02:15)
Target rule (director's decision; apply it, do not invent another):
- Humans (contractor, sergeant_mulroney): standing height = the rig patrol cop's x 1.00 (contractor) and x 1.05 (Mulroney),
  tolerance +-4 %.
- Robots of the street cast (appliance_warden, robot_gunner, rocket_trooper, shield_robot): standing height between 0.85
  and 1.00 of Rivet's live height; aim for 0.90 x Rivet, +-4 %. The door carrier (shield_robot) may read wider; height rule
  still holds.
- war_machine: at most 1.10 x Rivet (the owner warns against huge slow enemies); if it is already under 1.10 and above 0.9,
  leave it.
- sentry_turret: a turret, not a walker: leave its value unless it is above Rivet's height; report its number either way.
New `body_scale` = current x (target / measured), rounded to 2 decimals. Write each into `cast_cards.json` (keep sorted keys,
schema-valid). Re-run the same scene, re-measure, and append the after column to the table (bar: every foe inside its
tolerance; say PASS/FAIL per row). Stills `size_after_64.png`, `size_after_32.png` in the masters folder, and a
`frames.json` there (best first: `[{ "file", "title", "ppm", "before", "note" }]`, before = the before still's file name).
Also check: does a scaled card still fit its hit box/feet anchoring (feet on the ground, no float)? Look at the after crop.
Run `node tools/tests/run_unit.mjs --changed` and quote its summary line; fix any test that pins a body_scale (only
`tests/unit/test_cast_*` files). Run `node tools/gate/quick.mjs` before the commit. Add a `docs/decisions.md` line
(append-only, one line): `- [2026-11-25] DECISION n29 cast card scale: ...` with the values and the rule.

## Repo law (binding)
- Every Godot launch goes through `runGodot` (`tools/dev/run.mjs`, the film tools); before it: `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/cast`
  and `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; anything that
  renders gets `--rendering-driver d3d12`; windowed runs `--position 0,1440` (never the main display).
- **Lane Godot lock**: another sub-agent works in this worktree. Before any Godot launch, take the lock with
  `until mkdir build/lane-godot.lock 2>/dev/null; do sleep 15; done` (inside one bash command), and `rmdir build/lane-godot.lock`
  right after the run ends (also on failure). Never hold it while you think or edit. If it is older than 25 min, it is stale: remove it.
- Your first Godot action: one `"$GODOT_BIN" --headless --path project --import` (under the lock, via runGodot if possible,
  e.g. `node tools/godot/check.mjs` does not import; `node tools/dev/run.mjs` imports a stale cache by itself: that is fine).
- A `mem-budget: waiting` line means the machine is full: wait, do not kill.
- Typed GDScript, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`. Commit `.uid` with new `.gd`.
- Stage per path: `git add <path>` then `git commit -m "..." -- <paths>` or plain commit of what you staged. Banned: `git add -A/./-u`,
  `git commit -a`, `git stash`, `reset --hard`, amend, rebase, checkout of other branches. Never push.
- The pre-commit hook can take ~12 min on this machine; never skip it. If it fails on `tools/film/kill_reel_*.break.test.mjs`
  the class cache is stale: run an import and commit again.
- Fix lint and format findings in your own edit and go on.
- Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Allowlist (any other path: stop and report a NEED)
`project/dev/cast/cast_size_beside.*`, `tools/art/cast_size_measure.py`, `project/data/tables/cast_cards.json` (body_scale
values only), `project/tests/unit/test_cast_*.gd` (only to re-pin a body_scale), `docs/art/cast-audit.md` (append),
`docs/decisions.md` (append one line), `project/boot/launch_args.gd` KNOWN_FLAGS (append only, only if needed; then
`node tools/debt/debt.mjs --update --accept-regression="<flag> for n29 cast"`), `tools/debt/baseline.json` (through the
debt tool only), scratch under `build/look/n29-size/`, outputs in `C:\Users\kazda\kiro\gtai-masters\n29\cast\`.
Forbidden: `project/features/souls/**`, `project/boot/prologue/**`, player files, `ghost_*.json`, `enemies.json`,
`weapons.json`, any other lane's worktree, `main`. Another builder works on the door carrier / gunner hit flash in
`project/features/combat/squad/foe_gunner_card_view.gd` and the door carrier's view: do not touch those files.

## Report (then END)
The full table (before and after), the lineup cause with file:line, the new values, commit shas, `run_unit.mjs --changed`
summary line, the quick gate line, what you could not do. Never guess a number: unmeasured is "not measured".
