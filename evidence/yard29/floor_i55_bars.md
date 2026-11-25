# n29 floor i55: bars at the committed row (real renders)

Same seed/ticks/cameras as n28's sweep (`evidence/yard29/art_sweep.sh` with `imp_row.py`, `bars.sh`; measures `sweep_measure.py`, `rivet_delta.py`, `rivet_de.py`, `dusk_contrast.py`, `appliance_delta.py`). i55 = committed row `ffffff8c`; i20 = the same build with a temp row edit `ffffff33`, restored (`git diff --stat` empty). Raw: `build/n29/{i20,i55}.json`.

| measure | i20 | i55 | bar | i20 | i55 |
|---|---|---|---|---|---|
| floor between pools L* / C* / hue | 54.4 / 13.0 / 70.1 | 51.9 / 18.3 / 67.6 | info (plate 59.9 / 24 / 66) | | |
| Rivet luminance delta (mean of 10 exposures) | 0.183 | 0.147 | >= 0.19 | FAIL | FAIL |
| Rivet dE2000 (mean; min) | 27.3 (18.8) | 24.1 (18.0) | >= 15 | pass | pass |
| patrol blue outside, % of day contrast | 81.3 | 80.6 | >= 65 | pass | pass |
| patrol blue inside | 89.4 | 88.7 | >= 65 | pass | pass |
| rifle retained % | 103.4 | 104.5 | >= 95 | pass | pass |
| pellet (shotgun) retained % | 97.8 | 100.9 | >= 90 | pass | pass |
| pool gain (core - between, L*) | +2.6 | +2.0 | >= +4 | FAIL | FAIL |
| cream appliance delta (info) | 0.024 (dE 6.0) | 0.071 (dE 4.2) | info | | |

Failures, one line each (nothing tuned; the owner picked the value):
- Rivet luminance delta: i55 0.147 is 77 % of the 0.19 bar (i20 0.183 also misses it now, by 0.007: n28 measured 0.191 before the hall mouth lights; n28's later note quotes a 0.152 bar, which i55 misses by 0.005 and i20 clears). The browner floor darkens toward Rivet's copper; his hue still separates (dE2000 24.1).
- Pool gain: +2.0 at i55 and +2.6 at i20, both under +4 (n28 measured +6.2 at i20 before the hall mouth lights and floor glow joined the pools; this run's "core" zone is the fire pools only). i55 loses 0.6 more: a darker, browner floor lifts less under a fire. Not caused by this change alone; it is the row as the lane left it.
