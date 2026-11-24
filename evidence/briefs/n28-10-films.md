# Brief n28-10-films: Gloria in game (n27 | n28 | pistol), the plasma sword tile, evidence only

You are the builder of lane `keys` (run n28). Worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls`, branch `n28-keys`:
`cd` there in every shell command. Read `AGENTS.md`. **The code freeze has passed (no product file changes at all)**:
you only render, compose and write `evidence/n28-keys/gloria.md`. Check `date +%H:%M` first and often.

**HARD STOPS: report and END by {END}. Commit `evidence/n28-keys/gloria.md` (inert path: the hook skips lint, it takes
seconds) by {COMMIT}.** No images (the image tool is not used in this call).

## Machine law
- Godot: never before `build/gate_n28.exit` exists (the lane's reels gate). One Godot at a time in this lane. Before every
  Godot run `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/keys` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; `--rendering-driver
  d3d12`, `--position 0,1440`; only through `tools/lib/godot.mjs` (`runGodot`; 8 GB cap: `mem-budget: waiting` is the
  machine being full, not a hang). Free your own processes by PID, never by name.
- No subagents. Never amend, rebase, `git stash`, `git add -A/./-u`, `reset --hard`. Commit with a pathspec. Never edit
  JOURNAL.md, REPORT.md or anything under `project/`, `tools/`, `docs/`. Never touch other lanes' worktrees.
- A temp worktree you create goes under `%LOCALAPPDATA%\Temp\gtai-keys-film-<sha8>` and you remove it (`git worktree
  remove --force`) before you END; never delete anything in Temp you did not create.

## The capture you already have
`C:/Users/kazda/kiro/gtai-art/rivet-n28/homing_shard/scripts/capture28.py <weapon> <mode>` (run from the worktree root)
copies the archived dev scene `grid_arena_film` from `gtai-masters/n24/motion/grid_gloria_arena/capture-source/` into
`project/dev/motion/` for the run and moves it out afterwards, then renders tilt 70 at 32 and 64 px/m, 1080p, `--fixed-fps 60`,
King's Boulevard, `--loadout=<weapon>`: frames `frame_%04d.jpg` (991 frames, walk then sprint in 8 directions) to
`gtai-masters/n28/keys/grid_<weapon>_arena/<mode>_<ppm>/`. The stop-gap "before" columns of `grid_ray_gun_*.png` were made
the same way from a temp worktree at the base commit: do the same here. Before you run it, check `git status --short
project/` is empty after each run (the script must leave nothing behind).

## Jobs, in this order (each finished and looked at before the next)
1. **Gloria n28** at HEAD: `capture28.py gloria n28` (32 and 64). **Pistol** at HEAD: `capture28.py pistol n28`.
2. **Gloria n27**: temp worktree at `d0ab9d03a` (main before this run: compact gun, n27 colours), with the same files the
   gate's snapshot copies (`project/native/bin`, `project/data/generated/city`, `project/.godot` from this worktree), run
   `capture28.py gloria n27` from there with the output under the same masters folder (`grid_gloria_arena/n27_<ppm>`).
3. **Compose** `C:/Users/kazda/kiro/gtai-masters/n28/keys/gloria_n27_n28_pistol_64.png` and `_32.png`: rows = 4 facings
   (right, down-right, down, left) walking and 4 sprinting, columns n27 | n28 | pistol, the SAME frame index in each column;
   crop around Rivet at 1:1 pixels (no scaling), plain ASCII labels. And a clip `gloria_n28_32.mp4`: three 640x540 tiles
   side by side (n27 | n28 | pistol, 1:1 crops of the 32 px/m frames centred on the screen centre, ffmpeg hstack, 1920x540
   padded to 1920x1080 with the 64 px/m n28 tile below if you can, else black), 991 frames, 60/1, libx264 crf 16, yuv420p.
   `ffprobe` it (size, rate, frames, duration) and quote the line.
4. **Left strip edge**: from the n28 64 px/m frames, a 4x crop of the left-facing cells (walk and sprint) to
   `gloria_left_edge_64.png`; state whether the muzzle is cut flat in game (the p70 left strip's cells 2, 3 touch the
   cell edge: 15 opaque px at x=0).
5. **Plasma sword** at HEAD: `capture28.py plasma_sword n28` at 32 only if time remains (stop-gap; used to replace the
   text tile of `weapons_grids_32.mp4`; do not rebuild that clip, just report the frame dir).
6. `evidence/n28-keys/gloria.md`: the concept numbers (length 1.20x centre / 1.33x right against the pistol, bar 1.3;
   median gun hue 38.5 deg vs pistol 27.5; concept `gtai-masters/n28/keys/gloria_concept_n28.png`), the shipped commit
   `e0a82abf0` (p70 held strips main/diag/left + noflash, held/held_small/icon/pickup, showcase icon/p70,
   `rivet_muzzle.json` p70 gloria), what the in-game stills show (one claw on the grip, other claw free, brass vs the
   pistol's colour at 32 px/m: measure the median hue of the gun pixels in both columns), the left edge verdict, every
   still/clip path and the ffprobe line. Commit it alone: "evidence: Gloria brass in game, n27 | n28 | pistol".

Then add entries to `C:/Users/kazda/kiro/gtai-masters/n28/keys/frames.json` for each new still/clip (keys `file`, `title`,
`ppm`, `before`, `note`); insert the Gloria pair right after `weapons_grids_32.mp4`; keep 8 to 15 entries total.
Delete only the scratch you made that frames.json does not reference, and keep the `*_arena` frame dirs.

## Report (short)
Each job: done or not, paths, the ffprobe line, the hue numbers, the left edge verdict, the commit sha, the temp worktree
removed (yes/no), STATE "Next".
