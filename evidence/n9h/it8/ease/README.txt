n9-handheld it8: the boss cam ease (CamFollow). Deck row, 40 px/m, --view=combo, 2700 ticks, sim.mjs, CONTENDED.
camp-<boss>-<accel>.txt = a temporary Log line in BossCam._process (not committed): tick, framed x y (m), eased x y (m), m per screen px.
  The framed columns ARE the no-ease camera (the view never writes the sim; same ticks).
sweep.py <camp> = the recorded framing replayed through CamFollow's law at several limits (sweep-king.txt, sweep-servo.txt);
  it reproduces the in-game 2.0 run (lag 42.4 px, peak 15.9).
king-pancorr.txt = whole-frame phase correlation (it7's pancorr.py) of the no-ease and 2.0 clips: frames 707 / 1265 identical
  in both -> not the camera. Ground band alone (y 420-620): -1..+1 px a frame at both (it8 JOURNAL 07:0x); the top band
  (the King's car, the telegraph wedge) carries the 20 / 8 px.
<run>.json = sim.mjs summaries (frame times, CPU, RAM). The per-frame .frames.json logs are not committed (size).
