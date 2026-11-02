# Determinism contract (SIM-04)

- **MUST:** the same build, inputs and seeds give an identical state hash.
- **SHOULD:** the native sim is bit-identical across machines.
- **Never deterministic:** Godot physics and rendering. Nothing a test asserts or a replay
  reproduces may depend on them (SIM-03).

## Mechanics (landed in F-05)

- **Tick (SIM-01).** `core/clock/sim_clock.gd`: a fixed 60 Hz accumulator, at most 4 catch-up
  steps per frame. A longer frame is clamped to 4 ticks of time, so a stall slows the game instead
  of spiralling (the dropped time is counted for TEL-03). Systems see only `SimClock.TICK_DT` and
  the tick index; render-side consumers read the clamped `clock.frame_delta()` and `alpha()`.
- **One raw-delta choke point.** `World._process(delta)` (`boot/world.gd`) feeds
  `SimClock.advance()` and nothing else reads a frame delta. Lint fails any other
  `_process`/`_physics_process` whose delta parameter is used, and any
  `get_process_delta_time()`/`get_physics_process_delta_time()` outside `core/clock/`.
  The spike bug this closes: evolve `sfx.gd:177` ran music fades and loop TTLs on the raw `dt` of
  `_process`, unclamped and frame-rate dependent, so one long stall jumped every fade at once.
- **RNG (SIM-02).** `core/rng/rng_registry.gd`: `ctx.rng.stream(&"system")`. Seed = 32-bit master
  seed in the high word, FNV-1a of the name in the low word (pinned by a golden-value test). Lint
  bans the global RNG, `shuffle()`/`pick_random()` (they use it), `randomize()`, and
  `RandomNumberGenerator.new()` outside `core/rng/`.
- **Replay (SIM-05).** `core/replay/`: `SimLoop` samples one `TickInput` per tick and, while
  recording, stores input changes, a SHA-256 state hash every 60 ticks (tick + every RNG stream's
  state + every system's `write_state()`), the `Events` timeline and the final hash, as
  `gtai.replay/1` JSON. `-- --replay=<file>` re-runs the log headless, synchronously (no frame
  pacing involved, so `--fixed-fps` is not needed), and exits 0 identical / 1 diverged /
  2 unreadable. A divergence names the first differing checkpoint tick.
- **Proof.** `tests/scenarios/scenario_replay_60s.gd` records 60 s (3600 ticks) of a dummy sim
  (two systems on their own streams, events, a bot input) at random 20-250 fps frame pacing,
  saves and reloads the log, replays it bit-identically, shows a different frame pacing gives the
  identical run, and catches a planted input mutation (localised to the next checkpoint) and a
  planted seed change. `tests/integration/test_replay.gd` runs the same on 5 s in the GUT layer.
- **Build identity.** A log records `application/config/version` + the engine hash; replays hold
  within one build, and a build mismatch is reported as a divergence. The export pipeline will
  stamp the git hash into the version.
- **Not yet.** Sim maths limited to operations that round identically in GDScript and C++
  (NAT-07) lands with the native port (F-06), as do `WorkerThreadPool` merges (SIM-06) and seeds
  stored with generated output (SIM-07).

## The city (landed in F-06)

- **The real world replays.** `World._ready` registers `CitySystem` before the replay branch, so
  `-- --replay=<file>` checks streaming, spawning, traffic and the bubble sim
  (`-- --record=<file>` writes a log). `scenario_city_replay` proves 20 s of a bot-steered city
  replays bit-identically on the native backend and on the GDScript reference.
- **Streaming cannot change the sim.** `CityResidency` decides which chunks the sim holds as a
  pure function of the focus, once per tick, nearest first with key tie-breaks; a chunk not yet
  read by a worker is loaded synchronously. Drawing (`ChunkView`) is time-sliced and wall-clock
  dependent, but it never touches sim state.
- **Parity (NAT-06).** `tests/parity/run_parity.gd`: native vs reference, 1200 steps, 40 exact
  snapshot checks, plus a planted ulp-sized nudge that must be caught. The native core is built
  with `/fp:strict` / `-ffp-contract=off` and uses only + - * / sqrt floor on doubles (NAT-07).
- **Generator determinism (AST-12).** Quarter-turn rotations are exact (no libm sin/cos), so the
  golden hash list holds across platforms; `scenario_city_bake` bakes twice and compares.
