# REPORT - lane autosave (branch `d-save`), 2026-11-03

Written at 17:30 in the REPORT phase. Nothing new was built in this phase. Lint was re-run at HEAD (13/13 over 358 files). Every other
number below is from the earlier measured runs named in the JOURNAL. Performance numbers are CONTENDED (seven lanes shared the GPU).
No bench was run and no bench lock was taken, because the save engine never touches the render or sim path.

## What works

| Claim | Evidence |
|---|---|
| **Two-slot engine.** `auto_a` and `auto_b`. A write goes to the slot with the LOWER sequence number (tmp -> flush -> read back and verify the hash -> rename). The newer good slot is never touched. Only the two slots, `meta.json` and a transient tmp ever exist. | `project/core/save/` (`gtsv_container.gd`, `slot_file.gd`, `save_slots.gd`, `save_worker.gd`, `save_meta.gd`, `save_loader.gd`, `save_migrations.gd`, `save.gd` autoload). Test `test_saves_alternate_and_the_newer_slot_is_never_touched_by_a_write` in `project/tests/unit/test_save_slots.gd`. |
| **Off-thread write, at most one in flight, requests coalesced.** | `core/save/save_worker.gd`; test `test_requests_during_a_write_coalesce_into_one_pending`. |
| **Every cold path in the brief has a unit test.** Truncation at every length, every flipped byte, newer version (refused, never overwritten), zero-length, missing slot, leftover tmp, unwritable dir, both slots corrupt (kept as evidence), a failed replay-to-hash check, only the latest quarantined file kept per slot, a tmp that fails verification, and 1,000 alternating autosaves leaving exactly two slot files. | `project/tests/unit/test_save_slots.gd` (16 tests), `test_gtsv_container.gd`, `test_checkpoint_slot.gd`, `test_save_budget.gd`, `test_save_facade.gd`, `test_save_notice.gd`, `test_autosave_points.gd`. Fixture `project/tests/saves/v1.sav` (SAV-04). Unit 375 passed / 0 failed on d-save (`evidence/unit54.log`, `evidence/unit55.log`). |
| **Loader.** Loads the newest valid slot. A bad slot is quarantined (`state.sav.corrupt`) and the other slot loads. Both bad starts fresh with a notice. A hash-valid slot asking for an absurd replay (tick > 6 h, or a tape out of order) is refused like any bad slot. | `project/core/save/save_loader.gd`, `project/features/save/checkpoint_slot.gd`; tests in `test_checkpoint_slot.gd` (5). |
| **Quest autosave points.** `autosavePoints` is read and validated against `beats[]`, and a bad point is named in the error. Each point fires once at its edge, and the quest end always autosaves. Quest 1 declares the 5 requested points, with `why` lines. | `project/features/save/autosave_points.gd`, `autosave_edges.gd`, `quest_autosaver.gd`; `project/quests/collect-call/quest.json` (only the `autosavePoints` field was added); `test_autosave_points.gd`. |
| **Scenario: play to beat 4, drop the world, load, land on the saved state hash. Corrupt the newest slot, load again, land on the older slot's beat.** | `project/tests/scenarios/scenario_autosave_resume.gd`. Result `evidence/autosave/autosave-resume.json` and `evidence/autosave/load-after-corruption.log`: loads as-b4-dock at the saved hash and plays on to the same final hash as an uninterrupted run. After the flip it falls back to as-b3-toner-room, quarantines the file and raises the notice. A valid container with a wrong checkpoint hash is refused. Both bad gives a fresh start. |
| **Same scenario through the bound-input path** (simulated InputEvents -> InputMap -> `Quest1Session`) on the d-save + d-slice trial merge. 3 points written, world dropped, load re-simulates 5,669 ticks to the saved hash (751 ms CONTENDED). Newest slot flipped: fall back to b3 with the notice. The Continue button then opens a session on b3. A quit mid-beat writes a `quit` autosave, and the next load lands on that same tick and hash. | `evidence/autosave/autosave-input.json`. This ran on the trial branch `d-save-trial` (e58f359), not on d-save. See "What does not work" below. |
| **Real-process crash test.** 12 kills with `taskkill /F` mid-write, about 4,670 writes. After every kill at least one slot was valid, sequence numbers never went backwards, and there were no stray files (one leftover .tmp, tolerated). This is a random-timing test, so it runs by hand and is not a gate. | `node tools/tests/save_crash.mjs [rounds]`; result `evidence/autosave/save-crash.json`. |
| **`meta.json`** (last played, playtime, quest, beat, point, seq, slot) for the title screen. A damaged or leftover `meta.json` never blocks a load. | `core/save/save_meta.gd`; shown in `evidence/autosave/autosave-resume.json`. |
| **HUD notice, on screen.** The real game plays quest 1 to b3, the newest slot is flipped, Continue lands on b2, and "A save was damaged. Loaded the last good one." shows above the subtitle. One capture rejected (the notice overlapped the objective prompt; moved). 0 camera breaks. | `evidence/autosave/save-notice-32ppm.png` (source game-city, on `d-save-trial`, not on d-save). |
| **SAV-05 budget is a tested claim.** A 20-minute tape (4 changes/s) uses under half of the 256 KB budget. A pathological 72,000-change tape (889 KB) is still written, with a `SAV-05` note. | `project/tests/unit/test_save_budget.gd`. |
| **SAV rules and decision updated.** The owner decision (two slots replace `.bak`) is written, and the SAV-03/06/09 text matches. | `docs/decisions.md:123`, `STANDARDS.md` SAV-03. |
| **Sim untouched.** A save reads `state_hash()` and changes nothing. The only shared-file change on d-save is 3 lines in `dev/bots/collect_call_play.gd` (`state_hash()`). | Last full gates on d-save: lint 13/13, unit 375/0, scenarios 9/9 (replay_60s identical, autosave_resume green), parity exact (planted mutation caught at step 629), look goldens 11/11 (JOURNAL iteration 7, log `C:\Users\kazda\kiro\gtai-masters\day-d5\autosave\ev7.log`). Lint re-run at HEAD in this phase: 13/13. |

