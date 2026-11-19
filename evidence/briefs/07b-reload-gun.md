# Package 7b (guns lane, n19): reload cells must carry the gun's own art (director stopped 07 at 04:59)

I stopped your package 7 session to correct course before machine_pistol and hand_cannon. Your uncommitted electro_gun work is still in the tree; continue from it.

Looked at `gtai-masters/n19/guns/electro_gun/electro_gun_p55_reload_64.png` and a 2x crop of `rivet_reload_electro_gun.png` cell 1 beside `rivet_reload_plasma_rifle.png` cell 1 and `rivet_eq_electro_gun.png` cell 1:
- **Body: right.** It is the hand-made plasma reload figure. Keep it.
- **Gun: wrong.** The cell keeps the plasma rifle's wooden V stock and grafts on a pale grey, thin-line tube with antenna wires. The electro gun everywhere else is brass/gold with a copper coil wound on the barrel and a forked emitter (see `rivet_eq_electro_gun.png`, its `weapon_art.json` held art). At 64 px/m it reads as a different, unfinished gun.

Fix: in every electro reload cell (p55 + p70, right + left) the gun is the electro gun's own held art: composite its held texture (rotated/scaled to the plasma reload's gun pose by script, the same ink weight and shading as its held cells), remove every plasma stock pixel, and the swapped magazine is the electro `mag.png` you drew (an energy cell in the gun's own brass/copper colours; not vermilion; check it is not a grey sketch either). If a composite cannot sit in the hands, image_gen EDIT under a mask limited to the gun region with `rivet_eq_electro_gun.png` as the reference. Then machine_pistol and hand_cannon the same way on the hand-made pistol reload figure: their own held art, their own `parts.mag`.

Director sheet per weapon and pitch (required before each commit): 2x crop `base reload cell | new reload cell | the gun's own held cell`, cells 1, 5 and 7, to `gtai-masters/n19/guns/<gun>/<gun>_<pitch>_reload_zoom.png`. The gun must be recognisably the same object as in its held cell.

Everything else in brief 07 stands (mag view placeholder unreachable + test + Log fallback, mutate rivet_mag_view.gd, matrix_after_7, one commit per change).
