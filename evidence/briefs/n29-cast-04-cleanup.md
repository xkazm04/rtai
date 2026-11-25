# Brief n29-cast-04: three small cleanups (hard stop 02:33)

Lane `cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n29-cast`. **Hard stop 02:33 local.** No Godot.

1. Append ONE line at the end of `docs/decisions.md` (append-only, do not edit the previous line):
   `- [2026-11-25] DECISION n29 cast card scale VOID: the body_scale line above (d198af897) is withdrawn and reverted in f1ee4718b; the director's rule measured robots against Rivet's x1.5 visual height and treated the warden and the lancer (body: human) as robots. Values stay at main's until a new rule against Rivet's design height and the unjittered cop (100.6 px at 64 px/m).`
2. In `C:\Users\kazda\kiro\gtai-masters\n29\cast\frames.json` (valid JSON array): for the `size_after_64.png` / `size_after_32.png`
   entries, prefix each `note` with `NOT SHIPPED (values reverted in f1ee4718b): ` and move them after the `size_before_*` and
   `flash_*` entries; add two entries for `flash_door_gunner_before_after_64ppm_tilt70.png` and `..._tilt55.png` (ppm 64,
   before "" , note "hit flash pulse vs calm, lancer reference column; door and gunner now print the lancer's flash") placed first.
3. Commit, pathspec only, in ONE commit: `git commit -m "docs(cast n29): void the withdrawn card-scale decision; flash harness pitch + table" -- docs/decisions.md project/dev/cast/cast_impact_edge.gd evidence/n29-cast/flash/README.md`
   (the last two are already staged by an earlier builder). Message ends with
   `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Never skip the hook. If the hook fails on `debt-ratchet`
   for dev_loc, run `node tools/debt/debt.mjs --update --accept-regression="cast_impact_edge pitch for n29 cast"` and add
   `tools/debt/baseline.json` to the same pathspec. If it fails on anything else, commit only `docs/decisions.md` and report.
Banned: `git add -A/./-u`, `commit -a`, stash, reset, amend, rebase. Touch no other file. Report the sha (or the failure) and END.
