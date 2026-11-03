# JOURNAL - lane autosave (branch d-save)

## 2026-11-03 iteration 1 (BUILD)
- Copied `project/features/save/checkpoint.gd`, `input_tape.gd` (+ .uid) from branch `d-slice`
  commit 1d834f9 (`feat(save): beat checkpoints for quest 1`), unchanged except `Checkpoint.from_dict`
  (new; `from_json` now calls it). The Director resolves the two branches at merge; `Checkpoint.save/
  load_file/erase` (the old single-file path) stays for slice-play until it switches to `Save.autosave`.
- MILESTONE slot engine in `core/save`: GtsvContainer (SAV-02), SaveMigrations (SAV-04), SlotFile
  (tmp -> flush -> read back -> rename), SaveSlots (auto_a/auto_b, quarantine), SaveWorker (one
  thread, coalescing), SaveMeta (meta.json), SaveLoader (newest valid, fall back, quarantine), and
  the `Save` autoload facade. Envelope in the payload: {save_version, seq, saved_unix, point, body}.
- Registry rules applied (execution-state-checkpointing, error-handling, engine-integration-safety):
  write the new state beside the old and only then swap; verify what was written by reading it back;
  validate on load and fall back instead of default-filling; never let a persistence failure throw
  into gameplay (it is a Result + a notice); keep the previous good state until the new one verified.
- Tests: tests/unit/test_gtsv_container.gd (11), test_save_slots.gd (16, every SAV-09 cold path).
  "No write permission" is simulated by a file standing where the profile dir should be (Windows has
  no cheap read-only dir); the failure path is the same Error return from mkdir/open.
- MILESTONE quest autosave points: `AutosavePoints` (reader, validates against beats[], names the bad
  point), `AutosaveEdges` (each point once at its edge; quest end always), `QuestAutosaver` (snapshot + sink).
  Quest 1 `project/quests/collect-call/quest.json` gains only `autosavePoints` (5 points, all at beat start).
  The reader lives in features/save (I do not touch features/quest): `AutosavePoints.load_file(id)` /
  `read(raw)`; the session should call it when it opens the quest and treat `errors` as a load error.
- MILESTONE scenario `scenario_autosave_resume`: quest 1 to beat 4 with its points writing the real slots,
  world dropped, load -> as-b4 state hash exact, played on to the uninterrupted run's final hash; newest
  slot flipped -> as-b3; tampered-hash valid container refused; both bad -> fresh + notice. Evidence:
  evidence/autosave/, masters day-d5/autosave/ (frames.json lists the log; there are no pixels to show).
  HONEST GAP: the driver is `CollectCallBot` on main's `CollectCallPlay`, NOT the bound-input path.
  Quest1Session / InputTape (d-slice) are not on this branch; the accept callable has the same shape
  (`Callable(body) -> session|null`), so at merge `Quest1Session.resume(cp)` slots in as `accept`.
- Gates on this branch: lint 13/13, unit 360+4 passed (ran before test_save_facade), scenarios 9/9 incl.
  replay_60s, parity exact (native == reference, mutation caught). No sim file was changed: a save reads
  `state_hash()` only. The shared-file change: `dev/bots/collect_call_play.gd` + `state_hash()` (3 lines).
  Perf numbers: none taken (the engine is off-thread and tiny; no bench run, so no lock taken).
- API names for slice-play (title card "Continue"): `Save.has_continue() -> bool`,
  `Save.load_latest(accept: Callable(body: Dictionary) -> Variant) -> SaveLoader.Outcome`
  (`.status LOADED|FRESH`, `.value` = what accept returned, `.point`, `.notice_key`, `.notice`),
  `Save.take_notice() -> String` and signal `Save.notice(key, text)` for the HUD line,
  `Save.autosave(point, body, meta)`, `Save.flush()`, `Save.read_meta()`. Notice keys:
  SAVE__NOTICE_FELL_BACK, SAVE__NOTICE_NONE_READABLE (English fallback text in the signal).
- Merge notes for the Director: checkpoint.gd/input_tape.gd/README.md are now byte-identical copies of
  d-slice's (1d834f9 .. a1cf583 never touched them), so only JOURNAL.md conflicts (`git merge-tree`
  checked against d-slice, d-bodies, d-vehicles). My reader is `CheckpointSlot.read(body)` (own file). slice-play should replace
  `Checkpoint.save/load_file/erase` with `Save.autosave/load_latest` and call
  `QuestAutosaver.poll(runner.beat_index, runner.state == SUCCEEDED)` once after each step
  (replaces `poll_checkpoint`). Quit: Save flushes on WM_CLOSE_REQUEST.
