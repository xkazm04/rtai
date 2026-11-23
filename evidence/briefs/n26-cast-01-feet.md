# Brief n26-cast-01-feet: planted feet become a measured checklist rule; the patrol cop is re-cut to it

Lane `cast`, branch `n26-cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd).
**Hard stop 12:25 local** (check `date` regularly). **Commit deadline 12:10**: everything you want kept is committed by then; after 12:10 only stills and your report.
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/cast` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
Start with ONE `"$GODOT_BIN" --headless --path project --import` (main moved since the cache was made).
One Godot process at a time for this lane. Any windowed run: `--position 0,1440` (secondary monitor), `--rendering-driver d3d12` for anything that renders. Kill only your own PIDs, never by name.

## Why
The owner (verbatim pick, 2026-11-23): "Require planted feet and re-cut the patrol cop too." Last run measured that the shipped
patrol cop's supporting boot slides 10.24 screen px (0.32 m) against the ground during one held walk drawing at 32 px/m and
2.4 m/s (`docs/art/cast-audit.md`, "Original rig ground-contact measurements"; reproduce with `GTAI_CAST_STRIDE=1` in
`project/dev/cast/cast_lineup.gd`). The lancer slides 10 px too. The door carrier was fixed last run by holding the card's ground
point through a held walk cell (`project/features/combat/squad/foe_shield_card_view.gd`, commit 79c0c434b, test
`project/tests/unit/test_cast_door.gd` `_check_walk_contact`): its boot holds at 0 px. The owner kept the door carrier as it is.

## What to build, in this order (commit each step on its own)

1. **The rule, measurable.** Add a `Feet (planted)` definition to `docs/art/cast-checklist.md` replacing the current Feet row's
   reference-defect wording:
   - Landmark: the support boot's sole point (lowest 5% of the visible boot outline, alpha >128, as `tools/film/foot_slide.py`
     does), tracked in screen pixels against a fixed ground mark with a fixed camera, the actor moving at the archetype's real
     walk speed and real run speed (read them from the data/code the game uses; if an archetype has no run, say so and test walk only).
   - Contact span: every rendered frame from the frame that boot becomes the support until it lifts, INCLUDING across a drawing
     change while the same boot stays the support (a foot that jumps at the cell change fails just like a sliding one).
   - Pass: the landmark travels at most **2 screen px at 32 px/m** (0.0625 m) over the whole contact span, at tilt 70 AND 55, at
     walk AND run, in the right-profile facing and the down-right facing (state if a facing cannot be measured and why).
   - Also report, not gate: the largest body jump between two consecutive rendered frames (px at 32 px/m), so a stutter shows.
2. **The audit tool.** One command (extend `project/dev/cast/cast_lineup.gd`'s `GTAI_CAST_STRIDE` probe or add a dev script
   under `project/dev/cast/` plus a Python analyser under `tools/art/`) that, for every archetype with `enabled: true` in
   `project/data/tables/cast_cards.json` PLUS the patrol cop, riot cop, swat, robot thug, robot gunner, contractor,
   Mulroney and the warden as they render today, prints and writes one JSON (`build/cast/feet.json`, schema
   `gtai.cast-feet/1`): archetype, pitch, gait, facing, max contact travel px, max body jump px, PASS/FAIL. Use `tools/dev/run.mjs`
   as the front door if it fits (declare `KNOWN_FLAGS` for any flag you add). Add a unit test for the analyser's core (a
   synthetic sliding track fails, a planted one passes, a foot that jumps at the cell change fails).
   Put the table into `docs/art/cast-audit.md` (new section "Planted feet, n26", before and after columns).
