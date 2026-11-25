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

## Notes from the director (session 2, 03:24)
State at launch: fire 3a7fcfed0/12b7c141b/ddd15787f (+ fire.md); muzzle 2a1069f77 (muzzle.md: in-game gun flashes print cream before and after, the d4 muzzle star moved; row 11 kept: owner call); electric 330ad6592/3bf74f0c7 (electric.md; row 19 TUCK-IN glyph = dead code `StageView._bolt_robot`, the on-screen crate is the tuckin_crate PNG); sword 85c6b0c53 (row 15 four files; the showcase / held_55 small sword is another design with no rings; in-game stills still owed: mark `FIXED (source) <sha>, in-game still owed`); molotov rag row 12 = keys (NEED keys); rivet_eq_plasma_sword sheets in view/p55 + p70 carry rings = NEED keys. A third builder (electro bolt) commits in the same worktree: commit with `git commit -- evidence/n29/red/audit.md <your script>` only.

## Wall clock (binding)
Started 03:24. Commit the table (even with some rows marked `TODO <why>`) by **03:42**. HARD STOP **03:47**: report and END, committed.
