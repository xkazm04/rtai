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
`weapon_fx_bolt.gd` (--max=20, test_weapon_fx_electro): killed 2 / (2 + 12) = 14.3 % (2 invalid); the survivors are the
`draw()` path and `spawn_id` arithmetic, which need a CanvasItem or only feed the kink hash (not unit-reachable cheaply).
`weapon_fx_electro.gd` (--lines=28-33,134-146, --max=12): killed 6 / (6 + 5) = 54.5 % (1 invalid); the survivors were the two
translucent halo passes and the ink width at k != 1; a test (`test_chain_keeps_both_halos_and_scales_the_ink_with_k`) now
pins them (not re-mutated).

## Call 3c: lightning-sized kinks (`WeaponFxBolt.JAG_K` 3.0)
`WeaponFxBolt.amplify` scales every interior point's perpendicular offset from the end-to-end line by `JAG_K` (ends fixed, pure,
no RNG) after `ElectricArc.shape`, for the bolt (`WeaponFxBolt.plan`) and the chain hop (`chain_plan`); `electric_arc.gd` is
untouched, so kills and wrecks keep their arcs. 3.0 takes the 0.075 m kink to about 0.22 m. Measured in the 64 px/m bolt still
(tick 114, mean-y per column, peak to peak across the end-to-end line): cells zigzag 22.4 px, current 24.9 px. Red/vermilion 0 and
teal 0 in the bolt and the hop effect boxes (both arms). Only the current arm was re-rendered (the cells arm is unchanged code and
the same seed, its stills/film are reused). `stills/electro_{bolt,hop}_pair_64_flat.png` keep the near-straight 3b look. Films:
`electro_bolt_{cells,current}_32.mp4` 1920x1080 60 fps 18.000 s 1080 frames, `electro_bolt_pair_32.mp4` 1920x540 same
(labelled cells | live current), all ffprobe-checked.
