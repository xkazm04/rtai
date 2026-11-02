# Determinism contract (SIM-04)

- **MUST:** the same build, inputs and seeds give an identical state hash.
- **SHOULD:** the native sim is bit-identical across machines.
- **Never deterministic:** Godot physics and rendering. Nothing a test asserts or a replay
  reproduces may depend on them (SIM-03).

Mechanics (land with the first sim port): fixed 60 Hz tick with at most 4 catch-up steps
(`physics/common/max_physics_steps_per_frame=4`), one seeded `RandomNumberGenerator` per system
(SIM-02), a replay log of seed + build hash + per-tick input (SIM-05), and sim maths limited to
operations that round identically in GDScript and C++ (NAT-07).
