# n30-cast-10: flash through show_rig, host test (tag `c10`, model sonnet)

Read `evidence/briefs/_common.md` first: it binds. Hard stop: launch + 35 min (report and END). Commit by launch + 25 min.

## State
`6ffe37321` made the turret and war machine cards flash: `FoeTurretCardView.show_rig` (foe_turret_card_view.gd:36) and
`FoeWarCardView.show_rig` (foe_war_card_view.gd:34) call `card.sync_tint(rig.is_tinted())`. `test_cast_flash_cards.gd`
tests `sync_tint` directly, so mutate keeps two survivors: deleting either `card.sync_tint(...)` line in `show_rig`
(turret 1/2, war 1/2). No product change is wanted: tests only.

## Do
1. Add two tests to `project/tests/unit/test_cast_flash_cards.gd` that go through `show_rig` with an `ArenaRobotRigs` host,
   the way `test_cast_thug.gd` `test_thug_card_shows_hides_his_rig_and_draws_walk_hit_fall` does (host.arena = CombatArena,
   CutRig child, Fighter with archetype `sentry_turret` / `war_machine`, machine true, hp, pos, facing; ViewMode "combo";
   restore ViewMode and `CastCards._library` after). For each: `rig.set_tint(true)`, `show_rig(...)` -> the card under
   `rig.get_meta(<View>.CARD)` has the lit material `PartMaterials.get_mat(PartMaterials.PartKind.PART, true, 0)`;
   `rig.set_tint(false)`, `show_rig(...)` -> material null. Read both views first: if the war or turret row needs the
   preview enable (`CastMulroneyPreview.enable`) to have sheets, use what the shipped row gives (both rows are `enabled: true`).
   Keep the file under 200 lines and each function <= 40 lines.
2. `node tools/tests/run_unit.mjs --select=test_cast_flash_cards,test_cast_turret,test_cast_war_machine` green (lane lock).
3. `node tools/lint/lint.mjs`, `node tools/gate/quick.mjs`, commit with a pathspec:
   `test: turret and war machine cards flash through show_rig (kills the deleted sync_tint survivors)`.
4. Mutate both, after the commit: `node tools/mutate/mutate.mjs --file=project/features/combat/squad/foe_turret_card_view.gd --lines=36 --max=4 --tests=test_cast_flash_cards`
   and the same for `foe_war_card_view.gd --lines=34`. Quote killed/(killed+survived) for each.

## Allowlist
`project/tests/unit/test_cast_flash_cards.gd` only, `build/look/n30-c10/**`. Product files: read only. Anything else: NEED.

## Report
Commit hash, test result line, both mutate scores, every command's result line.
