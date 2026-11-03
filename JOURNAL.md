# JOURNAL d5-cast (branch d-cast)

## 2026-11-03 iteration 1 (BUILD)
- 10:05 start. Read brief, git log. Native DLLs present (417 KB, not LFS pointers).
- MILESTONE item 1 Rivet scale: measured with the new headless `dev/bench/rig_footprint.gd`:
  before rivet 2.50x2.62 m (size_k 1.3), cop 1.27x1.88, ped 0.69x1.34. The mass = arms in a wide guard.
  Applied RivetPlan FORMS hook: base = (size_k 1.0, guard_k 0.85) -> 1.79x2.15 m. Sim radius untouched
  (0.6 vs human 0.45), so no golden re-bless. Tried 0.95/0.9 (1.75x2.01): reads cop-sized at 32, claw mush; rejected.
  Frames: evidence/rivet-scale-ab-{32,48,64,128}ppm.png (city_frame, the real World+CityView, focus 0).
- MILESTONE item 3 soul trail: only lived in dev D5 hero (D5HeroExtras). Off by default, `--souls` shows it.
