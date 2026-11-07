# bench-it16 (n8 vehicles, 2026-11-07 03:13)

`RTAI-bench.exe -- --scenario=drive_dense --secs=30 --zoom=<1.0|1.5> --vsync=disabled --view=<top|tilt70>`,
release export `windows-bench` of f09f4456, bench.lock held, 2 runs per cell alternated.

CAUTION: `dev/bench/city_bench` builds no `VehicleView`: the cars are the city crowd's flat atlas layer in
both views. These numbers measure the angled view's cost on the drive WITHOUT the traffic cards. They are
not a measure of the cards (see JOURNAL.md, CORRECTION 03:26).
