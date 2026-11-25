# n31 melee 02p3 part 2 - guard rail with the drawn geometry (flag on; waves 1-4, seeds 1-5, average bot, greedy)

Before = `evidence/n31-melee/01-baseline/before/baseline.json` (flag off). Bar: kills/swing within +-15 %.
Geometry = `geometry.md` (part 1). Chainsaw lever: its sweep ends at its first bite (`MeleeSweep.bitten`:
a grinding hit stops sweeping once it struck; the grind re-test takes what it caught), plus its drawn arc.

Commands (each run `ok exit 0; SCRIPT ERROR 0; unknown arg 0; result fresh; flags checked: 4 against KNOWN_FLAGS`):
- `node tools/melee/play_baseline.mjs --label=after-sweep-2 --sweep --out=evidence/n31-melee/02-sweep` (25 runs; saw = first bite only)
- `node tools/melee/play_baseline.mjs --label=after-sweep-2-saw-arc --sweep --weapons=chainsaw --out=evidence/n31-melee/02-sweep` (saw = first bite + `sweep_arc_deg` [-44, 24])

| weapon | before | 02p2 (provisional) | after-sweep-2 | change | bar |
|---|---|---|---|---|---|
| claw | 0.795 | 0.874 (+9.9 %) | 0.872 | +9.7 % | PASS |
| chainsaw | 0.787 | 0.940 (+19.4 %) | first bite: 0.931 (+18.3 %, ABOVE); + drawn arc: **0.886** | **+12.6 %** | PASS |
| electro_baton | 1.040 | 1.017 (-2.2 %) | 1.174 | +12.9 % | PASS |
| katana | 0.994 | 0.739 (-25.7 %) | 1.073 | +7.9 % | PASS |
| plasma_sword | 1.238 | 1.101 (-11.1 %) | 1.189 | -4.0 % | PASS |

No deaths, every run reached wave 4. The first bite alone moved the saw only 1 point: its extra kills came
from the sweep's sector running wider than the drawn saw (sim -50..+48 deg vs drawn -44..+24); the drawn arc
(part 1's rule: > 10 deg apart) brought it inside the bar.
