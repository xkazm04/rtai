# n30 combat call 05: a killed card foe falls on his own fall sheet

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. You are Opus. Check `date +%H:%M` at start.
**Commit the code + tests by minute 35, evidence by minute 60, report and END at minute 70.** Never end uncommitted.
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
**One Godot at a time in this worktree**: another builder (c02 electro hop) runs Godot here too. Before each Godot launch
(unit tests included) wait until no file in `$LOCALAPPDATA/gtai/runs/*.json` names `n23-street`
(`grep -l n23-street "$LOCALAPPDATA"/gtai/runs/*.json`), re-check every 30 s. Every launch through the shipped tools
(`tools/tests/run_unit.mjs`, `tools/film/*.mjs`, `tools/dev/run.mjs`, `runGodot`), never raw `$GODOT_BIN`. Windowed: `--position 0,1440`.

## Owner's verdict (docs/decisions.md:1598)
"a killed card foe falls on his own fall sheet when the kill style has none".

## What is known (read `evidence/n29/kills/card_scale.md` and `docs/day/2026-11-25/n29-combat/REPORT.md` item 4 first)
- `project/features/combat/kills/kill_fall_cells.gd` `attach`: a whole-body kill style (`kill_new_styles.gd:60-80`) gives the
  body copy a hidden fall grid: the style's own cells (`KillDeathCells.path_of`) else `StreetWalkerFall.path_of(art, row)`,
  which for a card foe resolves to the generic `cop/head_swat` grid (5 facings x 3 rows, `STILL_PX` 192). n29 fixed its
  size (`victim_scale` = `CastCardPose.of(rig).sheets.scale_of(rig.actor_id)`).
