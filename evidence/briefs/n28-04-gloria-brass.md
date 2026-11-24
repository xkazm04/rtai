# Brief n28-04-gloria-brass: Gloria pushed further (longer nail strip, brass body, one-handed): concept, held strips, held art

Lane `keys`, branch `n28-keys`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (your cwd).

**Check `date` first and often. Commit the concept + p70 strips by {COMMIT1}; p55 strips and held art by {COMMIT2}.
Report and END by {END} at the latest, whatever state you are in** (the pre-commit hook takes about 12 minutes on this
shared machine). Small commits, staged per path, `git commit -- <paths>`. No amend, no rebase, no stash, no `add -A/./-u`,
no `commit -a`, no `reset --hard`, never push. Fix lint and format findings in your own edit and go on. mutate: `--max=20`,
changed lines only, with a `--tests=` subset and a 10-minute budget.

Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/keys` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; anything that renders
`--rendering-driver d3d12`; windowed runs `--position 0,1440` (never the main display). One Godot process at a time in this
lane; free your own by PID, never by name. Never launch Godot raw: go through `tools/dev/run.mjs`, the film tools or
`tools/lib/godot.mjs` (8 GB RAM cap; `mem-budget: waiting` = machine full, not a hang). After new pngs land, a Godot
`--import` before the commit. If the pre-commit hook fails on `tools/film/kill_reel_*.break.test.mjs`: stale class cache,
`--import` and commit again.

## Why
Owner (last `DECISION n27 verdicts (owner)` line of `docs/decisions.md`): "push Gloria further (longer nail strip, brass body,
one-handed; concept A)". **Brass, not amber** (amber is fire, heat and electric current only). She must read apart from the
pistol at 64 px/m and at 32 px/m. She stays one-handed (pistol grip, the claw arm free) and keeps walking on the bare stride
with the gun in the palm until her own walk/run grid is drawn (a later call; not this one).

## What exists (read first; reuse, do not rebuild)
- n27 made her compact: `evidence/n27-keys/gloria.md` (p70) and `gloria_p55.md`, brief `evidence/briefs/n27-03-gloria-p70.md`,
  rounds `C:/Users/kazda/kiro/gtai-art/rivet-n27/gloria-concept/` (concept A = `gloria_compact_a`) and `.../gloria-p70/`
  (`mkrefs.py`, `cut2.py`, `install.py`, `weapon_art.py`, `rivet_muzzle_n27.py`, `STATE.md`) and `.../gloria-p55/`.
  Concept sheet: `C:/Users/kazda/kiro/gtai-masters/n27/keys/gloria_concepts_ab.png`. Re-run that pipeline with a new concept.
- Shipped files: p70 and p55 `rivet_eq_gloria{,_noflash,_diag,_diag_noflash,_left}.png`,
  `project/features/combat/weapons/art/gloria/{held,held_small,icon,pickup}.png`, `held_55/gloria*.png`,
  `art/showcase/p55/gloria.png` (and a p70 showcase if one exists), `weapon_art.json` gloria rows, `rivet_muzzle.json` gloria.

## Images: at most 12 in this call (count them, report `IMAGES n`)
Round `C:/Users/kazda/kiro/gtai-art/rivet-n28/gloria-brass/` with a `STATE.md` updated after every step (resumable).
1. **Concept (at most 3 images)**: an image edit of concept A (the take A row of `gloria_concepts_ab.png`, image 1) beside the
   shipped pistol row (image 2): the same three figures and poses; Gloria's body in **polished brass** (warm yellow metal with
   darker brass shading and bright highlights, not cream, not orange, not amber glow); the cream name plate may stay small;
   the **nail strip about twice as long**, straight, angled down in front of the grip, nails clearly visible as a comb; overall
   gun length about 1.3 to 1.5 times the pistol's, still one hand on a pistol grip, the claw arm free; the collar a rigid
   hazard collar. Bar: at 32 px/m (downscale the concept to the in-game figure height) her silhouette and colour differ from the
   pistol's at a glance: measure gun bbox length vs the pistol's and the mean hue of the gun pixels vs the pistol's (write both).
   Save the pick as `C:/Users/kazda/kiro/gtai-masters/n28/keys/gloria_concept_n28.png` (old long | n27 | n28 | pistol).
2. **Held strips (at most 6 images)**: as n27 did: p70 main/diag/left as image edits of the shipped pistol strips (image 1)
   with the n28 concept (image 2); then p55 the same with the shipped p70 n28 cells as image 2 so both pitches show one gun.
   Cut, register (head/torso IoU against the pistol cell as in `cut2.py`), tone the body to the pistol cell, flash from the
   pistol's own drawn flash at Gloria's new muzzle, re-measure `rivet_muzzle.json` gloria (p70 and p55), `rivet_gun_diag.gd`
   only if her barrel angle changed. The longer gun may need wider cells: say so and keep the body at the pistol's size.
3. **Held art (at most 3 images)**: `held.png`, `held_small.png`, `icon.png`, `pickup.png`, `held_55/gloria*.png`, the
   showcase png(s): cut from the strips or one edit of the shipped held/icon with the concept; full size (the icon and pickup
   fill their canvas like the pistol's do: compare bbox fill in %).
4. LOOK in the game at tilt 70 and tilt 55, 8 aim directions, fire (say which flag/setting selects tilt 55). Colour law:
   no red, no teal; brass is not amber (no orange glow on the body).
5. `--import`, provenance lines appended to `steam/ai-provenance/2026-11.jsonl`, `node tools/tests/run_unit.mjs --changed`,
   `node tools/gate/quick.mjs`, commit per step ("Gloria in brass with a longer nail strip: p70 held strips", ...).

## Evidence (after the commits; commit it separately)
- `C:/Users/kazda/kiro/gtai-masters/n28/keys/gloria_old_n27_n28_pistol_64.png` and `_32.png`: in the game, same tick, 4
  facings standing and firing: old long Gloria (from a temp worktree at `98cb0c396^` or the n27-start commit that still has
  her long art: find it with `git log --oneline -- project/features/characters/art/view/p70/rivet_eq_gloria.png`) | n27 compact
  (your start sha) | n28 brass | pistol. Temp worktrees: `git worktree add build/wt-<name> <sha>`, `git worktree remove`
  afterwards; never `git checkout <old> -- <paths>` here.
- A 15-25 s 32 px/m tilt-70 1080p60 clip: walking and sprinting in 8 directions on the bare stride with the gun in the palm,
  firing, `gloria_n28_32.mp4` (ffprobe in your report). A 64 px/m still `gloria_n28_fire_64.png`.
- `C:/Users/kazda/kiro/gtai-masters/n28/keys/frames.json` entries (append; keep existing ones). `evidence/n28-keys/gloria.md`.

## Allowlist (anything else: stop and report a NEED line)
p70 and p55 `project/features/characters/art/view/*/rivet_eq_gloria*`, `project/features/combat/weapons/art/gloria/**`,
`.../weapons/art/held_55/gloria*`, the showcase gloria pngs, `weapon_art.json` (gloria rows only), `rivet_muzzle.json` (gloria
only), `rivet_gun_diag.gd` / `rivet_cell_feet.gd` (gloria rows only), `tools/art/rivet_frames.json` (gloria entries), the tests
that pin gloria's muzzle/cells, `steam/ai-provenance/2026-11.jsonl` (append), `evidence/n28-keys/**`,
`C:/Users/kazda/kiro/gtai-art/rivet-n28/**`, `C:/Users/kazda/kiro/gtai-masters/n28/keys/**`, `build/**`.
Forbidden: the pistol's art (read only), the walk/run grids (`rivet_walk_eq_*`, `rivet_run8_eq_*`), `rivet_motion.json`,
`weapons.json`, other weapons, `project/features/combat/**` code, `project/boot/prologue/**`, `native/`, other lanes'
worktrees, `main`.

## Report (final message)
`IMAGES n`, the concept numbers (gun length vs pistol, hue), steps done, commit shas, stills/clip + ffprobe line, what
`STATE.md` says is next.
