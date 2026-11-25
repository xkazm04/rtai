# Brief n30-03b `span-shadow-read`: make the span shadow read (lane yard, run n30)

HARD STOP: see the time in the prompt that launched you (report and END). FIRST COMMIT (look change + tests + pilots) started no later than 25 minutes after launch; LAST COMMIT started no later than 12 minutes before the hard stop. Check `date` often. Never amend, never rebase.

## Setup
Same as `evidence/briefs/n30-03-span-shadow.md` (env exports, d3d12 at `--position 0,1440`, runGodot-only tools, lane lock `build/yard-godot.lock` with your tag `span-shadow-read`). Never stage files you did not edit; `git commit -m ... -- <paths>`.

## Where it stands (read `evidence/yard30/span_shadow.md`, commits `726550b45`, `0603c886d`)
`PrologueSpanShadow` draws a 1.1 x 0.45 m ink ellipse (alpha 0.45) centred on Rivet's feet, only while the feet are on span art. Result: Rivet delta on a span 0.021 -> 0.021 (bar 0.06); the director's look at `evidence/yard30/span_shadow_before_after_64ppm.png`: before and after are indistinguishable, the ellipse hides under his own body. In 19 of 28 n29 stand points his feet are below the beam while his body covers it. 409 px spill past beam edges. A clip draft is in `build/n30/clip.gd` (untested).

## Work (the look is the bar: a shadow you can SEE on the beam beside him at 32 px/m)
1. Trigger: "on a span" = his body footprint (a box about 0.9 m wide from the feet up to his drawn head height, at x1.5 visual size) overlaps span art (alpha >= 0.5), not only the feet point. Keep the fade on the sim tick.
2. Shape: a soft blot offset down-screen and a little to one side so it shows past his silhouette on the beam (start at offset (0.25, 0.35) m, size 1.6 x 0.9 m, alpha 0.6; tune by look), CLIPPED to the span art so not one pixel lands on the floor (mask: draw the shadow as a texture whose alpha = span alpha mask x gradient, built once, or a small canvas shader with the span mask; no per-frame allocation). Every value in the `span_shadow` row (`offset_m` new, schema too).
3. Tests: body-overlap on / off, no shadow pixel outside the span mask, the fade, key absent = no node. If you can edit `project/tests/unit/test_prologue_raised_line.gd` by one line `assert_true(arched.erase("span_shadow"))`, do it and drop the key from `raised_line`. `node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs`. Pilots seeds 7, 3, 11, 21, 42 in ONE Godot process identical to `evidence/yard30/prologue-yard-pilots-shadow.json`. COMMIT 1 only after you LOOKED at a 64 px/m still on the S span and the shadow reads.
4. Measure with the n29 points (`evidence/yard30/span_stand_probe.gd.txt`, `span_shadow_measure.txt` method): on a span >= 0.06, floor frames pixel-identical, spill 0 px. Update `evidence/yard30/span_shadow.md`; still `evidence/yard30/span_shadow_before_after_64ppm.png` (re-render, labelled). Find a seed-7 pilot window where Rivet crosses a span (from the probe's track) and film 32 px/m 1080p60 15..40 s before | after hstack (two 960x1080 crops) to `C:/Users/kazda/kiro/gtai-masters/n30/yard/span_shadow_before_after_32ppm.mp4` (ffprobe line, the ticks); update its `frames.json` entries (valid JSON). One `docs/decisions.md` line (check `git diff --quiet docs/decisions.md` first; append and commit at once): `- [2026-11-25] DECISION yard n30 span shadow read: ...`. Mutate `node tools/mutate/mutate.mjs --file=project/boot/prologue/prologue_span_shadow.gd --max=20 --tests=test_prologue_span_shadow` to `evidence/yard30/span_shadow_mutate.txt`. COMMIT 2.

## Owned files (allowlist). Any other path: stop and report a NEED.
`project/boot/prologue/prologue_span_shadow.gd`, `prologue_yard_dressing.gd`, a new `project/boot/prologue/prologue_span_shadow.gdshader` (+ `.uid`) if needed, `project/data/tables/prologue_yard_dressings.json` (`span_shadow` keys only), its schema, `project/tests/unit/test_prologue_span_shadow.gd`, `project/tests/unit/test_prologue_raised_line.gd` (the one erase line), `evidence/yard30/**`, `docs/decisions.md` (one line), `C:/Users/kazda/kiro/gtai-masters/n30/yard/**`, `build/**`.

## Forbidden
`project/features/**` (keys' Rivet files), every other repo path, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`, other worktrees, `C:/Users/kazda/kiro/gtai-art/**`. No image generation. No `git add -A/./-u`, `git commit -a`, stash, amend, rebase, reset --hard, push, `--no-verify`. Fix lint and format findings in your own edit and go on.

## Report (final message, then END)
Commit shas; the values; delta on span / floor / spill; pilots identical; ffprobe line + ticks; mutate score; what you saw; what was not done.
