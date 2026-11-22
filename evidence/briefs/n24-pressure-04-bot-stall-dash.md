# Brief n24-pressure-04: the test player finishes its leftovers, and dashes out of a rocket's path

You build for lane `pressure` of RTAI (Godot 4, internal id `gtai`) in this worktree, branch `n24-pressure`.
Read `AGENTS.md` and `docs/gauntlet-loop.md` (the "Test player" section) before you start. STANDARDS.md binds.

**Wall clock: hard stop HARDSTOP. Last commit by COMMITBY.**

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

## Task 2 - dash (one commit; only after the director has merged `n24-motion`: check `git log --oneline -5` for a merge
of `n24-motion`; if there is none, skip this task and say so)

Lane motion adds input action `dash` (Shift; row bit 18, wire bit 31 per motion's JOURNAL `MILESTONE iface`) with
numbers in `project/data/tables/rivet_motion.json` block `dash` (`distance_m`, `ticks`, `cooldown_ticks`,
`iframe_ticks`, `enabled`); direction = held move input. Read motion's code to see how the press is read from
`TickInput`. Teach the bot to dash out of a large round's path (a rocket, a cannon shell) and out of a stomp radius, at
the skill levels where a player would: a `test_player.json` per-profile `dash_chance` (novice 0.2, average 0.6, expert
0.9) and `dash_read_ticks` (the reaction before it dashes: novice 30, average 16, expert 8, like the reaction ticks),
dashing sideways to the round's path when the roll is on cooldown or the round is too close for a roll. Count dashes per
wave in the result file as `dashes` (the contract's name; optional; omitted when 0 was not measured). Unit test with a
fake view: a rocket on a collision course -> a dash press within `dash_read_ticks` sideways to its path.

## Task 2b - ghost deploy (one commit; only after the director has merged `n24-ghost`; else skip and say so)

Lane ghost's `NEED pressure` (its JOURNAL `C:/Users/kazda/kiro/gtai-wt/n23-moves/JOURNAL.md` line 23, read it whole):
from n24-ghost on `ghost_forms.json` `transform_unlocked` is false, so the bot's `power_hauler` presses
(`project/features/gauntlet/bot/bot_forms.gd`) do nothing. Teach the bot the first-level power: `ghost_deploy` (row bit
19, wire bit 32) HOLD >= 2 ticks aimed at the spot, RELEASE to deploy the loaded ghost (cycled with `power_gearbox`),
per form `range_m` / `cooldown_ticks` from `ghost_attacks.json` `deploy.<form>`, with ghost's suggested target rule
(in that journal line). Keep the transform path for `transform_unlocked: true`. Result `deploys{<form>: count}` is
ghost's field: write it only if ghost's code does not already. Unit test with a fake view.

## Task 3 - a smoke batch (no commit needed beyond evidence)

`node tools/gauntlet/batch.mjs --profile=all --pick=greedy --controls=wheel --seed0=1 --seeds=2 --waves=40 --jobs=1
--out=<abs>/evidence/n24-pressure/smoke-04` and report: every run ends (death, wave 40 alive, or `stalled`), wall time,
death waves, dashes per wave median.

## After each code commit

`node tools/mutate/mutate.mjs --file=<main changed .gd> --max=20 --lines=<changed lines>`; quote the score.

## Report

Per task: done / not done, commit sha, files, checks with result lines, the stall cause in two sentences (and whether a
human could finish), smoke results, every NEED.
