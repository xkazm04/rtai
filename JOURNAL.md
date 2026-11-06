# JOURNAL - n8 lane `view` (branch n8-view)

## Iteration 3 (20:25-21:25) - first real session (iterations 1-2 died at start on billing)

Registry rules applied (game-production): `depth-ordered-layered-art` (one sort key per card,
per-pitch strips side by side), `sprite-and-atlas-production` (equal-frame strips, keyed by art
key not by pitch), `concept-scene-parity` / `motion-quality-gating` (judge on the real scenes in
motion, same seed before/after), `generative-artifact-gating` (A first, B with its named fix,
never C), `combat-pacing-and-dramatic-arc` (a telegraph commits its target when the wind-up
starts), `perf-regression-gating` (frame cost under the bench lock, CONTENDED otherwise).

- MILESTONE 20:50 item 1: the card sets are open to the lanes. `RigCardSets.all()` merges every
  `project/data/tables/card_sets/<lane>.json` (schema `gtai.card-set/1`,
  `data/schemas/card_set.schema.json`) over the base `RigCardSets.SETS`, files in name order, a
  later row replacing an earlier one. Lint's data-tables check maps the dir to the schema
  (`LANE_TABLE_DIRS`, the `arena_stations` precedent). Test: `test_rig_card_sets.gd`. Commit 8b006bae.

### To the other lanes (street, city, vehicles, hud)
Register head/bust card rows WITHOUT editing view files: add
`project/data/tables/card_sets/<your-lane>.json`:
```json
{
  "doc": "...",
  "lane": "street",
  "schema": "gtai.card-set/1",
  "sets": {
    "p70": {
      "ped/head_hair": {"anchor_y": 0.74, "bust": false, "raw": true, "strip": "res://features/characters/art/view/p70/ped_hair_card.png", "width": 2.0}
    }
  }
}
```
Keys are RigHeadCard keys (`<art_dir>` or `<art_dir>/<head part>`); `strip` "" keeps the base
strip and changes the rest; strips must split into RigHeadCard.FRAMES equal frames. Canonical JSON
(sorted keys, 2 spaces) or lint fails. Cherry-pick 8b006bae or merge n8-view to get it.

### REQUESTs
- REQUEST to assets: dent, 70, the ghost Dent (tan, as the p55 bust) at 70 degrees: five facings
  + the signature actions, the same proportions as `angle-r1/out/dent_55.png`; the combo view
  plays 70 in the city where Dent is on screen most.
- REQUEST to assets: ohm, 70, the ghost Ohm at 70 degrees, as `angle-r1/out/ohm_55.png`.
- REQUEST to assets: kerf, 70, Kerf v2 (the thin leaning card, 12 degree lean) at 70 degrees, as
  `angle-r1/out/kerf_55.png`.
- REQUEST to assets: king_car, 70, the throne-car at 70 degrees (five rotations), as
  `angle-r1/out/king_car_55.png`; only a 55 exists.
Meanwhile the 70 sets for Dent/Ohm/Kerf are built from the 55 drawings (the d8 p70 street-row way).

- MILESTONE 20:45 item 2: the owner's d8 values (commit d08768ea). `KerfRig.CARD_M` 0.8 -> 0.96
  (+20 %, lean kept); `KingArt.STRIPS["king"][2]` 1.5 -> 2.0; `KingCape.TRAIN_K` 1.0 -> 0.0.
  DECISION bust 2.0 over 1.75: at 32 px/m 2.0 reads as the boss at a glance and the stubby legs
  read stubby at every size, so the bigger bust costs nothing extra (Call for the owner, 1.75 one
  value away). The p70 court strip was padded for 1.5, so the 70 King grows by the same 2.0/1.5;
  `test_view_pitch_court` now states that (PAD_K). Evidence: `gtai-masters/n8/view/king_bust_abc_{32,64}ppm.png`,
  `king_bust_cape_before_after_64ppm.png`. Kerf +20 % NOT filmed yet.
- MILESTONE 20:55 item 3: the attack target freezes as the windup begins (commit e513d663).
  `bosses.json` top-level `aim_lock_at_windup: true` sets every attack's `lock` to its windup
  (BossSpec.from_table); false = the d8 lock. Applies to the King and Servo alike (every shipped
  attack). Test `test_boss_lock_at_windup.gd`: a step out 10 ticks into the windup dodges with the
  flag and is hit without it; every shipped attack locks at its windup. No replay golden moved:
  there is no boss scenario/golden (scenarios 52 ran; the only fail was rig_stress p50 1.041 ms,
  CONTENDED by my filming in parallel). Evidence: `king_ring_lock_before_after_combo_32ppm.mp4`
  (phase 3: at 7.0-7.5 s Rivet walks out of the frozen ring, the King lands on it empty),
  `king_ring_after_sequence_combo_32ppm.png`, `king_car_aim_lock_before_after_combo_32ppm.mp4`.
- FRICTION: the scenario suite read bosses.json while I flipped the flag for the before clip; it
  has no boss scenario so nothing was contaminated, but next time film the before from a worktree
  or a launch flag, never by editing a table under a running suite.
- FRICTION: Python on Windows writes CRLF by default; open(..., newline='') for every edit.

### Answers to REQUESTs (21:00)
- ANSWER to street (registration hook for the card rows): landed as data, not a second GDScript
  const: put your rows in `project/data/tables/card_sets/street.json` (shape above; `strip`,
  `anchor_y`, `width`, `bust`, `raw` per key). `RigHeadCard.rows_of(art)` reads
  `RigCardSets.all()`, which merges every card_sets file over `RigCardSets.SETS`, so your rows
  win for the keys they name; no view file to edit, no uncommitted patch. Merge n8-view (or
  cherry-pick 8b006bae). I leave the p55/p70 street rows in SETS; yours override. Tell me in your
  JOURNAL when your file is in and I drop the duplicates from SETS.
- ANSWER to city (building occlusion): `PropOcclusion` is the arena's (it redraws ArenaFloorView's
  props); it does not take an outside provider tonight. DECISION: the city draws its own cue
  over its roofs, from your `ChunkLift.occluder_at()` query, using the SAME look: read
  `PropOcclusion.SILHOUETTE`, `PropOcclusion.RIM`, `PropOcclusion.SIL_W_M` and `PropOcclusion.FRONT_DZ`
  (public consts; do not copy the numbers), so a hidden body reads identically behind a wall and
  behind a tenement. If you need a shared helper (the silhouette polygon from a rig), REQUEST it
  and I will lift it out of PropOcclusion into a static func you can call.
- MILESTONE 21:03 Kerf +20 % evidenced: `gtai-masters/n8/view/kerf_card_before_after_tilt_48ppm.png`.
  Found: at `--view=tilt70` Kerf (and every ghost without a p70 strip) draws the TOP-DOWN rig
  (hull + cables), not a card: GhostCard has no `art/view/p70/kerf_card.png`. That is item 5's
  first job: build p70 ghost strips from the 55 drawings now (the d8 p70 street-row way).
- Gates at d08768ea+e513d663: lint 15/15; unit 1489 passed / 0 failed (full no-arg run);
  scenarios 52 ran, 1 failed = rig_stress p50 1.041 ms > 1 ms CONTENDED (my filming ran alongside;
  re-run alone owed).
