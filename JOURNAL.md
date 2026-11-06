# d8-bosses JOURNAL (lane: bosses; branch d8-bosses)

## Iteration 1 (2026-11-06 14:09-15:09, BUILD)

- 14:10 Read: AGENTS.md, view.json (`tilt` is already pitch 55: no change), RigHeadCard, KingAccents,
  KingBodyView, the angle sheets (`king_55.png`) and NOTES.md. Other lanes' JOURNALs are empty so far.
- Registry rules applied (from the brief's slugs):
  - `concept-scene-parity`: the King's card is regenerated FROM the approved 55 sheet (image 1 = the
    sheet), so the in-game bust matches the concept the owner approved; judged in the live arena.
  - `generative-artifact-gating`: every generated strip is looked at, keyed, measured (frame count,
    bbox per frame) before it ships; the sheet's known defect (blood-red crown cap) is fixed in the prompt.
  - `sprite-and-atlas-production`: one strip per head variant, 5 drawn facings + 3 mirrored in code.
  - `depth-ordered-layered-art`: accents that stay drawn keep their z over the rig; the card replaces them.
  - `motion-quality-gating`: judged in motion (boss bot, fixed seed) at 32 and 64 px/m.
- 14:14 DECISION art keying: the shared `RigHeadCard.CARDS` belongs to `chars`, so the boss art per
  view lives in the bosses lane: `features/bosses/king/art/p<pitch>/` picked by the active view row's
  pitch (55 today; a 70 strip drops in beside it as `p70/`), swapped onto the built card by the King's
  own code. `top` draws no card at all, so it is untouched. Alternative (one data move away): a
  `card_set` per view row read by RigHeadCard (REQUEST to chars below).
- 14:15 Image round r1 started (King bust 55, gang head 55), lock taken by gen.mjs.

## REQUESTs
- REQUEST to chars (RigHeadCard owner): resolve card strips per view row (e.g. a `card_set` /
  pitch folder `art/view/p<pitch>/<name>.png`, fallback to today's path) so boss strips need no
  swap hook in the bosses lane. Until then bosses swap the King/gang card texture after `_build`.
