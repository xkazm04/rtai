# n29 belt snake: bars under a span

Spans are non-blocking over-print rows (collision, cover and lanes unchanged: `evidence/yard29/belt_lanes.txt` 31 ok 0 FAIL).

## Pilots (`evidence/yard29/prologue-yard-pilots-spans.json`, one Godot process, `yard_pilot_rows --dressings=arched_line --seeds=7,3,11,21,42`)
Expected = `prologue-yard-pilots-hall.json`: ticks, deaths, min_hp, stuck, sha256 all IDENTICAL for the five seeds
(11701 / 11958 / 10392 / 12158 / 13278; deaths 0/1/0/0/1; lowest health 36/0/44/28/0). The working tree held the other lane's uncommitted table/schema edits (hall-polish) while this ran.

## Readability under a span (`belt_under_span.py`, raw `belt_under_span.txt`)
Two exposures of the SAME seed-7 pilot at tick 2290, 32 px/m: `arched_line` and the temp row `arched_nospan` (arched_line minus the five `span_*` rows; removed again, never committed). Rivet or the first patrol cop is stood (render only, no sim step) on 28 points along the five spans, feet 0.9 and 1.5 m below the beam so the body overlaps it. Span pixels = where the two actor-hidden ground frames differ; the measure reads only the body pixels over a span pixel (cop >= 40 px, Rivet >= 150 px).
- Patrol blue (dusk_contrast.py mask and WCAG contrast ratio, span vs floor-only, same pixels): 8 samples, 1.99 vs 2.37, retained 84.1 % (per-sample min 60.4 %, 3 samples above 100 %). Bar >= 65 %: PASS on the mean; ONE sample (60.4 %) is under it.
- Rivet luminance delta against what is under him (rivet_delta.py style): 28 samples, 0.021 on a span vs 0.101 on the floor only (20.9 %, median per-sample 18 %, min 1.9 %). Copper on a copper beam: by luminance Rivet is nearly lost wherever he overlaps the beam's body. No bar is stated for this; the floor-only value is itself under the old 0.19 bar (floor_i55_bars.md 0.147). In the 64 px/m still (`belt_snake_64ppm.png`) he still reads by his silhouette, the dark helmet and the orange hazard collar. Not tuned: a decision for the owner (a darker or desaturated beam, or a drop shadow under Rivet).
- Method caveats: floor-only luminance varies by spot (0.008 to 0.25), so single samples are noisy; the 28 points were chosen on the beam, so this is the worst case, not the average play.
