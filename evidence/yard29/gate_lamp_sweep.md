# n29 gate lamp: floor glow sweep (arched_line `yard_lamp_gate`, glow radius 5 m, intensity 0.1 / light radius 9 unchanged)

Method: `build/n29/lamp_sweep.sh` (temp row edit by `build/n29/lamp_row.py`, then `evidence/yard29/art_sweep.sh`: day + dusk captures, `sweep_measure.py`, `dusk_contrast.py`); the table was restored after each run. Gate-lamp pool gain = `evidence/yard29/gate_lamp_gain.py` (mean floor L* within 3 m of the lamp (40.8, 32.3) minus the ring 6..8 m, dusk ground frames; raw `gate_lamp_gain.txt`). Radius 5 m (today's 8 m dropped).

| strength | patrol outside / inside % (>= 65) | rifle % (>= 95) | pellet % (>= 90) | Rivet delta | lamp pool gain L* |
|---|---|---|---|---|---|
| 0 (today) | 80.4 / 87.5 | 104.4 | 101.2 | 0.1464 | +3.38 |
| 0.06 | 80.4 / 87.5 | 104.4 | 100.8 | 0.1466 | +4.11 |
| 0.10 | 80.4 / 87.5 | 104.4 | 100.4 | 0.1468 | +4.59 |
| 0.15 | 80.4 / 87.5 | 104.4 | 99.8 | 0.1471 | +5.20 |
| 0.30 (extra) | 80.4 / 87.5 | 104.4 | 98.4 | 0.1479 | +7.03 |
| 0.50 (extra) | 80.4 / 87.5 | 104.4 | 96.5 | 0.1488 | +9.49 |

Every value passes every bar; only the pellet moves (about -1 point per 0.15 of strength). Floor between pools and the fire-pool gain (+5.6) are unchanged. The 0.30 / 0.50 rows go beyond the briefed list because 0.15 was far inside the pellet bar. Chosen: 0.30, radius 5 m (0.15 gives a +1.8 L* lift over today, hardly visible; 0.50 is the same look brighter with 2 more points of pellet spent). Pellet 98.4 %.
