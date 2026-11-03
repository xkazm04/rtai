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
