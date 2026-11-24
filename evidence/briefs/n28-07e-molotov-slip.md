# Brief n28-07e-molotov-slip: find why the molotov's run slips (diagnosis, no commit)

Same header rules and allowlist as `evidence/briefs/n28-07-ray-molotov.md` (molotov only). Worktree
`C:\Users\kazda\kiro\gtai-wt\n23-controls`, `cd` there in every shell command. **HARD STOP: report and END by 20:45.
Commit nothing; leave the wired molotov files in the tree as they are** (the next session commits). No new images.

The run foot-slide at 32 px/m is 10.94/20.31 cm (bar 7; rifle 6.69/8.93) and did NOT change when run row 1 was replaced,
so row 1 is not the cause. Find it: from `build/fs_molotov.json` and the capture under
`C:/Users/kazda/kiro/gtai-masters/n28/keys/grid_molotov_arena/rows`, which strip row (facing) and which cells the turn_090
lane reads; compare their sole/boot positions cell by cell against the donor's (plasma rifle) run sheet and against the ray
gun's shipped run sheet (which passed at 6.35); check the wiring difference (the ray gun KEPT `run_row_k` 1 lines for its
flagged rows in `rivet_motion.json`, this one dropped them). If the cause is a few cells' legs, build the fix (the donor's
legs under the edited arms in those cells, the 82 % seam as `final2`) into `molotov/final4/` but do not install it unless
you can re-measure by 20:42. Write cause, cells and the exact next steps into `molotov/STATE.md` "Next".

Report: the cause, the cells, whether final4 exists, the next steps.
