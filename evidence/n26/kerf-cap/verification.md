# Kerf cap verification

Both scenario passes completed. The focused run passed all seven cases: ghost attacks, Quest 1 Kerf, Quest 1 input, prologue pilot, prologue handover, Rivet claw and the 60-second replay. The full run passed all 68. The 60-second replay ended at `cbeb734ff9b97c41`.

The four scenario-generated tapes and the quest checkpoint below matched the previous full run from this lane byte for byte (23 November, 12:36 local). The scenario runners also replayed their recordings. A separate launch with the previous quest tape returned `replay: identical`, exit 0.

| Tape or checkpoint | SHA-256 of identical file bytes |
|---|---|
| `replay/replay_60s.json` | `73e204a23a6b82a9fcc2cfcf0bc2f025e647b1a0001c86df9499099510d318ed` |
| `replay/city_20s.json` | `89758a9d678a18151d6b30ba339792a95c60ecda98c1e4eb0550addacfdfe366` |
| `replay/arena-moves.json` | `22049e0f25e9ed3a49fbd5c9489a3dfb25e60ad9a6abb9164f827f491b488567` |
| `quest1/input-run.replay.json` | `15f48b97231337d97e74e95811092003fbfecf4b81eebdfaced80a6af30e7a19` |
| `quest1/checkpoint.json` | `7b8789a1ba4a5c617b06621ba83e7815e4beb30ec8833a8d9a5a045cf67ed672` |

Native and GDScript states matched over 1,200 steps and 40 checkpoints. Both ended at `94b2865f7f17d778`. The planted parity fault was caught at step 629.

The seven historical it14/it15 tapes also reproduced their previously documented failures at tick 60, with exit 1 on every file. No digest was re-pinned.

| Archived tape | Playback |
|---|---|
| `evidence/it14/linux/q1-linux.replay.json` | state hash differs at tick 60 |
| `evidence/it14/linux/q1-win.replay.json` | state hash differs at tick 60 |
| `evidence/it15/linrel.replay.json` | state hash differs at tick 60 |
| `evidence/it15/q1-linux.replay.json` | state hash differs at tick 60 |
| `evidence/it15/q1-win.replay.json` | state hash differs at tick 60 |
| `evidence/it15/q1ed.replay.json` | state hash differs at tick 60 |
| `evidence/it15/winrel.replay.json` | state hash differs at tick 60 |

The warden fixture run passed 16 tests. The final Kerf run passed 26 tests across the cap, deploy attacks and deploy bot. All four native still captures passed their HP assertions.
