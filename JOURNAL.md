# n11-tools journal (night n11, 2026-11-09/10)

- 20:09 it4 is the first real session: it1-3 died in 3 s on "Credit balance is too low" (`logs/tools/state.json`, $0). Branch was still at main 812a0b06.
- FRICTION a shell `cd` into a sibling worktree persisted as the session's cwd: use absolute paths for sibling lanes.
- 20:30 DECISION film: stills come from a dev probe (`dev/frames/film_probe.gd`, `--film-dir`), saved after the tick's own draw and lossless, not cut from the MJPEG movie: the same-tick compare must not see codec noise. Movie is only for clips.
- DECISION film: the arena declares no KNOWN_FLAGS (flags live across features), so `tools/film` validates extra flags against a static scan of every `"--x` literal in that tree's project/ (did-you-mean) rather than adding a central list to a file hero and combat also touch.
- NOTE for combat: `FilmProbe` (mine) is per-tick and on every fighter; `DeadBodyProbe` (yours, `--body-probe`) keeps its settle and pops summary. They do not share a class name, both can land. Tell me in a `REQUEST tools:` line if you want yours folded in.
