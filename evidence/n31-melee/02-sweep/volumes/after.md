# n31 melee 01e - drawn swing with Rivet's body cut out, before | after `--melee-sweep`

## How
- Renders: the SAME raw crops 01d rendered (`build/n31/01d/raw/{before,after}/<weapon>/`; before = game code of
  `ba8e470b0` in a temp worktree, after = HEAD `bcd19ed2d` with `--game-flags=--melee-sweep`). 01e changes only the
  mask (pure post-processing), so no new Godot run and no new temp worktree was needed:
  `node tools/melee/blade_volume.mjs --label=before --no-render` and
  `node tools/melee/blade_volume.mjs --label=after --raw=after --hits=evidence/n31-melee/01-volumes/after-model --out=evidence/n31-melee/02-sweep/volumes --no-render`.
  `volumes.json` `tree`/`head` of the before now name this checkout (the radius is read from its combat.json, 0.6 m,
  the same at `ba8e470b0`); the before's game code is still `ba8e470b0` (01d's render).
- Step 1 (body-only drawing of the same pose): none. `rivet_eq_<weapon>*.png` are full body + weapon sheets; no
  weapon-less strip holds the same strike cells, and the held view (`_nw`) only carries claw/baton/smear layers.
- Mask = 01d's clean mask, then `tools/melee/blade_volume_body.mjs` cuts per tick:
  - radius: ground point (the measure's gun-height projection) within `rivet.radius_m` 0.6 m of his centre at that tick (lunge included);
  - head: above his shoulder line (idle silhouette top + 36 px) inside his head column (idle x-span over the head rows +-6 px), moved with the lunge.
    Checked by painting the head-cut pixels on katana k1/3/5/8 and plasma k3/5/7/10 (after): they sit on the top of
    his helmet only, never on a blade; BUT plasma k7/k10 keep the right half of his helmet in the mask (the head box,
    anchored at the idle silhouette's top, misses it - cause not traced) and katana k1-k5 keep his back arm and feet; the rule is column-limited because a blade drawn high on screen AWAY from him is a real far cut (ring cells at 270 deg, 1.5 m+ sit up there);
  - floor (added, not in the brief): pixels whose colour matches the empty-arena `bg` frame - the floor his idle body covered and his lunge uncovered. It was a tall band along his back in katana/chainsaw (01d's strip diff flagged it) and projected onto the cells behind and north of him.
- What the cuts hide: a blade within 0.6 m of his centre (the 0.8 m cells' bodies reach 0.45 m, so their inner part is lost - this is why hit-not-drawn rises at 90/270 deg 0.8 m), and a blade drawn across his head on screen.
- What they still leave: his strike arm / back shoulder where the strike pose leaves the idle outline AND lies
  0.6-1.3 m from his centre in the projection (his torso band between the shoulder line and the radius projects
  0.6-1.3 m north). Seen in the overlays below. So drawn-no-hit behind him (120-240 deg, 0.8-1.4 m) is still partly body.

## Numbers (ring of 60 cells, facing 0; movers of 14)
drawn-no-hit all / inside the cut ticks, hit-not-drawn, mover drawn-no-hit. 01d = before the body cut (JOURNAL 23:31).

| weapon | 01d before | 01d after | **01e before** | **01e after** | bar |
|---|---|---|---|---|---|
| claw (hands) | 13/13, 0, 1 | 11/11, 5, 1 | **11/11, 0, 1** | **9/9, 5, 1** | in-cut 0, hnd <= 3, mover <= 0.7 |
| chainsaw | 25/18, 0, 3 | 18/12, 0, 0 | **23/13, 0, 3** | **16/8, 0, 0** | |
| electro_baton | 18/17, 0, 1 | 15/14, 3, 1 | **17/15, 0, 1** | **14/12, 3, 1** | |
| katana | 16/13, 3, 0 | 12/8, 7, 0 | **14/11, 3, 0** | **11/6, 8, 0** | |
| plasma_sword | 13/10, 8, 0 | 6/4, 7, 0 | **13/9, 10, 0** | **6/4, 9, 0** | |

Bars (5 % of 60 = 3 cells, of 14 movers = 0.7): drawn-no-hit inside the cut 0 - NOT met by any weapon before or
after; hit-not-drawn <= 3 - met by chainsaw, baton (3) after; claw 5, katana 8, plasma 9 miss; mover drawn-no-hit
- chainsaw, katana, plasma 0 after; claw and baton 1 (7 %).
Direction: the sweep lowers drawn-no-hit for every weapon (in-cut: claw -2, saw -5, baton -3, katana -5, plasma -5).

## Where the cells sit (angle off the aim, + clockwise on screen, 90 = screen down; distance m)
- hit-not-drawn AFTER: claw 90/0.8 270/0.8 60/1.4 90/1.4 270/1.4; baton 90/0.8 270/0.8 60/2; katana 90/0.8
  60/1.4 90/1.4 30/2 60/2 90/2 30/2.6 330/2.6; plasma 90/0.8 270/0.8 90/1.4 270/1.4 60/2 90/2 120/2 270/2 330/2.
  The 0.8 m side cells (90/270) are the radius cut's loss. The rest is real: the hit cone reaches sideways
  (60-120 deg, 1.4-2 m) where nothing is drawn - katana and plasma most (the sweep's sector runs wider than the drawn smear on the screen-down side).
- hit-not-drawn BEFORE: katana 60/2 60/2.6 330/2.6; plasma 90/0.8 270/0.8 90/1.4 270/1.4 60/2 90/2 270/2 330/2 60/2.6 90/2.6.
- drawn-no-hit AFTER sits behind him: claw 120-240/0.8, 210-240/1.4, 240-300/2; saw 90-300/0.8, 90-300/1.4;
  baton 150-240/0.8, 180-240/1.4, 0/2 30/2 0/2.6 (ahead, past the hit reach) 180-330/2; katana 120-240/0.8,
  150-240/1.4, 240/2, 0/3.2 (tip past the reach); plasma 180/0.8 150-180/1.4 0/2.6 30/2.6 210/2.6.
  Behind-him cells = windup smear + leftover strike-arm body (not separable by this rule); ahead cells
  (baton 0-30/2-2.6, katana 0/3.2, plasma 0-30/2.6) = drawn blade tip past the hit reach - real.

## Overlays (after, hit tick + 1; `overlay_body_<weapon>_k<k>.png`, before set in 01-volumes/before/)
- claw k4: outline on the claw arm (the weapon is his hand) and the small slash; his right body edge and a thin sliver on his left edge remain.
- chainsaw k10: on the saw and its sparks; only a thin line on his right shoulder remains. The back band (uncovered floor) is gone.
- baton k3: on the baton tip and the crescent below; his raised off-arm (top right of him) and a sliver of his left edge remain.
- katana k6: on the blade; pieces of his back shoulder/arm (strike pose outside the idle outline) remain; the back band is gone.
- plasma k8: on the plasma blade and its smear; his right shoulder/strike arm remains.

## Verdict input for the director
The body is OUT of the head and the 0.6 m core and the back band is gone, but the strike arm/shoulder still
leaks in at 0.6-1.3 m behind/north of him. Read "drawn-no-hit behind him (120-300 deg)" as an upper bound, and
"drawn-no-hit ahead (0-30 deg, past the hit reach)" plus "hit-not-drawn sideways at 1.4-2 m" as real geometry gaps
for 02p3's reach/sector choice (katana and plasma: the hit sector is wider sideways than the drawn smear; baton/katana/plasma
draw their tips past the hit reach).
Sheet: `before_after.png` (row = claw, chainsaw, baton, katana, plasma; left before, right after).
