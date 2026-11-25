# n30-cast-03b: land the turret/war flash commit, then mutate (tag `c03b`, model sonnet)

Read `evidence/briefs/_common.md` first: it binds. Launched 12:35. Hard stop 13:10 (report and END). Commit by 12:55.

## State you inherit
Builder c03 built the hit flash for the sentry turret and war machine cards (brief `evidence/briefs/n30-cast-03-flash-turret-war.md`)
and died before its commit landed (a stale `index.lock` blocked it; the director removed it). In the index (STAGED):
`project/features/characters/cast_far_card.gd` (static `CastFarCard.tint_of`), `project/features/combat/squad/foe_turret_card_view.gd`,
`project/features/combat/squad/foe_war_card_view.gd`, `project/tests/unit/test_cast_flash_cards.gd` (+ `.uid`),
`project/dev/cast/cast_flash_fight.gd`. The working tree ALSO has a newer unstaged edit of `cast_flash_fight.gd`
(env var picks the pair at field init, the per-card `CastMulroneyPreview.enable` loop removed, `_lit` walks `rig.get_meta_list()`):
that is c03's last state, the one its film was made with. Its evidence already exists: `C:\Users\kazda\kiro\gtai-masters\n30\cast\flash_turret_64.png`,
`flash_war_64.png`, `flash_turret_war_32.mp4` (turret 22 flashes / 22 shots, war 20 / 21, red 0, teal 0).
`steam/ai-provenance/2026-11.jsonl` has 3 unstaged lines from another builder: NOT yours, never stage or commit it.

## Do
1. `git diff project/dev/cast/cast_flash_fight.gd`: keep the working-tree version unless it fails lint/parse
   (`node tools/godot/check.mjs res://dev/cast/cast_flash_fight.gd`). It must not enable any preview on a shipped row.
2. `node tools/tests/run_unit.mjs --select=test_cast_flash_cards,test_cast_war_machine,test_cast_turret` (take the lane lock) green;
   `node tools/lint/lint.mjs` clean on these files; `node tools/gate/quick.mjs`.
3. Commit with a pathspec (hook may take ~12 min; never skip):
   `git add <the 6 paths>` then
   `git commit -m "cast: turret and war machine cards flash on a hit like the other card foes (CastFarCard.tint_of is the one rule), flash scene takes the pair, test" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -- project/features/characters/cast_far_card.gd project/features/combat/squad/foe_turret_card_view.gd project/features/combat/squad/foe_war_card_view.gd project/tests/unit/test_cast_flash_cards.gd project/tests/unit/test_cast_flash_cards.gd.uid project/dev/cast/cast_flash_fight.gd`
4. Mutate after the commit: `node tools/mutate/mutate.mjs --file=project/features/combat/squad/foe_war_card_view.gd --max=10 --lines=<its changed lines> --tests=test_cast_flash_cards,test_cast_war_machine`
   and the same for `foe_turret_card_view.gd` (`--tests=test_cast_flash_cards,test_cast_turret`, if that test exists) and
   `cast_far_card.gd` (`--max=8`). Quote killed/(killed+survived) for each. If a survivor shows a missing assertion, add it to
   `test_cast_flash_cards.gd` and commit that separately (pathspec).
5. Check `C:\Users\kazda\kiro\gtai-masters\n30\cast\frames.json` holds entries for flash_turret_64.png, flash_war_64.png and
   flash_turret_war_32.mp4 (append the missing ones: `file`, `title`, `ppm`, `before`, `note`; keep every entry already there; valid JSON).

## Allowlist
The 6 paths above, `project/tests/unit/test_cast_flash_cards.gd`, `build/look/n30-c03b/**`, the masters `frames.json`. Anything else: NEED.

## Report
Commit hashes, test line, lint line, mutate scores, what you could not do.
