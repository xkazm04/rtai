# Quest 1 (collect-call) art, D4 "Ink and Hatch"

Replaces the flat placeholder shapes of quest 1's view (`boot/collect_call/view/stage_view.gd` on
`main`). Seen straight down. Sizes are the footprints the placeholder view already draws, so a swap
keeps the layout. Night lane d4-production, 2026-11-03.

**Since 2026-11-03 (slice-play) the views load this art by id** from
`data/tables/collect_call_art.json` (`QuestArt` / `core/data/art_ids.gd`), never by path. To swap a
file, change its row's `art`. The rig captures (`rivet`, `rivet_peek`, `cop`) also carry their
drawn size there (`size_m` x `draw_k`): a Rivet re-capture at the base form is the new file, its
`size_m`, and `draw_k` 1 (today 1.1 / 1.3 = 0.846154). An unknown id draws an ink square, no crash.

| File | Footprint (m) | px | Replaces | Notes |
|---|---|---|---|---|
| `tuckin_crate.png` | 1.8 x 1.4 | 144 x 112 | `_crates()` box + `_bolt_robot()` + the "TUCK-IN" label | The robot head with the bolt through it is the stencil. Vermilion on the bolt only (an objective). |
| `tuckin_crate_hit.png` | 1.8 x 1.4 | 144 x 112 | the same crate while `stage.crates_burning` | Cracked lid, scorch hatch, half-burnt stencil. The fire stays FX (`fx_view.gd`). |
| `cash_taped.png` | 1.4 x 0.8 | 112 x 64 | `_cash()` box + the vermilion tape lines | Envelope + bill edge, two vermilion tape strips. The patch drops the "$1,500" / "taped under" labels and the "PAYPHONE" label (the art carries them). |
| `catwalk.png` | 4.0 x 1.2, tiles along x | 320 x 96 | the two 6 px lines at Dock 9 (y -15 / +15) | Repeats end to end every 4 m. |
| `dock_gate.png` | 4.0 x 0.7 | 320 x 56 | (no placeholder yet) | Closed sliding gate with hazard ends and a lock box, for Dock 9's gates. |
| `dock_floor.png` | 8 x 8, tiles | 768 x 768 | Dock 9's `_floor()` fill | Procedural (no AI pixels): 4 m slabs, saw-cut joints, a worn bay line. 96 px/m (F-13 ground). |
| `basement_floor.png` | 4 x 4, tiles | 384 x 384 | the Toner Room's `_floor()` fill | Procedural: low-contrast linoleum checker, ink grout, paper grain. Iteration 14: the soft scuff blotches removed (they printed as cow-print mottling in every square behind the cast). |
| `cage_mesh.png` | 2 x 2, tiles, RGBA | 160 x 160 | the vault cage's 33 vertical lines | Procedural: 0.5 m chain-link diamonds in ink on transparent. Draw it over the floor inside the cage rect. |

## Cast (`cast_view.gd`)

