# Player projectile sizes before

Computed from the default weapon-art draw code and the nontransparent bounds of the shipped textures. Length follows the sprite axis. Width is transverse. Values are pixels at 32 px/m in a straight-down view, before raster rounding. Smoke, exhaust, wick, detached sparks, ground shadows and other secondary effects are excluded.

Ordinary rounds use the full in-flight sprite. The jet and beam use tick 12 at 3.5 m flown. The two thrown weapons are at the apex. The quest assault rifle resolves to its assault_rifle art row through BareGunFx and WeaponArtKey.

| Weapon | Leading sprite | Length (px) | Width (px) | With trail (L x W, px) |
|---|---|---:|---:|---:|
| gloria | nail | 47.20 | 12.80 | 47.20 x 12.80 |
| pistol | tracer | 62.80 | 11.20 | 62.80 x 11.20 |
| machine_pistol | tracer | 62.80 | 11.20 | 62.80 x 11.20 |
| assault_rifle | tracer | 62.80 | 11.20 | 62.80 x 11.20 |
| hand_cannon | tracer | 79.44 | 17.92 | 79.44 x 17.92 |
| plasma_rifle | plasma_bolt | 51.00 | 12.80 | 51.00 x 12.80 |
| gatling | tracer | 48.64 | 6.72 | 48.64 x 6.72 |
| rocket_launcher | rocket | 36.40 | 14.00 | 106.60 x 31.22 |
| flamethrower | flame_0 | 47.85 | 20.97 | 57.14 x 37.00 |
| electro_gun | arc_0 | 72.38 | 22.64 | 78.00 x 22.64 |
| ray_gun | ray_beam_0 | 80.43 | 21.80 | 80.43 x 21.80 |
| homing_shard | shard | 37.80 | 8.80 | 37.80 x 8.80 |
| mini_nuke | nuke_shell | 78.57 | 36.45 | 97.22 x 36.45 |
| molotov | held bottle | 27.71 | 8.38 | 24.31 x 27.85 |

The FX scale is 32 x 2 / 320 = 0.2 px per source pixel. Bullet length scales by the square root of the weapon multiplier and width scales linearly. The electro measurement includes its 0.06 m ink outline on each side. Sources are the weapon_art and weapons tables, WeaponFxArt.shot, WeaponFxRay.draw_beam, WeaponFxShell.draw_round and BareGunFx.shot.

The last column measures the union of the in-flight marks along and across horizontal travel, including smoke, exhaust, the arc spark, jet tongues and embers, or the wick. It excludes the muzzle, impact and projected ground shadow. The sample uses tick 12, 3.5 m flown, origin (0, 0), shooter ID 0, and a 7 m throw for the lobbed weapons. The bottle rotates in flight, so its travel-axis bounds differ from its body-axis dimensions.

In the live view, FxView._shots hands typed player shots to WeaponFxArt.shot first. Gloria uses the nail cell at projectile_k 1.0. The launcher uses the rocket cell at scale 1.0 and places a separate animated exhaust behind the casing.

At tick 46 of the 32 px/m city capture, the casing includes RGB (141, 132, 124) and the exhaust includes RGB (232, 80, 42). The capture fired a real launcher at tick 40. All four baseline frames use that firing tick, camera and seed.
