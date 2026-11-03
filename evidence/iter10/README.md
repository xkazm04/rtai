# n-d4 iteration 10 evidence (night lane d4-production)

- `night_iter10_summary.png`: before | after | target crop, same deterministic scenes through look_d4 (city_frame
  seed 91 for the paving rows, the render selftest for the junction rows, the asset board for the kerb corner).
  The last row is a REJECTED probe (paper grain on the paving), not shipped.
- Shipped: pavement joints inked (3ebf21a; 3 px of 64 grey on sidewalk, curb x3, curb corner), junction zebras
  redrawn (5b3ce9c, then 95d22f1: 9 clean thin stripes a side, no corner glyphs, no ink wear pepper).
- `gates-*.txt`: `node tools/evidence/run.mjs --no-bench`, all PASS.
- Full frame sets: `gtai-masters/night/d4-production/{before,after}_pj`, `{before,after}_pjc`, `zb_{before,z6,z7,z9}`,
  `probe_pj64w2|64w3`, `probe_pgc`; ladder rows "i10 ...".
