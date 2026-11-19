# Rivet at native x1.5

The knock and get-up grid, bare-claw strike, base poses and four-frame walk now use 165 px source cuts at p70 and p55. The four-frame walk still plays with `--rivet-walk=4`. The default walk8 and run8 already use native art.

## Same-tick film at 64 px/m

Each pair uses the same pose, frame and world tick in a 300 × 300 framebuffer crop. Crop difference counts pixels where any RGB channel changed. Silhouette height and boot row come from subtracting a third capture at the same tick with only Rivet's card transparent. A pixel enters the silhouette when any channel differs by at least 24/255. The boot measurement uses the visible boot's columns so a low claw does not count as a foot. Collar displacement tracks the centroid of the bright orange stripes inside a fixed neck rectangle. The raw crops, transforms, background captures and recorder are in the [masters folder](<C:/Users/kazda/kiro/gtai-masters/n19/anim/rivet-x15/>).

| Strip | Pitch | PNG at 110 → native | Frame / tick | Changed crop | Height, px | Boot row, px | Collar Δx / Δy, px |
|---|---|---|---|---:|---:|---:|---:|
| Knock, kneel | p70 | 990×792 → 1485×1188 | 14 / 280 | 11.92% | 126 → 126 | 199 → 199 | +1.7 / −0.6 |
| Knock, kneel | p55 | 1385×1108 → 2080×1664 | 14 / 280 | 14.96% | 135 → 135 | 200 → 200 | −0.2 / +0.5 |
| Claw strike | p70 | 489×1232 → 732×1848 | 8 / 1467 | 16.72% | 166 → 165 | 233 → 232 | +1.0 / −0.9 |
| Claw strike | p55 | 510×1112 → 765×1664 | 8 / 1467 | 18.59% | 164 → 164 | 223 → 223 | +0.5 / +0.3 |
| Base, standing profile | p70 | 2296×124 → 3444×186 | 2 / 120 | 11.89% | 160 → 161 | 192 → 192 | −0.5 / −0.2 |
| Base, standing profile | p55 | 1414×117 → 2128×176 | 2 / 120 | 8.34% | 153 → 152 | 204 → 204 | −1.3 / +0.1 |
| Four-frame walk | p70 | 428×1024 → 640×1536 | 3 / 184 | 14.66% | 151 → 150 | 208 → 208 | +0.3 / −0.2 |
| Four-frame walk | p55 | 400×984 → 600×1472 | 3 / 184 | 15.15% | 159 → 159 | 208 → 208 | +0.1 / −0.3 |

- **Knock and get-up.** The kneeling boot sits in the same place by the car. The chipped dome, claw tip and collar rim resolve more clearly. The band keeps its rigid shape under the helmet. Impact, tumble and slide are also in the masters at ticks 200, 215 and 240. [Still](<C:/Users/kazda/kiro/gtai-masters/n19/anim/rivet-x15/knock_t280_64ppm.png>) · [2×](<C:/Users/kazda/kiro/gtai-masters/n19/anim/rivet-x15/knock_t280_64ppm_x2.png>)
- **Strike.** The follow-through reads at the same extension. The wrist plates, helmet seam and rigid collar stripes separate more cleanly at both pitches. The p70 front sole is one row higher. [Still](<C:/Users/kazda/kiro/gtai-masters/n19/anim/rivet-x15/strike_t1467_64ppm.png>) · [2×](<C:/Users/kazda/kiro/gtai-masters/n19/anim/rivet-x15/strike_t1467_64ppm_x2.png>)
- **Base.** The ear plate, shoulder edge and cracks in the helmet gain definition. The bolt-on collar keeps its position relative to the ear. The p55 boot initially moved four screen pixels. Accounting for the old and new four-texel BC block padding during packing restored it to row 204. [Still](<C:/Users/kazda/kiro/gtai-masters/n19/anim/rivet-x15/frames_t120_64ppm.png>) · [2×](<C:/Users/kazda/kiro/gtai-masters/n19/anim/rivet-x15/frames_t120_64ppm_x2.png>)
- **Four-frame walk.** Both boots meet the same road mark. The visor slit, wrist cuffs and collar edges separate more clearly. The helmet still rises by the original four-frame bob calculation. [Still](<C:/Users/kazda/kiro/gtai-masters/n19/anim/rivet-x15/walk_t184_64ppm.png>) · [2×](<C:/Users/kazda/kiro/gtai-masters/n19/anim/rivet-x15/walk_t184_64ppm_x2.png>)

## Reproduction

Run `py -3 -I evidence/rivet-x15/reproduce.py` at the repo root. It recuts from the keyed library into scratch and compares the PNG bytes against the committed LFS SHA-256 for each pitch. All eight 110 cuts match `e0a504451`. The eight native cuts match `4b31b3b3c` using the same inputs. Cells round to whole texels before assembly.

The knock uses the original walk8 tone reference from `738de8ddd`, with length multipliers 1.2 and 1.45. Its fifth column comes from the get-up kneel source. The strike registers each facing on the collar of its walk8 source. The base uses the two `rivet_frames` rows of the frames manifest. The four-frame p55 walk needs the archived left cells in `_raw/rivet_walk_55_left_cells_v2untoned`. The later tonematched delivery changed 39,740 pixels across the three left rows at 110.

The city film uses `car_knock_clip` at fixed 60 fps, zoom 2, with the car impact at tick 196 in both views. The arena film uses `cursor_sweep` at 64 px/m on the pad. The recorder takes the actual sprite and transform at frame-post-draw. The background pass hides the card in frame-pre-draw. Run `py -3 -I evidence/rivet-x15/measure.py C:/Users/kazda/kiro/gtai-masters/n19/anim/rivet-x15` to repeat the table measurements.

## Remaining art

The remaining 110-space weapon strips belong to lane guns. At both pitches these include plasma sword and electro baton (facings, drawn lefts, wind-ups and strikes) and the flamethrower diagonal. The p70 right katana wind-up also reads at 1×. The p55 katana and chainsaw sets include their left and action variants and the katana thrust/recovery pair.

HidePeek sizes its bin card from the dumpster, and the flat-view peek token uses QuestArt dimensions. The head and bust cards are part-based rig fallbacks. These use separate sizing paths. The look goldens select the top view, whose art key is empty and whose upright cards are disabled.
