# Quest 1 (collect-call) art, D4 "Ink and Hatch"

Replaces the flat placeholder shapes of quest 1's view (`boot/collect_call/view/stage_view.gd` on
`main`). Seen straight down. Sizes are the footprints the placeholder view already draws, so a swap
keeps the layout. Night lane d4-production, 2026-11-03.

| File | Footprint (m) | px | Replaces | Notes |
|---|---|---|---|---|
| `tuckin_crate.png` | 1.8 x 1.4 | 144 x 112 | `_crates()` box + `_bolt_robot()` + the "TUCK-IN" label | The robot head with the bolt through it is the stencil. Vermilion on the bolt only (an objective). |
| `tuckin_crate_hit.png` | 1.8 x 1.4 | 144 x 112 | the same crate while `stage.crates_burning` | Cracked lid, scorch hatch, half-burnt stencil. The fire stays FX (`fx_view.gd`). |
| `cash_taped.png` | 1.4 x 0.8 | 112 x 64 | `_cash()` box + the vermilion tape lines | Envelope + bill edge, two vermilion tape strips. The "$1,500" label can go. |
| `catwalk.png` | 4.0 x 1.2, tiles along x | 320 x 96 | the two 6 px lines at Dock 9 (y -15 / +15) | Repeats end to end every 4 m. |
| `dock_gate.png` | 4.0 x 0.7 | 320 x 56 | (no placeholder yet) | Closed sliding gate with hazard ends and a lock box, for Dock 9's gates. |
| `dock_floor.png` | 8 x 8, tiles | 768 x 768 | Dock 9's `_floor()` fill | Procedural (no AI pixels): 4 m slabs, saw-cut joints, a worn bay line. 96 px/m (F-13 ground). |
| `basement_floor.png` | 4 x 4, tiles | 384 x 384 | the Toner Room's `_floor()` fill | Procedural: 0.5 m low-contrast linoleum checker, ink grout. |
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
| `cast_dock_guard.png` | 0.9 x 0.9 | 108 x 108 | `_human(..., "G", facing)`: vermilion vest = threat. The patrol cops ("C") stay with the cop rig. |
| `cast_mertz.png` | 1.9 x 2.0 | 228 x 240 | `_mertz()` body boxes, cap, ribbon bars, "M". Keep the Robo-tazer, its cable and the charge tubes as code. |

Reuse from the city set (already D4): `features/city/art/props/payphone.png` (1.3 m) for `_phone()`,
`features/city/art/props/dumpster.png` (2.4 x 1.6 m in quest 1) for the hide spots.

To tile in `_draw()`: `draw_texture_rect_region()` per repeat (an import with repeat on also works).
A working local patch of the two views that draws all of the above and the
before/after frames of quest 1's own frame grabber are in the lane masters:
`gtai-masters/night/d4-production/q1_view_art.patch` (stage_view.gd + cast_view.gd), `before_q1/`, `after_q1f/`.
The patch is not committed here, because the view code belongs to the quest 1 owner.
