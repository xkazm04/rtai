# n31 melee 01d - drawn swing from pixels, CLEANED mask, before (game code of ba8e470b0)

Command: temp worktree `git worktree add --detach %TEMP%\gtai-melee-01d-base ba8e470b0` (+ `project/native/bin`,
`project/.godot` and the probe files `blade_pixels.{gd,tscn,gd.uid}`, `blade_tap.{gd,gd.uid}` copied in), then
`node tools/melee/blade_volume.mjs --label=before --tree=<that worktree>`; worktree removed after. Hit side = 01a's
`before-model/`. 01c's mask version: `before-01c/`.

## The clean mask (tools/melee/blade_volume_clean.mjs)

Each tick k is drawn twice with the sim held (no step between): full, then with Rivet's held view hidden (its children
are the held weapon, the swipe crescent and the smear). Mask = (a) full vs held-hidden: exactly what the held view drew,
UNION (b) held-hidden vs idle, minus his idle silhouette moved by his lunge (`poses[k]`) grown 4 px: what his strip cell
drew outside his body (katana, plasma, saw blades live in the cell), then (c) only 8-connected pieces (joined across
6 px) that come within 24 px of his moved silhouette. Tried and dropped: (a) alone for claw and baton: the baton then
draws NOTHING (its drawn baton is in the p55 strip cell, not the held sprite) and the claw draws only k 5.

| weapon | drawn-no-hit /60 (01c) | inside the cut ticks | hit-not-drawn /60 | mover drawn-no-hit /14 | p5..p95 deg / reach_p95 at hit+1 |
|---|---|---|---|---|---|
| claw | 13 (13) | 13 | 0 | 1 | -70..40 / 1.79 m |
| chainsaw | 25 (27) | 18 | 0 | 3 | -133..128 / 2.37 m |
| electro_baton | 18 (21) | 17 | 0 | 1 | -139..39 / 2.14 m |
| katana | 16 (19) | 13 | 3 | 0 | -133..130 / 3.13 m |
| plasma_sword | 13 (19) | 10 | 8 | 0 | -61..42 / 2.52 m |

## What the overlays show (before/overlay_clean_<weapon>_k<k>.png, hit+1 and last cut tick, facing 0)

- Gone vs 01c: the arena blobs ~3.3 m behind him and the comb of bars up-left (no outline on them any more).
- On the blade/swipe: katana smear arc + blade (k7, k10), plasma blade + its glow (k8), baton + crescent (k4), saw
  bar + sparks (k12).
- STILL on his body: the outline rings his head, shoulders and strike arm in every weapon (claw k5 is mostly body:
  the claw is his arm). His strike pose differs from his idle silhouette, so moving that silhouette by the lunge is not
  enough. The katana also keeps a thin arc left of his head (a drawn trail in the strip cell or his arm). These body
  pixels are the red cells around and behind him in `before/sheet.png`: the numbers above are still inflated.
- Repeated frames (01c item 3) RESOLVED as pose hold, not a stale read: byte-identical frames k/k-1 come with strike_t
  advancing (baton k 3, 4; claw k 7..9; plasma k 9; saw k 13), and every capture has its own held-view-hidden frame
  between them that differs. `<weapon>.json` `repeats` lists them.

Not done: (b) a per-tick body silhouette render (the body-only cell of that tick's pose); without it the body stays in.
