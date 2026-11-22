# Rivet’s blast weapons

The player arsenal in `project/data/tables/weapons.json` supplies these four rows to `GunHand`. The two weapons in `combat.json` are quest weapons with no splash fields. The new `combat.json` setting `blast.self_k` is 1.0.

| Weapon ID | Splash radius (m) | Direct damage (table HP) | Splash damage (table HP) | Point-blank self damage (fighter HP) |
| --- | ---: | ---: | ---: | ---: |
| `rocket_launcher` | 3.5 | 300 | 220 | 2.20 |
| `molotov` | 2.2 | 30 | 40 | 0.40 |
| `homing_shard` | 1.2 | 100 | 30 | 0.30 |
| `mini_nuke` | 12.0 | 2000 | 1500 | 15.00 |

The last column uses base-form Rivet in the open with enough HP to absorb the full blast. His gun converts 100 table HP to one fighter HP, the same conversion used for splash against a hostile. Distance is measured to the edge of Rivet’s body. Splash falls linearly to zero at the stated radius.

The filmed launcher round hit its target at tick 256 in both takes. At impact Rivet stood at (−1.200, −0.029) m and the rocket burst at (1.599, −0.547) m. His HP fell from 100 to 99.212469 on the open floor and stayed at 100 behind the high wall. The 16-second, 1080p60 capture and the two impact stills are in `gtai-masters/n23/controls/` as `self_blast.mp4`, `self_blast_hit.png` and `self_blast_wall.png`.

The seed-7 average gauntlet completed five waves. Its `self_damage` values in order were 0.0, 0.0, 0.0, 0.0 and 0.0. In the lethal gauntlet test, a rocket finished Rivet at 0.25 HP, the wave recorded 0.25 for both damage counters, the HUD showed zero health and the death row named `rocket_launcher`.