- MILESTONE real-process crash test: `node tools/tests/save_crash.mjs [rounds]` spawns a headless writer
  (`dev/save_crash_writer.gd` + `save_crash_loop.gd`), kills it by PID at random moments, and reads the
  slots with an independent Node GTSV reader. 12 kills, ~4,670 writes: at least one valid slot every
  round (always both, in this run), sequence never backwards, no stray files (one leftover .tmp seen and
  tolerated). Evidence evidence/autosave/save-crash.json. Random timing: not a deterministic gate, so it
  is not in `just evidence`; run it by hand.
- FRICTION `-s` SceneTree scripts cannot name autoloads (Save, Log) at compile time; the writer loads its
  loop script at run time instead.
- FRICTION the 1,000-save unit test took 82 s through a thread per save on the contended machine
  (it passed); it now calls `SaveWorker.write_now` (the same `_run` the thread executes): 14 s. The
  threaded path stays covered by the coalescing/burst tests and the crash test.
- MILESTONE full gates at 544fb5c: `node tools/evidence/run.mjs --no-bench` PASS: lint 13/13, unit 364,
  scenarios 9/9 (incl. replay_60s, autosave_resume), parity exact, selftest look goldens unchanged.
  Bench not run (nothing in the render/sim path changed; no lock taken).

NEXT: (1) slice-play wires `Save` into Quest1Session/title card (names above); at merge replace
`Quest1Session.poll_checkpoint` with `QuestAutosaver.poll` and use `Quest1Session.resume` as `accept`.
(2) Re-run `scenario_autosave_resume` against Quest1Session once both branches are merged so the
"bound-input" path is covered. (3) Quit-time autosave (SAV-08): the session may call
`Save.autosave("quit", ...)` with the same snapshot; the engine already flushes on close.
(4) Loc: add SAVE__NOTICE_FELL_BACK / SAVE__NOTICE_NONE_READABLE to the string table when Loc lands.
(5) Long resumes re-simulate on the main thread inside `accept`; if a late-game load takes >1 s, move
the replay behind a loading frame (the engine already returns the Outcome synchronously).

## 2026-11-03 iteration 3 (BUILD) - the bound-input gap closed in a trial merge
- MILESTONE trial integration (scratch worktree `gtai-wt/scratch-save-trial`, branch `d-save-trial` =
  d-save + d-slice ac69481; only JOURNAL.md conflicted, resolved "ours"). Wired the autosave engine
  into slice-play's `Quest1Session` / `Quest1Game`:
  - new `boot/collect_call/quest1_autosave.gd` (`Quest1Autosave`: points from quest.json, snapshot =
    `Quest1Session.checkpoint(beat)`, `accept(events, data)` Callable for `Save.load_latest`);
  - `Quest1Session`: `autosave` member built in `open()`, `poll_checkpoint()` body split into a public
    `checkpoint(beat)` (behaviour unchanged, `scenario_quest1_input` still passes);
  - `Quest1Game`: `_process` calls `session.autosave.poll()` instead of writing the checkpoint file;
    `start()` split into `_begin(session)`; Continue/Retry = `_continue()` -> `Save.load_latest`;
    `save_path != ""` is now just the on/off switch; `Checkpoint.erase` on the paid card is gone
    (quest end is an autosave `quest-end`; `_can_continue()` hides Continue when meta.point is that).
  - new scenario `scenario_autosave_input` (boot/quest1.tscn, bound-input driver, real Save engine):
    3 points written, world dropped, load = tick 5669 + saved hash (751 ms to re-simulate, CONTENDED),
    newest slot flipped -> as-b3 + notice + quarantine, Continue button -> session at b3 with autosave on.
  - Gates on the trial tree: lint 13/13, unit 384 passed, scenarios 12/12 (incl. quest1_input, replay_60s).
- Patches for the Director: `evidence/autosave/patches/0001..0003` (`git am` onto d-save + d-slice
  merged, or `git cherry-pick` from branch `d-save-trial` in the shared repo). Evidence:
  `evidence/autosave/autosave-input.json`, frames.json entry added.
- HONEST GAP: a resumed bound-input run is not claimed to end on the uninterrupted run's final hash
  (the driver's own state is not in a save, as a human's hands are not); the load itself is exact or refused.
- FRICTION a load re-simulates on the main thread: 5,669 ticks = 751 ms contended, so a 20-minute
  load would be several seconds. The slice should show a loading frame; if it is too slow, a later
  step can store a periodic state snapshot (needs sim serialisation, not in scope today).
- Worktree `scratch-save-trial` is scratch; delete after the merge (`git worktree remove`).

NEXT: Director applies the patches after merging d-save and d-slice. Then: Loc keys
SAVE__NOTICE_FELL_BACK / SAVE__NOTICE_NONE_READABLE; hook `Save.take_notice()` to the HUD line; decide
the quit-time autosave ("quit" point) with slice-play.

## 2026-11-03 iteration 4 (BUILD) - SAV-05 budget made a tested claim
- MILESTONE `tests/unit/test_save_budget.gd` (2): a 20-minute tape changing 4x/s (4,800 changes) uses
  under half of the 256 KB slot budget and raises no note; a pathological tape (a change on every one
  of 72,000 ticks = 889 KB) is still WRITTEN, with a `SAV-05` note and loads back (an over-budget
  save is reported, never dropped: losing the autosave would be worse than a big file).
