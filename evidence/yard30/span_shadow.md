# n30-03b span shadow read: a blot beside Rivet on the beam, clipped to the span art

Code: `project/boot/prologue/prologue_span_shadow.gd`, row `arched_line.span_shadow` = alpha 0.75, fade 6 ticks,
size_m 1.9 x 2.3, offset_m (0.55, -0.6) from the feet (down-right of his body centre, which sits 0.95 m up),
body_m 0.9 x 1.9; raised_line no longer carries the key (`test_prologue_raised_line.gd` erases it from arched_line).

- Trigger: his body box (`body_m` wide, `body_m.y` up from the feet, sampled every 0.15 m) overlaps solid span art
  (alpha >= 0.5), not only the feet point. Fade stays on the sim tick (6 ticks in, 6 out).
- Shape: the n30-03 radial gradient texture (made once), stretched to `size_m` round feet + `offset_m`.
  Started at the brief's (0.25, 0.35) m, 1.6 x 0.9 m, alpha 0.6: at 64 px/m it sat below his feet on the floor
  between the S curve and the lower beam and was clipped away (s1: 0 shadow px, s0: 763 px, max delta 39/255).
  Then (0.3, -0.55), 1.6 x 2.1, alpha 0.7 (s0 1278 px, still mostly under his body), then past his right side onto the beam: (0.55, -0.6), 1.9 x 2.3, alpha 0.75.
- Clip: the node sets `clip_children = CLIP_CHILDREN_ONLY` and draws the five spans with `PrologueYardPaint.wreck`
  (the over-print's own transform) as the mask; the blot is its only child. No per-frame allocation; the mask
  redraws only when the shadow turns on or off, the blot when he moves.
- Pilots seeds 7, 3, 11, 21, 42, one Godot process: ticks, deaths, min_hp, stuck, sha256 IDENTICAL to
  `evidence/yard29/prologue-yard-pilots-props.json` and `evidence/yard30/prologue-yard-pilots-{shade05,decals,shadow}.json`
  (`evidence/yard30/prologue-yard-pilots-shadowread.json`).
- Unit: `test_prologue_span_shadow` (body on with feet on the floor, body clear off inside the rect, fade in/out,
  clip mode + blot rect, key absent = no node) and `test_prologue_raised_line`: 30 passed with
  `test_prologue_yard_dressing`.

Seen (`span_shadow_before_after_64ppm.png`, S span, feet 28.67,17.77, tick 2290, n30-03's stand probe with
the shadow stepped 13 fake ticks; before = shadow hidden): after, the S curve's beam right of and below his body
is darker, a soft ink band that follows the beam's edge and stops at it; the floor round him is unchanged.
Shadow pixels (on vs off frame, delta > 2): s0 2571 px (max 128/255), s1 (feet 28.67,18.37) 877, s2 (27.57,19.15) 932.
It reads in a zoom; at the full sheet it is subtle, a darker beam beside him rather than a cast silhouette.

Measured (n29's 28 stand points, seed 7 tick 2290, 32 px/m, same probe and `span_shadow_measure.py`, floor arm = n30-03's
temp arched_nospan frames `build/n30/st_ns`, which have no spans and so no shadow node; raw `span_shadow_read_measure.txt`):

| set | samples | span before | span after | floor-only | shadow px off the span |
|---|---|---|---|---|---|
| all n29 points | 28 | 0.0211 | 0.0205 | 0.0944 | 57 |
| shadow on (body on a span) | 26 | 0.0210 | 0.0204 | 0.0953 | 57 |
| shadow off | 2 | 0.0212 | 0.0212 | 0.0822 | 0 |

- The body trigger works: the shadow is on at 26 of 28 points (n30-03: 9).
- Bar on a span >= 0.06: NOT MET (0.021 -> 0.020). The metric is |mean lum(Rivet + shadow px) - mean lum(ground)| over
  span pixels in his box: the blot adds pixels darker than the beam while parts of his body are lighter than it, so
  the signed means cancel; the beam beside him does get darker (see the still) but this number cannot show it.
- Floor: frames with the shadow off are pixel-identical (0 px). 57 px over 26 frames fall where the span art's alpha
  is so low that the spans-vs-nospan ground frames differ by <= 6 (the measure's span edge): the clip multiplies by
  the span alpha, so the anti-aliased rim of the art carries a faint trace. Not 0 px by this measure.

Not done (the shared lane Godot slot was busy 13:16..13:38 and 13:48..14:04 with decals-finish's runs): the 32 px/m
film and its frames.json entry. Mutate: `span_shadow_mutate.txt` if it finished (first 10 mutants only).

---

# n30-03 span shadow: soft drop shadow under Rivet on a belt span (BAR NOT MET)

Code: commit `726550b45` (`project/boot/prologue/prologue_span_shadow.gd`, key `span_shadow` alpha 0.45, fade 6 ticks, 1.1 x 0.45 m).
Pilots seeds 7, 3, 11, 21, 42 in one Godot process: ticks, deaths, min_hp, stuck, sha256 IDENTICAL to `evidence/yard29/prologue-yard-pilots-props.json`, `evidence/yard30/prologue-yard-pilots-shade05.json` and `-decals.json` (`evidence/yard30/prologue-yard-pilots-shadow.json`).

Method: n29's 28 Rivet stand points (`span_stand_targets.txt`), seed 7 tick 2290, 32 px/m, probe `span_stand_probe.gd.txt` (n29's yard_stand + the shadow stepped 13 fake ticks; exposures shadow shown / hidden (= before, the only render change) / actors and shadow hidden), temp row arched_nospan (restored, never committed), `span_shadow_measure.py` (n29's belt_under_span.py Rivet formula). Raw: `span_shadow_measure.txt`.

| set | samples | span before | span after | floor-only |
|---|---|---|---|---|
| all n29 points | 28 | 0.0211 | 0.0213 | 0.0944 |
| feet on span art | 9 | 0.0206 | 0.0213 | 0.1216 |
| feet off span art | 19 | 0.0213 | 0.0213 (no shadow) | 0.0815 |

- Bar on a span >= 0.06: FAIL (0.021 -> 0.021). 19 of the 28 n29 points have the feet on the floor below the beam (body overlaps it on screen), so by the brief's own definition there is no shadow there.
- Floor-only unchanged: yes (frames without spans have no shadow node; feet-off frames pixel-identical, 0 shadow px).
- Shadow reaches the floor: 409 px over the 9 feet-on frames where the ellipse passes a beam edge (unclipped). A clipped variant (the node draws the spans as a `CLIP_CHILDREN_ONLY` mask) is drafted in build/n30/clip.gd, not committed.
- Seen (`span_shadow_before_after_64ppm.png`, S span, feet 28.67,17.77): the ellipse sits almost entirely under Rivet's own feet and body; before and after are hard to tell apart. At 1.1 x 0.45 m centred on the feet it does not read as a shadow. It would need an offset (down-screen, away from the body) and/or a larger, darker blot to change the measure.

Not done: the 32 px/m film (the lane lock was held by the other builder 12:41..13:03), mutate.