- A card foe (`CastCardPose.of(rig)` non-null; rows on: `sergeant_mulroney` body_scale 1.23, `appliance_warden` 1.18,
  `contractor` 1, `rocket_trooper` 1.08; `robot_thug` may be turned on by the cast lane) has his own
  `pose.sheets.fall` (`CastCards.Sheets.fall`, a full res:// path, e.g. `view/p70/sergeant_mulroney_fall.png`): the
  sheets have their own cell geometry (p70 mulroney 2300x930, warden 2450x1320, trooper 3980x1164: NOT the 192 px grid).
  A card foe that dies without a kill style draws that sheet: `CastCardPose.path_for` -> `sheets.fall` when
  `StreetWalkerFall.down(rig)`; find exactly how that living death sizes, anchors (feet), frames (hframes/vframes,
  facing, flip) and steps it (look at `foe_cast_view.gd`, `street_walker_cards.gd`, `street_walker_fall.gd`,
  `street_fall_fit.gd`, the cast anchor classes such as `StreetMulroneyAnchors`), and reuse that code path or its
  numbers; do not invent new geometry.
- Mulroney's fall art shows the shotgun and cap flying: the proof is that the killed body now shows that art.

## Do
1. In `KillFallCells.attach`: when the kill style has no own cells (`own` empty) and the victim is a card foe with a
   usable `sheets.fall`, the grid is his own fall sheet, at his card scale (`scale_of`), facing as the grid does
   (the fall direction `toward`), stepped by `step`/`row_at` over the sheet's own row count. A card row without a usable
   fall sheet (missing file, unknown geometry) keeps the generic grid: list such rows in the evidence and in your report
   (the director writes `NEED cast`). Keep the old path one flag away: `--kill-card-fall=grid` (declare it in
   `project/boot/launch_args.gd` `KNOWN_FLAGS`, append-only one line, and run
   `node tools/debt/debt.mjs --update --accept-regression="--kill-card-fall for n30 combat"` if the debt check asks).
   Keep `kill_fall_cells.gd` <= 200 lines (hard 300), functions <= 40 lines: split into a new
   `project/features/combat/kills/kill_card_fall.gd` if needed (with its `.uid`: run the import, see below).
2. Check every reader of the grid still works with the card sheet: `step`/`StreetFallFit.fit`, `KillCellShadow`,
   `KillNewStyles` (`FEET`, `HEIGHT`), `StreetFallBetween.is_fall_card`, `lands_face_down`. If one needs the 192 px grid,
   handle it, do not break the street walkers (their kills must be pixel-identical: prove with one street walker kill still).
3. Tests (`project/tests/unit/test_kill_card_fall.gd`, and keep `test_kill_card_scale` green): a card foe with no own
   cells gets his own fall sheet path, at `scale_of`; a style with own cells keeps them; a street walker keeps the
   generic grid; `--kill-card-fall=grid` (or the static toggle behind it) gives the old grid; a row with no usable
   sheet falls back. `node tools/tests/run_unit.mjs --select=test_kill_card_fall,test_kill_card_scale` green.
   `node tools/lint/lint.mjs` and `node tools/debt/debt.mjs --check` green; fix lint and format findings in your own edit and go on.
4. Commit A (code + tests). Then mutate: `node tools/mutate/mutate.mjs --file=features/combat/kills/kill_fall_cells.gd --lines=<changed> --max=20 --tests=test_kill_card_fall,test_kill_card_scale`
   (and the new file if any), budget 15 min; quote killed/(killed+survived).
5. Evidence, at 64 px/m same tick before | after (before = HEAD code; easiest: the same command with `--kill-card-fall=grid`):
   `node tools/film/kill_reel.mjs --out=build/n30/cardfall/<arm> --weapons=machine_pistol --ppm=64 --dirs=90 -- --controls=legacy --foe-mix=sergeant_mulroney`
   (n29 c7 command; kill on tick ~174, stitch style on the fall grid; kill_reel may now pass `--controls=legacy`
   by default, passing it again is harmless). Then two other card foes (`appliance_warden`, `rocket_trooper` or
   `contractor`). Stills to `C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/card_fall_<foe>_pair_64.png`
   (before | after, labelled, three ticks: just before the kill, mid-fall, lying). A 32 px/m clip
   `films/card_fall_32.mp4` (kill_reel `--ppm=32 --clips`, then stitch the three foes' before|after clips with ffmpeg;
   1920x1080, 60 fps; n29 found a reel clip is ~2.5 s: concatenate the three foes with a quarter-speed repeat
   (`setpts`) to reach 15 s; ffprobe it and quote the line). Append entries to `frames.json` there
   (`{ "file", "title", "ppm", "before", "note" }`; another builder may append too: re-read just before writing).
   **Look at each still yourself**: say whether the fallen body shows Mulroney's shotgun and flying cap, and whether its
   size and feet match the standing card (no jump at the switch: measure the figure bbox on the frames before and at the switch).
   Write `evidence/n30/kills/card_fall.md` (commands, ticks, sizes, routing per row, what you saw). Commit B.

## Commits (stage per path; never `git add -A/./-u`, no stash, no amend, no rebase, no reset --hard)
End each message with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. The pre-commit hook can take ~12 min;
never skip it. If it fails on a stale class cache (or a new `.uid` is missing) run
`node -e "import('./tools/lib/godot.mjs').then(m=>m.runGodot(['--import'],{name:'import'}))"` and commit again.
Do not touch `docs/decisions.md` (the director writes it), JOURNAL.md, REPORT.md.

## Allowlist (any other path: stop and report a NEED)
`project/features/combat/kills/**`, `project/tests/unit/test_kill_card_fall.gd` (+ `.uid`), `project/tests/unit/test_kill_card_scale.gd`,
`project/boot/launch_args.gd` (one KNOWN_FLAGS line), `tools/debt/baseline.json` (through the debt tool only),
`evidence/n30/kills/**`, `build/**`, the masters dir. Forbidden: `project/features/characters/**` (cast's: read only),
`cast_cards.json`, `project/features/combat/squad/**` card views, `tools/film/kill_reel*` (read only),
`weapon_fx_electro.gd`, `weapon_fx_bolt.gd`, other lanes' worktrees.

## Report and END
Files, commits, commands with result lines, the routing per card row, mutate score, sizes, what you saw, what you could not do.
