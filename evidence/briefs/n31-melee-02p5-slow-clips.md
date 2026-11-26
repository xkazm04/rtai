# Builder n31-melee-02p5 (sonnet, 30 min): the slow hit-volume clips the owner can read

Read `evidence/briefs/n31-common.md` (binding). Tag `02p5`. Launched ~02:55; commit by 03:15; report and END by
03:22 whatever state (a session stop at 03:32 kills you). Commit with `git commit -- <paths>`.

Director looked at `gtai-masters/n31/melee/slow_katana.mp4` (02p4, from `tools/melee/sweep_clip.mjs` +
`project/dev/melee_n31/sweep_clip.gd`) at 3 s and 9 s: the picture fills only the top ~62 % of the frame (black
below), a wall and roof take the top third, Rivet stands at the bottom edge of the street, 16 cops packed round him
in pools of blood, and the cream hit sector is NOT visible on either still. The owner cannot read the volume.

Fix, in this order (find the cause of each first, 1 line each in your report):
1. Frame: the Movie Maker frame is 1280x800 while `_ready` sets the window to 1920x1080 (sweep_clip.gd:31-32);
   suspect the movie size is fixed at startup so the viewport no longer matches. Make the rendered frame a clean
   1920x1080 (or 1280x720 that scales) with the arena filling it: check `--resolution` / `display/window/size/*`
   overrides at launch (as the other film tools in `tools/film/` do - copy their working arguments) instead of
   resizing in `_ready`. Bar: ffprobe of the raw avi = 16:9, no black band on a still.
2. Spot: `FROM` (5,-38) sits against the wall/map edge. Pick an open floor spot (check the plan: no wall, no prop
   within 4 m, no zebra), camera centred on Rivet (`--cam-lock` = that spot).
3. Readability: ONE ring of 8 dummies at 1.8 m plus 4 at 2.8 m on the aim side only (+-60 deg), so the blade has
   room; sector outline 4 px at 64 px/m with the dark under-stroke, plus a translucent cream fill (alpha ~0.25)
   while it is live, kept 10 ticks fading; struck dummies flash. Blood: pass `--gore=reduced` if this scene reads
   it (check LaunchArgs), else leave it.
4. Re-render the five weapons (`node tools/melee/sweep_clip.mjs --tag=02p5`), katana first; LOOK at a still from
   the middle of each clip (ffmpeg -ss, Read the png): the sector must be visible crossing at least one dummy in
   the n31 half. If a weapon is not done by 03:12, commit what you have and list it.
5. Update the 5 `slow_*` entries' `note` in `C:/Users/kazda/kiro/gtai-masters/n31/melee/frames.json` (read it
   first; keep the order) with the new spot, rings and frame size.
Owned: `project/dev/melee_n31/sweep_clip.gd`, `sweep_clip_lines.gd`, `sweep_clip.tscn`, `tools/melee/sweep_clip.mjs`,
the masters slow_* files and their frames.json entries. Nothing else. Run `node tools/godot/check.mjs` on the
changed .gd files and `node tools/lint/lint.mjs` (fix your own findings) before the commit.
