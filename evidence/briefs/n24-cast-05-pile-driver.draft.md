# Brief 05 DRAFT (lane cast): the pile-driver in the game; the owner's films; frames.json
(Director: finish after reading brief 04's report `evidence/briefs/n24-cast-04-clamshell.out.txt`; strike what 04 did;
put 04's leftovers at the top. Commit deadline for code: 23:45 (the lane's last code commit is 00:00). Hard stop 75 min.)

## 0. Leftovers from brief 04 (fill in)
Director's review of round 04 pile-driver takes (20:58, `foes-n24/out/`):
- `war_machine_{walk,attack,fall}_70_front3` ACCEPTED (2 columns: col 1 front with cab, lamps, cannon at its right,
  louvres hidden; col 2 front three-quarter, cannon lower-right; walk stride alternates; attack breech glows then
  flashes; fall lamps go dark). These are the front columns for the splice.
- `war_machine_walk_70_v2`: rows 1 and 3 cols 3-5 right; rows 2 and 4 cols 2-4 are MIRRORED (cannon left, louvres
  right). `war_machine_fall_70_v2`: row 1 all five right; row 2 cols 3-4 mirrored; row 3 right (a clear wreck).
  A mirrored col 3/4 cell may be flipped horizontally to the right facing (the renderer mirrors left facings anyway);
  say which cells were flipped. Never ship a cell whose cannon points against its column.
- Splice: front3 cols 1-2 + the best v2 / round-03 cols 3-5 per row, same figure height and baseline (measure).

## 1. The pile-driver (war machine) finished
- Only from sheets the director accepted (list them here with the takes). Splice front columns if 04 left that open.
- Cut, pack, tone, provenance, `--import`; every cell at 32 and 64 px/m; facings against the cop's column order.
- Wire through `cast_cards.json` `war_machine` row (`stomp` action key if needed: schema + test). Keep the weak-spot
  read (louvres) and the stomp / cannon danger marks drawn by the views. Switch off = main. Render only.
- Height 2.6 m beside Rivet's 1.65 m: measure the drawn height at 64 px/m and say it.
- Stills `pile_{32,64}ppm_tilt{70,55}.png` beside cop and Rivet (walk, cannon tell, fire, stomp tell, slam, hit, wreck);
  `pile_wave_32.mp4` + `pile_close_64.mp4` (1920x1080, 60 fps, 15-40 s by ffprobe; all beats; the machine survives
  long enough to show both attacks).

## 2. The owner's comparison film (one per redrawn enemy, the brief's "beside the cop and beside Rivet")
For each finished enemy (lancer, door carrier, clamshell, pile-driver): a 15-25 s clip at 32 px/m, tilt 70, 1080p60,
the enemy standing beside a patrol cop and beside Rivet (scale), then walking, attacking (tell + fire), hit, dying,
from the cast dev scene (`project/dev/cast/**`, staged beats are fine for this one: it is a scale-and-animation
sheet, not a fight). Plus a before/after pair at the same tick and zoom: main's placeholder (row `enabled: false`)
beside the new card (`enabled: true`), `<enemy>_before_after_64.png`.

## 3. frames.json
`C:\Users\kazda\kiro\gtai-masters\n24\cast\frames.json`, 8-15 entries, best first:
`[{ "file", "title", "ppm", "before", "note" }]`. Delete scratch renders in that folder it does not reference
(keep the audit lineups).

## 4. Pass/fail update
Update `docs/art/cast-audit.md` with an "after" table for each redrawn enemy (same 15 items), with the evidence path
per PASS.

## Setup and law
(copy from brief 04)
