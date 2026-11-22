# Rivet guard scale

All 40 recut domes are within 5% of standing width. Previously 12 exceeded that tolerance. The largest error was the p55 front-right stagger, 43 texels against 55 at rest (-21.82%). That cell now measures 55. The largest remaining error is the p70 front-right held guard, 86 against 90 (-4.44%).

The previous cutter had two distinct effects. In the p55 front-right stagger, the widest connected run in the top third of the master reached 111 pixels across the helmet and adjacent armor. The exposed dome measured 86. In the p70 front-right held painting the old scan measured the dome correctly at 388 pixels, but fitting it to the old 83% height target flattened it. At a 90-pixel dome the painting would stand 188 pixels tall. The old strip forced it to 141 against a standing height of 170.

The new cutter keeps the same four master files, facing assignments and boot anchors. At p55 one uniform scale preserves the painting. The held poses measure 75.0 to 79.5% of standing height. At p70 the accepted held paintings are too tall for the old depth with a proportional helmet. The cutter uses up to 3.5% of dome-scale latitude, then a bounded vertical factor. The strongest compression is 10%. The resulting held figures are 95.0 to 96.4% of standing height. In all ten pitch/facing combinations the first in-between, second in-between and held pose get successively lower.

## Measurements

The table compares each guard cell with the standing facing in the first five cells of its own pitch’s `rivet_frames.png`. Widths are native PNG texels. Aspect is opaque figure width divided by height. “Paint” is the same measurement on the accepted master before resizing. The before strips are from `5b46a21f1`.

The dome measurement uses the widest exposed horizontal chord above the side discs, visor and collar. The marked scan stops at a visually inspected fraction of the alpha bounding box height for each painting. Both atlas measurements use the same landmark and an alpha threshold of 128. They read the output PNG pixels independently of the cutter’s scale calculation.

