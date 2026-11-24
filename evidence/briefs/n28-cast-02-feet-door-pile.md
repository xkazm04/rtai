# Brief n28-cast-02-feet-door-pile: planted feet for the door carrier and the pile-driver (anchored placement, no new art)

Lane `cast`, branch `n28-cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd). Do NOT switch branches.
**Hard stop HARDSTOP local** (check `date` often): at the hard stop commit what is green, report and END.
**Start the door carrier's `git commit` by COMMIT1** (the pre-commit hook takes about 12 minutes here), then the pile-driver;
start your last commit no later than LASTCOMMIT. Never leave finished work uncommitted.
Godot only through `tools/dev/run.mjs`, the film tools, gate or mutate (they go through `tools/lib/godot.mjs`, which waits
under the run's 8 GB RAM cap; `mem-budget: waiting` is not a hang).
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/cast` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Rendering runs `--rendering-driver d3d12`, windowed ones `--position 0,1440` (never the main
display). Kill only your own PIDs, never by name.

## Why
Owner (2026-11-24): "planted feet for the six that fail". The rule (`docs/art/cast-checklist.md`, Feet row): at 32 px/m the
support sole moves <= 2 screen px over the whole contact AND the body jumps <= 12 px between consecutive rendered frames, every
gameplay gait, 70 and 55. `docs/art/cast-audit.md` ("Planted feet, n26" and the n27 table the previous call added):
- door carrier `shield_robot` (1.6 m/s): sole 6.6-7.4 px, body jump 11.8-13.3 px; down-right sole unmeasurable (slab hides it).
- pile-driver `war_machine` (1.8 m/s): sole 23-29 px, jump 11.9-17.8 px; its 70 profile shows no identifiable lift.
They keep their shipped drawings. Put their card walks on the SAME N-drawing anchored placement the patrol cop, Mulroney, the
warden, riot, SWAT and the lancer use (`CastCards.anchored`, `StreetCopWalk.Contact`/`RigContact`, the per-facing per-drawing
support-sole anchor table measured by the cutter; read `git log --oneline -30 -- project/features/characters/ tools/art/`),
with tables measured from their shipped art. Do not invent a second mechanism.

## Build, in order
1. Door carrier: measure the anchor table from its shipped walk sheets (`shield_robot_*` at both pitches), wire it, choose
   STEP_M from the drawn advance so the body jump stays <= 12 px, record drawings/s (expect 5 to 10). Where the sole is truly
   hidden (down-right, behind the slab), measure the body anchor instead and say so; never fake a pass. The shove lane and the
   slab-separates-on-death behaviour must stay exactly as they are. Commit.
2. Pile-driver: same. Note from the audit: the pile-driver CARD is off (`enabled: false`) and the wave draws an enlarged thug
   rig with procedural legs. Plant the card's walk anyway (so the card can pass Feet when the rest of its checklist is done),
   keep it `enabled: false`, and say what else on its checklist still fails. If its drawings have no identifiable lift in a
   facing, say so with a still. Owner on size, verbatim: "we should be careful with too large bosses and enemies to avoid very
   heavy and slow oponents very easy to beat by just moving": do NOT enlarge it; report its on-screen height at 32 px/m. Commit.
3. Re-run `node tools/art/cast_feet.mjs` for both; numbers quoted: sole / body jump, right and down-right, 70 and 55, plus the
   body jump on a stop, a turn AND a reversal (aim one way, step the other; extend `test_cast_walk_reversal.gd`), drawings/s,
   and before (`main` `d0ab9d03a`) beside after. Add both to the "Planted feet, n27" table (add rows; title them n28) in `docs/art/cast-audit.md`.
