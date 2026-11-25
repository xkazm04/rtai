# n29 keys films: plasma sword, Gloria beside the pistol, p55 collar row 4

Brief `evidence/briefs/n29-08-films-live.md`. No product file changed. Scripts: `evidence/n29-keys/films/capture_film.py` (the n29 `capture28.py` with ppm list and output folder arguments), `compose.py` (ffmpeg hstack/vstack with burned-in labels), `run_hands.py` (the n26 bare-hands drift harness `hands_arena`, view `tilt` = p55 cards, 64 px/m).
Stop-gap and "before" = a temp worktree at `c649a15d6` (removed at the end). Masters root `C:/Users/kazda/kiro/gtai-masters/n29/keys/`.

## Job 1: plasma sword (done)
- Captures (991 frames each, 1080p, 60 fps fixed, King's Boulevard, tilt 70, walk then sprint x8): `sword/grid_plasma_sword_arena/n29f_32` (HEAD), `n29f_64` (HEAD, 16 samples only, the script saves 64 px/m as samples), `basef_32` (c649a15d6), `sword/grid_katana_arena/n29f_32` (HEAD donor).
- Clip `sword/plasma_sword_32.mp4`: three 640x540 1:1 crops (stop-gap | n29 | katana) over the n29 64 px/m full-width 1:1 crop (1920x540); the same frame index in every top tile (frames 70-990 = 15.35 s); the 64 px/m tile holds each sample for 1 s (it has no per-frame capture).
- ffprobe: `codec_name=h264 width=1920 height=1080 pix_fmt=yuv420p r_frame_rate=60/1 duration=15.350000 nb_frames=921 `
- Looked at: frame at 3 s (walk) and at 12 s (sprint). The stop-gap sword is a thin white line on the back-swinging hand; n29 carries an amber plasma bar in the leading hand, low; the katana donor shows a curved blade. Labels and the scene line readable. Rivet size and position match across the three tiles.

## Job 1b: Gloria beside the pistol (done)
- Captures: `gloria/grid_gloria_arena/n29f_32` and `n29f_64` (HEAD, 991 frames / 16 samples), `basef_32` (c649a15d6), `gloria/grid_pistol_arena/n29f_32` (HEAD donor, 991 frames).
- Clip `gloria/gloria_vs_pistol_32.mp4`, laid out as job 1 (stop-gap | n29 | pistol over n29 at 64 px/m).
- ffprobe: `codec_name=h264 width=1920 height=1080 pix_fmt=yuv420p r_frame_rate=60/1 duration=15.350000 nb_frames=921 `
- Looked at: frames at 3 s (walk) and 12 s (sprint). The stop-gap Gloria is a long brass gun that points back past the hip; n29 Gloria is the compact gun in the leading hand, the pistol donor the same pose in dark metal. 64 px/m tile shows the compact gun forward in both walk and sprint.

## Job 2: collar p55 row 4 (done: still and drift; 32 px/m clip: see end)
Row 4 in the collar notes is the 1-based sheet row (0-based row 3 of `p55/rivet_run8.png`; the harness reports it as row 3), the back three-quarter sprint beat 15 of the hands harness (tick 1888, column 6, 9.3 m/s).
- Still `collar/collar_p55_before_after_64.png`: top, the 200x220 1:1 crop (before | after); bottom, a 3x nearest crop of the changed region (2479 px differ, all in the neck band). Before = the sheet from c649a15d6 (a pale, soft, orange band), after = HEAD (flat vermilion and black diagonal stripes). Same tick 1888 in both runs. Pitfall found: the temp worktree's copied `.godot/imported` held HEAD's texture for that path, so the first "before" run drew the new sheet (zero pixel difference at the row-0-based-4 tick); the imported `rivet_run8.png-d76...` for the temp worktree was deleted and re-imported, and the before run redone.
- Frame diff over all 16 per-beat frames: only ticks 928 (row 3 walk, 3077 px) and 1888 (row 3 sprint, 2479 px) differ, every other tick 0 px.
- Drift (planted-boot residual, `hands_slide.py`, p55 sprint profile rows right 3.09 cm, left 4.56 cm): before 3.83 cm, after 3.83 cm at 64 px/m (bar 3.83 +- 0.1): unchanged by the neck-only edit, and equal to the n27 value.
- Runs: `collar/run_before_64`, `collar/run_after_64` (take.json, measurements.json, t*.jpg).
