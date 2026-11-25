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
