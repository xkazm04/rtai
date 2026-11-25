# n30-cast-21b: land the held-sole pin (door), then the pile-driver (tag `c21b`, model opus)

Read `evidence/briefs/_common.md` first: it binds. Then `evidence/briefs/n30-cast-21-held-sole-pin.md` (the item) and
`build/look/n30-c21/NOTES.md` (c21a's measurement). Launch time T. Door commit by T+20. Hard stop T+45 and no later than
17:12 (report and END). Never end with finished uncommitted work; never leave a commit in the hook at your stop.

## State
`build/look/n30-c21/fix.patch` (+3/-1 in `foe_shield_card_view.gd` `update_fighter`: pin the planted sole on a held walk
cell). c21a measured it (`cast_door_films.mjs ... feet`): the FOUR (what ships) p70 R 2.42/4.34 -> 0.00/3.41, p70 DR U/10.50
-> U/10.39, p55 R 2.03/5.09 -> 0.00/4.07, p55 DR U/10.43 -> U/9.66; the eight 0.00 sole everywhere, jumps p70 R 6.61 ->
7.95, p70 DR 11.999 -> 12.036 (0.04 over the bar), p55 R 6.98 -> 5.03, p55 DR 11.78 -> 11.77.
DIRECTOR DECISION (16:08): ship it for the four (every shipped number better, sole slide gone); the eight does not ship
(WALK stays FOUR: p70 down-right jump 12.04 > 12, so no WALK switch).

## Do
1. `git apply build/look/n30-c21/fix.patch`; `node tools/tests/run_unit.mjs --select=test_cast_door_walk,test_cast_foe_walks`
   green (if a test pins the old pivot pin, update it to the sole pin and say so); `node tools/gate/quick.mjs`.
2. Evidence (a slide is motion: c21s found one 64 px/m frame before | after looks identical, `build/look/n30-c21s/`):
   (a) a 32 px/m before | after CLIP of the door four walking, same ticks, 15-25 s, 1920x1080 (each half a 960 crop),
   masters `door_sole_pin_32.mp4` (ffprobe); (b) a 64 px/m strip `door_sole_pin_64.png`: 4 consecutive frames of ONE held
   drawing, 2x crops around the planted boot, before row over after row, so the drift is visible. LOOK at both. Replace
   `door8_edits_64.png`'s entry in masters `frames.json` with the strip and add the clip only if an entry can go (cap 15:
   drop `war8_four_eight_32.mp4`, the harness pair, since `war8_live_four_eight_32.mp4` shows the same in the game).
   Unit tests already ran green on the patch (c21p, 16:10: 12/0): re-run them only if anything else landed since.
3. Commit (pathspec): `cast: door card pins the planted sole on a held walk drawing (not the pivot)`.
4. Mutate: `node tools/mutate/mutate.mjs --file=project/features/combat/squad/foe_shield_card_view.gd --max=6
   --lines=<the 2 changed lines> --tests=test_cast_door_walk,test_cast_foe_walks`; quote killed/(killed+survived).
5. Only if 1-3 landed by T+25: the same pin in `foe_war_card_view.gd` (`hold_foot`): measure
   `node tools/film/cast_war_films.mjs build/look/n30-c21/war feet four,eight` against Part A (eight sole 18.16 / 27.45 /
   20.91 / 23.86, jump 10.73 / 10.37 / 10.74 / 9.93); commit only if the eight (what ships) gets no worse on any bar.
6. Append "## Held walk cell pins the sole, n30" to `docs/art/cast-audit.md` (c20: sole y gap 0, the still line was the
   pivot y 168; the fix; c21a's table; the war result or "not tried"); commit (pathspec).

## Allowlist
As brief n30-cast-21. Not decisions.md (the director's builder appends it after you).

## Report
Commits, test lines, still path and what you saw, mutate score, war table or "not tried", every command's result line.
