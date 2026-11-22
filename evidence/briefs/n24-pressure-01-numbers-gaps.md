# Brief n24-pressure-01: the owner's direct numbers, then the gaps between enemy shots

You build for lane `pressure` of RTAI (Godot 4, internal id `gtai`) in this worktree, branch `n24-pressure`.
Read `AGENTS.md` (commands, top rules) before you start. STANDARDS.md binds.

**Wall clock: hard stop 18:55. Last commit by 18:50.** Commit each task as it lands; an unfinished task at 18:50 is left
uncommitted and described in your final report (what is done, what is not).

## Machine rules (every command)

- `export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/pressure` and
  `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'` before any Godot,
  test, gate or tool run. Anything that renders: `--rendering-driver d3d12`, windowed runs `--position 0,1440`.
- **One Godot process at a time for this lane, and the director's baseline batch holds that slot now.** Do NOT start
  any Godot process (tests, scenarios, check.mjs, dev runs) until the file
  `evidence/n24-pressure/base-main/batch.json` exists (poll it with `ls`, e.g. every 2 minutes, while you read and edit).
  Until then: read code, make the table and code edits, run Node-only checks (`node tools/lint/lint.mjs` may call
  gdformat/gdlint only: fine; it does not start Godot).
- Free your own processes by PID; never kill by name. Never touch `main`, other worktrees, or push.
- Fix lint and format findings in your own edit and go on.

## Git law

