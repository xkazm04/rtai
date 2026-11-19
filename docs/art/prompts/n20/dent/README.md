# Dent · Ejected

The masters and tight cells are under `C:/Users/kazda/kiro/gtai-masters/n20/dent/`. Each raw filename is `masters/<sheet>_take<N>.png`. The prompt files contain the exact text sent to built-in image_gen. All raw sheets are 1536 × 1024.

## 70° flight and action references in input order

1. `C:/Users/kazda/kiro/gtai-masters/n20/concepts/dent_a.png`
2. `C:/Users/kazda/kiro/gtai-art/library/rounds/20261109-2015/out/dent_act_70.png`
3. `C:/Users/kazda/kiro/gtai-art/library/refs/camera_guide_70.png`

## Flight at 70°

`dent_sp_fly_70` shipped take 1 of 1, zero re-rolls. All twenty figures end at the belt in glass and teal light. The crown is less visible than on the 70° camera reference, especially in hover. The metal reads lighter and the plume is shorter than on the concept plate.

`ghost_pack.py --k=1` produced 269 × 236 px cells. Median figure height across all poses is 209.5 px. The profile hover head measures 91 px across the outline at its widest horizontal section (alpha ≥ 128). The five hover figures have a median height of 223 px. Both 70° proof boards use 86.4 / 223 game pixels per atlas pixel. Each contact board enlarges the 32 px/m rendering fourfold.

## Action at 70°

`dent_sp_act_70` shipped take 1 of 1, zero re-rolls. The twenty belt-up figures share the plate's cracked visor, coloured discs and seatbelt. The jab and the two-hand steering pose read differently in profile. The rear jab points slightly to the right of straight ahead.

The raw profile cock head was smaller than hover. `ghost_pack.py --match=240.4` (k = 1.097716894977169) produced 298 × 251 px cells with a median figure height of 238.5 px. Measured on the **packed textures**, profile hover and cock heads both span **90 px**, at scanlines 42 and 49 from the top of their tight alpha crops, respectively (alpha ≥ 128). The 91 px measurement above is on the flight cell before packing.

## Top parts

Input order for `dent_sp_top` was:

1. `C:/Users/kazda/kiro/gtai-masters/n20/concepts/dent_a.png`
2. `C:/Users/kazda/kiro/gtai-masters/n6/ghost-forms/gen/r2/out/dent_parts.png`

Shipped **take 1 of 3**. Take 1 repeated the waist buckle on the plume and drew four fingers plus a thumb. Re-roll 1 (take 2) retained both details and turned the glass into regular diamonds. Re-roll 2 (take 3) also retained both details. Take 1 had the clearest irregular glass shards. The cutter starts the tail immediately below the duplicate buckle. The open hand retains its thumb. The torso is deeper than the plate's top-view panel.

All six parts share a scale of 165 / 317. The raw 317 px head width sets the shipped width to the old sideways helmet's 165 px height. Tight dimensions in source reading order are 165 × 183, 270 × 187, 216 × 96, 190 × 101, 242 × 127 and 138 × 196 px. Median part height is 155 px. The assembly uses the same elbow and shoulder pivots recorded in `parts.json`.

## 55° flight and action references in input order

1. `C:/Users/kazda/kiro/gtai-masters/n20/concepts/dent_a.png`
2. `C:/Users/kazda/kiro/gtai-art/library/rounds/20261109-2205/out/dent_act_55.png`
3. `C:/Users/kazda/kiro/gtai-art/library/refs/camera_guide_55.png`

## Flight at 55°

`dent_sp_fly_55` shipped take 1 of 1, zero re-rolls. All twenty figures have the belt-up silhouette, cracked visor, crash-test discs and glass plume. The plate has a longer, more continuous trail. The forward dive is more upright in the front view than in profile.

`ghost_pack.py --k=1` produced 267 × 221 px cells with a median figure height of 201.5 px. The profile hover head measures 77 px on the packed texture at tight-crop scanline 38 (alpha ≥ 128). Median hover height is 212 px. Both 55° proof boards use 86.4 / 212 game pixels per atlas pixel.

## Action at 55°

`dent_sp_act_55` shipped take 1 of 1, zero re-rolls. The torso plates, strap and cracked visor match the plate. The generated tail is short, with angular shards, and the rear jab extends to the right of the body's facing. Each facing has four separate, legless poses.

`ghost_pack.py --match=201.1` (k = 0.9058558558558558) produced 237 × 216 px cells with a median figure height of 202 px. The packed profile cock head measures **77 px**, matching the **77 px** profile hover head. Both measurements use tight-crop scanline 38 and alpha ≥ 128.

## Rebuilding the proof boards

Run `py -3 -I tools/art/dent_spectral_cut.py cut MASTER CELLS`, then `py -3 -I tools/art/ghost_pack.py CELLS PACKED SCALE` with the scale option above. Run `py -3 -I tools/art/dent_spectral_cut.py board PACKED PREFIX HOVER_HEIGHT` with the pitch's median hover height. For the overhead sheet use `py -3 -I tools/art/dent_spectral_cut.py parts MASTER project/features/characters/art/dent/spectral evidence/a1/top_parts_board.png`. The cutter uses Pillow, NumPy and OpenCV.
