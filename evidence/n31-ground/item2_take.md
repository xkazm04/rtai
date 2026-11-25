# n31 item 2: the play take of the foes (cops and card foes on the floor, main | HEAD)

Builder n31-11. Mode as item 1 (`tools/ground/play_take.mjs`: gauntlet `--pick-view --bot=average --controls=wheel`, seed 7, 1920x1080 60 fps, d3d12).
Arms: main `ba8e470b0` (before) | HEAD `661f95fb6` (docs-only above `154a051e0`; game code of `33192b087`, `fe5712271`, `e3393e180`, `258f6f6ef`).
Same seed, same ticks: the sim is deterministic, so tick N is the same moment in both arms.

## Windows (written before rendering)
- (a) Street cops: seed 7 wave 1 is patrol cops only. They walk in from the right from about tick 280; crops cut at **ticks 300-345** (one cop tracked, lowest of the group at tick 320).
- (b) Card foes (robot_thug, robot_gunner, sentry_turret are tier 3; `gauntlet.json` `tier_unlock_wave` = [1,3,6,9,5]): they first appear in **wave 6**. Seed 7 with the shipped 90 s wave timeout is in wave 2 at tick 1800 (item 1 still: "Wave 2 8.0 s"), so it never reaches wave 6 within 4800 ticks.
  Window found with `--wave-timeout=<s>` (a gauntlet flag; `play_take.mjs` now passes it, commit `n31-11 ground: play_take --wave-timeout`): see the card section.

## Cops, 32 px/m, ticks 300-345 (measured in the delivered 1080p frames, one cop followed by a blue-cap tracker, `build/n31/n31-11/cop.py`)
Disc = the dark-grey blob under the cop; boot midpoint = middle of the lowest 12 rows of the cop's dark pixels. Positive dx = disc right of the boots.

| measure (45 frames) | main | HEAD |
|---|---|---|
| disc centre minus boot midpoint, x: median / mean / mean abs / worst | +6.9 / +5.4 / 8.2 / 20 px | +2.4 / +1.4 / 6.9 / 18 px |
| disc centre minus lowest boot row, y: median | +4.5 px | +3.9 px |
| head (cap) top travel over the stride, detrended | 14.3 px | 14.0 px |
| cop height (cap top to boot) range | 20 px | 23 px |

Read: the disc sits about 5 px less to the right of the boots (median 6.9 -> 2.4), y is unchanged (the disc is a few px below the boots in both), and the
head travel is NOT measurably lower in this window (14.3 vs 14.0): this cop walks diagonally toward the camera, the columns where `n31-10` found the head
travel is in the drawing (9-28 px, see the decisions line) and only side-on walks fell 8 -> 1 px. The tracker is coarse (the disc mask picks up
neighbours; x scatter is large): read the table as "disc closer under the boots by a few px", not as a precise figure.
Crops: `gtai-masters/n31/ground/item2/cops_stride_32_main_head.png` (8 ticks 300-342 every 6, x4 nearest, main row above HEAD row), per-tick numbers `cops_measure_32.json`.

Seen: main: the disc trails to the right of the boots by 15-25 px in most frames (t300, t312, t318, t324, t330, t342 on the sheet: a separate smudge beside the cop). HEAD: the disc sits
under or between the boots at t300, t324, t330, t342, still a few px off to the right at t318 and t336. The cap still pumps (a head bob of about 1-2 px per frame is visible between t324 and t336) on this diagonal walk: not fixed, by design (drawing).
