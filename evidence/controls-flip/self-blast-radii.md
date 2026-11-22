# Rivet’s blast weapons

The player arsenal in `project/data/tables/weapons.json` supplies these four rows to `GunHand`. The two weapons in `combat.json` are quest weapons with no splash fields. In `combat.json`, `blast.rivet_hp_per_table_hp` is 0.1 and `blast.self_k` is 1.0.

| Weapon ID | Splash radius (m) | Direct damage (table HP) | Splash damage (table HP) | Point-blank self damage (Rivet HP, before clipping) |
| --- | ---: | ---: | ---: | ---: |
| `rocket_launcher` | 3.5 | 300 | 220 | 22 |
| `molotov` | 2.2 | 30 | 40 | 4 |
| `homing_shard` | 1.2 | 100 | 30 | 3 |
| `mini_nuke` | 12.0 | 2000 | 1500 | 150 |

For base-form Rivet in the open, each table HP deals 0.1 Rivet HP. The damage falls linearly with the distance from the impact to the edge of his 0.6 m body radius. Splash against hostiles still uses the gun's 0.01 conversion.

A rocket takes at least **10 HP** through **1.909 m from the body edge** (**2.509 m from the centre**). The threshold is `3.5 * (1 - 10 / 22)`. A mini-nuke kills a full-health, 100 HP Rivet through **4.00 m from the edge** (**4.60 m from the centre**), where `150 * (1 - 4 / 12) = 100`. Wall cover, roll immunity and Tonnage armour still apply.

The seed-7 average gauntlet survived all five waves and produced no death row. Its `self_damage` values in order were 0.0, 0.0, 0.0, 0.0 and 0.0. In the lethal gauntlet test, a rocket finished Rivet at 0.25 HP, the wave recorded 0.25 for both damage counters, the HUD showed zero health and the death row named `rocket_launcher`.

The two eight-second film takes use identical inputs. Rivet fired at the bullseye from about 2.37 m at tick 242. The rocket hit at tick 246 at (0.077134, -1.149575) m, with Rivet at (0.416388, 1.05) m. His HP fell from 100 to 88.217955 in the open. The same spot behind the high wall kept all 100 HP. The production HUD rounds the live value up to 89. The impact caption shows the measured 11.78 HP loss.

All 59 targeted GUT cases passed. The mutation run on `project/features/combat/rivet_self_blast.gd` exercised all 18 candidates with a cap of 20. It killed 15 of 17 valid mutants (88.2%). Two survived, one was invalid and none timed out.
