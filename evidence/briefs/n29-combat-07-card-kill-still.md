# Brief n29-combat-07-card-kill-still: see a card foe fall at his card size (before | after, 64 px/m)

Lane `combat`, branch `n29-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadline: see "Wall clock" (binding). At the hard stop report and END, committed.** Never ask; at a
fork pick what serves the owner's words, say so in the report. Fix lint/format findings in your own edit and go on.

## Why
6d1fa3959 (`KillFallCells.victim_scale`) makes a killed card foe fall at his living card's size; before, Mulroney
(body_scale 1.11) shrank to 0.901 of his card on death, the warden to 0.909. Proven only headless and in a unit test
(`evidence/n29/kills/card_scale.md`, read it first: the path `arena_rigs.gd:70 -> foe_cast_view.gd:54 ->
kill_new_styles.gd:70/80`, and why the kill lab showed nothing: its gun kill styles that use the fall grid kill a
contractor, body_scale 1.0). The owner judges by frames: we need one take where a card foe with body_scale != 1.0
(Mulroney 1.11 or the appliance warden 1.1) is killed by a kill style that uses the fall grid, filmed before and after.

## What
1. Find the cheapest way to get that victim into a fall-grid kill, in this order of preference:
   a. existing flags only: `tools/film/kill_reel.mjs` (`--victims=`, `--weapons=`, `--before=<commit>`, `--quick`,
      `-- <extra game flags>`), `KillLabTurn.melee_victim` / `--foe-mix` (`project/features/combat/kills/kill_lab_turn.gd`);
   b. else the smallest dev-only change in `kill_lab.gd` / `kill_lab_turn.gd` (ours) so `--foe-mix=<card archetype>`
      (already declared) also swaps the solo guard for a gun kill style. No new launch flag if avoidable; if one is
      unavoidable, append it to `project/boot/launch_args.gd` `KNOWN_FLAGS` and accept the debt with
      `node tools/debt/debt.mjs --update --accept-regression="<flag> for n29 combat"`.
   Write the finding (which style, which victim, command) in `evidence/n29/kills/card_scale.md` "Evidence: stills" before
   rendering.
2. Render at 64 px/m (d3d12): **before** = the code at `6d1fa3959^` (= 49befa075) for `kill_fall_cells.gd` only (prefer
   `kill_reel.mjs --before=49befa075` if it does that in a temp tree; else a temp worktree under `%TEMP%\gtai-n29-card-before`,
   removed after, or copy the old `kill_fall_cells.gd` in for one render then `git checkout HEAD -- <it>`: say which, and the
   tree must be clean after); **after** = HEAD. Same seed, same ticks: one frame of the victim standing alive just before the
   kill and one or two frames of him down. Pair `stills/card_kill_pair_64.png` (before left) under
   `C:/Users/kazda/kiro/gtai-masters/n29/combat/`. MEASURE in those frames (not a lineup): the living figure's height in px
   and the fallen body's length in px, before and after; the ratio fallen/living should move from about 0.90x to about
   1.0x of what a body_scale-1.0 contractor gets in the same style (render a contractor arm too if cheap). LOOK at it.
3. Commit (by **05:50**): any dev change + its test if it changed behaviour (`node tools/tests/run_unit.mjs --changed` green),
   `evidence/n29/kills/card_scale.md`, one `frames.json` entry for the pair (re-read the file right before writing; keep
   all others). Pre-commit hook may take ~12 min; if a `tools/film/kill_reel_*.break.test.mjs` fails, run a Godot `--import`
   through the kit (`run_unit.mjs` does it first) and commit again; never skip the hook.

## Repo law, allowlist
`export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/combat` before every Godot run;
`GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; `--rendering-driver d3d12` for
renders; any windowed run `--position 0,1440`; Godot only through the kit (runGodot: `tools/film/*`, `tools/dev/run.mjs`,
`run_unit.mjs`). One Godot for the lane: another builder (c4, mutate in a Temp `gtai-mutate-*` worktree + `run_unit`)
runs in parallel; before each Godot launch check `wmic process where "name like 'Godot%'" get processid,commandline` for
one naming `n23-street` or `gtai-mutate` that you did not start and wait (poll 30 s, max 8 min, then go on and say so).
Stage per path, `git commit -- <paths>`; banned: git stash, add -A/./-u, commit -a, reset --hard, amend, rebase, push.
Trailer `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.
Allowlist: `project/features/combat/kills/kill_lab.gd`, `kill_lab_turn.gd`, a test under `project/tests/unit/` for a dev change,
`project/boot/launch_args.gd` (KNOWN_FLAGS append only, if unavoidable) + `tools/debt/baseline.json` via the debt tool,
`evidence/n29/kills/**`, `build/**`, the masters `n29/combat/` dir. Forbidden: `kill_fall_cells.gd` and every other product
file (do not change the fix), cast art and `cast_cards.json` (cast's), root JOURNAL.md / REPORT.md, other worktrees.

## Wall clock (binding)
Launched about 05:06. Finding written by 05:20. Commit by **05:50**. HARD STOP **06:00**: report (command, victim, style,
px heights before/after + ratios, pair path, what you saw) and END.
