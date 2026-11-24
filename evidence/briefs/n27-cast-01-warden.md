# Brief n27-cast-01-warden: finish the appliance warden (Peg Dolan) card from the WIP branch

Lane `cast`, branch `n27-cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd). Do NOT switch branches.
**Hard stop 04:05 local** (check `date` often): at 04:05 stop, commit what is green, report and END.
**Commit deadline 03:25: the WIP code + the red test fixed + her row (enabled false if anything is unproven) committed by then.**
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/cast` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Windowed or rendering runs: `--rendering-driver d3d12`, windowed ones `--position 0,1440`
(never the main display). Kill only your own PIDs, never by name.

## Where it stands
Last night's warden call died on a usage limit. Her art is already on `main` (commits `2c7f91f25`, `7f3232ef7`). The rest is
on branch `n26-cast-warden-wip`, one commit `20920e043` "cast WIP (not for merge)", parent `7f3232ef7` (already in this branch).
Bring it in WITHOUT cherry-picking that commit as is: `git diff 7f3232ef7 20920e043 -- <path>` per file and apply
(`git apply --3way`); `tools/debt/baseline.json` conflicts: do not hand-merge it, take ours and run
`node tools/debt/debt.mjs --update` at the end (see AGENTS.md "Debt ratchet"). Read the WIP diff whole before you start:
it adds row `appliance_warden` (enabled false) to `cast_cards.json`, `CastCards.padded/anchored/foot_y/painted_ink`,
`cast_warden_anchors.gd`, `FoeWardenCardView` (catch rows, `set_catch`), dev scenes `cast_warden_{fight,lineup,poses}`,
`test_cast_warden.gd`, tools `cast_warden_review.py`, `cast_warden_soles.py`.

## The one red test, and the rule for fixing it
`project/tests/unit/test_street_walker_hit.gd:164` (`test_a_thrown_card_is_placed_at_its_fill_about_the_planted_boot`)
fails because two WIP edits in `StreetWalkerCards.place` changed a SHIPPED card's placement: the hit check now reads
`card.texture.resource_path` instead of meta `ON`, and the hit fill is now multiplied by `StreetCopWalk.fill_of(path)`.
Keep both changes to her padded cells only (`CastCards.padded(path)`): every other card reads meta `ON` and its old fill
exactly as on `main`. **Never change a shipped card's size**; never edit that test's numbers. Prove it: the whole
`test_street_walker_*` and `test_cast_*` set green, and `node tools/tests/run_unit.mjs --changed` green.

## Build, in order (commit after each step that is green)
1. Apply the WIP, fix the red test as above, `--import`, quick gate, commit ("cast: warden card row (off), anchored walk, catch rows").
2. The catch view. `FoeWardenCardView.set_catch(h, held, tick)` must be driven, but `project/boot/prologue/**` is the yard lane's.
   First look whether the pin (Rivet held by her `catch_pole`; `project/boot/prologue/prologue_combat.gd` `first_catch_tick`
   and whatever holds the pin) is visible from features code (the arena, the Fighter, an Events signal, a meta on Rivet).
   If it is, drive `set_catch` from cast's own files (`foe_cast_view.gd`) and unit-test it. If it is not, keep `set_catch`
   as the one public entry, unit-test it, and write in your report the EXACT call the yard must add (file, function, line,
   signature) - the director files the `NEED yard`. The prologue today dyes her rig with an overalls shader and draws a
   vector pole (`prologue_props.gd`, yard-owned, do NOT edit): with her card on they double-draw; write exactly what
   the yard must switch off and how it can ask "is her card on" (e.g. `CastCards.current(&"appliance_warden") != null`).
