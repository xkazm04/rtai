# Brief n28-combat-05b: the medians tables (node only), from batches the director already ran

Lane `combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd), branch `n28-combat`.
Read `evidence/briefs/n28-combat-05-medians.md` (Why, the outputs it asks for, the director update at its end).
The batches are DONE (director ran `build/n28/medians/run_all.sh`, read it): `build/n28/medians/{combat,main,keys}/`
with `salt0/` (+ `salt1/` for combat and main), `floors.md`, `tree.txt`, `progress.txt`. First check
`build/n28/medians/all.txt` ends with `ALL DONE` and `restored`, and `git diff --quiet -- project/data/tables`; if
not, STOP and report (do not start Godot, do not touch the tables).

## What (no Godot, no product edits)
1. Copy the batch outputs into `evidence/n28/medians/<arm>/` the way n27 kept them (`evidence/n27-pressure/medians/main/`:
   salt dirs with batch.json + runs, out logs, floors.md, tree.txt). Check the size first (`du -sh`); if an arm is over
   ~30 MB, keep batch.json + runs/*.json + floors only and say so.
2. `evidence/n28/medians/medians.md`: per profile (novice, average, expert) salt 0 / salt 1 for `main` (toggle),
   `keys` (salt 0 only), `combat`, and the paired null floor (main / combat), beside n27's columns from
   `docs/day/2026-11-24/n27-pressure/REPORT.md` section 1 (main a3b3f1466 / after keys / after melee). A move inside the
   floor is noise: say so per row. Cross-check our `main` against n27's after-melee column (the tree that became main
   d0ab9d03a in gauntlet terms); a difference outside the floor is reported, not explained away.
3. `evidence/n28/medians/killers.mjs` (adapt `evidence/n27-pressure/medians/killers.mjs`) -> `killers.md` on the
   `combat` arm salt 0 (and salt 1 pooled as a second table): last blow per run per profile, death wave, median seconds
   alive, the stomp's share of wave 5 deaths for novice and average, HP taken in the wave 5 stomp wave.
4. `node tools/gauntlet/compare.mjs` main vs combat salt 0 (as n27's `evidence/n27-pressure/medians/melee/compare_s0.md`;
   read its usage) -> `evidence/n28/medians/compare_s0.md`.
5. Commit (evidence, inert paths: `git commit -- <paths>`), message ending `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Rules
No `git add -A/./-u`, no stash/amend/rebase/push; never stage root `JOURNAL.md` / `REPORT.md`. Allowlist: `evidence/n28/medians/**`.
Report: the medians table, floors, the killer headline (stomp share novice/average at wave 5), the main-vs-n27 cross-check, commits.
