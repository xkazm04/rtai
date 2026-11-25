# Vermilion per weapon: danger or heat (n30 keys, analysis only, no recolour)

Owner's pick: weapon item art keeps its design colours; this lists the vermilion per weapon as danger (warheads, emitters,
warning stripes) or heat (to amber) for the owner's yes. Colour law: red = blood only; vermilion = danger, objectives, Rivet's
collar; amber = fire, heat, electric current. Nothing was recoloured, no art file was touched.

## Method

- Input: n29's `evidence/n29-keys/held_red/table.md` (127 files). Vermilion = hue 9..24, s > 0.6, v > 0.6, alpha > 0 (same as `triage.py`).
- Weapons: every weapon whose art holds >= 50 vermilion px in any file (`vermilion/comps.py`). The crate (84 px in p70, wood grain) is not a weapon and is left out.
- File shown: the p70 showcase image per weapon (`showcase/p70/<weapon>.png`), except the assault rifle, which has only `assault_rifle/held.png`. Px counts are of that file. Other files of the same weapon (held_55, p55, icon, pickup) carry the same parts at other scales; a few hold far more vermilion in bulk (mini nuke held_55 6227 px, rocket launcher held_55 4527 px, homing shard p55 1126 px) because the same parts are drawn larger or the warm body paint reads vermilion there.
- Parts: connected components of the vermilion mask (dilated 2 px to merge), named by eye from the 4x crop (`vermilion/ids.py` draws the numbered boxes; `vermilion/build.py` holds the id -> part spec and makes the tables and stills).
- Classes: **danger** (warhead, live charge, warning stripe or decal), **heat** (coil, hot pipe, cable, burner: would go amber), **design** (a paint colour over a whole surface: keep), **speckle** (scattered wear, no part: no change).
- Stills: `gtai-masters/n30/keys/vermilion/<weapon>_4x.png` (left crop, right classed: danger white outline, heat amber fill, design grey hatch, speckle none) and `contact_4x.png`.
- Rebuild: `python -I evidence/n30-keys/vermilion/comps.py`, then `python -I evidence/n30-keys/vermilion/build.py`, from the worktree root.

## Per-part list

