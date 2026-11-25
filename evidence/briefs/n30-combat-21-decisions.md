# n30 combat call 21: two decisions.md lines (no Godot, no product files)

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. Hard clock: commit by 15:55, END by 16:00.
Append exactly these two lines at the END of `docs/decisions.md` (match the file's existing line format: re-read its last 5 lines
first; keep one line each, no wrapping):

- [2026-11-25] DECISION combat blast cells: the FX item print (`look_d4_item`, nearest ink, no dark-amber ink) snapped every amber->ink blend of `blast_1.png` to vermilion (outline + specks on every rocket and nuke blast floor); fixed in the cell art, not the print (core/render is no lane's): `evidence/n30/floor/fix.py` turns the grain to the cell amber and the fringe to a soot grey at alpha 128 (64 px/m floor vermilion rocket 1069 -> 0, nuke 9196 -> 112, the rest not the floor; `8809bb21d`, `evidence/n30/floor/specks.md`). Rejected: darkening edge px toward amber-brown (c07b: moves them INTO the vermilion cell). Re-check when the print gains a dark-amber ink (then the soot seam can go back to a clean ink edge).
- [2026-11-25] DECISION combat explosion rim: `rim.patch` stays band <= 1 with token `amber` #EDAB42; a deeper ink (#D9922C, #C27A1F) lowered the ring-floor contrast and a wider rim (bands <= 2, `evidence/n30/lights/rim_wide.patch`) washed the core and added 89 vermilion px (`evidence/n30/lights/rim_ink.md`). A stronger read needs a different shader mix: owner call. Re-check on the owner's view of `explosion_rim_ink_abc_64.png` / `explosion_rim_wide_64.png`.

Then commit only that file: `git commit -m "docs: n30 combat decisions (blast cell soot seam, rim ink kept)" -- docs/decisions.md`
(stage with `git add docs/decisions.md` first; message ends with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`).
Never skip the hook; no amend, no stash, no `git add -A/./-u`. Another builder (c20) works on
`project/features/combat/weapons/art/fx/blast_0.png` and `evidence/n30/floor/**`: never touch those. If the hook fails on something
in a path that is not yours, report it and END without retrying more than once. Report: commit hash, hook line.
