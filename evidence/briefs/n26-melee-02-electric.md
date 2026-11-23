# Brief n26-melee-02-electric: the electro gun's direct hit and the claw's full discharge finish robots

Lane `melee`, branch `n26-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`.
**Hard stop 13:42 wall clock. Last commit by 13:36.** Commit what is green; revert your own unfinished edits
with `git checkout -- <path>`; list the rest in your report.

## The owner's pick
"Electric: add the electro gun's direct hit and the claw's full discharge as robot finishers." They shut a robot
down the way the electro baton does, **each with its own finish** (a look of its own, not the baton's). Robots
stay immune to the plain one-swing claw kill (brief 01 made the claw rake one-shot humans; that stays).

## What exists (read first)
- The baton's robot finisher: `project/features/player/melee_shutdown.gd` (`MeleeShutdown.effect/land`, tiers:
  light robots `robot_thug`, `robot_gunner` shut down in one contact; `arch.machine` (shield_robot,
  sentry_turret) is OVERLOADED for `machine_stun_ticks` 150 and a second contact while primed executes it;
  `never_finish` (war_machine) takes normal damage + `heavy_stun_ticks` 30; bosses and brain-owned bodies
  never), `KillEvent.SHUTDOWN` meta, the look in `project/features/combat/kills/robot_shutdown_fx.gd` and the
  `electric_shutdown` row of `signature_kills.json` (about line 1852). Last run: `docs/day/2026-11-23/n24-melee/`
  REPORT/JOURNAL, commits `e04b93990`, `f6978fc2f`.
- The claw's charged discharge: `project/features/player/player_shock.gd` (`_discharge`, `_stun`: the first body
  in the cone takes `full_damage` when `stun >= shock.stun_full`; weapon id `claw_shock`; the human kill is
  `claw_throw`).
- The electro gun: `weapons.json` row `electro_gun` (bolt, chains between metal targets, stuns, charged bolt kills
  a human). Its hit resolves in `project/features/combat/weapons/fight_areas.gd` `land()` -> `_strike` (the
  direct victim) then `_chain` (hops). Only the DIRECT victim finishes; chain hops keep today's stun/damage.

## Build
0. (10 min, from brief 01) `rivet_melee.json` `claw.never_finish` lists `appliance_warden`. The warden is a wave
   grunt type (hp 1, three of them in the prologue), not a named character: the owner's "bare hands one-shot
   humans" covers him, and he should play the claw rake kill. Remove him from the list (keep Mulroney), give the
   rake row's default (or a `appliance_warden` variant if his drawn cells exist) for his death, re-run the
   prologue pilot seeds 1..5 (`evidence/n26/hands/prologue-after.*`) and confirm the numbers; update the
   decision line by appending a new one (never edit old lines). If removing him changes the prologue pilot's
   ticks, keep him exempt and say why.
1. Generalise the tiering so a non-melee source can call it: e.g. `MeleeShutdown.land_source(arena, target,
   source_id, tier_table)` or a small new class `RobotFinish` (yours, under `project/features/player/` or
   `project/features/combat/kills/`), keeping the baton's path byte-identical. The tier numbers for the two new
   sources (overload ticks, heavy stun ticks, never_finish list) come from data: a block per source in a table
   you own (`melee_weapons.json`/`rivet_melee.json` for the claw; for the electro gun use a NEW small table
   `project/data/tables/robot_finishers.json` + schema rather than editing the pressure lane's `weapons.json`
   row). Start every source with the baton's numbers.
   - Electro gun: any bolt that strikes a robot directly (`_strike` victim, not a chain hop) applies the tier.
     Decide charged vs uncharged: the owner said "direct hit"; ship "any direct hit" and keep "charged only" one
     data value away (`charged_only: false`). Decision line.
   - Claw: only the full discharge (`stun >= stun_full`, first body) applies the tier; a partial charge keeps
     today's stun.
   - The call site in `fight_areas.gd` (a shared weapon file) is at most 3 lines; logic lives in your file.
2. Two finish looks of their own (view only, no hashed state, no combat RNG), as new `signature_kills.json`
   rows (e.g. `electro_bolt_shutdown`, `claw_discharge_shutdown`) drawn by FX in `project/features/combat/kills/`:
   - bolt: the bolt punches in and the current runs out through the joints, plates blown off from inside, it
     locks and topples (say what you made);
   - claw: Rivet's clamp grips and dumps the charge, the robot is lifted on the arc and its head/core bursts,
     it drops at his feet smoking.
   They must read different from the baton's at 32 px/m. Colours: white-core arcs with cream/amber are the
   electric language; teal is souls only (never); red only for blood (robots do not bleed); vermilion only for
   danger. Keep the wreck's gunmetal plates.
