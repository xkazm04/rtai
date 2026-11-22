# Brief n24-pressure-04: the test player finishes its leftovers, and dashes out of a rocket's path

You build for lane `pressure` of RTAI (Godot 4, internal id `gtai`) in this worktree, branch `n24-pressure`.
Read `AGENTS.md` and `docs/gauntlet-loop.md` (the "Test player" section) before you start. STANDARDS.md binds.

**Wall clock: hard stop HARDSTOP. Last commit by COMMITBY.**

The pre-commit hook takes about 10 minutes on a table commit: start your last commit no later than COMMITBY.

**Godot is the director's until GODOTFREE.** The director runs one gauntlet batch (a Godot process of this lane) from
your start until GODOTFREE. Until then: read, design, write the code and the tests, but launch no Godot, no unit run,
no gate, no render (the lane gets one Godot at a time). After GODOTFREE Godot is yours alone.


## Machine rules, git law

As in `evidence/briefs/n24-pressure-02-deflect.md` sections "Machine rules" and "Git law" (read them). No merges: the
director merges other lanes.

## Allowlist (any other path: stop and report `NEED <lane>: <file> <why>`)

`project/features/gauntlet/**` (the bot is `project/features/gauntlet/bot/**`), `project/dev/gauntlet/**`,
`project/data/tables/gauntlet.json`, `project/data/tables/test_player.json` (+ their schemas),
`project/data/schemas/gauntlet_run.schema.json` (your own optional fields only), `tools/gauntlet/**`,
`docs/gauntlet-loop.md`, tests named for these files, `docs/decisions.md` append-only.
Forbidden: `project/features/player/**` (motion and melee own the player), `rivet_motion.json`,
`input_actions.json`, souls, characters, art, `combat.json`.

## Task 1 - the stall (one commit)

Last night average seed 9 (and seed 8) ran to the 216000-tick cap with all 40 waves "cleared", stuck on a
`sentry_turret` and a `shield_robot` left over from a timed-out wave. Evidence: `C:\Users\kazda\kiro\gtai-n23\freeze\avg89\`
(`runs/average-9.json`, `logs/average-9/`; the run command is the last lines of `logs/average-9.log`). Last night's
reading (`docs/day/2026-11-22/n23-loop/REPORT.md` lines 86-92): after timed-out waves about 40 hostiles and Rivet stop
dealing damage to each other. Reproduce it on this branch (same command, `--result` into
`evidence/n24-pressure/stall/`; if it no longer reproduces because the tables changed, reproduce it on the old tables
with a temp worktree via `tools/gauntlet/ablate.mjs --rev=b3f4727c0`), find WHY the bot cannot finish them (target
choice, path, line of sight, the sentry's armoured face, the shield's front, attack slots, a wave-state flag) and
whether a human could (a person would walk around the shield, hit the sentry's back): say which. Fix the bot (or, if the
cause is in game code outside your allowlist, write the NEED with the file and line and add a bot-side workaround).
Add a no-progress guard: when no hostile loses hp for 20 s of live wave, the result file records a `stall` entry for
that wave (`{"wave", "tick", "left": {<archetype>: n}}`, optional field, schema) and the run ends with outcome
`stalled` instead of hanging to the cap, so a batch never burns 8 minutes on one stuck run. Unit test for the guard.

## Task 2 - dash (one commit; `n24-motion` is merged at `b0a9c4c09`)

Lane motion adds input action `dash` (Shift; row bit 18, wire bit 31 per motion's JOURNAL `MILESTONE iface`) with
numbers in `project/data/tables/rivet_motion.json` block `dash` (`distance_m`, `ticks`, `cooldown_ticks`,
`iframe_ticks`, `enabled`); direction = held move input. Read motion's code to see how the press is read from
`TickInput`. Teach the bot to dash out of a large round's path (a rocket, a cannon shell) and out of a stomp radius, at
the skill levels where a player would: a `test_player.json` per-profile `dash_chance` (novice 0.2, average 0.6, expert
0.9) and `dash_read_ticks` (the reaction before it dashes: novice 30, average 16, expert 8, like the reaction ticks),
dashing sideways to the round's path when the roll is on cooldown or the round is too close for a roll. Count dashes per
wave in the result file as `dashes` (the contract's name; optional; omitted when 0 was not measured). Unit test with a
fake view: a rocket on a collision course -> a dash press within `dash_read_ticks` sideways to its path.

## Task 2b - ghost deploy: NOT yours

Lane ghost builds the bot's deploy policy itself (its JOURNAL 21:16: class `GhostDeployBot` in
`project/features/souls/ghost_deploy_bot.gd` and ONE call site in `project/features/gauntlet/bot/bot_brain.gd` `_pack`
plus its member and `_init` line). Do not write a deploy bot. Keep `bot_brain.gd` `_pack` easy to add one line to (no
rename of `_pack`, `_view`, `intent`, `_profile`).

## Task 1b - damage taken by source (one commit, before task 2)

The judging table needs "damage taken per wave by source"; a wave today only carries `damage_taken` (a total). Add an
optional per-wave `damage_by` object to the result (`{<source>: hp}`, source = the enemy weapon id from `enemies.json`
`weapons` (`pistol`, `rifle`, `rocket`, `stomp`, `war_cannon`, ...), or the archetype id for a melee contact, `self` for
Rivet's own blasts; sorted keys; a wave with no damage omits it), described in `gauntlet_run.schema.json`, written from
the same place `damage_taken` is summed (the gauntlet's own code, `project/features/gauntlet/**`; if the source id is only
known in combat code outside the allowlist, read it there through an existing signal or field, never edit that file:
NEED). Teach `tools/gauntlet/report.mjs` (or its tables module) a "Damage taken by source" section: per profile, the
median per wave of each source over the waves that were played, plus each source's share of all damage taken. Unit test
for the field, a node test for the table. It must not change the replay digest (results are not hashed: check).

## Task 2c - the stomp (read first, small)

The after-gaps batch (`evidence/n24-pressure/after-gaps/report.md`) lost 10 of 15 runs to the wave-5 war machine
(stomp 7, war_cannon 3); every novice died to the stomp. `enemies.json` `weapons.stomp`: `damage` 48 and
`splash_damage` 48 in 3.5 m (Rivet max_hp 100). Check in the code whether one stomp lands BOTH on Rivet (96). If it
does, that is a double count: report it with file:line as `NEED director: stomp double count` (the fix is in combat
code; do not change the boss's design numbers). Either way the bot must read the stomp's 0.8 s tell
(`alt_telegraph_s`) and step or dash out of 3.5 m at the skill levels where a player would (part of task 2).

## Task 3 - a smoke batch (no commit needed beyond evidence)

`node tools/gauntlet/batch.mjs --profile=all --pick=greedy --controls=wheel --seed0=1 --seeds=2 --waves=40 --jobs=1
--out=<abs>/evidence/n24-pressure/smoke-04` and report: every run ends (death, wave 40 alive, or `stalled`), wall time,
death waves, dashes per wave median.

## After each code commit

`node tools/mutate/mutate.mjs --file=<main changed .gd> --max=20 --lines=<changed lines>`; quote the score.

## Report

Per task: done / not done, commit sha, files, checks with result lines, the stall cause in two sentences (and whether a
human could finish), smoke results, every NEED.
