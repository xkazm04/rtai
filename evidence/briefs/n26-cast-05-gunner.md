# Brief n26-cast-05-gunner: the robot gunner as a cast card, cop quality

Lane `cast`, branch `n26-cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd).
**Hard stop HARDSTOP local** (check `date`). **Commit deadline COMMITBY: commit the cut art + row FIRST, before films.**
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/cast` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Windowed runs: `--position 0,1440`, `--rendering-driver d3d12`. Kill only your own PIDs.

## Goal
Draw the robot gunner (`robot_gunner`, `enemies.json`: speed 2.2 m/s, telegraph 0.9 s, weapon `cannon`) from the
director-picked plate at the patrol cop's standard, through the card path the lancer, Mulroney and the warden took (read
their commits first: `git log --oneline -20`, `docs/art/cast-audit.md`). Today he is drawn by the generic robot rig (box
head, one lens, hose arms). New look: same body family, a carbine held in both claws and an AMBER shoulder warning lamp.
The states that must read: walk, aim with the lamp lit, fire, hit, power-down fall.

## Source sheets (director-generated with Codex image_gen, all accepted; do not regenerate unless a sheet fails, then say so)
`C:\Users\kazda\kiro\gtai-art\foes-n26\gunner\out\` : `gunner_{armed_walk,attack,hit,fall}_{70,55}.png`, 1536x1024
on #00B140, the patrol layouts (5 facings x 4; hit 5+3; fall 5x3). The attack sheet's four columns are TIME: (1) LAMP LIT + aim (the tell: map it to `telegraph_s`), (2) FIRE (small cream
muzzle flash), (3) RECOIL, (4) RECOVER, lamp dark. Fall = a power-down onto his back: a robot, NO blood anywhere (red is blood
only); hit = sparks/dents, never red. The hit sheets are drawn about 1.6x larger than the walk: scale by the walk's body
height. Check `fall_70` row 1 col 2 for a pale green fleck at the arm after the key. The lamp is amber (heat/warning, allowed);
no blue, no teal, no vermilion on him. Plate `refs/plate.png` (from `plates/out/robot-gunner-b.png`), notes `notes.md`.

## Build, in order
1. Cut and pack all eight into `project/features/characters/art/view/{p70,p55}/robot_gunner_{armed_walk,attack,hit,fall}.png`
   (+ `.import`), key-clean (zero strongly green-leading opaque pixels), one `steam/ai-provenance/2026-11.jsonl` line per
   shipped PNG (prompt ref `gtai-art/foes-n26/gunner/jobs.json#<job>`, cutter edits, sha256). Reuse the cutter Mulroney and
   the warden used; pack intermediates in `foes-n26/gunner/pack/`.
2. Row `robot_gunner` in `cast_cards.json`, drawn by the existing card path (the lancer/rocket-trooper rows are the model),
   planted feet as the patrol cop got them. The gunner's existing robot rig must keep working with the card off (`enabled: false` = today's look, unchanged).
Size: about Rivet's height or a little under, never taller (owner: no heavy slow giants).
3. Checklist: every item of `docs/art/cast-checklist.md` incl. planted feet (`project/dev/cast/cast_feet.gd`,
   `tools/art/cast_feet.py` / `cast_feet.mjs`) at both pitches; the row in `docs/art/cast-audit.md`. `enabled: true` only if
   every item passes; otherwise `enabled: false` and list the fails. Never ship a half character.
4. Evidence to `C:\Users\kazda\kiro\gtai-masters\n26\cast\`: `gunner_beside_64ppm_tilt{70,55}.png` (beside the patrol cop, Rivet and the shipped robot thug look, front three-quarter
and back, `project/dev/cast/cast_lineup.gd`), `gunner_fire_64.png` (the four attack columns, down-right, at 64 px/m and at
32 px/m beside them: the lit lamp must read at 32), `gunner_close_64.mp4` (walk, lamp, fire, hit, fall; 15 to 40 s,
1920x1080, 60 fps; ffprobe it), `gunner_fight_32.mp4` (32 px/m tilt 70, Rivet against three gunners in a gauntlet wave
or a dev scene under `project/dev/cast/`, card on). Look at every frame you deliver.
5. Commit, then `node tools/mutate/mutate.mjs --file=<main changed .gd> --max=20 --lines=<changed lines>`; quote the score.

## Owned files (allowlist; any other path: stop and report a NEED)
`project/features/characters/art/view/{p70,p55}/robot_gunner_*`, `project/data/tables/cast_cards.json` (+ its schema),
`project/features/characters/cast_*.gd`, `street_*cards*.gd`, `project/features/combat/squad/foe_cast_view.gd`,
`foe_*_card_view.gd`, `cast_*.gd` there, `project/dev/cast/**`, `tools/art/**` (cast tools), `project/tests/unit/test_cast_*.gd`
(+ `.uid`), `docs/art/cast-checklist.md`, `docs/art/cast-audit.md`, `steam/ai-provenance/2026-11.jsonl` (append),
`project/boot/launch_args.gd` `KNOWN_FLAGS` (append one line; then `node tools/debt/debt.mjs --update --accept-regression="<flag> for n26 cast"`),
`tools/debt/baseline.json` (debt tool only), `C:\Users\kazda\kiro\gtai-art\foes-n26\gunner\**`.
**Forbidden**: `project/boot/prologue/**`, `prologue_stage.json`, `prologue_yard_dressings.json`, `project/features/player/**`,
`rivet_*` art, `input_actions.json`, `project/features/combat/kills/**`, `project/features/souls/**`, `ghost_*.json`,
`combat.json`, `enemies.json`, `weapons.json`, `bosses.json`, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`.

## Repo law
AGENTS.md and STANDARDS.md. Typed GDScript, ~200 lines per file (hard 300), functions <= 40 lines, <= 5 params, `Log` not
`print`. One commit per change, staged per path; never `git add -A/./-u`, `commit -a`, `stash`, `reset --hard`, amend or
rebase; never push. `--import` after new art/scripts before committing; commit `.uid`/`.import` with their source.
`node tools/gate/quick.mjs` before each commit (if red on something you did not touch, reproduce on `0779185ac` and say so).
**Fix lint and format findings in your own edit and go on.** `node tools/tests/run_unit.mjs --changed`. Replay digests,
quest 1 and prologue tapes must not move (rendering only). Never fake a number or a frame.

## Report at the end
Commits (sha + subject), the sheet and frame names, any entry the yard lane must call (exact signature), what the yard lane
must change, the checklist row, mutate score, quick gate, evidence paths, and what you could not do.