- Loc keys SAVE__NOTICE_*: not done; `data/loc` has no PO files yet (nothing to add them to).
- Gates: lint 13/13, unit 367 passed. No sim file touched; scenarios/parity unchanged from 544fb5c.

NEXT: unchanged from iteration 3 (Director applies the three patches after merging d-save + d-slice;
Loc keys when the string table lands; the "quit" autosave point with slice-play).

## 2026-11-03 iteration 5 (BUILD) - trial merge refreshed on d-slice 70513ab; quit autosave
- MILESTONE d-slice moved 38 commits since the last trial (to 70513ab). Merged d-save + d-slice into
  the scratch trial branch `d-save-trial` (2ba28ca; only JOURNAL.md conflicted, kept ours). Gates on
  the merged tree: lint 13/13, unit 386, scenarios 12/12 (autosave_input hashes identical to iteration 3:
  b2 tick 768, b3 tick 2421, b4 tick 5669, load 740 ms CONTENDED), so the three patches still hold.
- MILESTONE quit point (SAV-08 "quit"): patch 0004 (`evidence/autosave/patches/0004-...`, trial commit
  96fa79d). `Quest1Autosave.save_now(point)`, `Quest1Game.save_on_quit()` called from
  WM_CLOSE_REQUEST (writes the snapshot of this tick, then `Save.flush()`; skipped when the run is
  ended or failed, those have their own saves). The bound-input scenario now closes mid-beat on a
  Continue-resumed session (+45 ticks), drops the world and loads: point "quit", same tick (2466) and
  state hash. Patch 0004 needs 0001..0003 first (same files).
- No shared file changed on d-save in this iteration (evidence + patch only). No bench, no lock.

NEXT: Director applies patches 0001..0004 (or cherry-picks `d-save-trial`) after merging d-save and
d-slice. Loc keys when the PO table lands. If slice-play wants quit-save off while paused/in a cutscene,
`save_on_quit()` is the one place.
- MILESTONE full gates on d-save at 895e93b: `node tools/evidence/run.mjs --no-bench` PASS (lint 13/13,
  unit 367, scenarios 9/9 incl. replay_60s and autosave_resume, parity exact, selftest look goldens 11/11).

## 2026-11-03 iteration 6 (BUILD) - the fallback notice reaches the screen
- GAP found: `Save.take_notice()` was raised on a fallback but nothing in the game showed it (the
  title card's Continue called `Save.load_latest` and dropped the line). The brief says "show a
  one-line notice through a function the HUD can call": the function existed, the HUD never called it.
- MILESTONE `SaveNotice` (features/save, mine; wall clock, injectable, 3 unit tests; unit 370 on d-save,
  lint 13/13). First version ticked by frame delta and tripped the SIM-01 banned-api check in the view:
  it now compares `Time.get_ticks_msec()` against an expiry, so no `_process(delta)` is needed.
- MILESTONE patch 0005 (trial commit on `d-save-trial`, merged with d-slice 19eb758, the HUD move):
  `HudState.notice`, `HudView._notice` (a memo strip centred above the subtitle), `CollectCallView.notice`
  (SaveNotice), `Quest1Game._begin` shows `Save.take_notice()` for 7 s. SHARED-FILE CHANGES (d-slice's
  files, minimal, in the patch only, not on d-save): hud_state.gd, hud_view.gd, collect_call_view.gd,
  quest1_game.gd. REQUEST 1 -> slice-play: apply patch 0005 (needs 0001..0004 first) or move the notice
  line to wherever the HUD wants it; `view.notice.show(line)` is the whole API.
- Proof: `dev/showcase/save_notice_frame.tscn` plays quest 1 by bound input to b3, flips the newest slot,
  presses the real Continue, captures the real game at 32 px/m: evidence/autosave/save-notice-32ppm.png
  (frames.json entry, source game-city). 1 capture rejected (notice overlapped the objective prompt
  under the beat panel; moved above the subtitle). 0 camera breaks. CONTENDED, no timing claimed.
- Gates on the trial tree (d-save + d-slice 19eb758 + 0005): lint 13/13, unit 395, scenarios 12/12
  (replay identical in quest1_input). Not re-run on d-save itself beyond lint + unit (no sim touched).
  No bench, no lock.
- FRICTION the notice is raised once, by the first load after the damage; a second load sees the
  already-quarantined slot as plain missing and says nothing. Right for the title card's Continue
  (the first load), noted for a Retry-after-death path that loads again.

NEXT: Director applies patches 0001..0005 after merging d-save and d-slice. Loc keys for the notices
when the PO table lands. If late-game loads get slow (>1 s re-simulation), move the replay behind a
loading frame.
