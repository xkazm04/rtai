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
- `cruiser-world-print.json`: parked cruisers through the look_d4 world pass: grey in the real game (profiles' world teal = 0);
  ~37 % teal only under the shader's default teal uniform (dev scenes such as the D5 hero). See its CORRECTION.
- `cop-rim-t1.json`: iteration 4, T1's thick ink ring around the D4 cop dome (real city A/B at 32/48: ink px in the cop zones up, blue px and blobs unchanged).
- `cruiser-parked-plate.json`: iteration 4, the proposed look_d4 cop-blue plate (d5-city's shader; patch in masters) proven on a merged scratch tree: a parked cruiser's bar grey -> cop blue at 48/64, goldens unaffected by the patch.
- `rivet-footprint.json`: iteration 5 adds Rivet's T2 hunch (1.90 x 2.05 m) and King; 15:55 adds the King size
  option (1.2 = 2.15 x 2.62 m vs shipped 1.3 = 2.33 x 2.84 m; `king_showcase --king-size`).

Late afternoon (15:40-17:00): the D5 hero scene's borrowed cruiser bar in cop navy (masters
`day-d5/d5-cast/borrowed/`, `d5_hero --borrow=<dir>`; frames `cruiser-hero-navybar-ab.png`); a CONTENDED headless
rig bench (`build/evidence/rig-bench-*.json`, git-ignored; numbers in JOURNAL.md).
