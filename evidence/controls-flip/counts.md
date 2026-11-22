# Controls flip verification

Counts are passed / failed / skipped.

| Suite | Mode | Before | After |
|---|---|---:|---:|
| Scenarios | Wheel | 49 / 16 / 0 | 65 / 0 / 0 across full run and rerun |
| Scenarios | Legacy | 65 / 0 / 0 | 65 / 0 / 0 |
| Scenarios | No flag | 65 / 0 / 0 | 65 / 0 / 0 |
| Unit and integration | No flag | 3,637 / 0 / 2 | 3,640 / 0 / 2 |
| Unit and integration | Legacy | 3,637 / 0 / 2 | 3,640 / 0 / 2 |

After restoring the vendored GUT CLI and adding the runner-mode test, both full unit and integration runs passed 3,641 / 0 / 2. The selected runner-mode test also passed on its own with no flag and with `--controls=legacy`. The full no-flag and legacy scenario logs each ended with 65 ran, 0 failed.

The scenario baseline comes from the guard lane's [flip table](../guard-flip/flip-table.md) and [hands-start comparison](../guard-flip/wheel-start-drawn.md). Those measurements used the same 65 scenarios. The no-flag baseline selected legacy.

The unit baseline was measured in this worktree. The no-flag runner exited 0. The explicit legacy GUT run passed all 3,637 cases. Its separate load-all step caught an intermediate parse warning in the new pickup scenario. The wheel run subsequently compiled and passed that scenario.

The first full wheel sweep passed 62/65. Two failures came from running across the replay metadata edit. The corpse-horde timing assertion also failed. A fresh wheel process passed `corpse_horde`, `moves_replay`, `quest1_input` and `rivet_pickup` (4/4). The quest tape replayed identically after starting playback with the opposite launch mode.

## Protected state digests

| Fixture | Required final SHA-256 |
|---|---|
| 60-second replay | `cbeb734ff9b97c41645f735114692ea3b9e7cc6578750f32d8d9f31d69844e85` |
| Quest 1 input replay | `37bf8deacaad2f480055af695e77aa9296bb08c4f6b681c57344832333d4664a` |

Both values matched the pre-flip measurements. The 60-second replay file also retained its original byte SHA-256, `73e204a23a6b82a9fcc2cfcf0bc2f025e647b1a0001c86df9499099510d318ed`. No golden or archived tape changed.

Runner commit `c9499ca02` and wheel-default commit `a01c1e530` contain the implementation. The [fixture inventory](tests.md) identifies the contract twins, weapon selections and replay call sites.

The archived replay compatibility check covers `gtai.replay/1` files. Quest checkpoints use a separate `gtai.checkpoint/1` input history. Their same-mode resume and tamper tests passed. Persisting controls for cross-mode checkpoint resume still needs a change to the save format outside the controls lane.
