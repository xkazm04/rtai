# d5-cast evidence (2026-11-03)

The gate numbers live here; the frames (15, labelled) are in
`gtai-masters/day-d5/d5-cast/frames.json` (+ `ladder.png`, `frames/`), the raw renders in
`gtai-masters/day-d5/d5-cast/renders/` (130 MB, outside git). Rebuild the frames with
`python -I gtai-masters/day-d5/d5-cast/build_frames.py <that renders dir>`.

- `rivet-footprint.json`: `dev/bench/rig_footprint.gd` (headless): plan-view bbox of each body plan in
  its idle guard. Night Rivet was 2.50 x 2.62 m (size_k 1.3); now 1.97 x 2.37 m (1.1, guard 0.85).
- `cop-gate.json`: the 32 / 48 px/m cop-vs-ped gate in the real city riot (`city_frame.tscn`):
  blue / vermilion blobs per frame and dE76 of the police inks against the ped ink and the asphalt.
- `cop-shoulder-ab.json`: shoulder option A (shipped: blue-hi balls) vs B (navy + small core).

Frames sources: `dev/showcase/city_frame.tscn` (real World + CityView, seed 91), `d5_hero.gd`
(H2 scene; souls now off), `king_showcase.gd [--rivet-form=night]` (lineup + King on the rig).

Iteration 3 (2026-11-03, 11:00-11:35):
- `cop-helmet-t1.json`, `cop-cap-t1.json`: T1's cream cop heads (riot helmet, patrol cap), same-scene A/B numbers.
- `cop-gate.json` `t1heads/*`: the city gate re-measured with the cream heads (every cop still a blue blob).
- `cruiser-atlas-print.json`: the moving cruiser's light bar (traffic atlas cell 8) through each item shader:
  d-cast alone -> teal, merged with d-city -> cop blue. Merge d-city before or with d-cast.
- `cruiser-world-print.json`: parked cruisers through the look_d4 world pass print ~37 % teal (d5-city REQUEST 3).
