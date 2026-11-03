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
- Merge notes for the Director: checkpoint.gd/input_tape.gd are copies of d-slice 1d834f9 plus
  `Checkpoint.from_dict`; take d-slice's versions and re-apply from_dict. slice-play should replace
  `Checkpoint.save/load_file/erase` with `Save.autosave/load_latest` and call
  `QuestAutosaver.poll(runner.beat_index, runner.state == SUCCEEDED)` once after each step
  (replaces `poll_checkpoint`). Quit: Save flushes on WM_CLOSE_REQUEST.
