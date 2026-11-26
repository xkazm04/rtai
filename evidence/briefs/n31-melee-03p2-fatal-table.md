# Builder n31-melee-03p2 (opus): the fatality proof table, the owner's chainsaw rule, quest 1 install

Read `evidence/briefs/n31-common.md` (binding) and `evidence/briefs/n31-melee-03-fatalities.md` (scout findings).
Tag `03p2`. Launched 23:35. HARD STOP: commit part 1 by 00:00, part 2 by 00:20; report and END by 00:30.
Commit with `git commit -- <paths>`. Another builder (`01e`, files `project/dev/melee_n31/blade_*`,
`tools/melee/blade_volume*`) shares the lane's Godot lock; do not touch its files.

## State
Commit da9abe4fc: `--kill-feed` (off) installs `BrutalityHook` after `street.setup` in `GauntletSession`, attached
from `GauntletView._attach_kills`, `--gore=reduced` via LaunchArgs; integration test green. Flag off = byte-identical.

## Part 1: the proof table (commit by 00:00)
Do NOT edit `project/dev/melee_n31/play_baseline*` or `tools/melee/play_baseline.mjs` (another call runs them for
item 2's guard rail). Make NEW files: `project/dev/melee_n31/fatality_probe.gd` (+ `.uid`) that reuses the
baseline probe's bot/session setup (call into it or copy the minimal part; keep <= 200 lines) with `--kill-feed` on,
and `tools/melee/fatality_table.mjs` (+ a node test for its table/parse logic). Per kill record: weapon, victim
archetype, shielded at death (yes/no/broken), what plays: the signature row id (from the hook's consumed record /
`telemetry()`) or `generic` or `card_fall`. Run waves 1-4, each of chainsaw, katana, plasma_sword, electro_baton,
claw (`hands`?), seeds 1..5 (fewer seeds if time, but the chainsaw needs >= 40 kills on shieldless humans) ->
`evidence/n31-melee/03-fatal/table.md` + `table.json`: weapon x victim kind -> counts per what plays; the line
"chainsaw kill on a shieldless human = chainsaw_grind: N/M (bar 100 %)". Also list the card foes (Mulroney,
warden, contractor, trooper, robots) and what each gets (row with cells/variant, or own `KillCardFall`, or none).

## Part 2: make the owner's rule hold (commit by 00:20)
If part 1 shows any chainsaw kill on a shieldless human that is not `chainsaw_grind` (e.g. a kill outside the
grind finish, a cap, a lethal-gate exclusion, a kill kind the hook ignores), find the cause first (write it in the
report), then fix it in `project/features/combat/kills/**` (selection) so the share is 100 %; riot cop: only once
his shield is down or the saw went through it - say what plays for him. Re-run the chainsaw row of the table.
If it is already 100 %: spend part 2 on the quest 1 install per the scout findings (behind the same `--kill-feed`;
quest 1's script and lines must not change; if it needs files outside `boot/collect_call/quest1_session.gd`,
`boot/quest1_game.gd`, `collect_call_stage.gd` and our kills dir, stop and write a NEED).
No digest re-pin in this call (flag stays off). Final report: commits, the table, the share, cause found, NEEDs.
Before killing any PID print its CommandLine; kill only `n23-street` or your own tool.
