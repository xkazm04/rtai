# Brief n26-cast-03-warden: the appliance warden (Peg Dolan) as a cast card, cop quality

Lane `cast`, branch `n26-cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd).
**Hard stop HARDSTOP local** (check `date`). **Commit deadline COMMITBY: commit the cut art + row FIRST, before films.**
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/cast` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Windowed runs: `--position 0,1440`, `--rendering-driver d3d12`. Kill only your own PIDs.

## Goal
Draw the appliance warden (`appliance_warden`, the prologue's catch-pole officer) from the owner's picked plate at the
patrol cop's standard, through the same card path Sergeant Mulroney took in the previous call (read its commits first:
`git log --oneline -15`, and `docs/art/cast-audit.md`). Her weapon is the catch pole (`shove` in `enemies.json`; the
prologue's `catch_pole` hit pins Rivet, see `project/boot/prologue/prologue_combat.gd` `first_catch_tick`). The states that
must read: walk, swing, catch, death (plus hit).

## Source sheets (director-generated with Codex image_gen; do not regenerate unless a sheet fails, then say so)
`C:\Users\kazda\kiro\gtai-art\foes-n26\warden\out\` : `warden_{armed_walk,attack,hit,fall}_{70,55}.png`, 1536x1024 on
#00B140, the patrol layouts (5 facings x 4; hit 5+3; fall 5x3). The attack sheet's four columns are TIME: (1) WIND-UP (pole
drawn back over the rear shoulder, noose high behind her), (2) SWING (pole forward and down, noose at full reach), (3) CATCH
(noose closed, hauling back to her hip), (4) RECOVER. Map wind-up to the tell (`telegraph_s` 0.55), swing to the active
ticks, catch to the pin while Rivet is held (if the pin is visible to features code; otherwise see step 2), recover after.
Director's review: all first takes except `fall_55` (take 2; take 1 had green in her hair). The hit sheets are drawn about
1.6x larger than the walk: scale every sheet by the walk's body height, not by its cell. Her pole is drawn about 1.5 m
(shorter than the plate's 2.2 m): accepted. Attack columns 2-4 differ mostly by pole reach; if the swing does not read at
32 px/m say so with a still instead of faking motion. No blue anywhere on her (she is not police). Notes, plate, prompts:
`foes-n26/warden/notes.md`, `refs/plate.png`, `jobs.json`.

## Build, in order
1. Cut and pack all eight into `project/features/characters/art/view/{p70,p55}/appliance_warden_{armed_walk,attack,hit,fall}.png`
   (+ `.import`), key-clean, one `steam/ai-provenance/2026-11.jsonl` line per shipped PNG (prompt ref
   `gtai-art/foes-n26/warden/jobs.json#<job>`, cutter edits, sha256). Pack intermediates in `foes-n26/warden/pack/`.
2. Row `appliance_warden` in `cast_cards.json`, drawn by the existing human card path. Her WALK: the 4-drawing walks
   all fail the Feet rule, so the director had an 8-drawing walk drawn:
   `C:\Users\kazda\kiro\gtai-art\foes-n26\warden8\out\warden8_armed_walk_{70,55}_{a,b}.png` (layout as cop8: `_a` = down,
   down-right, right; `_b` = up-right, up; support L in 1-3, R in 5-7; prompts `warden8/jobs.json`). Cut it into
   `appliance_warden_planted8_armed_walk.png` and put her on the cop8 N-drawing anchored placement as the cop8 and mul-fix
   calls did (read their commits); her 4-drawing `armed_walk` stays selectable with one value. Check her wound contact
   against the shadow (Mulroney's boot lifted off it on a hit; reuse whatever fixed his). The prologue today dyes her rig card with an overalls shader and draws a vector pole
   (`project/boot/prologue/prologue_props.gd`, yard-owned: do NOT edit). With the card on, those double-draw. If the catch
   (pin) is not visible to features code, add ONE public entry the yard lane can call (like Mulroney's pump entry) and
   unit-test it. Write down exactly what the yard lane must change in your report.
3. Checklist: every item of `docs/art/cast-checklist.md` incl. planted feet (`project/dev/cast/cast_feet.gd`,
   `tools/art/cast_feet.py` / `cast_feet.mjs`) at both pitches; her row in `docs/art/cast-audit.md`. Size: a big solid woman
   at about the cop's height (pole excluded), NOT taller than Rivet. `enabled: true` only if every item passes; otherwise
   `enabled: false` and list the fails.
4. Evidence to `C:\Users\kazda\kiro\gtai-masters\n26\cast\`: `warden_beside_64ppm_tilt{70,55}.png` (beside the patrol cop,
   Mulroney and Rivet, front three-quarter and back, `project/dev/cast/cast_lineup.gd`), `warden_swing_64.png` (the four
   attack columns, down-right, at 64 px/m and the same at 32 px/m beside them), `warden_close_64.mp4` (walk, wind-up, swing,
   catch, hit, fall; 15 to 40 s, 1920x1080, 60 fps; ffprobe it), `warden_fight_32.mp4` (32 px/m tilt 70, Rivet against two
   wardens with the card on, Rivet caught at least once, from a dev scene under `project/dev/cast/`). Look at every frame.
5. Commit, then `node tools/mutate/mutate.mjs --file=<main changed .gd> --max=20 --lines=<changed lines>`; quote the score.

## Owned files (allowlist; any other path: stop and report a NEED)
`project/features/characters/art/view/{p70,p55}/appliance_warden_*`, `project/data/tables/cast_cards.json` (+ its schema),
`project/features/characters/cast_*.gd`, `street_*cards*.gd`, `project/features/combat/squad/foe_cast_view.gd`,
`foe_*_card_view.gd`, `cast_*.gd` there, `project/dev/cast/**`, `tools/art/**` (cast tools), `project/tests/unit/test_cast_*.gd`
(+ `.uid`), `docs/art/cast-checklist.md`, `docs/art/cast-audit.md`, `steam/ai-provenance/2026-11.jsonl` (append),
`project/boot/launch_args.gd` `KNOWN_FLAGS` (append one line; then `node tools/debt/debt.mjs --update --accept-regression="<flag> for n26 cast"`),
`tools/debt/baseline.json` (debt tool only), `C:\Users\kazda\kiro\gtai-art\foes-n26\warden\**`, `C:\Users\kazda\kiro\gtai-art\foes-n26\warden8\**`,
`project/features/characters/street_*.gd` (walk placement only).
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
