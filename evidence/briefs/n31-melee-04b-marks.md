# Builder n31-melee-04b (opus): blade impacts that look like the blade - katana, plasma sword, chainsaw contact

Read `evidence/briefs/n31-common.md` (binding) and `evidence/n31-melee/04-impacts/audit.md` (lift list items 1 and 3).
Tag `04b`. Launched ~00:02. HARD STOP: commit part 1 by 00:30, part 2 by 00:45, report and END by 00:50 (the session
dies at 00:57; uncommitted work is lost). Commit with `git commit -- <paths>`.

Another builder (`02p3`) is editing and testing `melee_weapons.json`, `rivet_melee.json`, `melee_hit.gd`,
`melee_sweep.gd`, `player_melee.gd`, `melee_combo.gd`, `melee_swing.gd`, `rivet_swipe_view.gd` and runs Godot under the
lane lock `build/n31/godot.lock`. Those files are FORBIDDEN to you. It has priority on Godot: take the lock only for a
short test run or a still, and release it at once.

## Rule for this call: VIEW ONLY
Nothing you change may move a sim digest (no hitstop ticks, no sim state). Prove it: run the melee scenarios
(`node tools/tests/run_scenarios.mjs --only=<the melee/claw/gauntlet ones that exist>`; list what you ran) or the unit
tests that pin digests for these paths. Allowed files: `project/features/combat/react/claw_marks.gd` (+ a new sibling
script if it grows past 200 lines), `project/data/tables/melee_marks.json` + its schema,
`project/features/combat/kills/saw_marks.gd`, the `chainsaw` row of `project/data/tables/hit_feel.json` (kick_px and
shake only - check shake/kick are view-only: read where they are applied), new tests under `project/tests/**`.
Anything else: stop and write a NEED.

## Part 1 (commit by 00:30): katana and plasma sword marks
Read first how `claw_marks.gd` draws the claw's rake (where, how long, which weapon id it is keyed to - `&"claw"`
hardcoded per the audit) and make it read rows per weapon from `melee_marks.json`. Add rows:
- `katana`: ONE clean straight cut line across the victim along the swing's tangent (thin, long: ~0.6-0.8 m, ink
  edge with a cream highlight), fading over ~0.35 s; a short red bead line along it on a human only (red = blood).
- `plasma_sword`: the same cut, but seared - the plasma rifle scorch's palette (read `gun_fx.json` /
  `PlasmaScorchView` for its colours; never teal, never red except blood), a slightly wider glowing core that cools
  to a dark sear, ~0.5 s.
Colours and widths are your call inside the colour law (red blood only, teal souls only, vermilion danger/collar only,
amber heat/electric): write one `- [2026-11-25] DECISION melee n31 impact marks: ...` line in `docs/decisions.md`
(append one line; 02p3 may also append - re-read the file right before you add yours).
BEFORE committing: a 64 px/m still of each mark on a cop at its first visible tick (a dev scene under
`project/dev/melee_n31/marks_still.*` or the kill lab; d3d12, `--position 0,1440`), Read the stills, and say what
you see. Save to `evidence/n31-melee/04-impacts/after/marks_<weapon>_64.png`.

## Part 2 (commit by 00:45): the chainsaw's contact outside the kill
The saw draws nothing on a non-lethal bite (score 1). Give its bite the `SawMarks` (or a cut of it) on the victim
while the grind holds, and in `hit_feel.json` its row kick_px 1 -> 2.5 plus a held low shake while it grinds (view
only). Still at 64 px/m as part 1. If SawMarks cannot be used outside `KillSplitFx` without touching forbidden files,
do kick + shake only and report why.

Final report: commits, what each still shows, what scenarios/tests you ran and their result lines, NEEDs.
