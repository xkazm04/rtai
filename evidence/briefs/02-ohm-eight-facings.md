# Brief 02 (lane polish): Ohm's body sheets redrawn with eight facings, no mirror

Hard stop: 75 minutes after you start (check `date` at the start and write the stop time down). Last commit
10 minutes before it. If you run short, the order of value is: masters generated and reviewed (part 1) >
comparison board (part 2) > cut + wiring (part 3). Commit what is green, stop, report exactly where you stopped.

## Environment (every Godot / gate / film run)
- `export APPDATA=C:/Users/kazda/kiro/gtai-n21/appdata/polish`
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- One Godot process at a time; windowed runs use `--position 0,1440`; kill only your own PIDs. Nobody rebuilds native.
- After new art lands, run a Godot `--import` before committing (`"$GODOT_BIN" --headless --path project --import`).

## Why
Today the spectral Ohm draws 5 facing rows (toward, toward_right, right, away_right, away) and **mirrors** them
(`flip_h`) for the three left facings, so his staff jumps to the other hand when he turns left. The owner wants a
true left. On n20 six separate left-row takes failed: drawn alone, the left figure came out taller and drawn
differently (`C:/Users/kazda/kiro/gtai-masters/n20/verdicts/ohm_left_vs_mirror_p70.png`). So tonight left and right
are drawn **in the same image**, every time.

## Owned files (allowlist; any other path: stop and report a NEED, do not edit it)
- `project/features/souls/ohm_*.gd`, `project/features/souls/ghost_drawn.gd` (only the facing-row selection, if that
  is where the mirror lives), their tests `project/tests/unit/test_ohm_*.gd` / `test_ghost_drawn*.gd`
- `project/features/souls/art/view/p70/ohm_spec_*`, `project/features/souls/art/view/p55/ohm_spec_*`
- `tools/art/ohm_spectral_cut.py` or a new `tools/art/ohm_n21_eight_cut.py` (prefer extending the existing one if it
  stays under ~300 lines per file; else a new file that imports from it)
- `docs/art/prompts/n21/polish/` (new), `art_src/n21_polish_ohm.manifest.json` (new)
- `steam/ai-provenance/2026-11.jsonl` (append only, one line per shipped PNG)
- `docs/decisions.md` (append one line only)
Masters go to `C:/Users/kazda/kiro/gtai-masters/n21/polish/masters/` (never into git).
Scratch and boards go to `C:/Users/kazda/kiro/gtai-masters/n21/polish/ohm/`.

## Part 1: six images (two tilts x three pose pairs), prompts VERBATIM
Use your built-in `image_gen`, landscape 1536 x 1024. Six jobs: tilt in {p70, p55} x pair in
{A: idle + drift, B: charged + thrust, C: recovery + struck}. Every job uses the prompt below **word for word**,
with only the three bracketed slots filled in from the table. Commit each final prompt as
`docs/art/prompts/n21/polish/ohm_eight_<tilt>_<pair>.md` (a `## References` list and a `## Prompt` section, as in
`docs/art/prompts/n20/ohm/ohm_spec_p70.md`, plus a `## Take review` line per take).

References, in this order, for every job:
1. `C:/Users/kazda/kiro/gtai-masters/n20/ohm/masters/ohm_spec_<tilt>_t3.png` (the accepted, shipped sheet for that
   tilt: the character AND the style to match exactly)
