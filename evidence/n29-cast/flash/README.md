# n29 cast: hit flash on the door carrier and robot gunner

Code: `CastFarCard.sync_tint(on)` (commit 7ca036a93); `FoeShieldCardView` and `FoeGunnerCardView` call it with
`rig.is_tinted()` in `show_rig`. Measured by `project/dev/cast/cast_impact_edge.gd` + `tools/art/cast_impact_edge.py`
(`rim()`: dark px outside the silhouette), 64 px/m, one pistol hit, flash forced on a frozen tick. BEFORE = worktree at
base `c649a15d6` (same harness, same scene file); AFTER = this branch. Pitch via `GTAI_CAST_PITCH`.

| id | pitch | calm rim | flashed rim before | flashed rim after | lancer (same run) | red/teal px | verdict |
|---|---|---:|---:|---:|---:|---|---|
| door carrier | p70 | 0 | 0 (no flash at all) | 0 | 0 | none seen: print is black and cream | flash now shows |
| door carrier | p55 | 0 | 0 | 0 | 1 | none seen | flash now shows |
| robot gunner | p70 | 0 | 0 (no flash at all) | 0 | 0 | none seen | flash now shows |
| robot gunner | p55 | 0 | 0 | 1 | 1 | none seen | flash now shows |

Notes: the brief's lancer numbers (482 / 596) are not what this harness reports; its rim() gives lancer 0 (p70) and 1 (p55),
the same as the n28 table in docs/art/cast-audit.md. Rim is therefore at or under the lancer's. "Red/teal px": judged by eye
on the stills (the flash material prints black and cream); no hue count script was run. A rim of 0 before is "by
construction" (no flash), the real comparison is the picture. In play the card syncs in `show_rig`, which runs before the
rig's own tint step in `ArenaRobotRigs._process`, so the card flash lags the rig's by one frame at both edges.
Stills: `gtai-masters/n29/cast/flash_door_gunner_before_after_64ppm_tilt{70,55}.png` (columns: lancer, door before, door
after, gunner before, gunner after; top row flash on, bottom calm). No 32 px/m street still or clip was made.
