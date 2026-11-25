# Brief n29-cast-07: the war machine (pile-driver) walks on 8 drawings with an exchange of support

Lane `cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd), branch `n29-cast`. You are a builder sub-agent.
**Hard stop 06:15 local** (check `date +%H:%M` often). **Commit part 1 by 06:03, part 2 by (next call).** Never end with
finished work uncommitted. Keep `C:\Users\kazda\kiro\gtai-art\foes-n29\war8\STATE.md` updated after every step. Then report and END.

## Goal (owner's pick)
"New walk art for the pile-driver and the war machine" (one character: the `war_machine` card is the pile-driver, see
`docs/decisions.md` / JOURNAL 01:10). Today `war_machine_armed_walk.png` is four drawings with a flat rear pad in all four in
the 70 profile: no lift, no exchange of support (`docs/art/cast-audit.md` "Pile-driver feet, n28": sole 24.75 / 22.97 px, body
jump 13.22 / 13.35 at 70 / 55, all FAIL). **Bars: sole slide <= 2.0 px at 64 px/m, body jump <= 12 px, every pad lifts in turn
(name which pad is planted in each of the 8 drawings, per facing), every facing.** Size: the card is now `body_scale` 0.84
(cast-01b, `31df5170f`): keep the view's size rule; the new sheet must give the same on-screen height as the old at the same
body_scale (quote both).

## The new art (generated and accepted by the director for identity)
`C:\Users\kazda\kiro\gtai-art\foes-n29\war8\out\war8_{70,55}_{down,dr,right,ur,up}.png`: one facing per image, 8 drawings in a
2x4 grid (row 1 = 1-4, row 2 = 5-8), green key `#00B140` (codex says the green varies: key by distance, not one value), edits of
the shipped walk sheet. Contacts `foes-n29/review_war8_s2.jpg`, `review_war8_s2b.jpg`. Codex flagged a repeated support pattern
in 55_right row 2, and frame 8 = frame 4's lift in 70_ur and 55_dr: your audit decides; a facing whose exchange fails gets a
reordered drawing sequence if that fixes it (say which), else it is reported as FAIL.

## Model to copy
The door carrier's 8-drawing call (`evidence/briefs/n29-cast-06-door8.md` and its commits, if landed: `git log --oneline -- project/features/characters/cast_door_anchors.gd`)
and the gunner's: `tools/art/cast_foe_eight.py`, `tools/art/cast_foe_soles.py` (anchors with `EIGHT` / `FOUR` / `WALK`).
The war view is `project/features/combat/squad/foe_war_card_view.gd` (`_cell`, `HEIGHT_M` 2.6 x body_scale, `BODY_PX`, louvres
heat): add the 8-drawing sheet the way the gunner's view takes its EIGHT, `WALK` switch in a generated `cast_war_anchors.gd`.

## Part 1: cut, pack, key-clean, provenance, import (commit by 06:03)
`project/features/characters/art/view/{p70,p55}/war_machine_planted8_armed_walk.png` (+ `.import`), one body height across
facings = the shipped walk's; key-clean 0 opaque px with a 50-level green or magenta lead; no red or vermilion introduced
(strict-red px before/after; hazard stripes stay amber, louvre glow stays amber). Look at each packed sheet at 1x on grey (Read
tool, `build/look/n29-war8/`) and say what you see per facing. One provenance line per PNG.

## Part 2: anchors, view, feet table, film (commit by (next call))
Feet table before (four-drawing) / after (eight) per pitch and facing, measured in the delivered film frames, appended to
`docs/art/cast-audit.md` ("Pile-driver on eight drawings, n29"). Re-pin `project/tests/unit/test_cast_war_machine.gd` where it
pins the sheet; `node tools/tests/run_unit.mjs --changed` (quote); `node tools/gate/quick.mjs`. Film
`C:\Users\kazda\kiro\gtai-masters\n29\cast\war8_walk_32.mp4` (1920x1080, 60 fps, 15-40 s, 32 px/m, tilt 70, ffprobe) and a 64
px/m before/after still `war8_feet_before_after_64.png`; append both to `frames.json`. Ship `WALK = EIGHT` only if every
facing is no worse than the four-drawing walk; else keep FOUR, commit the rest, report the failing facing. Mutate
`foe_war_card_view.gd --lines=<yours> --max=20 --tests=test_cast_war_machine`, at most 15 min, quote the score.

