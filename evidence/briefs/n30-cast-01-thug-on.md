# n30-cast-01: robot thug A on, re-filmed live (tag `c01`, model sonnet)

Read `evidence/briefs/_common.md` first: it binds. Launched ~11:20. Hard stop 12:20 (report and END). First commit by 11:45.

## Goal (owner's pick)
Robot thug A ships: `project/data/tables/cast_cards.json` row `robot_thug` `"enabled": true` (now false). Then show him in
the live game path (no forced preview, no in-memory enable): Rivet against three thugs at 32 px/m, and one 64 px/m still
of the thug beside the patrol cop and Rivet.

## Steps
1. Flip `robot_thug.enabled` to true. Run the tests that name robot_thug / CastCards / FoeThugCardView
   (`node tools/tests/run_unit.mjs --changed`); fix only tests that pinned `enabled: false` for this row.
   Commit: "cast: robot thug A on (owner n29 pick)".
2. Determinism: `node tools/gate/quick.mjs`, and the scenario suite through runGodot (find the runner in AGENTS.md /
   `tools/README.md` that goes through `tools/lib/godot.mjs`, e.g. `tools/tests/run_scenarios.mjs`). Every replay, tape,
   pilot and scenario digest must stay identical. IF ANY DIGEST MOVES: revert the flip with a new commit, STOP, and report
   exactly which digest and its old/new value.
3. Spawn mix: list where `robot_thug` spawns in the game (`enemy_waves.json`, `gauntlet.json`, `arena.json`,
   `arena_stations/enemy-ai.json`): table, wave, count, the other archetypes in the same wave. Read only; report it.
4. Film: `tools/film/cast_thug_films.mjs` drives `res://dev/cast/cast_thug_fight.tscn` with the card forced on. Remove the
   forcing (any preview enable / preview env / in-memory enable) from `project/dev/cast/cast_thug_fight.gd` so the card
   comes from the shipped table; keep spawns through the game's `ArenaSquad.spawn_member`; log per thug
   "full rig / far card / card on". Film to `C:\Users\kazda\kiro\gtai-masters\n30\cast\thug_live_32.mp4` (1920x1080,
   32 px/m, tilt 70, 15-40 s: check with ffprobe). Extract 6 frames (ffmpeg) and LOOK at them: three thugs drawn as cards
   (not rigs), Rivet fighting them, hits, at least one fall. Report what you see per frame.
5. Still 64 px/m: the thug beside the patrol cop and Rivet, one ground row, tilt 70, facing (1,1). Reuse
   `project/dev/cast/cast_size_beside.gd` (spawns cop + each enabled row + Rivet; add an id filter flag if needed, declared
   in its own KNOWN_FLAGS) or a small sibling `cast_thug_beside.gd`. Save `...\n30\cast\thug_beside_64.png`. Measure
   heights in that PNG (`tools/art/cast_size_measure.py` if it fits, else silhouette top/bottom rows); divide the cop by its
   logged jitter `StreetCrowdCards.body_scale(actor_id)`. Report thug px, cop px (and unjittered), Rivet px, ratios.
6. Commit the dev scene / tool edits. Write `C:\Users\kazda\kiro\gtai-masters\n30\cast\frames.json` (create if missing:
   a JSON array of `{ "file", "title", "ppm", "before", "note" }`; add your two entries; `before` = the n29 thug film
   path under `C:\Users\kazda\kiro\gtai-masters\n29\cast\` if one exists, else "").

## Allowlist
`project/data/tables/cast_cards.json` (robot_thug.enabled only), `project/dev/cast/**`, `tools/film/cast_thug_films.mjs`,
tests under `project/tests/unit/` that pin the thug row's enabled state, `C:\Users\kazda\kiro\gtai-masters\n30\cast\**`,
`build/look/n30-c01/**`. Anything else: NEED in the report. Another builder (c02) works on the pile-driver
(`foe_war_card_view.gd`, `cast_war_*`): do not touch those; share the lane Godot lock with it.

## Report
Commits, digest result line (quote), spawn mix table, ffprobe duration, per-frame observations, the height numbers.