3. Tests: each source shuts down a light robot in one direct contact; primes then executes a shield robot / turret;
   war machine only stunned; boss untouched; a chain hop does not finish; partial claw charge does not finish;
   the baton path unchanged; a human is unaffected by the robot tiering (the electro gun's human rules and the
   claw throw on humans stay as they are).
4. Tape identity: main `0779185ac` is gate-green, so do NOT run a BEFORE suite; run the scenario suite (and `--only=<names>` for the touched ones first) and shipped tape checks AFTER; the 60 s replay
   (`cbeb734ff9b97c41`) and native parity must stay identical. Every scenario/tape that moves: old -> new + reason;
   re-pin only when the cause is this pick, one `docs/decisions.md` line each
   (`- [2026-11-23] DECISION n26 melee: ...`). Quest 1 checkpoints must still be reached.
5. Review stills (not owner films): each source on robot_thug, robot_gunner, shield_robot (prime + execute),
   war_machine, at 32 px/m tilt 70 (contact, +10, +30, +60) and 64 px/m, to `evidence/n26/electric/frames/`.
   Kit: `tools/film/kill_reel.mjs`, `project/features/combat/kills/kill_lab.gd` (`--sig-gun=`), last run's
   `tools/film/owner_take.gd`. Look at them yourself before committing a look.
6. `node tools/mutate/mutate.mjs --file=<your main logic file> --max=20 --lines=<changed lines>`; quote the score.

## Files you may edit (allowlist). Any other path: stop that part and report a NEED.
- `project/features/combat/kills/**`, `project/features/player/melee_*.gd`, `project/features/player/player_shock.gd`,
  a new file of yours under `project/features/player/`, `project/features/combat/weapons/fight_areas.gd` (call site,
  3 lines max), `project/data/tables/rivet_melee.json`, `melee_weapons.json`, `signature_kills.json`, new
  `robot_finishers.json` and their schemas, new tests under `project/tests/unit/` and `project/tests/integration/`,
  scenario expectation files only for a justified re-pin, `docs/decisions.md` (append one line at a time),
  `evidence/n26/**`, `project/dev/melee/**`, `tools/film/**` only for a new still entry, `tools/debt/baseline.json`
  through `node tools/debt/debt.mjs --update` (`--accept-regression="<reason> for n26 melee"` if it rises),
  `project/boot/launch_args.gd` `KNOWN_FLAGS` append only.
- Forbidden (other lanes): `input_actions.json`, `rivet_motion.json`, player movement/input files, `combat.json`,
  existing rows of `enemies.json` / `weapons.json`, `enemy_round_look.gd`, `project/features/gauntlet/**`,
  `project/boot/prologue/**`, `prologue_stage.json`, `prologue_yard_dressings.json`, `cast_cards.json`, enemy cast
  art, the deploy input / deploy HUD chip files in `project/features/souls/**`. Root `JOURNAL.md`/`REPORT.md`.

## Repo law (binding)
- AGENTS.md and STANDARDS.md. Typed GDScript, files about 200 lines (hard 300), functions 40 lines or fewer,
  5 params max, `Log` not print, no global RNG (view-only FX never touch combat RNG or hashed state), data in JSON
  with a schema. Commit `.uid` with every new `.gd`; Godot `--import` after new scripts/art, before commit.
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/melee` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`;
  `--rendering-driver d3d12` for anything that renders; windowed runs `--position 0,1440`. One Godot process at a
  time. Kill your own processes by PID only.
- Before each commit `node tools/gate/quick.mjs`; fix lint and format findings in your own edit and go on. Stage
  per path; `git commit -- <paths>` is fine. No amend, no rebase, no stash, no `add -A/./-u`, no `reset --hard`,
  never push. `node tools/tests/run_unit.mjs --changed` in the loop; the full run once before your last commit.

## Report at the end
Commits (sha + subject), the tier table per source, the tape/scenario list (moved / re-pinned / identical),
mutate score, still paths, anything not done and why.

## Also owed from brief 01 (do last, only if time remains before the commit deadline)
`node tools/mutate/mutate.mjs --file=project/features/player/melee_lethal.gd --max=20 --lines=<lines changed by 21f4fd10c>`
and the same for `project/features/combat/kills/kill_rake_art.gd` (if that is brief 01's main art file); write the
scores to `evidence/n26/hands/mutate.md` and commit it.
