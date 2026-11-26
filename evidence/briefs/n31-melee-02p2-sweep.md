# Builder n31-melee-02p2 (opus): the sweep, part 2 - reach, lunge, digests, guard rail (all behind --melee-sweep)

Read `evidence/briefs/n31-common.md` first: it is binding. Then `evidence/briefs/n31-melee-02-sweep.md` (the rule
and the bars; part 1 landed as a607e0b77: `project/features/player/melee_sweep.gd`, `player_melee.gd`,
`tests/unit/test_melee_sweep.gd`). Tag: `02p2`.
HARD STOP: launched ~22:20. Commit each finished part by 22:50 at the latest; report and END by 23:15 sharp
(your process is killed at 23:40; uncommitted work is lost). Never leave a commit sitting in the pre-commit hook
past 23:15.

## Principle for this call
EVERYTHING item 2 changes stays behind `MeleeSweep.on` (`--melee-sweep`, off by default): with the flag off the
game is byte-identical to main (no digest moves). The flag flips on in a later call, after builder 01c's
pixel-measured drawn volume confirms the bars; that flip re-pins the digests once. So: no `reach_m` /
`lunge_ticks` edit in the tables that the flag-off path reads. Put the swept geometry in new fields read only
by the sweep (e.g. per-hit `sweep_reach_m`, `sweep_lunge_ticks` in `melee_weapons.json`/`rivet_melee.json` with
their schemas, or a small `melee_sweep.json` table keyed by weapon + hit index - your call, one DECISION line).

## Parts (commit each)
1. **Prove flag off is byte-identical** (part 1 did not): `node tools/tests/run_scenarios.mjs` (allow 20 min; it
   holds the lane lock the whole time - take it, builder 01c waits) or the narrowest replay/scenario subset that
   covers melee if you can name it from `project/tests/scenarios/`; quote the result line. If something moved
   with the flag off, fix it first.
2. **Drawn reach and lunge (flag on only).** First estimate of the drawn reach per weapon hit = grip offset +
   drawn blade length (`length_m`, read the held view / strip code for the grip) at the body's edge; the claw =
   the swipe crescent's real radius. Compare with `reach_m` (claw 1.85, chainsaw 2.10, baton 2.0, katana 2.55,
   plasma 2.65 - to the victim's centre) and write a table (weapon, hit, table reach, drawn estimate, chosen sweep
   reach). Where the art can't show the table reach, the sweep uses the drawn one; where the drawing is shorter
   than a reach that is right, lift `rivet_swipe_view.gd` REACH_MAX_M (1.35 m clamp) to that reach FOR THE FLAG
   ON ONLY. Katana: give its lunging hits a sweep lunge so the 0.55 m lunge has arrived at contact (check how
   `lunge_m` is applied today: `melee_combo.gd` / player motion - read before editing). Unit tests for each.
   Builder 01c will deliver `evidence/n31-melee/01-volumes/before/drawn_ticks.json` (pixel-measured angle range
   and reach per tick); if it lands before you finish, use it instead of the estimate and say so.
3. **Guard rail with the flag on.** Make `project/dev/melee_n31/play_baseline*` / `tools/melee/play_baseline.mjs`
   pass `--melee-sweep` through (e.g. `--extra=--melee-sweep` or `--sweep`), run
   `node tools/melee/play_baseline.mjs --label=after-sweep --sweep` (waves 1-4, seeds 1-5, five weapons) and
   compare kills/swing with `evidence/n31-melee/01-baseline/before/baseline.json` (claw 0.795, chainsaw 0.787,
   baton 1.04, katana 0.994, plasma 1.238). Bar: each within +-15 %. Above +15 %: pay it back in that weapon's
   recovery ticks (one value per weapon, again only read with the flag on), re-run, DECISION before -> after.
   Write `evidence/n31-melee/02-sweep/guard.md`.
4. One `docs/decisions.md` line for parts 2-3 (`- [2026-11-25] DECISION melee n31 item 2 ...`). Mutate
   `node tools/mutate/mutate.mjs --file=project/features/player/melee_sweep.gd --max=20 --tests=test_melee_sweep`
   (under the lock) and quote killed/(killed+survived).

## Rules for this call
- Builder 01c runs at the same time (files `project/dev/melee_n31/blade_*`, `tools/melee/blade_volume*`,
  `evidence/n31-melee/01-volumes/**`): do not touch those. Share the Godot lock (`build/n31/godot.lock`).
- Before killing ANY PID: print its CommandLine (`Get-CimInstance Win32_Process -Filter "ProcessId=<pid>"`) and kill
  only if it names this worktree (`n23-street`) or your own tool. Never by name. A builder killed another lane's
  Godot in session 1.
- Forbidden: `features/combat/squad/**` (foe_attacks.gd is foes'), `features/combat/ai/**`, `dev/gauntlet/**`,
  `features/gauntlet/bot/**`, enemies.json, cast_cards.json, Rivet motion/draw files.
- Report: files, commits (sha), commands with result lines, the reach table, the guard table, NEEDs.
