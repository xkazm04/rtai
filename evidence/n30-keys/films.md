# n30 keys films: molotov beside the stop-gap

Brief `evidence/briefs/n30-05-molotov-film.md`. No product file changed. Scripts: `evidence/n30-keys/films/capture_film.py` and `compose.py` (the n29 copies, masters root changed to n30, job name `n30-keys-film`). Masters root `C:/Users/kazda/kiro/gtai-masters/n30/keys/`.

## Molotov clip (done)
- Before = temp worktree `C:/Users/kazda/kiro/gtai-n30/tmp/keys-before` at `19259b098` (the commit before the molotov sheet `4513bda2a`); native DLLs, baked city and `.godot` copied, the imported `rivet_run8_eq_molotov.png-*` deleted so the new texture could not leak (n29 pitfall). Verified: the before tile shows the stop-gap's thin held sliver, not the bottle. Worktree removed at the end.
- Captures (1010 frames each, 1080p, 60 fps fixed, King's Boulevard, tilt 70): `molotov/grid_molotov_arena/basef_32` (before), `n30f_32` and `n30f_64` (HEAD), `b64_64` (before, 64 px/m samples), `molotov/grid_plasma_rifle_arena/n30f_32` (donor).
- Clip `molotov/molotov_32.mp4`: three 640x540 1:1 crops (stop-gap | n30 | plasma rifle), frames 70-990, over the n30 64 px/m full-width 1:1 tile (1 s per sample).
- ffprobe: codec_name=h264, width=1920, height=1080, pix_fmt=yuv420p, r_frame_rate=60/1, duration=15.350000, nb_frames=921.
- Looked at: 3 s (walk): the stop-gap shows a thin pale line on the hand, n30 carries the bottle with a lit rag in the leading hand, the donor holds the rifle in the same pose; the 64 px/m tile shows the bottle and flame by the right ear. 12 s (sprint): stop-gap still a sliver at the back hand, n30 bottle forward with flame, donor rifle forward; Rivet size and position match across the tiles, labels readable.

## Still `molotov/molotov_before_after_64.png`
Stop-gap (left) | n30 (right), 1:1 270x240 crops at 64 px/m, ticks 610 and 850 (two sprint facings). Seen: before a thin held sliver (and a different leg phase), after the bottle with the flame, collar and body unchanged in style.

## frames.json
`gtai-masters/n30/keys/frames.json`: 10 entries (molotov clip, molotov 64 still, grid_molotov_64, the collar stills).

## Collar rows 3, 6, 7 clip (compare)
Brief `evidence/briefs/n30-13-collar-film-compare.md`. Route 1 (n30-11, the bare-hands `run_hands.py` harness) failed: it copies `hands_arena.*` from `gtai-masters/n24` and `n26`, deleted at ~12:56. Route 2 is the shipped compare kit; no product file changed.
- Shot `arena` with `-- --bot=rivet` (ArenaGame reads the LAST `--bot`, so it overrides the shot's `--bot=reel`): the walk, strafe, sprint (left and right), roll, claw combo script. Sides `--a=5114a4441` (before the collar edits) and `--b=834607753` (HEAD at the time), tilt view (p55 art), pinned snapshots in `%TEMP%/gtai-film-<sha>`.
- Commands: `node tools/film/compare.mjs arena --a=5114a4441 --b=834607753 --view=tilt --ppm=32 --res=1920x1080 --clip=60-1260 --at=600 --out=build/n30-13/c32 -- --bot=rivet` and the same with `--ppm=64 --at=300 --out=build/n30-13/c64` (no clip). Both exit 3 UNVERIFIABLE only because the window is clamped to 1422x800 (movie 1280x800, stills 1920x1080); the pictures are real and differ (tick 300 stills differ).
- compare wrote no clip for an unverifiable side, so `collar_p55_rows367_32.mp4` was cut with ffmpeg from the two `arena.mp4` (frames 60-1260, each side scaled 1280x800 -> 960x600, hstack, padded to 1920x1080, labels "before 5114a44" / "after n30"). Rivet is small in it (about 60 px); the 64 px/m still is the readable proof.
- ffprobe clip: width 1920, height 1080, r_frame_rate 60/1, duration 20.000000, nb_frames 1200.
- Still `collar/collar_p55_64_compare.png`: tick 300, 320x320 crop at 3x nearest, before left, after right (1920x960). Seen: Rivet sprinting LEFT (row 7): before the collar is a twisted orange rope; after a flat black and orange striped ring. Head, body, legs identical.
- Frames looked at: 4 s (tick 300, the left sprint: before twisted, after striped ring, visible even at 32), 6 s (tick 420, claw combat: both collars are small orange bands, no clear difference at this size). Not shown: the bot never faces row 6 (front-left) or a right sprint through 3 clearly in the frames I viewed; rows 3 and 6 are unverified in this clip (a right sprint runs at ticks about 285+ before the left one is not confirmed). Row 7 is verified.
