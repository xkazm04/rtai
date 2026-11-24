# n27-01-order: number keys 1 Dent, 2 Tonnage, 3 Kerf, 4 Ohm; larger chip numbers

Slot list (data, `project/data/tables/ghost_forms.json` `deploy_slots`): `["dent", "tonnage", "kerf", "ohm"]`.
The pad/G cycle `order` (`tonnage, dent, kerf, ohm`) is unchanged and independent. Action bits
`ghost_deploy_1..4` (20..23) and wire bits are unchanged.

## Part A (commit e1c4b73d9, test fix 3f2bb5c2e)
Files: `ghost_forms.json` (one key), `ghost_forms.schema.json` (required, 4 unique ids),
`ghost_form_table.gd` (`deploy_slots`, `_check_slots`: unknown id / duplicate / length != 4 are load errors),
`ghost_number_keys.gd` (action/pressed/hint use `deploy_slots`), `ghost_form_hud.gd` (strip order),
`project/dev/controls/keys_film.gd` (`FORMS` = slot order; its press sequence still deploys all four).
`ghost_deploy_bot.gd`, `ghost_pilot.gd`, `ghost_deploy.gd`, `kerf_boss_still.gd` already go through
`GhostNumberKeys.action()`, so they follow the list with no edit. Loc / lesson cards: grep of `project/data/loc`,
`project/features`, `project/boot` for a key number next to Kerf/Ohm/Tonnage/Dent found nothing.
`gauntlet_session.gd` iterates `forms.values()` only to set unlocks (order-free).

Tests: new `test_each_number_deploys_the_named_ghost_through_the_real_press_path`,
`test_bad_deploy_slots_are_load_errors` (test_ghost_number_keys.gd). Updated for the new order:
test_ghost_number_keys.gd (SLOT_FORMS), test_ghost_form_hud.gd (strip order, number hints, labels, rebind of
`ghost_deploy_4`; `test_deploy_hint_follows_the_rebound_key` now installs the actions: it only passed before because
Tonnage was the last chip and `anchors[""]` hit it), test_ghost_deploy_bot.gd (ohm 4, kerf 3, tonnage 2),
test_ghost_bond_input.gd (ohm = `ghost_deploy_4`). `run_unit --changed` -> FULL suite (the schema file is mapped to
everything): `unit-tests: 4086 passed, 0 failed, 2 skipped (GUT, headless, FLAKY 1)`; the flake is
`test_audio_driving::test_the_radio_action_changes_the_station_only_while_driving` (fail then pass alone, unrelated).

## Tape and pilot identity
| name | presses bits 20-23? | result |
|---|---|---|
| `project/tests/**` | no shipped replay / tape / `.replay.json` file exists there; scenarios record their own logs at run time | n/a |
| `evidence/it14/linux/q1-*.replay.json`, `evidence/it15/*.replay.json` (quest 1 replays) | no: `inputs` is empty in all of them (decoded: `(packed >> 36) & 0xF` = 0 on every entry) | not re-run (evidence files, not shipped) |
| scenario `quest1_input` (records + replays quest 1 input log) | autopilot, no number keys | ok, 25.4 s |
| scenarios `quest1_keys`, `quest1_dent/kerf/ohm/tonnage`, `quest1_dent_lock` | go through ghost forms directly | ok |
| scenarios `replay_60s`, `city_replay`, `moves_replay`, `moves_fuzz`, `prologue_pilot`, `ghost_attacks` | no number-key presses in a recorded tape (`ghost_attacks` runs `--bot=ghosts` through `GhostDeployBot.action()`, which now maps to the new bits but is self-consistent: the same run records and replays) | ok |
Scenario summary line: `scenario-tests: 68 passed (headless)` (`node tools/tests/run_scenarios.mjs`, exit 0). No tape diverged.

## Merge note
`node tools/gate/quick.mjs` warned that `ghost_forms.json` conflicts with n27-melee: they edit the `bond` block and
the `doc` line, and the sorted-key rule puts `deploy_slots` between those two, so the hunks touch. The resolution is
trivial (keep both: their bond/doc lines plus the `deploy_slots` array between them).

## Part B (commit 403a31a8f)
`ghost_chip_number.gd` (new: ink plate with paper digit and ink outline), `GhostFormLayout.number_size`
(30 desktop, 24 handheld), `ghost_form_hud.gd` `_number()` (plate centre at chip centre + (-1.2, +1.15) x chip_r:
just below-left of the avatar ring, clear of the face, the Madness bar and the selected chip's key hint). The label is
still `GhostNumberKeys.hint`. Test: `test_ghost_chip_number.gd`
(`test_chip_number_is_much_larger_than_the_old_label_and_fits_the_chip_cell`).
Glyph height (digit "1", rows of paper-coloured pixels in the 1920x1080 still, tick 110 of the keys film):
before about 14-15 px (font 18, hidden half under the avatar's face), after 22 px (rows 1003..1024; font 30).
Stills: `C:/Users/kazda/kiro/gtai-masters/n27/keys/chip_before_full.png`, `chip_numbers_after_1080.png`,
`chip_numbers_before_after_1080.png`; entries in that folder's `frames.json`.
Caveat: the first chip's plate pokes about 4 px past the strip's dark panel on the left.

## Mutate
`node tools/mutate/mutate.mjs --file=project/features/souls/ghost_number_keys.gd --max=6 --tests=test_ghost_number_keys,test_ghost_deploy_bot,test_ghost_form_hud`
(at 403a31a8): score 83.3% = killed 5 / (killed 5 + survived 1). Survivor: `ghost_number_keys.gd:48`
`ENTER_R + 1.0` -> `- 1.0` (the car-door look-ahead radius; not slot-order logic, pre-existing). The brief's
`--max=20` run was started once and stopped by PID: the mutate worktree's first import was too slow for the
night's deadline, and its baseline also hit the test_ghost_form_hud failure fixed in 3f2bb5c2e.
