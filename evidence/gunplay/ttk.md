# Gunplay TTK bench (headless, deterministic, 24 seeds per cell)

Source: `project/dev/gunplay/ttk_bench.gd` over `data/tables/weapons.json` at the iteration-1 commit. Not a perf number (pure sim).
Cell = median time to kill (s) / kill rate within 10 s / hit rate. "-" = out of range or no kill in 10 s.
The shooter aims at where the target IS (no lead), so a strafing target shows dodgeability. Humans juke at 3.2 m/s (bodies.json run), Rivet at 4.5 m/s.

## Player vs a still human (100 hp)

| weapon | 5 m | 10 m | 20 m | 35 m |
|---|---|---|---|---|
| electro_gun | 0.62 / 1.00 / 1.00 | 0.73 / 1.00 / 1.00 | 1.00 / 1.00 / 1.00 | - |
| flamethrower | 1.42 / 1.00 / 0.32 | - | - | - |
| gloria | 0.10 / 1.00 / 1.00 | 0.22 / 1.00 / 1.00 | 0.43 / 1.00 / 0.50 | - |
| machine_pistol | 0.15 / 1.00 / 0.67 | 0.32 / 1.00 / 0.42 | 0.70 / 1.00 / 0.18 | - |
| molotov | 1.17 / 1.00 / 0.00 | 1.53 / 1.00 / 0.00 | 2.98 / 1.00 / 0.00 | - |
| pistol | 0.08 / 1.00 / 1.00 | 0.17 / 1.00 / 1.00 | 0.33 / 1.00 / 0.44 | 0.85 / 1.00 / 0.23 |
| rocket_launcher | 0.25 / 1.00 / 1.00 | 0.52 / 1.00 / 1.00 | 1.08 / 1.00 / 1.00 | 1.92 / 1.00 / 0.50 |

## Player vs a strafing human (100 hp, 3.2 m/s juke every 1.5 s)

| weapon | 5 m | 10 m | 20 m | 35 m |
|---|---|---|---|---|
| electro_gun | 1.65 / 1.00 / 0.46 | - | - | - |
| flamethrower | 2.47 / 1.00 / 0.14 | - | - | - |
| gloria | 0.10 / 1.00 / 1.00 | 4.63 / 1.00 / 0.08 | 3.23 / 1.00 / 0.11 | - |
| machine_pistol | 0.22 / 1.00 / 0.48 | 0.65 / 1.00 / 0.20 | 1.37 / 1.00 / 0.09 | - |
| molotov | 1.98 / 1.00 / 0.00 | 3.20 / 1.00 / 0.00 | 4.70 / 1.00 / 0.00 | - |
| pistol | 0.08 / 1.00 / 0.92 | 1.52 / 1.00 / 0.17 | 1.67 / 1.00 / 0.10 | 3.25 / 0.96 / 0.07 |
| rocket_launcher | 0.27 / 1.00 / 0.00 | 0.53 / 1.00 / 0.00 | 4.70 / 1.00 / 0.00 | 3.75 / 1.00 / 0.00 |

## Player vs a still robot (600 hp, metal)

| weapon | 5 m | 10 m | 20 m | 35 m |
|---|---|---|---|---|
| electro_gun | 5.62 / 1.00 / 1.00 | 5.75 / 1.00 / 1.00 | 6.00 / 1.00 / 1.00 | - |
| flamethrower | 5.62 / 1.00 / 0.51 | - | - | - |
| gloria | 2.12 / 1.00 / 1.00 | 2.22 / 1.00 / 1.00 | 2.45 / 1.00 / 0.86 | - |
| machine_pistol | 0.83 / 1.00 / 0.92 | 0.92 / 1.00 / 0.83 | 1.83 / 1.00 / 0.44 | - |
| molotov | 7.83 / 1.00 / 0.00 | 8.20 / 1.00 / 0.00 | - | - |
| pistol | 1.42 / 1.00 / 1.00 | 1.50 / 1.00 / 1.00 | 1.68 / 1.00 / 0.83 | 3.00 / 1.00 / 0.50 |
| rocket_launcher | 2.08 / 1.00 / 1.00 | 2.35 / 1.00 / 1.00 | 2.92 / 1.00 / 1.00 | 5.57 / 1.00 / 0.25 |

## Enemy fire (0.45x speed, 0.25x damage) vs Rivet strafing at 4.5 m/s (100 hp)

| weapon | 5 m | 10 m | 20 m | 35 m |
|---|---|---|---|---|
| electro_gun | - | - | 7.12 / 0.67 / 0.41 | - |
| flamethrower | 4.80 / 1.00 / 0.07 | - | - | - |
| gloria | - | - | - | - |
| machine_pistol | 7.72 / 0.92 / 0.11 | 9.20 / 0.42 / 0.08 | 8.02 / 0.13 / 0.06 | - |
| molotov | 3.52 / 1.00 / 0.00 | 4.95 / 1.00 / 0.00 | 5.25 / 1.00 / 0.00 | - |
| pistol | 6.08 / 1.00 / 0.20 | - | 9.33 / 0.38 / 0.10 | 9.63 / 0.08 / 0.07 |
| rocket_launcher | 4.32 / 1.00 / 0.00 | 6.62 / 1.00 / 0.25 | 4.32 / 1.00 / 0.00 | 9.70 / 1.00 / 0.00 |
