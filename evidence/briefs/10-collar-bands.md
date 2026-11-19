# Package 10 (guns lane, n19): clean collar bands on the mirror-based left cells

Director looked at `gtai-masters/n19/guns/gloria/gloria_p70_left_zoom.png` and `rocket_launcher/rocket_launcher_p70_left_zoom.png` (2x, mirrored source | shipped left). Helmet and gun ink now equal the source. The one remaining tell: **the re-slanted collar stripes are rough, broken strokes** (orange scribbles with gaps and stray dark specks, NW worst) next to the source's clean, evenly spaced bands with a solid ink edge. It does not show at 64 px/m, but it is the only thing that separates a corrected cell from a hand-made one.

Do, for every weapon built with `tools/art/left_from_right.py` (plasma_rifle, gatling, flamethrower, gloria, rocket_launcher, mini_nuke; p55 + p70; rest, fire, fire_noflash):
1. Rebuild the collar correction as a clean, scripted band: inside the collar mask, stripes as closed polygons in the source collar's own two colours (sample them), even spacing and width taken from the source band, slant reversed, the source's ink edge kept on top and bottom, no specks. Anti-alias only at stripe edges as the source does. No image_gen for this.
2. Also remove any stray specks/edges outside the collar that the correction left (2x sheets show a dark lip at the right shoulder of rocket p70 SW and speckle by the hose of rocket p70 W fire).
3. Re-cut, re-run `cell_metrics` (stay within the 06b thresholds), re-shoot every `<gun>_<pitch>_left_zoom.png` (add any missing) and the `_west`/`_nw` 64 px/m sheets.

Acceptance: as 06c (byte-for-byte reproducible cuts, audit count unchanged, unit `--changed`, Python tests, lint, quick gate; one commit for the tool change and one per weapon or one for all re-cuts). Report: per weapon, collar pixels changed, and which zoom sheets to look at.
