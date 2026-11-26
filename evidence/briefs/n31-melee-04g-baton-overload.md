# Builder n31-melee-04g (opus, 70 min): make the baton overload read at 32 px/m

Read `evidence/briefs/n31-common.md` (binding). Tag `04g`. Launched ~04:45. FIRST COMMIT by 05:30, LAST
commit by 05:50, report and END by 05:55 whatever state. `git commit -- <paths>`. No amend, no rebase.

LOCK: builder 03p8 renders the claw take now (its tool takes `build/n31/godot.lock` per run). Do NOT launch
Godot until 03p8 has committed (`git log --oneline -3` shows a `03p8` commit) or 05:05, whichever is first;
until then do the Godot-free part (1-2). From then on take the lock yourself for every Godot run (common law),
EXCEPT before `tools/melee/fatal_takes.sh` (its play_take.mjs takes the lock itself per run; taking it first
self-deadlocks: 27 minutes lost in session 5).

## The complaint
Owner: impacts and kills are uneven; "some detailed and well thought, some on surface done without care". The
electro baton's fatality `baton_overload` (`project/data/tables/signature_kills.json` row at ~:1681, style
`cook`) is the weakest of the five in play: in `C:/Users/kazda/kiro/gtai-masters/n31/melee/beside_fatal_electro_baton.mp4`
(1920x1080, right half = n31 HEAD, first fatality ~13 s) the director saw at 13.5 s "a pale grey overloaded cop
below Rivet, no amber current visible". The sheet `project/features/characters/art/view/p70/cop_patrol_baton_overload.png`
draws thin pale-cream current lines on the jolt rows (row 2) - at 32 px/m they are 1 px and the print
(look_d4) likely flattens them. Compare: katana_split / plasma_sword_split read at once (halves, pieces).

## 1. Cause first (Godot-free, ~10 min)
Read `kill_new_styles.gd` (cook branch ~:138, :187), `kill_cook_art.gd`, `kill_death_cells.gd` (:36-41 its
area scale k 0.87), `kill_char_fx.gd`/`kill_char.gdshader` and the row's `fx` (cells_at, cook_to, eyes_out,
smoke_ticks, tremble_deg). Name in your report: which ticks the jolt rows show, what is drawn on top of them
today (any arc? char? smoke?), and why it reads grey (char tint? print? scale?). Extract stills from the masters
film at 12.5-15 s (`ffmpeg -ss <s> -i ... -frames:v 1 build/n31/04g/b_<s>.png`) and Read them.

## 2. The lever (decide it, write it as a DECISION)
Preferred: live current OVER the body during the jolt window, drawn by code, reusing
`project/features/combat/kills/electric_arc.gd` (`ElectricArc`: amber halo #edab42 + cream core, screen-px widths,
no RNG, re-jags every 3 ticks) - 3-4 arcs from the baton contact point across the torso to the limbs and one to
the ground, live from the kill tick to the row's cells_at (+ a short tail), with a brief amber-white flash on the
contact tick, then the smoke the row already has; optionally a small dark scorch on the ground under the body
(ink/char, not red). Colour law: amber = electric current (allowed), red is blood only, teal souls only,
vermilion danger only. Values in the row's `fx` (one data value each: `arc_n`, `arc_ticks`) so they tune
without code. Keep it deterministic (replay) and cheap (<= 4 polylines per victim). Skip it under reduced
motion only as the existing arcs do. Do not repaint sheets (no image generation).

## 3. Evidence before the commit
- A 32 px/m AND 64 px/m in-game still of the overload at the jolt tick, before (HEAD at start) | after. Use
  `project/dev/melee_n31/fatality_probe.tscn` or `marks_still.tscn` through `tools/dev/run.mjs` (read their
  KNOWN_FLAGS; `--windowed --position 0,1440 --rendering-driver d3d12` for renders), crop around the victim,
  Read the pngs yourself. Bar: at 32 px/m the current is visible as amber strokes >= 2 px wide spanning >= 60 %
  of the body height on the jolt tick; nothing amber where it was before = fail.
- Tests: a unit test pinning arc count/window from the row (tests named for your new/changed class);
  `node tools/tests/run_unit.mjs --changed`; lint; the scenarios that read kills
  (`node tools/tests/run_scenarios.mjs --only=<names>` if it exists, else skip and say so). A view-only change
  should move no digest; if one moves, say which and stop (no re-pin without the director).
- Commit (part A). Then, if before 05:35: `tools/melee/fatal_takes.sh electro_baton` (after half re-rendered;
  read the script to see whether it re-renders the before too - if both, fine) -> replace
  `beside_fatal_electro_baton.mp4` in masters, look at the first fatality second, update that frames.json entry's
  note with ONE node read-modify-write; save the 32/64 px/m stills to masters as `still_overload_{32,64}_before_after.png`
  and add one entry after `still_grind_chainsaw_64.png`. Append to `evidence/n31-melee/03-fatal/takes.md`; one
  `docs/decisions.md` line `- [2026-11-26] DECISION melee n31 04g: ...`. Commit (part B).
- If time remains after part B: `node tools/mutate/mutate.mjs --file=<your main .gd> --max=12 --tests=<your test>`
  under the lock; quote the score in takes.md.

Owned: `project/features/combat/kills/**`, `project/data/tables/signature_kills.json` (the baton_overload row and
its variants only) + its schema if a new fx key needs it, tests for these, `project/dev/melee_n31/**`,
`tools/melee/**` (fixes only), `evidence/n31-melee/03-fatal/**`, the masters melee folder (only the files named
above). Anything else: stop and write a NEED in your report. Before killing any PID print its CommandLine; kill
only your own. Final report: cause, lever + values, stills (paths) and what you saw, commits, tests run with
result lines, mutate score, what you could not do.
