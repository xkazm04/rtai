# Brief 01 (lane cast): audit the wave cast against the cop, write the checklist, start the lancer

Hard stop: 18:40 wall clock (check `date`). Commit everything you finish by 18:35. If a part is not done at 18:35,
commit what is done, write what is left in your final report, and stop.

## Context
The owner played the game and said: "Design of new characters when added to waves should be always finetuned from start
to have cop-level quality (animations, clean cut and shape), assume we will use all characters in some form in the game".
Our lane redraws the wave enemies to the shipped patrol cop's quality, from the owner's concept picks, at a size near
Rivet's. This first call measures where every enemy stands, writes the standard down, and prepares the first redraw.

What the director already read (verify, do not trust):
- `project/data/tables/enemies.json` `archetypes`: patrol_cop, riot_cop, swat, robot_thug, robot_gunner, contractor,
  rocket_trooper, sentry_turret, shield_robot, war_machine, sergeant_mulroney, appliance_warden.
- The four n22 enemies are placeholders: `project/features/combat/squad/foe_looks.gd` dresses rocket_trooper in the swat
  rig (+ `foe_launcher_view.gd`), hides the rig for sentry_turret (`foe_turret_view.gd`), and scales the robot thug rig
  1.18x for shield_robot (`foe_shield_view.gd`) and 1.65x for war_machine (`foe_walker_view.gd`).
