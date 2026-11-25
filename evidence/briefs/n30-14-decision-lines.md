# n30-14 decision-lines: append this session's keys decisions to docs/decisions.md (lane keys, docs only)

Launched ~13:17. **Commit by 13:35, END by 13:40.** Work in `C:/Users/kazda/kiro/gtai-wt/n23-controls` (branch `n30-keys`).
Never amend, rebase, push, stash, `git add -A/./-u`, `commit -a`, `reset --hard`; `git commit -- docs/decisions.md` only (builder
n30-13 commits evidence files in this worktree). No Godot, no images, no other file.

Read the last 40 lines of `docs/decisions.md` (format: `- [YYYY-MM-DD] DECISION <area>: what was chosen, why, what was rejected.`;
the n30 keys lines already there are the model). Check each commit named below with `git show --stat <sha>` and quote numbers only
from its message or from the evidence md it names. Append, one line each, dated 2026-11-25, area `keys n30`:
1. The molotov run step: row 1 cols 5, 6 of `p70/rivet_run8_eq_molotov.png` registered 1 px to the donor's planted sole x
   (`0e399a732`; `evidence/n30-keys/grid_molotov.md` "Run step trace"): run step 7.28 -> 5.77 cm mean (bar 7), walk hold unchanged;
   `run_row_k` rejected (the cycle floor binds, bit-identical numbers). This supersedes the earlier n30 line that shipped it at 7.28
   (say so; do not edit that line).
2. p55 collar leftovers and row 6 visors: r7c3 r7c4 r6c2 r6c6 rigid (`2641a10fe`), row 6 cells 3, 5, 7, 8 keep the pre-n30 visor
   px inside protect boxes (`68d873f9e`; a re-composite was rejected because it moved two accepted bands 1 px). Rows 3, 6, 7 8/8;
   row 8 cells 4, 8 touch-ups kept shipped (two image edits each did not reach the defect, outside the collar hull).
3. p70 aim-left collar: the last 8 images of the lane went to `rivet_eq_{rocket_launcher,mini_nuke,gatling}_left` (`8776d8711`,
   `f371eddb6`, `f3aefd0a2`; audit `57c72c41a` `evidence/n30-keys/eq_collar_audit.md`): 7 cells rigid, mini-nuke c0 rejected on sight;
   why: the rigid-collar law and p70 is the in-play default; not an owner pick ("raise the weakest"); the alternative is
   `git revert` of the three art commits.
4. Before sheets from an older commit come from `node tools/film/blob.mjs <rev>:<path>` (LFS smudged); `git show` writes the LFS
   pointer and Godot imports it as an empty texture (n30-11 lost its film run to this).

Run `node tools/lint/lint.mjs` only if the pre-commit hook asks; never skip the hook. Commit
`docs(keys n30): decision lines (molotov step, collar leftovers, p70 aim-left collar, LFS before sheets)`. Report the sha and END.
