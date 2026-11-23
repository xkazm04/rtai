# Prologue yard frame cost

Seed 7, fixed 1920 x 1080 window, 70-degree camera, D3D12, NVIDIA GeForce RTX 4090, AMD Ryzen 7 7800X3D 8-Core Processor. Godot 4.7.2 ran uncapped with VSync disabled. Each sample covers 60 wall-clock seconds. The yard held the exclusive n26 bench lock throughout all nine samples. The release template failed to start the probe from the project directory. All measured runs used the same engine binary in game mode without a debugger. The probe recorded `debug_build=true`.

A is daylight torn_line. B0 is line_fire with dusk, fire, lamps and the broken front. B1 adds six drifting embers at each of the four heat sources. The three round orders were A/B0/B1, A/B1/B0 and A/B0/B1.

| Round | Day p50 | Day p99 | Dusk p50 | Dusk p99 | Dusk + embers p50 | Dusk + embers p99 |
|---|---:|---:|---:|---:|---:|---:|
| 1 | 2.810 | 5.613 | 2.533 | 5.365 | 2.528 | 5.098 |
| 2 | 2.302 | 4.739 | 2.207 | 19.521 | 2.539 | 5.298 |
| 3 | 2.178 | 3.971 | 2.424 | 31.867 | 2.435 | 5.166 |

All times are milliseconds between consecutive presentation-loop frames. The table below uses within-round differences and two-sided Student-t 95% intervals over the three paired differences (2 degrees of freedom).

| Comparison | Mean p50 difference [95% CI] | Mean p99 difference [95% CI] |
|---|---:|---:|
| Shipped dusk minus daylight | -0.042 [-0.702, +0.618] | +14.143 [-20.840, +49.127] |
| Increment from embers | +0.113 [-0.360, +0.585] | -13.730 [-46.580, +19.120] |

The ember pass was omitted. The samples did not establish the 0.5 ms limit at both percentiles.
