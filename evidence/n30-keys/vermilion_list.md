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
