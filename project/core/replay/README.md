# core/replay

SIM-05: `TickInput` (one tick of quantised input), `InputSource` / `ReplayInput`, and
`ReplayLog` (`gtai.replay/1` JSON: seed, build, input changes, a state hash every 60 ticks, the
event timeline, the final hash). `-- --replay=<file>` re-runs a log headless through `World` and
exits 0 when identical, 1 when diverged, 2 when the file is unreadable.
