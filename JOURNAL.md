# JOURNAL - day lane combat-notes (d6-combat-notes)

## Iteration 1 (13:28-14:28)

- 13:28 read: brief, backlog `docs/backlog/combat-notes-2026-11-04.md`, gunplay/brutality code paths for the shard. No REQUESTs for this lane in d6-perf-city's JOURNAL (none there yet).
- Registry rules applied: game-feel "the reaction lands on the contact frame" (hit feedback must start on the impact frame; anything covering the body at impact reads as lag); readability over spectacle (an effect must not hide the subject it reports on).
- FINDING 13:33 (item 1, homing shard delay): kill lands on the landing tick (63 in the director chapter) through CombatArena -> FightAreas.land -> kill_landed -> SignatureKills.on_kill (same tick). The visible delay is the view: the 1.2 m splash drew as the rocket burst (starburst 10 frames + smoke ring 25 frames) over the victim, and the burst row holds the body frozen 39 ticks before the pop. Film: frames 64-100 of `homing_shard` chapter.
- FRICTION: first A/B came out byte-identical: `LaunchArgs.has` does not see arena args after `--`; switched to `ArenaArgs.parse().has`. Second: my flinch was moving the parts, but under the pop's smoke.
- DECISION 13:36: small own pop for the shard (`FightShardArt.pop`) + per-shard flinch of the held body (`KillShardJolt`), flag `--no-shard-flinch` = before. Logged in docs/decisions.md.
- MILESTONE 13:39: item 1 built. Unit `test_kill_shard_jolt.gd` 5/5 (each shard's flinch starts on its landing tick; a planted 2-tick lag fails the check; live KillBurstFx moves on the kill tick; other kills do not flinch). Lint 13/13. Clip `gtai-masters/d6/combat-notes/shard_flinch_ab_48ppm_64slow.mp4` (13.7 s: 48 px/m real-time A/B, 64 px/m 0.4x A/B, 48 again). Looked at the 0.4x sheet: before = body buried in starburst + smoke until the pop; after = body visible, snaps back and tilts as shards land, then bursts.
