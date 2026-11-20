# Brief 05 (lane tonnage): take flight's own_body and smoke tail, give him the plate's vapour and his weight

Plate: `C:\Users\kazda\kiro\gtai-masters\n20\concepts\tonnage_b.png`. Look at it first. Its vapour is two things:
(a) a THICK teal smoke column that leaves the back of the torso at the waist, about as wide as the waist at the root,
drags LOW behind him and curls up and back at the end, fading; (b) thinner wisps hanging DOWN from under the chest
between the two arms, toward the road, never touching it. Today in game (`C:\Users\kazda\kiro\gtai-masters\n20\tonnage\tonnage_plate_game_64.png`)
the tail is a flat teal wedge with straight edges: it reads as a ribbon or a blanket, not smoke.

The rules of `evidence/briefs/03-films.md` and `04-glow-arm.md` all still bind (git: no amend/rebase/squash, a fix is
a new commit, stage per path, no stash/add -A/reset --hard, never push; APPDATA + GODOT_BIN + d3d12 + `--position 0,1440`;
one Godot at a time; PID-only kills; visual only, no sim/replay/parity/bake digest moves; your file list; the
`tools/godot/check.mjs` false failure). Read the end of 04's report in `evidence/briefs/04-glow-arm.out.txt` if present.

## 0. Merge flight
`git merge n20-flight` (brings `12ec7bffa` GhostDrawn.own_body, `7948f3382` weight-in-flight + ground light row fields,
`f183e88a1` tick-driven ribbon tail + shedding wisps: `GhostTail`, `ghost_tail_wisps.gd`, `ghost_vapour.gd`, new tail fields
`strands`, `spread_m`, `rise_m`, `wisps`, `flow_ticks`, `curl_m` in `ghost_hover.schema.json`). On a conflict in `ghost_hover.json` keep
flight's schema and other rows, and our `tonnage` values plus flight's new fields. Read `project/features/souls/README.md`
(section "Spectral look") and the headers of `ghost_tail.gd`, `ghost_tail_wisps.gd`, `ghost_vapour.gd`, `ghost_hover.gd` before tuning.
Run `node tools/tests/run_unit.mjs --changed` after the merge.

## 1. own_body
Under `GhostLook.spectral(&"tonnage")` set `drawn.own_body = true` in `tonnage_rig.gd`, and remove our own manual hiding
of the GhostDrawn sprite only if own_body makes it redundant (the legacy look must stay exactly as it was). Keep or adapt
the single-body regression test. Render the p70 and p55 rest frame (tick 72, 64 px/m, spectral): exactly one body.

## 2. The smoke column (our `tonnage` row of `ghost_hover.json` only)
Tune with the new fields until (a) above reads in game: root at the waist under the back plates (`anchor_m`), `width_m`
about the waist, `strands` 2-3 with `spread_m` so the edges are tongues not a straight line, `rise_m` at or below 0 so it
drags LOW and only the end lifts, `wisps` for shedding puffs, `flow_ticks` slow (he is heavy), `curl_m` for the up-and-back curl at the end, `swing_k` so it drags behind on
turns. Flight's package 3 (may land during your session; merge it if so) makes the ribbon a dense bright vapour with an ink edge and makes 0/negative `rise_m` drag low. If, after that, 0/negative `rise_m` cannot make it drag low, write `NEED flight: <exactly what>` in the report and keep the best
you can get.

## 3. The hanging wisps (inside `tonnage_spectral.gd`, or a new `tonnage_vapour.gd` if it would pass 200 lines)
A second `GhostTail` (a Node2D: `GhostTail.new(row)` with a tail row built in code from consts, not a new table row)
anchored under the chest between the fists, short (about 0.9-1.2 m), thin, hanging down and trailing slightly, drawn
behind the fists and in front of the main column. It must not read as a leg: thin, frayed, fading to nothing well above
the road, and swaying (not still). Only under spectral. Test: it exists under spectral and not under legacy.

## 4. His weight in flight (our `tonnage` row)
Use flight's new fields (`cruise_bob_k`, `start_lift_m`, `sway_m`, `lag_ticks`, `shadow.pool_m`, `shadow.pool_alpha`) so he
is slow to start and slow to stop, with a deep slow bob that flattens a little at cruise, the torso leading and the fists
arriving late (TonnagePose already lags the fists: check it still shows with the new lag). The teal ground pool should sit
under him, about as wide as the fist spread, not past the 4 m slam ring.

## 5. Evidence and films
- Before/after at the same tick and zoom (p70 64 px/m rest; top view 32 px/m cruising; p70 64 px/m hard turn), named
  `tonnage_smoke_<what>.png` / `..._before.png`, in `C:\Users\kazda\kiro\gtai-masters\n20\tonnage\`. Look at each one next to
  the plate. Re-roll the tuning at most twice if it reads as a blanket, a ribbon, or a third leg.
- Film with flight's tool (merged in item 0): `node tools/film/ghost_films.mjs --ghost=tonnage --look=spectral --out=C:/Users/kazda/kiro/gtai-masters/n20/tonnage --takes=move,attack,close --stills=163` (read its header first; it names files per the night convention). Fall back to your 04 method only if it fails, and say why.
- Re-render `tonnage_move_32`, `tonnage_attack_32`, `tonnage_close_64` (+ posters, real speed: no slow motion) under
  `--ghost-look=spectral` and update `frames.json` (best first; keep 8 to 15 entries; delete scratch it does not reference).
- `node tools/tests/run_unit.mjs --changed` and `node tools/lint/lint.mjs` green before each commit. Then
  `node tools/mutate/mutate.mjs --file=features/souls/tonnage_spectral.gd --max=40` and the same for `features/souls/tonnage_pose.gd --max=40` (NEVER without `--max`: 158 serial mutants took 41 min and were killed); add the tests 04 drafted for the survivors it found (torso ten-tick follow, both landing positions); report killed/(killed+survived).

Report: commits (sha + line), the final `tonnage` row, one-body check result, stills/film paths, the mutate score,
any NEED flight line, anything not done.
