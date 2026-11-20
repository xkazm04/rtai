# Brief a1-body-art (lane dent, n20): Dent's new legless body, as art only

You are building art for **Dent**, one of the four ghost forms of RTAI (`gtai`). Tonight the owner
redesigns all ghosts as legless, flying spectres. Dent's winning concept plate is
`C:\Users\kazda\kiro\gtai-masters\n20\concepts\dent_a.png` ("Ejected": a crash-test dummy from the
belt up, thrown through a windscreen, riding a comet tail of teal light and glass). **Look at that
plate before you start, and compare every sheet you make against it.**

This package is art only: generate, key, cut, pack, commit. **No GDScript wiring** in this package
(another lane, `flight`, is landing the shared hover/look switch; wiring comes in my next brief).

## Machine rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/dent` before any Godot or gate run.
- `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`.
  One Godot process at a time. Windowed runs (none needed here) go `--position 0,1440`.
- If the image service reports a usage or rate limit, wait 5 minutes and retry; meanwhile write the
  cut tool.
- Stage per path, one commit per sheet (or per logical step). No `git add -A/./-u`, no stash, no
  `reset --hard`, never push. Commit `.import` files with every new PNG (run
  `"$GODOT_BIN" --headless --path project --import` once to create them).

## The images: use these prompts VERBATIM
Use your built-in `image_gen`. Attach the reference images **in the listed order** (image 1, 2, 3).
Landscape 1536x1024. Do not edit, shorten or "improve" the prompt text. Save every raw output
(including rejects) under `C:\Users\kazda\kiro\gtai-masters\n20\dent\masters\` (never in git).

Re-roll rule (at most 2 re-rolls per sheet; record each in the commit message and in
`docs/art/prompts/n20/dent/README.md`): re-roll a sheet if any figure grew legs, feet or hips, if the
body is not teal (grey/tan/brown metal = reject), if the grid is not 4 rows x 5 columns of separate
figures, if figures touch each other, or if a column faces the wrong way. Keep the best take.

### Sheet 1: `dent_sp_fly_70` (refs: 1 = `C:\Users\kazda\kiro\gtai-masters\n20\concepts\dent_a.png`, 2 = `C:\Users\kazda\kiro\gtai-art\library\rounds\20261109-2015\out\dent_act_70.png`, 3 = `C:\Users\kazda\kiro\gtai-art\library\refs\camera_guide_70.png`)

```
FLIGHT SPRITE SHEET for a top-down action game, COPY BY EXAMPLE. Image 1 is the character: EJECTED, the ghost of a crash-test dummy robot thrown through a windscreen, exactly as the big hero drawing in image 1: only the body from the belt up; a round dummy head with one big black-and-yellow quartered disc on the side of the head and a wide black visor with a white star crack; a black-and-yellow quartered disc on each shoulder; dented riveted chest plates with a small steel plate on the chest; a dark diagonal seatbelt strap across the chest to a dark waist belt with a square steel buckle; two jointed dummy arms with segmented forearms and blocky four-finger hands; worn steel and rust specks. His whole body is a luminous glowing TEAL (#2EC4B6) spectre with the black ink linework clearly visible through the glow, pale aqua highlights on the top edges and deeper teal in the shadows; the discs stay black and yellow, the belt stays dark. Below the waist belt the body tears off into a short ragged flame-shaped plume of teal light, no longer than his head is tall, with three or four small pale glass shards in it. NO LEGS, NO FEET and NO HIPS in any drawing. Image 2 shows the ink, the outline weight, the fill, the figure size and the grid layout of our sprite sheets: match its style and its steep 70-degree camera, NOT its character (image 2's tan dummy with legs is a different character). Image 3 is a camera guide only, never drawn. Draw a GRID of FOUR ROWS and FIVE COLUMNS on a flat solid magenta (#FF00FF) background, one size for every figure, well separated so nothing crosses into a neighbour: column 1 facing the camera, column 2 three-quarter toward the camera facing picture right, column 3 right profile, column 4 three-quarter away facing picture right, column 5 straight away (back to us). Every pose leans along the direction its column faces: toward the camera means DOWN the picture, three-quarter means along the diagonal, profile means straight to the side, away means UP the picture. Row 1 HOVER: floating upright with a slight forward lean, both arms hanging loose and a little apart, the hands open, the plume hanging below him. Row 2 DIVE: thrown forward at full speed, the torso tipped forward nearly flat along the facing, the head leading, both arms swept back along his sides, the plume streaming straight back behind him. Row 3 SWING: whipped round a hard turn like a rag doll, the torso rolled onto its side, the head lolling, both arms flung loose and wide, the plume swinging out the other way. Row 4 HIT: jolted back by a blow from the front, the head snapped back, the chest arched, both arms thrown forward and up with the hands spread, the plume bunched under him. No text, no numbers, no grid lines, no slot borders, no motion lines, no ground, no shadow, no glow on the background.
```

### Sheet 2: `dent_sp_act_70` (same three refs as sheet 1)

```
ACTION SPRITE SHEET for a top-down action game, COPY BY EXAMPLE. Image 1 is the character: EJECTED, the ghost of a crash-test dummy robot thrown through a windscreen, exactly as the big hero drawing in image 1: only the body from the belt up; a round dummy head with one big black-and-yellow quartered disc on the side of the head and a wide black visor with a white star crack; a black-and-yellow quartered disc on each shoulder; dented riveted chest plates with a small steel plate on the chest; a dark diagonal seatbelt strap across the chest to a dark waist belt with a square steel buckle; two jointed dummy arms with segmented forearms and blocky four-finger hands; worn steel and rust specks. His whole body is a luminous glowing TEAL (#2EC4B6) spectre with the black ink linework clearly visible through the glow, pale aqua highlights on the top edges and deeper teal in the shadows; the discs stay black and yellow, the belt stays dark. Below the waist belt the body tears off into a short ragged flame-shaped plume of teal light, no longer than his head is tall, with three or four small pale glass shards in it. NO LEGS, NO FEET and NO HIPS in any drawing. Image 2 shows the ink, the outline weight, the fill, the figure size and the grid layout of our sprite sheets: match its style and its steep 70-degree camera, NOT its character (image 2's tan dummy with legs is a different character). Image 3 is a camera guide only, never drawn. Draw a GRID of FOUR ROWS and FIVE COLUMNS on a flat solid magenta (#FF00FF) background, one size for every figure, well separated so nothing crosses into a neighbour: column 1 facing the camera, column 2 three-quarter toward the camera facing picture right, column 3 right profile, column 4 three-quarter away facing picture right, column 5 straight away (back to us). Every action goes along the direction its column faces: toward the camera means DOWN the picture, three-quarter means along the diagonal, profile means straight to the side, away means UP the picture. Row 1 COCK: the right fist pulled back tight against his chest, the left hand raised in front as a guard, the shoulders twisted, the body coiled and leaning into the facing. Row 2 JAB: the right arm fired straight out along the facing at full length, the blocky fist leading, the right shoulder thrown forward, the left arm pulled back to the chest. Row 3 STEER ONE HAND: leaning back against a strong pull, the right arm raised and reaching forward along the facing at shoulder height, the right fist clenched as if gripping a strap (no strap drawn), the left arm out to the side for balance. Row 4 STEER TWO HANDS: both arms raised forward along the facing at shoulder height and shoulder width, the elbows bent, both hands hooked with the fingers curled down like a puppeteer working strings (no strings drawn). No text, no numbers, no grid lines, no slot borders, no motion lines, no ground, no shadow, no glow on the background.
```

### Sheet 3: `dent_sp_top` (refs: 1 = `C:\Users\kazda\kiro\gtai-masters\n20\concepts\dent_a.png`, 2 = `C:\Users\kazda\kiro\gtai-masters\n6\ghost-forms\gen\r2\out\dent_parts.png`)

```
A part sheet for a 2D cutout game rig: a grid of THREE COLUMNS and TWO ROWS of equal cells on a flat solid magenta (#FF00FF) background, every part seen from DIRECTLY ABOVE (a true 90-degree top-down view, looking straight down), the front of the body facing DOWN the page, each part centred alone in its own cell with clear magenta margin all round. Image 1 is the character: EJECTED, the ghost of a crash-test dummy robot; his straight-down view is the small panel at the top right of image 1. Image 2 shows the ink, the outline weight, the fill and the print style of our cutout part sheets: match that style, NOT its colours or its character. Every part is a luminous glowing TEAL (#2EC4B6) spectre with the black ink linework clearly visible through the glow, pale aqua highlights, deeper teal shadows and small worn steel and rust specks; the quartered discs are black and yellow, the belt is dark. Top-left: the HEAD from straight above: a round dummy skull with one big black-and-yellow quartered disc on its crown and the cracked black visor edge showing at the front (the bottom of the cell). Top-middle: the TORSO from straight above, the chest toward the bottom of the cell: broad rounded shoulders with a black-and-yellow quartered disc on top of each shoulder, a dark seatbelt strap crossing diagonally, a dark waist belt with a square steel buckle at the front, about twice as wide as it is deep, ending at the belt. Top-right: one UPPER ARM from above lying left to right: a segmented dummy arm tube with a round shoulder joint at the left end and an elbow joint at the right end. Bottom-left: one FOREARM WITH A CLOSED FIST from above lying left to right: forearm tube, wrist joint, a blocky clenched robot fist at the right end. Bottom-middle: one FOREARM WITH AN OPEN HAND from above lying left to right, the four fingers spread. Bottom-right: the TAIL ROOT from above: a ragged flame-shaped plume of teal light, wide at the top of the cell where it meets the belt and tearing into tongues toward the bottom, with four small pale glass shards in it. No legs, no feet. No text, no numbers, no grid lines, no borders, no shadow.
```

### Sheets 4 and 5 (only after 1-3 are committed): `dent_sp_fly_55`, `dent_sp_act_55`
Prompts = sheet 1 and sheet 2 verbatim with exactly two substitutions:
- `its steep 70-degree camera` -> `its 55-degree high three-quarter camera (the top of the head AND its front both clearly visible)`
- refs 2 and 3 -> `C:\Users\kazda\kiro\gtai-art\library\rounds\20261109-2205\out\dent_act_55.png` and `C:\Users\kazda\kiro\gtai-art\library\refs\camera_guide_55.png`.
Commit the substituted prompt texts too.

## Cut and pack (a script, never by hand)
Write `tools/art/dent_spectral_cut.py` (python, deterministic, `py -3 -I`): key the magenta
(including the anti-aliased magenta fringe: despill toward the neighbouring ink/teal, never leave
pink edges), split the 4x5 grid into its 20 figures by connected alpha components (not by fixed
grid lines: figures are not centred in equal cells), drop specks (reuse `tools/art/ghost_pack.py`'s
despeck idea), and write cells in the layout `tools/art/ghost_pack.py` expects: `{row}_{col}.png`
where **row = facing** (1 toward, 2 three-quarter toward right, 3 right profile, 4 three-quarter
away right, 5 away) and **col = pose** (sheet row 1..4). That is a transpose of the generated
grid. Cells go to `C:\Users\kazda\kiro\gtai-masters\n20\dent\cells\<sheet>\`. Then pack with
`tools/art/ghost_pack.py` into the game:
- `project/features/souls/art/view/p70/dent_sp_fly.png`, `.../p70/dent_sp_act.png`
- `project/features/souls/art/view/p55/dent_sp_fly.png`, `.../p55/dent_sp_act.png`
One figure scale across fly and act of a pitch (pack act with `--k` = the fly sheet's printed k, or
`--match`, whichever gives equal head sizes; measure the head/visor width in a profile cell of both
and state the two numbers). Print and record cell size and median figure height per sheet.

Top parts: cut each of the six parts tight (keyed, despilled) into
`project/features/characters/art/dent/spectral/` as `head.png`, `torso.png`, `upperarm.png`,
`forearm_fist.png`, `forearm_open.png`, `tail_root.png`, scaled so the head part's width matches the
old `project/features/characters/art/dent/helmet.png` height (it is 165 px: the old helmet lies
sideways), and write `project/features/characters/art/dent/spectral/parts.json` in the format of
`project/features/characters/art/dent/parts.json` (size, sheet, pivot_a / pivot_b: limb a = the
joint, b = the end; head and torso pivots at their centres; tail_root pivot_a at its top centre).

Do not touch the existing Dent PNGs; the old art stays. Your new files must not be named by any
code yet; if lint or tests flag new unreferenced PNGs, add a small unit test
`project/tests/unit/test_dent_spectral_art.gd` that loads each new texture and asserts its size is
a 5-row grid (sheet height divisible into 5 equal rows) and the 6 parts exist, rather than any
exemption.

## Records (all required)
- Prompts committed verbatim under `docs/art/prompts/n20/dent/` (one `.txt` per sheet, plus a
  `README.md` listing refs in order, takes, re-rolls and which take shipped).
- `art_src/n20_dent.manifest.json` in the format of `art_src/n19_move.manifest.json` (one entry
  per shipped PNG: master path, prompt file, refs, tool, date).
- One provenance line per shipped PNG appended to `steam/ai-provenance/2026-11.jsonl` in the format
  of its existing lines (append only, one line each).

## Acceptance (you check; I will check again)
1. A contact board per sheet: `evidence/a1/<sheet>_board.png` showing all 20 cells on dark asphalt
   grey (#3a3a3a) at 4x game size, and `evidence/a1/<sheet>_32ppm.png`: the five facings at the size
   the game draws them at 32 px/m (Dent is 1.8 m tall x PlayerScale 1.5 -> about 86 px for the
   figure incl. plume) next to each other. Top parts: `evidence/a1/top_parts_board.png` with the
   six parts and a rough assembled top view (head on torso, two arms forward, tail root behind).
2. No pink fringe on any cell edge at 4x (zoom one board crop and look).
3. `node tools/lint/lint.mjs` green; `node tools/tests/run_unit.mjs --select=test_dent_spectral_art`
   green (if you add the test); `node tools/gate/quick.mjs` before each commit.
4. Report back: per sheet, takes and re-rolls, cell size, median figure height, the head widths,
   anything that does not match the plate. Do not claim a sheet passes if a figure has legs.

## Order and time
Sheet 1 -> cut tool -> pack -> commit; sheet 2 -> commit; sheet 3 -> commit; then 4 and 5.
If you reach 65 minutes, commit what is finished and stop with a report; unfinished sheets are
fine, uncommitted work is not.
