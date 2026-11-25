# n30-cast-03: hit flash on the turret and the war machine (tag `c03`, model sonnet)

Read `evidence/briefs/_common.md` first: it binds. Hard stop: launch time + 55 min (report and END). First commit by launch + 25 min.

## Goal (owner's pick)
The sentry turret card (`project/features/combat/squad/foe_turret_card_view.gd`, `FoeTurretCardView`) and the war machine /
pile-driver card (`project/features/combat/squad/foe_war_card_view.gd`, `FoeWarCardView`) flash on a hit exactly like the
other card foes: the gunner, shield and thug views call `card.sync_tint(rig.is_tinted())` (`CastFarCard.sync_tint`,
`project/features/characters/cast_far_card.gd:9-15`: `PartMaterials.get_mat(PartMaterials.PartKind.PART, true, 0)` while
lit, `null` after). Both views are plain `Sprite2D`s, not `CastFarCard`: give them the same behaviour with the same material
(share it: e.g. a static helper both call, or move the body of `sync_tint` to a static `CastFarCard.tint_of(on)` that the
method uses too; no second copy of the rule). The war machine's vent sprite (`_vent`, its own glow material) keeps its
material; only the body card flashes. Call it from `show_rig` (both have the `rig`) after `sample` / `update_fighter`.

## Acceptance
1. Unit test (extend `project/tests/unit/test_cast_war_machine.gd` and the turret's test if there is one, else
   `test_cast_door.gd` shows the pattern at lines 70-82): the card's material is the tint material while `rig.is_tinted()`
   and null after; the vent's material untouched. `node tools/tests/run_unit.mjs --changed` green. Commit.
2. Live 64 px/m still of each, mid-flash, beside its unlit frame: reuse the flash scenes n29 made
   (`project/dev/cast/cast_impact_edge.gd` and whatever n29-cast-10 "flash live" used: `git log --oneline -- project/dev/cast | head -20`;
   brief `evidence/briefs/n29-cast-10-flash-live.md`). Save `C:\Users\kazda\kiro\gtai-masters\n30\cast\flash_turret_64.png`
   and `flash_war_64.png` (unlit | lit side by side). LOOK at them.
3. A 32 px/m take (1920x1080, tilt 70, 15-40 s, ffprobe) of Rivet shooting a turret and a war machine:
   `C:\Users\kazda\kiro\gtai-masters\n30\cast\flash_turret_war_32.mp4`. Count the flashes in the delivered film (frames where
   the card is lit, grouped into flashes; count the hits from the log) and report flashes vs hits per foe.
4. Colour law in the lit frames: red pixels (R > 150, G < 80, B < 80) inside each card's box = 0 added vs unlit; teal
   (H 160-190 deg, S > 0.4, V > 0.4) none added. Report the counts unlit / lit.
5. Mutate both views on the changed lines (`--max=20`), quote killed/(killed+survived). Add the two entries to
   `C:\Users\kazda\kiro\gtai-masters\n30\cast\frames.json` (append to the array; keep entries already there).

## Allowlist
`foe_turret_card_view.gd`, `foe_war_card_view.gd` (flash lines only: another builder's pad work may have landed in it;
read `git log -3 -- <file>` first and do not change walk/placement code), `cast_far_card.gd` (only to share the tint rule),
their unit tests, `project/dev/cast/**`, `tools/film/cast_*films.mjs` (a flash mode), `build/look/n30-c03/**`, the
`gtai-masters\n30\cast\flash_*` files and `frames.json`. Anything else: NEED in the report.

## Report
Commits, test names, still paths and what you saw, flash/hit counts, red/teal counts, mutate score.