| Pitch | Phase | Facing | Rest dome | Before dome | Before error | After dome | After error | Rest aspect | Paint aspect | Before aspect | After aspect |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| p70 | First | Front | 79 | 78 | -1.27% | 76 | -3.80% | 0.841 | 0.872 | 0.924 | 0.870 |
| p70 | First | Front right | 90 | 89 | -1.11% | 91 | +1.11% | 0.724 | 0.793 | 0.804 | 0.796 |
| p70 | First | Right | 91 | 92 | +1.10% | 93 | +2.20% | 0.514 | 0.554 | 0.564 | 0.557 |
| p70 | First | Back right | 93 | 93 | +0.00% | 92 | -1.08% | 0.701 | 0.707 | 0.744 | 0.707 |
| p70 | First | Back | 80 | 81 | +1.25% | 79 | -1.25% | 0.857 | 0.881 | 0.923 | 0.881 |
| p70 | Second | Front | 79 | 80 | +1.27% | 82 | +3.80% | 0.841 | 0.877 | 0.926 | 0.881 |
| p70 | Second | Front right | 90 | 90 | +0.00% | 93 | +3.33% | 0.724 | 0.746 | 0.758 | 0.727 |
| p70 | Second | Right | 91 | 91 | +0.00% | 94 | +3.30% | 0.514 | 0.637 | 0.658 | 0.632 |
| p70 | Second | Back right | 93 | 93 | +0.00% | 94 | +1.08% | 0.701 | 0.742 | 0.793 | 0.747 |
| p70 | Second | Back | 80 | 82 | +2.50% | 83 | +3.75% | 0.857 | 0.826 | 0.876 | 0.814 |
| p70 | Held | Front | 79 | 80 | +1.27% | 77 | -2.53% | 0.841 | 0.662 | 0.882 | 0.737 |
| p70 | Held | Front right | 90 | 90 | +0.00% | 86 | -4.44% | 0.724 | 0.641 | 0.851 | 0.712 |
| p70 | Held | Right | 91 | 92 | +1.10% | 88 | -3.30% | 0.514 | 0.644 | 0.826 | 0.688 |
| p70 | Held | Back right | 93 | 94 | +1.08% | 89 | -4.30% | 0.701 | 0.667 | 0.892 | 0.739 |
| p70 | Held | Back | 80 | 78 | -2.50% | 77 | -3.75% | 0.857 | 0.708 | 0.918 | 0.786 |
| p70 | Stagger | Front | 79 | 77 | -2.53% | 77 | -2.53% | 0.841 | 1.103 | 1.199 | 1.199 |
| p70 | Stagger | Front right | 90 | 82 | -8.89% | 87 | -3.33% | 0.724 | 0.996 | 1.024 | 1.090 |
| p70 | Stagger | Right | 91 | 85 | -6.59% | 88 | -3.30% | 0.514 | 0.679 | 0.697 | 0.720 |
| p70 | Stagger | Back right | 93 | 93 | +0.00% | 90 | -3.23% | 0.701 | 0.872 | 0.915 | 0.884 |
| p70 | Stagger | Back | 80 | 81 | +1.25% | 79 | -1.25% | 0.857 | 1.107 | 1.133 | 1.108 |
| p55 | First | Front | 50 | 51 | +2.00% | 50 | +0.00% | 0.667 | 0.697 | 0.654 | 0.695 |
| p55 | First | Front right | 55 | 55 | +0.00% | 55 | +0.00% | 0.565 | 0.655 | 0.600 | 0.655 |
| p55 | First | Right | 51 | 51 | +0.00% | 51 | +0.00% | 0.317 | 0.456 | 0.395 | 0.459 |
| p55 | First | Back right | 54 | 55 | +1.85% | 55 | +1.85% | 0.509 | 0.594 | 0.529 | 0.599 |
| p55 | First | Back | 49 | 51 | +4.08% | 49 | +0.00% | 0.648 | 0.728 | 0.660 | 0.729 |
| p55 | Second | Front | 50 | 51 | +2.00% | 50 | +0.00% | 0.667 | 0.792 | 0.748 | 0.788 |
| p55 | Second | Front right | 55 | 55 | +0.00% | 55 | +0.00% | 0.565 | 0.675 | 0.634 | 0.676 |
| p55 | Second | Right | 51 | 50 | -1.96% | 50 | -1.96% | 0.317 | 0.541 | 0.466 | 0.539 |
| p55 | Second | Back right | 54 | 51 | -5.56% | 53 | -1.85% | 0.509 | 0.704 | 0.600 | 0.702 |
| p55 | Second | Back | 49 | 51 | +4.08% | 49 | +0.00% | 0.648 | 0.816 | 0.741 | 0.812 |
| p55 | Held | Front | 50 | 54 | +8.00% | 50 | +0.00% | 0.667 | 0.690 | 0.674 | 0.688 |
| p55 | Held | Front right | 55 | 52 | -5.45% | 55 | +0.00% | 0.565 | 0.713 | 0.642 | 0.711 |
| p55 | Held | Right | 51 | 47 | -7.84% | 51 | +0.00% | 0.317 | 0.653 | 0.551 | 0.650 |
| p55 | Held | Back right | 54 | 50 | -7.41% | 54 | +0.00% | 0.509 | 0.676 | 0.575 | 0.680 |
| p55 | Held | Back | 49 | 50 | +2.04% | 50 | +2.04% | 0.648 | 0.712 | 0.674 | 0.713 |
| p55 | Stagger | Front | 50 | 47 | -6.00% | 50 | +0.00% | 0.667 | 1.023 | 0.917 | 1.028 |
| p55 | Stagger | Front right | 55 | 43 | -21.82% | 55 | +0.00% | 0.565 | 1.027 | 0.715 | 1.028 |
| p55 | Stagger | Right | 51 | 43 | -15.69% | 52 | +1.96% | 0.317 | 0.706 | 0.472 | 0.700 |
| p55 | Stagger | Back right | 54 | 51 | -5.56% | 54 | +0.00% | 0.509 | 0.990 | 0.722 | 0.992 |
| p55 | Stagger | Back | 49 | 55 | +12.24% | 48 | -2.04% | 0.648 | 1.120 | 0.910 | 1.114 |

## Reproduction

