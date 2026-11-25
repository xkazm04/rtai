# n30-cast-25: door four and eight, contact slide across drawing changes (measure only, docs append)

Tag `c25`. Model opus. Launched about 17:18. **Commit by 18:10. Hard stop 18:20: report and END.**
Common law: `evidence/briefs/_common.md` (read it first). Freeze is 18:45; nothing after your commit.

## Goal
`docs/art/cast-audit.md` "Door four and eight on the drawn boot, n30" (line ~1095) has a column "contact slide" = **not measured**
in all 8 rows. Fill it from the frames c22 already rendered, **without launching Godot** (frames exist under
`build/look/n30-c22/takes/`; scripts `c22_measure.py`, `c22_look.py`, `c22_strip.py`; the per-tick log of drawn card row, `xf`
and registered sole point is in each take). Contact slide = how far the planted boot moves on screen (world-fixed camera?
check: if the camera follows the carrier, subtract the camera motion using the background grid, or use the logged world
position) from the plant to the lift of ONE contact, i.e. across every drawing change inside that contact. A boot that
stays planted scores 0.

## What is known
- c22 lost the boot at drawing changes with three trackers: near vs far boot is ambiguous at a change. Rivet covers the boots
  in some holds (exclude those contacts, count them).
- Suggested method (yours to improve): for a walk to the right, the planted foot is the one whose drawn sole sits still in
  world x; per contact, take the lowest 7 ink rows (background-median subtracted, as c22), split the band's ink into connected
  blobs, and at each drawing change match each blob of hold N's last frame to the nearest blob of hold N+1's first frame by
  SSD on a 2x crop within +-16 px x; the planted boot is the blob whose world x moves least over the contact. Report per
  contact the sum of the per-change jumps of that blob plus its in-hold drift, max and mean per take, in px at 64 px/m and
  halved for the 32 px/m unit.
- Validate the tracker before trusting it: render a 2x strip (one contact, 4-6 frames around a change, a vertical line at the
  tracked heel) per walk at p70 right and LOOK at it; if the line leaves the boot, the number is not reported (write
  "not measured: <why>").

## Deliverable
1. Fill the 8 "contact slide" cells (or a precise "not measured: <reason>" per cell) and add 3-6 lines of method + verdict under
   the table: does the contact slide change the reading "the eight beats the four only at p70 right"? `CastDoorAnchors.WALK`
   is NOT changed in any case.
2. Scratch under `build/look/n30-c25/` (scripts, strips). Nothing in masters.
3. Commit ONLY `docs/art/cast-audit.md` (`git commit -m "audit(cast n30): door contact slide ..." -- docs/art/cast-audit.md`,
   attribution line `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`). It is inert: the hook skips lint.
   Run `node tools/evidence/cites.mjs docs/art/cast-audit.md` if it accepts that file; no new MISSING.

## Allowlist
Write: `docs/art/cast-audit.md`, `build/look/n30-c25/**`. Read anything in this worktree. Any other path: stop and report a
NEED. Forbidden: product code, data, art, tests, tools, `docs/decisions.md`, `JOURNAL.md`, `REPORT.md`, masters, other lanes'
worktrees. No Godot launches. **Never `rm -rf` anything under `build/film/c22-*`** (junctions into the tree). No amend, no
rebase, no stash, stage per path.

## Report (final message)
The 8 cells, the verdict line, the commit hash, the strip paths you looked at and what you saw, what you could not do.
