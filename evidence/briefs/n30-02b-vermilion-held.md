# n30-02b vermilion-held: the vermilion list for the art Rivet actually holds on screen (lane keys, analysis only)

**Commit within 25 minutes of launch, report and END within 35.** Work in `C:/Users/kazda/kiro/gtai-wt/n23-controls`
(branch `n30-keys`). No recolour, no image generation, no Godot. `python -I`. Stage per path; never amend, rebase, stash,
`git add -A/./-u`, `reset --hard`. Fix lint/format findings in your own edit and go on.

## Why
`fb93bfd25` (`evidence/n30-keys/vermilion_list.md`, scripts in `evidence/n30-keys/vermilion/`) classed vermilion parts on the
p70 SHOWCASE file per weapon. The owner sees the held art in play, and those files hold far more vermilion (mini nuke
`held_55` 6227 px, rocket launcher `held_55` 4527, homing shard p55 1126; n29 counted 56,649 vermilion px over the held art of
ray gun, electro gun, rocket launcher, mini-nuke). Extend the same method to the in-play art.

## Steps
1. Find which files the game draws while Rivet holds each weapon (read, do not edit: `project/data/tables/weapon_art.json`
   or the table the held art is resolved from, `project/features/combat/weapons/art/<weapon>/held.png`,
   `art/held_55/<weapon>.png`, and Rivet's strips `project/features/characters/art/view/{p55,p70}/rivet_eq_<weapon>*.png` /
   `rivet_{walk,run8}_eq_<weapon>.png`). Name them in the md.
2. For ray gun, electro gun, rocket launcher, mini-nuke, homing shard, flamethrower, machine pistol, gatling (the weapons with
   danger or heat parts in the list) and any other weapon whose in-play file holds >= 500 vermilion px: run the same
   component/part/class step on the in-play `held_55` file AND on one p70 Rivet strip cell holding it (a side-facing cell),
   reusing `comps.py` / `build.py` (extend, keep the old output identical). Where the warm body paint itself reads vermilion
   (a whole surface), class it **design** and say so.
3. Stills `C:/Users/kazda/kiro/gtai-masters/n30/keys/vermilion/<weapon>_held_4x.png` (same layout as the showcase ones) and
   `contact_held_4x.png`. Look at each still yourself before you write its row.
4. Append to `evidence/n30-keys/vermilion_list.md` a section `## In play (held_55 and Rivet's strips)` with the same two tables
   (per part; per weapon summary with "proposed (owner's yes)"), and a line per weapon where the in-play class differs from the
   showcase class. Commit: `evidence(keys n30): vermilion list for the held art and Rivet's strips`.

## Allowlist
`evidence/n30-keys/vermilion_list.md`, `evidence/n30-keys/vermilion/**`, `C:/Users/kazda/kiro/gtai-masters/n30/keys/vermilion/**`.
Everything else read-only. Forbidden: `JOURNAL.md`, `REPORT.md`, `docs/decisions.md`, any art or data file, other worktrees.
Other builders in this worktree own `p55/rivet_run8.png`, `rivet_run8_eq_molotov.png`, `evidence/n30-keys/collar_cells.md`,
`evidence/n30-keys/grid_molotov*`: do not touch, stage only your paths.

## Report
Commit hash, the in-play summary table, still paths, what you could not class.
