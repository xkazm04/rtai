# Brief n26-cast-08-feet-four: planted feet for the lancer, the door carrier and the pile-driver

Lane `cast`, branch `n26-cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd).
**Hard stop 17:20 local** (check `date`): the lane's final gate needs the machine at 17:25. **Commit deadline 17:10: nothing new after it.** After it: stills, clip and your report only.
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/cast` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Windowed runs: `--position 0,1440`, `--rendering-driver d3d12`. Kill only your own PIDs.

## Why
Item 1 of the lane: every enabled character passes the planted-feet rule (`docs/art/cast-checklist.md` Feet row: support sole
<= 2 px over the whole contact AND body jump <= 12 px between rendered frames, at 32 px/m, every gameplay gait, 70 and 55).
The feet-hop audit (`docs/art/cast-audit.md` "Planted feet, n26") left these failing; the clamshell (sentry_turret) passes:
- lancer `rocket_trooper` (3.2 m/s): sole 13.7-22.2 px. 4 drawings per stride: the patrol cop's problem.
- door carrier `shield_robot` (1.6 m/s): sole 6.6-7.4 px, body jump 11.8-13.3 px; down-right sole unmeasurable (slab hides it).
- pile-driver `war_machine` (1.8 m/s): sole 23-29 px, jump 11.9-17.8 px; its 70 profile shows no identifiable lift.
Your previous call (cop8) generalised the patrol contact placement to N drawings per stride with a per-facing, per-drawing
support-sole anchor table measured by the cutter. Read its commits first (`git log --oneline -15`) and REUSE that mechanism.

## Time plan (about 40 minutes: order by value, commit each as it lands)
Lancer first (worst numbers, art ready), one commit; then the door carrier and the pile-driver, one commit each, only if each
is measured before 17:10. What is not committed by 17:10 is not shipped: say so. Evidence: the 64 px/m stills for what you
committed; the clip only if it fits before 17:20 (else a later films call makes it). Mutate `--max=8`, after the commits.
Two calls before yours (mul-edge `af94f1c6e`, warden) changed the shared anchored placement in `street_cop_walk.gd` /
`street_patrol_pose.gd` (reversal fix, `test_cast_walk_reversal.gd`): build on it; run that test after your change.

## Build, in order
1. Lancer: cut the director's 8-drawing walk `C:\Users\kazda\kiro\gtai-art\foes-n26\lancer8\out\lancer8_armed_walk_{70,55}_{a,b}.png`
   (accepted; same layout as cop8: `_a` = down, down-right, right; `_b` = up-right, up; 8 drawings, support L in 1-3, R in 5-7;
   prompts `lancer8/jobs.json`) into `project/features/characters/art/view/{p70,p55}/rocket_trooper_planted8_armed_walk.png`
   (+ `.import`, provenance lines, same figure scale as the shipped lancer by body height, key-clean, toned to the shipped
   lancer; pack intermediates in `foes-n26/lancer8/pack/`), and put the lancer's card walk on the N-drawing anchored placement.
   The old strip stays selectable with one value.
2. Door carrier and pile-driver: keep their drawings; put their walks on the same anchored placement with tables measured
   from their shipped art. They are slow (1.6 / 1.8 m/s): choose each STEP_M from the drawn advance so the body jump stays
   <= 12 px; record drawings/s (expect 5 to 10). Where a facing's sole is truly hidden (door down-right) or there is no lift
   (pile 70 profile), say so and measure the body anchor instead; do not fake a pass. If a character cannot pass with its
   drawings, leave it enabled as on main (it shipped and the owner kept it) and list it as FAIL with the reason.
3. Re-run `node tools/art/cast_feet.mjs` for all enabled characters (patrol, lancer, door, clamshell, pile-driver, riot, swat,
   and any card row that is enabled now): table = sole px / body jump px / drawings per second, before (`0779185ac`) and after;
   update `docs/art/cast-audit.md` "Planted feet, n26".
4. Unit tests (`test_cast_*`), `node tools/tests/run_unit.mjs --changed` green, `node tools/gate/quick.mjs` before each commit.
   One commit per character. Then `node tools/mutate/mutate.mjs --file=<the placement file> --max=20 --lines=<changed lines>`.
5. Evidence (look at every frame): `C:\Users\kazda\kiro\gtai-masters\n26\cast\feet_{lancer,door,pile}_before_after_64ppm_tilt70.png`
   (before left / after right, same tick and zoom, sole dots per rendered frame, contact bracketed), and ONE clip
   `feet_four_before_after_32.mp4` (each of the three walking across a metre grid, before left / after right, sole dots on the
   ground, a 64 px/m inset of the feet; 20 to 40 s, 1920x1080, 60 fps; ffprobe it).

## Owned files (allowlist; any other path: stop and report a NEED)
`project/features/characters/art/view/{p70,p55}/{rocket_trooper,shield_robot,war_machine}_*`,
`project/features/characters/street_*.gd`, `project/features/characters/cast_*.gd`, `project/features/characters/foe_*.gd`,
`project/features/combat/squad/foe_*.gd` (walk drawing/placement only; no behaviour, speed or timing change),
`project/features/arena/arena_wave_cards.gd` (smallest edit), `project/dev/cast/**`, `tools/art/**`, `tools/film/**` (new files
only), `project/tests/unit/test_cast_*.gd` (+ `.uid`), `docs/art/cast-checklist.md`, `docs/art/cast-audit.md`,
`steam/ai-provenance/2026-11.jsonl` (append), `project/boot/launch_args.gd` `KNOWN_FLAGS` (append one line, then
`node tools/debt/debt.mjs --update --accept-regression="<flag> for n26 cast"`), `tools/debt/baseline.json` (debt tool only),
`C:\Users\kazda\kiro\gtai-art\foes-n26\lancer8\**`.
**Forbidden**: `project/boot/prologue/**`, `prologue_*.json`, `project/features/player/**`, `rivet_*` art, `input_actions.json`,
`project/features/combat/kills/**`, `project/features/souls/**`, `ghost_*.json`, `combat.json`, `enemies.json`,
`weapons.json`, `bosses.json`, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`, the patrol cop's, Mulroney's and the warden's art.

## Repo law
AGENTS.md and STANDARDS.md. Typed GDScript, ~200 lines per file (hard 300), functions <= 40 lines, <= 5 params, `Log` not
`print`. One commit per change, staged per path; never `git add -A/./-u`, `commit -a`, `stash`, `reset --hard`, amend or
rebase; never push. `--import` after new art/scripts before committing; commit `.uid`/`.import` with their source.
**Fix lint and format findings in your own edit and go on.** Replay digests, quest 1 and prologue tapes must not move
(rendering only). Never fake a number or a frame.
Pre-commit hook: bypass only as the cop8 brief allowed (only `kill_reel_life.break.test.mjs` failing, with the body line and
the DEVIATION line in `docs/decisions.md` if the cop8 call did not already write one).

## Report at the end
Commits (sha + subject), per character the STEP_M, drawings/s and the before/after table, what still fails and why, mutate
score, quick gate, evidence paths, what you could not do.
