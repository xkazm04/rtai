# Five-seed mixed fight probe

The probe opened the game session with `--enemy-brain=mixed`. All 15 runs reached their objective. City and pit clear times cover the first three waves, including gaps. HP lost and deaths cover the full 2,400 ticks. Quest 1 ends at the five-wave Dock 9 objective. The table gives means over seeds 20261103 through 20261107 at 60 Hz. A1 recorded zero deaths throughout.

| Encounter | A1 clear s | Clear s | Change | A1 HP lost | HP lost | Change | Deaths |
|---|---:|---:|---:|---:|---:|---:|---:|
| city | 17.58 | 24.86 | +41.4% | 3.60 | 2.64 | -26.7% | 0 |
| pit | 14.53 | 20.63 | +41.9% | 7.32 | 7.20 | -1.6% | 0 |
| quest1 | 35.36 | 35.36 | +0.0% | 4.68 | 4.68 | +0.0% | 0 |

| Arena archetype | Observed hostile-ticks in city and pit |
|---|---:|
| contractor | 4,788 |
| patrol_cop | 8,293 |
| riot_cop | 4,948 |
| robot_gunner | 8,545 |
| robot_thug | 9,384 |
| swat | 10,892 |

From the worktree root, use the lane APPDATA and GODOT_BIN recorded in [cost.md](cost.md).

~~~powershell
node tools/dev/run.mjs fight_probe --all --seeds=5 --enemy-brain=mixed "--out=$($PWD.Path)/evidence/n19-ai/probe-mixed.json"
~~~
