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
