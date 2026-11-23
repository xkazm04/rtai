# Brief n26-06 `card`: Mulroney's cast card in the prologue, the pump tell on it (lane yard, run n26)

HARD STOP: <HARD> local (stop work, report). LAST COMMIT: <LAST>. Check `date` now and then. Short call: one small code change, one test, two frames.

## Before anything
- `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/yard` and `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe` in every shell that runs Godot. `--rendering-driver d3d12` for renders. One Godot at a time; windowed runs `--position 0,1440`; kill only PIDs you started.
- The Director merged `n26-cast` (cast lane) into this branch just before this call: Mulroney's cast card is ON (`cast_cards.json` row `sergeant_mulroney`), drawn by `project/features/combat/squad/foe_cast_view.gd`. Read its `set_pump(h, progress, fired_this_tick)` (progress < 0 = normal pose; 0..0.5 pump back; 0.5..1 pump forward) and `CastCards.current(id)` in `project/features/characters/cast_cards.gd`. Do not edit either file (cast's).
- Today `project/boot/prologue/prologue_command_view.gd` `_process` shows the vector dress `PrologueCommanderDress` whenever the boss bar shows, so with the card on the prologue double-draws Mulroney (dress over card).

## The change (yard-owned)
In `PrologueCommandView._process` (keep it <= 40 lines; split a helper if needed):
```
_dress.visible = _bar.visible and CastCards.current(&"sergeant_mulroney") == null
if _bar.visible:
    var p: float = _battle.fire.shotgun.pump_progress(_stage.tick)
    FoeCastView.set_pump(boss, p, p == 0.0)
    _dress.pump = p
    if _dress.visible:
        _pose.call(_dress, boss)
```
The marker (`_marker` / `_pump_marker`, 1.6 m at 32 px/m) and the sounds stay keyed on `_dress.pump`, so they play with the card too. Confirm `fired_this_tick` is right: if the shotgun's pump clock starts on the discharge tick, `p == 0.0` on that tick; if not, pass `_battle.fire.shotgun.shot_ticks.back() == _stage.tick` instead, and say which in your report.

## Checks (all required)
1. A unit test (`project/tests/unit/test_prologue_command_card.gd` or extend the existing command-view test): card on -> dress hidden and `set_pump` reaches the boss (whatever `foe_cast_view.gd` stores on the fighter: meta or field; read it); card off (`ViewMode` cards false) -> dress visible as before. `node tools/tests/run_unit.mjs --changed` green.
2. LOOK at frames and save them: `evidence/yard26/card_pump_64ppm.png` (Mulroney mid-rack, card on: ONE Mulroney, the arm pumping, the marker above) and `evidence/yard26/card_pump_32ppm.mp4` (15-20 s around his first two blasts on the seed-7 pilot, line_fire yard, tilt 70, 1080p60; ffprobe it and quote the line). Use the dev film code that call 03 used for `pump_32ppm_before_after.mp4`. Check the patrol cops in the line too: if any line cop is drawn twice (card + the rifle/shield overlay in `_draw`), say so with a frame; fix only if the fix is inside `project/boot/prologue/**`.
3. The seed-7 prologue pilot result is byte-identical to the current pin (render-only change); quote ticks.
4. `node tools/mutate/mutate.mjs --file=project/boot/prologue/prologue_command_view.gd --max=20 --lines=<your changed lines>` after committing; quote killed/(killed+survived).
5. `node tools/gate/quick.mjs` before the commit.

## Owned files (allowlist). Any other path: stop and write the NEED in your final report.
- `project/boot/prologue/**`, `project/tests/unit/test_prologue_*`, `project/dev/prologue/**`, `project/dev/prologue_yard/**`, `evidence/yard26/**`, `.uid` files of new scripts there.
- `tools/debt/baseline.json` only through `node tools/debt/debt.mjs --update --accept-regression="<reason> for n26 yard"`.

## Forbidden
`project/features/**` (cast, melee, keys, pressure own them), `project/data/**` except nothing, other worktrees, `JOURNAL.md`, `REPORT.md`.

## Repo law
Typed GDScript, files <= 200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`. Stage per path; one commit per change (`git commit -- <paths>`); no `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push. Fix lint and format findings in your own edit and go on. If a pre-commit tool test fails in `tools/film/kill_reel_*.break.test.mjs` with `mkdirSync(undefined)`: run a Godot `--import` (stale class cache) and commit again; never `--no-verify`.

## Report (final message)
Commits, test names, the frames' paths and what you saw in them, ffprobe line, seed-7 ticks, mutate score, what was not done.
