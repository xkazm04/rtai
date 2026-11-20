# Brief a2-wiring (lane dent, n20): Ejected flies in game under `--ghost-look=spectral`

Context: RTAI (`gtai`), ghost form **Dent**. Tonight Dent becomes "Ejected": a legless crash-test
dummy from the belt up, riding a comet tail of teal light and glass (plate:
`C:\Users\kazda\kiro\gtai-masters\n20\concepts\dent_a.png`: **look at it first**, hero view = the
tilted look, top-right inset = the top view). The art is already committed on this branch by the
previous package (a1): `project/features/souls/art/view/p70|p55/dent_sp_fly.png` and
`dent_sp_act.png` (rows = 5 facings in GhostSheet order, cols = poses; fly: 1 HOVER, 2 DIVE,
3 SWING, 4 HIT; act: 1 COCK, 2 JAB, 3 STEER ONE HAND, 4 STEER TWO HANDS) and the top-view parts in
`project/features/characters/art/dent/spectral/` (`head`, `torso`, `upperarm`, `forearm_fist`,
`forearm_open`, `tail_root` + `parts.json`). Read `docs/art/prompts/n20/dent/README.md` and
`git log --oneline -10` for what shipped (some p55 sheets may be missing: then p55 falls back to p70
art scaled, and you say so).

This is a VISUAL night: abilities, numbers, timing, hit boxes, footprints and every
sim/replay/parity digest stay exactly as they are. Render-only code.

## Step 0: take flight's shared interface
`git merge n20-flight` (allowed tonight, only that branch; a merge commit is fine). Then read
`project/features/souls/README.md` section **"Spectral look"**: `GhostLook.spectral(&"dent")`, the
`--ghost-look=legacy|spectral` flag, `GhostFlight` (hover, tail, shadow; `body_offset()`,
`body_scale()`, `body_rotation()`, `hover.bank/lean/speed_mps`), `ghost_hover.json`. `GhostFormView`
already places Dent's body through `GhostFlight` under spectral and sets `drawn.hover`; you build what
Dent draws **inside** that. Concretely (flight commit 0e7d91e46): `GhostFormBodies._attach_body` sets
`DentBody.drawn.flight = GhostFlight.make(&"dent")` and `flight.mount(body)` when spectral, and
`step_dent` passes `DentBody.step(...)` a spot already moved by the flight (`_spot`). So inside
DentBody read `drawn.flight.hover` (`bank`, `lean`, `speed_mps`, `yaw_rate_dps`, `lift_m`) and
`drawn.flight` for the tail; do not offset the spot again, and check whether `mount` already applies
`body_scale()/body_rotation()` before applying them yourself. `GhostApparition` (the story whisper)
also builds a DentBody without a flight: it must not crash there (`drawn.flight == null` -> the
spectral body at rest, or the legacy path; say which). If flight has committed more since
(`git log n20-flight`), merge again and read the README's newer notes (tail `points()`).

## Machine rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/dent` before any Godot or gate run;
  `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`;
  `--rendering-driver d3d12` for anything that renders; windowed runs `--position 0,1440`; one Godot
  process at a time; free your processes by PID, never by name.
- Repo law: AGENTS.md (typed GDScript, files about 200 lines / hard 300, functions <= 40 lines,
  <= 5 params, `Log` not print, `.uid` committed). Stage per path, one commit per change, no
  `git add -A/./-u`, no stash, no `reset --hard`, never push.
- You may edit: `project/features/souls/dent_*.gd`, new `dent_*` files (code, tests `test_dent_*`),
  Dent's own row in `project/data/tables/ghost_hover.json` (only the `dent` row's values),
  `project/dev/ghost-powers/dent_beat.gd`. NOT `ghost_*.gd`, `ghost_drawn.gd`, `ghost_sheet.gd`,
  `ghost_form_view.gd`, the schemas, other ghosts' files or rows. If a hook in a flight file is
  missing, work around it in Dent's files and write the exact missing hook in your report.
- The legacy look stays byte-identical: every legacy path (no flag, or `--ghost-look=legacy`) draws
  exactly as before. Old art and code stay in the tree.

## 1. Tilt views (p70, p55): `DentSpectralDrawn` (new `dent_spectral_drawn.gd`)
In `DentBody`, when `GhostLook.spectral(&"dent")`, draw from the new sheets instead of `GhostDrawn`'s
walk/run (use `GhostSheet.of(path, 4)` / `show(spr, oct, col)`; left facings mirror, no left sheet):
- pose from flight's hover state, on sim ticks: HOVER below about 2.5 m/s; DIVE above it; SWING while
  `abs(yaw rate)` is high (a hard turn: pick a threshold that fires on the review film's turns but not
  on a straight run; state it); HIT for the hit window GhostDrawn already uses for the hit column
  (look at how it detects the hurt: `blow`, `HIT_TICKS`). Mirror SWING to the side of the turn.
