# Builder n31-melee-06 (sonnet, 35 min): mutate scores for item 4's three view files

Read `evidence/briefs/n31-common.md` (binding). Tag `06`. Launched 04:02; commit by 04:32; report and END 04:40.
Builder 03p7 renders films until ~04:25 and holds `build/n31/godot.lock` per run (tag 03p5 in the file).
Take the lane lock for EACH mutate run with `(set -o noclobber; echo "06 $$ $(date +%H:%M:%S)" > build/n31/godot.lock)`;
if it fails, poll every 30 s (do the reading below meanwhile). Remove it only with
`grep -q "^06 " build/n31/godot.lock && rm build/n31/godot.lock`. Never remove a lock that is not yours.

Runs, in this order, one at a time (each takes the lock, runs, frees it):
1. `node tools/mutate/mutate.mjs --file=features/combat/react/blade_marks.gd --max=20 --tests=test_blade_marks,test_claw_marks --timeout=90 --json`
2. `node tools/mutate/mutate.mjs --file=features/combat/react/shield_sparks.gd --max=20 --tests=test_shield_sparks_melee --timeout=90 --json`
3. `node tools/mutate/mutate.mjs --file=features/combat/weapons/gun_fx_wound.gd --max=20 --tests=test_gun_fx_wound --timeout=90 --json`
(check the exact --file form in tools/mutate/README.md first). Stop starting new runs at 04:25.
Write `evidence/n31-melee/04-impacts/mutate.md`: per file killed/(killed+survived), the surviving mutants
(line + op) and one line each on why a test does not see it (view-only code the headless test never draws is a
valid reason, say so). Do NOT add tests or change product code in this call. Commit that one file
(`git commit -- evidence/n31-melee/04-impacts/mutate.md`; if index.lock exists wait 20 s and retry).
Owned: `evidence/n31-melee/04-impacts/mutate.md` only. Report the scores and END.
