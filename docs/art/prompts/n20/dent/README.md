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
