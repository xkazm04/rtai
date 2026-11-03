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
- OWNER CHOICE flagged (masters frames.json "cop heads as T1 draws them"): cream domes are T1's cop, but blue px per frame
  fall vs iteration 1's navy heads: 3449 -> 2393 at 32 (-31 %), 4466 -> 2864 at 48 (-36 %); on the cream sidewalk the
  cream cap meets the cream sticker rim, so the blue mass per cop is smaller at 32. Every cop is still its own blue blob
  (navy body + blue-hi shoulders), so the gate holds. Back to navy heads = git revert 90bb8f6 34acc56.
- Scratch worktree gtai-wt/scratch-cast-merge removed after the trial merge (its commit was never on a branch).
- ANSWER to d5-city's "REQUEST 1 -> d5-cast" (their JOURNAL): cop rig parts are cop_blue / cop_blue_hi in both tiers with
  0 vermilion px (gate r - max(g,b) > 40), and the crowd atlas bakes from the rig at load, so its patrol/riot looks follow.
  At merge their accent_debt rows cop_vermilion_32/48/64 can be deleted (the selftest will report them paid).
- QUESTION for the owner (new): the cop portraits keep their black glossy visor helmets while the rig cops now wear T1's
  cream domes. A portrait close-up is a different shot (visor down), so I left them; say if they should match.
- FIX found by a full cop/police art audit (34 files): the D5 riot helmet still carried 118 vermilion px (rust flecks in
  the crescent; t1_helmet lacked the red-fleck greying t1_cap has). Greyed: cop + police art vermilion now 0 px in all 34
  files (gate r - max(g,b) > 40). (1-6 teal-gate px per D4 part are anti-aliased alpha-edge pixels, not printed teal.)

## Status at ~11:30 (iteration 3)
- New this iteration (d-cast 913129e..HEAD): cop portraits on a navy ramp (0 vermilion); T1 cop heads (riot cream dome +
  navy band; patrol cream crown + navy band + blue badge; OWNER CHOICE, revert = 90bb8f6 34acc56); traffic atlas cell 8
  blue (moving cruisers had vermilion bars); D5 helmet rust greyed; full audit: 0 vermilion in all 34 cop/police files.
- Integration: trial merge with d-city clean except JOURNAL + goldens; merged lint + unit 336/336 green; MERGE d-city
  BEFORE/WITH d-cast (else moving cruiser bars print teal). REQUEST 3 -> d5-city: world-pass teal gate excludes blue +
  cop-blue plate (parked cruisers print ~37 % teal today on every branch).
- Codex images used today: still 1 (King). Bench not run (colour-only changes): unmeasured, not zero.
- EVIDENCE run at dee7dab: lint, unit 326/326, scenarios 8/8, parity exact, selftest goldens 11/11 (worst 0.92) + 5/5
  PASS, but the run reports FAIL on its tree-changed guard: I appended to JOURNAL.md mid-run (FRICTION: never edit the
  tree during an evidence run). Re-run below on a clean tree.
- EVIDENCE (clean tree, HEAD 07182f0, 11:32): lint, unit 326/326, scenarios 8/8, parity 1200 steps exact, selftest look
  goldens 11/11 (worst 0.92) + block 5/5 PASS (--no-bench; bench not run: colour/texture-only changes, unmeasured).
