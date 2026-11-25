# n30-cast-09: pile-driver eight, evidence tail (tag `c09`, model sonnet)

Read `evidence/briefs/_common.md` first: it binds. Launched ~13:58. Commit by 14:25. Hard stop 14:45 (report and END).

## State
`CastWarAnchors.WALK = EIGHT` shipped in `bc22b9749` (owner's "eight now"); table in `docs/art/cast-audit.md`
"## Pile-driver, n30". On disk: `gtai-masters/n30/cast/war8_walk_32.mp4` (the eight only, 25.85 s) and
`build/look/n30-c02/war8_feet_before_after_64.png` (64 px/m, right facing, tick 150: four left | eight right).
`gtai-masters/n30/cast/frames.json` has 7 entries and no war8 entry. The owner judges before beside after.

## Do
1. Extend `tools/film/cast_war_films.mjs` with a mode `pair`: the four (staged `WALK = FOUR`, the tool already does it)
   and the eight (committed tree) at 32 px/m, the SAME ticks and facing sequence as `clip` (right 900 ticks, then
   down-right 600), each cropped to its centre 960x1080 and hstacked four | eight, 1920x1080 60 fps, a label is not needed
   (frames.json says which side). Output `war8_four_eight_32.mp4`. Keep the file under 200 lines if it can (it is ~140);
   update the usage comment. Lane lock around the run (one Godot at a time; the tool runs several Godot processes in turn:
   hold the lock for the whole tool run).
2. Run: `node tools/film/cast_war_films.mjs C:/Users/kazda/kiro/gtai-masters/n30/cast pair`. `ffprobe` it: 1920x1080,
   60 fps, 15-40 s (if longer than 40 s, cut the right take to 900 -> 600 ticks in pair mode only). LOOK at 3 frames
   (extract with ffmpeg at 5 s, 12 s, 20 s into `build/look/n30-c09/`, Read them): both machines walk, same place, the eight's
   legs change every drawing. Say what you see.
3. Copy `build/look/n30-c02/war8_feet_before_after_64.png` to `gtai-masters/n30/cast/war8_feet_before_after_64.png`; LOOK at it.
4. `node --test "tools/film/*.test.mjs"` if a test covers cast_war_films (grep); `node tools/lint/lint.mjs`; then commit the tool with a pathspec:
   `film: cast_war_films pair mode (four | eight at 32 px/m, same ticks)`.
5. Append to `gtai-masters/n30/cast/frames.json` (keep the 7 entries, valid JSON, check with `node -e "JSON.parse(...)"`):
   - `war8_four_eight_32.mp4` "Pile-driver four | eight (shipped), same ticks", ppm 32, before "war8_four_eight_32.mp4 (left half)",
     note with duration and "sole slide eight 18-27 px vs four 12-22 (cast-audit Pile-driver n30), body jump eight 9.9-10.7 passes <= 12".
   - `war8_feet_before_after_64.png` "Pile-driver four | eight at 64 px/m, right, tick 150", ppm 64.
   - `war8_walk_32.mp4` "Pile-driver eight, right then down-right", ppm 32, before "war8_four_eight_32.mp4", 25.85 s.
   - `warden_switch_64.png` "Appliance warden walk | hit | fall at 64: no sheet larger; the walk is a steeper view with a grey bucket hat, hit/fall frontal with a tan camo cap", ppm 64, before "none".
   (`warden_switch_64.png` is already in masters.)

## Allowlist
`tools/film/cast_war_films.mjs` (+ a test beside it if one exists), `build/look/n30-c09/**`, `build/film/**` (tool scratch),
masters files under `gtai-masters/n30/cast/`. Do NOT touch `project/dev/cast/**`, `tools/debt/baseline.json` (builder c08 runs beside you).
Anything else: NEED.

## Report
Commit hash, ffprobe line, what you saw in the 3 frames and the still, frames.json entry count, every command's result line.
