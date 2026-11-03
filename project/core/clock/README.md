# core/clock

`SimClock` (SIM-01): fixed 60 Hz tick, at most 4 catch-up steps, and `advance()` as the one choke
point that clamps the raw frame delta. `World._process` is its only caller; lint fails any other
`_process(delta)` / `_physics_process(delta)` that reads its delta, and any
`get_*process_delta_time()` outside this folder. `SimLoop` steps the `WorldSystem`s on the tick
and records replays. `WorldSystem.step()` sees `SimClock.TICK_DT` and the tick index only.

`SimClock.hold(seconds)` is the hit-stop (core/render/README.md, camera feel): `advance()` withholds
that much clamped frame time from the accumulator, so no tick runs while it lasts. It changes wall
pacing only, never a tick's content; `SimLoop.replay()` steps ticks directly and never sees it.
