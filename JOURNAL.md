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
- MILESTONE look goldens re-blessed (junction 11 + block 5): the evidence selftest failed d4@64, d5@48/64, auto@56/64 and
  block auto@64-night, all from the cop blue + Rivet scale (crowd and street unchanged in the A/B). look_golden --bless,
  then a check run: bit-identical (mean 0.00 on all 11). Lint/unit/scenarios/parity green (evidence run, --no-bench).
- MILESTONE item 5 King on the cutout rig: KingPlan (Rivet's rig, art_dir king, size_k 1.2, no hose). 1 Codex image
  (masters king/gen/out/king_parts_1.png, 121 s, layout held on the first try), sliced with Rivet's alpha, megaphone keyed
  wider. Frames: evidence/king/king-{32,64,128}ppm.png (dev scene, D5 tier on). Unit test: every King part exists.
  Codex images used today: 1 of ~25.
- MILESTONE Rivet scale tuned 1.0 -> 1.1 after a same-scene lineup (king_showcase --rivet-form=night|base): at 1.0 his
  body read cop-sized or smaller (cops' torsos are wide). 1.1/0.85: bbox 1.97x2.37 m. King 1.2 -> 1.3 (boss stays bigger).
  Goldens re-blessed again (check run mean 0.00). Unit 326/326, lint green.
- A/B cop shoulders: B (navy ball + small blue-hi core) tried and NOT shipped: bright px at 32 fell 197 -> 75; A kept,
  B offered to the owner (frames + masters recolor_cops.shoulder_marks()).
- FIX teal leak: the brightest cop_blue_hi shoulder pixels passed the teal gate (printed soul-teal on cops at 128 px/m).
  Teal now also needs b - g < 40/255 in print_part and look_d5_part (cop teal 512 px -> 0; Rivet loses 9 of 736 edge px).
  King's parts: teal-ish and green-spill pixels greyed (King carries no teal); provenance rows re-hashed. Look goldens
  still pass unblessed (max mean 0.007).

## Status at ~10:50 (iteration 1)
- Items 1-5 all landed and evidenced; 10 commits on d-cast (089400e..HEAD). Paths moved: raw renders now in
  masters:day-d5/d5-cast/renders/ (130 MB, outside git); owner frames: masters:day-d5/d5-cast/frames.json (15) + ladder.png;
  gate numbers: evidence/d5-cast/*.json (committed). The early "evidence/rivet-scale-ab-*" paths above are superseded.
- Final Rivet: RivetPlan FORMS base = (size_k 1.1, guard_k 0.85); night = (1.3, 1.0). King: KingPlan size_k 1.3.
- Codex images used: 1 (King parts). Portraits and cops are deterministic recolours (masters recolor_cops.py), so the
  "great" D5 style is kept exactly.
- Bench NOT run (no cost-bearing change: colours, a scale factor and a dev-only King). Unmeasured, not zero.
- Shared files touched: assets/shaders/look_d5_part.gdshader (cop-blue plate + teal gate), steam/ai-provenance/2026-11.jsonl.
- OPEN for the owner: (1) cop shoulders A (shipped) vs B (navy + small core); (2) King's portrait cape is vermilion;
  (3) in-game cruisers show the blue light bar as grey until REQUEST 1 lands.
- REQUEST 2 -> d5-city: look_d4_item's cop-blue plate should also exclude a bright cop blue from its teal test if it has
  one (here teal needed b - g < 40/255 so cop_blue_hi #4F86E0 highlights never print soul-teal).

NEXT:
- Owner pick on the cop shoulders (A/B); if B, run recolor_cops.shoulder_marks(art, 0.5), re-import, re-bless the goldens.
- After d5-city's look_d4 cop-blue plate merges: re-shoot city_frame with --police=4 and check the cruiser light bar is blue.
- King into the game: a BodyPlan.Kind or a pool entry + feed row when the boss fight ticket lands; KingPlan is ready.
- The bulky ghost form: a new RivetPlan.FORMS row (no rig code); the souls stay behind --souls until a mechanic uses them.
- Optional: King D5 expressions/portrait check vs the rig; Rivet portrait busts are scale-free (checked).
- EVIDENCE (clean tree, HEAD 1586b06): lint, unit 326/326, scenarios 8/8, parity 1200 steps exact, selftest look goldens 11/11 PASS (--no-bench; bench not run).
- A/B/C cop shoulders: C (core 0.75 of the ball) also rejected: blue-hi px at 32 = 91 vs A 197, and at 64 it looks like A. A stays.
- FIX missed vermilion on cops: the end-on shoulder cell (upperarm_endon, shown when the arm foreshortens: the riot
  shield arm) was still 57-62% vermilion in both tiers -> cop_blue_hi like the shoulder ball; all other cop parts' red
  flecks (D5 rust on shield/pelvis/forearms, D4 edge tint) -> their grey value. Cop vermilion px now 0 in D4 and D5
  (gate r - max(g,b) > 40). Found by looking at the noir A/B junction frame (d4 side). Noir still switches (ink masses,
  no blue leak). Goldens re-blessed (the check passed unblessed at mean <= 0.027). Unit 326/326.
