# Brief n28-combat-01b-bond (fresh call, continues 01): Tonnage gets his own mastery bar, Kerf's boss cut 3 -> 5, the ten-seed table n27 beside n28

Lane `combat`, branch `n28-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd), cut from `main` `d0ab9d03a`.
**HARD STOP 18:12 (wall clock): write your report and END, even mid-task. Commit part A+B by 17:45.** Never stop to ask: at
a fork pick what best serves the owner's words, write it in your report, go on. Fix lint and format findings in your own
edit and go on. No amend, no rebase.

## Why (owner, 2026-11-24)
"Mastery pace: keep 30 and play first", and he also ticked "a per-ghost mastery bar so Tonnage stops mastering at wave 3".
Both hold: the general bar `bond.master_at` stays 30 for Dent, Kerf and Ohm; Tonnage gets a bar of his own. "Kerf's boss
cut 3 to 5." Last run (`docs/day/2026-11-24/n27-melee/REPORT.md`, `evidence/n27/bond/mastery.md`): on ten seeds of the
average test player, Tonnage mastered at rests 3, 3, 4; Kerf was never mastered (best 28/30, seed 5).

## Contract (wire names, use exactly)
`project/data/tables/ghost_forms.json` `bond`: `master_at` stays 30; NEW `master_at_by_form: {"tonnage": <n>}` (absent
forms use `master_at`); `per_boss_cut` 3 -> 5.

## State (read first)
A previous call (stopped by the director at 17:08) already wrote part A, UNCOMMITTED in this tree: `ghost_forms.json`
(`master_at_by_form: {"tonnage": 999}` = the probe value, `per_boss_cut` 5, doc text), the schema, `ghost_bond.gd`
(`master_at_for`), `ghost_bond_ring.gd`, `ghost_form_table.gd` (`_read_bars`, unknown-id error), and the three test files.
Review it with `git diff`, keep what is right, run its tests, and go on. Fix one doc phrase: "so he stops mastering at wave
3" reads wrong; say "so Tonnage's first mastery comes later". Step 0's `--import` may already be done (check `project/.godot`).

**Why it was stopped: the memory budget.** The run's lane sessions keep the 8 GB cap at about 6.2 GB, so a Godot launch
that asks for the default 1200 MB (`GTAI_GODOT_EST_MB`) waits up to 30 min, every run. For HEADLESS runs only, export
`GTAI_GODOT_EST_MB=600` (a headless bond_measure is far below that; measure the first run's peak working set with
PowerShell `Get-Process -Id <godot pid>` polling and write it in `evidence/n28/bond/memory.txt`; if the peak is above
500 MB, raise the value to peak x 1.25). For rendered runs (part E) use `GTAI_GODOT_EST_MB=1000`. If a log still says
`mem-budget: waiting`, wait; never bypass the cap. Probe runs already wrote `build/n28/probe/` (none finished).

## What
0. First, once: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
   and run one headless `"$GODOT_BIN" --headless --path project --import` (fresh worktree for this run). Use those two
   exports before EVERY Godot run.
A. **Per-form bar: code + data + schema + tests.** `ghost_forms.schema.json` gets `master_at_by_form` (object, keys
   snake_case form ids, values number > 0; `additionalProperties: false` stays on `bond`). `GhostFormTable` reads it (an
   unknown form id in it = a load error, like `order`). `GhostBond` gets `master_at_for(form) -> float` and uses it in
   `record` (the cap) and wherever mastery is decided (grep every `master_at` read). `GhostBondRing`
   (`ghost_bond_ring.gd:27-29`) fills against the form's own bar. Grep the rest: `project/dev/ghost-forms/bond_film.gd`
   (prefill = "points short of the form's bar"), `quest_bond_tape.gd`, any mastery card / HUD text that shows the bar.
   Keep `GhostBond.master_at` as the general bar.
   Tests (`test_ghost_bond.gd`, `test_ghost_bond_ring.gd`, the form table's test): Tonnage caps and masters at his own bar;
   an absent form (dent, kerf, ohm) at 30; the ring fraction uses the form's bar; an unknown id in `master_at_by_form` is
   a load error. `per_boss_cut` 5: update `test_ghost_boss_cut.gd` and the table's `doc` text (its prose names the cut
   and "(30)"; fix both and describe `master_at_by_form` in one sentence).
B. **Choose Tonnage's value from data, not a guess.**
   1. Probe arm: `bond.master_at_by_form.tonnage` temporarily 999 (uncommitted), `per_boss_cut` 5; run the ten seeds
      exactly as `evidence/n27/bond/mastery.md` section "Measurement" says (`bond_measure.tscn`, `--bot=average
      --pick=greedy --waves=15 --mastery-free=1`, seeds 1..10). The per-rest bond in the log gives Tonnage's unperturbed
      bond at each rest.
   2. Value: the smallest multiple of 5 strictly above Tonnage's bond at every rest 1..7 on all ten seeds (so his first
      mastery can only come at rest 8 or later). Record the per-seed bond at rest 7 and the value in the evidence.
      If that value is so high that Tonnage cannot reach it by rest 15 on any seed, still take it and say so.
   3. Set it, commit A+B with ONE appended `docs/decisions.md` line:
      `- [2026-11-24] DECISION n28 combat: bond.master_at_by_form.tonnage = <n> (his bond at rest 7 was <max> at most on the ten seeds, so his first mastery comes at rest 8 or later); master_at stays 30 for Dent, Kerf, Ohm (owner: keep 30 and play first); per_boss_cut 3 -> 5 (owner). Rejected: a higher master_at for all (n27: it only dropped the late masteries).`
C. **The table** (after the commit, on the committed tree): ten seeds, arm `n28` (shipped values). Write
   `evidence/n28/bond/mastery.md` + `mastery.json` (copy and adapt `evidence/n27/bond/summarize.mjs` and `report.mjs`
   into `evidence/n28/bond/`): the n27 free row beside the n28 row: runs with a mastery, first-mastery waves, which ghost,
   inside wave 8..15, Kerf mastered; Kerf's bond at end and boss cuts per seed; the probe arm's Tonnage bond per rest.
   Commit.
D. **Mutate** after the commit: `node tools/mutate/mutate.mjs --file=project/features/souls/ghost_bond.gd --max=20
   --lines=<your changed lines> --tests=test_ghost_bond,test_ghost_bond_ring,test_ghost_boss_cut` (budget 15 min; stop it
   past that and say so). Quote killed/(killed+survived) and each survivor in `evidence/n28/bond/mutate.txt`. Commit.
E. **Film, if time remains (commit by 18:05):** re-render the bond film with the new bar and main's larger chip numbers,
   as `evidence/n27/films/films.md` and `evidence/n27/films/render_bond.mjs` describe (entry
   `project/dev/ghost-forms/bond_film.tscn`, seed 2, `--bond-prefill=6`), 32 px/m, 1920x1080, 60 fps, 15-40 s, to
   `C:/Users/kazda/kiro/gtai-masters/n28/combat/films/bond_mastery.mp4`, plus a 64 px/m still of the HUD chip strip with
   Tonnage's ring partly filled, `.../n28/combat/stills/bond_chips_64.png`. `ffprobe` each and quote the line. Look at the
   frames yourself (the ring fills against his bar; the numbers 1 to 4 read). Start
   `C:/Users/kazda/kiro/gtai-masters/n28/combat/frames.json` (array of `{file,title,ppm,before,note}`; `before` =
   `C:/Users/kazda/kiro/gtai-masters/n27/melee/films/bond_mastery.mp4` or null).

## Checks
`node tools/tests/run_unit.mjs --changed` green; `node tools/gate/quick.mjs` before every commit; also
`node tools/tests/run_unit.mjs --select=test_gauntlet_mastery,test_bot_pick_mastery,test_ghost_boss_cut`.
The 60 s replay and parity must not move (bond is gauntlet-only; if a tape or replay moves, stop and report it).
Budget about 12 minutes for the pre-commit hook. If it fails on `tools/film/kill_reel_*.break.test.mjs`, run a Godot
`--import` and commit again (never skip the hook).

## Repo law (binding)
- One Godot process at a time (you are the only one in this lane; the director waits). `--rendering-driver d3d12` for
  renders; any windowed run at `--position 0,1440`, never the main display. Kill only your own PIDs, never by name.
  The machine runs under an 8 GB cap: a log line `mem-budget: waiting` is not a hang; wait.
- Typed GDScript, ~200 lines a file (hard 300), functions <= 40 lines, <= 5 params, `Log` not print, `.uid` with every
  new `.gd`, Godot `--import` after new scripts before committing. Data is JSON with its schema. Stage per path; banned:
  `git stash`, `add -A/./-u`, `commit -a`, `reset --hard`, amend, rebase, push.

## Allowlist (any other path: stop that part and report `NEED <what>`)
`project/data/tables/ghost_forms.json`, `project/data/schemas/ghost_forms.schema.json`, `project/features/souls/**`
(only bond/ring/table code and what reads `master_at`), `project/features/gauntlet/**` (only a `master_at` read),
`project/dev/ghost-forms/**`, `project/tests/unit/test_ghost_*.gd`, `project/tests/integration/test_gauntlet_mastery.gd`,
`project/tests/unit/test_bot_pick_mastery.gd` (+ `.uid` of any new test), `docs/decisions.md` (one appended line),
`evidence/n28/**`, `C:/Users/kazda/kiro/gtai-masters/n28/combat/`.
Forbidden: `input_actions.json`, `rivet_motion.json`, `project/features/player/**`, character art, `cast_cards.json`,
`project/boot/prologue/**`, other worktrees, root `JOURNAL.md` / `REPORT.md`.

## Report and END (short)
Commits; the probe's Tonnage bond at rest 7 per seed and the chosen value; the n27/n28 table; unit + quick gate lines;
mutate score; film/still paths + ffprobe lines; what failed or was left.
