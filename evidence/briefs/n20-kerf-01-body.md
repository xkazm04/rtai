# n20-kerf brief 01: Kerf's new body art (the Gantry Wraith), masters, cut, packed sheets

Lane `kerf`, worktree `C:\Users\kazda\kiro\gtai-wt\n20-kerf`, branch `n20-kerf`. Tonight is a VISUAL night:
the four ghost forms become legless flying spectres. This package is ART ONLY: generate, look, cut, pack,
commit. Do NOT wire anything into game code in this package (no `.gd` edits except your new cut script).

## Goal
Kerf's new body as game sprites, recognisably the owner's chosen plate
`C:\Users\kazda\kiro\gtai-masters\n20\concepts\kerf_a.png` ("Gantry Wraith": a long teal dart of a
laser-cutter head, mirror-lens eye at the nose, ribbed cable loops arched over the back, hazard-striped
cross-beam stubs, two slim arms folded back along the flanks with emitter needles; NO legs). Look at that
plate first. The director's main worry: in the plate he reads like a small jet. In our sprites he must
read as a CREATURE: the lens is his eye, the nose is his face, the cable loops behave like hackles.

Two image sheets plus one derived sheet:
1. `kerf_parts_top` - top-view cutout parts for the rig (KerfRig, seen straight down).
2. `kerf_hover_70` - the tilted figure at the 70 degree play tilt: 5 facings x 3 moods.
3. `kerf_hover_55` - the same at the 55 degree tilt, made from the accepted 70 sheet.

## Image prompts: use them VERBATIM (the director wrote them; do not reword, shorten or "improve")
Use your built-in `image_gen`. Attach the references in the order listed (image 1, image 2, ...).
Each prompt below = the sheet text followed by a blank line and the STYLE line. If the image service
reports a usage or rate limit, wait five minutes and retry; meanwhile do the cut script.

### STYLE line (append to each prompt)
Flat-fill cutout game sprite art: bold black brush-ink outline, flat fills with light cel shading in luminous spectral TEAL (#2EC4B6, with paler mint highlights and a deeper teal shade), the steel plates, rivets and ribbed hoses drawn as black ink linework inside the teal, a few faint dull ochre rust specks, black-and-ochre hazard stripes on the cross-beam stubs, a pale glassy blue-white mirror lens, light riso print grain, opaque fills (no transparency, no glow halo, no cast shadow), no text, no labels, no numbers, no red, no orange. Background: flat solid chroma green #00B140 everywhere outside the figures.

### Sheet 1: `kerf_parts_top` (landscape 1536x1024)
References: image 1 = `C:\Users\kazda\kiro\gtai-masters\n20\concepts\kerf_a.png`;
image 2 = `project/features/souls/art/kerf/hull.png` composited onto flat #00B140 (make that ref PNG
with a script, save it beside the masters as `refs/style_hull_green.png`).

Prompt:
A part sheet for a 2D cutout game rig of a hovering spectral machine: a 3 x 2 grid of equal cells (three per row, two rows), every part seen from DIRECTLY ABOVE (a true 90-degree top-down view), each part centred alone in its own cell with green margin all round, nothing touching a cell edge. Image 1 is the character to match: KERF, the Gantry Wraith, a freed laser-cutter head; his straight-down view is the top-right inset of image 1, match that silhouette and those details. Image 2 shows the ink, fill and print style of our cutout part sheets: match its line work and print grain, not its grey colours and not its shape. Cells: Top-left: the HULL from straight above, nose pointing DOWN the page: a narrow arrowhead cutting head about three times as long as it is wide, riveted angular plates, three short slots on its back, a round EMPTY socket ring near the nose (the lens is a separate part), a short pointed cutter nozzle at the very tip, and one short stub cross-beam across its middle sticking out on both sides with black-and-ochre hazard stripes, each end finished with a small round joint knuckle. Top-middle: the CABLE LOOPS from straight above as they sit on his back: two ribbed hose loops side by side forming one tall horseshoe arch, both ends cut flat where they plug into the hull. Top-right: one ARM from above lying along the page from left to right: a long slim jointed strut, a round joint disc at the left end, a small elbow joint a third of the way along, ending at the right in a fine pointed emitter needle. Bottom-left: the LENS, open: a round mirror lens seen face-on, pale glassy blue-white with one bright diagonal glint, a thick ink rim and a thin teal ring around it. Bottom-middle: the same LENS half-narrowed: two curved steel shutter lids closing from top and bottom leave a wide almond-shaped opening, same size and rim. Bottom-right: the same LENS narrowed to a slit: the shutter lids almost closed, leaving one thin bright horizontal slit of glass, same size and rim. Kerf has NO LEGS and no limbs other than the two arms.