The masters/evidence copy is at `C:\Users\kazda\kiro\gtai-masters\day-d5\autosave\` (`frames.json`, the logs, `frames/save-notice-32ppm.png`).

## What does not work, or is only partly done

1. **The merged game is not wired on d-save itself.** The branch was cut from main, which has no `Quest1Session` / `Quest1Game`. The wiring into d-slice's `Quest1Session`, `Quest1Game` and the HUD exists as five patches and as the scratch branch `d-save-trial`. The patches are in `evidence/autosave/patches/0001..0005` and apply after d-save and d-slice are merged. `d-save-trial` was last at e58f359, merged on d-slice 3db4792. Its gates then were lint 13/13, unit 409/0 and scenarios 12/12 (`C:\Users\kazda\kiro\gtai-wt\scratch-save-trial\evidence\unit61.log` and `scen61.log`). d-slice has since moved to 17a85df. That diff touches only `view_prewarm.gd`, which is outside my scope. The trial tree was **not re-gated after that move**, so the iteration-61 gates are the last measured ones for it.
2. **The bound-input claim on d-save alone is the bot-driven scenario.** `scenario_autosave_resume` uses `CollectCallBot` on `CollectCallPlay`. The bound-input version is only on the trial tree.
3. **A resumed run is not claimed to finish on the uninterrupted run's final hash on the bound-input path.** The driver's own state is not in a save, as a human's hands are not. The load itself is exact or refused.
4. **REQUEST 2 -> slice-play is open.** `accept()` in d-slice's `quest1_autosave.gd` does not check `cp.quest == Quest1Session.QUEST`. A collect-call slot could be loaded by another quest's Continue. It is a one-line fix in d-slice's file, so I could not make it from here.
5. **Loc keys.** `SAVE__NOTICE_FELL_BACK` and `SAVE__NOTICE_NONE_READABLE` exist as keys with English fallback text. There is no PO table in the repo to add them to.
6. **Load time grows with play time.** A load re-simulates the input tape on the main thread. 5,669 ticks took 751 ms CONTENDED, so a 20-minute load would take several seconds. There is no loading frame yet.
7. **The notice shows once.** The first load after the damage raises it. A second load (for example Retry after a death) sees the slot already quarantined and says nothing.
8. **One flake seen on the trial tree, not mine.** At iteration 59, `test_noir_shadows.test_only_shadow_commands_with_a_length_are_swept` failed once with "Parameter 't' is null". It passed on an immediate re-run and did not recur at iteration 61. I read it as a contended-machine flake.
9. **No performance numbers.** The engine is off-thread and small, and I took none. Unmeasured does not mean zero.

## What blocked me, and for how long

- No hard blocks.
- Friction: the 1,000-save unit test took 82 s when it went through a thread per save on the contended machine. It now uses `SaveWorker.write_now` and takes 14 s. The threaded path stays covered by the coalescing and burst tests and by the crash test.
- Friction: `-s` SceneTree scripts cannot name autoloads at compile time, so the crash writer loads its loop script at run time.
- Friction: `/tmp/ev.log` is shared across lanes. I read another lane's results once, then moved my logs under the lane cwd.
- From iteration 8 to 68 (about 15:40 to 17:20) there was nothing left to build in my scope. Those iterations were audits, plus refreshes of the trial merge against d-slice.

## Merge notes for the Director

- `git merge-tree` of d-save against d-slice, d-bodies, d-vehicles, d-city, d-cast, d-combat, d-audio and main showed only `JOURNAL.md` (add/add) conflicting. `quest.json` is also edited by d-audio and auto-merges. This was last checked at iteration 57, and the files in scope have not changed since.
- `checkpoint.gd`, `input_tape.gd` and `features/save/README.md` are byte-identical to d-slice's copies, copied from d-slice 1d834f9. After the merge, take either side.
- Order: merge d-save and d-slice. Then `git am evidence/autosave/patches/0001..0005`, or cherry-pick from `d-save-trial` e58f359. Then run the gates.
- `scratch-save-trial` (`C:\Users\kazda\kiro\gtai-wt\scratch-save-trial`) is scratch. Delete it with `git worktree remove` after the merge.

## Next steps

1. The Director merges d-save and d-slice, applies patches 0001..0005 and re-runs lint, unit, scenarios, parity and replay on the merged tree.
2. slice-play: REQUEST 2 (the quest id check in `accept()`). REQUEST 1 (patch 0005, the notice line) only if the HUD wants the notice elsewhere. `view.notice.show(line)` is the whole API.
3. Add the `SAVE__NOTICE_*` Loc keys when the PO table lands.
4. If late-game loads pass about 1 s, put a loading frame over the replay. If that is still too slow, store periodic sim snapshots, which needs sim serialisation and is not in scope.
5. Decide whether the notice should repeat on a second load after a quarantine (the Retry-after-death path).
