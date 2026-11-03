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
- EVIDENCE final (clean tree, HEAD 1848411, 11:0x): lint, unit 326/326, scenarios 8/8, parity exact, selftest goldens PASS (--no-bench). Owner frames rebuilt from the final renders (15, masters frames.json + ladder.png).

## 2026-11-03 iteration 3 (BUILD, 11:01-12:31)
- 11:01 start. Items 1-5 evidenced; this iteration raises the weakest. Checked integration with d5-city (d-city f0cedb3):
  its look_d4_item tests cop blue BEFORE the nearest-teal fallback, so cop_blue_hi never prints teal there: my REQUEST 2
  is moot. REQUEST 1 (look_d4 world pass cop-blue plate for parked cruisers) still open on d-city. The crowd atlas is
  baked at run time from the rig, so it inherits the blue cops (d5-city's "29.3k/24.7k vermilion texels" are main's).
- MILESTONE portraits to the doctrine: iteration 1's #415D91 lift (x1.7 highlights) read royal blue (mean 63,90,140, chroma
  77). Now a navy ramp: shadows -> ink, median on #3D5078, highlights -> pale slate (mean 60,77,114, chroma 54). And the
  leftover vermilion specks (123-780 px per portrait, rl > 40) greyed: 0 vermilion px left. A first speck gate (rl > 25)
  caught 24k px of warm paper/ink greys per portrait: rejected, never shipped. Dialogue frame re-shot (d5_hero
  --dialogue=rivet,cop_shouting): panel armour (62,88,137) -> (60,76,112), vermilion 95 -> 0. Provenance re-hashed.
  Frames: masters frames/portraits-cop-ab.png (top orig, bottom now) + portraits-cop-3way.png (orig | iter1 | now).
- MILESTONE riot cop helmet to T1: T1's cops (zoomed crop) are dark figures with a big CREAM helmet dome, cream hands and a
  cream sticker rim, with no orange on them at all. Ours had a navy dome + cream stripe. Now inverted (recolor_cops.t1_helmet,
  both tiers, from orig): cream dome in its ink rim, the stripe in cop navy, the D5 scratches as darker hatch. Patrol cap
  unchanged (navy + cop_blue_hi badge), so riot (pale dome) and patrol (navy cap) now read apart. Same-scene A/B
  (d5_hero --borrow, hero1 vs heroHelmB): the ONLY changed region at 32/48/64/128 is the riot helmet; helmet luma
  107 -> 168, 0 vermilion. evidence/d5-cast/cop-helmet-t1.json. Look goldens pass unblessed (11/11 worst 0.47,
  block 5/5 worst 0.20), so no re-bless (less merge churn with d-city's goldens).
  The real-city city_frame A/B (helmA/helmB, --police=4) showed NO helmet change: the riot cops there are atlas cells
  with the shield over the head at 32, and the run differs by a few crowd-sim pixels between runs (one cop -> ped cell;
  not this change). Rejected as evidence for this item (0 helmets visible); the hero A/B is the proof.
- FOUND + FIXED: moving police cruisers still had a VERMILION light bar in the real game (city_frame city-2 at 128 px/m).
  Moving traffic draws from traffic_atlas*.png cell 8, not police_cruiser*.png, and iteration 1 only recoloured the sprites.
  Cell 8 recoloured in all four atlases (intact, d1, d2, hijack; recolor_cops.atlas_cells(), originals in masters
  orig/vehicles_atlas/): 1179-1306 px each, 0 px outside cell 8, 0 vermilion left. cruiser_wreck / car_wreck: 0 vermilion.
  CAVEAT on this branch alone: main's look_d4_item has no blue plate, so a moving cruiser's blue bar prints as nearest-ink
  TEAL here; d-city's look_d4_item (f0cedb3) adds the cop-blue plate. MERGE ORDER: d-city with d-cast (trial merge below).
- TRIAL MERGE d-cast (40d1e40) + d-city (f0cedb3) in a scratch worktree (gtai-wt/scratch-cast-merge, detached, never
  pushed): conflicts ONLY in JOURNAL.md and the 16 look goldens (both lanes re-blessed); all code/art merges clean.
  city_frame --police=4 on the merged tree = the d-cast frames (accent counts within a few px; blue cops intact).
  No moving cruiser came on screen in any run (riot frames; traffic timing differs per run), so the print was proven
  numerically: evidence/d5-cast/cruiser-atlas-print.json replays each item shader's rules on the 1262 cell-8 light-bar px:
  d-cast alone (main look_d4_item) -> 1159 TEAL; merged (d-city look_d4_item) -> 1159 cop_blue_hi + 103 cop_blue.
  MERGE NOTE for the Director: merge d-city before (or with) d-cast; d-cast alone prints moving cruisers' bars soul-teal.
  Goldens after the merge: take either side, then re-bless once on the merged tree (look_golden --bless).
- Merged tree (scratch d-cast + d-city): lint green, unit 336/336.
- FOUND: parked cruisers (world layer, look_d4 world pass) print their cop_blue_hi light bar with a mean 37 % SOUL-TEAL plate
  (663-870 px past half coverage per state): plates() teal density = (min(g,b) - r - 0.08) * 2.8 and cop_blue_hi has
  g - r = 0.215. Same on main and d-city f0cedb3 (d-city added blue to look_d4_item only). evidence/d5-cast/cruiser-world-print.json.
- REQUEST 3 -> d5-city (supersedes REQUEST 1): look_d4.gdshader plates(): (a) exclude blue from the teal density, e.g.
  multiply t by step(c.b - c.g, 0.157) (teal has b ~ g; cop_blue_hi has b - g = 0.35), and (b) add a cop-blue plate
  (b - max(r, g) >= blue_gate) like look_d4_item's, so parked cruisers' bars print cop_blue_hi, not grey/teal.
  Until then the parked cruisers are the one place blue cop art prints off-doctrine. Not changed here: shared shader.
- MILESTONE patrol cap to T1 too: in T1 BOTH cops (baton and pistol) wear the cream dome; our patrol cap (the majority of
  city cops) was a navy dome merging into the navy body. Now cream crown, cop-navy band, ink brim, blue-hi badge
  (recolor_cops.t1_cap, both tiers). Gate (real city, city-0): blue px 3207 -> 2393 at 32, 4437 -> 2864 at 48, every cop
  still its own blue blob (10 -> 15 blobs at 32: head no longer joins body). evidence/d5-cast/cop-cap-t1.json. Hero A/B:
  only the cops' heads change. Goldens pass unblessed (worst 0.92 / 0.53). Frames: renders/cap-hero-ab.png, cap-city32-ab.png.
