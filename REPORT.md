# REPORT lane yard, run n30 (2026-11-25, day run), branch `n30-yard`, base `5114a4441`

DRAFT (session 5, 16:00): the gate line and session 5's films are filled in at the end.

Owner's picks for this lane: `over_print_shade` 0.5; floor decals drawn over the i55 impression; a soft drop
shadow under Rivet when he stands on a span; per-bay roof art and per-bay plumes; one more span drawn into the
burst mouth. Then the whole prologue film and plate beside game from three cameras.

Masters: `C:\Users\kazda\kiro\gtai-masters\n30\yard\` (`frames.json`, best first).

## What works

| item | evidence | number |
|---|---|---|
| 1. `over_print_shade` 0.5 (`31838bbae`) | `evidence/yard30/shade05.md`, masters `shade05_before_after_mid_32ppm.mp4` (23.0 s), `shade05_before_after_64ppm.png` | contrast against i20 forklift / skip / fridges 110 / 94 / 100 % (at 1.0: 55 / 47 / 29 %); forklift hue 69.6 -> 70.1 deg (L* 40.3 -> 26.1); pilots identical on 5 seeds |
| 2. Decals over the impression (`5950ceb34`, `ed6b97278`, `7236d6218`) | `evidence/yard30/decals_over.md`, masters `decals_over_before_after_mid_32ppm.mp4` (23 s), `decals_over_64ppm.png` | tyre sweep A 112 %, bay lines 100-103 %, stains 119-125 % of before; floor L* 51.6 -> 50.8 (bar +-2); patrol 80.3 / 87.7 % (bar 65), rifle 104.5 % (95), pellet 99 % (90); pilots identical; mutate overprint 8 / 12 killed (first 12 of 40) |
| 3. Rivet's drop shadow on a span (`726550b45`, `ceb17574f`; film window `7d87cf75a`) | `evidence/yard30/span_shadow.md`, `evidence/yard30/span_shadow_windows.txt`, `evidence/yard30/span_shadow_film_frame.png`, masters `span_shadow_before_after_64ppm.png`, `span_shadow_before_after_32ppm.mp4` (seed 42 ticks 6846..7745, 15.0 s, Rivet fighting on the bend span) | body-box trigger on at 26 of 28 stand points (was 9); blot 1.9 x 2.3 m alpha 0.75 at (0.55, -0.6) m clipped to the span art, fade 6 ticks; floor frames with the shadow off pixel-identical; pilots identical; mutate 5 / 10 (first 10); on-span runs over 5 seeds: longest fight run 9.0 s (seed 42), seed 7 none over 1.2 s |
| 4. Per-bay roof slabs and plumes (`db7b5f36d` tool, `98cd845b2` cuts, `507f75178` placed, `7fd323782` tint a0a0acff) | `evidence/yard30/roof_before_after_front_32ppm.png`, `evidence/yard30/plate_vs_game_front_{32,64}ppm.png`, `evidence/yard30/roof_frame_cost.md`, masters `roof_before_after_front_32ppm.mp4` (20.0 s), `roof_plate_vs_game_64ppm.png` | 5 slabs at one depth 5.5 m (straight north edge y -12.70), 7 plumes, no two bays share a set; 7 images; pilots identical; frame cost p50 +0.444 ms, CI95 [-0.402, +1.290] (bar upper < 0.5 NOT met, see below) |
| 5. Sixth span out of the burst mouth (`dd890c7cd` art, `65183a395` placed; `e4797b637` end moved inside the fire; `89c56895c` end fades over 0.5 m) | `evidence/yard30/mouth_deeper_before_after_front_64ppm.png`, `evidence/yard30/mouth_fade_64ppm.png`, `evidence/yard30/mouth_deeper_film_frame.png`, `evidence/yard30/mouth_span_lanes.txt`, masters `mouth_deeper_before_after_front_32ppm.mp4` (h264 1920x1080 60 fps 20.0 s, before = HEAD without the mouth span row) | start (12.2, -1.26) -> (12.2, -2.5): the beam climbs into the burning opening; 9 images of 25 in total; lanes 32 / 32 ok; no cover, no collision, no legs; pilots identical (also after the fade); five old spans byte-identical; cutter pytest 8 / 8 |
| 6. Whole prologue film + plate beside game (`7e301f5c9`, `843a98e0a`) | masters `prologue_menu_to_quest1.mp4` (h264 yuv420p 1920x1080 60 fps 189.32 s), `evidence/yard30/prologue_film.md`, `evidence/yard30/plate_vs_game_{gate,mid,front}_{32,64}ppm.png`, `evidence/yard30/n29_vs_n30_{mid,front}_32ppm.png`, `evidence/yard30/plate_judgement.md` | handover 10792 / first line 10793 (unchanged from n29), 0 script errors |

## What does not

- Item 2: the faint wide tyre arcs read 76 % of before: they are drawn in `raised_line/floor_stains.png` (the stain layer), not a stamp, so the stamp value cannot reach them; Rivet's luminance delta 0.1479 -> 0.1340 (bar -0.01 missed by 0.004; the two arms differ by the whole n30 floor work).
- Item 3: the luminance delta on a span stays 0.021 -> 0.020 (bar 0.06 not met): the metric takes a signed mean inside his box, where the dark blot and his lighter body cancel; it cannot see a shadow beside him. The 64 px/m still shows the beam darken beside him; at full frame the effect is subtle. 57 px faint trace on the span art's anti-aliased rim.
- Item 4: frame cost bar (p50 upper CI95 < 0.5 ms) NOT proven: 3 rounds +0.444 ms [-0.402, +1.290], 4 more rounds +0.272 ms [-0.711, +1.254] (`evidence/yard30/roof_frame_cost.md`); the before arm's own p50 moves 2.2 to 3.1 ms between rounds on the shared machine, more than the effect; the after arm also carries the mouth span, so it is an upper bound. The lever the builder named (`ochre: false` on the slabs) turns the skylights and fire holes grey-mauve: rejected by look (`evidence/yard30/roof_ochre_off_64ppm.png`).
- Item 4 look: the slabs' vertical ribbing still reads a little like cladding at 64 px/m; roof-feed is the flattest slab; shutter_w's ledge line remains.
- Item 3 film: the blot is on screen in the seed-42 film but faint at 1080p (a soft darkening of the bend beside him, seen on a close look); the bot rarely stands on a span (seed 7: no run over 1.2 s), so the shadow is a rare sight in play.
- Item 6: the 189 s prologue film runs past the 15-40 s clip rule by design (the whole prologue was asked for).
- Mutate not run on the session 5 commits (`89c56895c` python cutter: pytest instead; `7d87cf75a` dev/ probe and film flags): the final gate held the lane's one Godot.

## What blocked or slowed you (minutes each)

- `git worktree add` / `git archive` for a "before" arm stalled over 20 min on the 23k-file repo (session 2): 20 min; overlay projects in `C:/Users/kazda/kiro/gtai-n30/dec-before|dec-after` used instead.
- One lane Godot slot shared by three builders (session 3): about 40 min of waiting; the span shadow film slipped.
- The front camera's centre is fixed at (26, 3), so the roof sat above the 64 px/m frame: one bounced 2 min call.
- Debt ratchet (`dev_loc` +122 for the span-window probe) stopped one commit: 3 min, accepted through `debt.mjs --accept-regression`.
- The first span shadow film used seed 7, where Rivet never stays on a span: one wasted film (about 20 min); a probe over five seeds found the window.

## Calls for the owner

1. Roof frame cost (item 4): ship the roof with its cost not proven under the bar on this shared machine (shipped on), or trade look for cost (ochre off: `evidence/yard30/roof_ochre_off_64ppm.png`; or half-resolution slab textures). Before | after: `evidence/yard30/roof_before_after_front_32ppm.png`.
2. Span shadow (item 3): soft blot beside him on the beam (shipped on) or a stronger alpha / a cast silhouette. Stills: `evidence/yard30/span_shadow_before_after_64ppm.png` (64 px/m), `evidence/yard30/span_shadow_film_frame.png` (32 px/m in play, faint).
3. Tyre arcs in the stain layer (item 2): leave them at 76 % or redraw `floor_stains.png`'s arcs darker (an art job, not a value). Still: `evidence/yard30/decals_over_before_after_mid_32ppm.png`.

## Merge notes

- Every yard change is data plus prologue yard code (`project/boot/prologue/**`, `prologue_yard_dressings.json`, its schema); keys' Rivet files untouched.
- Root `JOURNAL.md` / `REPORT.md`: keep this lane's on an add/add conflict.
- `tools/debt/baseline.json`: this lane raised `dev_loc` 39253 -> 39375 (`project/dev/prologue_yard` 705 -> 827) with a dated reason; on a conflict run `node tools/debt/merge_baseline.mjs`, then `--update`.
- `yard_film.gd` gained `--seed` / `--at` in its own `KNOWN_FLAGS` (a dev scene); `project/boot/launch_args.gd` is untouched.
- Shipped replays, tapes and the prologue pilots: unchanged (pilots identical on 5 seeds after every item).

## Next steps

- Roof cost: measure on a quiet machine with an A/A twin (the `tools/perf/fight_gate.mjs` method) before trading any look; if it is still over 0.5 ms, half-resolution slab textures first (keeps the ochre print).
- Plate gaps the three cameras still show (`evidence/yard30/plate_judgement.md`): warm lamp pools and cast shadows in the mid yard, a skyline behind the roof, a foreground set at the gate, the belt entering a visible breach in the hall.
- Tyre arcs: redraw `raised_line/floor_stains.png`'s arcs darker if the owner wants them at 100 %.
- Roof look: a slab edit pass for roof-feed (flattest) and shutter_w's ledge line; less vertical ribbing at 64 px/m.

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
| mouth-place (05c B) | Sonnet | 5 | accepted |
| mouth-evid (05c) | Sonnet | 2 | accepted (film 960x1080, redone) |
| ochre-look (04c 1) | Sonnet | 2 | accepted (look: ochre stays on) |
| roof-cost (04c) | Sonnet | 9 | accepted (bar still not proven) |
| mouth-fade (05d) | Sonnet | 8 | accepted |
| shadow-film (03c) | Sonnet | 22 | accepted (after a debt-ratchet stop) |

What I would brief differently: name the evidence window from data before the film call (a probe of where the thing is visible), not from a camera place; put the debt tool in the allowlist of any call that adds dev code; give one builder an item's change and its whole evidence tail (the short 5-25 min calls of session 5 were the best value, as in n29).
