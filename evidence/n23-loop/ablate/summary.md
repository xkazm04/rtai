# Why the average bot survives

Average profile, greedy picks, wheel controls and a 72,000-tick cap. Each intervention used seeds 1 and 2 serially in a detached worktree. The deadline limited the sample. Counts distinguish a lethal hit, a 90-second wave timeout, and a bot still alive at the tick cap.

| Arm | Deaths / seeds | Median wave reached | Median death wave | Capped alive | Wave timeouts |
|---|---:|---:|---:|---:|---:|
| Repair off | 1 / 2 | 6.5 | 5 | 1 | 0 |
| Repair 3 HP/s after 6 s | 2 / 2 | 20 | 20 | 0 | 0 |
| Filter stat picks | 1 / 2 | 21 | 20 | 0 | 1 |
| Guard off | 0 / 2 | 32 | — | 1 | 1 |
| Enemy weapon damage ×2 | 1 / 2 | 28.5 | 20 | 1 | 0 |
| Archived control, seeds 1–2 | 0 / 2 | 36 | — | 2 | 0 |

The archived control reached waves 37 and 35. A fresh seed-1 control through the ablation runner was in progress at writing. [Archived control](../base-greedy/batch.json)

1. **Repair saved lives and kept the bot advancing.** Slower repair killed both seeds, on waves 30 and 10. Without repair, seed 2 died on wave 5. Seed 1 cleared wave 8 at 80.6/110 HP and stayed there until the cap because it needed 82.5 HP to advance. In the separately verified control run, seed 3 took 196.1 damage on wave 25, fell to 29.5 HP and regained 195.5 HP before the wave closed. [Seed 3 HP trace](telemetry-check/runs/average-3.json)
2. **Stat cards helped the bot survive and clear waves.** Filtering them reduced median progress from wave 36 to 21. Seed 1 timed out and seed 2 died. All eight stat cards taken by the filtered bots were forced by all-stat offers. This measures the change in the whole loadout. [Filtered runs](no-stat-picks/batch.json)
3. **Enemy weapon damage mattered on seed 2.** Doubling ten weapon damage fields and three splash fields killed it on wave 20. Seed 1 still reached wave 37. Setting guard capacity to zero produced zero deflects and zero combat deaths, with one wave timeout. Guard activation requires positive charge, and refill is clamped to capacity. [Doubled damage](enemy-dmg-x2/ablation.json) · [Guard off](guard-off/batch.json)
