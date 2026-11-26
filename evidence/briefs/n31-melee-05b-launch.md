# Builder n31-melee-05 launch notes (03:58), on top of evidence/briefs/n31-melee-05-amber-print.md

Launched 03:58; commit by 04:18; report and END by 04:28. Builder 03p7 renders films through play_take beside
you and holds `build/n31/godot.lock` per run: step 2 (the still pair) only if the lock is free when you get there,
taken with `(set -o noclobber; echo "05 $$ $(date +%H:%M:%S)" > build/n31/godot.lock)`, removed with
`grep -q "^05 " build/n31/godot.lock && rm build/n31/godot.lock`; the temp worktree goes under
`C:/Users/kazda/kiro/gtai-n31/tmp-05` (not Temp) and is removed after. Otherwise skip step 2 and say so.

Two extra small parts (do these FIRST, Godot-free, one commit each):
A. Append ONE line to `docs/decisions.md` (append-only, keep every existing line):
   `- [2026-11-26] DECISION melee n31 enemy melee on Rivet: not changed tonight. Measured (01b, tools/melee/foe_reach.mjs): no foe melee hit lands with Rivet's whole body past the drawn tip, so reach is fair by body contact; but 42 of 58 hits land while he walks sideways out of the tell, because foe_attacks.gd locks the aim at the tell's start and hits within +-60 deg of it (foes' file). Owner call: narrow the cone or re-test against the drawn arc at the hit tick (one value in foe_attacks.gd for the foes lane). Rejected: a melee-side hurt radius cut (it would shrink every hit on Rivet, not the late ones).`
   Check the 42/58 numbers against `evidence/n31-melee/01b*` or the 01b section of JOURNAL.md first; correct them if they differ.
B. `C:/Users/kazda/kiro/gtai-masters/n31/melee/frames.json`: move every `slow_*.mp4` entry to the END of the
   list and prefix its note with "lab clip, hit volume not readable at this zoom; the polar sheet carries item 2's
   lab evidence. ". One read-modify-write node call (03p7 edits this file too). Not in git: no commit.
