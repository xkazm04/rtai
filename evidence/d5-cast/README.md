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
