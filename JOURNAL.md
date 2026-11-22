# JOURNAL - lane pressure (n24, 2026-11-22), branch `n24-pressure` in `C:\Users\kazda\kiro\gtai-wt\n23-loop`

## Session 1 (17:22 - 18:52)

- 17:23 read: no JOURNAL yet, no astra.lock, no astra-calls.jsonl for pressure. Other lanes: no `NEED pressure`.
  motion wrote `MILESTONE iface` (its 17:30 line): dash = row bit 18 / wire bit 31; ghost_deploy = bit 19 / wire bit 32 (mask widened to 48 bits).
- 17:24 Godot `--import` in the lane: exit 0, 14 s (`evidence/n24-pressure/import-s1.log`).
- 17:25 MILESTONE baseline started: `tools/gauntlet/ablate.mjs --name=base-main --rev=b3f4727c0` (no edits, temp worktree, so
  builder edits in the lane cannot leak into it), greedy wheel, seeds 1-5 x 3 profiles, 40 waves, jobs 1 ->
  `evidence/n24-pressure/base-main/`. This is the lane's one Godot until it finishes.
- 17:26 DECISION pressure: the owner's "double their damage" goes into `enemies.json` `weapons` (damage and splash) and
  `weapons.json` `enemy_fire.damage_scale` (0.25 -> 0.5), game-wide, not only through the gauntlet's `enemy_damage_k`
  (stays 1): the owner played the game, not only the gauntlet. Tapes that hold an enemy hit move: listed in REPORT.
- 17:26 DECISION pressure: the 45 s timer from wave 6 and "repair between waves only" are new `gauntlet.json` values
  (`wave_timeout_late_s`, `wave_timeout_late_from`, `rivet.repair_in_wave`), so the old behaviour is one value away.
- 17:26 ASTRA RUNNING numbers-gaps since 17:26 (brief `evidence/briefs/n24-pressure-01-numbers-gaps.md`, lock pid 29104, hard stop 18:55)
