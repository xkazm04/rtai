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

## 64 px/m cops (HEAD rendered `--ppm=64` ticks 0-420; main reuses `build/n31/n31-02/s7_64`)
`cops_pair_64_t320.png` (x2 nearest, tick 320): main shows the discs low and to the right of the boots on every cop; HEAD brings cops 1 and 2 closer under the
boots but cop 3 still has its disc a boot-width to the right and below. So at 64 px/m the disc is better on most cops, not all. No numbers: one frame, eye only.

## Card foes
Seed 7 only reaches wave 6 with `--wave-timeout=5` (each wave 300 ticks; the take `--from=1500 --ticks=3000` = waves 5-9, 25 s). That changes the pace of waves,
not how a foe is placed or drawn. In the take the crowd is dense (Rivet shoots into a pile of corpses) and the one card foe in view for a stretch is a robot thug
standing against the wall from tick 2250 to 2292: it barely walks, so there is no stride in it.
`thug_stride_32_main_head.png` (ticks 2250-2292 every 6, x4 nearest, main rows above HEAD rows) and `thug_pair_32_t2250.png`:
by eye (not the tracker, the crowd breaks it; read +/- 3 px): disc centre vs boot midpoint x about 0 to +1 px both arms, y about +8 to +9 px below the boot line both arms; head
top travel: not measured (the head is above the crop and the foe is pinned). Seen: the two arms look the same for this foe: the soft contact shadow sits under the boots in both
The lab numbers for the foe shadow are in `foe_lift_after.md`. Gunners and turrets were not in a
readable position; not claimed.

## Table (32 px/m, delivered frames; each cell main | HEAD)
| foe (window) | disc minus boot midpoint, x (median) | disc minus lowest boot row, y (median) | head-top travel |
|---|---|---|---|
| patrol cop, wave 1, ticks 300-345 (tracker, 45 frames) | +6.9 \| +2.4 px | +4.5 \| +3.9 px | 14.3 \| 14.0 px |
| robot thug, ticks 2250-2292 (by eye, +/- 3 px) | about 0 to +1 \| about 0 to +1 px | about +8 to +9 \| about +8 to +9 px | not measured |

## Films and files (masters `C:\Users\kazda\kiro\gtai-masters\n31\ground\item2\`, listed in its `frames.json`)
`gauntlet_cops_side_32.mp4` (25.0 s, 1920x1080 60 fps, ticks 0-1500, main left | HEAD right), `gauntlet_cards_side_32.mp4` (25.0 s, ticks 1500-3000, `--wave-timeout=5`),
`cops_stride_32_main_head.png`, `thug_stride_32_main_head.png`, `thug_pair_32_t2250.png`, `cops_pair_64_t320.png`, `cops_measure_32.json`.
Reproduce: `node tools/ground/play_take.mjs --rev=<ba8e470b0|HEAD> --seed=7 --ticks=<n> [--from=1500 --wave-timeout=5] --out=<dir>`, then `--side=<a>,<b>`.

## One sentence for the REPORT
At 32 px/m a player sees the cops' ground disc land under or between the boots on about half of the stride frames instead of trailing a boot-width behind them (median offset 6.9 -> 2.4 px), but the cap still pumps on diagonal walks and the one card foe we could film (a thug at a wall) looks the same, so the change is small and real only on the cops.
