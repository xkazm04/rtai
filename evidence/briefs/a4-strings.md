# Brief a4-strings (lane dent, n20): the Puppeteer's strings as the second tether look, and the evidence to judge it

Context: RTAI (`gtai`), ghost form **Dent** ("Ejected", plate
`C:\Users\kazda\kiro\gtai-masters\n20\concepts\dent_a.png`). The owner also liked the "Puppeteer"
plate `C:\Users\kazda\kiro\gtai-masters\n20\concepts\dent_c.png` and asked "whether we can
practically execute car driving this way": **look at its bottom-right vignette** (four strings of
teal light from his hands to the four roof corners of the car; the car hangs from his hands like a
marionette and tips onto two wheels in the turn). Earlier packages built `DentLook`
(`dent_look.json` `tether_look` strap|strings, flag `--dent-tether=strap|strings`), the strap
(`dent_strap.gd`), the heat ring and blast spokes, and the spectral body with its STEER TWO HANDS act
cell. Read `git log --oneline -15` and those files first.

VISUAL night: no sim, replay, parity or digest moves; numbers and timing unchanged. Render only.
Strap stays the default; strings is reachable only through `--dent-tether=strings` (or the row).

## Machine rules
`export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/dent`;
`GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`;
`--rendering-driver d3d12` to render; windowed `--position 0,1440`; one Godot process at a time; kill
by PID only. AGENTS.md law (typed, <= 200/300 lines, <= 40-line functions, <= 5 params, Log, `.uid`).
Stage per path, one commit per change, no `add -A/./-u`, no stash, no `reset --hard`, never push.
Edit only `dent_*` files, new `dent_*` files and `test_dent_*`; `dent_look.json` values.

## 0. Merge flight first
`git merge n20-flight` (allowed tonight, only that branch): it brings flight's film tool
`tools/film/ghost_films.mjs` (95d914ab8, 073237b56) and the spectral HUD chip face (4362c8109).
Resolve a root `JOURNAL.md` / `evidence/briefs/*` conflict by keeping n20-dent's working copy
(`git checkout --ours` on those paths only); stop and report any conflict in a product file.

## 1. `dent_strings.gd` (tether_look strings)
- Four strings: left hand -> the car roof's two left corners, right hand -> the two right corners
  (corners from the car's heading and its body half extents: find them in the vehicle code; in tilt
  views the roof is lifted like the strap's buckle end). Each string: 1.5 px ink under a 1 px bright
  teal core at 32 px/m (scale with ppm), a small ring at each corner, a faint glow; a small drawn
  control-cross is NOT wanted (hands only, the owner's brief).
- Steering reads in the hands: from the link's turn (sign and size of the car's heading change per
  tick, render side), the hand on the inside of the turn lifts and draws back up to 0.25 m and the
  outside hand pushes forward, so the inside strings shorten; the car's drawn roof corners on the
  inside dip a little (a visual roll: offset those two corner points toward the car centre and up by
  up to 0.15 m in tilt views). Tremble on the strings while the car hits bodies.
- Heat: strings lerp teal -> amber with heat exactly as the strap does (share the colour function).
- Let go: the four strings go slack and fall for 0.35 s, then fade. Same timing as the strap.
- Top view must still read: strings from the two hands to the four corners.

## 2. Evidence for the owner's question (this is the lane's main Call)
`tools/film/ghost_films.mjs` is flight's and passes no extra flags: do NOT edit it. Either write
a Dent-named wrapper `tools/film/dent_tether_films.mjs` that imports its exported pieces and
appends `--dent-tether=<look>` after `--`, or drive `ghost_review.tscn` directly with the same
arguments it uses (`--fixed-fps 60 --write-movie ... -- --ghost=dent --take=attack --view=<v>
--ppm=<p> --ghost-look=spectral --clean --film-panel`). Film both looks on the same seed and tick with the review driver (`ghost_review.tscn --ghost=dent
--take=attack --ghost-look=spectral --dent-tether=strap|strings`, both views, 32 px/m; and one 64
px/m), and build a side-by-side (strap left, strings right, same frames) with the film helper in
`tools/film/` (`compare.mjs` / the same-tick before/after tool; read `tools/README.md`). Outputs to
`C:\Users\kazda\kiro\gtai-masters\n20\dent\`: `dent_tether_strap_vs_strings_32.mp4` (+ `.jpg`
poster). Then measure and report, honestly:
- Readability at 32 px/m with the car at about 5 m and at about 20 m from Dent (stills of both, both
  looks, both views: `scratch/a4/`). Does each string stay visible at 20 m? Width in px.
- Clutter: does any string cross a guard's body in the attack take? Count the frames in which a
  string or the strap overlaps a guard sprite's box (render side count over the take), per look.
- Cost per frame: time `_draw` of strap vs strings (Time.get_ticks_usec around the draw over the
  take; mean and p99 in microseconds; say it is CONTENDED unless under the bench lock).
Write the numbers into `C:\Users\kazda\kiro\gtai-masters\n20\dent\scratch\a4\strings_eval.json`.

## Checks
`test_dent_strings.gd` (corner geometry, inside strings shorter on a left and a right turn, slack
timeline on ticks, top view endpoints); `node tools/godot/check.mjs`; `node tools/lint/lint.mjs`;
`node tools/tests/run_unit.mjs --changed`; replay/scenarios unmoved; `node tools/gate/quick.mjs`
before each commit; `node tools/mutate/mutate.mjs --file=features/souls/dent_strings.gd --max=20`.

## Order and time
1 (commit) -> 2. At 65 minutes commit what is finished and stop with a report (files, commands,
results, still/clip paths with ticks, numbers).