3. **Re-cut the patrol cop to pass.** Preferred method, because the owner accepted it on the door carrier: hold the card's
   ground point while the same walk drawing is held, advance it when the drawing changes, AND re-pack (re-cut) the cop's walk and
   armed-walk cells so the support boot's in-cell position between consecutive drawings of the same support moves back by
   exactly the step the body advances (so the foot does not jump at the change). Re-packing means shifting each figure inside its
   cell with the repo's cutter (`tools/art/street_walk.py` and friends); commit the new PNGs with their `.import` files and a
   `steam/ai-provenance/2026-11.jsonl` line per changed PNG (append only; human/tool edit noted, sha256 of the new file).
   If the hold cannot be done in a shared helper without moving other humans' behaviour, scope it to the patrol cop only and say so.
   If a re-cut cannot make it pass (the drawings themselves are wrong), report that with numbers; do not redraw in this call.
   The cop is used in the city, quests and waves: keep every place it draws working. Rendering is not sim: replay digests and
   parity must not move (run the scenario suite's replay at the end).
4. **Then the other four of last run, in this order, only if the cop passes and time remains:** lancer (`rocket_trooper`),
   door carrier (`shield_robot`, should already pass: confirm with the new tool), clamshell (`sentry_turret`: its base must not
   move at all while the turret turns), pile-driver (`war_machine`). Fix each that fails the same way.
5. **Before beside after at 64 px/m with the foot track overlaid**, for the patrol cop (and each fixed foe): a PNG with the
   ground-mark, the sole landmark per rendered frame drawn as dots and its contact span bracketed, before (HEAD at start, `0779185ac`)
   left and after right, same tick, same zoom, tilt 70; plus one tilt 55. Write to
   `C:\Users\kazda\kiro\gtai-masters\n26\cast\feet_<archetype>_before_after_64ppm_tilt{70,55}.png`. Look at them yourself before
   claiming a pass.

## Owned files (allowlist; any other path: stop and report a NEED)
`docs/art/cast-checklist.md`, `docs/art/cast-audit.md`, `project/dev/cast/**`, `tools/art/**` (new or cast tools only),
`project/features/characters/street_cop_walk.gd`, `street_walker_cards.gd`, `street_quest_cards.gd`, `rig_gait.gd`,
`cast_card_pose.gd` and the patrol cop's art `project/features/characters/art/view/{p70,p55}/cop_patrol_*` (+ `.import`),
`project/features/combat/squad/foe_*_card_view.gd`, `foe_cast_view.gd`, `project/tests/unit/test_cast_*.gd` and new
`project/tests/unit/test_*feet*.gd` / `test_*sole*.gd` (+ `.uid`), `steam/ai-provenance/2026-11.jsonl` (append only),
`project/boot/launch_args.gd` `KNOWN_FLAGS` (append one line if you need a flag; then
`node tools/debt/debt.mjs --update --accept-regression="<flag> for n26 cast"`), `tools/debt/baseline.json` (through the debt tool only).
**Forbidden** (other lanes): `project/features/player/**`, `rivet_*` art, `input_actions.json`, `rivet_motion.json`,
`project/features/combat/kills/**`, `project/features/souls/**`, `ghost_*.json`, `combat.json`, `enemies.json`, `weapons.json`,
`project/boot/prologue/**`, `prologue_stage.json`, `prologue_yard_dressings.json`, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`.

## Repo law that binds
AGENTS.md and STANDARDS.md. Typed GDScript, files about 200 lines (hard 300), functions 40 lines or fewer, 5 parameters max,
`Log` not `print`, no global RNG, no frame delta in sim. One commit per change, staged per path (`git add <path>`); never
`git add -A/./-u`, `git commit -a`, `git stash`, `reset --hard`, amend or rebase; never push. Run `--import` after new art or
scripts before committing (`.uid` / `.import` files go in with their source). Before each commit: `node tools/gate/quick.mjs`
(if it is red on something your diff does not touch, reproduce it on `0779185ac` and say so). **Fix lint and format findings in
your own edit and go on.** Tests: `node tools/tests/run_unit.mjs --changed`. After the cop commit:
`node tools/mutate/mutate.mjs --file=<the main changed .gd> --max=20 --lines=<your changed lines>`; quote killed/(killed+survived).
Never fake a number or a frame: unmeasured is never zero.

## Report at the end
Files changed, commits (sha + subject), the feet table (before/after per archetype, pitch, gait), the command that reproduces
it, mutate score, quick gate result, the paths of the stills, and what you could not do and why.
