# Brief n26 pressure 02b (resume): the cased rocket must read LARGE at 32 px/m

Hard stop 14:20 wall clock (stop, commit what is green, report). Commit deadline 14:10.
Same setup as brief 02 (`APPDATA`, `GODOT_BIN`, `--rendering-driver d3d12` for renders, one Godot at a time,
`--position 0,1440` for windowed). Same allowlist and forbidden list as brief 02.

## What I saw in your stills (Director review)
Shape and colours are right (casing steel, ice-blue rim `#92c9f5`, ice-blue jet). But at 32 px/m
(`rocket-enemy-32-pair.png`, `rocket-vs-rivet-32.png`) the new rocket is a ~30 px dark sliver on dark asphalt: it is
the SAME size as Rivet's rocket and much less visible than the old blob. The pick says "readable at 32 px/m as enemy,
LARGE, dodge it". Today it does not read as large.

## Do
1. Scale: body length 1.4 m in flight (was 0.97; at 32 px/m about 45 px), thickness in proportion, so it is clearly
   larger than Rivet's rocket and about the diameter of the trooper's launcher tube in `rocket-vs-rivet-64.png`.
   Change it in the cut tool (`BODY_SIZE`), re-cut, keep `--check` hashes in step (update the expected values).
2. Exhaust: the ice-blue jet about 0.9 to 1.0 m long at 32 px/m (today ~24 px at 64 = 0.37 m), cut from the same plate's
   plumes (scale them with their own factor in the tool, not by stretching in the draw call), bright core still
   ice blue / near-white, no amber anywhere.
3. Separation from asphalt: a thin soft ice-blue under-glow or 1-2 px ice-blue outline under the body sprite
   (view-only, drawn on the same round canvas, e.g. the body texture drawn once tinted `LARGE_RIM` at ~40 % alpha and
   scaled 1.12 underneath, or a soft line along the axis). Keep it subtle: the casing (steel) is what reads.
4. The surviving mutant on `fight_areas_art.gd` line ~86 (`and` -> `or` in the FoeOrdnanceView/FxView routing): add a
   unit test that pins the routing (a FoeOrdnanceView NOT under an FxView draws the cased rocket once; under an FxView it
   draws nothing itself, the tracer pass draws it once). If the routing can be made simpler (one owner of the draw,
   no parent check), do that instead and say so.
5. Re-make the four stills with the same names in `C:\Users\kazda\kiro\gtai-masters\n26\pressure\` (same tick, zoom,
   seed). Look at them: at 32 px/m the enemy rocket must be visibly larger than Rivet's and pop off the asphalt.
   Sample and report body, rim, glow and jet colours.
6. If (and only if) all of the above is committed before 14:05: cut plate C
   (`C:/Users/kazda/kiro/gtai-art/pressure-n26/out/enemy_rocket_c.png`) with the same tool to `build/rocket-c/` (NOT
   wired, not committed) and render one 32 px/m still with C drawn in place of A, same tick, beside the new A:
   `C:\Users\kazda\kiro\gtai-masters\n26\pressure\rocket-a-vs-c-32.png` (labelled A | C). The owner picks.
7. Runs: `node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs`, commit; then
   `node tools/tests/run_scenarios.mjs --only=replay_60s` and quest 1's tape scenario (view only: digests must not move).
   Then `node tools/mutate/mutate.mjs --file=project/features/combat/weapons/fight_areas_art.gd --max=20
   --lines=<changed lines>` and the same for `enemy_rocket_art.gd`; quote the scores.
8. One commit for the re-cut art + tool, one for the draw + test. No amend, no rebase. Fix lint and format findings in
   your own edit and go on. Append nothing to `docs/decisions.md` unless the size decision needs it: then ONE line
   `- [2026-11-23] DECISION pressure trooper rocket size: 1.4 m ...`.

## Report
Before/after sizes in px at 32 and 64 px/m, sampled colours, what you see in each still, test added, mutate scores,
digests, commits.
