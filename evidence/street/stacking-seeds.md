# Stacking with the tuned opening

## November 22 filmed run

The unmodified 90-second timer produced no stacks in three uncapped novice runs. Each peaked at one live wave, recorded zero timeouts and zero delayed spawns, and ended in a schema-valid death. Seed 1 died on wave 16 by `swat`, seed 2 on wave 9 by `shield_robot`, and seed 3 on wave 34 by `rocket`. All three results omitted `wave_timeout_s`.

Average seed 7 used the **12-second dev override**, wheel controls, random picks and no wave limit. Block 8 stayed occupied from wave 8 through death at tick 12892. The run schema validated the death on wave 16 by `shield_robot`. The result omitted `capped`.

| Wave announcement | Live waves |
| --- | ---: |
| `wave 8 tick 5387 block 8, 1 alive` | 1 |
| `wave 9 tick 6107 block 8, 2 alive` | 2 |
| `wave 10 tick 6827 block 8, 3 alive` | 3 |
| `wave 16 tick 11726 block 8, 8 alive` | 8 |

Waves 8 through 16 each recorded `timed_out: true`. Waves 1 through 12 each recorded zero delayed spawns. Waves 13 through 16 recorded 3, 8, 8 and 9 respectively, for 28 delayed roster members in total. Wave 16 timed out with its successor still waiting for a slot.

Both death runs used the same command and result path. The first result was copied aside before the second launch.

```powershell
& $env:GODOT_BIN --headless --path project res://dev/gauntlet/gauntlet.tscn -- --bot=average --seed=7 --wave-timeout=12 "--result=$dest"
cmp build/street/stack-first.json build/street/stack-result.json
```

`cmp` exited 0. Both files were **byte-identical**, 11,866 bytes with SHA-256 `25bff7c6162442210d1bcd2c06e899f4c90a4f699372c85eccca02b43d50dc9c`. [Full death result](stack-seed7.json)

The scratch capture played the same seed to tick 5650 before opening the normal gauntlet view with `--pick-view`. Godot Movie Maker rendered every subsequent frame with D3D12 at 32 px/m, tilt 70, on the secondary screen. Source frames 270–1859 form a continuous 26.5-second cut at 1920 × 1080 and 60 fps. The first stack enters about 3.8 seconds into the cut. [Watch the film](C:/Users/kazda/kiro/gtai-masters/n23/street/stack/stack-seed7-32.mp4)

| Film time | Inspected frame |
| --- | --- |
| 2.50 s | “Wave 8” reads clearly above Ohm and the fighters between the two crossings. [One wave](C:/Users/kazda/kiro/gtai-masters/n23/street/stack/stack-1-alive.png) |
| 4.50 s | “Wave 9 - 2 alive” is legible. The wave 8 contractor and robot gunner are near the lower curb. The new shield robots and sentry occupy the center of the road. [Two waves](C:/Users/kazda/kiro/gtai-masters/n23/street/stack/stack-2-alive.png) |
| 17.50 s | “Wave 10 - 3 alive” fits beside the timer. The new war machine crowds the crossing with shields and infantry. Several bodies overlap. Frame-matched positions at tick 6885 put two wave 8 survivors, four wave 9 fighters and six wave 10 fighters on screen. [Three waves](C:/Users/kazda/kiro/gtai-masters/n23/street/stack/stack-3-alive.png) |

## Earlier checkpoint

At commit `b98480af1`, the search used `node tools/dev/run.mjs gauntlet --seed=<seed> --bot=<bot> --result=<absolute path>` with default wheel controls, random picks and no wave limit. Peak concurrent waves across the 1 finished runs was 1.

1 runs ended in death. 0 result rows recorded `timed_out: true`. Each peak comes from scanning every wave announcement in that run. The last announcement and final tick below are copied from the runner log.

| Seed | Bot | Wave reached | Death (wave, by) | Timed-out waves | Peak waves alive | Last wave announcement | Final log |
| ---: | --- | ---: | --- | --- | ---: | --- | --- |
| 5 | novice | 23 | 23, shield_robot | none | 1 | `wave 23 tick 41246 block 23, 1 alive` | `tick 42255, segment 23` |

Coverage at this checkpoint was 1 of the 20 seed/profile combinations.

The completed runs provided no tick at which three waves were alive.

The separate five-wave screening runs on this budget also produced 25 clears, zero timeout rows and a peak of one live wave. [Opening results](budget-opening.md)
