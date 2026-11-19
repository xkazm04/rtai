# Rivet city melee reach, 2026-11-19

At `92c76a4dd`, each row ran alone with `node tools/tests/run_scenarios.mjs --only=rivet_city_melee`, seed 20261103, the same three melee weapons and 1,800 ticks per fight. The scenario requires at least two kills with melee close-in enabled, an identical replay, and fewer than two kills with `melee_close_in = false`.

| City fight | Live kills | Planted kills | Scenario result |
|---|---:|---:|---|
| (a) Shipped default (squad) | 8 | 4 | FAIL, exit 1 |
| (b) Explicit guard | 8 | 0 | PASS, exit 0 |
| (c) Explicit squad, removed `city.squad.contractor_speed_mps` | 6 | 3 | FAIL, exit 1 |
| (d) Explicit squad, disabled `city.station_spacing_m` | 8 | 4 | FAIL, exit 1 |

The baseline failed with "planted fault not caught: a bot at gun reach still dropped 4". All four runs reached the planted check, so each live replay matched. For (b)-(d), the scenario passed the brain flag through `ArenaArgs` to its three sessions and recorded the planted fight's kill count. Each table experiment removed only the named key for that run. Removing the spacing key selects its 0 m default.

Squad wave movement lets the gun-range bot score enough melee kills to pass the live kill threshold even with its melee approach disabled. Removing the speed override changed the count by one. Turning off station spacing left both counts unchanged. Guard preserves the separation this scenario needs to detect a broken approach by Rivet.
