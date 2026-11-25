# Brief n29-combat-05-audit: re-run the n28 red audit on the n29 tree, every row fixed / explained / NEED

Lane `combat`, branch `n29-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadline: see "Wall clock" at the end (binding). At the hard stop write your report and END, even
mid-task.** Never stop to ask. Fix lint and format findings in your own edit and go on. No amend, no rebase, no push.
Read `AGENTS.md` (repo law) first, briefly.

## Why
The owner: "repaint all the red the audit found". The audit is `evidence/n28/red/audit.md` (28 rows, its counter
`evidence/n28/red/count_red.py` or whatever it names). n29 repainted it group by group: read
`evidence/n29/red/{fire,electric,muzzle,sword}.md` and `git log --oneline c649a15d6..HEAD`.

## What
A. Re-run the n28 counter with the SAME thresholds on the same files at HEAD (and at `c649a15d6` from a temp worktree
   or `git show <rev>:<path>` blobs, never by touching the tree) and write `evidence/n29/red/audit.md`: the same 28 rows,
   columns `# | source | n28 px | n29 px | status | evidence`, status one of `FIXED <commit>`, `KEPT <colour-law reason>`
   (blood, danger cues, objectives, Rivet's collar), `NEED keys` / `NEED cast` (owner of the file, with the file list),
   `NOT ON SCREEN <why>`. Code rows (13, 14, 17-22): grep the cited lines at HEAD and say what colour they draw now.
   Every row has a status; no blank.
B. A short top section: totals (reddish px over all F/H/E rows n28 -> n29), what reaches the screen (cite the pair
   stills in `C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/`), the owner calls (Mertz's vermilion gloves = cast
   art; the molotov rag = keys; the FX-view amber ink scope; anything new you find).
C. Commit (`evidence/n29/red/**` only). `node tools/evidence/cites.mjs evidence/n29/red/audit.md` must show no MISSING.

## Allowlist
`evidence/n29/red/**`, `build/**`. Read anything. Forbidden: every product file, other worktrees, root `JOURNAL.md` /
`REPORT.md`. No Godot needed (if you need one: one at a time for the lane, through runGodot, APPDATA
`C:/Users/kazda/kiro/gtai-n29/appdata/combat`). Trailer `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Report and END (short)
Commit; the totals; rows by status; anything not fixed and why.