- act cells: jab wind-up (`DentJab.due_tick` pending) -> COCK; jab strike frames (`swung_step`, the
  span GhostDrawn uses for the jab cells) -> JAB; a car seized (`DentStage.car != null`) -> STEER ONE
  HAND (STEER TWO HANDS when `DentLook`/`--dent-tether=strings` exists and says strings; if that class
  does not exist yet, one hand).
- the body leans with flight: apply `hover.lean` as a forward tip of the sprite along the facing's
  screen direction (small rotation + squash, so DIVE cells tip further at top speed), and
  `hover.bank` as roll (flight's `body_scale()` may already squash; do not apply it twice).
- Scale: the figure (head to plume end) about 1.45 m tall at PlayerScale (Dent's old drawn figure was
  1.8 m with legs; the body from the belt up should keep the old head and shoulder size: measure the
  old dent_walk8 head width vs the new sheet's and match those, then state both numbers).
- Spectral finish: the body must read as soul light, not jade metal: reuse the existing ghost rim /
  apparition tools (`GhostRim`, `ghost_apparition.gdshader` / `ghost_keyline.gdshader`, `GhostAura`)
  on the sprite (a teal rim glow and a slight translucency, about 0.85 alpha, the black ink and the
  yellow discs staying solid). Pick the cheapest that reads at 32 px/m; show it.

## 2. Top view: `DentSpectralTop` (new `dent_spectral_top.gd`)
Under spectral the top view draws a small sprite rig instead of the legged CutRig: torso, head
roundel ahead of the shoulders, two arms (upper + forearm), the tail root behind the belt; no legs.
- At rest the arms hang slightly forward and out; at speed (DIVE) both arms sweep back along the sides
  and the head pushes further forward (lean); on a hard turn the arms swing out to the outside of the
  turn (rag doll), lagging by a few ticks; on the jab the right forearm (fist) shoots forward to 1.4 m
  from the body centre on the strike frames and recoils; while steering a car the right arm points
  at the car (open->fist).
- The top silhouette must give a DIRECTION, not a symbol: head forward, shoulders wide, tail behind.
  Check it at 32 px/m against a guard (a still beside a guard in the review film).

## 3. Glass in the tail
Dent's tail (flight's `GhostTail`, configured by his `ghost_hover.json` row) carries his glass:
add `dent_glass.gd`: 6 to 10 small pale glass shards (thin ink-edged slivers, white-aqua fill)
riding along the tail's points, drifting back and glinting (a 2-tick white flash, every shard on its
own period, deterministic from the tick, no RNG), more and longer at speed. If `GhostTail` exposes its
points, ride them; otherwise follow the body's trail yourself and say which.
Tune Dent's row in `ghost_hover.json` for his character: **fast and twitchy, thrown rather than
flown**: low lag (snaps), high bank (swings out like a rag doll), quick small bob, a long thin comet
tail that stretches a lot with speed (`stretch_k` high), plenty of `swing_k`. State the values.

## Checks and evidence
- Unit tests `test_dent_spectral_drawn.gd` (pose choice: still -> HOVER, 7 m/s straight -> DIVE,
  hard turn -> SWING mirrored to the turn side, jab -> COCK then JAB, seized -> STEER) and
  `test_dent_spectral_top.gd` (no leg parts exist under spectral; arms behind at speed; jab fist
  reach ~1.4 m on the strike tick). Legacy: an existing Dent test still passes untouched.
- `node tools/godot/check.mjs` on changed files; `node tools/lint/lint.mjs`;
  `node tools/tests/run_unit.mjs --changed`; replay/scenarios unmoved
  (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`, or `--only=` the replay and
  Dent scenarios; name them); `node tools/gate/quick.mjs` before each commit.
- Film with the review driver: `node tools/dev/run.mjs ghost_review.tscn --ghost=dent --take=move
  --ghost-look=spectral ...` (see `ghost_review.gd` and flight's README / `tools/film/` for the film
  helper flight adds) at 32 px/m and 64 px/m, tilt (70) and top. Save to
  `C:\Users\kazda\kiro\gtai-masters\n20\dent\scratch\a2\`: stills of HOVER, DIVE, SWING, the jab, and a
  steer in both views at 64 px/m, plus one 32 px/m still beside a guard; and the move clip if the
  film helper exists. Name each still's tick. Look at every still; do not claim a frame you did not
  look at. Same tick with `--ghost-look=legacy` for the before.
- After the main commit: `node tools/mutate/mutate.mjs --file=features/souls/dent_spectral_drawn.gd
  --max=20` and quote killed/(killed+survived).

## Order and time
0 -> 1 (commit) -> 2 (commit) -> 3 (commit). At 65 minutes commit what is finished and stop with a
report: files, commands and results, still paths with ticks, numbers you chose, and what is not done.
