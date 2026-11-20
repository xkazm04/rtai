# n20 flight, package 3 resumed (your session was killed at 03:09, it is now 04:05)

Your previous session (package 3, `evidence/briefs/n20-flight-03-effects.md`, read it again) was killed at
03:09 when the director's session was replaced; that is not your fault. What survived: commit 4362c8109
(HUD chip) and your STAGED, uncommitted work on item 0b: `project/data/tables/ghost_hover.json` (ohm
`fade_from` 0.41 -> 0.18), `project/features/souls/ghost_tail.gd`, `project/features/souls/ghost_tail.gdshader`,
and stills `C:/Users/kazda/kiro/gtai-masters/n20/flight/flight_tail_*` (03:07) vs `package2/`. Check
`git status` / `git diff --cached` first, then continue. Same law as package 3 (APPDATA, GODOT_BIN, d3d12,
`--position 0,1440`, one Godot at a time, stage per path, no stash/add -A/reset --hard/amend, never push,
other lanes' files and rows are not yours).

## Director's look at your 03:07 stills
- Ohm tilt70 t163: the tail is now a visible dense vapour mass. Good, keep that.
- Tonnage tilt70 t195: the tail is hidden under/behind the body, and a pale-green U-shaped stroke lies on the
  floor below the pool (bottom of the frame, ~1.5 m wide). Find out what draws it (tail ink edge? a ring?).
  If it is flight's, fix it; if it is Tonnage's legacy view, write `NEED tonnage: <file> <why>`.
- Kerf top t163: the tail is still a faint thin streak; in the TOP view all four tails must read as clearly
  as Ohm's tilt tail now does (dense bright root, ragged thinning tip).
- The wisps still read as chevron/bird glyphs 2-5 m behind (item 7a): soft puffs near the tip only.

## Order (commit each on its own; stop by the 65-minute mark with everything committed)
1. Finish 0b (tail reads in both views at all facings, ink edge, Ohm fade_from) + 7a (wisps) + the U-stroke.
   Before/after stills at 64 px/m t163 for all four, both views. Commit.
2. 0c: zero-foot-contact test for all four forms under spectral, with the legacy drive that does fire. Commit.
3. Item 1 (`--take=morph` in ghost_review + `morph` in ghost_films.mjs) and item 2 (`GhostFlight.set_emerge`,
   rise in / sink out driven from GhostForms stage, README line). Commit each.
4. Item 3 (soul line copies fade with the figure). Commit.
5. Last: `node tools/mutate/mutate.mjs --file=project/features/souls/ghost_flight.gd --max=40`, quote the score.
Items 4, 5, 5b, 6 of package 3: only if time is left; otherwise list them as not done.

Checks before each commit as in package 3 (`check.mjs`, lint, `run_unit.mjs --changed`, `gate/quick.mjs`),
plus one legacy still at a fixed tick pixel-identical before/after. Report: commits (sha + line), checks, every
still/film path with one line of what you judged in it, NEED lines, what is still weak or not done.
