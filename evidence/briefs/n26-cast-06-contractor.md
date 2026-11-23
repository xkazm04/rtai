# Brief n26-cast-06-contractor: the contractor as a cast card, cop quality

Lane `cast`, branch `n26-cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd).
**Hard stop HARDSTOP local** (check `date`). **Commit deadline COMMITBY: commit the cut art + row FIRST, before films.**
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/cast` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Windowed runs: `--position 0,1440`, `--rendering-driver d3d12`. Kill only your own PIDs.

## Goal
Draw the contractor (`contractor`, `enemies.json`: a human, speed 3 m/s, telegraph 0.6 s, weapon `rifle`) from the
director-picked plate at the patrol cop's standard, through the card path the lancer, Mulroney and the warden took (read
their commits first: `git log --oneline -20`, `docs/art/cast-audit.md`). New look (director's colour decision, owner call in
the lane REPORT): dirty WHITE hard hat with a head lamp, PALE LEMON-YELLOW hi-vis vest with grey bands (the shipped orange
vest collided with the vermilion law), moustache, cigarette, a compact rifle/SMG.
The states that must read: walk, aim, fire, hit, fall.

## Source sheets (director-generated with Codex image_gen, all accepted; do not regenerate unless a sheet fails, then say so)
`C:\Users\kazda\kiro\gtai-art\foes-n26\contractor\out\` : `contractor_{armed_walk,attack,hit,fall}_{70,55}.png`, 1536x1024
on #00B140, the patrol layouts (5 facings x 4; hit 5+3; fall 5x3). The attack sheet's four columns are TIME: (1) aim (tell, `telegraph_s`), (2) FIRE (small cream flash), (3) recoil,
(4) recover. Fall: he drops the hard hat and the gun as SEPARATE pieces beside the body: the cutter must keep detached pieces
inside the cell (do not let a largest-blob filter eat them). The hit sheets are drawn larger than the walk: scale by the
walk's body height. Red only as blood. Plate `refs/plate.png` (from `plates2/out/contractor-b.png`), notes `notes.md`.

## Build, in order
1. Cut and pack all eight into `project/features/characters/art/view/{p70,p55}/contractor_{armed_walk,attack,hit,fall}.png`
   (+ `.import`), key-clean (zero strongly green-leading opaque pixels), one `steam/ai-provenance/2026-11.jsonl` line per
   shipped PNG (prompt ref `gtai-art/foes-n26/contractor/jobs.json#<job>`, cutter edits, sha256). Reuse the cutter Mulroney and
   the warden used; pack intermediates in `foes-n26/contractor/pack/`.
2. Row `contractor` in `cast_cards.json`, drawn by the existing card path (the lancer/rocket-trooper rows are the model),
   planted feet as the patrol cop got them. Wherever the contractor is drawn today (rig and any card), the card-off path must stay exactly as on main. If the
orange vest is a tint in code (not art), leave the code and note it for the director. Size: the cop's height, not taller than Rivet.
   His WALK: the 4-drawing walks all fail the Feet rule, so the director had an 8-drawing walk drawn, one facing per image,
   8 figures in a 2x4 grid (drawings 1-4 top row, 5-8 bottom row; support L in 1-3, R in 5-7):
   `C:\Users\kazda\kiro\gtai-art\foes-n26\contractor8c\out\contractor8c_{70,55}_{down,dr,right,ur,up}_t3.png` (accepted;
   `contractor8c_55_up_t3_REJ_slim.png` is the rejected take: never use it; prompts `contractor8c/jobs.json`). Cut it into
   `contractor_planted8_armed_walk.png`, match all facings to one body height (his accepted 4-drawing walk), and put him on the
   cop8 N-drawing anchored placement as the cop8, mul-fix and warden calls did (read their commits). The 4-drawing `armed_walk`
   stays selectable with one value. Allowed extra: `project/features/characters/street_*.gd` (walk placement only),
   `C:\Users\kazda\kiro\gtai-art\foes-n26\contractor8c\**`.
3. Checklist: every item of `docs/art/cast-checklist.md` incl. planted feet (`project/dev/cast/cast_feet.gd`,
   `tools/art/cast_feet.py` / `cast_feet.mjs`) at both pitches; the row in `docs/art/cast-audit.md`. `enabled: true` only if
   every item passes; otherwise `enabled: false` and list the fails. Never ship a half character.
4. Evidence to `C:\Users\kazda\kiro\gtai-masters\n26\cast\`: `contractor_beside_64ppm_tilt{70,55}.png` (beside the patrol cop and Rivet, front three-quarter and back,
`project/dev/cast/cast_lineup.gd`), `contractor_fire_64.png` (four attack columns, down-right, 64 and 32 px/m),
`contractor_close_64.mp4` (walk, aim, fire, hit, fall with the hat and gun dropping; 15 to 40 s, 1920x1080, 60 fps; ffprobe),
`contractor_fight_32.mp4` (32 px/m tilt 70, Rivet against three contractors, card on, dev scene under `project/dev/cast/`). Look at every frame you deliver.
5. Commit, then `node tools/mutate/mutate.mjs --file=<main changed .gd> --max=20 --lines=<changed lines>`; quote the score.

## Owned files (allowlist; any other path: stop and report a NEED)
`project/features/characters/art/view/{p70,p55}/contractor_*`, `project/data/tables/cast_cards.json` (+ its schema),
`project/features/characters/cast_*.gd`, `street_*cards*.gd`, `project/features/combat/squad/foe_cast_view.gd`,
`foe_*_card_view.gd`, `cast_*.gd` there, `project/dev/cast/**`, `tools/art/**` (cast tools), `project/tests/unit/test_cast_*.gd`
(+ `.uid`), `docs/art/cast-checklist.md`, `docs/art/cast-audit.md`, `steam/ai-provenance/2026-11.jsonl` (append),
`project/boot/launch_args.gd` `KNOWN_FLAGS` (append one line; then `node tools/debt/debt.mjs --update --accept-regression="<flag> for n26 cast"`),
`tools/debt/baseline.json` (debt tool only), `C:\Users\kazda\kiro\gtai-art\foes-n26\contractor\**`.
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
