# Brief 01 (lane tonnage): the Press Golem body art, art only, no wiring

You are building the art for Tonnage's new spectral body. The target is the owner's chosen concept plate
`C:\Users\kazda\kiro\gtai-masters\n20\concepts\tonnage_b.png` (hero top-left, straight top-down view top-right,
the slam bottom-right). **Look at it first.** This session makes sprite sheets and parts only. Do NOT change any
`.gd`, scene, table or test in this session: nothing in the game uses the new files yet. The old art stays.

Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/tonnage` and
`GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Any windowed run gets `--position 0,1440`.

## Read first (10 minutes, no more)
- How the current ghost art was made: `docs/night/2026-11-05/ghost-forms/REPORT.md`, `tools/art/ghost_parts.py`,
  `tools/art/ghost_pack.py`, `art_src/tonnage_walk16_req221.manifest.json`, `docs/art/weapons.md` (section "Pipeline").
- The sheets you are replacing (keep them, do not edit them): `project/features/souls/art/view/p70/tonnage_act.png`
  (4 columns x 5 facing rows: front, front three-quarter, side facing right, back three-quarter, back) and its p55 twin;
  the top-view parts `project/features/souls/art/tonnage/*.png` (drawn facing DOWN the page; the rig rotates them).

## Deliverables, in this order (commit each as it lands; one commit per sheet)

Use `image_gen` with the prompts below **verbatim** (copy them exactly, do not rephrase, do not add words). Attach the
reference images in the listed order. Look at every result yourself. Re-roll (at most twice per sheet, same prompt)
when the figure grew legs or feet, lost the plate's silhouette (hunched back, sunk head, two huge arms with square
press-block fists), came out grey solid metal instead of teal, put the fists on the ground in any column except STRIKE,
or the grid is not the asked grid. Keep the best take and say in your report which take and why.

### A. Top-view parts (refs: image 1 = the plate `tonnage_b.png`, image 2 = `C:\Users\kazda\kiro\gtai-masters\n6\ghost-forms\gen\r4\refs\style.png`)

> A part sheet for a 2D cutout game rig of a hunched, legless spectral golem: a 3 x 2 grid (three cells per row, two rows, equal cells), every part seen from DIRECTLY ABOVE (true 90 degree top-down view, looking straight down), each part centred alone in its own cell with flat chroma green #00B140 margin all round. Image 1 is the character to match: TONNAGE, the Press Golem (its straight top-down view is the top-right panel of image 1): a glowing teal spectre built from riveted press plates, hoses and hydraulic pistons, with black ink linework, faint rust flecks and black-and-ochre hazard stripes on the fist plates. Image 2 shows the ink, fill and print style of our cutout part sheets: match its bold black ink line and flat, lightly shaded fills, not its robot. Fill every part in luminous teal (#2EC4B6 family, pale teal highlights, deep teal shadows), the steel shown only as black ink linework and small rust flecks inside the teal, never solid grey metal. A crisp black outline around every part, no glow, smoke or shadow outside the outline, nothing touching the cell edge. Cells: Top-left: the BACK AND SHOULDERS seen from straight above, front pointing DOWN the page: a wide rounded-square hump of overlapping riveted die-plates, wider than long, a small low head sunk between the shoulders at the front edge with a single slot visor, hoses looping over the shoulders. Top-middle: one UPPER ARM seen from above lying along the page left-to-right: a thick hydraulic cylinder with a round shoulder joint at the left end and a round elbow joint at the right end, a ribbed hose wrapped along it. Top-right: one FOREARM seen from above lying left-to-right: a polished piston rod sliding out of a riveted sleeve, a round elbow joint at the left end, a square wrist clamp at the right end. Bottom-left: one PRESS-PLATE FIST seen from straight above: a heavy square riveted press block, slightly longer than wide, the wrist socket at the top edge, black-and-ochre diagonal hazard stripes across its lower half, a rivet at each corner. Bottom-middle: a HOSE BUNDLE seen from above: three ribbed teal hoses looping in an upside-down U, the open ends at the bottom of the cell. Bottom-right: flat green, empty.

