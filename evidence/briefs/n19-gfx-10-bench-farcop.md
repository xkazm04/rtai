# Brief n19-gfx-10: quiet benches, far-cop clip, a clearer contact clip

Lane `gfx`, night run n19, NEW session (fresh context). Read `git log --oneline -20`, `AGENTS.md`, the last 8 lines of `docs/decisions.md` first. You build and measure; the director reviews every frame and number. Engine polish only: no new art, no colour change to the print. This call changes no product file unless Part C finds a real fault (then: one small commit, named).

Write your report as you go to `C:/Users/kazda/kiro/gtai-masters/n19/gfx/bench-10-REPORT.md` (append after each part), so a cap stop loses nothing. The call is stopped at 75 min: Part A first, then B, then C.

## Environment (every Godot run)
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/gfx` before every gate or Godot run.
- One Godot process at a time (yours). `--rendering-driver d3d12` for anything that renders; windowed runs take `--position 0,1440`. Kill only your own PIDs, never by name. Other lanes' `gtai-mutate-*` temp dirs and processes are not yours: never touch them.
- Never push, never read other `n19-*` worktrees. Stage per path; no `git add -A/./-u`, no stash, no `reset --hard`.
- Temp worktrees: `git worktree add --detach "$LOCALAPPDATA/Temp/gtai-gfx-<name>" <rev>`; remove with `git worktree remove --force <path>` + `git worktree prune` when done, also on failure. Native DLLs are git-ignored: a temp worktree has none. Build them there from that rev's `native/` (`cd native && scons platform=windows arch=x86_64 target=template_debug` and `template_release`; godot-cpp and its build cache can be copied from this worktree's `native/godot-cpp` if missing), then `--import` once. Never copy this branch's DLLs into a before run when `native/` differs between the two revs (`git diff --stat <rev> HEAD -- native/`).

## Part A. The benches on a quiet machine (about 35 min)
The bench lock is `C:/Users/kazda/kiro/gtai-n19/bench.lock`, shared by five lanes. Create it exclusively (`fs.writeFileSync(p, 'gfx ' + new Date().toISOString(), {flag:'wx'})`); if it exists and is younger than 20 min, wait (check every 2 min, at most 20 min), then go on without it and label every number CONTENDED; if older than 20 min it is stale: delete it and take it. Delete it the moment your runs end, also on failure (try/finally).
Before each run count the Godot processes on the machine (`Get-CimInstance Win32_Process -Filter "Name like 'Godot%'"`) and quote the count and their command lines' `--path` (which lane): a run with others alive is CONTENDED whatever the tool says.
1. Heat-3 bench: `node tools/bench/run.mjs --heat=3` (check `--help` first for the real flag; it queues on other runs itself). Last night's police lane got p99 2.39 ms CONTENDED. Quote the section 20 verdict lines and the CONTENDED flag.
2. Rig bench for item 3A's cost (`268960380`, baked crowd contact): `"$GODOT_BIN" --headless --path project -s res://dev/bench/rig_bench.gd -- --out=<abs>/rig-bench-after.json` at HEAD, then the same at `268960380^` in a temp worktree (native differs: build its DLLs there). Run each twice, alternating (after, before, after, before). Report 50 and 200 people p50/p99 before -> after for each pair.
Copy every bench JSON to `C:/Users/kazda/kiro/gtai-masters/n19/gfx/bench/`.

## Part B. Item 2 (far cops) clip and frames.json (about 20 min)
`b9cddfe91` made the far (baked) crowd draw cops in the cop rows (blue) instead of civilian row 7. `C:/Users/kazda/kiro/gtai-masters/n19/gfx/farcop/` has stills (`top-32-cop-details.png`, `*-before-after.png`) but no clip and no `frames.json`.
1. A side-by-side clip, 32 px/m, tilt 70, heat 3, seed 18 (as the stills), 15 to 30 s, with several far (rank > 16) cops in shot: left `b9cddfe91^` (temp worktree, DLLs built there: `render.cpp` differs), right HEAD, same ticks, labelled `Before / civilian row` and `After / cop rows`, one arrow or ring on one far cop in both panels. Use `tools/film/` (read its README: it has a same-tick before/after mode). Into the farcop folder as `item2-farcop-tilt70-32ppm.mp4`.
2. `frames.json` in that folder, 8 to 12 entries best first (`[{"file","title","ppm","before","note"}]`), the clip second. Delete the `before-*`/`after-*` frame dirs if nothing references them.
3. Look at three frames of your clip yourself before you list it.

## Part C. Item 3A contact clip, re-picked (about 15 min)
`C:/Users/kazda/kiro/gtai-masters/n19/gfx/contact/item3a-contact-tilt70-32ppm.mp4` shows the change, but its marked walker (rank 15/16/17 crossing) stands over a dark street prop, so its feet inset shows little. Re-shoot it with a marked walker that crosses the 16-rig boundary on clear light paving, plus a 64 px/m feet inset that shows the ellipse holding through the switch (before: the shadow changes shape/fades at the switch; after: it does not). Same tool and seed as the first clip if a better walker exists there; else a nearby tick or seed, said in the report. Replace the clip only if the new one reads better; put it first in `contact/frames.json`.

## Report back (short, also in the report file)
A: lock taken/freed times, Godot count per run, heat-3 verdict lines, rig bench before -> after per pair, CONTENDED or not. B: clip path, three frames you looked at, frames.json written. C: clip path, walker id and ticks, replaced or not. Anything not done and why.
