# Brief n27-cast-02-feet3: planted feet for the riot cop, SWAT and the lancer (8-drawing walks)

Lane `cast`, branch `n27-cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd). Do NOT switch branches.
**Hard stop 06:37 local** (check `date` often): at the hard stop commit what is green, report and END.
**Commit each character as soon as it is green; the first commit by 05:53** (25 minutes after launch).
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/cast` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Rendering runs `--rendering-driver d3d12`, windowed ones `--position 0,1440` (never the main
display). Kill only your own PIDs, never by name.

## Why
Owner (2026-11-24): "planted feet for the six that fail". The rule (`docs/art/cast-checklist.md`, Feet row): at 32 px/m the
support sole moves <= 2 screen px over the whole contact AND the body jumps <= 12 px between consecutive rendered frames,
every gameplay gait, 70 and 55. Today (`docs/art/cast-audit.md` "Planted feet, n26") riot 14-31 px, SWAT 16-41 px, lancer
13-22 px of sole slide: four drawings per stride, the patrol cop's old problem. The patrol cop was fixed last night by an
8-drawing walk + run on an N-drawing anchored placement with a per-facing, per-drawing support-sole anchor table measured by
the cutter. Read those commits first and REUSE that mechanism exactly; do not invent a second one:
`a8f88999a` (cut and tone the eight-drawing patrol walk and run), `da4dd924e` (pin patrol soles across eight walk and run
drawings), `d0e794f9a`, `a691ce8a1`, `8b360e8be` + `af94f1c6e` (Mulroney: the same on both card hosts; reversal fix and clean
edge), and the warden call just before yours (`git log --oneline -10`), which generalised `CastCards.anchored/padded`.
Tools: `tools/art/cast_patrol_eight.py`, `cast_patrol_soles.py`, `cast_mulroney_eight.py`, `cast_mulroney_soles.py`,
`cast_mulroney_edge.py`, `cast_feet.py` / `cast_feet.mjs`, dev `project/dev/cast/cast_feet.gd`, `cast_stride.gd`.

**Bars are the checklist's and nothing else** (`docs/art/cast-checklist.md`): sole <= 2 px over a contact, body jump <= 12 px
between consecutive rendered frames at 32 px/m. Never invent a stricter bar; quote each number beside the checklist bar.
A feet improvement ships when it is better than `main` on every measured take and breaks nothing, even if one take still misses
the bar: then say which take misses and by how much (these characters are already on; this call replaces their strips).

## Source art (director-generated last night, all ACCEPTED; do not regenerate)
Under `C:\Users\kazda\kiro\gtai-art\foes-n26\`, notes in each folder's `notes.md`:
- riot: `riot8c/out/riot8c_{70,55}_{down,dr,right,ur,up}_t3.png` (ONE facing per image, 8 figures in a 2x4 grid: drawings
  1-4 top row, 5-8 bottom row; support L in 1-3, R in 5-7). Walk 2.8 m/s; the riot has no run.
- SWAT walk: `swat8c/out/swat8c_{70,55}_{down,dr,right,ur,up}_t3.png` (same layout); SWAT run (rifle-post bound, 6 m/s):
  `swat8run/out/swat8run_{70,55}_{down,dr,right,ur,up}_t3.png` (same layout; cut it like the patrol's `cop8run`).
- lancer (`rocket_trooper`, 3.2 m/s): `lancer8/out/lancer8_armed_walk_{70,55}_{a,b}.png`: 8 drawings per BAND, `_a` = 3 bands
  (down, down-right, right), `_b` = 2 bands (up-right, up); same drawing order. Prompts `lancer8/jobs.json`.
Match each character's 8-drawing figure to its shipped body height and tone (shipped `cop_riot_armed_walk.png`,
`swat_armed_walk.png`, `rocket_trooper_armed_walk.png` at each pitch), key-clean (zero strongly green-leading opaque pixels),
pack intermediates in each source folder's `pack/`. Output names: `cop_riot_planted8_armed_walk.png`,
`swat_planted8_armed_walk.png`, `swat_planted8_run.png`, `rocket_trooper_planted8_armed_walk.png` in
`project/features/characters/art/view/{p70,p55}/` (+ `.import`), one `steam/ai-provenance/2026-11.jsonl` line per shipped PNG
(prompt ref `gtai-art/foes-n26/<folder>/jobs.json#<job>`, cutter edits, sha256). The old 4-drawing strips stay selectable by
one value. The riot shield and the SWAT/lancer weapon must stay whole inside every cell.

