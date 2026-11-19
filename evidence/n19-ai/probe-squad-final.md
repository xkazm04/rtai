# Five-seed squad fight probe

The probe opened the game session with `--enemy-brain=squad`. All 15 runs reached their objective. City and pit clear times cover the first three waves, including gaps. HP lost and deaths cover the full 2,400 ticks. Quest 1 ends at the five-wave Dock 9 objective. The table gives means over seeds 20261103 through 20261107 at 60 Hz. A1 recorded zero deaths throughout.

| Encounter | A1 clear s | Clear s | Change | A1 HP lost | HP lost | Change | Deaths |
|---|---:|---:|---:|---:|---:|---:|---:|
| city | 17.58 | 23.08 | +31.3% | 3.60 | 1.92 | -46.7% | 0 |
| pit | 14.53 | 21.34 | +46.8% | 7.32 | 6.12 | -16.4% | 0 |
| quest1 | 35.36 | 35.36 | +0.0% | 4.68 | 4.68 | +0.0% | 0 |

| Arena archetype | Observed hostile-ticks in city and pit |
|---|---:|
| contractor | 43,389 |

From the worktree root, use the lane APPDATA and GODOT_BIN recorded in [cost.md](cost.md).

~~~powershell
node tools/dev/run.mjs fight_probe --all --seeds=5 --enemy-brain=squad "--out=$($PWD.Path)/evidence/n19-ai/probe-squad-final.json"
~~~
