# Brief n28-cast-01-gunner-on: robot gunner A, close the four open checklist points, then switch him on

Lane `cast`, branch `n28-cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd). Do NOT switch branches.
**Hard stop 17:40 local** (check `date` often): at the hard stop commit what is green, write your report and END.
**Start your first `git commit` by 16:55** (the pre-commit hook takes about 12 minutes on this shared machine); start your
last commit no later than 17:25. Commit each finished part; never leave finished work uncommitted.
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/cast` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time (Godot only through `tools/dev/run.mjs`, the film tools, gate or mutate: they go through
`tools/lib/godot.mjs`, which waits under the run's 8 GB RAM cap; `mem-budget: waiting` is not a hang). Rendering runs
`--rendering-driver d3d12`; windowed ones `--position 0,1440` (never the main display). Kill only your own PIDs, never by name.
Run one Godot `--import` first (fresh session on this branch).

## Goal
Robot gunner A (`robot_gunner`, navy plates on a gunmetal frame) is fully drawn and wired on this branch (n27 commits
`9733ddf64` art, `635ca4f4b` `FoeGunnerCardView` + `CastGunnerAnchors`; row `enabled: false`). Read his section
"Robot gunner A (navy plates) as a card" in `docs/art/cast-audit.md` (line ~327) first: soles, jumps, drawings/s, size,
palette, key and identity already PASS. **Four points are OPEN. Measure them, fix what fails (drawing only), shoot two clips,
then set `enabled: true` in `project/data/tables/cast_cards.json` if every point passes.** If one honestly fails and you
cannot fix it in this call, he stays off, and the audit row says exactly what fails and by how much.

## The four open points and their exact bars (these are the checklist's bars, nothing else; never invent a stricter one)
Measure with his card forced on in a dev process (`GTAI_CAST_PREVIEW=robot_gunner`, as in n27).
1. **Live 64 px/m rim** (`tools/art/cast_mulroney_edge.py`, the frozen-exposure method the warden used; write a small frozen
   exposure dev scene for him under `project/dev/cast/` modelled on `cast_warden_poses`/`cast_warden_lineup`): count the dark
   exterior edge px on his live sprite at 64 px/m, 70 and 55, walk + attack + hit + fall. **Bar: the patrol cop's / the warden's
   live count (the warden measured 0 on ten sheets). Pass = no dark exterior rim (comparable to the patrol in the same exposure).**
2. **Ink** (checklist "Ink" row): at the shipped 192 px cell height, trace the front passing pose's left contour; from the first
   alpha >= 128 px to the first px with max RGB >= 48 at y = 70, 75, 80. **Patrol reference 3, 3, 4 px at 70 and 3, 3, 3 at 55.
   Pass = outline closes at native 32 and 64 px/m, runs within about 2 px of the patrol's (the cop8 card passed with
   2/3/6 and 4/2/1), no lost hands, no duplicate hatching.** Look at the frames yourself.
3. **Shadow** (checklist "Shadow" row): he draws his own contact rings (patrol ring set). Write the toggle so the lineup's
   same-pose exposure reaches his rings (a dev-only toggle, or the lineup hides his ring node in the "off" exposure). Count
   pixels darkened by >= 12/255 at 32 px/m, 70 deg, front three-quarter. **Patrol reference 236 px; the cop8 card measured
   248 / 221. Pass = a visible separate ground contact of the same order (roughly 150 to 350 px), feet still on it after the
   shot and during a wound, no baked key shadow.**
4. **Live fight film** of lens tell, fire, hit and fall, every frame looked at: tell (lens lit) appears before the first harmful
   tick (`telegraph_s` 0.9 s from `enemies.json`), active = flash, recoil, recover; hit holds 0.20 s and returns to walk; fall
   power-down to rest on his back, rifle beside him, **no red, no blood** (robot).