4. Item 4 of the lane, one measured answer: does the shared impact-outline material draw dark teeth on other cards' HITS at
   64 px/m (it did on Mulroney's; `af94f1c6e` cleaned his cut)? Measure with `tools/art/cast_mulroney_edge.py` (or its method)
   on a rendered 64 px/m hit frame of the patrol cop, riot, SWAT, lancer, door carrier and the warden: dark pixels outside the
   silhouette per card, before and after the impact pulse. If any card shows teeth, fix it the way Mulroney's was fixed
   (card material path, `CastCards.painted_ink`), one commit, and show a before/after still. If none, say so with the numbers.
5. Unit tests (`test_cast_*`), `node tools/tests/run_unit.mjs --changed` green, `node tools/gate/quick.mjs` before each commit.
   Mutate after the commits: `node tools/mutate/mutate.mjs --file=<the placement file you changed most> --max=20 --lines=<changed lines>`.

## Films (after each commit), to `C:\Users\kazda\kiro\gtai-masters\n28\cast\`
**True 1920x1080 only:** reuse the scratch-project path of `tools/film/cast_foot_films.mjs` / `cast_warden_films.mjs`
(Movie Maker ignores `--resolution`; never edit `project/project.godot`). Update `frames.json` there (JSON array, best first).
`feet_{door,pile}_before_after_64ppm_tilt70.png` (before left / after right, same tick and zoom, sole dots per rendered frame,
contact bracketed), `impact_edge_64.png` (item 4: the hit frames side by side at 64 px/m), and one clip
`feet_door_pile_before_after_32.mp4` (each walking across a metre grid, before left / after right, sole dots, a 64 px/m inset of
the feet; 20 to 40 s, 1920x1080, 60 fps; `ffprobe` it). Append entries to `frames.json` there (valid JSON array). Look at every
frame you deliver.

## Owned files (allowlist; any other path: stop and report a NEED, do not edit it)
`project/features/characters/street_*.gd`, `cast_*.gd`, `foe_*.gd` (walk drawing/placement and card material only),
`project/features/combat/squad/foe_*.gd` (drawing only), `project/features/arena/arena_wave_cards.gd` (smallest edit),
`project/data/tables/cast_cards.json` (+ schema), `project/dev/cast/**`, `tools/art/**`, `tools/film/**` (new files only),
`project/tests/unit/test_cast_*.gd`, `test_street_*.gd` (ADD only) (+ `.uid`), `docs/art/cast-checklist.md`,
`docs/art/cast-audit.md`, `steam/ai-provenance/2026-11.jsonl` (append), `docs/decisions.md` (append one line at a time),
`project/boot/launch_args.gd` `KNOWN_FLAGS` (append one line; then `node tools/debt/debt.mjs --update --accept-regression="<flag> for n28 cast"`),
`tools/debt/baseline.json` (debt tool only), `C:\Users\kazda\kiro\gtai-masters\n28\cast\**`.
**Forbidden** (other lanes): `project/boot/prologue/**`, `prologue_*.json`, `project/features/player/**`, `rivet_*` art,
`input_actions.json`, `rivet_motion.json`, `project/features/combat/kills/**`, `project/features/souls/**`, `ghost_*.json`,
`combat.json`, `enemies.json`, `weapons.json`, `bosses.json`, `fx_atlas.png`, `weapon_fx_electro.gd`, the deflect VFX
(combat lane's this run; if item 4's fix would need the shared impact-outline material outside the card path, write a NEED
instead), `project/dev/gauntlet/**`, `tools/gauntlet/**`, root
`JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`, any shipped PNG (no art changes in this call). No behaviour, speed or timing
change: rendering only (replay digests, quest 1 and prologue tapes must not move). No image generation in this call.

## Repo law
AGENTS.md and STANDARDS.md. Typed GDScript, ~200 lines per file (hard 300), functions <= 40 lines, <= 5 params, `Log` not
`print`. One commit per change, staged per path (`git add <path>`); never `git add -A/./-u`, `commit -a`, `stash`, `reset --hard`,
amend or rebase; never push. `--import` after new scripts before committing; commit `.uid` with its source.
**Fix lint and format findings in your own edit and go on.** If the pre-commit hook fails on
`tools/film/kill_reel_*.break.test.mjs`, the class cache is stale: run a Godot `--import` and commit again (never skip the
hook). Never fake a number or a frame: unmeasured is never zero.

## Report at the end (and END at the hard stop)
Commits (sha + subject); per character STEP_M, drawings/s, sole/jump before and after, reversal jump; item 4's numbers per
card and the verdict; what still fails and why; mutate score; quick gate line; evidence paths + ffprobe lines.
