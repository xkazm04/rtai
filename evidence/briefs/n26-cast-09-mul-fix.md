# Brief n26-cast-09-mul-fix: Sergeant Mulroney passes the checklist (8-drawing walk, wound contact), then his card goes on

Lane `cast`, branch `n26-cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd).
**Hard stop 15:30 local** (check `date`). **Commit deadline 15:15: commit the 8-drawing cut + placement FIRST, then the wound fix, before films.** Keep films short (one close clip, two stills); skip re-taking anything that did not change. After it: stills, films and your report only.
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/cast` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Windowed runs: `--position 0,1440`, `--rendering-driver d3d12`. Kill only your own PIDs.

## Where he stands
Your Mulroney call (commits cd2b7d4be, 984d0453c, 745d86cde; `docs/art/cast-audit.md` "Sergeant Mulroney card admission")
left `sergeant_mulroney` at `enabled: false` with **Walk, Feet, Hit and Shadow FAIL**: down-right sole 32.98 px (70) and >= 10.92
px (55) on the 4-drawing walk at 3.2 m/s; his boot lifts away from its shadow on a wound. The cop8 call (read its commits
first, `git log --oneline -15`) put the patrol cop on an N-drawing walk with a per-drawing support-sole anchor table.

## Build, in order
1. Cut the director's 8-drawing walk `C:\Users\kazda\kiro\gtai-art\foes-n26\mul8\out\mul8_armed_walk_{70,55}_{a,b}.png`
   (accepted; layout as cop8: `_a` = down, down-right, right; `_b` = up-right, up; 8 drawings, support L in 1-3, R in 5-7;
   prompts `mul8/jobs.json`) into `project/features/characters/art/view/{p70,p55}/sergeant_mulroney_planted8_armed_walk.png`
   (+ `.import`, provenance, same figure scale as his shipped walk by body height, key-clean, toned like his other sheets;
   intermediates in `foes-n26/mul8/pack/`). Put his card walk on the cop8 anchored placement (same mechanism, his own table
   and STEP_M chosen from his drawn advance; record drawings/s at 3.2 m/s). His 4-drawing strip stays selectable with one value.
2. Wound contact: find why his boot leaves its shadow on a hit (the hit sheet's baseline/anchor vs the walk's, or the hit cell's
   ground point) and fix it in the cut or the anchor so the feet stay on the shadow through the hit; measure it the way the
   checklist's Shadow row does.
3. Re-run every checklist item that failed (Walk, Feet, Hit, Shadow) at both pitches with the same tools as your Mulroney call;
   update his row in `docs/art/cast-audit.md`. If ALL items pass: `enabled: true` in `cast_cards.json`, and prove the prologue
   still runs: the prologue scenario/tapes pass and a prologue run shows his card (the vector dress overlay is yard-owned: with
   the card on it may double-draw until the yard lane hides it; take a still of what the prologue shows and say so plainly).
   If any item still fails: stay `enabled: false` and list it.
4. Unit tests, `node tools/tests/run_unit.mjs --changed` green, `node tools/gate/quick.mjs` before each commit; replay digests,
   quest 1 and prologue tapes must not move. Then `node tools/mutate/mutate.mjs --file=<main changed .gd> --max=20 --lines=<changed lines>`.
5. Evidence (look at every frame): replace `C:\Users\kazda\kiro\gtai-masters\n26\cast\mulroney_close_64.mp4` (walk on the 8
   drawings with the sole dots, aim, fire, pump, hit with the shadow, fall; 15 to 40 s, 1920x1080, 60 fps; ffprobe),
   `feet_mulroney_before_after_64ppm_tilt70.png` (before = your 4-drawing walk at 745d86cde, after = 8 drawings; sole dots per
   rendered frame), `mulroney_hit_shadow_64.png` (before/after of the wound contact), and if he is enabled
   `mulroney_fight_32.mp4` re-taken.

## Owned files (allowlist; any other path: stop and report a NEED)
`project/features/characters/art/view/{p70,p55}/sergeant_mulroney_*`, `project/data/tables/cast_cards.json` (+ schema),
`project/features/characters/street_*.gd`, `project/features/characters/cast_*.gd`, `project/features/combat/squad/foe_cast_view.gd`,
`foe_*_card_view.gd`, `cast_*.gd` there, `project/dev/cast/**`, `tools/art/**`, `tools/film/**` (new files only),
`project/tests/unit/test_cast_*.gd` (+ `.uid`), `docs/art/cast-checklist.md`, `docs/art/cast-audit.md`,
`steam/ai-provenance/2026-11.jsonl` (append), `project/boot/launch_args.gd` `KNOWN_FLAGS` (append one line, then
`node tools/debt/debt.mjs --update --accept-regression="<flag> for n26 cast"`), `tools/debt/baseline.json` (debt tool only),
`C:\Users\kazda\kiro\gtai-art\foes-n26\mul8\**`, `C:\Users\kazda\kiro\gtai-art\foes-n26\mulroney\**`.
**Forbidden**: `project/boot/prologue/**`, `prologue_*.json`, `project/features/player/**`, `rivet_*` art, `input_actions.json`,
`project/features/combat/kills/**`, `project/features/souls/**`, `ghost_*.json`, `combat.json`, `enemies.json`,
`weapons.json`, `bosses.json`, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`, the patrol cop's and the warden's art.

## Repo law
AGENTS.md and STANDARDS.md. Typed GDScript, ~200 lines per file (hard 300), functions <= 40 lines, <= 5 params, `Log` not
`print`. One commit per change, staged per path; never `git add -A/./-u`, `commit -a`, `stash`, `reset --hard`, amend or
rebase; never push. `--import` after new art/scripts before committing; commit `.uid`/`.import` with their source.
**Fix lint and format findings in your own edit and go on.** Never fake a number or a frame. Do not use `--no-verify`.

## Report at the end
Commits (sha + subject), his STEP_M and drawings/s, the checklist row before/after, enabled or not (and why), what the prologue
shows with the card on, mutate score, quick gate, evidence paths, what you could not do.
