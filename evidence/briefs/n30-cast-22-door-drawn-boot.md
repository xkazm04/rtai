# n30-cast-22: the door four and eight measured on the DRAWN boot (tag `c22`, model opus, measure only)

Read `evidence/briefs/_common.md` first: it binds. Then `docs/art/cast-audit.md` "## Held walk cell pins the sole, n30"
(c21b's finding) and "## Door eight, p55 round 2, n30", and the scratch tools `build/look/n30-c21/c21b_clip.mjs` (renders the
door four as raw 1920x1080 movies through `runGodot`) and `build/look/n30-c21/c21b_holds.py` (band slide per held drawing).
Launch T = 16:30. Godot is NOT free until the final gate ends (lane lock tag `gate`, about 16:55-17:05): prepare everything
without Godot first, then wait for the lock (`( set -o noclobber; ... )` loop every 30 s, never delete the `gate` lock).
Renders done by 17:20. Audit section committed by 17:35. Hard stop 17:38: report and END.

## Why
The feet reader (`tools/film/cast_door_films.mjs ... feet`) tracks the REGISTERED sole point, about 7 screen px below the drawn
boot at 64 px/m. On the shipped four (p70 right) it reads a 2.42 sole while the drawn boot band slides only 0.86 / 1.65 px
(mean / max) inside the held drawings. The owner's door call (keep the four or take the eight) rests on the reader's p55 eight
soles 2.05 / 2.08 against a bar of 2. He should see the drawn boot instead.

## Do (no product file changes; no repo commit except the audit append)
1. One render per walk x pitch x facing at 64 px/m, 1920x1080, same ticks for four and eight: four and eight, p70 and p55, right
   and down-right (8 takes; as few Godot launches as the tool allows, one at a time under the lane lock). `CastDoorAnchors.WALK`
   is FOUR in the tree: for the eight, use the film tool's existing four/eight switch (as `cast_door_films.mjs` does) or a
   temp snapshot that changes only that constant (never edit the tree's file). Put scratch tools and frames under
   `build/look/n30-c22/` (adapt c21b_clip.mjs; go through `runGodot`).
2. Two numbers per take, measured on the DRAWN boot in the frames:
   (a) in-hold slide: the boot band's shift from the first to the last frame of each held drawing (c21b_holds.py method:
       SSD over +-10 px with a sub-pixel fit; find the boot band rows per take from the frames, say which rows);
   (b) contact slide: the planted boot's screen x from plant to lift across ALL drawings of one contact (track a patch around
       the planted boot's heel/toe, re-locked at each drawing change by the best match within +-12 px), max over contacts.
   Convert to the 32 px/m unit the bars use (divide by 2) and give both px units. Bars: sole <= 2 at 32 px/m.
3. LOOK at one frame per take (2x crop around the planted boot) and say what you see; save a 4-frame strip of the worst
   contact of the eight at p55 (the facing the owner's call is about) to `build/look/n30-c22/eight_p55_contact_2x.png`.
4. Append "## Door four and eight on the drawn boot, n30" to `docs/art/cast-audit.md`: method, the 8-take table (in-hold and
   contact slide, both units) beside the feet reader's numbers (four p70 R 2.42 / DR U / p55 R 2.03 / DR U; eight 1.96 / 1.39
   / 2.05 / 2.08), and one sentence: does the eight pass the 2 px bar on the drawn boot in every facing, and does it beat the
   four in every facing. Commit with pathspec: `audit(cast n30): door four and eight measured on the drawn boot`.
   Do NOT change `CastDoorAnchors.WALK` (the director decides from your table).

## Allowlist
`build/look/n30-c22/**`, `docs/art/cast-audit.md` (append only). Nothing else: no product files, no decisions.md, no masters
frames.json (you may copy the strip to masters only if the director asks). Anything else: NEED in the report.

## Report
The table, the verdict sentence, what you saw in the frames, the commit, every command's result line, anything not done.
