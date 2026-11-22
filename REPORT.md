# REPORT - lane `controls` (n23, 2026-11-22)

Branch `n23-controls`, cut from `main` `76111adec`. Director: Opus; builder: Astra (all product edits).
Final gate on `9880acfdb` (07:38 to 07:58), wheel as the default: `gate: PASS; C:\Users\kazda\kiro\gtai-wt\n23-controls\build\gate\9880acfdb77c\gate.json`
(PASS lint 19 checks over 1958 GDScript files; PASS unit-tests 3666 passed, 0 failed, 2 skipped; PASS scenario-tests 65 passed; PASS parity 1200 steps bit for bit, planted mutation caught at step 629; PASS selftest; PASS export-audit 883 loaded, 0 failed). Commits after `9880acfdb` touch only inert paths (`REPORT.md`, `JOURNAL.md`, `docs/decisions.md`).

| Suite on `9880acfdb` | Wheel (default) | Legacy (`--controls=legacy`) |
|---|---|---|
| Scenarios | 65 / 0 failed (gate) | 65 / 0 failed (`build/dev/scen_legacy_final.log`) |
| Unit + integration | 3,666 / 0 / 2 skipped (gate) | 3,666 / 0 / 2 skipped (`build/dev/unit_legacy_final.log`) |

Before the flip (`76111adec`): scenarios wheel 49 / 16 failed, legacy 65 / 0; unit 3,637 / 0 / 2 in both modes (`evidence/controls-flip/counts.md`).
Films and stills named below are in `C:\Users\kazda\kiro\gtai-masters\n23\controls\` (`frames.json`, 15 entries, best first).

## What works

| Item | Evidence | Number |
|---|---|---|
| Runners take `--controls=wheel\|legacy` | `c9499ca02`, `f1d5e915f`; `tools/tests/run_unit_controls.test.mjs`; GUT gets the mode through env `GTAI_CONTROLS` + `project/tests/support/gut_pre_run.gd` (vendored GUT untouched) | Node parser test green |
| Wheel is the default, opens on slot 0 `hands` | `a01c1e530`; `evidence/controls-flip/counts.md` | scenarios wheel 49 -> 65/65, legacy 65/65, no flag 65/65; unit+integration 3,641/0/2 in both modes at the flip (3,666 at the final gate); mutate `controls_mode.gd` 5/5 (100%, `build/dev/mutate_controls_mode.log`) |
| Pinned, twinned and re-selected tests | `evidence/controls-flip/tests.md` (every fixture with its reason) | 2 legacy contracts twinned (`rivet_pickup`, `rifle_rack`), 17 weapon fixtures re-selected, tapes replay on their recorded mode |
| Replays on their recorded mode, not re-recorded | tape header gains optional `controls`; a tape without it replays on legacy (`docs/decisions.md` 2026-11-22 controls) | 60 s replay `cbeb734f...` and quest 1 `37bf8dea...` unchanged in both modes |
| Quest 1 help card follows the mode | `b8ed9d480`, `project/boot/quest1_controls_text.gd`; stills `card_wheel.png`, `card_legacy.png` | 12/12 card tests per mode |
| Swing telemetry: a held primary counts one combo start | `f14c7cc13` | not in replay state |
| Blast ring stamped with the impact tick | `b0bdcdc2e` | 6 replay artifacts / 34 digest fields unchanged in both modes |
| Rivet's own blasts hurt him | `12d548bf6`, `93d0d5b49`, `4f175c24a`, `b765422a1`; `project/features/combat/rivet_self_blast.gd`; `evidence/controls-flip/self-blast-radii.md` | own rocket 22 HP at point blank, 0 at 3.5 m; nuke lethal within 4.0 m of the body edge; film 100 -> 88.2 in the open, 100 -> 100 behind a high wall; mutate 15/17 (88.2%) |
| Per-wave `self_damage` in the gauntlet result | `gauntlet_run.schema.json` (own optional field) | seed 7 average: 0.0 x5 (measured, the bot did not self-hit) |
| Guard pose reads without the spark | `5b46a21f1`: painted `rivet_guard.png` per pitch (p70, p55), cut by `tools/art/rivet_guard.py`; `project/features/player/player_guard_pose.gd`; stills `guard_pose_32.png`, `guard_pose_64.png` (old beside new, 8 facings, both pitches, no spark), `guard_phases_64.png`, film `guard_pose.mp4` | 2 in-betweens of 3 ticks + held + stagger held while broken; flat rig lowers its body; replay_60s, quest1_input, rivet_deflect byte-identical; mutate 19/20 (95%) |
| Quest 1 and arena films on hands with the wheel | `9f47d79a7`, `979ca87d0`, `1599978eb`; `evidence/controls-flip/films.md`; films `quest1_wheel.mp4` (24 s), `arena_wheel.mp4` (16 s), before `quest1_legacy.mp4` (12 s); stills `quest1_wheel_pickup.png`, `quest1_wheel_select.png`, `arena_wheel_select.png`, `wheel_hands_64.png` | no `--controls` flag given; each take `ok exit 0; SCRIPT ERROR 0; unknown arg 0` |
| Wheel card names the pad and the use detail again | `dda3339d4`, `project/boot/quest1_controls_text.gd`; still `card_wheel.png` | 4 lines; card tests per mode green |
| The wheel shows at the opening and on a hands-only scroll | `755ff6c26`, `7847148d9`, `4a5548421`; `project/features/player/wheel_readout_view.gd` (view-only `readout_scroll_tick`, not in replay state); stills `quest1_wheel_opening.png`, `arena_wheel_hands.png` | readout visible ticks 0-59 and 60 ticks after any cycle press; replay_60s `cbeb734f...`, quest1_input `37bf8dea...`, rivet_deflect `4352a444...` identical; mutate rivet_wheel 10/10 |
| Guard keeps Rivet's size | `425ec8894`, `tools/art/rivet_guard.py` recut from the same masters; `evidence/controls-flip/guard-scale.md`; stills `guard_phases_64.png`, `guard_pose_64.png` (before: `*_b4.png`) | helmet width of all 40 guard cells within 5% of rest (worst -21.8% -> -4.4%); held figure 95-96% of standing height at p70 (crouch) |
| rig_stress under the bench lock | `build/dev/rig_stress_lock.log` (not committed) on `9880acfdb`, CPU load 34% | rig p50 0.784 ms at 50 people, 0.776 ms at 200 (budget 1 ms): the 03:20 miss was machine load |

## What does not
- Quest checkpoints (`gtai.checkpoint/1`) do not store the controls mode; a checkpoint saved on legacy and resumed on wheel replays its input history on the launch mode. Same-mode resume and tamper tests pass. Needs a save-format change outside this lane.
- In quest 1's opening the wheel readout (lower right) sits just above the dialog box and is half hidden by its top edge when a line is up (`quest1_wheel_opening.png`). It reads, but a HUD layout pass should keep it clear of the dialog.
- The test player does not yet keep its rockets outside its own blast radius (loop's bot, `NEED loop` in JOURNAL 04:32). On seed 7 average it took 0.0 self damage in 5 waves, so the measured cost is none so far, not a proof.

## Moved digests
- `brutality_kills` rocket replay (in-memory tape, not a golden): Rivet's own splash at ticks 66 and 396 now takes 10.06 HP instead of 1.006, so 8 intermediate checkpoints per mode moved; the tick-700 finals are identical. Listed in `evidence/controls-flip/self-blast-digests.md`.
- Nothing else: `replay_60s`, quest 1 input, 6 tapes, 61 archived digest fields identical in both modes.

## What blocked or slowed you
- b1 edited the vendored GUT addon to forward the flag; bounced and reverted in b2 (about 20 min).
- b3: Rivet's splash first used the hostile 0.01 HP conversion (own rocket 2.2 HP, invisible); a resume (b3b, 46 min) added the conversion knob and refilmed.
- b5's films showed that the wheel readout only appeared for 60 ticks after a selection change, so the opening (on hands) had no wheel on screen; fixed in b6b (50 min, with the helmet-scale recut). b6 stopped after 2 min to ask for one old-contract test.
- A director journal commit swept Astra's staged files once; undone with a soft reset at once (5 min). Lesson: commit with a pathspec while Astra runs.

## Calls for the owner
1. **How much Rivet's own rocket hurts.** Shipped: `combat.json` `blast.rivet_hp_per_table_hp` 0.1 (own rocket 22 HP at point blank, close to an enemy lancer rocket's 24). The alternative is 0.01 (2.2 HP, which you would not notice). `self_k` 1.0 stays as the knob for "how much his own blasts count". Film `self_blast.mp4`, stills `self_blast_hit.png` / `self_blast_wall.png`.
2. Self damage can kill (you said "hurt", not "spared"). A mini-nuke kills a full-health Rivet within 4 m of his body.
3. A walk-over pickup under the wheel does not auto-select the new weapon (as last night); scroll or the grip key draws it. But quest 1's scripted rifle grab at Dock 9 (Use, through `project/boot/collect_call/stage_actions.gd` -> `CombatArena.grab_rifle`) equips the rifle at once (`quest1_wheel_pickup.png`, film frame 1084). Kept: an explicit Use-grab reads as taking it in hand. The alternative (stow it like a floor pickup) is one call in the quest's stage actions, not this lane's file.

## Merge notes
- `combat.json`: only the new `blast` block (moves adds `moves`; both are new top-level keys, sorted).
- One-line call site in `project/features/combat/weapons/fight_areas.gd` (`RivetSelfBlast.land`).
- Files outside this lane's list, all small call sites (`git diff 76111adec --stat`): `project/features/gauntlet/gauntlet_wave_stats.gd` (+1, `self_damage`; street owns the folder, expect a nearby edit), `project/boot/collect_call/stage_pilot.gd` (4 lines, the swing counter the brief asked for), `project/boot/collect_call/quest1_session.gd`, `project/boot/quest1_game.gd`, `project/boot/world.gd`, `project/features/arena/arena_session.gd`, `project/features/arena/arena_stage.gd`, `project/core/clock/sim_loop.gd`, `project/core/replay/replay_log.gd` (tape gains optional `controls`), the arena and react-line test bots (+1 each, a weapon selection), `project/features/characters/rivet_res.gd` (+2, the guard strip), `project/dev/showcase/reel_director.gd` / `reel_arsenal.gd` (reels select their weapon under the wheel).
- `tools/debt/baseline.json` moved through the debt tool only (dev-line debt for the film drivers under `project/dev/controls/`); after a conflict run `node tools/debt/merge_baseline.mjs`.
- Shared append-only: four `docs/decisions.md` lines, two `steam/ai-provenance/2026-11.jsonl` lines (the guard paintings).
- `loop` must expect `self_damage` per wave and that the bot can now kill itself with rockets (`NEED loop` in JOURNAL 04:32).
- Root `JOURNAL.md` / `REPORT.md`: keep each lane's own.

## Next steps
- Move the wheel readout clear of the dialog box in quest 1 (HUD layout).
- Store the controls mode in quest checkpoints (`gtai.checkpoint/1` -> an optional field, as the replay tape got) so a cross-mode resume replays on the mode it was saved in.
- Loop lane: teach the test player to keep rockets >= 3.5 m and the nuke >= 12 m from Rivet now that his splash hurts him; re-measure with `self_damage` per wave.
- Owner verdict on `blast.rivet_hp_per_table_hp` (0.1 shipped, 0.01 the alternative) after watching `self_blast.mp4`.

## Astra ledger
| Call | Minutes | Verdict | Note |
|---|---:|---|---|
| b1-flip | 74 | accepted | runner flag + default flip; bounced the GUT addon edit into b2 |
| b2-card | 69 | accepted | addon revert, quest card, swing count, ring tick |
| b3-selfblast | 69 | bounced (partly accepted) | debt ratchet stopped the call-site commit; HP conversion too small |
| b3b-selfblast-scale | 46 | accepted | conversion 0.1, refilm with target, HP bar and wall |
| b4-guard-pose | 46 | accepted | painted strips at both pitches, 2 rerolls on p70 front facings; film driver left staged (dev-line debt), committed in b5 Part 0 |
| b5-films | 37 | accepted | quest 1 + arena films on hands, wheel card detail, tests.md fix; found that the opening had no wheel on screen |
| b6-readout-scale | 2 | bounced | stopped before any edit to ask for one old-contract test (`test_rivet_wheel_pilot.gd:159`); granted |
| b6b-readout-scale | 50 | accepted | wheel at the opening and on a hands-only scroll, first HUD frame, helmet-scale recut |
| b7-decisions | 1 | accepted | two missing `docs/decisions.md` lines (pickup stowed, Use-grab draws, self damage can kill) |

Total: 9 calls, 394 minutes; 7 accepted, 1 partly accepted, 1 bounced before any edit.

What I would brief differently: (1) name the debt-ratchet route (`node tools/debt/debt.mjs --update --accept-regression=...`) in every brief that adds dev or film code, so no call stops on it (b3, b4); (2) put a number on "hurt" in the brief (HP lost at point blank) instead of letting the builder reuse the hostile conversion (b3); (3) give a standing grant for tests that assert the old contract of an allowed file, from the first brief (b6); (4) ask for the opening frame of every film to be checked for the HUD element the film is about (b5 missed that the wheel was not on screen at the opening).