All 40 cells retain the boot line of the corresponding standing facing. A second cut from the four masters produced byte-identical PNGs. The p70 strip SHA-256 is `a32c9da7a49f4abbb170d7085d8fa618ef06b2986636bbdc6d073fbadd73496a`. The p55 strip is `7ab867ed68da45d1cf96be618051109e169de526e9bc2ccf342f8677a994655c`. SciPy reported a NumPy version warning during both cuts.

Run the cutter and import from the controls worktree with the lane environment from the common brief.

```powershell
python -B tools/art/rivet_guard.py C:/Users/kazda/kiro/gtai-masters/n23/controls/masters
& $env:GODOT_BIN --headless --path project --import
```

To repeat the table, divide each guard strip into 20 equal cells and the standing strip into 14. For each cell, crop to the bounding box of pixels with alpha above 128. Scan rows zero through the rounded product of the cropped height and its `CROWN_END` percentage, inclusive. Take the maximum distance from the leftmost to the rightmost qualifying pixel, counting both ends. The error is 100 times the guard-to-standing width ratio minus 100. Compare the current guard PNGs to the same two paths at `5b46a21f1`.

The captures use the same 640 x 360 viewport and the original inspection crops. Run the following once for each combination of `$viewId` (`tilt70` for p70 or `tilt` for p55) and `$ppm` (32 or 64), with a separate absolute output directory for each take.

```powershell
& $env:GODOT_BIN --path project --windowed --rendering-driver d3d12 --position 0,1440 --audio-driver Dummy --fixed-fps 60 res://dev/controls/guard_pose_film.tscn -- "--out=$directory" "--ppm=$ppm" "--view=$viewId"
```

## Verification

The headless import completed. Both `.import` files already tracked the correct texture settings and UIDs. `node tools/tests/run_unit.mjs --changed` reported 3,650 passed, zero failed and two skipped. `node tools/tests/run_unit.mjs --select=test_guard_view` reported five passed, zero failed and zero skipped.

`node tools/tests/run_scenarios.mjs --only=replay_60s,quest1_input,rivet_deflect` reported three passed. All three serialized replay files matched the captures from before Part A byte for byte.

| Scenario | Final state digest | SHA-256 of the identical tape |
|---|---|---|
| `replay_60s` | `cbeb734ff9b97c41645f735114692ea3b9e7cc6578750f32d8d9f31d69844e85` | `73e204a23a6b82a9fcc2cfcf0bc2f025e647b1a0001c86df9499099510d318ed` |
| `quest1_input` | `37bf8deacaad2f480055af695e77aa9296bb08c4f6b681c57344832333d4664a` | `20561e3c8181bf05eca4cc61610fe651bd139399d196ac2f7f24dfcbb4a2391a` |
| `rivet_deflect` | `4352a44470140d68f6ba237fb842cfb9745b557caefca284a81da77f039fd7ae` | `e733e3db2a689694c3a482f4110a9f2870b0b23032214c1d51e76108372a26b4` |

## Stills

The three stills and their original `_b4.png` counterparts are in `C:/Users/kazda/kiro/gtai-masters/n23/controls/`. I inspected all 52 source frames from the four final takes, then the three assembled sheets. The guard rises without a spark in each take. All four runs broke guard at tick 646 and produced the same stage tape, `22552211ab0e4ce2656bf9bf62c21031ee622e8b30b135168092f2728e821cba`. The renderer logged shutdown resource leaks and warnings about other art. Each capture exited successfully with 13 PNGs.

| Still | Contents | SHA-256 |
|---|---|---|
| `guard_phases_64.png` | Front-right at 70°, ticks 59, 60, 63, 66 and 678 | `81684cc6c7f46d11689a7ab6fd5ee760002e66d43f4e446fdce39563e91d54c6` |
| `guard_pose_32.png` | Held guard at gameplay zoom, all eight directions at both pitches | `bb4347570a9b88077f750d6fef371c49645d377f37ca3cc30f4e55f90595d44f` |
| `guard_pose_64.png` | Same poses and matched ticks at double zoom | `00e68b696c3e76ae06e514b6c1c83e021762d0f6f3f33ba1291b8bc8e0141df9` |
