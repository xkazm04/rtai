# n-d4 iteration 10 evidence (night lane d4-production)

- `night_iter10_summary.png`: before | after | target crop, same deterministic scenes through look_d4 (city_frame
  seed 91 for the paving rows, the render selftest for the junction rows, the asset board for the kerb corner).
  The last row is a REJECTED probe (paper grain on the paving), not shipped.
- Shipped: pavement joints inked (3ebf21a; 3 px of 64 grey on curb x3, curb corner; the plaza tile inks only its 4 m joints, a1874f7), junction zebras
  redrawn (5b3ce9c, then 95d22f1: 9 clean thin stripes a side, no corner glyphs, no ink wear pepper).
- `gates-c4dfe4a.txt`, `gates-123e170.txt`, `gates-cc9633c.txt` (final, incl. the plaza): `node tools/evidence/run.mjs --no-bench`, all PASS.
- Full frame sets: `gtai-masters/night/d4-production/{before,after}_pj`, `{before,after}_pjc`, `zb_{before,z6,z7,z9}`,
  `probe_pj64w2|64w3`, `probe_pgc`; ladder rows "i10 ...".
- `generator_art_pick_v2.patch` (SUPERSEDES `evidence/iter8/generator_art_pick.patch`): the iteration-8 art pick
  (generic roofs, upright lettered roofs + warehouse, plaza quarter turns) plus road / kerb variants as an a-b-c
  cycle per street line from a random offset, so neighbouring tiles never share a variant (the random pick put the
  same hatched kerb crack on two neighbouring tiles: `before_v3|after_v3/city-0-64ppm.png`). New AST-12 golden list
  included. Applies on main, n-d4 and n-visual; lint 13/13, unit 142/142 with it applied on n-d4.
- REQUEST 18 (traffic wiring patches in `evidence/iter8/`) is SUPERSEDED: n-visual wired the traffic atlas itself
  (7bfb6b9); the iteration-8 wiring patches no longer apply there and are not needed.
- `rig_variant_new_looks.patch` (characters code, for the characters owner): crowd slot 3 jacket-hat -> hoodie-cap
  (`head_cap`, `torso_hoodie`), slot 7 coat-hair -> overalls-bald (`head_bald`, `torso_overalls`), so the 5 ped parts
  n-d4 shipped in iteration 1 are finally seen (the runtime crowd baker picks them up; no prewarm warnings).
  `before_rv|after_rv/city-*-{32,48,64}ppm.png`, `work/rv_zoom48.png`. Lint 13/13, unit 142/142, scenarios 8/8 with it
  applied. Needs n-d4 merged first (the parts live in n-d4); applies on main and n-visual.
