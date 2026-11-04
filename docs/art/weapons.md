# Weapon art: the design language and the contract (weapon-art lane, 2026-11-04)

Reference sheets (masters, outside git): `gtai-masters/n4/weapon-art/frames/design-sheet-all16.png`
(each weapon: the held top-down part with grip and muzzle marked, the side-view pickup, the HUD icon,
the muzzle-flash frames and the held part at its true 32 and 64 px/m size, next to the T2 concept),
`lineup-core-*.png` / `lineup-adv-*.png` (held on the real Rivet rig beside a cop). Raw Codex sheets
and prompts are in `gtai-masters/n4/weapon-art/raw/`.

## The rules

1. **Scrap-built by a scrap robot.** Every weapon is junk welded into a tool: worn gunmetal, scuffed
   steel, electrical tape on handles, copper wire, riveted cream-painted plates, rust blooms. Nothing
   factory-clean, no brand marks, no text, no numbers.
2. **The silhouette names the weapon, not the detail.** One unique shape per weapon, checked as a
   flat icon (the HUD icon *is* the silhouette): the pistol is a short block, the machine pistol has
   the side clip and the wire stock, the rocket tube flares at the back, the flamer is a long thin
   wand with a ring tip plus the twin tank, the electro gun is the coil body with two prongs, the hand
   cannon is a fat drum, the ray gun has stacked rings and a bulb, the shard gun has the crystal
   cluster and the funnel, the mini-nuke has the striped bomb in the mouth.
3. **The palette tokens only.** Ink `#1B1517`, charcoal, wash, steel, paper. The one colour on a
   weapon is vermilion, and only where it means danger: the rocket's nose stripes, the mini-nuke
   shell, the molotov rag. Effects: muzzle flashes are paper with a vermilion core; flame is
   vermilion with a paper core; electro arcs, plasma and ray rings are paper-white in an ink ring.
   Never teal (souls only), never cop blue, never red (blood only).
4. **Bold ink outline, flat fills, print grain** (the D5 sticker parts, e.g. the cop's
   `forearm_pistol`). In game the held part draws through the rig's `print_part` material, so it
   prints as a dark ink silhouette like Rivet's parts, on a 1 world px paper rim (`WeaponArt.make_held`
   adds 8 cream silhouettes under it, the rigs' sticker halo; `--weapon-rim=off` drops it).
5. **Readable at 32 px/m.** Held weapons are drawn about 1.5x real size (pistol 0.70 m = 22 px,
   rocket launcher 1.70 m = 54 px), so they stick out of the claw beside a 2 m Rivet. One value per
   row (`length_m`).

## Views

