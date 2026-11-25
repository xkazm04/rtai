# n31 melee 02p3 part 3 - volumes after the drawn geometry (flag on), 01e after | 02p3 after

## How
- Hit side, re-run on `fc23cdf14` (parts 1-2) with the flag, headless, lane lock held:
  `node tools/melee/blade_volume.mjs --model --label=after-model-2 --game-flags=--melee-sweep`
  -> `evidence/n31-melee/01-volumes/after-model-2/` (exit 0).
- Drawn side: the re-render (`--label=after-2 --raw=after-2 --game-flags=--melee-sweep`) died on a parse error in
  another builder's uncommitted `features/combat/react/claw_marks.gd` (not this lane item's file), so the drawn
  side is 01d's after renders (`build/n31/01d/raw/after`, HEAD `bcd19ed2d` + flag) with 01e's body-free mask:
  `node tools/melee/blade_volume.mjs --label=after-2 --raw=after --hits=evidence/n31-melee/01-volumes/after-model-2 --out=evidence/n31-melee/02-sweep/volumes/after-2 --no-render` (exit 0).
  Caveat: with the flag `RivetSwipeView` draws the crescent at the hit's `reach_m` where a strike cell has no
  arc of its own (the baton at facing 0 per 01e); the baton's reach 1.5 -> 2.2 grows that crescent, which 01d's
  renders do not show. A re-render is owed for the baton once the tree parses.
- `before_after.png`: rows claw, chainsaw, baton, katana, plasma; left 01e after (`../<weapon>.png`), right this.
  Blue = hit-not-drawn, red = drawn-no-hit; the grey wedge is the plot's cone_dot sector, NOT the clamped sweep.

## Bars (facing 0, front of him = -90..+90 deg of the aim): in-cut drawn-no-hit 0, hit-not-drawn <= 3 of 60, mover <= 1 of 14

| weapon | 01e after: in-cut dnh / hnd / mover | **02p3 after** | bar | cells left |
|---|---|---|---|---|
| claw | 1 / 5 / 1 | **1 / 1 / 1** | MISS by 1 (in-cut) | dnh -60/2.0 (needs reach 1.55, which hits 0 and +-30 at 2.0 m undrawn); hnd -90/0.8 |
| chainsaw | 4 / 0 / 0 | **4 / 0 / 1** | MISS by 4 (in-cut) | dnh -90/0.8 -90/1.4 -60/1.4 -60/2.0: the saw drawn swinging in from its windup pose (-124..-36 deg) on the first cut ticks; covering it means lo -100, which raises the saw's guard back past +15 % |
| electro_baton | 5 / 3 / 1 | **0 / 2 / 0** | PASS | hnd 60/2.0, 30/2.6 |
| katana | 1 / 8 / 0 | **0 / 3 / 1** | PASS | hnd 30/2.0, -60/2.6, -30/2.6 (the far blade is a narrow tip) |
| plasma_sword | 1 / 8 / 0 | **1 / 1 / 0** | MISS by 1 (in-cut) | dnh -60/2.0 (lo -48 leaves it just out; lo -55 would take it and add -60/2.6 undrawn); hnd -30/2.0 |

Behind him (report, not a bar; strike-arm / shoulder leak, 01e): in-cut dnh claw 8, saw 4, baton 7, katana 5,
plasma 9 (was 3: the clamp drops the plasma's hits behind him at 120-150 deg, 0.8-2 m, which its body-cut mask
still reads as drawn). Whole-ring numbers in `table.md` (dnh / in-cut / hnd: claw 9/9/1, saw 18/8/0,
baton 9/7/2, katana 11/5/3, plasma 14/10/1).

## Verdict
Baton and katana meet every bar; hit-not-drawn is inside the bar for all five (was 5, 0, 3, 8, 8 -> 1, 0, 2, 3, 1).
Claw and plasma miss the in-cut bar by one cell each and the chainsaw by four (its windup swing-in). Parts 1-3 do
not all meet the bars: the flag stays OFF (no part 4 in this call).
