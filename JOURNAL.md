# JOURNAL d5-cast (branch d-cast)

## 2026-11-03 iteration 1 (BUILD)
- 10:05 start. Read brief, git log. Native DLLs present (417 KB, not LFS pointers).
- MILESTONE item 1 Rivet scale: measured with the new headless `dev/bench/rig_footprint.gd`:
  before rivet 2.50x2.62 m (size_k 1.3), cop 1.27x1.88, ped 0.69x1.34. The mass = arms in a wide guard.
  Applied RivetPlan FORMS hook: base = (size_k 1.0, guard_k 0.85) -> 1.79x2.15 m. Sim radius untouched
  (0.6 vs human 0.45), so no golden re-bless. Tried 0.95/0.9 (1.75x2.01): reads cop-sized at 32, claw mush; rejected.
  Frames: evidence/rivet-scale-ab-{32,48,64,128}ppm.png (city_frame, the real World+CityView, focus 0).
- MILESTONE item 3 soul trail: only lived in dev D5 hero (D5HeroExtras). Off by default, `--souls` shows it.
- MILESTONE item 2 cops in blue: art recoloured D4 + D5 (torso jacket navy, shoulder balls blue-hi, cap/helmet navy + badge),
  print_part + look_d5_part gain a cop-blue plate, cop head_swap 4 removed, cruiser light bar blue in intact/d1/d2.
  Gate: evidence/cop-gate.json. Frames: evidence/cops1 (city_frame), evidence/hero1 (D5 hero scene, souls off).
- SHARED FILE: project/assets/shaders/look_d5_part.gdshader (n-d5's D5 parts print; only parts use it): + cop-blue branch.
- REQUEST 1 -> d5-city: look_d4.gdshader (world pass) needs a cop_blue plate like your look_d4_item one; parked
  police cruisers draw on the world layer and their new blue light bar prints grey there. Token values I hard-coded
  in print_part / look_d5_part: cop_blue #3A4766, cop_blue_hi #4F86E0 (from your uncommitted palette.json).
- MILESTONE item 4 cop portraits: the 5 cop portraits recoloured (vermilion armour -> lifted cop navy #415D91, style
  untouched, glints kept). 0 Codex images used: a recolour keeps the "great" D5 portraits exactly. evidence/portraits-cop-ab.png.
  Rivet/King portraits: busts, no scale issue. QUESTION for owner: King's portrait cape is vermilion (doctrine: vermilion =
  danger/objectives/collar); left as is.
