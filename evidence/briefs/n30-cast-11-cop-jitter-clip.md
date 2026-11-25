# n30-cast-11: patrol cop jitter, 32 px/m before | after clip (tag `c11`, model sonnet)

Read `evidence/briefs/_common.md` first: it binds. Hard stop: launch + 45 min (report and END). Evidence only: no product change.

## State
`c2281acbb` narrowed the patrol cop's build jitter from +-16 % to +-8 % (`StreetCrowdCards.COP_SCALE_VAR` 0.08,
`body_scale_of(rig)`), crowd keeps +-16 %. Measured at 64 px/m in `gtai-masters/n30/cast/cop_jitter_64.png`
(min 92 / unjittered 100 / max 108 px; were 84.6 / 100.6 / 116.7). Missing: the 32 px/m before | after clip in the game.
Before = `5114a4441` (main, run base). After = `HEAD` of this branch.

## Do
1. Use the shipped compare tool (it films both sides at the same ticks through runGodot; read its header):
   `node tools/film/compare.mjs city --a=5114a4441 --b=HEAD --ppm=32 --res=1920x1080 --view=combo --clip=<from>-<to> --at=<t,t> --out=build/look/n30-c11/city --label-a="cops +-16 % (before)" --label-b="cops +-8 % (after)"`.
   First run it without `--clip` (stills only, `--at` two ticks ~300,700) to find a window where several blue patrol cops are on
   screen; LOOK at the stills. Then the clip, 15-40 s (900-2400 ticks at 60). If the `city` shot shows no cops, try
   `--lock=` / `--seed=` or the `arena` shot (wave cops), say which, and keep the one where cops are on screen.
   Hold the lane lock for each tool run. If the side-by-side is 2x960 wide, that is fine; if the composite is not 1920x1080,
   scale/pad it with ffmpeg to 1920x1080 (do not stretch).
2. Copy the clip to `C:\Users\kazda\kiro\gtai-masters\n30\cast\cop_jitter_32.mp4`, `ffprobe` (size, fps, duration).
   Extract 3 frames (`build/look/n30-c11/f_*.png`), LOOK, and count cops on screen per side in one frame; say if any cop
   reads visibly different in size between sides at 32 px/m (expected: small, at most +-8 px at 64 = +-4 px at 32).
   Note any other difference between the sides (other lanes are NOT in this branch: only cast's n30 commits differ; the
   robot thug A is on in after: if a thug appears, say so).
3. Append one entry to `gtai-masters/n30/cast/frames.json` (keep every entry, valid JSON; another builder may have just
   appended: re-read it right before writing): file `cop_jitter_32.mp4`, title "Patrol cop build jitter +-16 % | +-8 %, same ticks", ppm 32,
   before "left half (5114a4441)", note with duration, shot, ticks, cops counted.
4. Delete the compare snapshot only if the tool says how (`--clean`) and only after the clip is copied.

## Allowlist
`build/look/n30-c11/**`, masters files under `gtai-masters/n30/cast/`. No repo file changes, no commit needed.
If the compare tool fails on a repo bug, STOP and report it (NEED director), do not patch tools.

## Report
The exact commands and their exit/verdict lines, ffprobe line, cops counted per side, what you saw.
