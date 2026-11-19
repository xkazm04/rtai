# City station spacing

At gameplay HEAD `f4b08fa71568d8cf032b1901797e79fc3f57505a`, the five station partners crowded at the west end of the north wall. Both 20-seed city sweeps reproduced all 40 A9b digests in `build/a9b/final`.

| Baseline brain | Ticks with any partner within 1 m / 48,000 | Crowded partner-ticks | Mean three-wave clear (s) | Mean HP lost | Deaths |
|---|---:|---:|---:|---:|---:|
| Guard | 36,610 | 110,321 | 17.6825 | 3.15 | 0 |
| Squad | 36,388 | 114,314 | 18.1300 | 2.91 | 0 |

The A1 fight probe runs the pit bot for 2,400 ticks on each seed from 20261103 through 20261122. Its normal trace covers wave members. The observer in `station-probe.py` samples after all station hooks, before the stage returns. It counts each living partner (3000 through 3004) once if its centre is at most 1 m from any other living fighter in the arena's hostile list, including wave members and dummies. A tick with multiple affected partners counts once in the first column. The observer restores the original stage bytes after each sweep.

```powershell
$env:APPDATA='C:/Users/kazda/kiro/gtai-n19/appdata/ai'
$env:GODOT_BIN='C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe'
node evidence/n19-ai/station-film.mjs f4b08fa71568d8cf032b1901797e79fc3f57505a build/a10/film-before
python evidence/n19-ai/station-probe.py build/a10/before
```
