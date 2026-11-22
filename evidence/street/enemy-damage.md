# Gauntlet enemy damage, seed 7

The average bot produced byte-identical 10-wave results at baseline commit `b04e95908` and with the new multiplier set to `1.0`. Both files were 7,372 bytes. `cmp` exited 0.

| 10-wave result | SHA-256 |
| --- | --- |
| `before10.json` | `dd403c5e28824601477efd6d9e24fc6532317500c11a22ccbd482523da9f471e` |
| `after10.json` | `dd403c5e28824601477efd6d9e24fc6532317500c11a22ccbd482523da9f471e` |

| Multiplier | Wave reached (20 requested) | Death wave | Wave 1 damage taken (HP) |
| ---: | ---: | --- | ---: |
| 1.0 | 20 | Survived all 20 | 3.6 |
| 2.0 | 10 | 10, killed by `war_cannon` | 7.2 |

## Commands

Run from the worktree root in PowerShell. All four gauntlet runs exited 0 with fresh results and zero script errors.

```powershell
$env:APPDATA = 'C:/Users/kazda/kiro/gtai-n23/appdata/street'
$env:GODOT_BIN = 'C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe'
$out = (New-Item -ItemType Directory -Force build/street/edmg).FullName

# At baseline HEAD, before editing
node tools/dev/run.mjs gauntlet --seed=7 --bot=average --waves=10 "--result=$out/before10.json"

# With enemy_damage_k set to the shipped value of 1.0
node tools/dev/run.mjs gauntlet --seed=7 --bot=average --waves=10 "--result=$out/after10.json"
cmp "$out/before10.json" "$out/after10.json"
Get-FileHash "$out/before10.json","$out/after10.json" -Algorithm SHA256
node tools/dev/run.mjs gauntlet --seed=7 --bot=average --waves=20 "--result=$out/k1-20.json"

# With only enemy_damage_k temporarily set to 2.0 in project/data/tables/gauntlet.json
node tools/dev/run.mjs gauntlet --seed=7 --bot=average --waves=20 "--result=$out/k2-20.json"
```

The table was restored to a multiplier of one before the acceptance checks and commit. The runtime reads the canonical JSON value `1` as `1.0`.

## Acceptance checks

- `node tools/gate/quick.mjs` passed on all three changed GDScript files.
- `node tools/tests/run_unit.mjs --changed` reported 3,646 passed, 0 failed and 2 skipped. The two new tests passed all nine assertions, covering enemy hits, self-blasts, outgoing hits and the absent key.
- `& $env:GODOT_BIN --headless --path project -s res://tests/run_scenarios.gd` reported 65 ran, 0 failed, matching the previous street run. The 60-second replay finished 3,600 ticks and 60 checkpoints with final digest `cbeb734ff9b97c41`. Its saved 11,825 bytes matched the previous run by `cmp`, with SHA-256 `73e204a23a6b82a9fcc2cfcf0bc2f025e647b1a0001c86df9499099510d318ed`.
