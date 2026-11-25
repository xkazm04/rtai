# Brief b4c-weapons (lane foes, run n31): each kind its own gun + the rest of the levers (item 3, part C)

Worktree (your cwd): `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n31-foes`.
Read `evidence/briefs/b4-open-fire.md` (owner's words, bars, guard rail, repo law, owned files),
`evidence/briefs/b4b-levers.md`, `evidence/n31/foes/item3-compare.md` (+ `item3-levers.md` if present) and
`AGENTS.md` first. **Hard stop: 60 minutes after launch, report and END.** First commit by 25 minutes in;
start your last commit 15 minutes before the stop. Never end uncommitted or with a commit in the hook.

## Where item 3 stands (read git log for b4b's commits and its numbers first)
main (average, ranged, w1-4+6-7): idle 66 %, react in range 1.05 / 6.15 s, firing/s 1.02, shot distance
p50 9 m, damage w1-4 62.9. Item 2 alone: idle 70 %, firing/s 0.66, damage 39.0 (too easy). b4b landed lever 1
(shooter slots = max(3, ceil(0.35 x ranged alive))) and maybe lever 2 (attack_m patrol 20 / SWAT 26 /
contractor 20). Bars: react p50 <= 1.0 s, p90 <= 2.5 s, idle < 35 %, guard rail damage w1-4 (average) in
53.5..72.3.

## Do, in order, each measured (average bot, seeds 1-10, `--waves=7`; novice only for the final setting), each one commit with its `docs/decisions.md` line and the re-pins it moves
1. **Lever 3, `cover_bias`** patrol and contractor 1 -> 0.5 (only if the bars still fail after levers 1-2).
2. **Lever 4, advance to a firing spot:** a token-less ranged foe's strafe ring = `attack_m - 1` (in
   `SquadMind._plan`, `project/features/combat/squad/squad_mind.gd` ~L83) instead of
   `lerp(attack_m, preferred_m, aggression)`, so it walks (TRAVEL) into reach and is ready when a token frees.
   Behind one data value `squad.waiting_ring` ("reach" new / "lerp" old).
3. **Lever 5, each kind its own gun** (the fairness lever: more guns, each weaker or slower). Today every
   non-explicit ranged kind fires the shared production `assault-rifle` (`arena_squad.gd` `spawn_member` L48,
   `_ranged` -> `GuardBrain.trigger` with `arena.tuning`), and only explicit spawns (Mulroney) fire their
   `enemies.json` weapon through `FoeAttacks.trigger`. Add `squad.own_weapons` (bool, data): when true,
   patrol cop, SWAT, contractor and robot gunner fire their `enemies.json` weapon through the `FoeAttacks`
   path (pistol 2 / 0.25 s / cooldown 1.6 s, rifle 3 / 0.1 / 1.8, cannon for the gunner), keeping the token,
   sight line, FoeGait `may_fire`, the burst-pause and `e.shot_tick` / state bookkeeping of `_ranged`. Before
   coding, READ how a round's weapon id is drawn and judged (muzzle, tracer, hit) for `pistol` / `rifle` /
   `cannon` vs `assault-rifle` (grep the view and the projectile loop); if a weapon id has no look, map it to
   the existing rifle look in foes code, or write `NEED melee` (weapon effect files are melee's) and keep the
   look of the assault rifle. `combat.json` and `weapons.json` are NOT yours: change no row there. If the
   `enemies.json` damage of these weapons is not in Rivet's damage units, say so and use the value that gives
   the guard rail (one data value per weapon, a DECISION each).
   Measure with it on; the guard rail is the judge (damage w1-4 within 53.5..72.3 for the average bot).
4. **Flank check:** `project/tests/scenarios/scenario_arena_squad.gd` lost `live.flankers < 1` in 7dfba0b0f
   (a flanking foe now TRAVELs and fires only when it holds). Replace it with a check that at least one foe
   REACHES a flank spot in the live seed (count arrivals, not shots); if the probe cannot see arrivals, add the
   counter to the scenario's own probe.
5. Final setting: average + novice tables into `evidence/n31/foes/waiting-final/`, the compare table
   main | gait | each lever | final in `evidence/n31/foes/item3-compare.md`, full unit + scenarios green,
   mutate on the changed lines (`--max=20 --lines=... --tests=...`), quote the score.

Stop at the last setting that holds the guard rail; everything beyond goes in the report as a call for the
owner with the measured effect.

## Godot, owned files, repo law
As in `b4-open-fire.md` and `b4b-levers.md` (APPDATA `C:/Users/kazda/kiro/gtai-n31/appdata/foes`, lane lock
`build/n31/godot.lock` with content `b4c <pid>`, Godot only through runGodot, one `docs/decisions.md` line per
lever, stage per path, no amend/rebase/stash/--no-verify, message ends with
`Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`, fix lint and format findings in your own edit).
Owned additionally: `project/tests/scenarios/scenario_arena_squad.gd`.

## Report (final message)
Commits, commands with result lines, the compare table with bars and guard rail, which bars hold, the weapon
look finding, mutate score, NEED lines, what you could not do.
