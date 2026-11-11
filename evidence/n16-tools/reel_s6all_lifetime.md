# kill reel: aftermath lifetime of every death (n16 tools s6)

`node tools/film/kill_reel.mjs --out=build/kreel/s6all --weapons=all --quick --after=600 --rev=b9dba1da8 --native=donor` (kills-new b9dba1da8, dir 90, 32 px/m, feel off), 13/13 PASS, 18:03:14-18:14:53.
Measured by the 8a9a91375 rule (curve = whole kill window vs the trigger frame; `gone by` = under 0.5 % from that beat to the last, outside his standing spot), recomputed on the films' frames.

| weapon | kill | aftermath curve (measured) |
|---|---|---|
| rocket_launcher | 68 | +20 29.0 / +40 5.2 / +80 5.0 / +150 5.0 / +300 5.0 / +600 4.9 %, still there at +600 (outside his standing spot) |
| hand_cannon | 63 | +20 2.8 / +40 2.4 / +80 2.0 / +150 2.0 / +300 2.0 / +600 2.0 %, still there at +600 (outside his standing spot) |
| flamethrower | 237 | +20 2.6 / +40 2.6 / +80 2.5 / +150 2.2 / +300 2.0 / +600 2.0 %, still there at +600 (outside his standing spot) |
| molotov | 182 | +20 12.0 / +40 11.6 / +80 11.6 / +150 11.7 / +300 12.5 / +600 12.5 %, still there at +600 (outside his standing spot) |
| electro_gun | 129 | +20 1.4 / +40 1.6 / +80 1.8 / +150 1.8 / +300 1.8 / +600 1.0 %, gone by +600 (outside his standing spot) |
| claw_shock | 127 | +20 4.7 / +40 4.2 / +80 1.4 / +150 1.4 / +300 1.4 / +600 1.0 %, gone by +600 (outside his standing spot) |
| katana | 68 | +20 11.5 / +40 3.1 / +80 3.2 / +150 3.2 / +300 3.2 / +600 2.3 %, still there at +600 (outside his standing spot) |
| plasma_rifle | 65 | +20 2.2 / +40 2.3 / +80 2.2 / +150 1.9 / +300 1.8 / +600 1.0 %, gone by +600 (outside his standing spot) |
| plasma_sword | 68 | +20 10.7 / +40 2.1 / +80 2.1 / +150 2.1 / +300 2.1 / +600 1.1 %, gone by +600 (outside his standing spot) |
| chainsaw | 68 | +20 11.1 / +40 11.1 / +80 9.4 / +150 3.5 / +300 3.5 / +600 2.6 %, still there at +600 (outside his standing spot) |
| ray_gun | 63 | +20 2.3 / +40 2.5 / +80 2.3 / +150 2.1 / +300 2.1 / +600 1.1 %, gone by +600 (outside his standing spot) |
| homing_shard | 69 | +20 1.2 / +40 3.0 / +80 4.0 / +150 4.1 / +300 4.1 / +600 3.5 %, still there at +600 (outside his standing spot) |
| mini_nuke | 127 | +20 73.6 / +40 35.7 / +80 35.7 / +150 35.7 / +300 35.7 / +600 6.4 %, still there at +600 (outside his standing spot) |
