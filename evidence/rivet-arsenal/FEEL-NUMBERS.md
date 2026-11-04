# rivet-arsenal feel numbers (live game paths, 2026-11-04 night, iterations 1 and 6)

All on the CONTENDED machine (six lanes). Sim numbers are 60 Hz tick-true.

| Number | Value | How |
|---|---|---|
| Input -> sim move, windowed d3d12 vsync 60 fps | 2 frames, 27-34 ms (12 trials, median about 33 ms) | `latency-window-d3d12.json`, `dev/rivet_arsenal/latency_probe_main.gd`: InputEventAction move_right injected through Input.parse_input_event in the live arena; counted to the frame whose sim step moves Rivet (that frame poses and draws him) |
| Same, headless uncapped (128 fps) | 2-4 frames, 14-31 ms | `latency-headless.json` |
| Display (swapchain + monitor) on top | UNMEASURED | needs a camera or a present-timestamp probe |
| Sim input latency | 0 ticks | arena telemetry `input_latency_ticks` all 0: Rivet moves on the tick the input is sampled |
| Sprint top speed | 6.20 m/s (walk stays < 5.0) | scenario_rivet_claw telemetry, test_live_melee |
| Claw combo cadence (mash) | finisher lands on tick 31 after the first press = 517 ms | test_live_melee `test_combo_cadence_is_the_tables` (exact) |
| Claw hits landed in the live arena run | 7/7, 3 kills, 0 whiffs | `rivet-claw-telemetry.json` |
| Draw time per grip class | one_hand 12 t (200 ms), two_hand_long 20 (333), shoulder 30 (500), backpack_hose 18 (300), thrown 8 (133), heavy_two_hand 26 (433) | rivet_arsenal.json, test_weapon_hold (exact) |
| Switch pistol -> rocket launcher | 8 + 30 = 38 ticks (633 ms) | test_weapon_hold |
| Walk (live pilot) | top 4.50 m/s, 90 % in 9 ticks (150 ms), stop 0.22 m in 6 ticks (100 ms), reversal 10 ticks (167 ms) | `feel-live.json` (iteration 6): RivetFeel drives StagePilot on a CollectCallStage (the pilot quest 1, the arena and the city block share), `dev/rivet_arsenal/feel_main.gd`; test_live_feel (planted near-zero brake never stops) |
| Sprint (live pilot) | top 6.20 m/s, 90 % in 21 ticks (350 ms), stop 0.43 m in 9 ticks (150 ms), reversal 24 ticks (400 ms: the sprint drops out when the stick leaves the facing) | same |
| Aim turn 180 degrees (live pilot) | 15 ticks = 250 ms (turn_dps 720, to within 5 degrees) | same; arena telemetry `turn_rate_peak_dps` 720 in every live run |