Cut with a new script `tools/art/tonnage_spectral_parts.py` (key the green, trim, one PNG per part) into
`project/features/souls/art/tonnage/spectral/`: `back.png`, `upper_arm.png`, `forearm.png`, `fist.png`, `hoses.png`.
Same orientation convention as the old parts (body parts face DOWN the page; limbs lie left-to-right). Check the key
edge: teal is close to the green key, so there must be no green fringe and no eaten teal; if the keyer eats teal, key
by distance to `#00B140` with a tight threshold plus a despill, never by "is green dominant". Write a contact sheet of
the five parts on mid grey to `C:\Users\kazda\kiro\gtai-masters\n20\tonnage\scratch\parts_contact.png` and look at it.

### B. Tilted pose sheet, p70 (refs: image 1 = the plate, image 2 = `project/features/souls/art/view/p70/tonnage_act.png`)

> A sprite sheet for a 2D top-down action game: a 4 x 5 grid (four columns, five rows, equal cells) of one character on flat chroma green #00B140, every cell seen from the same high camera looking down at about 70 degrees (the camera angle of image 2), the figure centred in each cell with green margin all round and the same size in every cell. Image 1 is the character to match: TONNAGE, the Press Golem: a colossal hunched spectral genie built from press parts, ONLY AN UPPER BODY: a massive back and shoulders of riveted die-plates, a small low head sunk between the shoulders with a single glowing slot visor, two enormous hydraulic piston arms draped with hoses, each ending in a flat square press-plate fist the size of a car door with black-and-ochre hazard stripes. Below the chest the body ends in a short rounded taper (the game adds his smoke tail): draw NO legs, NO feet, nothing standing on the ground. His whole body is luminous teal (#2EC4B6 family, pale teal highlights, deep teal shadows), the steel plates and hoses shown as black ink linework and faint rust flecks inside the teal, never solid grey metal. Image 2 shows the ink, fill, grid and camera angle of our game sprites: match its bold black ink line, flat lightly shaded fills and its five facing rows, NOT its character (the legs and grey metal of image 2 are exactly what we do not want). A crisp black outline, no glow, smoke, shadow or ground outside the outline. Rows, top to bottom, the facing: row 1 facing the camera (toward the bottom of the page), row 2 facing three-quarter toward the camera and to the right, row 3 side view facing right, row 4 facing three-quarter away from the camera and to the right, row 5 facing away from the camera. Columns, left to right, the pose, the same pose all down each column: column 1 CARRY: hovering upright, both fists carried at chest height and forward, elbows bent outward, the fists level and side by side, far above the ground; column 2 CRUISE: the same carry with the torso tipped forward into the direction it faces and the fists trailing a little behind the shoulders; column 3 ARMED: a charging pose, one shoulder dropped forward and its fist tucked tight in front of the chest like a bumper, the other fist pulled back beside the body; column 4 RECOIL: the torso jolted backward, the head ducked between the shoulders, both fists pulled in to guard the chest. No text or labels.

Save as `project/features/souls/art/view/p70/tonnage_spectral_pose.png`.

### C. Tilted attack sheet, p70 (refs: image 1 = the plate, image 2 = your accepted sheet B, image 3 = `project/features/souls/art/view/p70/tonnage_act.png`)

