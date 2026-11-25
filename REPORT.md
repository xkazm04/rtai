# REPORT lane yard, run n30 (2026-11-25, day run), branch `n30-yard`, base `5114a4441`

DRAFT (session 4, 14:40): items 4 to 6, the gate line and the ledger are filled in sessions 4 and 5.

Owner's picks for this lane: `over_print_shade` 0.5; floor decals drawn over the i55 impression; a soft drop
shadow under Rivet when he stands on a span; per-bay roof art and per-bay plumes; one more span drawn into the
burst mouth. Then the whole prologue film and plate beside game from three cameras.

Masters: `C:\Users\kazda\kiro\gtai-masters\n30\yard\` (`frames.json`, best first).

## What works

| item | evidence | number |
|---|---|---|
| 1. `over_print_shade` 0.5 (`31838bbae`) | `evidence/yard30/shade05.md`, masters `shade05_before_after_mid_32ppm.mp4` (23.0 s), `shade05_before_after_64ppm.png` | contrast against i20 forklift / skip / fridges 110 / 94 / 100 % (at 1.0: 55 / 47 / 29 %); forklift hue 69.6 -> 70.1 deg (L* 40.3 -> 26.1); pilots identical on 5 seeds |
| 2. Decals over the impression (`5950ceb34`, `ed6b97278`, `7236d6218`) | `evidence/yard30/decals_over.md`, masters `decals_over_before_after_mid_32ppm.mp4` (23 s), `decals_over_64ppm.png` | tyre sweep A 112 %, bay lines 100-103 %, stains 119-125 % of before; floor L* 51.6 -> 50.8 (bar +-2); patrol 80.3 / 87.7 % (bar 65), rifle 104.5 % (95), pellet 99 % (90); pilots identical; mutate overprint 8 / 12 killed (first 12 of 40) |
| 3. Rivet's drop shadow on a span (`726550b45`, `ceb17574f`) | `evidence/yard30/span_shadow.md`, masters `span_shadow_before_after_64ppm.png` | body-box trigger on at 26 of 28 stand points (was 9); blot 1.9 x 2.3 m alpha 0.75 at (0.55, -0.6) m clipped to the span art, fade 6 ticks; floor frames with the shadow off pixel-identical; pilots identical; mutate 5 / 10 (first 10) |
| 4. Per-bay roof slabs and plumes (`db7b5f36d` tool, `98cd845b2` cuts, `507f75178` placed, `7fd323782` tint a0a0acff) | `evidence/yard30/roof_before_after_front_32ppm.png`, `evidence/yard30/plate_vs_game_front_{32,64}ppm.png`, `evidence/yard30/roof_frame_cost.md`, masters `roof_before_after_front_32ppm.mp4` (20.0 s), `roof_plate_vs_game_64ppm.png` | 5 slabs at one depth 5.5 m (straight north edge y -12.70), 7 plumes, no two bays share a set; 8 images of 25 for roof + mouth; pilots identical; frame cost p50 +0.444 ms, CI95 [-0.402, +1.290] (bar upper < 0.5 NOT met, see below) |
| 5. Sixth span out of the burst mouth (`dd890c7cd` art, `65183a395` placed) | `evidence/yard30/mouth_span_before_after_front_32ppm.png`, `evidence/yard30/mouth_span_64ppm.png`, `evidence/yard30/mouth_span_lanes.txt`, masters `mouth_span_before_after_front_32ppm.mp4` (20.0 s) | path 9.1 m from (12.2, -1.26) to the door section; lanes 32 / 32 ok; no cover, no collision, no legs; pilots identical |
| 6. Whole prologue film + plate beside game (`7e301f5c9`, `843a98e0a`) | masters `prologue_menu_to_quest1.mp4` (h264 yuv420p 1920x1080 60 fps 189.32 s), `evidence/yard30/prologue_film.md`, `evidence/yard30/plate_vs_game_{gate,mid,front}_{32,64}ppm.png`, `evidence/yard30/n29_vs_n30_{mid,front}_32ppm.png`, `evidence/yard30/plate_judgement.md` | handover 10792 / first line 10793 (unchanged from n29), 0 script errors |

## What does not

- Item 2: the faint wide tyre arcs read 76 % of before: they are drawn in `raised_line/floor_stains.png` (the stain layer), not a stamp, so the stamp value cannot reach them; Rivet's luminance delta 0.1479 -> 0.1340 (bar -0.01 missed by 0.004; the two arms differ by the whole n30 floor work).
- Item 3: the luminance delta on a span stays 0.021 -> 0.020 (bar 0.06 not met): the metric takes a signed mean inside his box, where the dark blot and his lighter body cancel; it cannot see a shadow beside him. The 64 px/m still shows the beam darken beside him; at full frame the effect is subtle. 57 px faint trace on the span art's anti-aliased rim.

## What blocked or slowed you (minutes each)

- `git worktree add` / `git archive` for a "before" arm stalled over 20 min on the 23k-file repo (session 2): 20 min; overlay projects in `C:/Users/kazda/kiro/gtai-n30/dec-before|dec-after` used instead.
- One lane Godot slot shared by three builders (session 3): about 40 min of waiting; the span shadow film slipped.
- The front camera's centre is fixed at (26, 3), so the roof sat above the 64 px/m frame: one bounced 2 min call.

## Calls for the owner

1. Tyre arcs in the stain layer (item 2): leave them at 76 % or redraw `floor_stains.png`'s arcs darker (an art job, not a value). Still: `evidence/yard30/decals_over_before_after_mid_32ppm.png`.
2. Span shadow (item 3): soft blot beside him on the beam (shipped on) or a stronger alpha / a cast silhouette. Still: `evidence/yard30/span_shadow_before_after_64ppm.png`.

## Merge notes

- Every yard change is data plus prologue yard code (`project/boot/prologue/**`, `prologue_yard_dressings.json`, its schema); keys' Rivet files untouched.
- Root `JOURNAL.md` / `REPORT.md`: keep this lane's on an add/add conflict.

## Next steps

## Builder ledger

| call | model | minutes | verdict |
|---|---|---|---|
| shade05 | Sonnet | 15 | accepted |
| roof-art (04a) | Opus | 13 | accepted |
| decals-over (02a) | Sonnet | 22 | bounced (pale floor) |
| mouth-span-art (05a) | Opus | 26 | accepted |
| decals-fix (02b) | Sonnet | 23 | accepted |
| decals-evidence (02c) | Sonnet | 46 | bounced (partial) |
| span-shadow (03) | Opus | 56 | bounced (did not read) |
| decals-finish (02d) | Sonnet | 49 | accepted |
| span-shadow-read (03b) | Opus | 63 | accepted |
| roof-art-in (04b1) | Sonnet | 5 | accepted |
| roof-place-try1 | Opus | 11 | accepted |
| roof-pilots | Sonnet | 2 | accepted |
| roof-stills | Sonnet | 2 | bounced (camera) |
| roof-place (04b) | Opus | 53 | accepted (cost bar open) |
| mouth-span-place (05b) | Sonnet | 20 | accepted |
| prologue-film (06) | Sonnet | 40 | accepted (span shadow film a miss) |
| mouth-deeper (05c A) | Opus | 7 | accepted |
