# n31 melee 02 part 2.3 - guard rail with the flag on (waves 1-4, seeds 1-5, average bot, greedy picks)

Commands (lane lock per run, tree 435eaf4e1 = part 2):
- `node tools/melee/play_baseline.mjs --label=after-sweep --sweep --out=evidence/n31-melee/02-sweep` (25 runs,
  every one `ok exit 0; SCRIPT ERROR 0; unknown arg 0; result fresh; flags checked: 4 against KNOWN_FLAGS`)
- payback re-run: `node tools/melee/play_baseline.mjs --label=after-sweep-payback --sweep --weapons=claw,chainsaw --out=evidence/n31-melee/02-sweep`

Before = `evidence/n31-melee/01-baseline/before/baseline.json` (flag off). Bar: kills/swing within +-15 %.

## First pass (no payback): `after-sweep/baseline.json`

| weapon | before kills/swing | after (sweep) kills/swing | change | bar +-15 % | before hit rate | after hit rate | after deaths | after wave mean/min |
|---|---|---|---|---|---|---|---|---|
| claw | 0.795 | 0.989 | +24.4 % | ABOVE | 0.883 | 0.961 | 0 | 4/4 |
| chainsaw | 0.787 | 0.94 | +19.4 % | ABOVE | 1.946 | 2.138 | 0 | 4/4 |
| electro_baton | 1.04 | 1.017 | -2.2 % | PASS | 0.972 | 0.92 | 0 | 4/4 |
| katana | 0.994 | 0.739 | -25.7 % | BELOW | 0.927 | 0.744 | 0 | 4/4 |
| plasma_sword | 1.238 | 1.101 | -11.1 % | PASS | 0.9 | 0.893 | 0 | 4/4 |

## Payback (one value per weapon, `sweep_recovery_ticks`, read only with the flag on)

| weapon | recovery ticks | kills/swing | vs before | bar | kept |
|---|---|---|---|---|---|
| claw | 13 -> 18 | 0.989 -> 0.874 | +9.9 % | PASS | yes (`rivet_melee.json` claw swing `sweep_recovery_ticks` 18) |
| chainsaw | 18 -> 24 | 0.940 -> 1.007 | +28.0 % | worse | no: a longer recovery means fewer swings for the same grind kills, so kills/swing ROSE; reverted, the chainsaw stays +19.4 % (ABOVE, open) |

## Final with the flag on

| weapon | before | after | change | bar |
|---|---|---|---|---|
| claw | 0.795 | 0.874 | +9.9 % | PASS |
| chainsaw | 0.787 | 0.940 | +19.4 % | ABOVE (open: recovery cannot pay it back; the lever is the grind - grind_ticks or damage - a NEED for the flip call) |
| electro_baton | 1.040 | 1.017 | -2.2 % | PASS |
| katana | 0.994 | 0.739 | -25.7 % | BELOW (the provisional drawn reach 2.1 -> 1.8 m; 01c's pixels, which read the katana LONGER than the table, decide it) |
| plasma_sword | 1.238 | 1.101 | -11.1 % | PASS |

No deaths, every run reached wave 4 in both passes. The flag stays OFF: the flip call re-chooses the sweep reaches
from 01c's measured drawn volume and re-runs this guard.