Seen straight down, **facing -y (the top of the image)**: rotate by `facing.angle() + PI / 2`.
120 px/m at the gameplay footprint, cream sticker rim included. **Draw them at 1.5x the footprint
(the dock guard at 1.7x).** At 1x the thin robots (Juno's IV pole, Kilohm) and the guards read as
specks next to the placeholder boxes (`after_q1e` vs `after_q1f` in the lane masters). Teal is
neutralised (D4 doctrine: teal is the dead's), so the eyes are ink. The package design notes ask
for teal eyes, and that call belongs to the owner.

| File | Footprint (m) | px | Replaces |
|---|---|---|---|
| `cast_juno.png` | 0.8 x 1.2 | 96 x 144 | `_ally("Juno")` box + "J" |
| `cast_brass.png` | 1.6 x 1.2 | 192 x 144 | `_ally("Brass")` |
| `cast_kilohm.png` | 0.8 x 1.6 | 96 x 192 | `_ally("Dr. Kilohm")` |
| `cast_don_fax.png` | 1.8 x 1.1 | 216 x 132 | `_ally("Don Fax")` (incl. the vermilion dot) |
| `cast_dock_guard.png` | 0.9 x 0.9 | 108 x 108 | `_human(..., "G", facing)`: vermilion vest = threat. |
| `cast_mertz.png` | 1.9 x 2.0 | 228 x 240 | `_mertz()` body boxes, cap, ribbon bars, "M". Keep the Robo-tazer, its cable and the charge tubes as code. |
| `cast_guard_down.png` | 1.6 x 1.6 | 192 x 192 | a dead hostile's faint disc. Knocked out, lying face up. **No vermilion** (no longer a threat). Draw at **1x** with alpha 0.8 so the bodies stay quiet. |
| `cast_mertz_down.png` | 2.6 x 2.4 | 288 x 312 | the "shorted out" box + label. Sparking backpack, gloves re-inked. 1.5x, alpha 0.8. |
| `cast_rivet.png` | 2.37 x 2.07 (arms incl., centred padding) | 284 x 248 | `_rivet()` boxes, collar bar, eyes, "R" (not the hidden-in-crate peek). **A capture of the real Rivet rig, the n5-cast hybrid** (RivetPlan FORM_BASE, size_k 0.97, lanky + android parts; n5-cast iteration 20; was d5-cast's size_k 1.2 base form at 2.73 x 2.9 m) (idle, facing -y, 120 px/m, `dev/showcase/rivet_sprite.gd` + masters `n5/cast/tools/matte_centred.py` (crop symmetric about the rig root), cream rim `tools/sprite_rim.py` r 5); draw at **1x** (true scale). A stand-in until the quest view hosts the rig itself: re-capture if the Rivet parts change. Drawn above ~42 px/m; below it `cast_rivet_lod.png` stands in (`CastView._lod_art`). |
| `cast_rivet_lod.png` | 2.37 x 2.08 | 284 x 250 | Rivet below the rigs' flat-sticker threshold (`PartMaterials.flat_below`, about 42 px/m: the quest's 32 px/m), so the sprite Rivet prints what the rig Rivet prints there: the tan core, the welder-visor slot, the hazard collar's ink breaks, grey limb rods (n5-cast iteration 21). The same capture with `rivet_sprite.gd --tier=sticker` (rigs zoom hint 1.0 at 120 px/m: a supersampled 32 px/m print), cream rim r 5; **1x**. `CastView.LOD_SPRITES` false = the art captures at every zoom. |
| `cast_rivet_peek.png` | 0.97 x 0.97 | 116 x 116 | the hidden-in-a-hide-spot peek (`_rivet()` when `hidden_in` is set). A round cut (r 50 px) of the same capture around the welder-visor helmet + hazard collar, cream rim 4 px (masters `tools/rivet_peek.py`); drawn facing -y at the old peek spot. Below ~42 px/m `cast_rivet_peek_lod.png` (116 x 116, the same r 50 cut of the sticker-tier capture, rim 4 px) stands in. |
| `cast_cop.png` | 1.45 x 2.83 (gun arm incl.) | 174 x 340 | the patrol cops (`_sprite("cop")` while heat > 0; drawn even under `--rigs`). The slim patrol cop rig (n5-cast: size_k 1.0, look 5, Call 4 D bright crown over navy sleeves, gun out, aiming -y) captured the same way (`rivet_sprite.gd --kind=cop`), cream rim r 5, body centred; **1x**. Re-capture if the cop parts change (was the pre-slim 1.85 x 3.23 m capture). |

Reuse from the city set (already D4): `features/city/art/ground/road_straight_tone{,_b,_c}.png` for Harbor Road
(the band between the tile's edge lines, rows 20..748, scaled to the 5 m road, cycling the three variants), `features/city/art/props/payphone.png` (1.3 m) for `_phone()`,
`features/city/art/props/dumpster.png` (2.4 x 1.6 m in quest 1) for the hide spots.

To tile in `_draw()`: `draw_texture_rect_region()` per repeat (an import with repeat on also works).
A working local patch of the two views that draws all of the above and the
before/after frames of quest 1's own frame grabber are in the lane masters:
`gtai-masters/night/d4-production/q1_view_art.patch` (stage_view.gd + cast_view.gd), `before_q1/`, `after_q1p/` (final).
The patch is not committed here, because the view code belongs to the quest 1 owner.
