# Brief 12 (lane anim, tag level-honest, --resume): make Tonnage's Planted feet level one honest number

## Machine law
Same as brief 11 (APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/anim, one Godot, stage per path, no stash/add -A,
`node tools/gate/quick.mjs --no-godot` before the commit). Docs only: no code, no art. TIME BOX: committed by 06:08 wall clock (`date`); this call is killed at 06:16. Your brief 11 says all 16 rows are under 9 px, so step 1 raises the lead to 3. Skip the optional Rivet measure.

## Problem
`LEVEL.md`, row `| Planted feet`, Tonnage column: the cell still OPENS with level `2`, then claims "Level 4 for the p70
right-profile walk", "Level 4 for the p70 left-profile walk", "Level 4 for the four p70 three-quarter rows", "Level 4 for
both p55 profiles". One cell = one level. And 4 means "past today's Rivet": no Rivet number on the same hold-ride
measure exists in the row (Rivet's cell is "3, stretch from the feet + flight lift"), so 4 is not evidenced.

## Do
1. Read your brief-11 table (`evidence/tonnage-hold/holds_it4.md`). If EVERY Tonnage walk row is now measured under 9 px
   at 32 px/m (p70: both profiles, four 3/4 rows, straight toward and away; p55: both profiles, four 3/4 rows, straight
   toward and away): change the cell's leading number from `2` to `3` with `(n19 anim, 2026-11-19: every walk row,
   both pitches, worst hold < 9 px@32, holds_it4.md)`. If any row is unmeasured or over 9, the lead stays `2` and the
   text names the row(s) that keep it there.
2. Replace each "**Level 4 for ...**" phrase with "**meets the < 9 px bar for ...**" (keep the numbers and links).
   Do not claim 4 anywhere unless you measure Rivet's walk with the same `measure_rows.py` hold-ride measure at 32 px/m
   and Tonnage beats it: if you have time inside the box, measure Rivet's p70 walk right profile and append the
   number to the Rivet cell (a number, no level change); otherwise do not.
3. Check the other cells your night's commits touched (Ohm combat feel, Dent/Ohm hit cells, Kerf planted feet) for the
   same pattern (a sub-claim that contradicts the lead number); fix wording only, do not raise anything.
4. One commit `docs: one level per LEVEL cell for Tonnage planted feet`. Final message: the diff of the lead numbers.