| weapon | file shown | part | class | px | one line why |
|---|---|---|---|---|---|
| ray_gun | `showcase/p70/ray_gun.png` | grip coil winding | heat | 1348 | copper coil wrapped round the grip: current wire, goes amber |
| ray_gun | `showcase/p70/ray_gun.png` | side feed cables | heat | 302 | cables running to the emitter: current |
| ray_gun | `showcase/p70/ray_gun.png` | top feed pipe | heat | 298 | copper pipe arching over the body: hot pipe |
| ray_gun | `showcase/p70/ray_gun.png` | emitter rings | heat | 1100 | two copper coil rings before the dish: the charged coil, amber like the arc |
| ray_gun | `showcase/p70/ray_gun.png` | warning triangle | danger | 117 | solid triangle decal: a hazard mark |
| ray_gun | `showcase/p70/ray_gun.png` | scattered wear | speckle | 8 | small orange flecks and rust patches, no part |
| electro_gun | `showcase/p70/electro_gun.png` | barrel coil (3 rings) | heat | 2114 | the coil that makes the arc: current, amber |
| electro_gun | `showcase/p70/electro_gun.png` | warning slash plate | danger | 127 | diagonal hazard stripe on a plate: warning |
| electro_gun | `showcase/p70/electro_gun.png` | scattered wear | speckle | 54 | small orange flecks and rust patches, no part |
| rocket_launcher | `showcase/p70/rocket_launcher.png` | warhead nose stripes | danger | 737 | warning stripes on the round's nose: the warhead |
| rocket_launcher | `showcase/p70/rocket_launcher.png` | fuse cables | heat | 130 | orange cable looping between the two charge boxes: current |
| rocket_launcher | `showcase/p70/rocket_launcher.png` | scattered wear | speckle | 724 | small orange flecks and rust patches, no part |
| mini_nuke | `showcase/p70/mini_nuke.png` | muzzle warning stripes | danger | 465 | hazard stripe plate under the muzzle: live charge |
| mini_nuke | `showcase/p70/mini_nuke.png` | coolant hoses | heat | 95 | copper hose elbows under the barrel: hot pipe |
| mini_nuke | `showcase/p70/mini_nuke.png` | scattered wear | speckle | 197 | small orange flecks and rust patches, no part |
| homing_shard | `showcase/p70/homing_shard.png` | stripe plates (3) | danger | 362 | diagonal hazard stripes on the body plates: warning |
| homing_shard | `showcase/p70/homing_shard.png` | coiled hoses | design | 420 | design colour, keep (owner) |
| homing_shard | `showcase/p70/homing_shard.png` | scattered wear | speckle | 352 | small orange flecks and rust patches, no part |
| flamethrower | `showcase/p70/flamethrower.png` | feed pipe | heat | 313 | pipe running to the nozzle: hot pipe, amber |
| flamethrower | `showcase/p70/flamethrower.png` | nozzle cage | heat | 87 | burner cage around the flame: heat |
| flamethrower | `showcase/p70/flamethrower.png` | scattered wear | speckle | 333 | small orange flecks and rust patches, no part |
| electro_baton | `showcase/p70/electro_baton.png` | coil winding | heat | 295 | copper coil at the prongs: current, amber |
| electro_baton | `showcase/p70/electro_baton.png` | scattered wear | speckle | 42 | small orange flecks and rust patches, no part |
| machine_pistol | `showcase/p70/machine_pistol.png` | coolant pipe loop | heat | 871 | copper U-pipe over the receiver: hot pipe |
| machine_pistol | `showcase/p70/machine_pistol.png` | scattered wear | speckle | 181 | small orange flecks and rust patches, no part |
| plasma_rifle | `showcase/p70/plasma_rifle.png` | feed cables | heat | 351 | orange cables over the top rail: current |
| plasma_rifle | `showcase/p70/plasma_rifle.png` | scattered wear | speckle | 18 | small orange flecks and rust patches, no part |
| gatling | `showcase/p70/gatling.png` | warning stripe panel | danger | 117 | hazard stripe window on the receiver: warning |
| gatling | `showcase/p70/gatling.png` | scattered wear | speckle | 77 | small orange flecks and rust patches, no part |
| plasma_sword | `showcase/p70/plasma_sword.png` | hilt hoses | heat | 128 | copper hoses into the blade: current |
| plasma_sword | `showcase/p70/plasma_sword.png` | warning stripe plate | danger | 52 | hazard stripes on the hilt block: warning |
| plasma_sword | `showcase/p70/plasma_sword.png` | scattered wear | speckle | 73 | small orange flecks and rust patches, no part |
| chainsaw | `showcase/p70/chainsaw.png` | scattered wear | speckle | 700 | rust patches on the bar and body |
| katana | `showcase/p70/katana.png` | scattered wear | speckle | 212 | rust patches on the blade and guard |
| hand_cannon | `showcase/p70/hand_cannon.png` | scattered wear | speckle | 479 | rust flecks over the body |
| pistol | `showcase/p70/pistol.png` | scattered wear | speckle | 309 | rust flecks over the body |
| assault_rifle | `assault_rifle/held.png` | scattered wear | speckle | 91 | rust flecks |
| gloria | `showcase/p70/gloria.png` | scattered wear | speckle | 33 | stray specks |

## Per-weapon summary