## Films (true 1920x1080, 60 fps)
Godot's Movie Maker renders at the project viewport (1280x800) and ignores `--resolution`. **Use the scratch-project path of
`tools/film/cast_warden_films.mjs`** (commit `6b3bdffcd`; it overrides the viewport in a temp copy, never edits
`project/project.godot`). Write `tools/film/cast_gunner_films.mjs` by copying it, and dev scenes modelled on
`project/dev/cast/cast_warden_fight.gd`. Out dir `C:\Users\kazda\kiro\gtai-masters\n28\cast\` (create it):
- `gunner_close_64.mp4`: 64 px/m, tilt 70, one gunner beside the patrol cop and Rivet: walk, lens tell, fire, hit, fall, rest. 15-40 s.
- `gunner_fight_32.mp4`: 32 px/m, tilt 70, Rivet against **three** gunners (card on), they tell, fire, get hit and fall. 15-40 s.
- `gunner_beside_64ppm_tilt70.png` (re-shoot with the card on, beside the patrol cop and Rivet) and `gunner_rim_64.png` (the rim exposure).
`ffprobe` each clip: must print `1920x1080`, `60/1`, a duration of 15-40 s. Extract one frame and check Rivet is about 77 px
tall at 32 px/m (about 154 at 64). Write `frames.json` there: a JSON array, best first, each
`{ "file", "title", "ppm", "before", "note" }` (`before` = file name of the before still, or null).

## Steps, in order
1. `--import`; read the audit section and `git show --stat 635ca4f4b`. Measure points 1-3; fix what fails (drawing only).
2. Commit: the measurement tools/dev scenes + audit rows with numbers (by 16:55).
3. Films (point 4); look at the frames. Then, if all four pass: `enabled: true` for `robot_gunner` in `cast_cards.json`,
   update the audit section heading/verdict and the summary table row for `robot_gunner` (line ~26 and the card table ~233),
   append one `docs/decisions.md` line (`- [2026-11-24] DECISION cast: robot gunner A card on, ...` with the four numbers).
   Run the tests that pin the row (`node tools/tests/run_unit.mjs --changed`, and `--select=test_cast_gunner`); if a scenario
   or tape moves when he is on, it must not: he is rendering only (replay digests, quest 1 and prologue tapes must stay
   byte-identical). `node tools/gate/quick.mjs`, commit.
4. Mutate (after the commit): `node tools/mutate/mutate.mjs --file=project/features/combat/squad/foe_gunner_card_view.gd --max=20 --tests=test_cast_gunner`
   (check the real path first; give it a 10-minute budget; if it does not finish, quote what it printed). Quote the score.

## Owned files (allowlist; any other path: stop and report a NEED, do not edit it)
`project/features/characters/art/view/{p70,p55}/robot_gunner_*`, `project/data/tables/cast_cards.json` (+ schema),
`project/features/characters/cast_*.gd`, `street_*.gd` (card drawing/placement only), `foe_*.gd`,
`project/features/combat/squad/foe_cast_view.gd`, `foe_*_card_view.gd`, `cast_*.gd` there,
`project/features/arena/arena_robot_rigs.gd` and `arena_wave_cards.gd` (smallest edit, drawing only), `project/dev/cast/**`,
`tools/art/**`, `tools/film/**` (new files only), `project/tests/unit/test_cast_*.gd`, `test_street_*.gd` (ADD only) (+ `.uid`),
`docs/art/cast-checklist.md`, `docs/art/cast-audit.md`, `steam/ai-provenance/2026-11.jsonl` (append), `docs/decisions.md`
(append one line at a time), `project/boot/launch_args.gd` `KNOWN_FLAGS` (append one line; then
`node tools/debt/debt.mjs --update --accept-regression="<flag> for n28 cast"`), `tools/debt/baseline.json` (debt tool only),
`C:\Users\kazda\kiro\gtai-masters\n28\cast\**`.
**Forbidden** (other lanes): `project/boot/prologue/**`, `prologue_*.json`, `project/features/player/**`, `rivet_*` art,
`input_actions.json`, `rivet_motion.json`, `project/features/combat/kills/**`, `project/features/souls/**`, `ghost_*.json`,
`combat.json`, `enemies.json`, `weapons.json`, `bosses.json`, `fx_atlas.png`, `weapon_fx_electro.gd`, the deflect VFX,
`project/dev/gauntlet/**`, `tools/gauntlet/**`, root `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`, every other character's
shipped art. No behaviour, speed or timing change. No image generation in this call (the art is accepted).

## Repo law
AGENTS.md and STANDARDS.md. Typed GDScript, ~200 lines per file (hard 300), functions <= 40 lines, <= 5 params, `Log` not
`print`. One commit per change, staged per path (`git add <path>`); never `git add -A/./-u`, `commit -a`, `stash`,
`reset --hard`, amend or rebase; never push. `--import` after new art or scripts before committing; commit `.uid`/`.import`
with their source. `node tools/gate/quick.mjs` before each commit. **Fix lint and format findings in your own edit and go on.**
If the pre-commit hook fails on `tools/film/kill_reel_*.break.test.mjs`, the class cache is stale: run a Godot `--import`
and commit again (never skip the hook). Never fake a number or a frame: unmeasured is never zero.

## Report at the end (and END at the hard stop)
Commits (sha + subject); the four points, each number beside its bar; enabled true/false and why; film paths + ffprobe
lines + Rivet px check; mutate score; quick gate line; any NEED; what you could not do.
