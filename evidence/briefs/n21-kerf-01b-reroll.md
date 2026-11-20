# n21-kerf brief 01b (resume of 01): re-roll the two FLIGHT sheets with a raised-blade HOVER row

Same rules, allowlist and pipeline as brief 01. **Wall-clock hard stop: 12:55. Commit deadline: 12:50.**
Fix lint and format findings in your own edits and go on. Never amend, never rebase. Stage per path.

## Why (the director looked at every take)
Your sheets are good: wedge helmet, slit lens, crescent blade arms, slots front and back, the ribbon, the teal.
One fault matters: in `kerf_sp_fly_70` take 1, row 1 HOVER (his idle, the pose seen most), the crescent tips in
the toward and three-quarter cells droop DOWN the picture beside the ribbon tail. At 32 px/m that is three
hanging shapes under a torso: it reads as two legs and a tail, which is exactly what the owner rejected. Also
row 1 column 4 (three-quarter away) shows the chest slots: it faces the wrong way. The HIT row (tips up) shows
what reads well. CRUISE, TURN and HIT are right.

## Director's rulings on your question ("keep the blade rule or approve the best pair?")
- **Action sheet 70: APPROVED as drawn, take 1** (its three-quarter-away column shows the back best). The action
  poses last at most 16 ticks and the blades are in motion; the droop in COCK/RECOVER/BLINK toward cells is
  accepted. Ship take 1; record the ruling in the README ("director ruling 11:59").
- **Flight sheet 70: the blade rule STANDS for row 1 HOVER only** (the idle, seen most). Rows 2 to 4 of take 1
  are good. Re-roll with the sharper row 1 text below.
- The 55-degree sheets follow once the 70 pair is settled: `kerf_sp_act_55` from the brief 01 action prompt
  (accepted as drawn by the same ruling, one take unless it breaks the grid or grows legs), `kerf_sp_fly_55`
  with the new row 1 text.

## Do
1. Re-roll `kerf_sp_fly_70` (refs R1, R2, R3 as before) with the brief 01 prompt, changing ONLY the Row 1 text
   to this, verbatim:
   `Row 1 HOVER: floating upright and poised like a swordsman waiting, the lens looking straight ahead, both upper arms raised out to the sides at shoulder height with the elbows bent, both blades held UP like a swallow's raised wings, the curved blade tips pointing up toward the sky and back, higher than his helmet, never hanging down beside the ribbon; the ribbon tail hanging below him in one loose S curve; in column 4 we see his back and right side, the chest slots hidden and the three back slots showing.`
   At most two takes. Pick the take whose HOVER row has every blade tip above shoulder height, keeps the person
   (head, neck, shoulders, chest) and keeps the other rows as good as take 1. If neither new take beats take 1's
   rows 2 to 4, you may ship take 1's rows 2 to 4 with the new take's row 1, cut by the script (same scale:
   match the head size), and say so.
   If after two re-rolls no take has the hover tips up, take the best one, write in the README which cells still
   droop, and go on: do not stop and ask (nobody will answer; the director will judge the frames).
2. Generate `kerf_sp_fly_55` with the new Row 1 text and `kerf_sp_act_55` with the brief 01 action prompt
   (refs R1, R4, R5; the 55-degree substitutions of brief 01). Same judging.
3. Prompt files get the exact text sent; the README, manifest and provenance record every take and why it was
   kept or rejected.
4. Re-cut and re-pack through `tools/art/kerf_n21_cut.py` (same scale rule, re-detect the slots into `cut.json`),
   `--import`, finish everything brief 01 asked (packed sheets, `cut.json` slots, `parts.json`, prompts, README, manifest,
   provenance, quick gate), re-make `body_contact_sheet.png`, `body_scale_32ppm.png`, `body_slots.png`.
5. Commit: `Add the Swarf Ronin tilt flight and action sheets (art only)` (one commit for the four
   sheets and their metadata, staged per path).

## Final message
Takes kept/rejected with reasons, which cells shipped from which take, scale numbers, slot counts, quick gate,
commit hash.