| weapon | danger px | heat px | design px | speckle px | proposed (owner's yes) |
|---|---|---|---|---|---|
| ray_gun | 117 | 3048 | 0 | 8 | grip coil, cables, pipe, emitter rings -> amber; triangle stays vermilion |
| electro_gun | 127 | 2114 | 0 | 54 | barrel coil -> amber; warning plate stays vermilion |
| rocket_launcher | 737 | 130 | 0 | 724 | fuse cables -> amber; nose stripes stay vermilion; rust stays |
| mini_nuke | 465 | 95 | 0 | 197 | hoses -> amber; muzzle stripes stay vermilion; plum casing stays (design, hue below vermilion) |
| homing_shard | 362 | 0 | 420 | 352 | stripe plates stay vermilion; hoses stay (design colour, keep) |
| flamethrower | 0 | 400 | 0 | 333 | feed pipe and nozzle cage -> amber; tank rust stays |
| electro_baton | 0 | 295 | 0 | 42 | coil -> amber; bar rust stays |
| machine_pistol | 0 | 871 | 0 | 181 | coolant loop -> amber; rust stays |
| plasma_rifle | 0 | 351 | 0 | 18 | cables -> amber |
| gatling | 117 | 0 | 0 | 77 | stripe panel stays vermilion |
| plasma_sword | 52 | 128 | 0 | 73 | hoses -> amber; hilt stripes stay vermilion (n29 excluded this weapon; owner's call) |
| chainsaw | 0 | 0 | 0 | 700 | no change: wear only |
| katana | 0 | 0 | 0 | 212 | no change: wear only |
| hand_cannon | 0 | 0 | 0 | 479 | no change: wear only |
| pistol | 0 | 0 | 0 | 309 | no change: wear only |
| assault_rifle | 0 | 0 | 0 | 91 | no change: wear only |
| gloria | 0 | 0 | 0 | 33 | no change: wear only |

## In play (held_55 and Rivet's strips)

What the game draws while Rivet holds a weapon. `project/data/tables/weapon_held_pitch.json` (pitch 55, the `tilt` row) names `art/held_55/<weapon>.png` as the held part (with `<weapon>_small.png` under the held_small_below_ppm zoom and `_empty`/`_empty_small` for the tubes after the shot; the Gatling's entry reads `enabled`, its pale 55 part holds 19 vermilion px anyway). Rivet himself is drawn from the baked strips `project/features/characters/art/view/{p55,p70}/rivet_eq_<weapon>*.png`, `rivet_walk_eq_*` and `rivet_run8_eq_*`, which show the weapon in his hands; the side-facing cell used here is cell 0 (strip width / 3) of `p70/rivet_eq_<weapon>_left.png`. Same mask, components and classes as above (`vermilion/held_lib.py`, `vermilion/held_build.py`, `vermilion/held_ids.py`; the old outputs are unchanged). Counts use the unfiltered vermilion mask above, so they run higher than n29's red-gated column (mini nuke `held_55` 8423 here, 6227 there). New class **rivet**: Rivet's own hazard collar in the cell (owner's vermilion, not weapon art), kept out of the weapon totals. Stills: `gtai-masters/n30/keys/vermilion/<weapon>_held_4x.png` (held_55 at 2x on top, the cell at 4x below; left crop, right classed) and `contact_held_4x.png`. No recolour, no art file touched.

Files with >= 500 vermilion px in play and classed: every weapon below. Not classed on a cell: hand cannon, pistol, katana, electro baton (rust-only or coil-only held art; their cells were not looked at one by one).

### Per-part list (in play)

| weapon | file shown | part | class | px | one line why |
|---|---|---|---|---|---|
| ray_gun | `held_55/ray_gun.png` | feed cable arcs | heat | 269 | thin copper cable arc over the body: current wire, goes amber |
| ray_gun | `held_55/ray_gun.png` | scattered wear | speckle | 195 | rust patches and flecks, no part |
| ray_gun | `p70 rivet_eq_ray_gun_left.png cell 0` | emitter coil rings | heat | 30 | copper coil rings at the dish: the charged coil |
| ray_gun | `p70 rivet_eq_ray_gun_left.png cell 0` | feed pipe loop | heat | 16 | pipe loop over the body: hot pipe |
| ray_gun | `p70 rivet_eq_ray_gun_left.png cell 0` | Rivet's collar | rivet | 432 | Rivet's own hazard collar (owner's vermilion), not weapon art |
| ray_gun | `p70 rivet_eq_ray_gun_left.png cell 0` | scattered wear and Rivet's cracks | speckle | 307 | rust patches and flecks, no part |
| electro_gun | `held_55/electro_gun.png` | feed cable arcs | heat | 425 | thin copper cable arc over the body: current wire, goes amber |
| electro_gun | `held_55/electro_gun.png` | scattered wear | speckle | 293 | rust patches and flecks, no part |
| electro_gun | `p70 rivet_eq_electro_gun_left.png cell 0` | barrel coil | heat | 118 | the coil that makes the arc: current, amber |
| electro_gun | `p70 rivet_eq_electro_gun_left.png cell 0` | Rivet's collar | rivet | 221 | Rivet's own hazard collar (owner's vermilion), not weapon art |
| electro_gun | `p70 rivet_eq_electro_gun_left.png cell 0` | scattered wear and Rivet's cracks | speckle | 69 | rust patches and flecks, no part |
| rocket_launcher | `held_55/rocket_launcher.png` | warhead nose stripes | danger | 4008 | warning stripes on the warhead nose: the live round |
| rocket_launcher | `held_55/rocket_launcher.png` | scattered wear | speckle | 2370 | rust patches and flecks, no part |
| rocket_launcher | `p70 rivet_eq_rocket_launcher_left.png cell 0` | warhead nose stripes | danger | 44 | warning stripes on the warhead nose: the live round |
| rocket_launcher | `p70 rivet_eq_rocket_launcher_left.png cell 0` | Rivet's collar | rivet | 303 | Rivet's own hazard collar (owner's vermilion), not weapon art |
| rocket_launcher | `p70 rivet_eq_rocket_launcher_left.png cell 0` | scattered wear and Rivet's cracks | speckle | 250 | rust patches and flecks, no part |
| mini_nuke | `held_55/mini_nuke.png` | warhead nose stripes | danger | 6082 | warning stripes on the warhead nose: the live round |
| mini_nuke | `held_55/mini_nuke.png` | coolant cable arc | heat | 935 | thin copper cable arc over the body: current wire, goes amber |
| mini_nuke | `held_55/mini_nuke.png` | scattered wear | speckle | 1406 | rust patches and flecks, no part |
| mini_nuke | `p70 rivet_eq_mini_nuke_left.png cell 0` | Rivet's collar | rivet | 323 | Rivet's own hazard collar (owner's vermilion), not weapon art |
| mini_nuke | `p70 rivet_eq_mini_nuke_left.png cell 0` | scattered wear and Rivet's cracks | speckle | 567 | rust patches and flecks, no part |
| homing_shard | `held_55/homing_shard.png` | coiled hose arcs | design | 368 | design colour, keep (owner): the showcase class of the hoses |
| homing_shard | `held_55/homing_shard.png` | scattered wear | speckle | 450 | rust patches and flecks, no part |
| homing_shard | `p70 rivet_eq_homing_shard_left.png cell 0` | hose loop | design | 21 | design colour, keep (owner): the showcase class of the hoses |
| homing_shard | `p70 rivet_eq_homing_shard_left.png cell 0` | Rivet's collar | rivet | 446 | Rivet's own hazard collar (owner's vermilion), not weapon art |
| homing_shard | `p70 rivet_eq_homing_shard_left.png cell 0` | scattered wear and Rivet's cracks | speckle | 580 | rust patches and flecks, no part |
| flamethrower | `held_55/flamethrower.png` | scattered wear | speckle | 129 | rust patches and flecks, no part |
| flamethrower | `p70 rivet_eq_flamethrower_left.png cell 0` | Rivet's collar | rivet | 180 | Rivet's own hazard collar (owner's vermilion), not weapon art |
| flamethrower | `p70 rivet_eq_flamethrower_left.png cell 0` | scattered wear and Rivet's cracks | speckle | 282 | rust patches and flecks, no part |
| machine_pistol | `held_55/machine_pistol.png` | coolant cable arcs | heat | 699 | thin copper cable arc over the body: current wire, goes amber |
| machine_pistol | `held_55/machine_pistol.png` | scattered wear | speckle | 1264 | rust patches and flecks, no part |
| machine_pistol | `p70 rivet_eq_machine_pistol_left.png cell 0` | Rivet's collar | rivet | 411 | Rivet's own hazard collar (owner's vermilion), not weapon art |
| machine_pistol | `p70 rivet_eq_machine_pistol_left.png cell 0` | scattered wear and Rivet's cracks | speckle | 463 | rust patches and flecks, no part |
| gatling | `held_55/gatling.png` | scattered wear | speckle | 19 | rust patches and flecks, no part |
| gatling | `p70 rivet_eq_gatling_left.png cell 0` | Rivet's collar | rivet | 265 | Rivet's own hazard collar (owner's vermilion), not weapon art |
| gatling | `p70 rivet_eq_gatling_left.png cell 0` | scattered wear and Rivet's cracks | speckle | 352 | rust patches and flecks, no part |
| chainsaw | `held_55/chainsaw.png` | ignition cable loop | heat | 679 | copper cable looped off the engine: current wire |
| chainsaw | `held_55/chainsaw.png` | scattered wear | speckle | 1227 | rust patches and flecks, no part |
| chainsaw | `p70 rivet_eq_chainsaw_left.png cell 0` | Rivet's collar | rivet | 348 | Rivet's own hazard collar (owner's vermilion), not weapon art |
| chainsaw | `p70 rivet_eq_chainsaw_left.png cell 0` | scattered wear and Rivet's cracks | speckle | 269 | rust patches and flecks, no part |
| hand_cannon | `held_55/hand_cannon.png` | scattered wear | speckle | 1201 | rust patches and flecks, no part |
| pistol | `held_55/pistol.png` | scattered wear | speckle | 1138 | rust patches and flecks, no part |
| katana | `held_55/katana.png` | scattered wear | speckle | 673 | rust patches and flecks, no part |
| electro_baton | `held_55/electro_baton.png` | coil winding | heat | 889 | copper coil at the prongs: current, amber |
| electro_baton | `held_55/electro_baton.png` | scattered wear | speckle | 29 | rust patches and flecks, no part |
| plasma_rifle | `held_55/plasma_rifle.png` | feed cable arcs | heat | 339 | thin copper cable arc over the body: current wire, goes amber |
| plasma_rifle | `held_55/plasma_rifle.png` | scattered wear | speckle | 296 | rust patches and flecks, no part |
| plasma_rifle | `p70 rivet_eq_plasma_rifle_left.png cell 0` | Rivet's collar | rivet | 359 | Rivet's own hazard collar (owner's vermilion), not weapon art |
| plasma_rifle | `p70 rivet_eq_plasma_rifle_left.png cell 0` | scattered wear and Rivet's cracks | speckle | 377 | rust patches and flecks, no part |
| mini_nuke_empty | `held_55/mini_nuke_empty.png` | coolant cable arc | heat | 935 | thin copper cable arc over the body: current wire, goes amber |
| mini_nuke_empty | `held_55/mini_nuke_empty.png` | scattered wear | speckle | 1661 | rust patches and flecks, no part |
| rocket_launcher_empty | `held_55/rocket_launcher_empty.png` | scattered wear | speckle | 2699 | rust patches and flecks, no part |
| mini_nuke_small | `held_55/mini_nuke_small.png` | warhead nose stripes | danger | 2239 | warning stripes on the warhead nose: the live round |
| mini_nuke_small | `held_55/mini_nuke_small.png` | scattered wear | speckle | 700 | rust patches and flecks, no part |
| rocket_launcher_small | `held_55/rocket_launcher_small.png` | warhead nose stripes | danger | 1719 | warning stripes on the warhead nose: the live round |
| rocket_launcher_small | `held_55/rocket_launcher_small.png` | scattered wear | speckle | 124 | rust patches and flecks, no part |

### Per-weapon summary (in play)

| weapon | file | danger px | heat px | design px | speckle px | rivet px | proposed (owner's yes) |
|---|---|---|---|---|---|---|---|
| ray_gun | `held_55/ray_gun.png` | 0 | 269 | 0 | 195 | 0 | held_55 feed arcs and the cell's emitter rings and pipe loop -> amber; no warning triangle in play |
| ray_gun | `p70 rivet_eq_ray_gun_left.png cell 0` | 0 | 46 | 0 | 307 | 432 | see its held_55 row |
| electro_gun | `held_55/electro_gun.png` | 0 | 425 | 0 | 293 | 0 | feed arcs and cell barrel coil -> amber; no warning plate in play |
| electro_gun | `p70 rivet_eq_electro_gun_left.png cell 0` | 0 | 118 | 0 | 69 | 221 | see its held_55 row |
| rocket_launcher | `held_55/rocket_launcher.png` | 4008 | 0 | 0 | 2370 | 0 | nose stripes stay vermilion (danger) in held_55 and the cell; rust stays; no fuse cables in play |
| rocket_launcher | `p70 rivet_eq_rocket_launcher_left.png cell 0` | 44 | 0 | 0 | 250 | 303 | see its held_55 row |
| mini_nuke | `held_55/mini_nuke.png` | 6082 | 935 | 0 | 1406 | 0 | nose stripes stay vermilion (danger); coolant arc -> amber; the cell holds none (hazard bands are yellow) |
| mini_nuke | `p70 rivet_eq_mini_nuke_left.png cell 0` | 0 | 0 | 0 | 567 | 323 | see its held_55 row |
| homing_shard | `held_55/homing_shard.png` | 0 | 0 | 368 | 450 | 0 | arcs stay (design colour, keep); rust stays; no stripe plates in play |
| homing_shard | `p70 rivet_eq_homing_shard_left.png cell 0` | 0 | 0 | 21 | 580 | 446 | see its held_55 row |
| flamethrower | `held_55/flamethrower.png` | 0 | 0 | 0 | 129 | 0 | no change: wear only in play |
| flamethrower | `p70 rivet_eq_flamethrower_left.png cell 0` | 0 | 0 | 0 | 282 | 180 | see its held_55 row |
| machine_pistol | `held_55/machine_pistol.png` | 0 | 699 | 0 | 1264 | 0 | held_55 cable arcs -> amber; rust stays; the cell holds none |
| machine_pistol | `p70 rivet_eq_machine_pistol_left.png cell 0` | 0 | 0 | 0 | 463 | 411 | see its held_55 row |
| gatling | `held_55/gatling.png` | 0 | 0 | 0 | 19 | 0 | no change: no vermilion in play |
| gatling | `p70 rivet_eq_gatling_left.png cell 0` | 0 | 0 | 0 | 352 | 265 | see its held_55 row |
| chainsaw | `held_55/chainsaw.png` | 0 | 679 | 0 | 1227 | 0 | ignition cable loop -> amber; rust stays |
| chainsaw | `p70 rivet_eq_chainsaw_left.png cell 0` | 0 | 0 | 0 | 269 | 348 | see its held_55 row |
| hand_cannon | `held_55/hand_cannon.png` | 0 | 0 | 0 | 1201 | 0 | no change: rust only |
| pistol | `held_55/pistol.png` | 0 | 0 | 0 | 1138 | 0 | no change: rust only |
| katana | `held_55/katana.png` | 0 | 0 | 0 | 673 | 0 | no change: rust only |
| electro_baton | `held_55/electro_baton.png` | 0 | 889 | 0 | 29 | 0 | coil -> amber; rust stays |
| plasma_rifle | `held_55/plasma_rifle.png` | 0 | 339 | 0 | 296 | 0 | held_55 feed arcs -> amber; the cell holds none |
| plasma_rifle | `p70 rivet_eq_plasma_rifle_left.png cell 0` | 0 | 0 | 0 | 377 | 359 | see its held_55 row |
| mini_nuke_empty | `held_55/mini_nuke_empty.png` | 0 | 935 | 0 | 1661 | 0 | arc -> amber; rust stays; no nose |
| rocket_launcher_empty | `held_55/rocket_launcher_empty.png` | 0 | 0 | 0 | 2699 | 0 | no change: rust only (nose cut away) |
| mini_nuke_small | `held_55/mini_nuke_small.png` | 2239 | 0 | 0 | 700 | 0 | nose stripes stay vermilion (danger); the small has no arc |
| rocket_launcher_small | `held_55/rocket_launcher_small.png` | 1719 | 0 | 0 | 124 | 0 | nose stripes stay vermilion (danger); rust stays |

### Where the in-play class differs from the showcase class

- ray_gun: showcase heat 3048 (grip coil, side cables, pipe, emitter rings) and a danger triangle; in play the held_55 part is a pale variant with only the feed arcs (heat 269) and the cell only the emitter rings and pipe loop (46). No grip coil, no triangle in play.
- electro_gun: showcase danger plate 127; in play none (heat arcs 425 in held_55, barrel coil 118 in the cell; the showcase coil 2114 is not vermilion in the cell).
- rocket_launcher: showcase danger 737 / heat 130; in play danger 4008 (held_55 nose, whole warhead as stripes) and 1719 (small), 44 in the cell; no fuse cables. Same class, far more px: the nose is the one danger part and stays vermilion.
- mini_nuke: showcase danger muzzle plate 465 / hoses 95; in play danger is the warhead nose stripes 6082 (the showcase muzzle plate is not in held_55), heat is one coolant arc 935. The cell holds no danger (yellow bands).
- homing_shard: showcase danger stripe plates 362 + design hoses 420; in play only the hose arcs (design 368) and rust; no stripe plates.
- flamethrower, gatling, machine pistol: showcase heat pipe/loop is largely absent in play: flamethrower held_55 and cell are wear only, gatling 19 px wear, machine pistol keeps its cable arcs (heat 699) in held_55 only.
- Chainsaw (new vs the showcase's wear-only): an ignition cable loop (heat 679) off the engine; the rest is rust. Plasma rifle and electro baton: feed arcs / coil as heat, as the showcase.
- Where the warm body paint reads vermilion as a whole surface: none found; the big counts are the warhead stripes (danger) and rust patches (speckle, they are the 2370 / 1406 / 1227 / 1201 px speckle rows). No design-class surface.

### Could not class

- Rivet's cracks, wear and collar overlap in the cell: the rivet row is the collar by component id, cracks sit in the speckle row.
- Rocket launcher empty: a 329 px orange sliver at the cut edge of the nose ring is counted as speckle; it is a warhead remnant by eye (danger if the owner wants the cut edge kept).
- Cells for hand cannon, pistol, katana, electro baton, the Rivet walk/run strips and the diag/up views were not classed; they repeat the same collar and the same held parts at other angles.