Stage per path (`git add <path>`), one commit per task, message `pressure: <what>`, ending with the line
`Co-Authored-By: GPT-6.2 Astra <noreply@openai.com>`. Banned: `git stash`, `git add -A/./-u`, `git commit -a`,
`reset --hard`, `--amend`, rebase. Run `node tools/gate/quick.mjs` before each commit. Commit `.uid` files with any new `.gd`.
Do not touch `JOURNAL.md`, `REPORT.md` or `evidence/briefs/` (the director's).

## Files you may edit (allowlist; any other path: stop that task and report a `NEED <lane>: <file> <why>`)

- the numbers in `project/data/tables/enemies.json` (`weapons` block, and archetype numeric fire/damage fields such as
  `telegraph_s`, `aim_lock_s`, `aim_lead`; NOT art/view keys), `project/data/tables/weapons.json` `enemy_fire` block only
- `project/data/tables/gauntlet.json`, its schema `project/data/schemas/gauntlet.schema.json`
- `project/features/gauntlet/**`, `project/dev/gauntlet/**`, `project/features/combat/ai/**` (fire timing only),
  `project/features/combat/enemy_gunner.gd`, `enemy_rounds.gd`
- tests you create or that are named for those files (`project/tests/unit/test_gauntlet*.gd`, `test_enemy_*`...),
  and test fixtures/expected digests that must move because of these number changes (list every one in your report)
- `tools/gauntlet/**`, `docs/gauntlet-loop.md`
- `project/boot/launch_args.gd` `KNOWN_FLAGS`: append-only, one line per flag
- `docs/decisions.md`: append-only, one line per decision, format in AGENTS.md
- `project/features/combat/combat_arena.gd`: one-line call sites ONLY (it is at its size cap); say which line in your report

Forbidden (other lanes own them tonight): `project/features/player/**` except nothing (deflect/guard is the next brief),
`project/data/tables/input_actions.json`, `rivet_motion.json`, `melee_weapons.json`, `signature_kills.json`,
`ghost_*.json`, `powers.json`, `combat.json` (the `moves` block is ghost's; leave the whole file for now),
`project/features/souls/**`, `project/features/characters/**`, `project/features/combat/squad/**`, any art.

## Task 1 - double every enemy attack's damage (one commit)

Owner: "Enemies are too weak, I would double their damage". Double `damage` and `splash_damage` of every row in
`enemies.json` `weapons` (ranged and melee: baton, cannon, claw, pistol, rifle, rocket, shove, stomp, turret_gun,
war_cannon, and any other). Double `weapons.json` `enemy_fire.damage_scale` (0.25 -> 0.5): it scales a player gun row
held by a hostile. Read the code for any other place enemy damage to Rivet is set separately (archetype fields,
boss-specific damage in `features/combat/ai/**`, `production_damage` - find out what it is and say whether it is an
attack on Rivet) and double those attacks too if they are enemy attacks on Rivet and in your allowlist; otherwise
list them in the report. Keep `gauntlet.json` `enemy_damage_k` at 1. Update docs strings that quote the old numbers.
Then run the unit tests (`node tools/tests/run_unit.mjs --changed`, then the full `node tools/tests/run_unit.mjs`) and the
scenarios (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`). Expected digests, tapes or golden
results that move because enemies hit harder: list each with a one-line reason; update a test's expected number only
when the test is about these numbers; a quest/prologue/boss scenario that now FAILS its pass condition (e.g. Rivet dies):
do not weaken it, report it with the scenario name and the failing line.

## Task 2 - no repair inside a gauntlet wave (one commit)

n23 owner verdict: no repair inside a gauntlet wave, only between waves. Today `gauntlet.json` `rivet.repair_per_s` 10
after `repair_delay_s` 3 applies all the time (`combat_arena.gd:254`, `features/gauntlet/gauntlet_bonus_apply.gd:19,74`
scales it with the regen bonus). Add `rivet.repair_in_wave` (bool, default false in the table; true = the old
behaviour) and make the gauntlet repair Rivet only while no wave is live (between a clear and the next wave's spawn), at
the same rate scaled by the regen bonus. Quest 1 and every non-gauntlet mode keep `combat.json` repair untouched.
Schema updated. A unit test that proves: no hp gained during a live wave after 5 s without damage; hp gained between
waves; `repair_in_wave: true` restores the old behaviour. Check the test player (`GauntletBot`, rest/retreat logic in
`features/gauntlet/` or `dev/gauntlet/`): its "rest until X% hp" after a clear must still work between waves; its
"retreat to repair" inside a wave can no longer heal, so make sure it does not stall waiting for hp that never comes
(say what you changed).

## Task 3 - the wave timer is 45 s from wave 6 (one commit)

n23 owner verdict. Today `gauntlet.json` `wave_timeout_s` 90 for every wave (`features/gauntlet/gauntlet_street.gd:43`).
Add `wave_timeout_late_s` (45) and `wave_timeout_late_from` (6): waves 1-5 keep 90 s, wave 6 and later 45 s. The
`--wave-timeout` dev flag (`dev/gauntlet/gauntlet.gd:63`) still overrides all waves. Schema, unit test (wave 5 -> 90 s,
wave 6 -> 45 s, a late value of 0 = off). Check the stacked-wave rule (a timed-out wave calls the next roster into the
same fight) still reads the per-wave value.

## Task 4 - measure where the time between enemy shots goes (one commit: the tool + its first result)

Owner: "Enemies do have too much delay between shootings, making too easy just running around without skill and kill
everyone." Build a headless dev measurement `project/dev/gauntlet/fire_gaps.gd` (a `-s` script or scene runnable with
`node tools/dev/run.mjs fire_gaps -- ...`; declare `const KNOWN_FLAGS`), on the real combat code at the fixed 60 Hz tick:
for each ranged enemy archetype in `enemies.json` that the gauntlet spawns, one enemy at 10 m from Rivet for 30 sim
seconds, Rivet (no player input other than movement, invulnerable or with hp so high he does not die) in three motions:
standing still, circling the enemy at run speed at 10 m, and strafing back and forth. Per archetype and motion write:
rounds that left the muzzle, rounds per second, mean and max gap between rounds (s), the gap split into its parts as the
code really spends them (telegraph/tell, aim lock, burst gap, cooldown, `enemy_fire` rest after `volley_shots`, waits
for line of sight or squad `max_shooters`, reposition), hits on Rivet, hit share, and the share of ticks with at least
one enemy round in flight that will reach Rivet's position ("under fire"). Output JSON to `--out=<abs path>` plus a
markdown table beside it. Run it on the committed tables after task 1 and commit the result under
`evidence/n24-pressure/fire-gaps/before.{json,md}` together with the tool. Say in the report which code paths spend the gap.

## Task 5 - shorter gaps (one commit, only if task 4 is committed by 18:30)

Shorten the gaps so that circling at run speed without skill gets Rivet hit: keep every tell readable (do not take any
archetype's `telegraph_s` below 0.30 s, and never below its current value minus half; name your number and why: a
human's simple visual reaction is about 0.2-0.25 s plus the move), shrink `enemy_fire.rest_s` and the `cooldown_s` of
the gun rows, and make the lead on a moving target a tunable share (`aim_lead` exists per archetype: read how it works;
if the circle is not led because the lead only uses straight-line velocity, say so and propose the code change, do not
build a new predictor in this session). Target: rounds per second per ranged type up by 1.5x to 2x versus `before`, and
the circling hit share clearly above the standing-still hit share of `before` is NOT required, but circling must be hit
at least 1 round per 3 s by a single pistol cop at 10 m. Re-run the tool, commit `evidence/n24-pressure/fire-gaps/after.{json,md}`
with the table change, and put rounds per second before -> after per type in your report.

## After each code commit

`node tools/mutate/mutate.mjs --file=<the main .gd you changed> --max=20 --lines=<the changed lines>`; quote
killed/(killed+survived) in your report. Skip mutate for pure JSON commits.

## Report (your final message)

Per task: done / not done, commit sha, files, the checks you ran with their result lines, the numbers (task 4/5 table),
moved digests with reasons, and every NEED.
