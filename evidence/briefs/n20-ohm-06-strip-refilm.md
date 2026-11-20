# Brief n20-ohm-06: the judged cast strip on a stun-only cast, re-film, mutate

Worktree `C:\Users\kazda\kiro\gtai-wt\n20-ohm`, branch `n20-ohm`. Read `git log --oneline -15` first (brief 05's
commits: top staff, transform/hit if changed, HUD chip, look switch). Plate:
`C:\Users\kazda\kiro\gtai-masters\n20\concepts\ohm_c.png`. VISUAL ONLY: no sim, replay, parity or digest moves.

Environment: in every shell `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/ohm` and
`GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; `--rendering-driver
d3d12` for anything that renders; `--position 0,1440` on every windowed run (never the main display); one Godot at a
time; free only your own PIDs, never kill by name. Same file rules as brief 05 (Ohm files only; never delete `##`
comments or constants to fit caps; never hand-edit `tools/debt/baseline.json`).

## Step 0: merge flight's tail 0b (the director tells you to)
`git merge n20-flight` (allowed; only that branch): 5e906fd53 makes the tail root dense and bright, anchored aft of
the body in both views, wisps soft round puffs. In `ghost_hover.json` keep flight's schema and OUR ohm row values
(our `fade_from` is 0; flight's branch says 0.18: keep 0). `node tools/tests/run_unit.mjs --changed` after it. Then
look at one top and one tilt70 still at 32 px/m: if the tail now fights the robe (two tails, or the root floating
off the hem), retune only the ohm row's tail numbers and say what you changed.

## Part A: the owner's judged strip (no commit needed unless a dev driver changes)
The owner judges "a strip of one cast (jars at one, two, three, press tick, +4 frames) from the top view with all
three links and all three victims visible". Today's `n20/ohm/bolt/cast_strip_top_32.png` (ticks 105..139) is a cast
that KILLS the three guards, so the shared shock-kill X-ray (skeleton starbursts, not Ohm's files) covers them.
Re-shoot it on the FIRST cast of a take with fresh guards (0.5 damage + 1.2 s stun each, nobody dies): jars 1, 2, 3
before the press, press, +2, +4 (the third link lands at +4), same labels/format as today, top and tilt70, into
`C:\Users\kazda\kiro\gtai-masters\n20\ohm\bolt\cast_strip_stun_{top,tilt70}_32.png` (keep the old strips; they are the
Call's evidence). If `ghost_review` only offers the take as it is, use `project/dev/ghost-powers/ohm_beat.gd` (ours) to
stage three fresh guards inside 11 m / 60 deg, the second and third within 3 m of the first. Say which ticks.

## Part B: re-film after brief 05
With flight's tool, `--look=spectral` explicitly: `ohm_move_32`, `ohm_attack_32`, `ohm_close_64` (+ jpg posters)
into `C:\Users\kazda\kiro\gtai-masters\n20\ohm\` (overwrite; the previous versions are not referenced elsewhere).
Quote ffprobe (duration, size, codec) and the SCRIPT ERROR count of every Godot log.

## Part C: mutation score
`node tools/mutate/mutate.mjs --file=features/souls/ohm_spirit.gd --max=12` and `--file=features/souls/ohm_drift.gd
--max=12`; quote killed/(killed+survived). If a surviving mutant shows a real test gap in `test_ohm_drift.gd`
(e.g. the clamp or the settle), add the assertion (one commit).

Hard stop at 06:10 wall clock (the director runs the final gate at 06:15 and it needs the only Godot slot), order A, B, C. Last commit by 06:00.

## Report
Strip paths and ticks, film ffprobe lines, mutate scores, commit shas.