2. `C:/Users/kazda/kiro/gtai-masters/n20/concepts/ohm_c.png` (the owner's plate)
3. `C:/Users/kazda/kiro/gtai-masters/n6/ghost-forms/gen/r4/out/ohm_parts.png` (our ink and fill style)
For pairs B and C of a tilt, once pair A of that tilt is accepted, add it as reference 4 with the extra sentence
given below, so the three images of a tilt agree on size and drawing.

Slots:
| slot | p70 | p55 |
|---|---|---|
| {TILT} | `looking down at 70 degrees (a steep top-down three-quarter view: the top of the head, the shoulders and the tops of the three jars are clearly visible, the coat is foreshortened)` | `looking down at 55 degrees (a high three-quarter view: the head, the shoulders and the three jars are clearly visible, the coat less foreshortened than seen from straight above)` |

| slot | A | B | C |
|---|---|---|---|
| {POSE1} | `hovering idle: stooped, the staff held upright beside him in his right hand, the coat hanging still into its misty hem` | `charged: drawn up tall, the staff raised high overhead in his right hand, the forked copper tip pointing up` | `recovery: hunched, pulling the staff back across his chest in his right hand, the coat swinging forward` |
| {POSE2} | `drifting forward: leaning forward from the waist, the staff held out ahead of him at an angle in his right hand like a walking stick whose foot hangs just above the ground, the coat hem and beard streaming backwards` | `the thrust: lunging forward, both hands on the staff, his right hand behind his left, thrusting it straight out ahead of him at shoulder height in the direction he faces, the forked tip foremost` | `struck: thrown backwards off balance, head tipped back, the staff still gripped in his right hand swinging away from him, the coat hem flaring forward` |

### The prompt (verbatim)

```
Image 1 is the character AND the style to match exactly: OHM, the Lightning Rod, our finished game sprite sheet. Draw the very same figure: the same size in the cell, the same proportions, the same ink line weight, the same translucent teal fill, the same goggles, beard, riveted shoulder plates, ragged coat, three jars and staff. Image 2 is the original concept of the same character, for his details only. Image 3 shows our ink, fill and print style. Do not redesign him.

OHM is a stooped old robot wizard who is a floating teal spectre: cracked round goggles, a short bristly cable-wire beard, riveted shoulder plates over a long ragged insulating coat of rubber sheets whose hem frays into teal mist and a few loose wires, NO LEGS AND NO FEET, three big glass capacitor jars in a row on his back joined by curling hoses, and a tall staff that is a lightning rod ending in a FORKED tip of two copper prongs. The staff is ALWAYS held in his own RIGHT hand, in every cell, whichever way he faces.

Draw a character turnaround sheet of OHM: a grid of 4 columns and 4 rows of equal cells, one full figure centred alone in each cell with green margin all round, every figure the same size and the same scale, all seen from a camera high above and in front, {TILT}. The two left-facing and right-facing figures of each pair are drawn as true turns of the same body, not as mirror images: when he faces right the staff is on the near side of his body, in front of him; when he faces left the staff is on the far side of his body, partly hidden behind his coat.

Rows 1 and 2 show pose one, {POSE1}. Rows 3 and 4 show pose two, {POSE2}.
Columns, the same in every pose: column 1 turned three-quarters toward the viewer (row 1 and row 3: turned to the RIGHT of the picture, the staff in front of his body on the picture's left; row 2 and row 4: turned to the LEFT of the picture, the staff on the far side of his body on the picture's left). Column 2 in side profile (rows 1 and 3: facing the RIGHT edge of the picture, the staff on the near side in front of him; rows 2 and 4: facing the LEFT edge of the picture, the staff on the far side behind him). Column 3 turned three-quarters away from the viewer, we see his back and the three jars (rows 1 and 3: turned to the RIGHT of the picture, the staff on the picture's right, near side; rows 2 and 4: turned to the LEFT of the picture, the staff on the picture's right, far side). Column 4: rows 1 and 3 face straight toward the viewer, the staff on the picture's left; rows 2 and 4 face straight away from the viewer, we see his back with all three jars side by side, the staff on the picture's right.

In every cell the insides of the three glass jars on his back are painted flat solid magenta (#FF00FF), an even placeholder colour with no glow and no shading, only inside the jar glass, wherever the jars can be seen from that angle. The hem of the coat ends in short ink-outlined teal wisps about a third of his height below the coat and never touches the bottom of the cell; there is nothing under him.

Style: a sprite sheet for a shipped top-down action game, in a hand-inked comic print style: bold black brush-ink outlines around every shape, flat and lightly shaded fills, light cross-hatching, a hint of risograph print grain. Match image 1 exactly. The background of the whole sheet is one flat, even chroma green (#00B140): no shadow, no gradient, no ground, no floor glow, nothing drawn on the green. The figure is a translucent glowing TEAL (#2EC4B6) spectre lit from within, the black ink linework visible through the glow, faint worn steel and rust inside it; only the two copper prongs of the staff keep their own copper colour. Every edge of the figure, including the misty hem, is closed by a bold black ink outline, so it stands cleanly off the green. Original design. No text, no letters, no numbers, no labels, no grid lines, no borders, no watermark.
```

Extra sentence for pairs B and C when reference 4 is attached (append it as the last paragraph, verbatim):
`Image 4 is another page of this same turnaround sheet: draw the figure at exactly the size and in exactly the drawing of image 4.`

### Review every take yourself (look at the image), before cutting
Reject and re-roll (at most twice per job, so at most 3 takes) if any of these holds:
- a figure has legs or feet, or the hem touches the cell bottom;
- the staff is not in his own right hand in any cell (check each left/right pair: it must NOT be a mirror image);
- a left-facing figure is visibly taller, shorter or differently drawn than its right-facing partner in the row above;
- the grid is not 4 x 4, or figures overlap a neighbouring cell;
- the jars are not magenta where visible, or the drawing is muddy next to reference 1.
Record each take's verdict in the prompt file's `## Take review`. Keep the best take even if imperfect and say
what is wrong with it.

## Part 2: the comparison board (the ship / keep-mirror decision is made on this)
Before wiring, build `C:/Users/kazda/kiro/gtai-masters/n21/polish/ohm/ohm_eight_vs_shipped_<tilt>_<ppm>.png` for
tilt p70 and p55 at 32 and 64 px/m (4 boards): for each of the 6 poses, the shipped right cell, the new right cell,
the shipped mirror (what the game draws today for left), the new left cell, at the game's draw scale for that
px/m (`draw_scale_32ppm` in `ohm_spec_cells.json`; 64 px/m is twice that), on the game's dark road colour, with a
patrol cop at the same scale for size (`project/features/characters/art/view/p70/cop_patrol_card.png` as the
existing cut script does). Use a script under `tools/art/` (no hand edits). Labels on boards are fine (they are
boards, not game art).
Then judge: the new set ships only if the new left cells and the new right cells are **at least as good** as the
shipped cells at both 32 and 64 px/m (same height within 5%, same detail, staff readable, jars visible in the
away facings). If not, keep the mirror: do not wire, commit the prompts + manifest + the board script only, and
say so with the board path.

## Part 3: cut and wire (only if Part 2 passes)
- Cut with the script: same pipeline as `tools/art/ohm_spectral_cut.py` (keying, figure finding, jar masks into
  `_jars` sheets, fork tip positions `forks_row_major`, the height calibration to the shipped `legacy_median_height_px`
  so the new figures draw at the shipped height). Rows become eight facings in this order:
  `toward, toward_right, right, away_right, away, away_left, left, toward_left` (update `ohm_spec_cells.json`
  `rows`). Sheets stay `ohm_spec_hover.png` (idle, drift) and `ohm_spec_act.png` (charged, thrust, recovery,
  struck) + their `_jars` twins, per tilt, so the loader keeps its file names.
- Wiring: under the spectral look no Ohm facing sets `flip_h` when the sheet has 8 rows; the fork tip and the jar
  overlay follow the same cell (`ohm_fork.gd`, `ohm_jars.gd` read `flip_h` today: keep them correct). A 5-row sheet
  still mirrors (so the old art keeps working), i.e. the switch is the data, not code.
- Tests: a unit test that loads the shipped p70 and p55 `ohm_spec_cells.json`, asserts 8 rows, and asserts that for
  every one of the 8 facing directions the spectral Ohm sprite has `flip_h == false` and selects the matching row;
  a test that a 5-row meta still mirrors the left facings. Run `node tools/tests/run_unit.mjs --changed` green.
- Manifest `art_src/n21_polish_ohm.manifest.json` (same format as `art_src/n20_ohm.manifest.json`: masters as
  `masters:n21/polish/masters/...`, prompts, refs, cut command), and one provenance line per shipped PNG in
  `steam/ai-provenance/2026-11.jsonl` (same format as the n20 Ohm lines).
- One line in `docs/decisions.md`:
  `- [2026-11-20] DECISION ohm art: eight drawn facings per tilt, left and right drawn in the same image by pose pair; no mirror; a 5-row sheet still mirrors. Rejected: patching left rows onto the n20 sheet (six takes failed on n20).`
- Godot `--import`, `node tools/gate/quick.mjs`, commit ("Draw Ohm's eight facings; drop the left mirror").
- Then stills: `node tools/film/ghost_films.mjs --ghost=ohm --look=spectral --takes=move --stills=<two ticks where he
  faces left and right, read ghost_films_plan.mjs for the drive>` into `C:/Users/kazda/kiro/gtai-masters/n21/polish/ohm/`.
  If the film tool's options differ, read `tools/film/ghost_films_plan.mjs` and use what it supports.
- Mutate after the commit: `node tools/mutate/mutate.mjs --file=features/souls/ohm_drawn.gd --max=20 --lines=<changed lines>`
  and quote killed/(killed+survived).

## Repo law (binding)
- AGENTS.md / STANDARDS.md. Typed GDScript, functions <= 40 lines, files about 200 lines (hard 300), <= 5 params,
  `Log` not `print`. Python tools: plain, no hand edits of art.
- Stage per path. No `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push.
- Fix lint and format findings in your own edit and go on (`node tools/gate/quick.mjs` before each commit).
- No sim, replay, parity or bake digest may move: this is drawing only. Colour law: teal is souls only.
- Keep weapon and injury words out of image prompts (the prompt above is already clean; do not add any).
- If the image service reports a usage or rate limit, wait five minutes and retry; meanwhile build the board script.

## Report back
Takes per job with verdicts and master paths, the four board paths and your ship/keep verdict with the reason,
commits (hash + subject), test results, the mutate score line, the still paths, and anything not done and why.