3. Checklist: every point of `docs/art/cast-checklist.md` at both pitches, incl. planted feet (`project/dev/cast/cast_feet.gd`,
   `tools/art/cast_feet.py`), and these three that bounced work last night, measured and quoted as numbers:
   - **Body jump between consecutive rendered frames** on walk, a stop, a turn AND a reversal (aim one way, step the other;
     Mulroney had a 30 px jump there, fixed by mul-edge: read `git log --oneline -40 -- project/features/characters/` and reuse
     that path). Bar: no jump above the stride's own per-frame travel + 2 px at 64 px/m.
   - **The 64 px/m edge measure** (dark pixels outside the silhouette; `tools/art/cast_mulroney_edge.py` does it) on EVERY
     state's sheet: walk, attack, hit, fall, both pitches. Quote each.
   - **Size**: a big solid woman about the patrol cop's height with the pole excluded, NOT taller than Rivet. Quote px at 32 px/m
     70 degrees for her, the patrol cop and Rivet.
   - Wound contact: her boot on the shadow during a hit (Mulroney's lifted off; reuse what fixed his).
   No blue anywhere on her (she is not police); red is blood only.
   Her row in `docs/art/cast-audit.md` (the table + a short "after" note like the patrol cop's and Mulroney's).
   `enabled: true` ONLY if every point passes; otherwise `enabled: false` with the fails listed in the audit row. Commit.
4. Films (only after step 3 is committed), to `C:\Users\kazda\kiro\gtai-masters\n27\cast\`:
   - `warden_beside_64ppm_tilt70.png` and `_tilt55.png`: her beside the patrol cop, Mulroney and Rivet, front three-quarter and
     back (`project/dev/cast/cast_lineup.gd` / `cast_warden_lineup`).
   - `warden_swing_64.png`: her four attack columns (wind-up, swing, catch, recover), down-right, at 64 px/m with the same at 32 beside.
   - `warden_before_after_32.png`: the same tick, same zoom, card off (today's dyed rig + pole) beside card on.
   - `warden_close_64.mp4` (walk, wind-up, swing, catch, hit, fall) and `warden_fight_32.mp4` (32 px/m tilt 70, 1920x1080, 60 fps,
     15 to 40 s: Rivet against two wardens with the card on, Rivet caught at least once, from `cast_warden_fight`).
     `ffprobe` both and quote duration, size, fps. Use `tools/film/` (read `tools/README.md`). Look at frames yourself.
   - `frames.json` in that folder: `[{ "file", "title", "ppm", "before", "note" }]`, best first (create it; later calls append).
5. Mutate, capped: `node tools/mutate/mutate.mjs --file=project/features/combat/squad/foe_warden_card_view.gd --max=20` (and
   `street_walker_cards.gd --max=20 --lines=<your changed lines>` if time); quote killed/(killed+survived).

## Owned files (allowlist; any other path: stop and report a NEED, do not edit it)
`project/features/characters/art/view/{p70,p55}/appliance_warden_*`, `project/data/tables/cast_cards.json` (+ its schema),
`project/features/characters/cast_*.gd`, `project/features/characters/street_*.gd` (card placement only),
`project/features/combat/squad/foe_cast_view.gd`, `foe_*_card_view.gd`, `cast_*.gd` there, `project/dev/cast/**`,
`tools/art/**` (cast tools), `project/tests/unit/test_cast_*.gd`, `test_street_walker_*.gd` (only to ADD a test, never to change
an existing number) (+ `.uid`), `docs/art/cast-checklist.md`, `docs/art/cast-audit.md`, `steam/ai-provenance/2026-11.jsonl`
(append), `docs/decisions.md` (append one line at a time), `project/boot/launch_args.gd` `KNOWN_FLAGS` (append one line; then
`node tools/debt/debt.mjs --update --accept-regression="<flag> for n27 cast"`), `tools/debt/baseline.json` (debt tool only),
`C:\Users\kazda\kiro\gtai-art\foes-n26\warden*\**`, `C:\Users\kazda\kiro\gtai-art\foes-n27\**`, `C:\Users\kazda\kiro\gtai-masters\n27\cast\**`.
**Forbidden** (other lanes): `project/boot/prologue/**`, `prologue_stage.json`, `prologue_yard_dressings.json`,
`project/features/player/**`, `rivet_*` art, `input_actions.json`, `rivet_motion.json`, `project/features/combat/kills/**`,
`project/features/souls/**`, `ghost_*.json`, `combat.json`, `enemies.json`, `weapons.json`, `bosses.json`,
`project/dev/gauntlet/**`, `tools/gauntlet/**`, root `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`.
No image generation in this call.

## Repo law
AGENTS.md and STANDARDS.md. Typed GDScript, ~200 lines per file (hard 300), functions <= 40 lines, <= 5 params, `Log` not
`print`. One commit per change, staged per path (`git add <path>`); never `git add -A/./-u`, `commit -a`, `stash`, `reset --hard`,
amend or rebase; never push. `--import` after new art or scripts before committing; commit `.uid`/`.import` with their source.
`node tools/gate/quick.mjs` before each commit. **Fix lint and format findings in your own edit and go on.** If the pre-commit
hook fails on `tools/film/kill_reel_*.break.test.mjs`, the class cache is stale: run a Godot `--import` and commit again
(never skip the hook). Replay digests, quest 1 and prologue tapes must not move (rendering only). Never fake a number or a frame.

## Report at the end (and END by 04:05)
Commits (sha + subject); the red test's fix in one sentence; the checklist row with every number (jump incl. reversal, edge
per sheet, size px); enabled true/false and why; the exact yard call(s) needed; film paths + ffprobe lines; mutate score;
quick gate line; what you could not do.
