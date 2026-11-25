# n30 combat call 18: the vermilion specks and outline on the blast floor (cause, fix, measure)

## What draws the floor
The amber "blast floor" is not a shape. It is frame 1 of the blast sheet, the PNG
`project/features/combat/weapons/art/fx/blast_1.png` (380 px: an amber burst with a cream star inside and an ink rim; the
amber is (232,159,42), with darker grain specks such as (199,136,36) and (171,117,30), and an anti-aliased amber->ink fringe).
It is drawn by `WeaponFxArt._blast_cells` (`project/features/combat/weapons/art/weapon_fx_art.gd:149-172`, frame 1 at blast
age 4-9, `BLAST_FRAMES` line 10) for every rocket and the mini-nuke (12 m, so at 64 px/m the cell is upscaled ~3.8x and
fills the screen). The nuke's own shapes (`fight_nuke_art.gd`) are only the `--weapon-fx=shapes` path; `rivet_blast.gd` and
`weapon_fx_shell.gd` do not draw it. At t520-580 the floor is gone (blast frames end at age 30; t520 shows only the fire ring).
So the floor is measured at **t484 and t486** (nuke, blast t478) **outside the light disc** (centre (1095,405), r 460 px
excluded: the light lives t478-513 and c17's rim patch was applied during the after take), and the rocket at **t70, t72**
(blast t64, no light: FlashBudget refused it).

## How the print turns its edge vermilion
`weapon_art.json` `fx_colour_dir` is "", so the cell is printed by the FX view's item print `look_d4_item.gdshader`
(`PrintStage.fx_material`, `amber_ink` 1 since n29): every opaque sampled colour snaps to its NEAREST ink in RGB among
CREAM, STEEL, INK, VERM (0.910,0.314,0.165), AMBER (0.929,0.671,0.259), TEAL. A dark orange-brown (any amber->ink blend
between about 25 % and 70 % ink, e.g. (170,118,36) or (130,93,33)) is nearer VERM than AMBER, INK or STEEL, so:
- the fringe texels of the rim and the bilinear samples between an amber and an ink texel print pure VERM: the outline;
- the darker grain specks inside the amber print VERM: the specks.
565 of the cell's texels snap VERM on their own and 6019 neighbour blends (snap model `snap.py`). This is why c07b's dark
amber-brown edge got worse: it moved the fringe INTO the vermilion cell. The `verm_gate` (`r - max(g,b) >= 0.31`) in
`palette_tokens.gd` / `grade_ink.gdshader` only counts and grades; it does not paint.

## Fix (ours: the cell art)
`blast_1.png` repainted by `evidence/n30/floor/fix.py <HEAD png> <out> half` (reproducible: md5 09269584ed8a5595db7fbae1e99bd44a):
- grain specks inside the amber that lie on the amber->ink line (2200 texels) -> the cell amber (232,159,42): the print
  snapped them to flat AMBER anyway, except the dark ones that went VERM;
- the fringe between amber and ink (1685 texels: blends touching the rim, plus amber texels touching it) -> a soot grey
  (128,118,118) at alpha 128. Amber->soot blends stay AMBER/STEEL, soot->ink blends stay INK, and where alpha < 0.75 the
  item print draws a translucent ink tint: a dark seam that joins the ink rim. Cream, ink and alpha elsewhere keep their bytes.
Model after: 1 texel and 0 blends snap VERM (`sim.py`: 9488 -> 0 VERM px at 3.8x, 281 -> 0 at 0.5x).

## Counts (64 px/m, `--chapter=rocket_launcher,mini_nuke --reel=director`, `count.py`)
Box: rocket (860,340)-(1340,760); nuke (380,0)-(1880,1080) minus the light disc and the HUD. vermilion `r-max(g,b) >= 0.31`,
red `R>170,G<110,B<90` (n29 is_red), amber hue 25-50 sat >= 0.45, teal `min(g,b)-r >= 0.26`.

| tick | before verm / red / amber / teal | after verm / red / amber / teal | verm that is blood-gated, after | px changed in box / outside |
|---|---|---|---|---|
| t68 (frame 0, blast_0: untouched) | 76 / 8 / 10554 / 0 | 76 / 8 / 10554 / 0 | - | 0 / 0 |
| t70 rocket | 1471 / 953 / 52416 / 0 | 531 / 0 / 51326 / 0 | 531 (all) | 2478 / 0 |
| t72 rocket | 1659 / 1069 / 55305 / 0 | 609 / 0 / 54147 / 0 | 609 (all) | 2667 / 0 |
| t484 nuke | 8173 / 8113 / 221887 / 0 | 181 / 88 / 213368 / 0 | 60 | 318517 / 0 (light disc incl.) |
| t486 nuke | 9231 / 9162 / 272195 / 0 | 164 / 63 / 262563 / 0 | 52 | 320216 / 0 (light disc incl.) |
| t520, t540, t580 (whole frame, fire ring) | unchanged | unchanged | - | 0 whole frame |

Vermilion that is not blood in the floor box: rocket 955 -> **0**, 1069 -> **0**; nuke 8140 -> **121**, 9196 -> **112**.
Of the nuke residue, 116 / 105 px were already vermilion before and are not the floor: the dropped assault rifle's red camo
(99 / 95 px at x 388-430, y 496-547) and a small flame sprite on a prop (x 1094-1103, y 894-901). **5 / 7 px are new**: dark
vermilion (134-164, 51-60, 33-35) where the soot seam crosses something under the floor's lower edge.
The rocket's remaining verm-gate px are the dead hostile's blood drops (blood-gated). Red: rocket 0, nuke 88/63 (the rifle and
blood). Teal 0. Amber -2.1 % (t70), -2.1 % (t72), -3.8 % (t484), -3.5 % (t486): the fringe px that were VERM or amber now
print as the seam. Px outside the box changed: 0 at every tick. The in-box change count at t484/486 includes c17's light disc.

## What I saw (`C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/nuke_floor_specks_pair_64.png`)
Before: a 1-2 px vermilion line runs along every amber/ink edge of the floor and the rocket burst, and 2-4 px vermilion dots
sit in the amber. After: no vermilion line and no dots; the amber floor is the same flat hot amber with its cream star and
heavy ink rim. The edge now has a ragged dark seam, 2-4 px at 64 px/m, slightly lighter than the rim where concrete shows
through (it reads as soot at the fire's edge, not as an outline colour). The rocket burst at 64 px/m reads the same apart
from the seam.

## Checks
- Unit: `node tools/tests/run_unit.mjs --select=<the 54 tests test_map.mjs reaches from blast_1.png>`: `unit-tests: 334
  passed, 0 failed, 0 skipped (GUT, headless)` (with c17's uncommitted light edits in the tree). `--changed` was not used:
  the diff held c17's paths too.
- Lint: `lint: all 19 checks pass over 2295 GDScript files`.
- `tools/godot/check.mjs` and mutate do not apply: no `.gd` changed (a PNG has no lines to mutate).

## Not done / for the Director
- `blast_0.png` (frame 0, ages 0-3) has the same fringe: 30 texels snap VERM (70 px at 3.8x in the model). The same
  `fix.py` would clear it; not applied here (no before take at t64-67 / t478-481, and t480 is inside the light).
- Root cause in the print (not ours): `look_d4_item` has no dark-amber ink, so every amber->ink blend crosses the VERM cell.
  A print-side fix (e.g. snap a pixel to VERM only when it is nearer VERM than the AMBER->INK segment) would cover every amber
  cell at once.

## blast_0 (c20)
Frame 0 of the blast sheet (ages 0-3, rocket and nuke) had the same snap: `snap.py` 30 texels VERM, 78 blends; `sim.py`
`{0.5: 0, 1.0: 30, 3.8: 70}`. `python -I evidence/n30/floor/fix.py <HEAD png> <out> half` (fix.py unchanged; its amber fits
this cell): 413 grain texels -> amber (232,159,42), 0 fringe texels (frame 0 is a cream burst with an amber star and an ink
rim, no amber->ink contact, so no soot seam is needed). Model after: 0 VERM texels, 0 blends, `{0.5: 0, 1.0: 0, 3.8: 0}`.

Takes (`node evidence/n29/red/take.mjs build/n30floor0/{before,after} 65,66,67,68 --rigs --bot=reel --reel=director
--loadout=pistol --chapter=rocket_launcher,mini_nuke --ppm=64 --clean --silent`; the take timed out after the stills at 240 s,
as c18's did). `import` run before the after take. Box (860,340)-(1340,760), `count.py` counts:

| tick | before verm / red / amber / teal | after verm / red / amber / teal | px changed in box / outside |
|---|---|---|---|
| t65 | 904 / 6 / 9373 / 0 | 898 / 0 / 9379 / 0 | 6 / 0 |
| t66 | 404 / 8 / 9741 / 0 | 396 / 0 / 9749 / 0 | 8 / 0 |
| t67 | 185 / 5 / 10157 / 0 | 180 / 0 / 10161 / 0 | 6 / 0 |
| t68 | 76 / 8 / 10554 / 0 | 68 / 0 / 10560 / 0 | 10 / 0 |

t68 is frame 0 here too (c18 saw it unchanged by the blast_1 fix). Every changed px is a vermilion speck (227,78,41) inside the
amber star that is now amber (232,168,65); one at t67 was amber->cream. Vermilion that is not blood: 6 / 8 / 6 / 10 -> **0**
(the remaining verm-gate px, 898 / 396 / 180 / 68, are the dead hostile's blood drops: mean (159,5,9), x >= 1251, R <= 170).
Bars: floor vermilion 0, red 0 added, teal 0, amber +0.06..0.10 %, outside the box 0.

What I saw (`C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/rocket_blast0_specks_pair_64.png`): before, 5-6 isolated
orange-red 1 px dots in the flat amber star; after, a clean amber star. Nothing else on the burst moved. The effect is small
(frame 0 has no fringe problem); the 70 px at 3.8x were the grain, and at 64 px/m they are 6-10 px.
Unit: `unit-tests: 334 passed, 0 failed, 0 skipped (GUT, headless)` (the 54 tests `test_map.mjs` reaches from blast_0.png).
Lint: `lint: all 19 checks pass over 2294 GDScript files`.
