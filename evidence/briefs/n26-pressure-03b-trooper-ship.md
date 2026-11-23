# Brief n26 pressure 03b (--resume): ship the orbit lead at 1.1 s

Hard stop HARDSTOP wall clock. Commit deadline COMMITBY. Same setup, allowlist, forbidden list and law as brief 03
(APPDATA / GODOT_BIN exports, one Godot, stage per path, `git commit -- <paths>`, no stash / add -A / amend / rebase /
reset --hard / push; fix lint and format findings in your own edit and go on).

## Director's reading of your result (binding)
Criterion (c) meant "nobody dies to rockets ALONE before wave 6", not "the last blow is never a rocket". Your own data:
novice seed 4 took exactly ONE rocket hit in the whole run (wave 5, 1 hit, 1 trooper) and it was the killing blow in the
stomp wave where 9 of 10 novices die anyway (median novice death wave 5 in every arm). Rockets alone killed nobody:
0/20 (orbit 1.1) and 0/20 (orbit 1.4). Both orbit arms therefore meet (b) and (c). By the brief's ship rule (closest to
(a)): **orbit lead at rest 1.1 s** (average 0.205 hits per trooper, vs 0.141 at 1.4 s orbit, 0.222 control; expert partial
0.5). Linear at any rest misses the circle (0/42, 0/48) so it cannot meet the owner's "circling costs health".

## Do
1. `enemies.json` `weapons.rocket`: `cooldown_s` 1.1, `lead_model` "orbit" (aim_lead, speed, damage unchanged). One
   commit "Rocket trooper: orbit lead at 1.1 s so circling costs health".
2. Tests (`test_gauntlet_fire_gaps.gd` and the lead tests): circle without dash at 10 m takes at least N hits in 30 s
   (N from your arena with margin, e.g. >= 12 of 16 launches), circle_dash takes 0, standing takes every launch, the lock
   assertions stay. A unit test on `RocketLead.orbit` if not there yet (a steady circle is hit, a dash after the lock
   is not). Each bound with a comment saying what it means.
3. Measure the per-hit cost so the owner can judge harshness: in the arena at 10 m, 1.1 orbit, circle: Rivet's hp lost in
   the first 10 s and seconds to death if he keeps circling (from your arena json or one more arena run). Put it in
   `evidence/n26-pressure/trooper/arena.md` under "What a steady circle costs".
4. A second `docs/decisions.md` line (append; do not edit your earlier line):
   `- [2026-11-23] DECISION pressure rocket trooper (supersedes the 14:25 line): ship orbit lead at rest 1.1 s; circle 48/48 at 10 m, dash 0/48, rocket hits per trooper per wave 0.205 (average, 10 seeds), rocket-only deaths before wave 6 0/21 (the one rocket last blow, novice seed 4 wave 5, was its only rocket hit, in the stomp wave); alternative rest 1.4 s orbit (0.141) is one value.`
   Update `evidence/n26-pressure/trooper/gauntlet.md` with a "Shipped" paragraph saying the same.
5. `node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs`, commit; then the scenarios that could move
   (`node tools/tests/run_scenarios.mjs --only=replay_60s,<quest 1 names>,<any gauntlet/rocket scenario>`): quest 1 tapes
   and replay_60s must not move (if they do, stop and report). Then
   `node tools/mutate/mutate.mjs --file=project/features/combat/squad/rocket_lead.gd --max=20` and quote the score.

## Report
The commit, the new test bounds, the circle cost numbers, scenario results, mutate score.
