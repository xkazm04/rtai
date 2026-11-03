# core/save

`Save` autoload: exactly two rotating autosave slots (SAV-01..09; owner decision 2026-11-03).

- `GtsvContainer` the SAV-02 byte format + `Decoded` (kind OK / MISSING / CORRUPT / NEWER, reason).
- `SaveMigrations` chained pure `vN -> vN+1`; fixture `tests/saves/v1.sav` is loaded by a test.
- `SlotFile` tmp -> flush -> read back -> rename. `SaveSlots` paths, scan, write target (the older
  slot), quarantine (`state.sav.corrupt`). `SaveWorker` one thread, one pending (coalesced).
- `SaveLoader` newest valid slot through the caller's `accept` (null rejects), falls back, FRESH when
  both are bad. `SaveMeta` `meta.json` (informational; the slots are the truth).
- API for the game: `Save.autosave(point, body, meta)`, `Save.flush()` (quit), `Save.has_continue()`,
  `Save.load_latest(accept)` -> `SaveLoader.Outcome`, signal `notice(key, text)` / `take_notice()`,
  `Save.read_meta()`. Layout under `user://profile/`: `auto_a/state.sav`, `auto_b/state.sav`, `meta.json`.
