# n-d4 iteration 10 evidence (night lane d4-production)

- `night_iter10_summary.png`: before | after | target crop, same deterministic scenes through look_d4 (city_frame
  seed 91 for the paving rows, the render selftest for the junction rows, the asset board for the kerb corner).
  The last row is a REJECTED probe (paper grain on the paving), not shipped.
- Shipped: pavement joints inked (3ebf21a; 3 px of 64 grey on sidewalk, curb x3, curb corner), junction zebras
  redrawn (5b3ce9c, then 95d22f1: 9 clean thin stripes a side, no corner glyphs, no ink wear pepper).
- `gates-*.txt`: `node tools/evidence/run.mjs --no-bench`, all PASS.
- Full frame sets: `gtai-masters/night/d4-production/{before,after}_pj`, `{before,after}_pjc`, `zb_{before,z6,z7,z9}`,
  `probe_pj64w2|64w3`, `probe_pgc`; ladder rows "i10 ...".
- `generator_art_pick_v2.patch` (SUPERSEDES `evidence/iter8/generator_art_pick.patch`): the iteration-8 art pick
  (generic roofs, upright lettered roofs + warehouse, plaza quarter turns) plus road / kerb variants as an a-b-c
  cycle per street line from a random offset, so neighbouring tiles never share a variant (the random pick put the
  same hatched kerb crack on two neighbouring tiles: `before_v3|after_v3/city-0-64ppm.png`). New AST-12 golden list
  included. Applies on main, n-d4 and n-visual; lint 13/13, unit 142/142 with it applied on n-d4.
- REQUEST 18 (traffic wiring patches in `evidence/iter8/`) is SUPERSEDED: n-visual wired the traffic atlas itself
  (7bfb6b9); the iteration-8 wiring patches no longer apply there and are not needed.
