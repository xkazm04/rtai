
## Autosave lane (d-save)

- `AutosavePoints` reads/validates the quest package's `autosavePoints` against `beats[]` (an unknown
  beat names the point); `AutosaveEdges` fires each at its beat edge once, the quest end always;
  `QuestAutosaver` snapshots and hands each fired point to `Save.autosave`. The session owns the one
  `poll(runner.beat_index, runner.state == SUCCEEDED)` call after each step.
- The slot body is `Checkpoint.to_dict()`; `Checkpoint.from_dict` validates it on load. The accept
  callable re-simulates and returns the session or null (see tests/support/autosave_run.gd).
- `Checkpoint.save/load_file/erase` (single file) is legacy from the slice; switch to `Save.autosave`.
