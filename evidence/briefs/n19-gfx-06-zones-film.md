# Follow-up (resume): item 1's films still do not show the mix. Short package, ~20 min.

Director review of item 2 (far cops): ACCEPTED (b9cddfe91, ca6438e84). Thank you.

Item 1's second films (`zones/districts2-*.png`, `de01ecf7c`, `project/dev/view/zone_traffic_film.gd`) are framed and labelled, but they still do not let the owner see "docks differ from downtown" in ten seconds:
1. The label counts only MOVING cars (9 per panel). The queued cars of a jam are traffic too and are left out; parked kerb props must stay out.
2. One tick is noise: docks after reads Van 1, Pickup 2, Sedans 6, which looks like downtown's 6 sedans.
3. The docks camera does not read as docks: no warehouses, no quay in frame.

## Do
- Label = every spawned traffic car in frame at that tick (moving + queued/stopped), NOT the generator's kerb-parked props. Say in film.json how you tell them apart.
- Add a clip-wide census per panel: the sum, over every frame of the clip, of traffic cars in view per art (van / pickup / taxi / ambulance / sedans), printed as a second label line with the share of the dominant zone arts (e.g. `clip: vans+pickups 48% taxis 0%`). Write the numbers to `evidence/n19-gfx/zones/film.json` too.
- Docks camera deeper into the docks (chunks x 13..15; around x ~1856 m), placed so warehouses and/or the quay are in frame, on a road with traffic. Downtown camera where towers are in frame. Keep a still camera. Pick targets that are not one solid jam (traffic moving).
- Keep the film-only traffic raise as a dev-script flag (not game data).
- Re-shoot: `districts3-top.png`, `districts3-tilt70.png` (docks | downtown | mixed, after, same tick, 32 px/m), one before/after per district at the same tick (top and tilt 70), and a 10-40 s clip per district at 32 px/m (after). One 64 px/m close-up of the docks panel (vans/pickups readable).
- Look at each panel yourself before writing it: if docks and downtown do not visibly differ, move the camera or lengthen the clip, do not ship it.
- Delete the scratch dirs/panels in `C:/Users/kazda/kiro/gtai-masters/n19/gfx/zones/` that the new `frames.json` does not reference (the `districts-*`, `districts2-*`, `*2-*-before-after.png`, and the frame dirs no entry uses). Rewrite `frames.json` (8-15 entries, best first, `[{file,title,ppm,before,note}]`).

## Rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/gfx` before every Godot run; `--rendering-driver d3d12`; any windowed run `--position 0,1440`; one Godot at a time; kill only your own PIDs.
- Only dev script + evidence change. No game code, no digest. `node tools/lint/lint.mjs` green, `node tools/gate/quick.mjs` before the commit. One commit, staged per path. Debt baseline only through `node tools/debt/debt.mjs`.

## Report back
The commit, the per-panel tick counts and clip census numbers, every frame path in the new frames.json.
