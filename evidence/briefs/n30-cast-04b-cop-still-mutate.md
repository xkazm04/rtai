# n30-cast-04b: cop jitter still (rendered) + mutate (tag `c04b`, model sonnet)

Read `evidence/briefs/_common.md` first: it binds. Hard stop: launch + 35 min (report and END). Commit by launch + 25 min.

## State
Item landed in `c2281acbb` (`StreetCrowdCards.COP_SCALE_VAR` 0.08, `body_scale_of(rig)`), table `c7185487a`
(`docs/art/cast-audit.md` "Patrol cop build jitter, n30"): cop id 1 measured 93 px at 64; the min (id 710, 92.6 px) and
max (id 230, 108.6 px) rows are COMPUTED, not rendered. Read the original brief `evidence/briefs/n30-cast-04-cop-jitter.md` step 4.

## Do
1. Render, at 64 px/m tilt 70, the min-jitter cop (id 710), the unjittered cop and the max-jitter cop (id 230) beside the card
   foes and Rivet, with `project/dev/cast/cast_size_beside.gd` (add a way to pick the cop's actor id / force k=1 there if
   missing: dev code only) and measure heights IN THE PNG with `tools/art/cast_size_measure.py`. Still:
   `C:\Users\kazda\kiro\gtai-masters\n30\cast\cop_jitter_64.png` (min | unjittered | max cop with the card foes). LOOK at it.
2. Replace the COMPUTED min/max rows in the n30 table of `docs/art/cast-audit.md` with the measured px (say "measured in
   cop_jitter_64.png"); commit (pathspec) with the dev scene change.
3. Mutate: `node tools/mutate/mutate.mjs --file=project/features/characters/street_crowd_cards.gd --max=15 --lines=<lines c2281acbb changed> --tests=test_street_crowd_cards,test_kill_card_scale`.
   Quote killed/(killed+survived); add a test for a meaningful survivor (commit separately).
4. Append the still's entry to `C:\Users\kazda\kiro\gtai-masters\n30\cast\frames.json` (keep entries; valid JSON).

## Allowlist
`project/dev/cast/**`, `tools/art/cast_size_measure.py`, `project/tests/unit/test_street_crowd_cards.gd`, `docs/art/cast-audit.md`
(the n30 cop table only), `build/look/n30-c04b/**`, masters files. Forbidden: `street_crowd_cards.gd` product code (no change needed),
the flash files, door files, warden files (other builders). Anything else: NEED.

## Report
Commits, the measured table (figure, px at 64, / unjittered cop, / Rivet), the still and what you saw, mutate score.
