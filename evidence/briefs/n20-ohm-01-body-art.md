# Brief n20-ohm-01: Ohm's new spectral body art (sheets, cut, jar masks). Art only, no game wiring yet.

You are building in `C:\Users\kazda\kiro\gtai-wt\n20-ohm` (branch `n20-ohm`). Tonight Ohm, one of four ghost
forms, is redrawn as a legless flying spectre, the "Lightning Rod". The owner picked the target plate:
`C:\Users\kazda\kiro\gtai-masters\n20\concepts\ohm_c.png` (open it first: hero, a top-down inset top right, the
attack inset bottom right). This package makes the sprite art and cuts it. Wiring it into the game comes in a
later package (it depends on the `flight` lane's shared hover code that is not merged yet). Do not edit any
`.gd` game file in this package.

## Environment (every Godot run)
- `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/ohm`
- `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`; one Godot
  process at a time; anything windowed gets `--position 0,1440`. Free your own processes by PID only.

## Read first (briefly)
- `AGENTS.md` (repo law; stage per path, no `git add -A`, no stash, no reset --hard, never push).
- How the current ghost art was made: `docs/art/weapons.md` (Pipeline section), `art_src/n19_move.manifest.json`
  (manifest format), the last lines of `steam/ai-provenance/2026-11.jsonl` (provenance format),
  `tools/art/ghost_pack.py` and `tools/art/ghost_parts.py` (how tilt grids and top-view parts were keyed, packed
  and scaled), `project/features/souls/ghost_sheet.gd` (grid convention: 5 facing rows toward / 3-4 toward right /
  right profile / 3-4 away right / away; left octants mirror), and the shipped Ohm art it replaces:
  `project/features/souls/art/view/p70/ohm_walk8.png`, `ohm_act.png`, `project/features/souls/art/ohm/*.png`,
  `project/features/souls/ohm_rig.gd` (top-view sizes in metres, `CARD_M`), `ohm_view.gd`.

## 1. Generate three images with your built-in image_gen, prompts VERBATIM
Use the prompts below word for word (the director wrote them; do not rephrase, shorten or add to them). Attach the
reference images in the stated order. If the image service reports a usage or rate limit, wait five minutes and
retry; meanwhile do the scripting below.

Reference files:
- R1 = `C:\Users\kazda\kiro\gtai-masters\n20\concepts\ohm_c.png` (the character)
- R2 = `C:\Users\kazda\kiro\gtai-masters\n6\ghost-forms\gen\r4\out\ohm_parts.png` (ink and fill style)
- R3 = `project/features/souls/art/view/p70/ohm_act.png` (the facing-row layout)

The STYLE paragraph is appended to the end of each of the three prompts, unchanged.

STYLE:
> Style: a sprite sheet for a shipped top-down action game, in a hand-inked comic print style: bold black brush-ink outlines around every shape, flat and lightly shaded fills, light cross-hatching, a hint of risograph print grain. Match the ink and fill of image 2, not its character. The background of the whole sheet is one flat, even chroma green (#00B140): no shadow, no gradient, no ground, no floor glow, nothing drawn on the green. The figure is a translucent glowing TEAL (#2EC4B6) spectre lit from within, the black ink linework visible through the glow, faint worn steel and rust inside it; only the two copper prongs of the staff keep their own copper colour. Every edge of the figure, including the misty hem, is closed by a bold black ink outline, so it stands cleanly off the green. Original design. No text, no letters, no numbers, no labels, no grid lines, no borders, no watermark.

### Image A: `ohm_spec_p70` (refs R1, R2, R3)
> Image 1 is the character to match: OHM, the Lightning Rod, a stooped old robot wizard who is a floating teal spectre: cracked round goggles, a short bristly cable-wire beard, riveted shoulder plates over a long ragged insulating coat of rubber sheets whose hem frays into teal mist and a few loose wires, NO LEGS AND NO FEET, three big glass capacitor jars in a row on his back joined by curling hoses, and in his right hand a tall staff that is a lightning rod ending in a FORKED tip of two copper prongs. Image 2 shows the ink, fill and print style of our game sprites: match that style, not its robot. Image 3 shows the layout of our character sheets: five rows, one per facing direction, the same figure in every row.
>
> Draw a character sprite sheet of OHM: a grid of 6 columns and 5 rows of equal cells, one full figure centred alone in each cell with green margin all round, every figure the same size and the same scale, all seen from a camera high above and in front, looking down at 70 degrees (a steep top-down three-quarter view: the top of the head, the shoulders and the tops of the three jars are clearly visible, the coat is foreshortened).
>
> Rows, top to bottom: row 1, he faces the viewer (toward the bottom of the page); row 2, he faces three-quarters toward the viewer and to the right; row 3, right side profile, facing right; row 4, three-quarters away from the viewer and to the right (we see his back and the jars); row 5, facing straight away from the viewer (his back and the three jars fully visible).
>
> Columns, the same in every row: column 1, hovering idle: stooped, the staff held upright beside him in his right hand, the coat hanging still into its misty hem; column 2, drifting forward: leaning forward from the waist, the staff held out ahead of him at an angle like a walking stick whose foot hangs just above the ground, the coat hem and beard streaming backwards; column 3, charged: standing tall, the staff raised high overhead in his right hand, the forked copper tip pointing up; column 4, the thrust: lunging forward, both hands on the staff, thrusting it straight out ahead at shoulder height, the forked tip foremost; column 5, recovery: hunched, pulling the staff back across his chest, the coat swinging forward; column 6, struck: thrown backwards off balance, head tipped back, the staff swinging away from him, the coat hem flaring forward.
>
> In every cell the insides of the three glass jars on his back are painted flat solid magenta (#FF00FF), an even placeholder colour with no glow and no shading, only inside the jar glass, wherever the jars can be seen from that angle. The hem of the coat ends in short ink-outlined teal wisps about a third of his height below the coat and never touches the bottom of the cell; there is nothing under him.

### Image B: `ohm_spec_p55` (refs R1, R2, then the accepted Image A as image 3)
> Image 1 is the character to match: OHM, the Lightning Rod, a stooped old robot wizard who is a floating teal spectre: cracked round goggles, a short bristly cable-wire beard, riveted shoulder plates over a long ragged insulating coat of rubber sheets whose hem frays into teal mist and a few loose wires, NO LEGS AND NO FEET, three big glass capacitor jars in a row on his back joined by curling hoses, and in his right hand a tall staff that is a lightning rod ending in a FORKED tip of two copper prongs. Image 2 shows the ink, fill and print style of our game sprites: match that style, not its robot. Image 3 is the same character sheet drawn for a steeper camera: draw the same figure, the same poses, in the same 6 columns and 5 rows in the same order.
>
> Draw a character sprite sheet of OHM: a grid of 6 columns and 5 rows of equal cells, one full figure centred alone in each cell with green margin all round, every figure the same size and the same scale, all seen from a camera above and in front, looking down at 55 degrees (a three-quarter view: more of his face, coat and side are visible than in image 3, the shoulders and the tops of the three jars still visible).
>
> Rows, top to bottom: row 1, he faces the viewer (toward the bottom of the page); row 2, he faces three-quarters toward the viewer and to the right; row 3, right side profile, facing right; row 4, three-quarters away from the viewer and to the right (we see his back and the jars); row 5, facing straight away from the viewer (his back and the three jars fully visible).
>
> Columns, the same in every row: column 1, hovering idle: stooped, the staff held upright beside him in his right hand, the coat hanging still into its misty hem; column 2, drifting forward: leaning forward from the waist, the staff held out ahead of him at an angle like a walking stick whose foot hangs just above the ground, the coat hem and beard streaming backwards; column 3, charged: standing tall, the staff raised high overhead in his right hand, the forked copper tip pointing up; column 4, the thrust: lunging forward, both hands on the staff, thrusting it straight out ahead at shoulder height, the forked tip foremost; column 5, recovery: hunched, pulling the staff back across his chest, the coat swinging forward; column 6, struck: thrown backwards off balance, head tipped back, the staff swinging away from him, the coat hem flaring forward.
>
> In every cell the insides of the three glass jars on his back are painted flat solid magenta (#FF00FF), an even placeholder colour with no glow and no shading, only inside the jar glass, wherever the jars can be seen from that angle. The hem of the coat ends in short ink-outlined teal wisps about a third of his height below the coat and never touches the bottom of the cell; there is nothing under him.

### Image C: `ohm_spec_top` (refs R1, R2)
> Image 1 is the character to match: OHM, the Lightning Rod, a stooped old robot wizard who is a floating teal spectre with goggles, a wire beard, riveted shoulder plates, a ragged coat that frays into mist, three glass jars on his back and a staff with a forked copper tip; his straight-down view is the small inset at the top right of image 1. Image 2 shows the ink, fill and print style of our cutout part sheets: match that style, not its robot.
>
> A part sheet for a 2D cutout game rig: a 3 x 2 grid of equal cells, each part centred alone in its own cell with green margin all round, every part seen from DIRECTLY ABOVE (a true 90-degree top-down view, looking straight down), all parts at the same scale, the front of the character pointing to the RIGHT of the page.
>
> Top-left: the BODY seen from straight above, front to the right: the hunched rounded mass of riveted shoulder plates, and the hooded head at the front edge with two round goggle lenses, the tip of the bristly wire beard just showing in front of the goggles; on the back half, three round glass jar tops in a row across his back, each jar top a circle whose inside is painted flat solid magenta (#FF00FF) with no glow and no shading, joined by short curling hoses. No arms in this cell. Top-middle: the COAT HEM seen from straight above, lying left to right: the ragged rubber-sheet coat tail fraying into ink-outlined teal mist wisps and a few loose wires, broad at the right end where it joins the body, thinning and tattered toward the left. Top-right: the STAFF seen from straight above, lying left to right: a long thin segmented teal pole with rings, ending at the right in a FORKED tip of two parallel copper prongs. Bottom-left: the STAFF ARM seen from straight above, lying left to right: a thin bony arm in a ragged coat sleeve, a riveted shoulder plate at the left end, at the right end a closed hand with a round hole through the fist where a pole would pass. Bottom-middle: the FREE ARM seen from straight above, lying left to right: a thin bony arm in a ragged coat sleeve, an open clawed hand at the right end with the fingers spread. Bottom-right: the BEARD seen from straight above, root at the left: a short bristly tuft of cable wires spreading toward the right, with copper wire ends.

### Judge every image before you use it (re-roll at most twice per image, same prompt)
Re-roll if: any figure has legs or feet; the grid is not 6x5 (A, B) or 3x2 (C); figures differ in size or a row
faces the wrong way; jars are missing their magenta insides in rows where the jars are visible; the body is
solid grey/brown metal instead of translucent teal; anything is drawn on the green (shadows, glow pools, floor);
the silhouette is no longer the plate's (stoop, three jars, forked staff). If the third take still fails, keep
the best, cut it anyway, and say exactly what is wrong in your report.

Save every take (accepted and rejected) to `C:\Users\kazda\kiro\gtai-masters\n20\ohm\masters\` as
`<name>_t<n>.png`; never into git. Commit the three prompts (the full text incl. STYLE, refs in order, take
results) as `docs/art/prompts/n20/ohm/ohm_spec_p70.md`, `ohm_spec_p55.md`, `ohm_spec_top.md`.

## 2. Cut script `tools/art/ohm_spectral_cut.py` (deterministic; re-runnable; nothing done by hand)
Inputs: the three accepted masters. Reuse helpers from `ghost_pack.py` / `ghost_parts.py` by import where it fits.
- Key the green (#00B140) to alpha with clean edges (despill the green fringe; keep the black ink rim). Split
  each sheet into its cells by finding the figures (connected components / column gaps), not by a blind grid,
  so a figure that leans over its cell line is not cut.
- **Jar masks.** In each cell find the magenta (#FF00FF, with tolerance for antialias) pixels, take the up to
  three largest blobs as the jars, and number them 1..3 so the SAME physical jar keeps its number in every
  facing: jar 1 is the jar on his left shoulder side (the screen-left jar in the away row), jar 2 the middle, jar 3
  his right side. Write a mask texture with the same layout as the body sheet: jar 1 in R, jar 2 in G, jar 3 in B
  (255 inside, antialiased edge), alpha = 255 where any jar. In the body texture itself replace the magenta with
  an empty-glass look: a dark translucent teal-black (about `#0B2624`, alpha 200) with the jar's ink kept, so an
  unfilled jar reads empty. Report how many jars were found per cell (a toward-facing cell may legitimately show
  fewer).
- **Tilt sheets.** Pack each tilt as two GhostSheet-style grids into `project/features/souls/art/view/p70/` and
  `.../p55/`: `ohm_spec_hover.png` (5 rows x 2 cols: idle, drift) and `ohm_spec_act.png` (5 rows x 4 cols:
  charged, thrust, recovery, struck), each with its `_jars.png` mask twin (`ohm_spec_hover_jars.png`,
  `ohm_spec_act_jars.png`). One scale for every cell of a tilt, all cells the same size, every figure seated on
  the same anchor (the bottom of the coat body, not the wisps; write the anchor and the cell size into a small
  JSON next to the sheets, `ohm_spec_cells.json`: cell px, anchor px in the cell, the jar bounding box per jar per
  cell). Match the drawn height of the shipped Ohm at the same tilt (measure `ohm_walk8.png`'s figure height
  and the scale the game draws it at; the new figure, wisps excluded, should come out the same world height,
  his staff and fork rising above).
- **Top-view parts.** Cut image C into `project/features/souls/art/ohm/spectral/` as `body.png`, `body_jars.png`
  (the three jar tops as the R/G/B mask, same rule), `hem.png`, `staff.png`, `arm_staff.png`, `arm_free.png`,
  `beard.png`, all at one shared scale, oriented front = +x (to the right), and write `parts.json` with each
  part's size in px, its pivot (shoulder / root / grip) and the body's jar circle centres and radii in px.
- **Preview** (for review, not shipped): `C:\Users\kazda\kiro\gtai-masters\n20\ohm\body_preview.png`: every cut
  cell of both tilts and the top parts on dark asphalt (`#1B1F24`), each cell shown 4 times with the jar mask
  filled teal (#2EC4B6 glowing) for 0, 1, 2 and 3 full jars, plus one with the jars amber (#FFB000).
  And `C:\Users\kazda\kiro\gtai-masters\n20\ohm\body_32ppm_guard.png`: the p70 idle row at the game's 32 px/m
  scale beside a guard (the cop's p70 standing cell from `project/features/characters/art/view/p70/`) and beside
  the shipped `ohm_walk8.png` cell at the same scale, plus the same at 2x nearest-neighbour for viewing.

## 3. Import, provenance, commit
- Run `"$GODOT_BIN" --headless --path project --import` once (APPDATA as above) and commit the new `.import`
  files with their PNGs.
- `art_src/n20_ohm.manifest.json` in the `n19_move` manifest format: one master entry per accepted take, with
  `masters:n20/ohm/masters/<file>`, the prompt_ref, the references in order, accepted true.
- One line per shipped PNG appended to `steam/ai-provenance/2026-11.jsonl` (append only, same fields as the
  existing lines; `accepted_by: "agent:n20 ohm (master and cut review)"`, `human_edits` names the cut script).
- `node tools/lint/lint.mjs` must pass (python scripts are not linted by gdlint, but the file-size and other
  checks run). Then commit, staged per path: one commit for the cut script + art + imports + manifest + provenance
  + prompts ("Cut Ohm's spectral Lightning Rod body: tilt sheets, top parts, jar masks").
- Do not touch `ghost_forms.json`, any `.gd`, any other ghost's art, or the shipped `ohm_*` art (it stays as the
  legacy look).

## Report back
The three take counts and why any were re-rolled; jars found per cell; cell size, scale and anchor; the commit
hash; the preview paths; and anything in the drawings that does not match the plate (be honest: the director
looks at every image).
