# n31 ghost 01: Tonnage before (main) and after (HEAD drop mode)

Builder `g01-measure`, 2026-11-25. Before = `ba8e470b0` (main, run in a temp worktree, see `measure-main.md`).
After = this branch at `22511980e`, which contains g02-drop's `d7db0eb24`: one press, 27-tick charge, then a
full circle of radius 5.5 m on the aim spot with the victim radius added. Both sides were measured with the same
tool (`tools/ghost/deploy_measure.mjs`, as shipped, no what-if flags), the same 13 to 15 lab shapes per size and the
same gauntlet seeds 1..10 with profile `average`. Tool fix for drop mode: key-down = the tick the ghost leaves IDLE
(AIMING on main, ACTIVE at once in drop mode), damage = the tick `GhostDeployStrike.land` runs (the dump tick). The lab steps on after the
release until the dump lands, and as-shipped reads the drop row's radius for the bot-spot search (optional fields,
defaults to main). Re-running main's lab with the fixed tool gives the identical table (`main-recheck`).
In the summary JSON "(main)" in a variant name means "as shipped at that rev".

| measure | main `ba8e470b0` (hold, half-disc 4 m) | HEAD `22511980e` (drop, full circle 5.5 m, 27-tick charge) |
|---|---|---|
| lab, 8-cop share hit (15 shapes) | 54% (4.33 of 8) | 67% (5.33 of 8) |
| lab, 4-cop share hit | 78% | 80% |
| lab, 12-cop share hit | 44% | 70% |
| play 8 waves, deploys | 106 | 115 |
| play 8 waves, mean hits / deploy | 2.80 | 3.71 |
| play 8 waves, median hits / deploy | 3 | 3 |
| play 8 waves, mean kills / deploy | 2.33 | 3.19 |
| play 8 waves, zero-hit deploys | 2 | 0 |
| play 8 waves, key-down to damage, ticks (median) | 1 | 27 |
| play 3 waves, deploys | 48 | 48 |
| play 3 waves, mean hits / deploy | 3.21 | 4.02 |
| play 3 waves, median hits / deploy | 3 | 4 |
| play 3 waves, mean kills / deploy | 3.21 | 4.02 |
| play 3 waves, zero-hit deploys | 0 | 0 |
| play 3 waves, key-down to damage, ticks (median) | 1 | 27 |

The play runs are whole runs, so they differ in more than the footprint: on HEAD seeds 5 and 8 died at wave 5, and
on main seeds 3, 4 and 7 died at waves 5, 6 and 5. The lab foes are live for the 27 charge ticks on HEAD, so the cops move
before the dump lands. That is the shipped behaviour, and it is why HEAD's 8-cop share (67 %) sits below the instant
full-circle 5.5 m what-if on main (83 %, `measure-main.md`). The charge costs about 16 points of share on 8 cops.
In play the charge costs little: full r5.5 at the spot with no charge gave 3.86 hits per deploy on main at 3 waves, and HEAD gives 4.02.
