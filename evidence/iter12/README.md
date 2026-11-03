# n-d4 iteration 12 evidence (night lane d4-production)

- `night_iter12_summary.png`: before | after | target crop, same deterministic scenes through look_d4 (the asset
  board `--page=decals` / `--page=props`, `city_frame` seed 91 with the dev HUD overlay at UI 0.5). The last row is
  a REJECTED probe (skid marks redraw), not shipped.
- Shipped:
  - `tank_tracks` decal redrawn as a crisp ink chevron imprint, two 0.6 m bands 2.5 m apart, faded ends (7f517e6).
    Procedural, no AI image; same 480 x 280 and id 64.
  - `bollard` prop reads as a capped post (thin ink cap ring) instead of a plain coin at 48-64 px/m (72301db). A small
    gain; about level at 32 px/m.
  - `features/hud/art/hud_digits.png`: a hand-inked numeral strip (`0123456789$/x+-:`) in the world's sign-painter
    caps, Codex `d4n_digits` (1 image, 0 rejected). The dev HUD overlay draws its counters from it instead of the
    default sans (36ce71b). The HUD README documents the cells and advances. Words still need a font (owner, AST-10).
- `gates-31a948f.txt`: `node tools/evidence/run.mjs --no-bench`, all PASS.
- Merged check (scratch worktree, n-visual 928ed15 + n-d4 31a948f, `merge --no-commit`): only JOURNAL.md conflicts;
  unit tests there 214 passed, 0 failed (n-visual suite incl. the accent audit); frames
  `masters:night/d4-production/merged_i12/city-*-{32,48,64}ppm(-hud50).png`, `merged_i12_dec/decals-*`.
- Full frame sets: `gtai-masters/night/d4-production/{before,after}_i12d(_c)`, `{before,after}_i12b(2)`,
  `{before,after}_i12h(2)`, `{before,probe}_i12s_city`; ladder rows "i12 ...".
