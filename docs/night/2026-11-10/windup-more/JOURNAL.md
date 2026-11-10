# JOURNAL: lane n14-windup-more, 2026-11-10

Branch `n14-windup-more` in `C:\Users\kazda\kiro\gtai-wt\n14-windup-more`, cut from main `63088ade9`.
Brief: `BRIEF.md` beside this file (committed alone, `fb8c7ea18`). Scratch: `build/n14/` (git-ignored:
film.sh, the sheets, the films). Masters (films, stills, `frames.json`):
`C:\Users\kazda\kiro\gtai-masters\n14\windup-more\`. Godot: `gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`;
every windowed run with `--position 0,1440`. Native DLLs as copied from n13, untouched.

## Setup
- Brief committed by path (`fb8c7ea18`; the hook skipped lint: inert path).
- First `--import` exit 0, 0 ERROR; `dev/bake_city.gd` 256 chunks.
- Director note (17:40): main's n11 re-cut the p70 katana and chainsaw equipped strips at x1.5
  (RivetRes.X15). Cherry-picked the Director's test fix `bc1682b84` as `355fd1c04` (the size check in
  110 space; before it test_rivet_windup failed 317 >= 473 on the katana, confirmed here). The DLLs
  predate main's body.cpp (50b476905): test_downed_person_walkable's two tests are known failures
  until the Director copies new ones in.
- Chainsaw p70: the asset lane's pre-cut cells (172x171, 154x207) are at the x1.5 strip's scale, so
  the wind-up strip is laid at x1.5 and `p70/rivet_eq_chainsaw_windup.png` joins RivetRes.X15 (not
  resampled down to 110 space).

## Tooling: rivet_windup_cells.py (n14)
- A cell's figure may now be figure `fig` (0 left, 1 right) of a row's two-figure `sheet` (the
  it313 / it317 p55 and chainsaw sheets; the two largest alpha components, loose pieces to the
  nearest), scaled by the row's `sheet_k` = rivet_frames.py's printed action-band scale for that
  equipped row (p55: sword 0.2664, katana 0.2847, baton 0.1974, chainsaw 0.2463) times the cell's k.
- Rows are named after the equipped strip (`electro_baton_left` -> `rivet_eq_electro_baton_left_windup.png`,
  `eq_cells` 3; a `left` cell). The equipped cell is read in the wind-up strip's own px (the equipped
  strip's res from its rivet_frames.json fig_h; the row's `res`); `min_cell` [317, 172] on p70 katana
  pins n13's 110-space cell (the equipped strip was re-cut at x1.5 after n13 cut its wind-up).
- Re-running the whole manifest reproduces n13's three p70 strips byte for byte (cmp).
- Fit by eye (`build/n14/fit.py`, `fv.sh`: facing | wind-up | strike | rest and facing cam | wind-up
  cam | strike cam on one ground line, the facing's helmet top and the cell centre drawn, 3x):
  helmet width between the facing's and the strike's, helmet on the centre column.
  p55 sword side k 0.92 dx 15, cam 1.08 (its helmet is drawn small under the raised arms); katana
  side 0.95 dx 8, cam 1.1; baton side 1.0 dx -6, cam 1.05; chainsaw side 0.95 dx 26, cam 1.0 dx 10.
  p70 chainsaw (x1.5 px) side 0.92 dx -10, cam 1.0. Left baton (full keyed v2 figures): p70 k 0.25
  dx 3, p55 0.267. The p55 sword runs the B ink rim like its equipped strip.
- Found: the p55 baton's equipped strip draws its strike cells about 0.72 of the facings' size (the
  cutter fell back to act_k 0.75, measured 1.07); the wind-ups are fitted to the strikes, so the
  facing -> wind-up step is the size step facing -> strike already had. Not changed (an owner call).
- Re-tone: none needed by eye at 3x and 1x (the same drawn plates as the strips, as n13 found).

## Code
- RivetWindup: second slot `LEFT_FILE` (`rivet_eq_<weapon>_left_windup.png`, one cell): `path_or`
  swaps the drawn left strip for it while winding, as it swaps the equipped strip; `cells_of`;
  `small_of` gives the one cell unmirrored. RivetStrips.cells_of asks RivetWindup.cells_of (0 lines
  net), RivetStripWarm lists the left file, RivetRes.X15 lists the p70 chainsaw wind-up.
  rivet_frames.gd untouched (200 lines).
- Dev: ReelChapters.extras `<blade>_left` (the cop 2.4 m behind him) and `<blade>_cam` (2.4 m
  below: he swings toward the camera) for the four blades.
- Films: `build/n14/film.sh` (n13's), p55 = `--view=tilt` (55 degrees, art p55: the boss view's
  pitch and cards; BossBot fights with guns from 8 m, so a blade cannot be filmed in a real boss
  fight: the director chapters under the 55 view instead). Before = `--rivet-windup=off`, same build.

## Films (32 px/m, same build, `--rivet-windup=off` vs on)
Differing frames (framemd5, video stream; movie frame f <-> logged tick t[f-1]); the view sees the
last 2-3 wind-up ticks of a sword / katana / baton swing (RigInput's late start), 10 of the chainsaw's
12, 7 on the baton's crack. Stills: `ab.py` crops each frame on the centroid of the off/on difference.

| Blade, view | Differing frames | Anticipation off -> on | Read |
|---|---|---|---|
| plasma sword p55 side | 59-60, 74-75 | 2 -> 4 | the bright blade cocks up and back for 2 frames before each slash; helmet line and feet hold; the chained slash re-cocks (strike, strike, raise, raise, strike) |
| plasma sword p55 cam | 57-58, 72-73 | 2 -> 4 | blade straight overhead; the body sinks into a crouch under the raised arms (helmet lower, reads as a squash at 1x, not a jump) |
| katana p55 side | 59-61, 76-78 | 4 -> 5 | 3-frame coil, blade over the shoulder; the drawn arc now lands on the contact frame, not 3 frames early |
| katana p55 cam | 57-59, 74-76 | 3 -> 4 | two-hand overhead raise; before, the finished cut and its arc showed 3 frames early |
| electro baton p55 side | 57-58, 70-71, 79-85 | 2 -> 4 | backswing before each jab, the 7-frame raise before the crack; the game smear (p55 NO_ARC) unchanged |
| electro baton p55 cam | same | 2 -> 4 | baton overhead, then the camera strike |
| electro baton left p70 | 57-58, 70-71, 79-85 (after the fix) | 2 -> 3 | the drawn left raise, then the left facing + smear (the left strip has no strike cell) |
| electro baton left p55 | same | 2 -> 3 | as p70 |
| chainsaw p70 side | 54-63 | 3 -> 4 | saw cocked up in front and held 10 frames, then down into the cop; off showed the running saw and its sparks 10 frames before contact |
| chainsaw p70 cam | 57-66 | 3 -> 4 | the bar upright before the dome, then down |
| chainsaw p55 side | 54-63 | 3 -> 4 | as p70, front foot lifted |
| chainsaw p55 cam | 57-66 | 3 -> 4 | at k 1.0 the upright figure read bulky beside the facing at 1x; re-cut at 0.93 and re-filmed (`p55-chainsaw_cam-on2`) |

- No pop or flicker in any: no arcs in the cells, the helmet holds its column, the feet hold the line.
  All twelve ON.
- p70 left baton, first take: 24 frames differed: the left wind-up path made `RivetStrips.hides_held`
  true (it matched only `_left.png`), so the hidden held part stopped posing and the baton's game smear
  (the left strip's only swing, LEFT_NO_SWING) was missing on the hit frame and trailed late after it
  (`i2_electro_baton_left_p70-trial1-smear-lost.png`). Fixed (`hides_held` treats the left wind-up as
  the left strip); re-filmed: 11 frames differ, the wind-up frames only, the smear as before.
- Perf in the films (editor, process ms, wind-up frames vs off): the first wind-up frame +1.5-3 ms
  (the strip's first use: the director hands the blade over after the load, as in n13; RivetStripWarm
  lists every new file for a carried weapon, tested), worst 8.9 ms; later wind-ups no change.

## Commits
- `7de9a7c86` item 1 (p55 sword, katana, baton; the tool; dev chapters; debt +7 dev_loc accepted).
- `e42469841` item 2 (the left slot, the hides_held fix, p70 + p55 left strips).
- `1277d2bf7` item 3 (chainsaw p70 x1.5 + X15, p55).
- The manifest, the provenance log and test_rivet_windup.gd carry per-item versions (staged by path
  as blobs; each commit's tree lints clean through the hook).
- DLLs: the Director's fresh build copied in at 17:57 (debug 601103df, release 6b017cd9), after all
  films; unit 2488 / 0 with them (test_downed_person_walkable passes).
