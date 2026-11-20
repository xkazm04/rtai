# n20 flight, package 5: the morning films (after the final gate, NO code changes)

Same law as packages 1-4 (briefs in `evidence/briefs/`). The final gate has already run on HEAD: **do not change,
stage or commit any file in the repo** in this session (no code, no data, no docs). You only render films and stills
into `C:/Users/kazda/kiro/gtai-masters/n20/flight/` (outside git) and write `frames.json` there.
`export APPDATA=C:/Users/kazda/kiro/gtai-n20/appdata/flight`;
`GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`;
`--rendering-driver d3d12`; windowed runs `--position 0,1440`; one Godot at a time; never kill by name.
Stop by **07:20** (the freeze is 07:30) and report.

## 1. The all-ghosts reel (first)
`node tools/film/ghost_films.mjs --all --look=spectral --out=C:/Users/kazda/kiro/gtai-masters/n20/flight --name=all_ghosts_32`
(the command package 4 committed; if package 4 named it differently, use what `tools/README.md` says).
Look at 4 frames (one per ghost) and describe each in one line.

## 2. Re-film flight's own clips with everything from packages 3 and 4
For kerf, tonnage, ohm, dent in that order:
`node tools/film/ghost_films.mjs --ghost=<g> --look=spectral --out=C:/Users/kazda/kiro/gtai-masters/n20/flight --prefix=flight_ --takes=move,close --stills=163`
then `--takes=morph` for kerf and tonnage (already filmed at 05:00 by package 3: skip if the files exist and are newer
than 04:40). If time is short, drop dent's close first.

## 3. frames.json and cleanup
Write `C:/Users/kazda/kiro/gtai-masters/n20/flight/frames.json`, 8 to 15 entries, best first,
`[{ "file", "title", "ppm", "before", "note" }]`, `file` and `before` relative to that folder:
1. `all_ghosts_32.jpg` (reel poster), 2. `flight_tail_kerf_top_64_t163.png` before `package2/flight_tail_kerf_top_64_t163.png`,
3. `flight_tail_ohm_tilt70_64_t163.png` before `package2/flight_tail_ohm_tilt70_64_t163.png`,
4. `flight_morph_kerf_tilt70_64_t84.png` before `before/flight_morph_kerf_tilt70_64_t84.png`,
5. `flight_tonnage_morph_32.jpg`, then the fresh move/close posters and t163 stills, with the legacy `before/` frame of the
same tick where one exists. Notes are one honest line each (say what is still weak).
Delete scratch renders in that folder (not in `before/`, `package2/`, `controls/`) that frames.json does not
reference and that are not a film/poster pair (`*.mp4` + `*.jpg` of the same name stay).

## Report
Every film/still path with one line of what you judged in it; the frames.json content; anything that failed to render.