### Sheet 2: `kerf_hover_70` (portrait 1024x1536)
References: image 1 = the plate `kerf_a.png`; image 2 = a crop of column 1 (the five standing facings,
one per row) of `project/features/souls/art/view/p70/kerf_run8.png` on black, saved as
`refs/tilt70_facings.png`.

Prompt:
A character sprite sheet for a 2D top-down action game: a grid of 3 columns and 5 rows of equal cells, one figure centred alone in each cell with green margin all round, every figure drawn at the same size and scale, seen from above at a steep 70-degree camera tilt (we look down on his back and top; the far end of his body sits higher on the page). Image 1 is the character to match: KERF, the Gantry Wraith, a freed laser-cutter head flying level a metre above the ground. Keep the silhouette and every detail of the large hero drawing in image 1: the long narrow angular head, the round mirror-lens eye at the nose with a short cutter nozzle under it, the tall horseshoe of ribbed cable loops arched over his back, the short hazard-striped cross-beam stubs as shoulders, and two long slim jointed arms with fine emitter needles folded back along his flanks. Image 2 shows only the camera tilt and the five facings in order, one per row: match its viewing angle and the facing of each row, never its body (that old body had legs; ours has none). Rows, top to bottom: (1) flying TOWARD the viewer, nose and lens facing us; (2) three-quarter toward, nose pointing down and to the right; (3) right profile, nose pointing right; (4) three-quarter away, nose pointing up and to the right; (5) flying AWAY, we see his back and the cable loops, the nose hidden beyond. Columns, left to right, the same body in three moods: (A) POISED: at rest and coiled like a fencer en garde, nose dipped low, lens wide open and bright, cable loops raised tall like the hackles of a cat, arms held a little out from the flanks; (B) CRUISE: body level and stretched long and narrow like a dart, lens half-narrowed, cable loops laid flat back along the spine, arms tucked tight along the flanks; (C) LUNGE: nose thrust forward and the whole body at its longest, lens narrowed to one bright slit, cable loops swept flat back, arms swept straight back like fins. He is a creature, not a vehicle: the lens is his eye and the nose is his face. NO LEGS, no feet, nothing hangs below the body in any cell. No beams, streamers, trails, wisps or sparks behind him (the game draws those), no ground shadow.

### Sheet 3: `kerf_hover_55` (portrait 1024x1536), only after sheet 2 is accepted
References: image 1 = your accepted `kerf_hover_70` master; image 2 = the plate `kerf_a.png`;
image 3 = the same column-1 crop of `project/features/souls/art/view/p55/kerf_run8.png`, saved as
`refs/tilt55_facings.png`.

Prompt:
Redraw image 1, a character sprite sheet of 3 columns and 5 rows, cell for cell, with the same character, the same three moods per row, the same facings, the same size, line and colours, but seen from a lower 55-degree camera tilt: we see more of his side and his underside edge and a little less of his back, so every figure is a little shorter on the page and the cable loops stand up more against the sky. Image 2 is the character's identity (KERF, the Gantry Wraith). Image 3 shows only the 55-degree camera tilt and the five facings in order, one per row: match its viewing angle, never its body (that old body had legs; ours has none). One figure centred alone in each cell with green margin all round. NO LEGS, no feet, nothing hangs below the body in any cell. No beams, streamers, trails, wisps or sparks behind him, no ground shadow.

## Look at every image before it ships
Open each master and judge it against the plate. Re-roll (same prompt, at most twice per sheet) a sheet
that grew legs or feet, lost the plate's silhouette (long narrow dart + arch of cable loops + lens at the
nose), came out muddy or grey instead of luminous teal, broke the grid, or lost the facing order. In the
final message say for each sheet which take you kept and why (and what the rejected takes got wrong).

