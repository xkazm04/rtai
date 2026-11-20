# n21-kerf brief 01: the Swarf Ronin body (art only: generate, look, cut, pack, commit)

Lane `kerf`, worktree `C:\Users\kazda\kiro\gtai-wt\n21-kerf`, branch `n21-kerf`. Tonight is a VISUAL night.
This package is ART ONLY. Do NOT wire anything into game code (no `.gd` edits; your new cut script under
`tools/art/` is the only code you write).

**Wall-clock hard stop: 13:15. Commit deadline: 13:10.** If the image service holds you up, commit what is
accepted and say what is left. Fix lint and format findings in your own edits and go on. Never amend, never
rebase. No `git stash`, no `git add -A/./-u`, no `commit -a`, no `reset --hard`. Stage per path.

## Allowlist (any other path: stop and report it as `NEED <owner>: <file> <why>` in your final message)
- `tools/art/kerf_n21_cut.py` (new)
- `project/features/souls/art/view/p70/kerf_sp_fly.png`, `kerf_sp_act.png` (+ `.import`)
- `project/features/souls/art/view/p55/kerf_sp_fly.png`, `kerf_sp_act.png` (+ `.import`)
- `project/features/souls/art/kerf/ronin/**` (new folder: top-view parts + `parts.json` + `cut.json`, + `.import`)
- `docs/art/prompts/n21/kerf/**` (new)
- `art_src/n21_kerf.manifest.json` (new)
- `steam/ai-provenance/2026-11.jsonl` (append-only, one line per shipped PNG)
- scratch and evidence under `C:\Users\kazda\kiro\gtai-masters\n21\kerf\` (outside git)
Do not touch any `.gd`, any other ghost's art, `ghost_forms.json`, the old `art/kerf/spectral/` (it is deleted
in a later package), any sim, any golden.

## The character (LOOK AT THE PLATE FIRST)
Plate: `C:\Users\kazda\kiro\gtai-masters\n21\concepts\kerf_b.png` ("Swarf Ronin", the owner's pick). A gaunt,
legless robot PERSON cut from teal-edged sheet-steel plates: wedge helmet with a slit lens, layered shoulder and
chest plates, two jointed arms whose forearms are long curved cutter plates (his hands are the blades), three
glowing vertical slots on the chest, and below the ribs the body unwinds into a ribbon of metal shaving that
thins to vapour. The owner wants "a legless robot with hands as blades" and a HUMANOID form like the other
ghosts. The model for how we draw such a ghost is Dent's accepted spectral sheet (see the references): a robot
person from the waist up, a short spectral tail instead of legs.

Things the director has decided (the image prompts already say them; do not "fix" them back to the plate):
- The blades are carried swept BACK and out to the sides like a swallow's wings. The tips never point at the
  road and never forward-down (the plate's top inset curves them forward-down: that is wrong for the game).
- Three slots on the chest AND three matching slots on the back plate (the charge count must show from behind
  and from above). The slots are drawn bright pale aqua-white so a script can find them later.
- The swarf tail is ONE simple S-shaped ribbon with punched holes, about as long as his torso, no tight curls.

## Image prompts: use them VERBATIM (the director wrote them; do not reword, shorten or "improve")
Use your built-in `image_gen`, landscape 1536x1024 for every sheet. Attach the references in the order listed
(image 1, image 2, ...). If the image service reports a usage or rate limit, wait five minutes and retry;
meanwhile write the cut script. Save every take (kept and rejected) to
`C:\Users\kazda\kiro\gtai-masters\n21\kerf\masters\<sheet>_take<N>.png`.

### References
- R1 = `C:\Users\kazda\kiro\gtai-masters\n21\concepts\kerf_b.png` (the plate)
- R2 = `C:\Users\kazda\kiro\gtai-masters\n20\dent\masters\dent_sp_fly_70_take1.png` (Dent's accepted 70-degree flight sheet)
- R3 = `C:\Users\kazda\kiro\gtai-art\library\refs\camera_guide_70.png`
- R4 = `C:\Users\kazda\kiro\gtai-masters\n20\dent\masters\dent_sp_fly_55_take1.png`
- R5 = `C:\Users\kazda\kiro\gtai-art\library\refs\camera_guide_55.png`
- R6 = `C:\Users\kazda\kiro\gtai-masters\n20\dent\masters\dent_sp_top_take1.png` (Dent's accepted top part sheet)
Copy them into `...\n21\kerf\masters\refs\` for the record. NEVER attach any n20 Kerf image (`kerf_a.png`,
the Gantry Wraith): it pulls the generator back to a craft.

### The CHARACTER block (the same text is pasted at the start of sheets 1 to 4 below; it is part of the verbatim prompt)
CHAR = `Image 1 is the character: KERF, the Swarf Ronin, the ghost of an industrial cutting machine, exactly as the big hero drawing in image 1: a tall, gaunt robot PERSON from the chest up with a head, a neck, two shoulders, upper arms, elbows and forearms, assembled from flat plasma-cut sheet-steel plates with drilled holes, scored cut lines, rivets and a few rust specks; a narrow wedge-shaped helmet with one horizontal visor slit and one small round glowing lens in it, and one short torn strip of sheet steel streaming back from the back of the helmet; layered angular shoulder plates; a narrow plated chest with three short vertical slots side by side that glow bright pale aqua-white; the same three glowing slots repeated on his back plate between the shoulder blades; two long thin jointed arms, and from each elbow the forearm IS one long curved sheet-steel cutter blade shaped like a crescent or a swallow's wing, as long as his whole arm, its outer edge glowing pale aqua-white; he has no hands, the blades are his hands. His whole body is a luminous glowing TEAL (#2EC4B6) spectre with the black ink linework clearly visible through the glow, pale aqua highlights on the top edges and deeper teal in the shadows, the plate edges glowing like freshly cut hot metal. Below the ribs the body unwinds into ONE flat ribbon of teal metal shaving with a row of small punched round holes, about as long as his torso, that ends in a few wisps of teal vapour. NO LEGS, NO FEET and NO HIPS in any drawing. The two blades are ALWAYS held swept BACK and out to the sides of his body like a swallow's wings, the curved tips pointing backward and up, NEVER pointing at the ground and never pointing forward-down.`

### Sheet 1: `kerf_sp_fly_70` (refs R1, R2, R3)
Prompt (CHAR, then this):
`FLIGHT SPRITE SHEET for a top-down action game, COPY BY EXAMPLE. ` + CHAR + ` Image 2 shows the ink, the outline weight, the fill, the figure size and the grid layout of our sprite sheets: match its style, its steep 70-degree camera and its figure size, NOT its character (image 2's crash-test dummy with round discs, a seatbelt and fists is a different character; Kerf has no discs, no belt, no fists). Image 3 is a camera guide only, never drawn. Draw a GRID of FOUR ROWS and FIVE COLUMNS on a flat solid magenta (#FF00FF) background, one size for every figure, well separated so nothing crosses into a neighbour, the blades included: column 1 facing the camera, column 2 three-quarter toward the camera facing picture right, column 3 right profile, column 4 three-quarter away facing picture right, column 5 straight away (back to us, the three back slots visible). Every pose leans along the direction its column faces: toward the camera means DOWN the picture, three-quarter means along the diagonal, profile means straight to the side, away means UP the picture. Row 1 HOVER: floating upright and poised like a swordsman waiting, the lens looking straight ahead, both blades held half open out to the sides at shoulder height and swept back like a swallow's wings, the ribbon tail hanging below him in one loose S curve. Row 2 CRUISE: flying forward at full speed, the torso tipped far forward along the facing, the helmet leading, both blades swept far back close along his sides like folded wings, the ribbon tail pulled out straight behind him. Row 3 TURN: carving a hard turn, the whole body banked onto its side, the inner blade low and tucked, the outer blade raised high and swept back, the ribbon tail swinging out wide the other way. Row 4 HIT: jolted back by a blow from the front, the helmet snapped back, the chest arched, both blades flung up and out to the sides, the ribbon tail bunched under him. No text, no numbers, no grid lines, no slot borders, no motion lines, no sparks, no ground, no shadow, no glow on the background.`

### Sheet 2: `kerf_sp_act_70` (refs R1, R2, R3)
Prompt (CHAR, then this):
`ACTION SPRITE SHEET for a top-down action game, COPY BY EXAMPLE. ` + CHAR + ` Image 2 shows the ink, the outline weight, the fill, the figure size and the grid layout of our sprite sheets: match its style, its steep 70-degree camera and its figure size, NOT its character (image 2's crash-test dummy with round discs, a seatbelt and fists is a different character; Kerf has no discs, no belt, no fists). Image 3 is a camera guide only, never drawn. Draw a GRID of FOUR ROWS and FIVE COLUMNS on a flat solid magenta (#FF00FF) background, one size for every figure, well separated so nothing crosses into a neighbour, the blades included: column 1 facing the camera, column 2 three-quarter toward the camera facing picture right, column 3 right profile, column 4 three-quarter away facing picture right, column 5 straight away (back to us, the three back slots visible). Every pose acts along the direction its column faces: toward the camera means DOWN the picture, three-quarter means along the diagonal, profile means straight to the side, away means UP the picture. Row 1 COCK: coiled to strike, the torso leaning forward and low, the lens fixed straight ahead, his right blade drawn back across his chest to the opposite shoulder ready to cut, the left blade swept back, the ribbon tail drawn tight. Row 2 CUT: the moment just after one fast straight cut: the torso stretched forward, his right arm thrust fully forward along the facing with its blade extended straight ahead past him, the edge leading, the left blade swept far back behind, the ribbon tail pulled out straight behind. Row 3 RECOVER: settling after the cut, the torso coming upright, the right blade swinging back out to his side, both blades half open, the ribbon tail starting to curl. Row 4 BLINK: folded tight for a dash, the torso tipped fully forward and narrow, both blades swept back flat against his sides like a diving swift, the ribbon tail pulled out thin and straight. No text, no numbers, no grid lines, no slot borders, no motion lines, no sparks, no light beams, no ground, no shadow, no glow on the background.`

### Sheets 3 and 4: `kerf_sp_fly_55` and `kerf_sp_act_55` (refs R1, R4, R5), only after 1 and 2 are accepted
Same prompts as sheets 1 and 2 with these exact substitutions and nothing else:
`steep 70-degree camera` -> `lower 55-degree camera`; image 2 is R4 (Dent's 55-degree sheet); image 3 is R5.
Write the final text of each into its prompt file, so the file holds exactly what was sent.

### Sheet 5: `kerf_sp_top` (refs R1, R6)
Prompt (no CHAR block):
`A part sheet for a 2D cutout game rig: a grid of THREE COLUMNS and TWO ROWS of equal cells on a flat solid magenta (#FF00FF) background, every part seen from DIRECTLY ABOVE (a true 90-degree top-down view, looking straight down), the front of the body facing DOWN the page, each part centred alone in its own cell with clear magenta margin all round. Image 1 is the character: KERF, the Swarf Ronin, a gaunt legless robot ghost cut from sheet-steel plates; his straight-down view is the panel at the top right of image 1, but in our game his blades are swept BACK, never curved forward. Image 2 shows the ink, the outline weight, the fill and the print style of our cutout part sheets: match that style, NOT its colours or its character. Every part is a luminous glowing TEAL (#2EC4B6) spectre with the black ink linework clearly visible through the glow, pale aqua highlights, deeper teal shadows, drilled holes, rivets and a few rust specks, the plate edges glowing like freshly cut hot metal. Top-left: the HEAD from straight above: a narrow wedge-shaped helmet pointing DOWN the page, the visor slit with one small glowing round lens at its front tip, a short torn strip of sheet steel trailing from the back of the helmet toward the top of the cell. Top-middle: the TORSO from straight above, the chest toward the bottom of the cell: layered angular shoulder plates about twice as wide as the body is deep, and on the back plate between the shoulder blades three short slots side by side that glow bright pale aqua-white. Top-right: one UPPER ARM from above lying left to right: a thin jointed sheet-steel strut with a round shoulder joint at the left end and an elbow joint at the right end. Bottom-left: one FOREARM BLADE from above lying left to right: a round elbow joint at the left end, then one long curved sheet-steel cutter blade shaped like a crescent or a swallow's wing, curving gently upward toward its pointed tip at the right end, its outer curved edge glowing pale aqua-white, drilled holes along its spine. Bottom-middle: the TAIL RIBBON STRAIGHT from above: one flat ribbon of teal metal shaving running from the top of the cell to the bottom, slightly twisted once, a row of small punched round holes along it, the top end cut flat where it meets the body and the bottom end thinning into teal vapour wisps. Bottom-right: the TAIL RIBBON CURLED from above: the same ribbon in one loose S curve, the top end cut flat, the bottom end thinning into vapour wisps. No legs, no feet, no hands. No text, no numbers, no grid lines, no borders, no shadow.`

## Look at every image before it ships
Open each take and judge it against the plate (R1). Re-roll a sheet (same prompt, at most twice) that: grew
legs, feet, hips or hands; has blades pointing at the ground or forward-down in HOVER / CRUISE / TURN / BLINK;
lost the wedge helmet with the slit lens; lost the three chest slots in the toward columns or the three back
slots in the away column; reads as a craft, a bird or an insect rather than a robot person; came out muddy, grey
or opaque instead of luminous teal; broke the 4x5 grid or the facing order; or has a figure much smaller than
Dent's. In the final message say per sheet which take shipped and what the rejected takes got wrong.

## Cut and pack (a script, never by hand)
- New `tools/art/kerf_n21_cut.py` (`py -3 -I`), deterministic, documented docstring. Start from
  `tools/art/dent_spectral_cut.py` (read it; IMPORT from it or copy the functions you need, do NOT edit it: it is
  not yours). Magenta key by flood from the borders and cell margins, fringe clean on the ink outline (the teal
  glow must keep its edge). Then pack with the existing `tools/art/ghost_pack.py` exactly as Dent did (read
  `docs/art/prompts/n20/dent/README.md`, "Rebuilding the proof boards").
- Outputs: the four packed sheets to `project/features/souls/art/view/p70/kerf_sp_fly.png`, `kerf_sp_act.png`,
  `project/features/souls/art/view/p55/kerf_sp_fly.png`, `kerf_sp_act.png`, in the same layout as
  `dent_sp_fly.png` / `dent_sp_act.png` (4 rows x 5 columns, equal cells, figure seated as Dent's are), so
  Dent's drawer could read them unchanged. Top parts to `project/features/souls/art/kerf/ronin/{head,torso,
  upperarm,blade,tail_straight,tail_curled}.png` with a `parts.json` in the format of
  `project/features/characters/art/dent/spectral/parts.json` (size, pivots: shoulder and elbow pivots for arm
  and blade; the tail's pivot at its flat top end).
- SCALE: Kerf is a person of Dent's size. Match the HEAD size: the packed profile HOVER helmet must measure
  about the same as Dent's profile hover head on the packed textures (90 px at p70, 77 px at p55, alpha >= 128,
  per Dent's README). The blades and ribbon make his cells wider and longer than Dent's: that is fine. State the
  numbers you measured and the `--match` / `--k` you used.
- SLOTS: in every packed cell, find the glowing slots (small bright pale aqua-white blobs, three side by side)
  and write their centroids per cell (atlas px, relative to the cell origin, ordered left to right on the
  page; empty list where none show) to `project/features/souls/art/kerf/ronin/cut.json`, together with cell
  sizes and the per-cell alpha-mass centre. The same for the torso part. A later package uses these to darken
  spent charges. Say for how many cells per sheet three slots were found.
- Run Godot `--import` once so the `.import` files exist (`export APPDATA=C:/Users/kazda/kiro/gtai-n21/appdata/kerf`
  first; Godot is `C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`,
  `--headless --path project --import`). One Godot process at a time. Free your own processes by PID, never by name.

## Evidence (scripts are fine; write into `C:\Users\kazda\kiro\gtai-masters\n21\kerf\`)
- `body_contact_sheet.png`: the plate (~800 px wide) on the left; on the right the four packed sheets and the six
  parts on dark asphalt grey `#1d2228`.
- `body_scale_32ppm.png`: Kerf's HOVER cells for column 1, 3 and 5 (toward, profile, away) at both tilts, at the
  size the game draws them at 32 px/m (use Dent's board numbers: 86.4 / median hover height game px per atlas
  px), each beside a p70 police guard standing cell at the same 32 px/m (find the cop's p70 sheet under
  `project/features/characters/art/view/p70/`), and Dent's matching hover cell; then the same image x3
  nearest-neighbour. The question it answers: at 32 px/m, is he a person with two blade arms next to a guard?
- `body_slots.png`: the toward HOVER, away HOVER and torso part at x2 with the detected slot centroids marked.

## Provenance and docs (repo law LEG-04)
- Prompts committed verbatim under `docs/art/prompts/n21/kerf/` (one `.txt` per sheet with exactly the text sent)
  and a `README.md` in the format of `docs/art/prompts/n20/dent/README.md`: references in input order, takes
  kept and rejected with reasons, scale numbers, how to rebuild.
- One manifest `art_src/n21_kerf.manifest.json` in the format of `art_src/n19_move.manifest.json` (every
  master: file `masters:n21/kerf/masters/<name>.png`, accepted true/false, date 2026-11-20, model, prompt_ref,
  references).
- One provenance line per shipped PNG appended to `steam/ai-provenance/2026-11.jsonl` (shared, append-only,
  one line at a time), in the format of its last lines.

## Commit
- One commit for the art + script + `.import` files + prompts + manifest + provenance, staged PER PATH.
  Message: `Draw Kerf as the Swarf Ronin: flight, action and top-view sheets (art only)`.
- Before committing run `node tools/gate/quick.mjs` (read `tools/README.md` for its flags); lint must be green.
  If a size or debt check complains about the new PNGs, report it rather than working around it.
- No mutate in this package (no game code changes).

## Final message
Files changed, takes kept/rejected per sheet with reasons, the scale numbers, slot detection counts, quick gate
result, commit hash, and the paths of the three evidence images.
