# Builder n31-melee-01c-pixels (opus): the drawn blade volume from pixels, validated

Read `evidence/briefs/n31-common.md` first: it is binding. Tag: `01c`.
HARD STOP: commit each finished part by 25 min into the call; report and END 55 min after launch.
Your files: `project/dev/melee_n31/blade_*` and `tools/melee/blade_volume*` (01a's, committed in 18c2c7393 and
7bd951964), their tests, `evidence/n31-melee/01-volumes/**`. Another builder (`02`) changes
`features/player/player_melee.gd`, `melee_combo.gd`, `melee_swing.gd`, `rivet_swipe_view.gd` and melee tables: do
not touch those.

## Why
01a measured the hit side well (one hit-test tick per swing; the cut stays drawn 2-6 ticks after it), but its
DRAWN side is wrong: `evidence/n31-melee/01-volumes/overlay_check_electro_baton.png` shows the measured line from
Rivet's chest pointing down-right while the baton lies across his front; `overlay_check_hands.png` shows the
crescent as a small arc at his feet. Katana, plasma sword and chainsaw are drawn only as pixels in Rivet's strip
cell, so 01a read nothing for them. Without a trustworthy drawn volume the "drawn-but-no-hit" bar cannot be judged.

## Build: measure what is drawn from the rendered frames
1. Rendered, not modelled: for each weapon and each tick of one swing (Rivet facing 0 deg, then also 90 and 315
   deg), render the real frame at 64 px/m, tilt 70 (d3d12, windowed at `--position 0,1440`, or the film tools'
   capture), twice: (a) Rivet swinging, (b) the same tick with Rivet idle in the same pose start (or the same
   frame with the swing's weapon/smear layers hidden - pick what isolates the blade + swipe + smear best and
   say which). The drawn swing mask = pixels that differ beyond a threshold (exclude Rivet's body/shadow
   that also differ: use a mask of the idle body dilated a little, or hide the body layer). Keep the dummies
   out of these renders (an empty arena) so they do not mix in.
2. Screen to ground: map each mask pixel to ground metres with the camera's real transform (read the print
   stage / camera code for the tilt and `ShotLift.up_m()` lift; a pixel at drawn height h maps to ground by the
   tilt's y-scale - the blade is drawn at gun height, so project it as the game projects Rivet's gun height,
   and document the assumption). VALIDATE: overlay the projected mask outline back onto the frame for the baton,
   the katana and the claw and LOOK: it must sit on the drawn blade/swipe. Save
   `evidence/n31-melee/01-volumes/overlay_pixels_<weapon>.png`.
3. Drawn-overlapped cell = the mask (union over the swing's frames, and per tick) intersects the dummy's body
   circle (radius 0.45 m) at that ring cell. Reuse 01a's hit side (it is sound) and recompute per weapon:
   drawn-but-no-hit, hit-but-not-drawn (of 60), the per-tick drawn cutting window, the mover. Update
   `tools/melee/blade_volume.mjs` so `--label=<x>` produces this pixel version (keep `--model` for 01a's old
   path only if cheap) and re-run `--label=before` ON THE BASE COMMIT: make a temp worktree at `ba8e470b0`
   plus your probe files copied in (`git worktree add` under `%TEMP%\gtai-melee-01c-base`, remove it after),
   so the before is main even if builder 02's sweep has landed. Replace `evidence/n31-melee/01-volumes/before*`
   (old model version moves to `before-model/`).
4. Polar plots (drawn = cream outline, hit = filled translucent, drawn-no-hit vermilion, hit-not-drawn ice blue)
   per weapon + one combined sheet. Tests for the projection and mask->cell logic.

## Acceptance
- Overlay frames for baton, katana, claw where the outline sits on the drawn blade (you looked; say what you saw).
- before.md table for all 5 weapons from pixels; commits per part; the re-run command for an after on HEAD.

## Session 2 additions (22:20 launch; HARD STOP: commit each part by 22:50, report and END by 23:15 sharp)
- Batch: render all weapons/facings/ticks in as FEW Godot processes as the tool allows (one per weapon at most);
  each Godot run holds the lane lock only while it runs. Builder `02p2` shares the lock: it runs unit tests,
  scenarios and the gauntlet baseline. If the lock is busy, do Godot-free work (projection code, tests, plots).
- Also write `evidence/n31-melee/01-volumes/<label>/drawn_ticks.json`: per weapon, per tick k of one swing
  (facing 0, 90, 315): the drawn blade/swipe mask's angle range about Rivet (deg, signed off the aim) and its
  max ground reach from Rivet's centre (m). Item 02's next call sets the sweep's arc and reach from this file.
- Before killing ANY PID: print its CommandLine (`Get-CimInstance Win32_Process -Filter "ProcessId=<pid>"`) and
  kill only if it names this worktree (`n23-street`) or your own tool. Another lane's Godot was killed by a builder
  in session 1. Never kill by name.
- The tree is shared with builder 02p2 (it edits player_melee.gd/melee_sweep.gd/melee tables, flag-gated): your
  before comes from the temp worktree at ba8e470b0; do not film or measure HEAD as "after" in this call.