| View | Where | Source |
|---|---|---|
| held (top-down, +x forward) | in Rivet's claw on the cutout rig | the top-down sheet |
| pickup (side view, lying flat) | on the floor; a gun on the floor shows its side | the side sheet |
| icon (cream silhouette, 9 px ink ring) | HUD | made from the side view |
| extra parts | `flamethrower/tank.png` (the twin tank on Rivet's back; the hose is a line to the wand) | the top-down sheet |

## The contract (`data/tables/weapon_art.json`, schema `gtai.weapon-art/1`, loader `WeaponArt`)

Per weapon id (the ids of `weapons.json` incl. the canon nail gun `gloria`, `melee_weapons.json`, plus
`chainsaw` and `plasma_sword`; 16 rows):
`held`, `pickup`, `icon`, `parts`, `size_px`, `grip_px` (where the claw closes), `muzzle_px` (the
bore tip; the blade tip for melee), `length_px` (tail-to-tip span), `length_m`, `grip_class`
(`one_hand`, `two_hand_long`, `shoulder`, `backpack_hose`, `thrown`, `heavy_two_hand`),
`muzzle_fx`, `projectile_fx`, `casing`.

```gdscript
var art: WeaponArt = WeaponArt.new()
var held: Sprite2D = art.make_held(&"pistol")  # origin = grip, +x = barrel, scaled to 32 px/m
socket.add_child(held)                          # rivet-arsenal: parent to the claw, rotate with the aim
var muzzle: Vector2 = art.muzzle_m(&"pistol")   # metres from the grip along the barrel: spawn shots here
var flash: Array[Texture2D] = art.fx_frames(art.muzzle_fx(&"pistol"))  # 3 frames, anchor fx_anchor()
```

`rig_scale(id)` gives the same scale in the cutout rig's part px (CutRig.SC = 0.1). FX cells draw at
`fx_scale()` = `fx_draw_scale` (2.0) x the part scale: at 1.0 a pistol flash was a speck at 32 px/m.

## Gore stickers (`art/gore/`, for the brutality kills)

`stump_round`, `stump_oval`, `chunks_3`, `chunk`, `bone`, `splash`, `charred` (overlay), `xray` (overlay),
`ash`, and the TOP-DOWN body overlays `xray_top`, `xray_top_jolt`, `charred_top`, `charred_top_slump`
(drawn on the human rig's layout from above: head disc, shoulder oval, arms forward to +x; anchor = the head
disc = the rig origin; rotate by the body's facing). The front-view `xray` / `charred` stay for a comic flash.
Blood tokens only (`#A30509` / `#540005`), comic ink, never photoreal. All are fx cells `gore_<name>`
(`WeaponArt.fx_frames(&"gore_xray_top")`). Authored at about 300-450 px per sticker: draw at the part scale
(0.1 world px per px) or larger.

## Silhouette check in the claw (iteration 4)

Judged in a live fight (`res://dev/arena/arena.tscn -- --rigs --clean --start=pit --bot=arsenal
--loadout=...`), the held parts print dark through `print_part`. At 32 px/m only the outline survives, so a
weapon must differ in OUTLINE from above, not in plates or colour. The machine pistol got a long curved side
feed box (`tools/art/smg_feed_box.py`) because it printed as the pistol's blob. A throw has no muzzle flash
(`muzzle_fx` ""). The flame jet starts long and thin at the nozzle and fans out (round puffs near the gun
read as red drops).

## Paper rim and magazines (iteration 5)

At 32 px/m the held gun printed as a dark blob on Rivet's dark arm. Every held part (and magazine) now sits
on a 1 world px paper rim, the same cream sticker edge the rigs draw: the gun reads as its own object at
32 px/m (`it5-rim-ab-64-32ppm.png`). Brass is a small paper glint (casing at 0.75 scale): charcoal casings at
1.3 read as bricks the size of a magazine.

Magazines (`parts.mag`, `part_grip_px.mag`; `tools/art/weapon_mags.py`, cut from each gun's own held part):
pistol = the slide plate with a paper nose, machine pistol = the curved feed box with its tape band, plasma
rifle = the glass cell, hand cannon = a six-round speed-loader. Drawn at the held part's scale, feed end +x.
`WeaponMagView` carries one in Rivet's off claw through the reload (out to the hip, a fresh one in) and leaves
the spent one on the floor.

## Weapon wall and the electro bolt (iteration 6)

- **Weapon wall** (`arena_stations/weapon-art.json`, station `weapon_art_rack`, `ArenaWeaponRack` +
  `WeaponRackView`): every weapon with art hangs muzzle up on a paper-wash board along the arena hub's north
  wall, in the brief's order, as its pickup side view at its drawn length. Render only (no sim state, nothing
  hashed); `--weapon-rack=off` hides it. Frame: `it6-weapon-wall-hub-64-32ppm.png`.
- **Electro bolt** (`arc_0..2`, `tools/art/weapon_fx_jet.py`): a jagged lightning bolt (6 sharp kinks on
  alternating sides, tapering to the head) with two kinked forks leaving forward and outward. The iteration-3
  smooth zigzag with backward stubs read as twigs. Same size and anchor, so nothing else changed.
- **Electro bolt ink** (iteration 20, call 3): on cream paving at 32 px/m the paper bolt read thinnest of the energy
  rounds. `WeaponFxElectro.ink_under` now draws the same arc frame in ink at 8 offsets 0.06 m out (the held rim's
  method) before the paper, so the bolt's ink outline thickens and it reads as one bold inked stroke. It applies to
  Rivet's bolt and the chain arcs. A silhouette 1.6x taller was tried first: its peaks missed the paper's and read as
  a smudge. `--arc-ink=off` (or `ARC_INK_M` 0) is the before. No new palette token.

## Character looks made for other lanes (iteration 6)

- `art/cop/` + `art/d5/cop/` `head_swat`, `torso_swat` (human-reactions REQUEST 1), `tools/art/swat_parts.py`.
- `art/thug/` + `art/d5/thug/`, Rivet's 25 parts as a dark gunmetal street-gang robot with one paper optic
  (human-reactions REQUEST 2), `tools/art/thug_parts.py`.
Both are scripted derivations of existing AI parts, so footprints and pivots are the rig's own.

## Energy rounds in flight (iteration 8)

Judged frame by frame in the city proving block at 32 px/m (cream paving) and in the arena at 64 px/m.
The rule is the tracer's: **two tones per round**. A charcoal (`INK_2`) part reads on cream paving, a paper
part reads on asphalt, and the whole round sits inside an ink ring.

- **Plasma bolt** (`fx/plasma_bolt`, 260 x 64, anchor at the head's tip): an ink comet. A charcoal tail
  tapers back, the fat head has a steel halo and a paper core, and a paper speed streak runs down the tail.
  The iteration-1 steel oval printed as a pale pill on cream.
- **Homing shard** (`fx/shard`, 190 x 44, anchor at the tip): the pale crystal head stays and gains a
  charcoal speed tail.
- **Ray gun** (`fx/ray_ring_0..2`, `WeaponFxRay`): a train of 4 hoops strung back along the beam from its
  head. Each is squashed to 0.42 along the travel (seen edge-on), and they widen and fade toward the tail.
  Each cell is a charcoal band with a paper stripe. Until iteration 8 every BOLT row drew the electro
  arc, so the ray gun fired lightning.
- Generator: `tools/art/energy_round_tails.py <fx_dir>` (deterministic). It prints the size and anchor
  for the table rows.

## Kinetic rounds and the empty tube (iteration 9)

The same read as iteration 8: every round at 32 px/m on the city block's cream paving and on asphalt. The cells
draw at 0.2 of their part size there (`fx_draw_scale` 2 x 32 / 320), so a feature under about 20 part px is a
hairline. `it9-round-cells-at-32ppm-cream-asphalt-3x.png` puts every round and flash cell at that true scale on
crops of both grounds.

- **Tracer** (`fx/tracer`, 320 x 64, anchor at the tip): a charcoal needle 44 px across at the head, with a paper
  streak and the 13 px ink ring. The iteration-1 needle (18 px across) printed as a pale hairline beside the guard's
  vermilion-headed rounds. Rivet's rounds stay ink and paper. The vermilion head is the enemy's danger mark.
- **Gloria's nail** (`fx/nail`, 240 x 64, anchor at the point): a steel shank 22 px across with a paper glint, a
  broad paper head, and a charcoal speed tail behind the head (the shard's rule). Head, shank and point still say
  "nail". The old 150 x 40 nail was a 30 x 2 px sliver.
- **Per-gun weight** (`projectile_k`, optional per weapon row, 0.5..3, absent = 1): the round's cell is drawn
  k times thicker and sqrt(k) times longer. The hand cannon is 1.6: a slug on the same tracer cell.
- **Mini-nuke shell** (`WeaponFxShell`): the mini-nuke is a THROWN row in `weapons.json` (a lobbed shell). A
  THROWN row whose `projectile_fx` is `rocket` flies as the rocket cell with its exhaust lick, on the bottle's lob
  arc and ground shadow, nose along the travel, swelling 35 % toward the apex, at `projectile_k` 1.5. Until
  iteration 9 it drew the molotov bottle.
- **Lob shadows** (`WeaponFxShell.shadow`): every lobbed round casts an ink ellipse 0.62 x 0.26 m (half axes)
  times its size, shrinking 40 % at the apex, so the arc's height reads from above. The shell uses its
  `projectile_k` at the scorch's 35 % ink; the small molotov bottle uses `BOTTLE_SHADOW_K` 0.8 (about 1 m across,
  0.6 m at the apex) at 60 % ink (`BOTTLE_SHADOW_INK`), because at 0.55 and 35 % it vanished on cream. Before
  iteration 10 the bottle cast a fixed 28 x 12 px dash, the same in pixels at every zoom.
- **Bottle bursts** (`WeaponFxArt.FIRE_BURST_TICKS` 10, iteration 14, gunplay REQUEST 31): a splash whose own fire
  patch lies under it (patch radius = splash radius, so the molotov and not the rocket or the nuke) plays only the
  blast sheet's inked star, held 10 ticks and fading over the last 5, then the fire patch carries the burn. The
  rocket's grey smoke ring and its last frame (a ring of cream discs) read as debug beads over the fire.
  `--fire-burst=off` is the before.
- **Bottle glass** (`WeaponFxShell.glass`, `GLASS` 7 shards, `GLASS_M` 0.8 m, `GLASS_TICKS` 16): the burst flings the
  shard cell (cream sliver in ink) from half the splash radius out to 1.1 of it, easing out and spinning, fading over
  the last third. Angles come from the burst's place (replay-stable). 0.45 m read as hairlines at 48 px/m.
- **Rocket blast tail** (iteration 14): the blast sheet's last frame (a ring of cream discs) read as debug beads, so
  the smoke ring (frame 2) holds through the last 10 ticks instead, growing from 1.08 to 1.30 and fading to 15 %.
  `--blast-beads=on` is the before.
- **Rocket blast tail, torn smoke** (iteration 20, replaces the held ring as the default): from tick 20 (the end of the
  smoke-ring frame) until the effect's 40-tick life ends, the ring tears into 12 of the rocket's drawn smoke puffs
  (`WeaponFxShell.wisps`). Each puff is 0.55 x the splash radius across, sits on the ring's line (0.78 of the radius)
  and drifts out by 0.4 of the radius, easing out. Each stretches along the ring as it grows (an expanding ring tears
  into arcs), shrinks to 60 % and fades out. Angles come from the blast's place, so a replay draws the same smoke. A
  radial stretch was tried first and read as flower petals. `--blast-tail=ring` is the iteration 14 held ring;
  `WISPS` 0 also turns the tail off. A big blast caps a puff at 2.5 m (`WISP_MAX_M`) and tears into more of them, so the
  mini-nuke's 12 m ring breaks into about 32 puffs instead of 12 puffs 6.6 m wide that hid Rivet. The rocket (3.5 m,
  1.9 m puffs) is unchanged.
- **Mini-nuke shell** (iteration 20): the mini-nuke lobbed the rocket cell at 1.5x, so in flight it read as a big
  rocket. It now flies its own `nuke_shell` cell (`tools/art/nuke_shell.py`, procedural like the other FX cells, so no
  AI provenance line). The cell is a fat bomb from above: a round-bellied steel body, a boxed dark ring tail, a cream
  nose cap, and a vermilion hazard band (danger) with two ink stripes. Its silhouette is short, fat and square-tailed,
  never a dart. It flies on the same lob arc, shadow and exhaust lick (`WeaponFxShell.SHELLS`). `projectile_fx`
  `rocket` in the table, or `--nuke-shell=rocket`, is the before.
- **Fire patch ground** (`WeaponFxShell.patch_ground`, `PATCH_SCORCH_K` 1.0 at `PATCH_SCORCH_INK` 0.8): under a
  burning patch the scorch cell (the inked burst) spans the patch's diameter, its turn fixed by its place, fading
  with the patch, instead of gunplay's flat grey disc, which read as a debug circle under the flames. 0 = the disc.
- **Energy muzzle flashes** need no change. The pale star inside its 13 px ink ring reads on cream at 32 px/m.
- **Empty tubes** (`parts.empty` = `held_empty.png` for the rocket launcher and the mini-nuke): the held part
  with the striped warhead cut away just past the front band, and an inked open mouth. It uses the same canvas,
  and `part_grip_px.empty` = `grip_px`, so `make_held(id, "empty")` lands exactly on the loaded tube. A view shows
  it from the shot until the reload's load phase (rivet-arsenal REQUEST 11).
- Generators: `tools/art/bullet_tracer.py <fx_dir>` (tracer, nail) and `tools/art/empty_tubes.py <art_dir>`.

## Held guns at gameplay scale (iteration 12)

In the claw at 32-48 px/m the four kinetic guns printed as the same dark ink lozenge (iteration 10 finding). The
cause is tone, measured at the print's real scale: at 48 px/m `print_part.gdshader` posterizes a part to solid ink
from an ink density of about 0.43 (luminance about 140). The held guns' body tones sit at a median luminance of
101-123. Rivet's own D4 parts sit at 180-200. So the gun's body went solid and took its inner shapes with it.

- **`parts.small`** (`held_small.png`, every held weapon but three): the held part on the same
  canvas, re-toned into Rivet's tone budget. The darkest ink (luminance 52 and under: outlines, bores, slots) is
  kept as drawn. The body's median lands at 186, at 0.45 of its drawn spread, by an additive shift, so the rust
  keeps its red lead and never crosses the vermilion gate. A 9 part-px ink edge runs along the silhouette (about
  1 screen px at 48 px/m). What survives the print: the hand cannon's drum bands, the machine pistol's side feed
  box, Gloria's rear bulb and long barrel, and the pistol's slide.
- **Not re-toned:** the molotov and the plasma sword print light already, and the flamethrower's thin wand
  prints darker re-toned (the ink edge swallows it). The print sim measured every held part at 48 px/m first:
  54-88 % solid ink for the rest. The rocket launcher and the mini-nuke also get `parts.empty_small`
  (`held_empty_small.png`, lifted by the loaded tube's median so both tubes match).
- **The swap** (`HeldLod`, a Sprite2D that `make_held(id)` returns when the row has `parts.small`): it draws the
  small cell while `PartMaterials.view_px` (the print's own zoom) is under `held_small_below_ppm` (56, the zoom
  where RigDetail's D5 tier switches on). At 64 px/m and closer it draws the full art. The paper rim swaps with it.
  `--held-small=off` keeps the full art at every zoom (A/B). A view that sets the texture to a full art (the
  empty tube from rivet-arsenal's HeldTube) is mapped to its small cell: HeldLod runs at process priority 20,
  after the claw view.
- **Gloria is two-tone, not re-toned** (iteration 13): re-toned pale, she printed as the pistol's twin at
  32 px/m (the same pale lozenge with inner marks; her tank sits behind the grip, against the claw). Her cell is
  ink with the drawn cream tape and plate kept as paper (source luminance over 170), so the pistol reads as the
  pale gun and Gloria as the dark banded one. Both tones sit outside the print's wash band (it12's tone-target
  measure). `TWO_TONE` in the generator. Measured in the arena pit: `it13-held-gloria-two-tone-ab-arena-pit-32ppm-3x.png`.
- **Printed like a limb (call 14 C) was tried and rejected** (iteration 13): with the LIMB print kind at
  32 px/m every held gun turns into a grey sticker in the arm's own tone. It reads as a third forearm, the hand
  cannon's drum and Gloria's tip are gone, and only the machine pistol's T survives
  (`it13-held-call14-AC-kinetic-arena-pit-32ppm-3x.png`).
- The pickups, the HUD icons and the weapon wall are unchanged: they print flat at their own size.
- Generator: `tools/art/held_small.py <art_dir> [ids]`. `--sim <out.png>` previews the print offline (box
  minification + the shader's D4 thresholds) before a Godot run: `it12-held-small-print-sim.png`.

## FX cells (`features/combat/weapons/art/fx/`, procedural, seeded: `tools/art/weapon_fx.py`)

`flash_pistol_0..2`, `flash_smg_0..2`, `flash_tube_0..2`, `flash_energy_0..2`, `flash_nuke_0..2`,
`tracer`, `casing`, `rocket`, `plasma_bolt`, `shard`, `ray_ring_0..2`, `smoke_0..2`, `flame_0..2`,
`arc_0..2`, `spark_0..2` (also the chain-arc landing and the stun daze: `WeaponFxElectro`). Each has `anchor_px`: the point placed on the muzzle (flash) or the head (projectile).

## Pipeline (re-run any step; all deterministic except the Codex call)

1. Codex `image_gen` (one at a time, `gtai-n4/image.lock`): a side sheet, then the same props redrawn
   top-down with the side sheet attached. Keep weapon nouns out of the prompt ("scrap-built gadget
   props"): the first try with weapon names was refused (`moderation_blocked`).
2. `python tools/art/weapon_cut.py <sheet> <cols> <rows> <dir> <ids> [--icon]` keys the green and cuts.
3. `python tools/art/weapon_fx.py <fx_dir>`; `python tools/art/weapon_ingest.py <top> <side> <fx>`
   copies the parts, measures grip and muzzle, writes the table (canonical JSON).
4. `python tools/art/weapon_provenance.py <sheet> <edits> <files...>`: one row per AI file.
5. `python tools/art/weapon_sheet.py <out.png> [<concept>]`; the lineup:
   `<godot> --rendering-driver d3d12 --path project -s res://dev/weapon_art/weapon_lineup.gd -- --out=<dir> [--set=adv]`.