## Build, in order (one commit per character, the order is by value)
1. Riot cop: cut, anchor table, wire (riot and SWAT ride the cop rig's `StreetCopWalk` rows `cop/head_riot` / `cop/head_swat`;
   the patrol cop's row shows how), measure, commit.
2. SWAT walk + run: same, commit.
3. Lancer: its card path is the lancer's own (`rocket_trooper` row in `cast_cards.json`, `CastFarCard` / `FoeCastView`); put
   its walk on the same anchored placement, measure, commit.
For each: `node tools/art/cast_feet.mjs` (or the `cast_feet.gd` take) right and down-right at 70 and 55, every gait, AND
these, quoted as numbers:
- **Body jump between consecutive rendered frames** on walk, a stop, a turn AND a reversal (aim one way, step the other;
  `test_cast_walk_reversal.gd` exists for Mulroney/patrol: extend it to each new walk). Bar <= 12 px at 32 px/m.
- **Drawings per second** at each gait (expect 5 to 10; above 12 reads as a flicker: say so).
- **The 64 px/m edge measure** (dark pixels outside the silhouette, `tools/art/cast_mulroney_edge.py`) on each new sheet.
- Scale: the new walk's on-screen height within 3% of the shipped walk's at 32 px/m (no size pop between walk and hit/attack).
Then the audit: update `docs/art/cast-audit.md` "Planted feet, n26" -> add a "Planted feet, n27" table: before (`main`
`a3b3f1466`) beside after for each of the three, both pitches, right and down-right, every gait.
Unit tests (`test_cast_*`), `node tools/tests/run_unit.mjs --changed` green, `node tools/gate/quick.mjs` before each commit.

## Films (after each character's commit, not at the end), to `C:\Users\kazda\kiro\gtai-masters\n27\cast\`
**Every clip is a true 1920x1080 at 60 fps.** Godot's Movie Maker renders at the project viewport (1280x800) and ignores
`--resolution`: use the 1920x1080 film path the warden call built tonight (`git log --oneline -8`, its films commit; else
`tools/film/ghost_films.mjs` lines 20 to 50: a scratch project copy with the viewport overridden) and check on one extracted
frame that Rivet stands about 77 px (front) at 32 px/m. Never edit `project/project.godot`.
- `feet_<riot|swat|lancer>_before_after_64ppm_tilt70.png`: before left / after right, same tick and zoom, sole dots per rendered
  frame on the ground, the contact bracketed (the patrol's n26 stills in `gtai-masters\n26\cast\` show the format).
- ONE clip `feet_three_before_after_32.mp4`: each of the three walking across a metre grid, before left / after right, sole dots,
  a 64 px/m inset of the feet; 20 to 40 s, 1920x1080, 60 fps; `ffprobe` it and quote duration, size, fps. Use `tools/film/`.
- Append entries to `frames.json` there (`[{ "file", "title", "ppm", "before", "note" }]`, keep it a valid JSON array; it may
  already hold the warden's entries). Look at every frame you deliver.
Mutate after the commits: `node tools/mutate/mutate.mjs --file=<the placement file you changed most> --max=20 --lines=<changed lines>`.

## Owned files (allowlist; any other path: stop and report a NEED, do not edit it)
`project/features/characters/art/view/{p70,p55}/{cop_riot,swat,rocket_trooper}_planted8_*` (new files only; never overwrite a
shipped PNG), `project/features/characters/street_*.gd` and `cast_*.gd` (walk drawing/placement only),
`project/features/combat/squad/foe_cast_view.gd`, `foe_*_card_view.gd`, `project/data/tables/cast_cards.json` (+ schema),
`project/dev/cast/**`, `tools/art/**`, `tools/film/**` (new files only), `project/tests/unit/test_cast_*.gd`,
`test_street_*.gd` (ADD tests only; never change an existing number) (+ `.uid`), `docs/art/cast-checklist.md`,
`docs/art/cast-audit.md`, `steam/ai-provenance/2026-11.jsonl` (append), `docs/decisions.md` (append one line at a time),
`project/boot/launch_args.gd` `KNOWN_FLAGS` (append one line; then `node tools/debt/debt.mjs --update --accept-regression="<flag> for n27 cast"`),
`tools/debt/baseline.json` (debt tool only), `C:\Users\kazda\kiro\gtai-art\foes-n26\{riot8c,swat8c,swat8run,lancer8}\**`,
`C:\Users\kazda\kiro\gtai-masters\n27\cast\**`.
**Forbidden** (other lanes): `project/boot/prologue/**`, `prologue_*.json`, `project/features/player/**`, `rivet_*` art,
`input_actions.json`, `rivet_motion.json`, `project/features/combat/kills/**`, `project/features/souls/**`, `ghost_*.json`,
`combat.json`, `enemies.json`, `weapons.json`, `bosses.json`, `project/dev/gauntlet/**`, `tools/gauntlet/**`, root
`JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`, the patrol cop's, Mulroney's and the warden's art. No behaviour, speed or timing
change: rendering only (replay digests, quest 1 and prologue tapes must not move). No image generation in this call.

## Repo law
AGENTS.md and STANDARDS.md. Typed GDScript, ~200 lines per file (hard 300), functions <= 40 lines, <= 5 params, `Log` not
`print`. One commit per change, staged per path (`git add <path>`); never `git add -A/./-u`, `commit -a`, `stash`, `reset --hard`,
amend or rebase; never push. `--import` after new art or scripts before committing; commit `.uid`/`.import` with their source.
**Fix lint and format findings in your own edit and go on.** If the pre-commit hook fails on
`tools/film/kill_reel_*.break.test.mjs`, the class cache is stale: run a Godot `--import` and commit again (never skip the
hook). Never fake a number or a frame: unmeasured is never zero.

## Report at the end (and END at the hard stop)
Commits (sha + subject); per character the STEP_M, drawings/s per gait, sole/jump before and after (both pitches, right and
down-right), reversal jump, edge numbers; what still fails and why; mutate score; quick gate line; evidence paths + ffprobe
lines; what you could not do.