> A sprite sheet for a 2D top-down action game: a 4 x 5 grid (four columns, five rows, equal cells) of one character on flat chroma green #00B140, every cell seen from the same high camera looking down at about 70 degrees, the figure centred in each cell with green margin all round and the same scale in every cell. The character is exactly the one drawn in image 2: TONNAGE, the Press Golem from image 1, ONLY AN UPPER BODY of riveted die-plates with a small sunk head and a slot visor, two enormous hydraulic piston arms ending in square press-plate fists with black-and-ochre hazard stripes, the body ending below the chest in a short rounded taper: NO legs, NO feet. Luminous teal body (#2EC4B6 family) with black ink linework and faint rust flecks, never solid grey metal. Match the ink, fills and camera of image 2; image 3 shows only the grid of five facing rows. A crisp black outline, no glow, smoke or shadow outside the outline. Rows, top to bottom, the facing: row 1 facing the camera, row 2 three-quarter toward the camera and to the right, row 3 side view facing right, row 4 three-quarter away from the camera and to the right, row 5 facing away from the camera. Columns, left to right, the moment of a double-fist ground pound, the same moment all down each column: column 1 RAISE: both fists lifted high above the head and spread wide apart, the torso reared back; column 2 POUND: both fists brought down together onto the ground in front of the body, their flat faces side by side on the ground at arm's length ahead, the torso hunched forward over them, open ground visible between the body and the fists; column 3 LIFT: the fists rising off the ground halfway back to the chest, the torso straightening; column 4 the CARRY pose of image 2 column 1 again. No text or labels.

Save as `project/features/souls/art/view/p70/tonnage_spectral_act.png`.

### D and E. The p55 twins

Sheets B and C again for the 55 degree tilt: the same prompts word for word except `about 70 degrees` becomes
`about 55 degrees`; image 2 for B becomes `project/features/souls/art/view/p55/tonnage_act.png` and add your accepted
p70 sheet B as image 3 with this sentence appended to the prompt: `Image 3 is the same character at a steeper camera:
draw exactly that character.` For E, image 2 = your accepted p55 sheet D, image 3 = `p55/tonnage_act.png`.
Save as `project/features/souls/art/view/p55/tonnage_spectral_pose.png` and `.../p55/tonnage_spectral_act.png`.

## Packing the tilted sheets
- Cut each generated grid with a new script `tools/art/tonnage_spectral_pack.py` (green key + despill as in A, find
  each figure, place it into equal cells of the same 4 x 5 layout, bottom-anchored on one common baseline per sheet,
  same scale across all cells and across the pose and act sheets of one tilt). Cell size: at least 1.25x the old act
  cell (old act sheet 776x1020 = 194x204 per cell), so the 64 px/m close-up is not upscaled. The figure's scale must
  match across B/C (one tilt) so a pose switch does not pop.
- Print per sheet: cell size, the median figure height in cell px (`fig_px`, as `ghost_pack.py` prints it), and the
  bottom-anchor y. Put those numbers in your report: the next session wires them.
- Run `"$GODOT_BIN" --headless --path project --import` once so the `.import` files exist; commit `.png` + `.import`.

## Provenance and law (each binds)
- Every raw generation (including rejected re-rolls) goes to `C:\Users\kazda\kiro\gtai-masters\n20\tonnage\masters\`
  (never into git). One manifest `art_src/tonnage_spectral_n20.manifest.json` in the format of the existing
  `art_src/*.manifest.json` (sheet path, per master: date 2026-11-20, file, model, prompt_ref, sha256, tool).
- One provenance line per shipped PNG appended to `steam/ai-provenance/2026-11.jsonl` (copy the shape of the
  existing lines; append only, one line at a time).
- The prompts, verbatim, and the reference lists committed as `docs/art/prompts/n20/tonnage/<sheet>.md`.
- New tool scripts carry `tonnage` in the name. Python only under `tools/art/`. Nothing in `project/` but the PNGs.
- Stage per path. No `git add -A/./-u`, no stash, no reset --hard, never push. Commit messages: imperative, one line,
  e.g. `Add the Press Golem's spectral top-view parts`.
- If image_gen reports a usage or rate limit: wait five minutes and retry; up to three waits.
- Before each commit: `node tools/gate/quick.mjs` (if it complains about something you did not touch, say so and go on).

## Report
Per sheet: accepted take number, re-rolls and why, cell size, fig_px, baseline y, commit hash. Paths of the contact
sheets. Anything you could not finish. Then stop.
