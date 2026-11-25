# Builder n31-melee-02p4 (opus): item 2's evidence tail - play takes, slow clips with the hit volume, labelled plots

Read `evidence/briefs/n31-common.md` (binding). Tag `02p4`. HARD STOP: commit each part by 25 min into the call;
report and END 55 min after launch. Commit with `git commit -- <paths>`. Precondition: `--melee-sweep` is ON by
default on HEAD (02p3 flipped it; `--melee-sweep=off` = the before). If it is not flipped, STOP and report.

## Part 1: real-play takes main | HEAD (the owner judges these first)
`tools/melee/play_take.mjs` runs `res://dev/melee_n31/play_baseline_take.tscn` (gauntlet, wheel controls, the
average bot holding one melee weapon, seed 7, 32 px/m, tilt 70, 1080p60). Add `--game-flags=<a,b>` passed to the
scene (before or after `--`, whichever the flag reader uses: check `LaunchArgs` vs `ArenaArgs` for
`--melee-sweep` and `--kill-feed`) and a `--before-flags` default `--melee-sweep=off`. The existing befores
(`gtai-masters/n31/melee/before_play_{katana,plasma_sword,claw}.mp4`, 35 s, seed 7) were rendered from the tree
with the flag off = main. Render `after_play_<w>.mp4` for katana, plasma_sword, claw with `--frames=<same as the
befores: ffprobe them>` and `--kill-feed` OFF (item 3 is filmed separately). Then a beside film per weapon
`beside_play_<w>.mp4` (ffmpeg: each side scaled to 960x540, hstack, padded to 1920x1080, drawtext "main" /
"n31 sweep" top-left of each half, 15-40 s: ffprobe). LOOK at frames from each (extract 3 stills with ffmpeg and
Read them): Rivet visible, swings visible, enemies present. Write one honest sentence per weapon: what a player
feels differently (from the counted swings: `play_baseline` kills/swing + the blade-overlap-no-hit count in the
take if the probe reports it).

## Part 2: one 64 px/m slow clip per weapon with the hit volume drawn
A dev scene `project/dev/melee_n31/sweep_clip.tscn/.gd` (own `KNOWN_FLAGS`): Rivet with one weapon, a ring of
dummy humans (reuse blade_volume's ring setup), one swing repeated, and an overlay drawing the hit volume LIVE per
tick: the sector `MeleeSweep` tests on that tick (thin outline, ink colour - not red, not teal, not vermilion; use
cream or ice-free grey), each struck dummy flashes its outline once. Render at 64 px/m, tilt 70, 1080p60, then
slow 4x with ffmpeg (`setpts=4*PTS`), 10-25 s per weapon, both with the flag off and on side by side
(`slow_<w>.mp4`). Five weapons. Look at 2 stills per clip before committing.

## Part 3: labelled before|after polar sheet + frames.json
Re-plot `evidence/n31-melee/02-sweep/volumes/before_after.png` with weapon names per row, "before (main)" /
"after (sweep)" column titles and a legend (drawn-no-hit, hit-not-drawn, hit sector, drawn outline) -> also copy
to the masters folder as `volumes_before_after.png`. Write/extend `C:/Users/kazda/kiro/gtai-masters/n31/melee/
frames.json` (best first: `file`, `title`, `ppm`, `before`, `note`): the three beside films first, then the slow
clips, then the sheet. Masters hold films and stills only (no scripts). Delete scratch renders not referenced.

## Director addendum (session 4, 00:50) - supersedes the precondition above
Builder 02p3b runs IN PARALLEL and flips the default (tests, digests, decisions.md). Do NOT wait for it and do NOT
touch its files (any test under `project/tests/**`, `docs/decisions.md`, `player_melee*.gd`, `melee_hit*.gd`,
`launch_args.gd`, `tools/melee/play_baseline.mjs` default flags). The rule with the explicit flag `--melee-sweep`
on today's HEAD is byte-for-byte the rule the flip makes default, so render every "after" WITH `--melee-sweep`
passed explicitly and every "before" with nothing (today's default = off = main) - and after 02p3b lands, with
`--melee-sweep=off`. Your `play_take.mjs --game-flags` must therefore accept both. Put the flags used into each
film's frames.json `note`.
Order: Part 1 (takes, owner sees them first) -> Part 3 (Godot-free, do it while the lane lock is held by 02p3b) ->
Part 2. The lane lock `build/n31/godot.lock` will often be held by 02p3b (full unit + scenarios ~25 min): wait
for it, do Godot-free work meanwhile; remove only a lock whose first word is `02p4`
(`grep -q "^02p4 " build/n31/godot.lock && rm build/n31/godot.lock`).
Windows: commit Part 1 by 01:25, Part 3 by 01:35, Part 2 by 01:55; report and END by 02:05 whatever state
(uncommitted part: write `build/n31/02p4/state.md` with what remains). Before killing any PID print its CommandLine
and kill only if it names `build/n31/02p4` or a process you started.
