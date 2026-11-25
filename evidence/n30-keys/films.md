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
