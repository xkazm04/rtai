# core/clock

`SimClock` (SIM-01): fixed 60 Hz tick, at most 4 catch-up steps, and `advance()` as the one choke
point that clamps the raw frame delta. `World._process` is its only caller; lint fails any other
`_process(delta)` / `_physics_process(delta)` that reads its delta, and any
`get_*process_delta_time()` outside this folder. `SimLoop` steps the `WorldSystem`s on the tick
and records replays. `WorldSystem.step()` sees `SimClock.TICK_DT` and the tick index only.
