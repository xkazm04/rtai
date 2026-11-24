# Brief n28-combat-05-medians: median death waves on main, after keys' dash, after the combat lane; what kills the test player

Lane `combat`, branch `n28-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadline: see the end of this brief (wall clock). At the hard stop write your report and END, even
mid-task.** Never stop to ask: at a fork pick what best serves the owner's words, write it in your report, go on. Fix lint
and format findings in your own edit and go on. No amend, no rebase. **No balance value changes** (the stomp waits for the owner).

## Why
The owner will play wave 5 and give the stomp a number. He needs the medians on the tree he will play (main + keys' shorter
dash + this lane's bond changes) and what kills the test player there. n27's method and numbers:
`docs/day/2026-11-24/n27-pressure/REPORT.md` sections 1 and 5, scripts `evidence/n27-pressure/medians/join.sh`,
`killers.mjs`, `whatif.sh`.

## What
Three arms, each 10 seeds x 3 profiles (novice, average, expert), salts 0 and 1, greedy pick, wheel controls, 40 waves:
`node tools/gauntlet/batch.mjs --profile=all --pick=greedy --controls=wheel --seeds=10 --seed0=1 --salt=<s> --waves=40 --jobs=1 --out=<dir>/salt<s>`,
then `node tools/gauntlet/report.mjs --batch=<dir>/salt<s>/batch.json` and
`node tools/gauntlet/tune.mjs floor --before=<dir>/salt0/batch.json --null=<dir>/salt1/batch.json --out=<dir>/floors.md`.
1. `main` = `d0ab9d03a`: in a temp worktree (`git worktree add <%TEMP%>/gtai-combat-main d0ab9d03a`, native DLLs copied
   from this worktree, one `--import`; `git worktree remove` it at the end).
2. `keys` = main + keys' dash only: the temp worktree checked out at `64004a59d` if keys' branch at that sha is main + dash
   (else a detached merge of `64004a59d` onto `d0ab9d03a` in the temp worktree, no commit to any branch).
3. `combat` = this branch HEAD (keys' dash merged + bond changes).
Run them ONE AT A TIME (one Godot per lane; batches are long, ~10-15 min a salt). Write each to
`evidence/n28/medians/<arm>/` (`tree.txt` with the sha, salt dirs, floors.md). Then:
- `evidence/n28/medians/medians.md`: the three columns beside n27's (`main a3b3f1466` / after keys / after melee from the
  n27 report), per profile salt 0 / salt 1 and the paired null floor. A move inside the floor is noise; say so.
- `evidence/n28/medians/killers.md` (adapt `evidence/n27-pressure/medians/killers.mjs` into `evidence/n28/medians/`):
  last blow per run on the `combat` arm, per profile, wave and median seconds alive; the stomp's share at wave 5 for
  novice and average; HP taken in the wave 5 stomp wave.
- `node tools/gauntlet/compare.mjs` main vs combat (as n27's `compare_s0.md`) -> `evidence/n28/medians/compare_s0.md`.
Commit the evidence as each arm lands (raw run JSONs too, as n27 did).

## Repo law (binding)
- Memory budget: the lane sessions hold the 8 GB cap near 6.2 GB, so the default 1200 MB estimate waits up to 30 min a run. Export `GTAI_GODOT_EST_MB=600` for headless runs and `GTAI_GODOT_EST_MB=1000` for rendered runs (measured in call 01b, `evidence/n28/bond/memory.txt`). A `mem-budget: waiting` line is still not a hang: wait; never bypass the cap.
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
  Headless only. One Godot process at a time; kill only your own PIDs, never by name. 8 GB cap: `mem-budget: waiting` is not a hang.
- Stage per path; banned: `git stash`, `add -A/./-u`, `commit -a`, `reset --hard`, amend, rebase, push. `node tools/gate/quick.mjs`
  before commits that touch code (evidence-only commits: inert paths).

## Allowlist (any other path: stop and report `NEED <what>`)
`evidence/n28/**`, your temp worktrees under `%TEMP%` (remove them at the end; never delete Temp files you did not make).
Forbidden: every product file, other worktrees, root `JOURNAL.md` / `REPORT.md`.

## Report and END (short)
The medians table (three arms beside n27), floors, the killer table headline (stomp share novice/average), what was left.

## Director update (19:30): arms by data toggle, not temp worktrees
Two temp worktrees at main died tonight (import segfault, ~12 min lost). The sim difference between main `d0ab9d03a` and
this HEAD is data only for the gauntlet: `rivet_motion.json` (dash 40 -> 24, keys) and `ghost_forms.json`
(`master_at_by_form`, `per_boss_cut` 3 -> 5); the bond code reads an absent `master_at_by_form` as the general bar
(pinned by test_ghost_bond), the deflect commit is view only. So, on this HEAD, uncommitted, one arm at a time:
- `main`: `git show d0ab9d03a:<path> > <path>` for BOTH files; `keys`: only `rivet_motion.json` stays HEAD's (24) and
  `ghost_forms.json` is main's; `combat`: nothing toggled. Restore after each arm with `git checkout -- <path>` and prove
  `git diff --quiet` on both. NEVER commit them (rivet_motion is keys'; ghost_forms is ours but the shipped values are HEAD's).
- `tree.txt` per arm: HEAD sha + which files were toggled to which sha.
- Order and scope (time): `combat` salt 0 + salt 1 (the tree he plays + its null floor), then `main` salt 0 + salt 1,
  then `keys` salt 0 only. Compare and killers on what landed. Cross-check `main` against n27's after-melee column; a
  difference outside the floor is reported, not explained away.
