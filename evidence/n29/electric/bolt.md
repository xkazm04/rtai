# n29 electric: the in-flight electro bolt as live current

Code: `WeaponFxBolt` (`project/features/combat/weapons/art/weapon_fx_bolt.gd`), called from the BOLT branch of
`weapon_fx_art.gd`; `--electro-cells` keeps the old arc/spark cells. Commits 3e2fde824, 3ba4b1fdd (wiring), 25fb82801.

## Look (screen px, call 3b)
One width for the bolt, the chain hop and the stun (`WeaponFxElectro.BODY_PX` 10, `CORE_PX` 4, `add_path`): halo a0.18 9 px,
mid a0.5 4.5 px, (chain and bolt only) opaque ink outline 13 px (`INK_EXTRA_PX` 3), **opaque amber body a1.0 10 px**, cream
core a1.0 4 px; the daze stars get the same body and core without the ink rim (it stays a faint under-halo). The 3a bolt-only
5 px body is gone. The first try, 8/3 px with no ink, read as a thin line next to the cells zigzag; amber on the pale floor
needs the ink rim, as the cells' zigzag has. `ElectricArc.strokes()` is untouched; `--electro-cells` keeps the cells.
Measured in the 64 px/m take frames (1920x1080, k = 1 so the same at 32 px/m): across the path 10 px of amber/cream
(rows 134-143 at one column), 13 px with the ink; in the hop frame the same. Red/vermilion count 0 (bolt box), 0-1 (hop box);
teal 0 (bolt box), 33 in the hop box vs 19 in the cells arm (robot ink and glints, no effect stroke is teal).
Honest read: bold amber with ink at the cells' weight, but flatter than the cells zigzag (the kink amplitude is `ElectricArc`'s).

## Take (item `electro_gun_hop`)
`TAKE_FLAGS=--electro-cells node tools/film/owner_takes.mjs <dir> 32|64 electro_gun_hop` (no flag = current). Rivet stands
10 m from the first robot_thug and does not walk; a second thug is held 2.5 m behind it (inside chain_radius_m 4).
Hop proof (take.json `hop`, both arms): `{"chain_hits":1,"first_hop_tick":119,"hurt_tick":119,"extra_hp":6.0,"hop_m":2.5}`,
first thug hit and killed tick 119; the second thug loses hp the same tick.
Masters: `C:/Users/kazda/kiro/gtai-masters/n29/combat/films/electro_bolt_{cells,current,pair}_32.mp4` (1920x1080 60 fps,
18.0 s, 1080 frames; the pair 1920x540), `stills/electro_bolt_{cells,current,pair}_64.png` (tick 114), `stills/electro_hop_pair_64.png` (tick 121, the 3a thin one kept
as `electro_hop_pair_64_thin.png`). Re-rendered in call 3b: each film 1920x1080 60 fps 18.000 s 1080 frames (pair 1920x540,
labelled cells | live current).

## Mutate
Not run (next call): `node tools/mutate/mutate.mjs --file=project/features/combat/weapons/art/weapon_fx_electro.gd --max=20 --tests=test_weapon_fx_electro,test_electric_arc` and the same on `weapon_fx_bolt.gd`.
