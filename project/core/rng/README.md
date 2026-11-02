# core/rng

`RngRegistry` (SIM-02): one seeded `RandomNumberGenerator` per system, `ctx.rng.stream(&"name")`.
The seed is the 32-bit master seed in the high word and FNV-1a of the name in the low word, so a
new system or an extra draw never shifts another stream. Lint bans the global RNG
(`randf`/`randi`/`seed()`/`randomize`/`shuffle`/`pick_random`) and any
`RandomNumberGenerator.new()` outside this folder.
