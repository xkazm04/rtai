# Brief n26-melee-01-hands: bare hands one-shot humans, each type with its own kill

Lane `melee`, branch `n26-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (cut from main `0779185ac`).
**Hard stop 12:28 wall clock. Last commit by 12:22.** Whatever is not done by then: leave it uncommitted-free
(commit what is green, revert your own unfinished edits with `git checkout -- <path>`), and list it in your report.

## The owner's pick (verbatim from the run brief)
"Bare hands one-shot humans too." One claw swing (the quick claw, the `claw` row of
`project/data/tables/rivet_melee.json`, today `kills_human: false`) kills each human enemy type, **with a kill
animation of its own per type**, the way the melee weapons got theirs last run (brutal; red is blood only).
Bosses and named humans are NOT one-shot.

## What you need to know (read these first)
- Last run's work: `docs/day/2026-11-23/n24-melee/REPORT.md` and `JOURNAL.md` there. The one-shot path is
  `project/features/player/melee_lethal.gd` (`MeleeLethal.contact`, `pit_damage`, `_eligible` excludes
  `sergeant_mulroney`); per weapon x archetype kill variants live in `project/data/tables/signature_kills.json`
  (see `katana_split` `variants` at about line 191, `plasma_sword_split`, `chainsaw_grind`); commits `2dfefbbc7`
  (MeleeLethal + MeleeContact + variants), `4bdda2843` (plasma kill art), `9f8d6c8f8` (baton cook art).
- There is NO signature kill row for the plain claw today (`claw_throw` is the charged claw, weapon `claw_shock`).
  Add one row for the claw rake one-shot (e.g. `claw_rake_kill`), with a `variants` entry per human archetype:
  `patrol_cop`, `riot_cop`, `swat`, `contractor`, `rocket_trooper`, and the plain quest/prologue guard (archetype
  empty) through the row default. Each type must read differently at 32 px/m: e.g. patrol cop: the clamp rakes
  across the throat, cap flies, he spins and drops; riot cop: the claw rips the helmet/visor off and slams him
  down, shield clatters; SWAT: torn through the vest, folded over the claw, thrown; contractor: gouged and
  flung back over his own pistol; rocket trooper: launcher torn away, he goes down clutching. These are
  suggestions; the rule is five visibly different deaths + blood. Use the existing drawn cells
  (`KillDeathCells`, `KillFallCells`, the per-type drawn fall grids) and view-only FX (blood fan/pool, gouges,
  pose track, hat/kit kick) as the other rows do. Do NOT draw new character art from script shapes (no new
  procedural bodies); procedural FX (blood, gouges, sparks, skid lines) are fine. Colour law: red only for blood,
  teal only for souls, vermilion only for danger and Rivet's collar, cops blue.
- Exempt (keep normal damage): bosses (`f == boss` path), `sergeant_mulroney`, `appliance_warden` (named / boss
  of the prologue: check `enemies.json` and the prologue code; if the warden is a wave grunt, say so and decide),
  any `boss` flagged row, all robots. Add the exemption by data (a field or a list in a table you own) rather
  than more hard-coded ids if it fits in the time; otherwise keep `_eligible` and add the warden id.
- Hands keep: one click one swing, system arrow cursor, robots immune to the plain claw, the shield rule
  (`claw` `vs_shield: "blocked"`: a raised riot shield from the front blocks and is shoved open 40 ticks, the
  next swing kills). Keep that.
- The claw moves from Space to F in the keys lane: not yours; tapes press actions, not keys.

## Tape identity and the prologue (measure, do not guess)
1. BEFORE any edit: run the prologue pilot on seeds 1..5 (find the right entry: `project/dev/prologue/`,
   `node tools/dev/run.mjs prologue --bot --seed=N` or `newgame_pilot --bot`; the n25-path REPORT used
   `newgame_pilot --bot --seed=7`). Record per seed: prologue fight length (sim seconds per encounter and total),
   Rivet's lowest health, outcome. Save as `evidence/n26/hands/prologue-before.json` (+ `.md` table).
2. After the change: same five seeds -> `prologue-after.json` + a before/after table in
   `evidence/n26/hands/prologue.md`. If the prologue becomes trivial (e.g. lowest health stays at full, or fight
   time halves), do NOT retune it (yard lane owns it): write the numbers in your report as a NEED for yard.
3. Run `node tools/tests/run_scenarios.mjs` (or the scenario suite) and the shipped-tape / replay checks before
   and after. Every tape or scenario whose digest moves because the claw now kills humans: list it with old ->
   new and the reason. Re-pin only where the cause is the claw one-shot (scenario expectations, quest tapes'
   pinned digests if the tape still reaches its checkpoints), each with one line in `docs/decisions.md`:
   `- [2026-11-23] DECISION n26 melee: ...`. Quest 1's script, rules and checkpoints do not change. If a quest
   tape no longer reaches a checkpoint because of the one-shot, do not edit the quest: gate the one-shot off for
   that path only if trivially possible, otherwise stop and report it. The native parity digest and the 60 s
   replay (`cbeb734ff9b97c41`) must stay identical (check).

## Deliverables, in order (commit each when green; one commit per change, staged per path)
1. `kills_human: true` for the claw + exemptions + unit tests (claw kills each human type in one swing; does not
   one-shot Mulroney, the warden, a boss, a robot; shield block still works). Decision line.
2. The claw kill row with five variants + tests in the style of `test_kill_plasma_art.gd` (each variant resolves
   for its archetype; the row default for an empty archetype).
3. Review stills (NOT owner films yet): for each of the five types, the kill at 32 px/m tilt 70 (kill tick, +10,
   +30, +60) and a 64 px/m close-up, to `evidence/n26/hands/frames/` (git-ignored scratch is fine if
   `evidence/` is not tracked for png; check `.gitignore`). Use the kit: `tools/film/kill_reel.mjs`,
   `tools/film/owner_take.gd` (last run's films), `tools/film/compare.mjs`. Look at them yourself before you
   commit a look: if two types read the same at 32 px/m, change one.
4. Prologue numbers before/after (above), scenarios/tapes list.
5. `node tools/mutate/mutate.mjs --file=project/features/player/melee_lethal.gd --max=20 --lines=<your changed
   lines>` and the same for the main new kill art file; quote killed/(killed+survived).

## Files you may edit (allowlist). Any other path: stop that part and report a NEED.
- `project/features/combat/kills/**`, `project/features/player/melee_*.gd` (melee code), `project/features/react/**`
  only for kill poses, `project/data/tables/rivet_melee.json`, `melee_weapons.json`, `signature_kills.json` and
  their schemas, new tests under `project/tests/unit/` and `project/tests/integration/`, scenario expectation
  files only for a re-pin you justify, `docs/decisions.md` (append one line at a time), `evidence/n26/**`,
  `project/dev/melee/**` (dev entries for stills), `tools/film/**` only for a new still entry,
  `tools/debt/baseline.json` through `node tools/debt/debt.mjs --update` (with `--accept-regression="<reason> for
  n26 melee"` if it rises), `project/boot/launch_args.gd` `KNOWN_FLAGS` append only.
- Forbidden (other lanes): `input_actions.json`, `rivet_motion.json`, player movement/input files, `combat.json`,
  existing rows of `enemies.json` / `weapons.json`, `enemy_round_look.gd`, `project/features/gauntlet/**`,
  `project/boot/prologue/**`, `prologue_stage.json`, `prologue_yard_dressings.json`, `cast_cards.json`, enemy
  cast art, the deploy input / deploy HUD chip files in `project/features/souls/**`.

## Repo law (binding)
- AGENTS.md and STANDARDS.md. Typed GDScript, files about 200 lines (hard 300), functions 40 lines or fewer,
  5 params max, `Log` not print, no global RNG (view-only FX must not touch combat RNG or hashed state), data in
  JSON with schema. Commit `.uid` with every new `.gd`. Run a Godot `--import` after new scripts/art, before commit.
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/melee` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`;
  `--rendering-driver d3d12` for anything that renders; windowed runs `--position 0,1440`. One Godot process at
  a time. Kill your own processes by PID only.
- Before each commit: `node tools/gate/quick.mjs` (fix lint and format findings in your own edit and go on).
  Stage per path; `git commit -- <paths>` is fine. No amend, no rebase, no stash, no `add -A/./-u`, no
  `reset --hard`, never push. Do not touch `JOURNAL.md` or `REPORT.md` at the repo root (the director's).
- Tests: `node tools/tests/run_unit.mjs --changed` in the loop, the full `node tools/tests/run_unit.mjs` once
  before your last commit.

## Report at the end
Commits (sha + subject), the prologue table, the tape/scenario list (moved / re-pinned / identical), the exempt
rows and why, mutate scores, the still paths, anything not done and why.
