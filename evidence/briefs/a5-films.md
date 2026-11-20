# Brief a5-films (lane dent, n20): the owner's three Dent films, the plate still, frames.json

Context: RTAI (`gtai`), ghost form **Dent**, tonight rebuilt as "Ejected" (plate
`C:\Users\kazda\kiro\gtai-masters\n20\concepts\dent_a.png`). Earlier packages built the spectral
body (tilt + top), flight, the seatbelt strap, the overload heat ring and blast, and the strings look
(`--dent-tether=strap|strings`, default strap). Read `git log --oneline -20` first. This package
makes **no product change** unless a film exposes a bug (then: a small fix commit, named in the
report, with its test). Evidence only.

## Machine rules
`export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/dent`;
`GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`;
`--rendering-driver d3d12`; every windowed run `--position 0,1440` (never the main display); one
Godot process at a time; kill by PID only. If you need `project/override.cfg` for the movie size, it
is temporary: delete it afterwards and never commit it. Stage per path; never push.

## The films (the owner judges by these)
Flight HAS landed the film tool (n20-flight 95d914ab8 + 073237b56; a4 merged it into n20-dent: if
`git log n20-dent..n20-flight` lists newer commits, `git merge n20-flight` first), then
`node tools/film/ghost_films.mjs --ghost=dent --look=spectral --out=C:/Users/kazda/kiro/gtai-masters/n20/dent --takes=move,attack,close --stills=163`
(tilt 70 above the top view, 1920x1080, a poster each, named as the owner's film list wants). Read
its usage first; if a take misses part of the attack (jab, strap, overload), say so. Fallback only if
it fails: Use the film tool if flight has landed one: `git log n20-flight --oneline -10` and look for
`tools/film/ghost_films.mjs` (if it is there: `git merge n20-flight` first, then read its README /
`tools/README.md` and use it). Otherwise follow last night's recipe exactly:
`C:\Users\kazda\kiro\gtai-masters\n19\ghosts\INDEX.md`, section "Re-shoot a take" (override.cfg for
1920x1080, `--write-movie`, `--fixed-fps 60 --quit-after 370`, `--clean`, frames 68..367, each panel
1920 x 510 from source y = 242, a 58 px title, 2 px divider, tilt 70 above, top below, H.264 High,
60 fps, AAC, faststart; poster 960x540 JPEG from the delivered movie). Add `--ghost-look=spectral` to
every Dent run (default tether: strap).

Deliver into `C:\Users\kazda\kiro\gtai-masters\n20\dent\`:
1. `dent_move_32.mp4` + `.jpg`: `--take=move --ppm=32`, tilt 70 above, top below.
2. `dent_attack_32.mp4` + `.jpg`: `--take=attack --ppm=32`. The 5 s must include the jab, the
   seize + steer with the strap, and the overload heat ring + blast. If the scripted attack take
   cannot fit all three in 5 s, deliver the take's full length (up to 20 s) and say so; never cut
   the blast.
3. `dent_close_64.mp4` + `.jpg`: `--take=attack --ppm=64`, framed on Dent (full-width crop,
   vertical framing adjusted so his head, arms and tail root are in frame in both panels).
Titles on the films: plain words, e.g. "Dent (Ejected), spectral look, 32 px/m: move", no internal
jargon.

## The still beside the plate (first entry of frames.json)
`dent_vs_plate.png`: left the plate `dent_a.png` scaled to 1080 high, right an in-game frame of Dent
at 64 px/m tilt 70 in the dive (from the move take; name the tick), cropped to a similar framing, and
below the right one the top-view frame at the same tick. Plain caption strip at the bottom.

## frames.json
`C:\Users\kazda\kiro\gtai-masters\n20\dent\frames.json`: 8 to 15 entries, best first,
`[{ "file", "title", "ppm", "before", "note" }]`: 1 the plate still; then the three films; the
strap-vs-strings side-by-side (from a4, if present); the jab-over-the-car before/after; the overload
heat ring and blast (tilt and top); the top-view direction still. `before` names the n19 file or the
legacy-look still at the same tick (`C:\Users\kazda\kiro\gtai-masters\n19\ghosts\dent_*.mp4` or
`scratch/a2/*-legacy.png`). Delete scratch renders in `n20\dent\` that frames.json does not
reference only if you made them in this package; leave `scratch/a2`, `scratch/a3`, `scratch/a4`.

## Checks
ffprobe each mp4 (1920x1080, 60 fps, duration) and quote it; look at each poster and at 3 frames of
each film yourself and say what you see (no claim without a look). Zero script errors in every
pass (quote the dev_verdict line or the log grep).

## Time
At 50 minutes stop with what is delivered and a report listing every file, its ffprobe line, and
what is missing.
