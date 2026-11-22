# Brief 04 DRAFT (lane cast): clamshell and pile-driver in the game; the standing rule
(Director: finish this after reading brief 03's report; strike what 03 already did, add 03's leftovers at the top.)

Hard stop: 75 minutes after you start (`date` first). Stop-minus-10: commit what is done and stop. Commit each step.

## 0. Leftovers from brief 03 (fill in) + round 04 retakes (start first, detached)
Director's review of round 03 (19:55, files in `foes-n24/incoming/`):
- `rocket_trooper_attack_{70,55}_v2`: columns 4 (up-right, from behind, tube up-right) and 5 (up, from behind, tube up)
  are RIGHT now; rows 1/2/4 are near identical, so the old sheet keeps columns 1-3 (its row 1 kneel-anticipation reads
  better): splice v2 columns 4-5 into the shipped grid (measured height/baseline), if 03 did not.
- `sentry_turret_*` REJECTED take 1, three faults: (a) the square base plate turns into a diamond in the diagonal
  columns, so in game the bolted plate would spin as the dome tracks; (b) translucent green-grey smoke/heat wisps over
  the stacks and the wreck (they key badly; the game draws its own smoke); (c) fall column 4 (up-right) points the
  barrels LEFT. Retake: draw the DOME + CAGE + BARRELS ONLY in every cell (no base plate in any cell), facings as
  the cop's columns, and ONE separate sheet `sentry_turret_base_{70,55}` with the square striped base plate seen
  from the camera (the game draws the plate once, still, under the turning dome card). No smoke, haze, sparks or
  any translucent effect anywhere; opaque art only.
- UPDATE 20:05: Astra already retook the clamshell in round 03 (`out/sentry_turret_*_v2`). attack_70_v2 ACCEPTED by
  the director at sheet level: the base plate stays square and identical in every cell, no smoke, facings right
  (col 4 barrels up-right with the cage toward the lower-left, col 5 cage toward the viewer). Check the row ORDER:
  row 2 has the muzzle flash and row 3 the glow, i.e. the drawn order may be idle, fire, glow, idle: map rows to
  idle/tell/fire/recover by what is drawn, not by position. Review the other v2 sheets (fall_70_v2, hit_*_v2, 55s)
  the same way; the separate base-plate idea above is then not needed if the plate is still in every v2 cell.
- 20:12 `sentry_turret_fall_70_v2` ACCEPTED at sheet level (facings right, plate still, row 3 a clear wreck) with one
  fault: row 2 has translucent smoke wisps over the dome. Erase them in the cut (they are not part of the body) or
  retake row 2; never ship a half-keyed wisp.
- `war_machine_walk_70` ALSO REJECTED take 1: column 1 (down) shows the BACK louvres toward the viewer, column 5 (up)
  is a plan view with the lamps; columns 2-4 all show the louvres at the left with the cannon right.
- `war_machine_fall_70` REJECTED take 1: column 1 (down) is a plan view from straight above, column 2 (down-right)
  shows the BACK louvres toward the viewer instead of the cab front, column 4 (up-right) points the cannon LEFT;
  translucent grey smoke in row 3. Check every war_machine sheet for the same faults. Retake prompts must name, per
  column, what faces the viewer: col 1 = cab front, cannon muzzle and light bar toward the viewer; col 2 = cab front
  three-quarter, cannon toward lower-right, louvres hidden; col 3 = right profile, cannon right, louvres at the left
  end; col 4 = from behind three-quarter, louvres toward the viewer's lower-left, cannon toward upper-right;
  col 5 = straight from behind, louvres facing the viewer, cannon pointing up the sheet. Same camera pitch in every
  cell (70 or 55 above the floor, never straight down). No smoke or haze.

## 1. The clamshell (sentry turret) in the game
Round 03 sheets `foes-n24/out/sentry_turret_{attack,hit,fall}_{70,55}.png`. Director's review notes: (fill in).
- Cut, pack, tone, provenance, `--import`; look at every cell at 32 and 64 px/m and check the FACINGS against the
  cop's column order (down, down-right, right, up-right, up), the base plate square and still in every cell.
- Wire through `cast_cards.json` (`sentry_turret` row, same switch): today the rig is hidden and `FoeTurretView` draws
  vector shapes. With the row on, the card draws (attack row from the fighter's tell and shot ticks; idle = row 0;
  hit; fall), and `FoeTurretView` draws only what the card does not (aim line / tell marks if any: keep the danger
  read). With `enabled: false` everything is as on main. Render only.
- Size: dome about 1.1 m wide, plate about 1.4 m square. Say the measured numbers.
- Stills `C:\Users\kazda\kiro\gtai-masters\n24\cast\clamshell_{32,64}ppm_tilt{70,55}.png` beside cop and Rivet:
  idle, tell, fire, hit, wreck. A 32 px/m clip of it firing at Rivet in a fight (15-40 s, ffprobe).

## 2. The pile-driver (war machine) in the game
Same as 1 for `war_machine_{walk,attack,stomp,hit,fall}`: wire through `cast_cards.json` (the table may need a `stomp`
action key: extend the schema, the attack row comes from `alt_telegraph`/the stomp tell when the alt weapon is the
one telling; read the fighter). Today it is the thug robot rig scaled 1.65x (`FoeLooks.robot_plan`) + `FoeWalkerView`
+ `FoeWalkerCrackView`: keep the crack/weak-spot read (the louvres) working or drawn by the card. Height 2.6 m beside
Rivet's 1.65 m: measure and say it. Stills and a clip as above.

## 3. The standing rule (docs)
Add a short section where the character art rules live (find them: `docs/art/`, `STANDARDS.md` art section) saying a
character enters a wave only when it passes `docs/art/cast-checklist.md`, with the checklist's items in one table
(item, how it is checked). Then write the pass/fail table per enemy (lancer, door carrier, clamshell, pile-driver,
the others from the audit) into `docs/art/cast-audit.md`. Propose one `docs/decisions.md` line (append, one line).

## Setup and law
(copy from brief 03)
