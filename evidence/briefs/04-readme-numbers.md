# Brief 04: README numbers from the full run (docs only, ~10 minutes)

Same worktree, branch and repo law. **No Godot** (the gate holds the slot). Edit only
`tools/mutate/README.md`; one commit, plain message `docs: mutate README numbers from the full kerb_dresser run`.

All your commits so far are accepted. In `tools/mutate/README.md`, replace the paragraph that starts
"On this machine the four-mutant sample above averaged **7.69 s/mutant**" (the example above it no longer
uses `--max=4`, so the sentence is stale) with a short "Field notes: bake-check" paragraph using these
measured facts (all CONTENDED: ~15 lanes on one machine):

- `node tools/mutate/mutate.mjs --file=features/city/gen/kerb_dresser.gd --oracle=bake-check`: 261 mutants,
  score 93.0% = killed 238 / (238 + 18); timeout 0, invalid 5; 3013 s wall, 11.41 s/mutant mean. Kills:
  golden 234 (all first seen in `c_00_00.bin`, so a kill costs one Godot start plus one chunk, 6-17 s),
  crash 4 (`:121`, `:122`: the mutant indexes `LANE_PAINT` out of range). The clean bake baseline took
  21.3 s; a survivor pays both full bakes (16-42 s). Before this oracle the same file scored 0/10 with its
  mapped unit tests.
- The districts lane's two hand plants are killed: `:63` `true -> false` (parked car shadow) and `:104`
  `0.12 -> 1.12`, both `golden c_00_00.bin`.
- Survivors to read, not test gaps by default: 15 `<` -> `<=` / `>=` -> `>` on `g.rnd()` draws (a float
  draw equal to the bound is practically never hit: equivalent), `:131` `LANE_M * side` -> `/ side`
  (side is +-1: equivalent), `:101` `1 -> 0` and `:133` `0.0 -> 1.0` (not yet explained: candidates for a
  branch the district never reaches).
- Invalid 5: deleting a call leaves a local unused (`:55`, `:68`, `:95`, `:133`, `:159`), which the
  warnings-as-errors rule turns into a parse error.
- With the earlier 2x / 60 s cap, `:56` (delete `busy.append`) came back `timeout` at 63 s under
  contention and is killed in 16.5 s on the 3x / 120 s cap: why the floor is 120 s.
- Negative controls (`controls.mjs ... --oracle=bake-check --timeout=60`): hang -> timeout in 61.0 s,
  crash -> killed/crash 7.4 s, parse -> invalid 2.6 s, clean -> survived 17.2 s, all PASS.

Keep it compact (a few lines or a small table), keep the rest of the README as is. Run
`node --test "tools/mutate/*.test.mjs"` (paste the summary) and `node tools/gate/quick.mjs --no-godot --no-clash`.
Final message: the commit sha.
