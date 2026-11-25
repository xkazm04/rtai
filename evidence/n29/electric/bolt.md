# n29 electric: the in-flight electro bolt as live current

Code: `WeaponFxBolt` (`project/features/combat/weapons/art/weapon_fx_bolt.gd`), called from the BOLT branch of
`weapon_fx_art.gd`; `--electro-cells` keeps the old arc/spark cells. Commits 3e2fde824, 3ba4b1fdd (wiring), 25fb82801.

## Look (screen px)
Path tail -> head: halo a0.18 9 px, mid a0.5 4.5 px, **opaque amber body a1.0 5 px (bolt path only)**, cream core a1.0 2 px;
a 3-4 fork star at the head (the chain star strokes). Kinks hash the spawn point (0.25 m) and the 3-tick cell, so ticks
in one cell give the same plan. No ink rim.
Why the body: a 64 px/m still of the first build (halo only) showed a cream hairline, the arena print dissolves the
translucent halo. A 3.5 px body was still invisible (printed to paper); 5.0 px prints amber. The chain hop and stun
(shared `add_path`) print cream with a pale amber glow and are unchanged. Honest read: at 32 px/m the bolt is a thin
amber/cream line, quieter than the thick cells zigzag; a wider body or a deeper amber print ink is the next lever.

## Take (item `electro_gun_hop`)
`TAKE_FLAGS=--electro-cells node tools/film/owner_takes.mjs <dir> 32|64 electro_gun_hop` (no flag = current). Rivet stands
10 m from the first robot_thug and does not walk; a second thug is held 2.5 m behind it (inside chain_radius_m 4).
Hop proof (take.json `hop`, both arms): `{"chain_hits":1,"first_hop_tick":119,"hurt_tick":119,"extra_hp":6.0,"hop_m":2.5}`,
first thug hit and killed tick 119; the second thug loses hp the same tick.
Masters: `C:/Users/kazda/kiro/gtai-masters/n29/combat/films/electro_bolt_{cells,current,pair}_32.mp4` (1920x1080 60 fps,
18.0 s, 1080 frames; the pair 1920x540), `stills/electro_bolt_{cells,current,pair}_64.png`, `stills/electro_hop_pair_64.png`.

## Mutate
Not run (next call): `node tools/mutate/mutate.mjs --file=project/features/combat/weapons/art/weapon_fx_electro.gd --max=20 --tests=test_weapon_fx_electro,test_electric_arc` and the same on `weapon_fx_bolt.gd`.