- The cop standard: `project/features/characters/art/view/<p55|p70>/cop_patrol_walk.png`, `cop_patrol_armed_walk.png`,
  `cop_patrol_card.png`, `cop_patrol_hit.png`, `cop_patrol_fall.png`, `cop_patrol_pistol_snap.png` etc. Provenance lines in
  `steam/ai-provenance/2026-11.jsonl` say: cut by `tools/art/street_walk.py` from the assets library's keyed sheet
  (`C:\Users\kazda\kiro\gtai-art\library\keyed\street\cop_patrol_walk_70.png`, 5 facings x 4 stride frames, 192 px
  cells), toned by `tools/art/street_tone.py`. The library: `C:\Users\kazda\kiro\gtai-art\library\` (`LIBRARY.md`,
  `catalog.json`, `rounds/`, `tools/mk_round_*.py`, `tools/queue.sh`); the generation runner is
  `C:\Users\kazda\kiro\gtai-art\gen.mjs` (Codex image_gen; known fault: a job can stall copying to `./out` after the image
  exists under `~/.codex/generated_images/`; copy it by hand then).
- Owner's concept picks (hero plates with a steep top-down inset): `C:\Users\kazda\kiro\gtai-art\foes-n22\out\`
  `rocket-trooper-b.png` (the lancer), `sentry-turret-a.png` (the clamshell), `shield-robot-a.png` (door carrier, bare
  steel slab with striped edges), `war-machine-b.png` (pile-driver). Notes + owner's words: `foes-n22\notes.md` (end).
  Owner on size: "we should be careful with too large bosses and enemies to avoid very heavy and slow oponents very easy
  to beat by just moving". Rivet is 1.65 m (his x1.5 is visual only).

## Setup (do first)
- `export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/cast` before every Godot run. `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`,
  `--rendering-driver d3d12` for anything that renders, `--position 0,1440` on any windowed run. One Godot process at a
  time. Kill only your own PIDs, never by name. The import is already done.

## Part A: the audit (commit 1)
1. Work out exactly how the patrol cop is drawn in a gauntlet wave and in the prologue (sheet cards vs cutout rig, which
   code picks which; follow `StreetQuestCards`, the view code under `project/features/characters/` and the squad views).
   Then do the same for every archetype above.
2. Write `docs/art/cast-checklist.md` ("cop quality", the standard every wave character is held to), measured from the
   cop's files, not guessed: actions and frame counts per action (walk, armed walk, attack with its tell, hit, death /
   fall), facings (and which are mirrored), cell size, both pitches (p55 and p70), height in m and px at 32 px/m, ink
   line weight in px at the cell scale, palette (navy value, what colours are allowed: colour law below), how the cut is
   cleaned (key, despill, fringe; name the library tools used), how the feet plant (no slide; how the stride frames line up
   with speed), shadow, provenance line. Each item must be checkable: say how to check it (a tool, a measurement).
3. Write `docs/art/cast-audit.md`: one row per archetype: drawn with (own sheets / borrowed / rig placeholder), its
   height beside Rivet's 1.65 m and the cop's (measured in game, at 32 px/m), and PASS / FAIL per checklist item.
4. One contact sheet rendered by the game (not composed from vector shapes): every archetype standing in a row beside a
   patrol cop and Rivet, at 32 px/m tilt 70, 1920x1080, plus a 64 px/m one. Use an existing dev lineup scene if one fits
   (search `project/dev/` for lineup / showcase / gauntlet stills, `tools/film/`, `tools/README.md`); otherwise add
   `project/dev/cast/cast_lineup.gd` (+ `.uid`) that spawns them through the game's own spawn path. Save to
   `C:\Users\kazda\kiro\gtai-masters\n24\cast\audit_lineup_32ppm_tilt70.png` and `..._64ppm_tilt70.png`, and the same
   at tilt 55 if the scene allows. Look at them yourself; label each figure (a label row in the PNG is fine).
5. Commit 1: the two docs + the dev scene, message `cast: audit of the wave cast against the patrol cop`.

## Part B: the lancer generation round (commit 2, if time)
Prepare the first redraw: the rocket trooper as the lancer (`rocket-trooper-b.png`: lean officer, navy fatigues, flak
vest, open-faced helmet, frame backpack with two spare rockets, a LONG slender launcher tube with amber-and-black stripes
on the rear third and a flared blast cone).
1. Find in `C:\Users\kazda\kiro\gtai-art\library\catalog.json` and `rounds/` exactly how `cop_patrol_walk_armed_70_v2`
   and the swat sheets were generated (prompt, refs, layout, cell grid) and the jobs that made a cop's fire, hit and fall
   rows.
2. Create `C:\Users\kazda\kiro\gtai-art\foes-n24\` with `jobs.json` + `refs/` (refs: the lancer plate, the keyed cop sheet
   of the same layout as the layout and style reference, Rivet in-game for scale) for the lancer's sheets at pitch 70
   and 55: walk (the cop's facings x stride frames), attack with its tell (shoulder, aim, fire with backblast), hit, death.
   Match the cop's layout so the repo's cutting scripts take the result. Height: a human near the cop's.
3. Start the generation detached (`nohup node C:/Users/kazda/kiro/gtai-art/gen.mjs C:/Users/kazda/kiro/gtai-art/foes-n24 > ... 2>&1 &`),
   write its PID and log path in your report, and do not wait for it past the hard stop.
4. Commit 2 (repo side only, if anything changed in the repo; the gtai-art folder is not in this repo).

## Files you may write
`docs/art/cast-checklist.md`, `docs/art/cast-audit.md`, `project/dev/cast/**` (new), `tools/art/cast_*.py|mjs` (new),
`C:\Users\kazda\kiro\gtai-art\foes-n24\**`, `C:\Users\kazda\kiro\gtai-masters\n24\cast\**`. Any other path: stop and
report it as a NEED in your final message. Forbidden: everything other lanes own: `project/features/player/**`,
`rivet_walk*`, `rivet_run8*`, `project/features/souls/**`, `project/features/gauntlet/**`, `project/dev/gauntlet/**`,
`input_actions.json`, `combat.json`, `weapons.json`, any number in `enemies.json`, `melee_*`, `signature_kills.json`,
`project/features/combat/kills/**`, `combat_arena.gd`. Do not touch JOURNAL.md, REPORT.md or `evidence/briefs/`.

## Repo law
AGENTS.md and STANDARDS.md. Typed GDScript, files about 200 lines (300 hard), functions 40 lines or fewer, 5 params max,
`Log` not `print`. Fix lint and format findings in your own edit and go on (`node tools/lint/lint.mjs`,
`node tools/godot/check.mjs <file>`, `node tools/gate/quick.mjs` before each commit). Commit the `.uid` of every new
`.gd`. Stage per path (`git add <path>`), `git commit -- <paths>` is fine. Never amend, rebase, stash, `add -A`, push.
Colour law: red is blood only; cops are blue; vermilion only for danger, objectives and Rivet's collar; teal only for
souls; amber for heat. Never imitate a real person's likeness. Do not invent characters or change who these enemies are.

## Report back
Files changed, commits (sha), what you ran and its result, the audit table inline, the checklist inline (short), the
contact sheet paths, the generation PID / log / which jobs, and what you could not do and why.