- cop-gate.json t1heads/*: city-0 32 px/m 15 blue blobs / 2393 px, 48 px/m 13 / 2864 px; vermilion = Rivet's collar only.
- Frames: masters frames.json (15) + ladder.png rebuilt: lineups re-shot with today's cops (lineup3-*), hero frames
  heroCapB, city frames capB, cop heads A/B (OWNER CHOICE), cruiser sprites + atlas cell A/B, portraits navy A/B.

NEXT:
- Owner picks at 18:00: (1) cop heads cream (T1, shipped) vs navy (revert 90bb8f6 34acc56); (2) shoulders A (shipped) vs B;
  (3) King's portrait cape vermilion; (4) cop portraits' black visor helmets vs the rig's cream domes.
- Merge order: d-city before/with d-cast (moving cruiser bars). Goldens conflict both ways: re-bless once on the merged tree.
- After d5-city REQUEST 3 lands: shoot a city_frame with a parked AND a moving cruiser on screen (no current frame has one;
  traffic timing varies per run: --police=16 did not bring one into frame) and check both bars print cop blue.
- King into the game when the boss ticket lands (KingPlan ready); ghost form = a new RivetPlan.FORMS row.
- REJECTED (not committed): a darker T1 dome (0.82 x paper instead of 0.94) to part the cop's head from the cream sticker
  rim on the sidewalk at 32. Same-scene hero A/B: d4-32 4 px changed, d4-48 10 px (the D4 part print snaps the dome to
  paper at gameplay zoom), d5-64/128 only ~15 luma darker. No gain where it was meant to help; art reverted, DOME_K = 0.94.
- CHECK noir still switches with the T1 cop heads (dev/noir/noir_frames.tscn, masters renders/noir3): junction-noir
  32/48/64 = 0 blue, 0 teal, 0 vermilion px; cops print as ink masses like everyone. Owner kill-cam frame swapped to
  city_frame focus 1 (city-0 at 128 has a crowd ped standing on Rivet): before night 1.3 | after base 1.1, same street.
- 11:37 provenance audit: all 91 latest d5-cast rows hash-match their files. Session end for iteration 3.
NEXT: unchanged from the NEXT block above (owner picks: cop heads cream vs navy, shoulders A/B, King's cape, portrait
helmets; merge d-city before/with d-cast and re-bless the goldens once; after d5-city REQUEST 3, shoot a parked + moving
cruiser in city_frame; KingPlan into the boss ticket).
- CORRECTION (my own error, 11:45): REQUEST 3's "parked cruisers print ~37 % teal" used look_d4's DEFAULT teal uniform.
  look_profiles.json sets world teal = 0 (and verm = 0) in d1/d4/d5, so in the real game a parked cruiser's blue bar prints
  as grey ink: REQUEST 1's original ask (a cop-blue plate in the world pass) is the real need; the teal-exclusion half of
  REQUEST 3 only matters for scenes that keep the default uniform. Proof that it does happen there: the D5 hero scene with
  a blue-bar borrowed cruiser prints the bar teal (157 px) on d-cast AND on a second trial merge with d-city (cfabdcb)
  (renders/cruiser-hero48-3way.png: night vermilion | d-cast | merged). So the owner's hero frames keep the night's
  vermilion borrowed cruiser (masters night/d5-close/borrowed, dev-only sprite; mine at day-d5/d5-cast/borrowed/ is ready
  for when the plate lands). evidence/d5-cast/cruiser-world-print.json carries the correction; decisions line fixed.
- 11:41 owner frames final for this iteration (masters frames.json, 15 + ladder.png): hero frames re-shot with the
  night-borrowed cruiser; cop-heads A/B differs only at the cops' heads (32/64: 2 regions = riot + patrol head).
  Scratch worktree scratch-cast-merge2 removed. No art/code change since the clean-tree evidence run at 07182f0
  (the darker-dome trial was reverted; later commits are docs/evidence JSON only).

## 2026-11-03 iteration 4 (BUILD, 11:42-13:12)
- 11:42 start. d-city has not landed REQUEST 1/3 (no cop-blue plate in look_d4's world pass yet; d-city 0ea24f4).
- MILESTONE 02d459e cop portraits wear T1's cream dome (owner question 4 from iteration 3, answered by an option that
  ships): the portraits' black helmets clashed with the rig cops' cream T1 domes in the same dialogue frame. Per portrait a
  hand-set dome polygon (masters portrait_dome/polys.py; two first masks spilled onto the band / strap buckle, fixed by eye),
  then a tone curve (smoothstep L 22..85 -> 0.94 x cream) keeps the ink lines in their OWN warm colour (a first pass mixed
  toward the palette INK and left blue-violet streaks: rejected), paper/visor/band/body untouched. Reads as a scuffed
  cream riot dome in the same drawing. 0 Codex images. Provenance rows appended (5). Dialogue frame re-shot
  (renders/dialogue-dome): portrait + street cops in the same cream dome. OWNER CHOICE: revert 02d459e = black helmets.
  Frames: masters frames/portraits-cop-dome-3way.png (orig | navy | dome), dialogue-rivet-cop-48ppm-dome.png.
- MILESTONE 704570f D4 cop heads get T1's thick ink ring: looking at the real city at 32 px/m beside T1, our cop's cream
  dome (4 % rim, gone in the print) ran into the cream sticker rim and sidewalk, so a cop read as a pale blob with a navy
  strip; T1 rings the cream dome in a thick ink band. recolor_cops.t1_rim(): light px within 0.13 x width of the edge ->
  ink, D4 tier only (helmet + cap), band/stripe/badge kept, alpha unchanged. city_frame A/B same session (rimA 6993dc6,
  rimB 704570f), city-0: ink px in cop zones 8944 -> 9358 at 32, 12399 -> 12930 at 48; 92 % of changed px at 32 are
  at cops (rest = crowd jitter); blue px/blobs unchanged (2339/19 -> 2340/19). evidence/d5-cast/cop-rim-t1.json.
  Frame: masters frames/cop-rim-t1-ab.png (T1 | before | after). The owner's city0 32/48 frames now use rimB.
- EVIDENCE (clean tree, HEAD 704570f, 11:54): lint 13/13, unit 326/326, scenarios 8/8, parity 1200 steps exact,
  selftest look goldens 11/11 (worst 0.84) + block 5/5 (worst 0.46) PASS unblessed, crowd atlas on doctrine (--no-bench).
- CHECKED Rivet's portraits: ~13-21k vermilion-ish px each, all in the collar and the rust drips. T2 draws the same
  red-orange rust streaks all over him, so they stay (no change). King: the cape question stands for the owner.
- 12:00 hero scene re-shot with the ring (masters renders/heroRim, --borrow night cruiser): deterministic, the ONLY
  changed px vs heroCapB are the cop heads at 32/48 (103 / 238 px), 64+ D5 tier identical. Owner hero frames now heroRim.
- READY PATCH for REQUEST 1/3 (d5-city's look_d4 world pass, parked cruisers): masters day-d5/d5-cast/
  look_d4-cop-blue-plate.patch (applies on d-city 4e1e055; 17 lines): `uniform float cop_blue = 0.0` + a COP_BLUE_HI
  plate where src b - max(r, g) >= 0.12..0.16 (palette gate 0.157: only the light bar, never the navy body), the teal
  density zeroed for b - g > 0.16 (cop blue is not teal), and look_profiles `world.cop_blue` = 1 in d1/d4/d5/d5c, 0 in
  noir (+ schema key). Tested in a scratch worktree (d-city 4e1e055 + d-cast merged, goldens/JOURNAL from d-city, never
  committed): parked cruisers are 1 in 12 kerb-parked cars (kerb_dresser PARKED id 53); a found one (offset -32, 7.7 from
  city_frame BASE, temporary focus at -32, 3) prints its bar GREY without the patch and cop_blue_hi with it: blue px 0 ->
  340 at 48, 0 -> 633 at 64; teal px unchanged (Rivet's torch tip). The same 32 px/m shot holds a MOVING cruiser too,
  already blue through d-city's look_d4_item: both bars now agree (masters frames/parked-cruiser-plate-ab.png).
  Merged + patched: lint 13/13, unit 336/336, selftest "no new off-doctrine accents" (cop vermilion debt rows reported
  paid). Goldens OFF on the merged tree as expected (both lanes re-blessed; re-bless once after the merge).
- Owner frames (masters frames.json 15 + ladder.png): + cop-rim-t1-ab, + parked-cruiser-plate-ab (PROPOSED patch);
  city0 32/48 and hero frames re-shot with the ring; portraits 3-way (orig | navy | dome) and the dome dialogue frame.
  Dropped from the 15: the cop-shoulders A/B frame (its B panel was from an earlier tree; the A/B question stays in NEXT,
  file frames/cop-shoulders-32ppm-verm-A-B.png kept on disk).
- Patch attribution: the same merged scratch tree WITHOUT the patch gives the identical selftest line (goldens 6/11
  worst 2.47, block 0/5 worst 3.63, same accent shares, "no new off-doctrine accents"): the golden drift is the merge
  alone, the patch moves nothing at the golden sites. Scratch worktree gtai-wt/scratch-cast-plate removed after.
- OPTION (not shipped) King's portrait cape in ink: masters king_cape/cape.py, frames/king-cape-option.png (owner
  question 3 shown, not asked). Hand-set sash band per portrait (measured stripe centres per row); vermilion components
  >= 300 px with r - max(g,b) > 90 outside the band -> a charcoal ramp (folds kept); sash, gauge needle, rust kept.
  Rejected on the way: a 31 px density mask (inked the dense sash bottom), rl > 30 (blotched King's warm steel), and a
  self-intersecting band polygon (my bug: extra closing points dropped half the band). A few cape folds inside the band
  stay vermilion. Owner frames: the dialogue frame swapped out for this one (still 15; file kept).
- REQUEST 4 -> d5-city (supersedes REQUEST 1/3): apply masters day-d5/d5-cast/look_d4-cop-blue-plate.patch (17 lines,
  tested; evidence/d5-cast/cruiser-parked-plate.json), or the Director applies it at the merge. Without it, every
  kerb-parked police cruiser (1 in 12 parked cars) prints its light bar grey in the real game.
- CHECKED Rivet at 32 px/m in the real city (rimB city-1/2): grey arms, a readable claw, the vermilion collar ring,
  the cream helmet: T1's read. City-0's dark Rivet is a crowd ped standing on him (known), not the rig.
- REAL-GAME cop close-up at 64 px/m (city_frame --police=12 --zooms=2,4, city-0; masters renders/copclose): a cop
  with the new ring, blue badge, navy body, blue-hi shoulders: T1's read (added as row 3 of frames/cop-rim-t1-ab.png).
  No cop came within the 128 px/m views (0 blue px in all three foci): the 128 cop close-up stays the hero scene's.
- FINDING (for the owner / d5-city): at 64 px/m in the REAL game most people print the D4 tier, not D5. RigDetail adds
  the D5 overlay to full rigs only, and RigSelect gives full rigs to the 16 nearest within 14 m (STANDARDS section 20);
  everyone else is a CrowdAtlas cell baked from the D4 rig. A 64 px/m view holds ~20 people, so the outer ones (the cop
  above, ~7 m from Rivet) never get the D5 grime H2 shows. PROPOSAL (d5-cast owns the atlas inputs, d5-city the people
  layer): bake a second CrowdAtlas with RigDetail on at FULL_ZOOM and swap the MultiMesh texture while RigDetail.active
  (memory: one more 128 px-cell atlas; bake time ~30 frames at load). Not started: too big for this session's tail.
- TRIED + REVERTED (never committed): a D5 twin of the crowd atlas (CrowdAtlas.make_d5: 171 px cells at 64 px/m,
  baked with RigDetail on, the people layer swapping textures while RigDetail.active; unit 329/329 green). The dumped
  atlases (masters renders/atlasD5/atlas-zoom.png, crowd-atlas vs crowd-atlas-d5) show NO D5 print in the twin: the cells
  are the D4 print at a higher resolution. Known cause for the sleeved looks: RigDetail skips palette-swapped parts
  (sprite_swaps != 0). Unverified for the cop look (unswapped, has d5/cop parts) - its twin cell shows no D5 scratches
  either, so the overlays may not print in the bake SubViewport at all. Cost without the gain (+~23 MB VRAM, +~30 load
  frames, and a real-city run whose crowd layout moved because the longer load let the sim advance) -> reverted.
  The FINDING above stands: outer crowd at 64 px/m prints D4. NEXT owner: whoever takes the D5 crowd must first make the
  RigDetail overlays print in the baker's SubViewport (check the cop cell), then decide on swapped parts.

## Status at ~12:25 (iteration 4)
- New this iteration (d-cast 6993dc6..HEAD): cop portraits wear T1's cream dome (02d459e, OWNER CHOICE: revert for black
  helmets); D4 cop heads get T1's thick ink ring (704570f; real city A/B at 32/48 + a real-game cop at 64); hero frames
  re-shot (only cop heads changed); a tested look_d4 cop-blue plate patch for parked cruisers (REQUEST 4 -> d5-city,
  masters patch, evidence/d5-cast/cruiser-parked-plate.json); a King cape option (not shipped); Rivet portraits and
  Rivet at 32 checked against T2/T1 (no change). Tried and reverted: a D5 crowd atlas twin (no D5 print in the bake).
- EVIDENCE (clean tree, HEAD 704570f; later commits are docs/evidence JSON only, project/ unchanged since): lint 13/13,
  unit 326/326, scenarios 8/8, parity exact, selftest goldens 11/11 + 5/5 PASS unblessed (--no-bench).
- Codex images used today: still 1 (King). Bench not run (art-only changes): unmeasured, not zero.
- Owner frames: masters day-d5/d5-cast/frames.json (15, `before` now only real files; A/B composites name the before
  panel in the note) + ladder.png.

NEXT:
- Owner picks at 18:00: (1) cop heads cream (T1, shipped) vs navy (revert 90bb8f6 34acc56, then also 704570f's ring
  and 02d459e's portrait domes); (2) shoulders A (shipped) vs B; (3) King's portrait cape: vermilion (shipped) or ink
  (masters king_cape/cape.py, frames/king-cape-option.png); (4) cop portraits: cream dome (shipped) vs black (revert 02d459e).
- Merge order: d-city before/with d-cast (moving cruiser bars); goldens conflict both ways: re-bless once on the merged
  tree. Apply masters look_d4-cop-blue-plate.patch (REQUEST 4) on d-city or at the merge, then delete d-city's
  accent_debt rows cop_vermilion_32/48/64 (the merged selftest reports them paid).
- D5 crowd at arena zoom: make RigDetail overlays print in CrowdBaker's SubViewport first (the cop cell is the test),
  then decide on palette-swapped parts; only then a D5 atlas twin (code shape in the journal entry above).
- King into the game when the boss ticket lands (KingPlan ready); ghost form = a new RivetPlan.FORMS row.
- DIAGNOSIS (12:30) of the D5 crowd twin's missing print, for the next owner: the D5 part tier itself is strong at 64
  (dev d5_showcase, same pose, tier off vs on: 9282 px change at 64, 16955 at 96; masters renders/tier64/cop-tier64.png
  shows the hatched dome and scratched shoulders). The bake lost it because RigDetail is global: CharacterRigs steps
  every frame and calls RigDetail.set_view(view zoom = 1 or 1.5) during the ~30 bake frames, which turns `active` off
  (the bake's sync then hides the overlays) and sets the SHARED overlay materials' `amount` to 0. Probable, not proven
  (no instrumented run). Fix shape: the baker builds its own overlay materials (amount 1, px_scale at the bake zoom) and
  a RigDetail.sync variant that takes `want` and the material instead of reading the globals. Then re-dump the atlases
  (rig_showcase saves crowd-atlas.png; add crowd-atlas-d5.png) and judge the cop cell before any city integration.
- 12:22-12:32 D5 crowd twin, second attempt (timeboxed): DIAGNOSIS CONFIRMED. With the baker's own overlay materials
  (CrowdBakeDetail: look_d5_part at amount 1, px_scale at the bake zoom, independent of RigDetail.active) the twin
  prints the D5 tier (masters renders/atlasD5b/atlas-zoom.png: hatched domes, scratched shoulders, like the live tier).
  Committed as 7f187e1 (unit 330/330, scenarios, parity green) and REVERTED in f88df08: the selftest went red, look
  goldens 0/11 (worst 11.64, d1@32 and d4@32 included) and block 0/5 (worst 15.29). The second bake's ~30 extra load
  frames move the crowd's timing in every golden scene, not the print. And the in-game benefit was not shown: in the
  real city at 64 px/m (--police=12) all ~12 visible people were inside the 16 full rigs (A/B crowdA/crowdB, temporary
  pin of crowd_texture() to D4, never committed), so the twin only matters in denser scenes (riots).
- EVIDENCE (clean tree, HEAD f88df08, project/ identical to 704570f): lint 13/13, unit 326/326, scenarios 8/8,
  parity exact, selftest goldens 11/11 (worst 0.84) + 5/5 PASS (--no-bench).
- FRICTION: one unit run failed test_noir_shadows ("Parameter t is null", engine) and passed on the re-run unchanged:
  a flake (d-city fixed a CityTextures thread-load flake today, 000087f; not on this branch).

NEXT (final for iteration 4, supersedes the NEXT above where they differ):
- Owner picks: cop heads cream (shipped) vs navy (revert 90bb8f6 34acc56 704570f); cop portrait domes (revert 02d459e);
  shoulders A vs B; King's portrait cape vermilion (shipped) vs ink (masters king_cape).
- Merge: d-city before/with d-cast; re-bless the goldens once on the merged tree; apply REQUEST 4's patch.
- D5 crowd twin: code is in 7f187e1 (revert of the revert to resume). Before re-landing: (a) bake the twin without
  changing load timing (e.g. after the selftest/scene starts its clock, or bake both looks in ONE SubViewport pass),
  or re-bless deliberately with a decisions line; (b) prove it in a dense real scene at 64 px/m (riot) A/B.
- King into the game with the boss ticket; ghost form = a new RivetPlan.FORMS row.
- 12:35 checks: provenance audit, all 91 latest d5-cast rows hash-match their files. Masters frames.json: 15 frames,
  every file and `before` exists. REQUEST 4's patch still applies cleanly (git apply --check, read-only) on d-city
  b8efb91 + its working tree. Session end for iteration 4: tree clean at the commit below, evidence green at f88df08.

## 2026-11-03 iteration 5 (BUILD, 12:34-)
- 12:34 start. Items 1-5 evidenced; raising the weakest against verdict 1 ("Rivet too massive"): the kill-cam frame
  (T2 vs hero 128) still showed a 2 m "C" of arms, with the hands level and forward in the guard.
- MILESTONE 8118692 + its follow-up: Rivet's guard hunches as T2 draws him. RivetPlan FORMS rows are now (size_k,
  guard_k, hand_z): base = (1.2, 0.7, -250); King keeps the open guard (FORM_OPEN = the old base, so the boss squares up).
  Footprint (rig_footprint) 1.97 x 2.37 -> 1.90 x 2.05 m (cop 1.27 x 1.88). Tried on the way: guard_k 0.6 alone
  (1.67 x 2.50: elbows flare, WIDER, rejected); the hunch at 1.1 (1.74 x 1.88, shipped briefly in 8118692): in the D5 hero
  scene Rivet then read cop-sized or smaller beside the riot cops, while T1 draws him ~1.3x a cop -> 1.2.
  Real-game A/B (city_frame seed 91 --police=4, same session, renders hunchA vs hunchC): focus 1 changes only at Rivet
  at 32/48/64/128; the claw and torch read at 32; at 64+ the upper arms show their end-on cells (round shoulder joints,
  as T2). King lineup: only Rivet's region changes. Hero scene re-shot (renders heroHunch12): only Rivet changes.
  Goldens 11/11 (worst 1.37) + block 5/5 (worst 0.91) PASS unblessed; scenarios 8/8; parity exact; unit 326/326.
  decisions line + evidence/d5-cast/rivet-footprint.json. OWNER CHOICE: open guard = revert both commits.
- FRICTION: test_noir_shadows "Parameter t is null" failed inside the evidence run twice this iteration and passed
  standalone both times (engine flake, not d5-cast scope; d-city has a thread-load fix in 000087f).
- Owner frames (masters frames.json, still 15; build_frames.iter4.py keeps the old recipe): lineup now 3-way
  (night | iteration 1 | now), the city1-128 A/B replaced by the 4-zoom real-game hunch A/B, T2/T1/hero frames and the
  King frame re-shot with the hunch. All images looked at: all straight down, 0 rejected.
- 12:49-12:54 D5 crowd twin, third attempt (timeboxed), TRIED + REVERTED (never committed; masters
  day-d5/d5-cast/crowd-twin-v3.patch, 379 lines, applies on 2eb58bb). Found WHY the goldens moved in attempt 2:
  look_golden.gd lets the World process during the load (World._prewarm holds the sim; the golden scene does not), so the
  twin's ~30 bake frames advanced the riot. Fix in the patch: CityCharacters.bake_d5() as its own step; World._prewarm
  awaits it; look_golden/city_frame hold the World (set_process(false)) around it; city_frame --no-d5-crowd for A/B;
  plus a get_meta default fix in CrowdBakeDetail (an engine ERROR on the first sync). Real-city A/B (city_frame seed 91
  --police=12 --zooms=2,3, renders twin-off vs twin-on, frames twin-city0-64-zoom.png / twin-city0-96-zoom.png):
  city-1/2 unchanged (<30 px: everyone on screen is a full rig); city-0 38.8k px at 64, 56k at 96. LOOKS WORSE at 64:
  the twin bakes the sticker halo at 64 px/m, so the crowd keeps a thinner cream rim than the D4 cells magnified from
  48 (figures separate less from the asphalt); the D5 hatch it adds is hardly visible at 64. At 96 the hatch is crisper,
  but 64 is the arena zoom the twin was for. Not shipped (brief: worse in-engine -> revert). If someone resumes: bake the
  halo at the D4 bake's width (scale the halo by 1.5/2.0 in the twin stage) and re-judge at 64 first.
  ADDENDUM: the thinner rim is by design, not a twin bug: CutRig._on_view fades the halo as view px rises
  (hk = 1 - smoothstep(0.12, 0.3, px)), so the live full rigs at 64 px/m (the 16 nearest, Rivet) already carry the
  same thin rim; only the D4 atlas cells, baked at 48, carry the thick one. The twin makes the crowd consistent with
  the full rigs; the D4 cells give more separation. OWNER CHOICE (frames in masters renders twin-city0-64-zoom.png,
  twin-city0-96-zoom.png; patch crowd-twin-v3.patch; then re-bless the 64+ goldens with a decisions line).
- CHECKED d-city (00ebb7c): REQUEST 4 (look_d4 cop-blue plate for parked cruisers) not landed; the masters patch still
  applies cleanly (git apply --check, read-only). d-city's palette.json cop_blue #3A4766 / cop_blue_hi #4F86E0 equal the
  values hard-coded in print_part / look_d5_part (shaders cannot read the table; same as d-city's item shader).
  d-city's REQUEST 1 to d5-cast (cop rigs + atlas to cop_blue) is done here since iteration 1 (answered iteration 3).
- NOTE d-city bf43a68 ramps the WORLD's D5 overlay in from 32 px/m (0.5 at 32, 1 at 64). The characters' D5 part tier
  (RigDetail, 56 -> 64 px/m) is left as is: below 56 most people are D4 atlas cells (only the 16 nearest are full rigs),
  so a part ramp from 32 would split the crowd into two tiers, and the D5 part grime is sub-pixel at 32. Owner call.
- 13:00-13:20 TRIAL MERGE 3 (scratch worktree gtai-wt/scratch-cast-merge3, detached, removed after; its commit never on a
  branch): d-city 00ebb7c + d-cast 3bb490f + masters look_d4-cop-blue-plate.patch. Conflicts ONLY JOURNAL.md and the 16
  look goldens (took d-city's). The plate patch still applies. Merged evidence (--no-bench --no-parity): lint 13/13,
  unit 336/336, scenarios 8/8; selftest FAIL on goldens only (7/11 worst-pass 2.32, OFF d4@64 d5@48 d5@64 auto@56;
  block 4/5, OFF auto@64-night): the expected drift from cops + Rivet over d-city's re-blessed goldens; "no new
  off-doctrine accents"; "debt rows no longer seen (delete them): cop_vermilion_32/48/64"; world lock holds.
  -> MERGE RECIPE for the Director: merge d-city, then d-cast (JOURNAL: keep both; goldens: either side), apply the
  plate patch, delete accent_debt rows cop_vermilion_32/48/64, then look_golden --bless (junction + block) ONCE with a
  decisions line, and re-run the selftest unblessed.
  Real-city preview (city_frame seed 91 --police=4): renders merge3/, owner frame frames/merged-preview-city0-32-64.png
  (d-city's D5 world ramp from 32 + blue cops + hunched Rivet; at 64 Rivet stands clear and reads). It replaced the
  city0-48ppm-ab frame (its after showed the iteration-1 Rivet). frames.json still 15, all files present.
- rig_footprint now also measures King (KingPlan, Rivet's look): King 2.33 x 2.84 m vs Rivet 1.90 x 2.05 m (1.7x the
  area; about the night Rivet the owner called too massive). Kept: a boss in a 64 px/m arena. OWNER QUESTION: smaller
  King = KingPlan.SIZE_K (1.3 -> 1.2 gives ~2.15 x 2.6 m by proportion, unmeasured).

## 2026-11-03 iteration 46 (BUILD, 15:40-17:00)
- 15:40 start. Items 1-5 evidenced (see above). Gap since 13:20: no lane activity on this branch (last commit 13:08).
- MILESTONE 294e6b5 King size option for the owner's question: KingPlan.build(size_k = SIZE_K), king_showcase
  --king-size=<k>, rig_footprint row king_1_2. Measured: King 1.3 (shipped) 2.33 x 2.84 m, King 1.2 2.15 x 2.62 m,
  Rivet 1.90 x 2.05, night Rivet 2.50 x 2.62. Same-scene frames (renders kingsize-1.3/, kingsize-1.2/): only King's
  region differs (2306 / 10904 / 38267 px at 32 / 64 / 128); all straight down, 0 rejected. At 1.2 King still reads
  as the boss beside Rivet. Shipped value unchanged; OWNER CHOICE = KingPlan.SIZE_K 1.2. Owner frame
  frames/king-size-option.png replaces king-rig-128ppm.png (frames.json still 15; ladder rebuilt; build_frames.py updated).
- Rig bench (F-09b, headless = CPU only, debug build, CONTENDED), d-cast HEAD 44bf93d at 15:43, lock held by d5-cast:
  50 people rigMsAvg 0.366 (p99 0.647), 200 people 0.342 (p99 0.529), full rigs max 16, pool grown 0. Older uncontended
  rig-quarter "new" runs (another day, main) were ~0.30 at 50. Same-session A/B against main 089400e was set up
  (scratch worktree gtai-wt/scratch-cast-bench) but d5-combat took the bench lock at 15:42 -> skipped (rule).
- Evidence run (clean tree, HEAD 294e6b5, --no-bench): lint 13/13, unit 326/326, scenarios 8/8, parity exact (1200
  steps, mutation caught at 629), selftest look goldens 11/11 (worst 1.37) + block 5/5 (worst 0.91), world lock holds.
- MILESTONE (masters only, no code) D5 hero scene's parked cruiser loses the night's vermilion light bar, the last
  vermilion on a cop in the owner's H2 frames. A blue bar printed soul-teal there (dev-scene world teal uniform), so the
  bar goes to cop NAVY (#3A4766 ramp by luminance, 1742 px) in a d5-cast copy of the borrowed sprites:
  masters day-d5/d5-cast/borrowed/ (the night's folder untouched). Shoot with d5_hero --borrow=<that dir>. Same-session
  A/B (renders heroBarA vs heroBarB): only the cruiser region changes (288 / 527 / 326 px at 32 / 48 / 64); it prints
  ink (dark bar, cream centre), no vermilion, no teal; heroBarA == heroHunch12 (0 px). All straight down, 0 rejected.
  Owner frames t1-vs-hero-48ppm and hero-d5-64ppm-ab rebuilt from heroBarB; A/B at frames/cruiser-hero-navybar-ab.png
  (named in the cruiser-art-ab note; frames.json stays 15). Vermilion left in that scene = cones and the striped
  barrier (danger cues, doctrine-allowed) and Rivet's collar.
