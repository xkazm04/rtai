# Builder n31-melee-01b-foes-baseline (sonnet): enemy melee reach on Rivet + the gauntlet melee baseline

Read `evidence/briefs/n31-common.md` first: it is binding. Tag: `01b`. Launched ~21:05.
HARD STOP: commit each finished part by 25 min into the call; report and END by 22:05 at the latest.
This item MEASURES only. Do not change any game rule, table or view (current tree = main = the "before").
Another builder (`01a`) works in `project/dev/melee_n31/blade_*` and `tools/melee/blade_volume*`: do not touch
those. Your files: `project/dev/melee_n31/foe_reach*`, `project/dev/melee_n31/play_baseline*`,
`tools/melee/foe_reach*.mjs`, `tools/melee/play_baseline*.mjs`, their tests, `evidence/n31-melee/01-foes/**`,
`evidence/n31-melee/01-baseline/**`.

## Part A: enemy melee on Rivet (drawn reach vs hit reach)
Known (verify): `project/features/combat/squad/foe_attacks.gd:58-84` (READ ONLY, foes' file): the swing starts when
Rivet is within `weapon.reach_m + 0.6` (Rivet's hurt radius, `data/tables/combat.json` ~:64); aim locks at the tell
start; after `telegraph_ticks` it hits if he is still inside that reach and within +-60 deg of the locked aim.
Baton cop 1.6 m / 0.55 s / 2.4; thug claw 2.0 m / 0.8 s / 3.6 (`lunge_m` 3 unused on this path); shield shove: slab
1.8 m tested once at the end of a 15-tick lunge; warden shove 1.8 m / 0.55 s.
Build `project/dev/melee_n31/foe_reach.gd/.tscn` (real arena + views, fixed 60 Hz) that for each of baton cop, thug
claw, warden shove, riot shield shove: (1) measures the DRAWN reach of the tell/strike (furthest point of the drawn
weapon/arm/shield from the foe's centre over the strike frames, from the view nodes or the drawn cells' anchors -
say which), against the HIT reach; (2) runs Rivet stepping out of the swing at walk/run speed starting at several
tell ticks and records whether a hit lands after Rivet has visibly left the drawn swing (his body circle outside
the drawn weapon's extent at the hit tick).
Tool `tools/melee/foe_reach.mjs` -> `evidence/n31-melee/01-foes/before/foe_reach.json` + table `before.md`.

## Part B: the gauntlet melee baseline (guard rail for the next item)
The next item changes the player's melee hit rule; its guard rail is "kills per swing for the average bot in
gauntlet waves 1-4 within +-15 % of before". Measure the before: read `project/dev/gauntlet/gauntlet.gd`,
`project/features/gauntlet/bot/**` and `tools/gauntlet/**` (READ ONLY) to find how to run the gauntlet headless with
the bot holding one melee weapon (claw/hands, chainsaw, electro_baton, katana, plasma_sword). Build
`tools/melee/play_baseline.mjs` (+ a probe under `project/dev/melee_n31/play_baseline*` if needed) running waves
1-4 at seeds 1..5 per weapon (one Godot process per weapon if possible, to save memory), recording per weapon:
swings, hits, kills, kills/swing, Rivet damage taken / deaths, wave reached. Output
`evidence/n31-melee/01-baseline/before/baseline.json` + `before.md`. Keep the run under ~20 min total; cut to 3
seeds if needed and say so. The tool must take `--label=` so the after run writes beside it.

## Part C (only with >= 15 min left after A and B are committed): the before play take
A 32 px/m, tilt 70, 1080p60 film of the gauntlet with the default wheel controls, seed 7, katana then plasma sword
then claw through a wave, 15-40 s per weapon (check with ffprobe), to
`C:\Users\kazda\kiro\gtai-masters\n31\melee\before_play_<weapon>.mp4`. Find the take path in `tools/film/film.mjs`,
`tools/film/owner_takes.mjs`, `tools/gauntlet/pressure_films.mjs` (read only); a new wrapper lives in
`tools/melee/play_take*.mjs`. Record the exact command so the after is filmed at the same seed and ticks.

## Acceptance
- Tests for any pure logic (GUT or node --test), lint clean on your files, commits per part.
- Report: Part A table (foe, hit reach, drawn reach, hits after leaving the drawn swing / trials), Part B table,
  Part C command + film paths, NEED lines (anything in foes' files).
