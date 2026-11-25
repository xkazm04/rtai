# Brief n29-combat-04-mutate: finish the pressure_rifles.gd mutate run and pin what survives

Lane `combat`, branch `n29-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadline: see "Wall clock" at the end (binding).** Never stop to ask; fix lint/format findings in
your own edit and go on. No amend, no rebase, no push. Read `AGENTS.md` and `tools/mutate/README.md` first, briefly.

## What
n28 ran mutate on `project/dev/gauntlet/pressure_rifles.gd` (tests `test_pressure_takes`) and stopped at the time cap
after 7 of 12 mutants: 3 killed / 4 survived (`evidence/n28/deflect/mutate.md`); the shooter-pick line (`turn`, the
round-robin by rounds fired that 55f8d0778 added) was never reached.
A. Run `node tools/mutate/mutate.mjs --file=project/dev/gauntlet/pressure_rifles.gd --lines=<the turn pick lines + 36-41, 69-85> --tests=test_pressure_takes --max=20`
   (budget 20 min; `--json` to keep the table). Quote killed/(killed+survived).
B. For every survivor that changes what a take does (a beat, a salvo count, an `and`/`or`), add the smallest pin to
   `project/tests/unit/test_pressure_takes.gd` that kills it (a test that names the behaviour, not the literal). An
   equivalent mutant (no behaviour change): explain it in the note, no test. Re-run mutate on the same lines; quote
   before -> after. `run_unit.mjs --select=test_pressure_takes` green, `node tools/gate/quick.mjs`, commit tests +
   `evidence/n29/mutate/pressure_rifles.md` (table before/after).

## Repo law, allowlist
APPDATA `C:/Users/kazda/kiro/gtai-n29/appdata/combat`, `GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`,
`GTAI_GODOT_EST_MB=600`; one Godot for the lane (another builder may run one: you queue; never kill what you did not
start). Quick gate before commit; the hook takes up to ~12 min (kill_reel break test fails = stale class cache: Godot
`--import`, commit again; never skip the hook). Stage per path; banned: `git stash`, `add -A/./-u`, `commit -a`,
`reset --hard`, amend, rebase, push. Trailer `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.
Allowlist: `project/tests/unit/test_pressure_takes.gd`, `evidence/n29/mutate/**`, `build/**`. `pressure_rifles.gd` itself
only if a survivor reveals a real bug (then say so). Anything else: `NEED`.

## Report and END (short)
Commit; score before -> after; survivors explained; gate lines.

## Added by the director (session 4)
C. `project/boot/collect_call/view/current_look.gd` (n29 c2e, the tazer + burst arc current): mutate
   `--tests=test_collect_call_current --max=20` (budget 15 min), quote the score; pin a behaviour-changing survivor in
   `project/tests/unit/test_collect_call_current.gd` the same way as B. Allowlist adds that test file.
D. `project/dev/ghost-forms/bond_film.gd:68` crashes at `--prefill=0`: `forms.table.order if _prefill > 0 else []` puts
   an untyped `[]` into `Array[StringName]`. Fix it (e.g. a typed empty `var none: Array[StringName] = []`), check with
   `node tools/godot/check.mjs res://dev/ghost-forms/bond_film.gd`, and run the bond film entry once headless with
   `--prefill=0` through `node tools/dev/run.mjs` to show the crash is gone (paste its verdict line). Allowlist adds
   that file.
Mutate runs need Godot: the other builder (c2d2 sword stills + film) runs in parallel: one Godot for the lane between
you two. Before every mutate/Godot launch check `wmic process where "name like 'Godot%'" get processid,commandline` for a
Godot naming `n23-street` you did not start; wait for it (poll 30 s, max 10 min, then go on and say so). Mutate's Godot
runs in a Temp worktree `gtai-mutate-*`: that one is yours. Mutate leaves its Temp worktree when it ends cleanly; if one
is left from your run, remove it (never one you did not create).

## Wall clock (binding)
Launched 04:55. Order A+B (pressure_rifles), then D (quick, a bug), then C. Commit A+B by **05:30**, D by **05:40**,
C by **05:55**. **HARD STOP 06:05**: report and END, committed. Write `evidence/n29/mutate/<file>.md` per file.