## Repo law, allowlist
Same repo law as `evidence/briefs/n29-cast-06-door8.md` (runGodot, APPDATA, GODOT_BIN, lane lock, mem-budget, typed GDScript,
pathspec commits, banned git commands, hook flakes, no image generation). Commit messages end with
`Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
Allowlist: `project/features/characters/art/view/{p70,p55}/war_machine_planted8_*` (+ `.import`),
`project/features/characters/cast_war_anchors.gd` (+ `.uid`, new, generated), `project/features/combat/squad/foe_war_card_view.gd`
(the sheet switch only), `tools/art/cast_foe_eight.py`, `cast_foe_soles.py`, `cast_war_*.py`, `project/tests/unit/test_cast_war_machine.gd`,
`docs/art/cast-audit.md` (append), `steam/ai-provenance/2026-11.jsonl` (append), `gtai-art/foes-n29/war8/**`, `build/look/n29-war8/`,
`gtai-masters/n29/cast/`. Forbidden: `cast_cards.json` (unless the sheet must be named there: that key only), the boss files,
`enemies.json`, other characters' art, other lanes' files.

## Report (then END)
Shas, heights, key-clean counts, the planted-pad sequence per facing, the feet table, WALK shipped, unit/quick lines, film +
duration, mutate score, what you could not do.

## Added session 4 (director, lessons from the door's eight)
- The door's eight (`073321ae7`, `fac845dd9`, `61c383438`) came out WORSE than its four until a placement bug was fixed:
  `FoeShieldCardView` rescaled after the anchored placement, so every sole slid 1.41x. If you add an anchored contact to
  `foe_war_card_view.gd` (today it sets `position` to the ground point then `scale`, no `CastFarCard`), scale FIRST, then
  place the anchored sole (see `FoeShieldCardView._rescale` in `61c383438`), and quote the sole slide with and without.
- Order of value if time runs short: part 1 commit (packed + key-clean + provenance) > the feet table (eight vs four, tool
  `cast_feet.tscn` path as in `tools/film/cast_door_films.mjs feet`) > the film. Measure the feet BEFORE spending on the film:
  if every facing of the eight clearly fails, ship `WALK = FOUR`, commit, and report which drawings break the exchange.
- The quick gate's Godot parse step failed on untouched files: `node tools/gate/quick.mjs --no-godot` + GUT is accepted, say so.
- `node tools/tests/run_unit.mjs --changed`: quote its line in every commit's report.
- Do not grow the machine: `body_scale` stays 0.84 (owner: no heavy slow giants as the rule).

## Added 05:44 (director): THIS CALL = PART 1 ONLY
- Do Part 1 (cut, pack, key-clean, red, provenance, import, look at each packed sheet) and commit it by 06:03. Do NOT start
  the view, anchors, feet or film: a later call does Part 2 from your STATE.md. If Part 1 is committed before 06:03 and
  time remains, write in `gtai-art/foes-n29/war8/STATE.md` the planted-pad sequence per facing read from the packed
  sheets (which pad is down in each of the 8 drawings), nothing else.
- The door call learnt that codex "edits" re-encode every drawing (mean 4-5 levels): for war8 that is fine (all new art),
  but key by distance from the green, not one value.
- A sonnet builder runs beside you until 06:12 on thug files (`project/dev/cast/cast_thug_*`, `cast_flash_fight.gd`,
  `evidence/n29/thug/**`): never stage or revert them; commit only with `git commit -- <your paths>`; the lane Godot lock is shared.
