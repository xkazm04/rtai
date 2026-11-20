# n20-kerf brief 03: the blink and the blink-slice, drawn for the spectral look

Lane `kerf`, worktree `C:\Users\kazda\kiro\gtai-wt\n20-kerf`, branch `n20-kerf`. Visual night: no sim,
replay, parity or bake digest may move; abilities, numbers, timing and hit boxes unchanged. **Everything
resolves on the tick the button is pressed, and that stays: the look has to sell an instant cut, not
delay it.** Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/kerf`. Godot:
`C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`, `--rendering-driver d3d12`
for rendering, `--position 0,1440` on windowed runs, one Godot process at a time, kill only your own PIDs.

Everything below applies ONLY under `GhostLook.spectral(&"kerf")`; the legacy look draws exactly what it
draws today (constants and code path untouched).

## Part A first: fixes from the director's review of 3e2aacee0 (commit these on their own)
1. **Feed the stage.** Make the one-line call site you reported (`v._bodies.kerf.stage = stage` in
   `GhostFormView.make`, `project/features/souls/ghost_form_view.gd`, flight's file). That single line
   is allowed tonight; name the file and line in your final message. Nothing else in that file.
2. **Top view must read as the plate's top inset, not a bare jet** (look at the top-right inset of
   `C:\Users\kazda\kiro\gtai-masters\n20\concepts\kerf_a.png`; in `wire_idle_32_top.png` the cable arch
   and arms do not read). The cable arch is drawn ABOVE the hull (after it in the tree, lens still on
   top of all), over the hull's rear half (its centre about -0.2 m on the body axis), the round end of
   the arch pointing to the TAIL, about 0.62 m long. The two arms start at the cross-beam knuckles and
   run BACKWARD along the flanks, needles pointing to the tail (like rapiers sheathed), 6-10 degrees out.
   Mood: POISED = arch raised (its length x 1.15, arms 14 degrees out: hackles up, coiled); CRUISE and
   LUNGE = arch flattened (length x 0.85 along the body, x 0.9 across) and arms tucked (3 degrees).
   Ease between moods over 4 ticks, never snap except into LUNGE.
3. **Beams read on pale ground too.** Under the teal glow add a thin ink underlay
   (`Color(0.09, 0.08, 0.07, 0.35)`, width about 0.07 m) so the three beams read on the pale boulevard
   and on dark asphalt. Check both in a still.
4. **Tests that bite.** The mutate run on `kerf_spectral.gd` scored 4/12. Add tests that kill the
   survivors (sprite attachment, scale, lens choice per mood, arch scale per mood, beam count/length).
   Re-run `node tools/mutate/mutate.mjs --file=project/features/souls/kerf_spectral.gd --max=12` after
   committing and quote the new score (target >= 8/12).
5. Re-shoot `wire_idle_32_top.png`, `wire_idle_32.png`, `wire_cruise_32.png` (overwrite) and look at them.

## Part B: the blink-slice

## What last night's film showed wrong (fix these)
1. No wind-up to read: aim line, cut, relocation and hit star all arrive on one tick.
2. The blink after-images repeat one upright pose while he changes pose (three KerfRig copies along the path).
3. At the cut, guard, blades and flash share one patch; the kill only reads after he has passed.
4. At 64 px/m the big top rig covers the centre of the struck body.

## The design (director's decision; build it so each piece is one constant)
- **The idle is the wind-up** (already in KerfSpectral: POISED, eye open). Add: while the sight has a
  target (`KerfView._sight` logic, `KerfStage.pick` on `sight_aim`), the eye goes to HALF and the
  body's nose turns onto the aim line in the top view (render-only yaw toward the target, at most
  25 degrees, eased over 4 ticks).
- **One after-image where he left, in the pose he left in.** Each blink leaves ONE after-image at
  `trail_from`: a snapshot of what KerfSpectral showed on the tick BEFORE the blink (same view, cell,
  facing/rotation, mood, scale), drawn teal-washed (`modulate` like `KerfView.ECHO_WASH`), alpha 0.55
  fading to 0 over `cut_hang_s`, slightly stretched toward the blink direction on its first 3 ticks. Keep
  a one-tick snapshot buffer in the view so the pre-blink pose is known. Pool them (a 3-blink chain).
  Reduced motion: no after-image.
- **The slot.** On the press tick the path from the after-image to him is drawn as ONE thin, ruler-straight
  slot: pale-mint core (~0.04 m) in a narrow teal glow (~0.12 m), no ink fat line, no dashes. It does not
  grow: it is all there on the press tick. Over `cut_hang_s` it retracts from the after-image end toward
  him and thins. The three charge beams: the spent beam is visibly gone from his tail on that same tick.
- **He is already past.** On the press tick he is drawn 0.9 m behind the target (the sim already put him
  there). Add a render-only overshoot: for the first 6 ticks after a slice the body is drawn up to 0.5 m
  further along the blink direction, easing back to the sim point (cubic ease-out), so his body and the
  victim never share a patch (fixes 4). LUNGE cell meanwhile.
- **The victim stays whole on the press tick.** No star, no flash and no cut flare on top of the victim
  on that frame: under spectral, KerfView skips `_flare` and the `_cut` circle; the hanging cut mark across
  the target may appear from tick +3 (`CUT_MARK_DELAY_TICKS` = 3), thin. Then find, and report precisely,
  what ELSE is drawn on the victim on the press tick (hit-feel flash `flash_ticks` from
  `features/combat/hit_feel/hit_feel.gd` and its table, kill marks/stars in `features/combat/kills/`,
  the split itself in `signature_kill.gd` / `kill_split*`, the `kerf_split` row of
  `data/tables/signature_kills.json`). Those files are NOT yours: do not edit them. If a delay of the
  victim's split by ~4 ticks or removing the flash/star needs one of them, write in your report the exact
  `NEED <file>: <one-line change> <why>` and whether a data value (e.g. a new row field) would do it.
  If the ONLY change needed is a one-line call site, you may make that one line and name it in the report.

## Files you own
`project/features/souls/kerf_*.gd` (incl. `kerf_view.gd`, `kerf_spectral.gd`, `kerf_stage.gd` read-only
getters only), `project/dev/ghost-powers/kerf_beat.gd`, tests named for them. Files about 200 lines
(hard 300), functions <= 40 lines, <= 5 params, typed, `Log` not print. Split `kerf_view.gd` (now 190
lines) into a `kerf_slot.gd`/`kerf_echo.gd` rather than growing it past 200.

## Tests
`project/tests/unit/test_kerf_slot.gd` (or similar): one after-image per blink at `trail_from`, carrying
the pre-blink snapshot; slot full length on the press tick and retracting after; overshoot is at its maximum
on the slice tick and 0 by tick 6; legacy look keeps three echoes. Run
`node tools/tests/run_unit.mjs --changed`, and the scenario suite once
(`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`) to prove no digest moved.

## Evidence (into `C:\Users\kazda\kiro\gtai-masters\n20\kerf\`)
- A frame strip of ONE blink-slice from the review driver (`project/dev/ghost-powers/ghost_review.tscn`,
  `--ghost-look=spectral`, Kerf, 32 px/m), straight-down top view: press tick, +3, +15 frames side by side,
  `slice_strip_top_32.png`; the same for the 70 tilt `slice_strip_70_32.png`; and the same three frames
  at 64 px/m `slice_strip_64.png`. Also the same press-tick frames WITHOUT the flag (legacy) as
  `slice_strip_legacy_32.png`. Use `tools/film/` (read `tools/README.md`) for same-tick captures.
- Look at the strips yourself: at +0, can you see where he was (after-image), where he is (past the
  target) and the cut (slot through a still-standing target)? Say what you see, honestly.

## Commit
Stage per path, one commit; `node tools/gate/quick.mjs` green first. Then
`node tools/mutate/mutate.mjs --file=project/features/souls/kerf_view.gd --max=12` (or the new slot file)
and quote the score. No `git add -A/./-u`, no stash, no reset --hard, no commit -a, never push.

## Final message
Files, test/scenario/gate lines, mutate score, strip paths, what you saw in them, and the exact NEED lines.
