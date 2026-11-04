# rivet-arsenal feel numbers (live game paths, 2026-11-04 night, iteration 1)

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
| Turn rate, stop distance | unchanged from the evening (TopDownMover under PlayerMotion): 180-degree turn 250 ms walk / 550 ms sprint; stop 0.22 m walk / 0.43 m sprint | docs/eve/2026-11-03/rivet-motion/REPORT.md section 5; not re-measured live this iteration |
