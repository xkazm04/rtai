# JOURNAL: lane chars (d8, 2026-11-06)

## Iteration 3 (14:08-15:08; iterations 1-2 died at launch on billing, so this is the first working session)

Read: AGENTS.md, view REPORT (n7x), view.json, RigHeadCard / ViewMode, rivet_55.png, the n7 head card.
Registry rules applied (from the slugs' titles; full read owed next session): depth-ordered-layered-art
(the bust card rides the head's z, torso hidden under it), sprite-and-atlas-production (strip of equal
cells, divisible by FRAMES, unit-tested), concept-scene-parity (judged in the live King fight, same seed,
same tick, before | after), generative-artifact-gating (cut from an owner-accepted sheet, provenance line).

- MILESTONE 54c05d12: per-view card sets. `view.json` rows take `card_set`; `tilt` = `55`;
  `RigHeadCard.SET_CARDS["55"]["rivet"]` = Rivet's bust (head + hazard collar + chest plate), 5 drawn
  facings + 3 mirrored, cut by `tools/art/rivet_bust.py` from `gtai-art/angle-r1/out/rivet_55.png`
  (masked per facing: shoulder balls and arms dropped; tan55 print ramp). New study row
  `tilt_basecards` = the n7 head-only card (the before). Unit tests: rows_of merge, set strips load,
  tilt/top/basecards sets (17 pass). Lint 15/15.
- DECISION card art keyed by view row (card_set), never a hard-coded 55 (docs/decisions.md line).
- EVIDENCE gtai-masters/d8/chars/: before|after under tilt at 32 and 64 px/m (King fight seed 2,
  tick 900, 0 SCRIPT ERROR in all 4 runs). LOOKED: at 64 the chest plate, shoulder disc and seams read;
  at 32 the chest reads but the collar stripes alias (192 px cell drawn ~25 px, no mipmaps).
- FRICTION: the arena flags need `res://dev/arena/arena.tscn` on the command line (else "unknown
  launch arg"). Python on Windows writes CRLF in text mode: write with newline="\n" or sed it off.
- NOT RUN this session: full unit run, scenarios, evidence, director reel in top/tilt. `top` is
  untouched by construction (no card_set, cards false) but NOT yet measured md5-identical.

NEXT:
1. Gates on 54c05d12: full `node tools/tests/run_unit.mjs`, scenarios, `top` md5 vs main at seed 2
   tick 900 (32 px/m), director reel 19/19 in top and tilt.
2. Card aliasing at 32 px/m: mipmaps on the 55 strip (+ LINEAR_WITH_MIPMAPS on the card sprite) or a
   second strip cut at the 32 px/m cell height; compare stills.
3. Rivet film: walking a full circle, sprint, pistol, claw jab (before/after 32, close-up 64).
   Check every facing of the bust (the f1/f3 frames carry a sliver of arm at the collar's edge).
4. Then the ghosts (Tonnage first) from `<ghost>_55.png`; read the other lanes' JOURNALs for REQUESTs.
