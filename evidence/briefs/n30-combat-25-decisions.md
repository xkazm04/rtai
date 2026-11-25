# n30 combat call 25: one decisions.md line (the nuke band soot seam)

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. **Commit by 17:00, END by 17:05.** No Godot.

Append exactly one line at the END of `docs/decisions.md` (re-read the file's last lines first; keep its format):

`- [2026-11-25] DECISION combat (n30 c23): the mini-nuke round's amber nose band gets a 1-texel opaque soot seam (128,118,118) on every band texel that touches the black stripes or the band rim orthogonally (262 texels of nuke_shell.png, 0 outside the band mask; evidence/n30/rounds/seam.py), because the FX item print snaps amber/ink blends to vermilion (c18): in game at 64 px/m the band's vermilion goes 39 -> 0 (t1212; 42/43 -> 0 at t1206/1218), amber 957 -> 869. Rejected: darker band edges (c07b, count rose to 55-71), a 2-texel seam (no fewer vermilion px, half the amber), an alpha-128 seam (same counts, but a see-through slit in a solid shell). Re-check if the print gains a dark-amber ink.`

Commit only that file: `git commit -m "docs: n30 combat decision (nuke band soot seam)" -- docs/decisions.md`, message ending with
`Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Never skip the hook; no amend, rebase, stash, add -A. Touch no other file.
Report the commit hash and END.
