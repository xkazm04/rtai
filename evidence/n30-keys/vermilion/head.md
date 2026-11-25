# Vermilion per weapon: danger or heat (n30 keys, analysis only, no recolour)

Owner's pick: weapon item art keeps its design colours; this lists the vermilion per weapon as danger (warheads, emitters,
warning stripes) or heat (to amber) for the owner's yes. Colour law: red = blood only; vermilion = danger, objectives, Rivet's
collar; amber = fire, heat, electric current. Nothing was recoloured, no art file was touched.

## Method

- Input: n29's `evidence/n29-keys/held_red/table.md` (127 files). Vermilion = hue 9..24, s > 0.6, v > 0.6, alpha > 0 (same as `triage.py`).
- Weapons: every weapon whose art holds >= 50 vermilion px in any file (`vermilion/comps.py`). The crate (84 px in p70, wood grain) is not a weapon and is left out.
- File shown: the p70 showcase image per weapon (`showcase/p70/<weapon>.png`), except the assault rifle, which has only `assault_rifle/held.png`. Px counts are of that file. Other files of the same weapon (held_55, p55, icon, pickup) carry the same parts at other scales; a few hold far more vermilion in bulk (mini nuke held_55 6227 px, rocket launcher held_55 4527 px, homing shard p55 1126 px) because the same parts are drawn larger or the warm body paint reads vermilion there.
- Parts: connected components of the vermilion mask (dilated 2 px to merge), named by eye from the 4x crop (`vermilion/ids.py` draws the numbered boxes; `vermilion/build.py` holds the id -> part spec and makes the tables and stills).
- Classes: **danger** (warhead, live charge, warning stripe or decal), **heat** (coil, hot pipe, cable, burner: would go amber), **design** (a paint colour over a whole surface: keep), **speckle** (scattered wear, no part: no change).
- Stills: `gtai-masters/n30/keys/vermilion/<weapon>_4x.png` (left crop, right classed: danger white outline, heat amber fill, design grey hatch, speckle none) and `contact_4x.png`.
- Rebuild: `python -I evidence/n30-keys/vermilion/comps.py`, then `python -I evidence/n30-keys/vermilion/build.py`, from the worktree root.
