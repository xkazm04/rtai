# n22-street brief 07: kill two mutate survivors in the contact counter (tests only)

Lane `street`, worktree `C:\Users\kazda\kiro\gtai-wt\n22-street`. Continue from brief 06 (all accepted).

**Wall-clock hard stop: 05:45 (stop, write the final message). Commit deadline: 05:42.** Fix lint and format
findings in your own edit and go on. Never amend, never rebase. No `git stash`, no `git add -A/./-u`, no
`commit -a`, no `reset --hard`, no tags, no merges. Stage per path; never stage `JOURNAL.md`, `REPORT.md` or
`evidence/briefs/**`. Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/street` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. One Godot
process at a time.

## Allowlist (any other path: stop and report a NEED)
`project/tests/unit/test_gauntlet_wave_stats.gd` only. No product code changes.

## The task
`node tools/mutate/mutate.mjs --file=features/gauntlet/gauntlet_combat.gd --lines=32-75 --max=12 --tests=test_gauntlet_wave_stats`
scored 9/12. Two survivors at `gauntlet_combat.gd:71`, `and -> or` in
`if killer_id == rivet.id and victim != rivet and victim.alive() and victim.exposed:`. No test shows that a
contact is NOT counted when (a) the damage comes from a hostile (killer_id is not Rivet's), (b) the victim is
Rivet himself, (c) the victim is already dead, (d) the victim is not exposed. Add one small test per case
(or one table-driven test) asserting `hits_gun` and `hits_melee` stay 0 / no `rivet_contact` emitted.
(The third survivor, `:37 set_meta(FIRED, true -> false)`, is equivalent: `has_meta` tests presence. Leave it.)

Then run `node tools/tests/run_unit.mjs --select=test_gauntlet_wave_stats` and re-run the mutate command above
with `--lines=71`; quote both lines. One commit:
`gauntlet tests: pin that only Rivet's contacts on live exposed foes count`.

## Final message
The commit sha, the unit line, the mutate score line. Nothing else.
