# Rivet's feet before the motion change

Five of the seven requested loadouts held one equipped drawing through all 144 moving ticks at both zooms. Their boots stayed together as the metre marks passed. Wheel slot 0 selected `hands`, stowed the arena weapon and published `""` to the rig. Its feet alternated in profile and three-quarter view.

All nonempty grid paths below are relative to `res://features/characters/art/view/p70/`. Tick 40 starts the recorded take. The walk is 2.4 m/s, just below the 2.5 m/s run threshold, and the run is 3.2 m/s. Each take uses the wheel, arena rig feed, held view and guard view. Nothing fires. The floor tracks world metres. Left and right columns are walk and run, upper and lower rows are right profile and three-quarter toward.

| Wheel selection | Walk grid | Run grid | Slides on a still card? | What the frames show |
|---|---|---|---|---|
| hands | `rivet_walk8.png` | `rivet_run8.png` | No | Empty held ID. The profile boot passes the other boot. The run extends into flight. |
| pistol | `rivet_walk_eq_pistol.png` | `rivet_run8_eq_pistol.png` | No | Four walk columns and eight run columns. The pistol moves with the painted arm. |
| gloria | `""` | `""` | Yes | The blocky gun and both boots bob as one figure on the Gloria facing card. |
| rocket_launcher | `""` | `""` | Yes | The tube is distinct, but the boot outlines keep the same separation. |
| assault-rifle | `""` | `""` | Yes | The equipped art resolves to `assault_rifle`. The magazine and feet keep the same pose. |
| chainsaw | `""` | `""` | Yes | The saw and feet stay on one equipped cell in each direction. |
| electro_baton | `""` | `""` | Yes | The baton extends below the profile hand. The narrow boot silhouette never steps. |

The five missing pairs all take the same branch. `RivetWalk.path_of` probes a filename made from the held ID and returns `""` when the file is absent. `RivetFrames.step` then uses the equipped facing card. The two pitches each ship five armed grid pairs, for pistol, plasma rifle, katana, Gatling and flamethrower.

## Sole travel

Measured from the right-profile PNGs with `tools/film/foot_slide.py`. For an animated grid the numbers are mean absolute net stance drift, in centimetres from contact to release. A still has no contact or release transition. For those rows the numbers instead track one boot against the world ruler over ticks 60–120, in metres. The baton's low tip enters the lowest-five-percent mask and makes that boot estimate unreliable.

| Selection | Metric | 32 px/m walk / run | 64 px/m walk / run |
|---|---|---:|---:|
| hands | stance drift, cm | 1.5 / 4.8 | 1.1 / 5.3 |
| pistol | stance drift, cm | 0.6 / 5.3 | 0.3 / 5.7 |
| gloria | one-second drift, m | 2.39 / 3.19 | 2.40 / 3.19 |
| rocket_launcher | one-second drift, m | 2.39 / 3.17 | 2.41 / 3.17 |
| assault-rifle | one-second drift, m | 2.39 / 3.17 | 2.40 / 3.17 |
| chainsaw | one-second drift, m | 2.41 / 3.19 | 2.41 / 3.17 |
| electro_baton | visual only | fixed boots | fixed boots |

There is a second, smaller source of apparent sliding on hands. At 3.2 m/s the run drawing holds for 13–14 ticks while the ground moves under it. At 64 px/m the mean within-drawing excursion was 67.1 cm, even though the next stance drawings brought mean net drift down to 5.3 cm. The wheel ID and the run-grid selection both worked.

The [32 px/m film](C:/Users/kazda/kiro/gtai-masters/n24/motion/before/legs_32.mp4) contains all eleven loadouts, including the other four original armed grids for the control comparison. FFprobe counted 1,584 H.264 frames, 1920 × 1080, 60/1 fps, 26.4 seconds. Native-scale strips, individual frames, selected paths and per-tick columns are in the [baseline directory](C:/Users/kazda/kiro/gtai-masters/n24/motion/before/). The movie labels its enlarged inspection panel separately.

The [capture source](C:/Users/kazda/kiro/gtai-masters/n24/motion/capture-source/) can be copied into `project/dev/motion/` for a repeat take. Import once, then run the `legs_film` dev scene at fixed 60 fps, D3D12, window position 0,1440, with `--controls=wheel --out=<absolute directory> --ppm=32` and again with `--ppm=64`. The adjacent `assemble.py` builds strips and a movie and runs the sole measurements from the worktree root.