## Cut and pack (a script, never by hand)
- Masters (all takes, kept and rejected) go to `C:\Users\kazda\kiro\gtai-masters\n20\kerf\masters\`
  (create it; never into git), refs into `...\masters\refs\`.
- New script `tools/art/kerf_n20_cut.py` (`py -3 -I`), deterministic, documented docstring like
  `tools/art/ghost_pack.py`: keys #00B140 by flood from the sheet border/cell margins (NOT a global hue
  threshold: the body is teal and must not lose edges; clean the green fringe on the ink outline),
  splits the grid by the green gutters, crops each part tight with a 2 px pad.
  - Sheet 1 -> `project/features/souls/art/kerf/spectral/{hull,cables,arm,lens_open,lens_half,lens_slit}.png`
    (hull nose turned to point +x, i.e. rotate so the nose points RIGHT like the existing `hull.png`;
    arm lying along +x with the joint disc on the left; lenses as cut).
  - Sheets 2 and 3 -> packed grids `project/features/souls/art/view/p70/kerf_hover.png` and
    `project/features/souls/art/view/p55/kerf_hover.png`: 5 rows (toward, 3/4 toward right, right
    profile, 3/4 away right, away) x 3 columns (poised, cruise, lunge) in the layout `GhostDrawn` /
    `ghost_pack.py` reads (equal cells, each figure centred on the cell; there are no feet, so seat the
    figure's VISUAL CENTRE (alpha mass) on the cell centre, not a baseline). Scale: measure the old
    grid's px per metre (`KerfRig` builds `GhostDrawn.new("kerf", 1.8, ...)`: the old figure is 1.8 m
    tall; measure its median figure height in px in `p70/kerf_run8.png`), then scale so the
    right-profile CRUISE figure's nose-to-tail length is 1.5 m at that px/m. State the numbers you used.
    p55 to the same px/m as p70.
  - Write the cut sizes and per-cell alpha-mass offsets to `project/features/souls/art/kerf/spectral/cut.json`.
- Run Godot `--import` once so `.import` files exist:
  `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/kerf` first, Godot is
  `C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`
  (`--headless --path project --import`). One Godot process at a time. Free your own processes by PID, never by name.

## Evidence to make (scripts are fine; put scratch under `C:\Users\kazda\kiro\gtai-masters\n20\kerf\`)
- `body_contact_sheet.png`: the plate (scaled to ~800 px wide) on the left; on the right the three
  packed sheets and the six parts on dark asphalt grey `#1d2228`.
- `body_scale_32ppm.png`: the right-profile and 3/4-toward POISED cells at the scale the game draws them
  at 32 px/m (old Kerf p70 card height in metres is `KerfRig` `CARD_M`/the drawn grid; Kerf is about
  1.35 m nose to tail) beside a p70 police guard standing cell at the same 32 px/m (find the cop's p70
  sheet under `project/features/characters/art/view/p70/`), then the same image x3 nearest-neighbour.

## Provenance and docs (repo law LEG-04)
- Prompts committed verbatim under `docs/art/prompts/n20/kerf/` (one `.md` per sheet with the
  references list and which take shipped).
- One manifest `art_src/n20_kerf.manifest.json` in the format of `art_src/n19_move.manifest.json`
  (every master: file `masters:n20/kerf/masters/<name>.png`, accepted true/false, date 2026-11-20,
  model, prompt_ref, references).
- One provenance line per shipped PNG appended (one line at a time, append-only, it is a shared file)
  to `steam/ai-provenance/2026-11.jsonl`, in the format of its last lines.

## Commit
- One commit for the art + script + import files + prompts + manifest + provenance, staged PER PATH
  (no `git add -A/./-u`, no stash, no reset --hard, no commit -a). Commit `.import` files with their PNGs.
- Before committing: `node tools/lint/lint.mjs` (or `node tools/gate/quick.mjs` if lint alone is not the
  pre-commit path; read `tools/README.md`) must be green. If the lint size/debt check complains about the
  new PNGs, report it rather than working around it.
- Do not touch: any `.gd` outside `tools/art/`, any other ghost's art, `ghost_forms.json`, sims, goldens.

## Final message
Files changed, the takes kept/rejected per sheet with reasons, the scale numbers, lint result, commit hash,
and the paths of the two evidence images.
