# Brief b4f-share (lane foes, run n31): item 3 last levers on the own-gun window, novice + final tables

Worktree (cwd) `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n31-foes`. Read `evidence/briefs/b4-open-fire.md`
(bars, guard rail, repo law, owned files), `evidence/briefs/b4c-weapons.md`, `evidence/n31/foes/item3-compare.md`
and `git log --oneline -12` first. **Hard stop 60 min after launch: report and END.** First commit by 25 min in;
start the last commit 15 min before the stop. Measure every setting with `--rev=<its commit>` where the tool allows.

## State
HEAD = lever 1 (shooter slots max(3, ceil(0.35 x ranged))) + lever 5 (own guns, pistol 3 / rifle 2 / cannon 8 hp).
b4e (d6bacc8ab) made the probe judge own-gun foes on their own gun's window but did NOT re-measure. STEP 0 (first):
re-measure HEAD with the new probe (average, seeds 1-10, --waves=7, `--rev=d6bacc8ab` or later) into
`evidence/n31/foes/waiting-l5-ownwin/`, commit, quote idle / react p50 p90 / firing/s / damage w1-4. Also confirm the
probe still compiles at `--rev=ba8e470b0` (b4e changed foe_window's signature duck-typed; its --check run was
stopped unfinished under machine load): one seed is enough; if it does not compile, fix it first. Bars: react in range p50 <= 1.0 s, p90 <= 2.5 s, idle (engaged rule) < 35 %, guard rail damage
w1-4 (average) 53.5..72.3. Lever 2 (attack_m) was measured and rejected (react p50 0.72 -> 1.02).

## Do, in order, each one commit + one docs/decisions.md line (before -> after numbers)
1. If idle >= 35 % or p90 > 2.5 s with the rail held: `squad.max_shooters_share` 0.35 -> 0.5. Measure (average,
   seeds 1-10, --waves=7). Keep it only if the rail holds (damage w1-4 <= 72.3) and react p50 stays <= 1.0.
2. If the rail is broken by 1, try 0.45; stop at the last setting that holds.
3. Lever 4 (token-less ranged foe's ring = attack_m - 1, `squad.waiting_ring` "reach" | "lerp") only if time
   remains after 1-2 and bars still fail; same keep rule.
4. Final: novice + average tables of the final setting into `evidence/n31/foes/waiting-final/` (--rev of the
   final commit), compare table main | gait | lever1 | lever5 | each kept lever | final in item3-compare.md with
   bars and the rail for both profiles (novice rail is informational: quote main vs final).
5. Test gap from mutate (foe_own_gun.gd 12/20): one GUT test that pins the aim lead (FoeOwnGun.aim turns
   facing toward the led point for a moving Rivet) and one for `carries()` (explicit spawn / melee / own_weapons
   off each false). Re-run mutate `--file=project/features/combat/squad/foe_own_gun.gd --max=20 --lines=11-55
   --tests=test_foe_own_gun,test_squad_burst` and quote the score.
6. Full unit + scenarios green on the final commit.

Godot / owned files / law: exactly as in b4c-weapons.md (lane lock `build/n31/godot.lock` content `b4f <pid>`).
Report: commits, commands with result lines, compare table, which bars hold, mutate score, what you could not do.
