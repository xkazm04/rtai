# n30-02 vermilion-list: per weapon, which vermilion parts are danger and which are heat (lane keys, analysis only)

Launched ~11:16. **Commit by 11:45. Report and END by 11:55** (wall clock; check `date`). Work in
`C:/Users/kazda/kiro/gtai-wt/n23-controls` (branch `n30-keys`). Never amend, rebase, push, stash, `git add -A/./-u`, `reset --hard`.
Stage per path. **No recolour this run, no image generation, no Godot.** Python (`python -I`) on the PNGs only.

## Goal
The owner (verbatim pick): "weapon item art keeps its design colours, and the lane lists the vermilion per weapon as danger
(warheads, emitters) or heat (to amber) for the owner's yes (no recolour this run)". Colour law: red is blood only;
vermilion only for danger, objectives and Rivet's collar; amber for fire, heat and electric current; teal only for souls;
ice blue for enemy large rounds. Design colours stay (the mini-nuke's plum casing, the homing shard's hoses are not on the list
as recolours: name them "design colour, keep").

## Input
- `evidence/n29-keys/held_red/table.md` (127 files with R>170 G<110 B<90 px; vermilion = hue 9..24, s>0.6, v>0.6; and its
  `triage.py` beside it if present) and the contact sheet `C:/Users/kazda/kiro/gtai-masters/n29/keys/held_red/contact_4x.png`.
- Weapon art under `project/features/combat/weapons/art/` (`<weapon>/held.png`, `held_55/`, `showcase/{p55,p70,icon}/`, pickups).

## Steps
1. Group the files by weapon (ray gun, electro gun, rocket launcher, mini-nuke, homing shard, flamethrower, chainsaw,
   machine pistol, electro baton, assault rifle, katana, Gloria, ... every weapon whose art holds >= 50 vermilion px in any file).
2. Per weapon pick the most representative file (the held p70 showcase or held.png) and make a connected-component map of
   its vermilion px (hue 9..24, s>0.6, v>0.6, alpha>0): group them into named parts by position on the drawing (look at the
   crop yourself: tip, muzzle, emitter, coil, warhead, nose band, hose, trigger guard, speckle/wear ...).
3. Per weapon, per part: class **danger** (warhead, live emitter, live charge, a warning stripe), **heat** (coil, hot pipe,
   barrel glow, current -> would go amber), **design** (the part's paint colour over a whole surface: keep), or **speckle**
   (scattered wear, no part). Count px per part.
4. Per weapon one still `C:/Users/kazda/kiro/gtai-masters/n30/keys/vermilion/<weapon>_4x.png`: left the 4x nearest crop of the
   weapon, right the same crop with each vermilion part outlined/tinted by class (danger = white outline, heat = amber fill
   overlay, design = grey hatch, speckle = none) and a small legend. Plus `contact_4x.png` with all weapons, one row each.
5. Write `evidence/n30-keys/vermilion_list.md`: method, then ONE table: `| weapon | file shown | part | class | px | one line why |`
   and a short per-weapon summary table `| weapon | danger px | heat px | design px | speckle px | proposed (owner's yes) |`
   where "proposed" is e.g. "coil -> amber, emitter stays vermilion". Keep the script under `evidence/n30-keys/vermilion/`.
6. Commit the md + script: `evidence(keys n30): vermilion list per weapon, danger vs heat (no recolour)`.

## Owned files (allowlist; any other path: stop and report a NEED)
`evidence/n30-keys/vermilion_list.md`, `evidence/n30-keys/vermilion/**`, `C:/Users/kazda/kiro/gtai-masters/n30/keys/vermilion/**`.
Read-only: everything else. Forbidden to write: `JOURNAL.md`, `REPORT.md`, `docs/decisions.md`, any art file, other worktrees.
Another builder works in this worktree on `p55/rivet_run8.png`, `evidence/n30-keys/collar_cells.md` and Godot: do not touch those,
and stage only your own paths.

## Report (your final message)
Commit hash, the summary table, the still paths, what you were unsure about (parts you could not class from the crop).
