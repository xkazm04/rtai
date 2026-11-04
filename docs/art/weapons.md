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
   prints as a dark ink silhouette like Rivet's parts.
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
