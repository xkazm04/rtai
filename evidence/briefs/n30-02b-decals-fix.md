# Brief n30-02b `decals-fix`: the decals-over look fix (the stain wash and the ochre bay lines) (lane yard, run n30)

HARD STOP: see the time in the prompt that launched you (report and END). COMMIT started no later than 15 minutes before it. Check `date` often. Never let the call end before its commit; never amend, never rebase.

## Setup
Same as `evidence/briefs/n30-02a-decals-over.md` (read its Setup: env exports, runGodot-only tools, the lane's Godot lock `build/yard-godot.lock`, here with your tag `decals-fix`). Another builder (`mouth-span-art`) has uncommitted edits in `tools/art/prologue_yard_spans*.py` and `steam/ai-provenance/2026-11.jsonl` and may take the Godot lock for its commit: never stage those files, never delete its lock.

## Why
Commit `5950ceb34` (read its diff first: `git show 5950ceb34`) moved the `floor_stains.png` ground layer (`over_impression`) and the non-ochre decals (`decals_over_impression`) of `arched_line` onto the over-print node after the i55 impression. Director's look at `evidence/yard30/decals_over_before_after_mid_32ppm.png`: tyre sweeps, scorch and oil are crisp and stay under the wrecks (good), BUT the whole floor went pale cream, the stains vanished and the ochre bay lines vanished. Two causes: (1) the stain layer's own `wash` `f6dca880` (a cream wash over its whole 60 x 34 m rect), which the world print used to press down, now draws raw over the floor; (2) the ochre layer (`PrologueYardPaint.attach_ochre`, the bay lines and other `ochre` pieces) is a CanvasLayer stacked BELOW the over-print layer, so the impression still hazes the bay lines. The owner asked for tyre marks, bay lines AND stains above the impression, and the floor must stay as dark as before (the plate's floor is dark concrete).

## Work
1. Stains: with the layer over the impression, drop its wash (`"wash": "00000000"` on that layer in `arched_line`) and, only if a look says so, retune that layer's `tint` alpha so the stains read at least as strong as at `5114a4441` (before) without going black. Data only.
2. Bay lines: one data value, a row key `"ochre_over_impression": true` (absent = today). With it, the impression (and the flagged ground layers and decals) draw on a layer BELOW the ochre layer, and the over-print wrecks and spans stay ABOVE the ochre layer: e.g. split `PrologueYardOverprint.attach` into a ground node attached before `attach_ochre` and the pieces node after it, keeping today's single-node path when the key is absent. Schema property, parse in `prologue_yard_dressing.gd`, keep files <= 200 lines (hard 300), functions <= 40 lines. A bay line must never draw over a wreck, a belt section or a span.
3. Tests: extend `project/tests/unit/test_prologue_yard_decals_over.gd` (key parses; with the key the layers stack impression < ochre < pieces; absent = today). `node tools/tests/run_unit.mjs --changed` (the whole changed set, green), `node tools/gate/quick.mjs`; fix lint and format findings in your own edit and go on.
4. Look before you commit: a mid still at `--place=mid --tick=300 --ppm=32` (`node tools/art/prologue_yard_film.mjs`), `5114a4441` look | after, to `evidence/yard30/decals_over_before_after_mid_32ppm.png` (REPLACE the file; the old after stays in git history). Measure the floor between the stains (a few clean patches away from decals and pools; mean CIELAB L*, C*): bar within +-2 L* of the `5114a4441` render at the same pixels. Say what the stains, tyre marks and bay lines look like against before. A 64 px/m crop of one bay line crossing a tyre mark beside a wreck: `evidence/yard30/decals_over_64ppm.png`.
5. COMMIT (`git commit -m "Yard n30: decals fix: stain layer without its wash, ochre bay lines over the impression" -- <paths>`).

## Owned files (allowlist). Any other path: stop and report a NEED.
`project/boot/prologue/prologue_floor.gd`, `prologue_yard_overprint.gd`, `prologue_yard_dressing.gd`, `prologue_yard_paint.gd` (all under `project/boot/prologue/`), `project/data/tables/prologue_yard_dressings.json` (`arched_line` keys of this item only), `project/data/schemas/prologue_yard_dressings.schema.json`, `project/tests/unit/test_prologue_yard_*.gd`, `project/tests/unit/test_prologue_raised_line.gd` (one erase line if it compares rows), `evidence/yard30/decals_over*`, `build/**`.

## Forbidden
As in n30-02a; plus `tools/**` and `steam/**` (another builder's uncommitted work). No mutate in this call. No `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push, never `--no-verify`.

## Report (final message, then END)
Commit sha; the stain values chosen; the ochre design; the floor L*/C* before vs after; what the decals look like now; tests; what was not done.
