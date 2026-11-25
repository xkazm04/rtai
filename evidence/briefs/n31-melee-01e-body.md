# Builder n31-melee-01e (opus, ~35 min): take Rivet's body out of the drawn mask, then judge the bars

Read `evidence/briefs/n31-common.md` (binding) and `evidence/briefs/n31-melee-01d-clean.md` + its result in JOURNAL
(session 2, 23:31). Tag `01e`. Your files: `project/dev/melee_n31/blade_*`, `tools/melee/blade_volume*`, their
tests, `evidence/n31-melee/01-volumes/**`, `evidence/n31-melee/02-sweep/volumes/**`. Commit with
`git commit -- <paths>`. HARD STOP: commit by 25 min into the call, report and END by 35 min. This is the LAST
measure call for item 2 (director's time box): deliver numbers the director can judge, with their caveat.

## Problem
01d's mask (commits bcd19ed2d..7cbc0df90) drops the arena blobs but keeps Rivet's head, shoulders and strike arm
(his strike pose differs from the idle outline). For katana / plasma / saw / baton the weapon is drawn inside the
same strip cell as the body (`features/characters/art/view/p55/rivet_eq_<weapon>*.png` look like body + weapon
sheets - check).

## Build, in this order, stop at the first that validates
1. (10 min max) Is there a body-only drawing of the same pose (e.g. the same cell index in a weapon-less or
   unarmed strip, or a separate eq layer node you can hide)? If yes: per tick reference = that, mask = diff.
2. Else the geometric rule: drop mask pixels whose ground point lies within 0.6 m (Rivet's hurt radius,
   `combat.json`) of his centre AT THAT TICK (lunge included), and pixels whose SCREEN position is above his
   shoulder line at that tick (the head: no blade is drawn above the shoulders in a top-down strike - check this
   against the katana/plasma overhead frames before using it; skip the rule if a blade goes there).
   Report the numbers with the rule and say what it can hide (a blade within 0.6 m of his centre is not counted:
   the nearest ring cell's body reaches 0.35 m, so only its inner part is lost).
3. Look at `overlay_body_<weapon>_k<hit+1>.png` for all 5: the outline on the blade/swipe/smear only. Say what you see.
4. Re-run before (temp worktree at ba8e470b0, remove after) and after (`--game-flags=--melee-sweep`, as 01d did),
   write `evidence/n31-melee/02-sweep/volumes/after.md` (table before | after: drawn-no-hit all / inside the cut,
   hit-not-drawn, mover; for hit-not-drawn cells: where they sit (angle, distance)) and ONE side-by-side polar
   sheet `before_after.png` (row = weapon, left before, right after). Rewrite `drawn_ticks.json` for both.
Before killing any PID print its CommandLine; kill only `n23-street` or your own tool. Another builder (03) shares
the Godot lock.

## Session 3 window (launched 23:35)
Commit by 23:58. Report and END by 00:08. If step 2's rule is in and the after is not re-run by 23:55, commit the
before with the rule and say so - the director judges on what is committed. Godot lock: builder `03p2` shares it.
