# Brief n29-cast-01b: one scale value per card foe (part B), re-filmed beside the rig patrol cop

Lane `cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd), branch `n29-cast`. You are a builder sub-agent;
the director reviews your diffs and frames. **Hard stop 03:50 local** (check `date +%H:%M` often). **Commit part 1 by 03:15,
part 2 by 03:40.** Never end before your last finished part is committed. Then report and END.

## The owner's words
"Measure every card foe against the full-rig patrol cop first, then scale with one value each." And: "be careful with too
large bosses and enemies to avoid very heavy and slow opponents very easy to beat by just moving ... humongous main bosses
... should not be example for majority."

## What is already measured (part A, `f4bf378ea`; read `docs/art/cast-audit.md` "Card foes beside the rig patrol cop, n29")
Scene `project/dev/cast/cast_size_beside.gd` + measurer `tools/art/cast_size_measure.py` exist and work: reuse them as they are.
Unjittered standing heights at 64 px/m, tilt 70 (Rivet 154 px on screen = 103 px design height x1.5 visual):
patrol cop 100.6, contractor 100.7 (body_scale 1.0), appliance_warden 94 (1.1; `body: human`), robot_gunner 93 as drawn
(its pose never gets an `actor_id`, so it always takes `StreetCrowdCards.body_scale(0)` = 0.926; unjittered ~100.4),
rocket_trooper 93.3 (1.0; `body: human`), sergeant_mulroney 95.6 (1.11), sentry_turret 107 (`PLATE_M`, ignores body_scale),
shield_robot 108 (view sets `HEIGHT_M` 2.0, overwrites body_scale), war_machine 155 (`HEIGHT_M` 2.6, ignores body_scale).
The n28 lineup's 1.35x / 0.78x came from the per-actor build jitter `StreetCrowdCards.body_scale(actor_id)` (1 +- 0.16,
`street_crowd_cards.gd:68`) applied to every whole-figure card (`cast_far_card.gd:80`, `street_walker_cards.gd:168`).

## The director's rule (decided, apply it; do not invent another)
1. **Card foes drop the build jitter**: a card foe's size is its one `body_scale`, the same for every spawn. Make it data: a
   new top-level key in `cast_cards.json` `"build_jitter": 0.0` (schema `project/data/schemas/cast_cards.schema.json`:
   number 0..0.3, optional, default 0.16 when absent so an old table behaves as before), read in `cast_cards.gd`, applied
   where a CARD pose takes `StreetCrowdCards.body_scale(actor_id)` (`cast_far_card.gd:80`; `street_walker_cards.gd:168` only
   when `pose != null`, i.e. a card: the crowd's own peds keep their jitter, untouched). The alternative (old look) = set 0.16.
2. **Targets against the unjittered patrol cop (100.6 px at 64 px/m = 1.00)**: humans (contractor, appliance_warden,
   rocket_trooper) x1.00; sergeant_mulroney x1.05; robots (robot_gunner, shield_robot) x1.10; sentry_turret unchanged (107);
   war_machine x1.30 (131 px at 64, 0.85 of Rivet's on-screen height: still the biggest foe, no longer Rivet-tall).
   Tolerance +-4 % per row.
3. **One value each**: the shield view and the war machine view must multiply their height by the row's `body_scale`
   (default 1.0 = today's size), so the value in `cast_cards.json` is the only knob. Find those views
   (`grep -rn "HEIGHT_M" project/features/combat/squad project/features/characters`); smallest change. Leave the turret alone.
4. New `body_scale` = current x target / measured-unjittered (for the gunner: 1.0 x 110.7 / 100.4), rounded to 2 decimals.
   Expected roughly: contractor 1.00, warden 1.18, lancer 1.08, Mulroney 1.23, gunner 1.10, shield 1.03, war machine 0.85.
   Use your re-measured numbers, not these.
5. Check the fall / corpse / kill cells of a scaled card (`street_walker_fall.gd`, `street_crowd_corpse.gd`,
   `kill_fall_cells.gd`): if they size the dying card without `body_scale`, a 1.23 Mulroney would shrink when he falls. Say
   what you find; fix only if the fix is in `project/features/characters/**` and small, else write it as an open point.

## Part 1 (commit by 03:15): code + data + tests
The jitter key, the two view hooks, the values, schema, tests: one unit test in `project/tests/unit/test_cast_cards*.gd` (or the
nearest existing `test_cast_*`) that (a) a card pose's scale is the same for actor ids 0, 1, 7 when `build_jitter` is 0, (b)
the shield and war views scale with body_scale. Re-pin any test that pins a body_scale or a card size. Run
`node tools/tests/run_unit.mjs --changed` and quote its summary line; `node tools/gate/quick.mjs` before the commit; one
`docs/decisions.md` line (append-only, one line):
`- [2026-11-25] DECISION n29 cast card scale: card foes drop the +-16 % build jitter (cast_cards.json build_jitter 0, 0.16 restores); one body_scale per foe against the unjittered rig patrol cop (100.6 px at 64 px/m): humans x1.00, Mulroney x1.05, robots x1.10, war machine x1.30 (was 1.54, the owner's size warning), turret unchanged; values <list>.`
Scenarios and replays must not move (card scale is visual); if a scenario or golden pins a card size, say which and re-pin
with a reason in the same decisions line.

## Part 2 (commit by 03:40): re-film beside the cop
Re-run `cast_size_beside` (through `node tools/dev/run.mjs`; the part-A builder used an uncommitted launcher
`build/look/launch.mjs` for engine flags: reuse it if it still exists), re-measure every row at 64 and 32 px/m with the same
actor ids as part A AND with two other ids for one human and the gunner (proves the jitter is gone: heights equal +-1 px).
Append an "n29 part B, applied" table to the audit section: id | old body_scale | new | 64 px/m | 32 px/m | / cop | target |
PASS/FAIL. Look at the 64 crops of each foe yourself (Read tool): feet on the ground row, no float, nothing clipped. Stills
`C:\Users\kazda\kiro\gtai-masters\n29\cast\size_after_64.png` / `size_after_32.png` (overwrite the reverted ones), and in
that folder's `frames.json` (valid JSON array, keep the flash entries first) replace the two `NOT SHIPPED` size_after entries
with the real ones (`before`: `size_before_64.png` / `size_before_32.png`) and add size_before entries if they are missing.
If time is left by 03:30: a 32 px/m 1080p clip of 15 to 40 s cycling the foes beside the cop (3-4 s each) to
`gtai-masters/n29/cast/size_beside_32.mp4` (check with `ffprobe`); else say "no clip".
Commit the doc and any scene change (pathspec). Then
`node tools/mutate/mutate.mjs --file=project/features/characters/cast_far_card.gd --lines=<your changed lines> --max=20 --tests=<the test basenames you touched>`
holding the lane lock, at most 15 min; quote killed/(killed+survived).

## Repo law (binding)
- Every Godot launch goes through `runGodot` (`tools/dev/run.mjs`, the film tools); before it:
  `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/cast` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; anything that renders
  gets `--rendering-driver d3d12`; windowed runs `--position 0,1440` (never the main display).
- **Lane Godot lock**: another sub-agent works in this worktree (flash harness, `project/dev/cast/cast_impact_edge.gd`). Before
  any Godot launch take `until mkdir build/lane-godot.lock 2>/dev/null; do sleep 15; done` (inside one bash command), and
  `rmdir build/lane-godot.lock` right after the run ends (also on failure). Never hold it while you think or edit. Older than
  25 min = stale: remove it. mutate and the unit runner launch Godot too: hold the lock for them.
- A `mem-budget: waiting` line means the machine is full: wait, do not kill.
- Typed GDScript, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`. Commit `.uid` with new `.gd`.
- Stage per path, commit with a pathspec. Banned: `git add -A/./-u`, `commit -a`, `stash`, `reset --hard`, amend, rebase,
  branch switches, push. The hook can take ~12 min; never skip it. If the hook's `tool-tests` fails only on
  `tools/merge/step_guard.break.test.mjs`, run that file alone; if it passes alone, commit again (load flake). If it fails
  on `tools/film/kill_reel_*.break.test.mjs`, run an import and commit again.
- Fix lint and format findings in your own edit and go on. Debt rises: `node tools/debt/debt.mjs --update --accept-regression="card scale for n29 cast"`.
- Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Allowlist (any other path: stop and report a NEED)
`project/data/tables/cast_cards.json`, `project/data/schemas/cast_cards.schema.json`, `project/features/characters/cast_cards.gd`,
`cast_far_card.gd`, `street_walker_cards.gd` (the card branch only), the shield and war machine card view files (name them),
fall/corpse files under `project/features/characters/**` (only the small fix in rule 5), `project/tests/unit/test_cast_*.gd`
(+ `.uid`), `project/dev/cast/cast_size_beside.*`, `tools/art/cast_size_measure.py`, `docs/art/cast-audit.md` (append),
`docs/decisions.md` (append one line), `tools/debt/baseline.json` (through the debt tool), scratch `build/look/n29-size/`,
outputs in `C:\Users\kazda\kiro\gtai-masters\n29\cast\`.
Forbidden: `project/dev/cast/cast_impact_edge.gd` and `evidence/n29-cast/flash/**` (the other builder), `project/features/souls/**`,
`project/boot/prologue/**`, player files, `ghost_*.json`, `enemies.json`, `weapons.json`, other lanes' worktrees, `main`.

## Report (then END)
The applied table, the jitter proof (heights for 3 ids), the fall/corpse finding, the values, commit shas,
`run_unit.mjs --changed` line, quick gate line, mutate score, clip or "no clip", what you could not do. Unmeasured is "not measured".
