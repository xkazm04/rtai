# JOURNAL n16 kills-polish

## Iteration 1 (2026-11-11 11:00, BUILD)

- 11:00 read: brief, common rules, n15 combat REPORT "What does not work", n15 hero REPORT (peek card), kills/ folder.
- SHARED FILE (kills-new, read me): I edit `project/data/tables/signature_kills.json` only inside MY rows
  (rocket_gib, hand_cannon_blowback, burn_char, electro_shock, ohm_shock, katana_split, plasma_hole,
  plasma_sword_split, chainsaw_grind, ray_gun_dissolve, homing_shard_burst, mini_nuke_vaporise, tonnage_*, dent_*,
  kerf_split) and I ADD optional keys to `project/data/schemas/signature_kills.schema.json` (alphabetical, one key per
  property block, no reorder). First: `streak_m`, `streak_w_m` (the split style's slash streak). A merge of both
  lanes' schema keys is a union.
- Item 1d (peek card): already wired on main. `collect_call_art.json` maps BOTH `rivet_hide_p55` and `rivet_hide_p70`
  to `rivet_hide_p55.png` (n15 hero it14, b536742b4, DECISION hero/quest-hide-peek). The owner's verdict = kept as built.
  Evidence: `grep -n rivet_hide project/data/tables/collect_call_art.json` (lines 96-101). Film still owed.

### REQUESTs to the asset lane (11:20, item 3; riso ink-and-cream, red = blood only, cops blue, no vermilion/teal)
Gore level (owner pick 2026-11-11): drawn innards, bone and skulls may show in cut edges, holes and gibs. Delivery as
before: one PNG per piece/frame on transparent, keyed, under `library/keyed/street/<name>/`; reply in
`gtai-assets/replies/n16-kills-polish.md`. Priority order = the order below.

- REQUEST assets: (A1) gib pieces WITH BONE, beat = the rocket gib's aftermath (pieces flying, then lying on the street
  for 20+ s). 6 pieces per kind in this order: head, torso, image-left arm, image-right arm, image-left leg,
  image-right leg (same layout as it363 `<kind>_gib_70_cells/1_{1..6}`). New: every torn end shows a drawn cream bone end
  (humerus/femur knob, a broken spine stub out of the torso's neck and waist) inside a red raw meat lip with ink;
  the torso's tear shows two or three rib ends. Head piece: keep the headgear, the neck tear shows a spine stub.
  Kinds, in order: cop_patrol (navy cap), cop_riot (helmet), swat, ped_hood, ped_suit, ped_cap, ped_worker, and if time
  ped_jogger, ped_punk, ped_shopper, ped_elder, ped_hat. thug is a ROBOT: wires and a cracked chassis instead of bone
  (its it363 set is fine; skip unless spare time). Pitch p70 (about 69 deg) AND p55 (about 51 deg). Size as it363
  (each piece about 300-500 px longest side, the packer scales). Name `<kind>_gib_bone_70_cells/1_{1..6}.png` and
  `<kind>_gib_bone_55_cells/...`.
- REQUEST assets: (A2) the blade cut face, beat = the katana / chainsaw split: the two halves part and their cut edge
  must read as a body cut through, not a paper edge. A horizontal STRIP texture (tileable left-right), 512 x 64 px,
  the cut face seen edge-on from a 70 deg camera: an ink lip on top, under it red raw meat with cream rib cross-sections
  (small cream ovals in a row), one cream spine disc with a dark cord dot, a thin cloth band (blue for cops, neutral grey
  for peds) at both ends. Three variants: `cut_face_clean` (katana: clean, glossy, straight), `cut_face_saw` (chainsaw:
  ragged torn top edge, shredded cloth, bone chips), `cut_face_hot` (plasma sword: cauterised, charred black-brown crust
  with a thin cream-hot line, NO red). One p70 set is enough (it is drawn along the cut edge at any pitch).
  Name `fx/cut_face_70/{clean,saw,hot}.png`.
- REQUEST assets: (A3) the electro X-ray, beat = the shock kill's held flash (6-10 ticks: the body blinks out and the
  skeleton shows in its place, cream bones on ink, ringed by cream arcs). A full standing skeleton sticker PER KIND,
  standing pose (arms a little out, convulsing), skull with eye sockets and jaw open in a scream, ribcage, spine,
  pelvis, limb bones; the kind's headgear and gear drawn as a thin ghost outline round the skull/body (cap peak,
  riot helmet with visor, SWAT helmet + vest outline, hood, suit collar + tie, worker hard hat?). Two frames per kind:
  (1) cream bones on a dark ink body silhouette, (2) the inverse flash (ink bones on a cream silhouette). Kinds:
  cop_patrol, cop_riot, swat, ped_hood, ped_suit, ped_cap, ped_worker, generic ped. p70 and p55. Cell 256 x 384,
  feet on the cell floor. Name `xray_<kind>_70_cells/1_{1,2}.png` (`_55_` for p55). Today's sticker is one
  `weapons/art/gore/xray.png` for every kind.
- REQUEST assets: (A4) the plasma hole, beat = the victim stands looking at the hole in his torso for ~20 ticks, then
  topples. A round wound ring through the torso (seen at 70 deg): outer charred cloth crust, inside it cauterised flesh
  with the cut ends of 3-4 cream ribs and a spine segment visible at the back edge, the centre TRANSPARENT (the street
  shows through). Three frames cooling: white-hot cream edge, amber-hot edge, cooled black-brown char. No red (it is
  cauterised). 256 x 256 cells, ring outer diameter ~220 px, hole ~140 px. p70 (p55 optional: an ellipse squashed
  ~0.8 vertically). Name `fx/plasma_hole_70_cells/1_{1,2,3}.png`.
- REQUEST assets: (A5) chainsaw grind chunks, beat = the grind (the body held on the saw, ~20 ticks) throws chunks off
  the chain: 10 small drawn chunks, each in its own 96 x 96 cell: 4 red meat chunks with ink, 2 cream bone chips,
  1 rib piece, 2 torn cloth scraps (one cop navy blue, one neutral grey), 1 tooth-sized cream chip. Ink-and-cream riso,
  red blood only. Name `fx/saw_chunks_70_cells/1_{1..10}.png`.

- MILESTONE 11:05 de9f68f8a item 1b streak: row keys streak_m/streak_w_m (schema), katana + plasma sword 1 m x 0.06 m,
  KillSlashStreak split out (KillSplitFx at its size ratchet). Film: `evidence/n16-kills-polish/katana_streak_ab_64ppm_t61-68.png`,
  `..._32ppm_x2_t63-70.png` (before = main 5843f5a28). Reads as a short red-lipped line over the cut, not a white stick.
- MILESTONE e4d81df1b item 1c blade hold: RigClips.strike_hold = 6 ticks for BLADE_LEFT blades (RivetWindup.hold_s),
  `--rivet-strike-hold=off` = before. Boss blade film (tilt 64 px/m, King + katana): before t307-308 upright back-turned
  frames, after the strike cell holds into the t309 wind-up (`evidence/n16-kills-polish/boss_katana_strike_hold_ab_64ppm_t305-310.png`).
- MILESTONE 917d75a5e item 1a gib pieces as rigs: GibCardPieces.dress_rig + 6 new packed sheets (thug, hood, cap, suit,
  worker, SWAT). Before, a rig-gibbed thug/hood flew blue cop-suit rig parts. Films 64 and 32 px/m in evidence.
  Open (DEFECTS #2): at 32 px/m the pieces are small and the thug's grey reads weakly on the smoke.
- FRICTION 11:05-11:22 my first compare chained `--a=HEAD~1 --b=HEAD` and I committed in the middle (HEAD moved), plus
  `--subject=dead` was off screen: stopped it. Lesson: film explicit SHAs with `film.mjs --rev=` and flag befores
  (one snapshot import, about 5 min, then cached).
- Registry rules applied (motion-quality-gating: judge on frames at the play zoom, not packed sheets; combat-pacing:
  the hold is under the 6-tick hit-stop budget and the fight does not stop): the hold is 6 ticks, view only.
- Item 1d peek card: no change needed (see above); a quest 1 still is still owed.
- NOTE for kills-new (11:45): since 917d75a5e `GibCut.cut(rig, false)` (the six-part throw, e.g. your gatling_shred)
  swaps a rig victim's six part groups for its kind's DRAWN gib pieces when `GibCardPieces.GRIDS` has the kind
  (`GibCardPieces.dress_rig`); `whole=true` (your pose-track body copy) is untouched. `--gib-pieces=cut` = the old rig parts.
- 11:40 asset lane it410 delivered gib pieces WITH BONE for ped_elder, ped_hat, ped_punk, ped_shopper (B, torso x0.8),
  contractor; bone versions of the seven no-gore sets are coming (round 20261111-1130). Judged on a contact sheet
  (`build/scratch`, not kept): strong, cream bone stubs, rib tops, red only as flesh and blood. Packed elder/hat/punk/
  shopper (row keys ped/head_bald, ped/head_hat, ped/head_punk, ped/head_shopper). Contractor HELD: its hi-vis vest and
  hard hat are orange (colour law: vermilion only for danger/objectives/Rivet's collar) and its quest-card row key is
  not a StreetDeadPlan row; judge against the contractor card first.
- MILESTONE 76f023a08 item 3: bone gib pieces (it410) for elder, hat, punk, shopper packed and wired (not yet filmed in
  game: `film.mjs weapon:rocket_launcher --victim=ped/head_punk` etc. is owed).
- MILESTONE item 2 ranking films (11:36-11:47, rev 1b823dbf7, `build/film/rank{32,64}_<weapon>`, git-ignored, kept):
  electro_gun, flamethrower, plasma_rifle, chainsaw, ray_gun, homing_shard, hand_cannon, mini_nuke, plasma_sword filmed;
  rank32_rocket_launcher cut short (I stopped the queue: rocket and katana were filmed for item 1). Scored in KILLS.md:
  electro, flamethrower, plasma, chainsaw, ray gun. Beat strips: `python -I build/strip.py <film> auto:520,420 0.6 <out>`
  (build/strip.py and build/ab.py are my scratch helpers, git-ignored; copy them if build/ is cleaned).
- MILESTONE bb9314a83 plasma hole (weakest, 7/20): hole at the chest (row hole_up_m 0.4), ink-grey smoke. Before/after
  64 and 32 px/m in `evidence/n16-kills-polish/plasma_hole_chest_smoke_ab_*`. Now ~9/20.
- 12:00 GATES started on bb9314a83 (`node tools/gate/run.mjs --rev=bb9314a83 --reels`, log build/gate_bb93.log,
  results build/gate/bb9314a83*/gate.json).

NEXT (iteration 2):
1. Read the gate result for bb9314a83 (build/gate/<sha>/gate.json). If red: fix first. Look goldens: none was meant
   to move; a red look golden means a kill frame is in a golden: name it, judge, re-bless only that one + decisions line.
2. Score the four filmed but unscored deaths in KILLS.md from build/film/rank{32,64}_{homing_shard,hand_cannon,
   mini_nuke,plasma_sword}; film the ghosts' kills (tonnage, dent, kerf, ohm) and score them.
3. Electro X-ray upright on the body (DEFECTS ranking #2): `KillShockFx._draw` draws the sticker turned along the shot
   at the body group's centre; under a card view draw it upright with its feet on the body's feet (check where p is for
   a card vs a rig first). Then wire A3 per-kind stickers when they land.
4. Film the bone gib pieces in game (punk, elder, hat, shopper; 64 + 32), and pack the bone versions of the seven
   no-bone kinds when the asset lane's round 20261111-1130 lands (same keys: swap the KINDS folder to *_gib_bone_70_cells).
5. Plasma hole: the cream halo (1.55 x radius, alpha 0.55) is large at 32 px/m; then A4 drawn insides.
6. Ray gun dissolve does not read at k+10..k+30 (DEFECTS ranking #3).
7. Owed: a quest 1 still of the p55 peek card (item 1d is already wired on main; evidence only); perf: fight_gate under
   the bench lock once drawn cells are added (none warmed yet: gib sheets load on first use).
8. Contractor bone gib set: judge its orange hi-vis against the contractor card and colour law before packing.
- GATES on bb9314a83 (12:00-12:25, build/gate/bb9314a83ecb/): PASS lint 19/19, unit 2649/0/2, scenarios 55, parity
  bit-exact (mutation at 629), selftest look goldens 11/11 worst 0.00, block 5/5, export-audit 683/0. The REEL gate was
  still running at 12:25 (session stop): read `build/gate/bb9314a83ecb/reels.log` / `gate.json` first next session.
  Commits after bb9314a83 are docs only (c15db9cc6, 23d4535a5).
- FRICTION 12:03 a commit with root KILLS.md/DEFECTS.md ran full lint and `tools/merge/step_guard.break.test.mjs:277`
  (a timeout test) failed while the gates loaded the machine; it passed on the retry a minute later (flaky under load,
  not my change; the tools lane may want it: REQUEST tools: step_guard timeout test flakes under a running gate).

## Iteration 2 (2026-11-11 12:30, BUILD)

- 12:30 read JOURNAL, git log, the asset replies (it410 p70 bone for all 13 kinds 11:41; it414 p55 bone for the 7
  priority kinds 12:22; A2 cut faces running in round 20261111-1230). The reel gate on bb9314a83 never finished (the
  session stopped mid combo pass, no verdict line): re-run on the final commit.
- MILESTONE fdb3a0d2d bone gib for patrol, riot, SWAT, hood, cap, suit, worker (it410, drop-ins; old/new board judged).
  Film rocket --victim=cop/head_cap 64/32: bone reads at 64, NOT at 32 (pieces too small over the smoke).
- MILESTONE 455148cb5 electro X-ray upright on the body's feet (KillXray.mid; `--shock-xray=lie` = before). Reads as
  his X-ray at 64 and 32. Ohm's shock shares it.
- MILESTONE 7d3ba705a FOUND filming the ranking: every blade split (katana, plasma sword, chainsaw, Kerf) cut through the
  body's GROUND POINT, so in the upright view one "half" was the whole cop, standing and aiming as he slid off, and the
  other his feet. Row key `cut_up_m` (schema) 0.8: real head-and-shoulder and legs halves. Films katana 64/32, plasma
  sword 64, chainsaw 64 before/after. Open: the halves slide upright (no topple).
- Scored on films: hand cannon 13, homing shard 13, mini nuke 15, plasma sword 7 -> 10, katana 10 -> 13 (KILLS.md).
- Registry rules applied: motion-quality-gating (judge on game frames at play zoom, before/after same tick; the 32 px/m
  bone result recorded as a miss, not claimed); combat-pacing (no new holds: all three changes are view placement only).
- MILESTONE e69fd5359 blade halves topple (`split_topple_deg` 80, KillSplitHalves; key renamed from `topple_deg`
  because kills-new's `track` sits at the same schema spot: quick.mjs merge-clash caught it). Films katana 64/32,
  plasma sword 64. The chainsaw's level cut stacks the halves and its torso fell back UNDER Rivet: fixed in the work
  tree (stacked halves fall along the blow), commit after the gate.
- 13:08 GATES started on e69fd5359 (`node tools/gate/run.mjs --rev=e69fd5359 --reels`, log build/gate_e69f.log).
- 13:15 A2 cut faces delivered (it414, `library/keyed/fx/cut_face_70/`): wiring the tile variants into KillCutEdge
  (`--cut-face=line` = before); needs a Godot import after the gate (no second Godot while it runs).
- 13:12 stopped my own gate (PID 71904 tree) to keep Godot free for the chainsaw fix and A2; gate re-run on the last
  commit below.
- MILESTONE 0dcdf95c1 stacked halves (the saw's level cut) fall along the blow, off Rivet.
- MILESTONE 794f27f80 A2 drawn cut faces on the blade halves (KillCutEdge.FACES; `--cut-face=line` = before). Films
  katana 64/32, chainsaw 64, plasma sword 64. Owner Call: the hot face is a charred crust, less glow than the cream bar.
- 13:20 GATES started on d3e25fc4a (`node tools/gate/run.mjs --rev=d3e25fc4a --reels`, log build/gate_d3e2.log).
- 13:25 jogger bone gib packed (it410 retry, maroon track jacket = the card's; torso x0.8 as the shopper):
  `ped/head_jogger` in GibCardPieces.GRIDS. Uncommitted until the gate frees Godot for its .import.
- GATES on d3e25fc4a (13:20-13:46, build/gate/d3e25fc4a0a7/): PASS lint 19/19, unit 2662/0/2, scenarios 55, parity
  bit-exact (mutation at 629), selftest look goldens 11/11 worst 0.00, block 5/5, export-audit 685/0. REELS FAIL: the top
  pass threw `has_meta on a null value` (StreetWalkerCards.row_of via GibCardPieces.dress_rig, 917d75a5e: a top-view rig
  has no head card) at the rocket chapter; tilt70 and combo OK. -> fixed 9d3d821f6 (no head card = the rig's own parts,
  test added). The reel gate must be re-run on the next tip (the top pass at least).
- MILESTONE d99019902 jogger bone gib (it410 retry, torso x0.8; ped/head_jogger).
- FRICTION: one Godot per lane meant the gate (40 min with reels) blocked filming; I stopped a gate at 13:12 to keep
  working. Lesson: start the gate only when the session's last Godot work is done.

NEXT (iteration 3):
1. Re-run the reel gate on the tip (`node tools/reel/run_reels.mjs`, or tools/gate/run.mjs --reels): the top pass
   failed on d3e25fc4a and 9d3d821f6 fixes it; everything else passed on d3e25fc4a. The jogger (d99019902) is
   unfilmed: film rocket --victim=ped/head_jogger 64.
3. Ray gun dissolve (DEFECTS ranking #3): film chapter:ray_gun 64 --on=kill:1+80 and check where root.position sits
   (feet or hips) vs the drawn figure; likely the blades' bug (mask/rings on the ground point, BODY_R_M 0.62 too small for
   a 1.7 m upright figure): lift the disc to mid-body as a row key (`dissolve_up_m`?) and make it an ellipse.
4. Plasma hole: the cream halo at 32 px/m; A4 drawn insides when delivered.
5. A3 per-kind X-ray skeletons when delivered (KillShockFx XRAY_TEX by row key -> per kind).
6. The bone gib at 32 px/m does not read (pieces ~10-15 px over the smoke): try the pieces over the smoke z, or larger.
7. Owed films: the ghosts' four (tonnage, dent, kerf, ohm), burn_char's flame column; the p55 peek card still.
8. Perf: fight_gate under the bench lock (new preloaded cut faces, 3 x 256x32; gib sheets load on first use).
9. Owner Calls to write in REPORT: plasma sword hot face (charred vs glowing), split topple 80 deg, cut_up_m 0.8,
   upright X-ray, bone gib.

## Iteration 3 (2026-11-11 13:52, BUILD)

- 13:52 read JOURNAL, git log, the asset replies: A3 X-ray p70 complete for 8 kinds (13:23-13:52), A4 plasma hole (13:19),
  A5 saw chunks (13:23) all delivered and unwired. No Godot of mine running (checked by command line: the others are
  third-life and kills-new). Plan: wire A3, A4, A5 (one commit each, films before/after by flag on the same build), then
  the gate on the tip (the reel top pass failed on d3e25fc4a; 9d3d821f6 fixes it).
- Registry rules applied (motion-quality-gating): before/after on game frames at the same ticks, 64 and 32 px/m; the
  32 px/m read judged separately and written down where it is weaker (X-ray on dark asphalt, plasma impact bloom).
- MILESTONE b037d283f electro X-ray per kind (A3, `KillXray.ART`, 8 sets, frame 1 held, the inverse on alternate strobe
  pulses; `--xray-art=plain` = before). 64: the cop's own skeleton with cap and belt, hood/worker/SWAT each their own. 32:
  reads as the cop's (the cap), busier and darker than the plain sticker on dark asphalt (owner Call).
- MILESTONE 0dce9f3b6 plasma hole drawn ring (A4, cross-fade hot -> amber -> char over 150 ticks; `--hole-art=plain`).
  The hole now reads as a hole (the street through a torn charred ring with rib ends and spine), not a bullseye; the
  impact bloom at 32 px/m is weaker than the procedural cream bloom (owner Call; not tried: a short bloom under it).
- FRICTION 14:20 the plasma commit's full lint failed json-canonical on my NEXT item's unstaged schema edit: the
  pre-commit lint's json check read the work tree, not the staged snapshot (it said "linting the staged snapshot" on the
  retry, so this may be the first-run path). Canonicalised with tools/art/canon_json.mjs and re-committed.
- MILESTONE af3f9af1c chainsaw chunks, A5: row key `saw_chunks` 8 (schema), `KillSawChunks` throws meat, bone chips,
  a rib and a tooth on 18-tick arcs; they lie on the street 1.3-2.6 m off. First try 0.36 m cells sank into the blood
  pool at 64 px/m -> 0.46 m, thrown farther; reads at 64 and 32 (`--saw-chunks=off` = before).
- 14:37 GATES started on 49c7c0be9 (`node tools/gate/run.mjs --rev=49c7c0be9 --reels`, log build/gate_49c7.log).
- 14:45 FOUND (code read while the gate ran, matches the rank64 ray gun film t50-89): the ray gun's "cop falls back over
  as a plain death" is the HAT piece. GibCut.cut(whole) copies every sprite under rig.head into the hat, and the
  whole-figure walker card hangs under rig.head (RigHeadCard), so the kicked, spinning "cap" was the whole man drawn
  unclipped over his own dissolving body. Fix in the work tree: `figure` (the card while StreetWalkerCards.hides_parts)
  stays in the BODY only; test test_gib_cut_figure_hat.gd (written, not yet run: Godot busy with the gate).
- GATES on 49c7c0be9 (14:37-14:49): PASS lint 19/19, unit 2671/0/2, scenarios 55, parity bit-exact (mutation at 629),
  selftest look goldens 11/11 worst 0.00, export-audit 686/0. Reels running from 14:49 (build/gate/49c7c0be9423/reels.log).
- GATES on 49c7c0be9: REELS PASS (top, tilt70, combo all OK; 14:49-15:11): the whole gate is green on 49c7c0be9.
- 15:13 ray gun hat fix verified: test_gib_cut_figure_hat 2/2, film rg64_b vs rank64_ray_gun (1b823dbf7, same chapter
  and ticks; `evidence/n16-kills-polish/ray_gun_no_figure_hat_ab_64ppm_t50-89.png`): the spinning whole cop is gone.
  It EXPOSES the next defect: the dissolve's disc mask (BODY_R_M 0.62, centred on the body group) holds only his legs
  from t50, his head and torso clipped at once, so the dissolve still does not read as a man being eaten.

NEXT (iteration 4):
1. Ray gun mask: lift the disc to the drawn figure's middle and make it an ellipse that holds the whole 1.7 m card
   (rows: `dissolve_up_m` ~0.45, ry ~0.95 m, rx 0.62); the rings, motes and glow follow the same centre/ellipse
   (KillDissolveFx._rings/_motes use d.root.position). Film chapter:ray_gun 64/32 --on=kill:1+60, before = af3f9af1c.
   Then re-score ray_gun in KILLS.md and add DEFECTS #4's fix commit.
2. The gate is green on 49c7c0be9; the ray-gun commit after it touches GibCut (whole cuts: ray gun only): run unit +
   reels again on the final tip before the freeze.
3. Owner Calls to write in REPORT: X-ray per kind at 32 px/m (darker than the plain sticker), plasma ring impact pop
   (bloom gone), saw chunk size 0.46 m, plus iteration 2's (hot face, topple 80, cut_up_m 0.8, upright X-ray, bone gib).
4. A3 p55 X-ray sets when delivered (KillXray.ART by view); jogger/elder/etc map to ped_generic today.
5. Owed: the ghosts' four films (tonnage, dent, kerf, ohm), burn_char's flame column, p55 peek card still, fight_gate
   under the bench lock (new preloads: 8 X-ray strips ~244x120, plasma 384x128, chunks 480x48).

## Iteration 4 (2026-11-11 15:23, BUILD)

- 15:23 read JOURNAL, git log. The ray gun hat fix (verified at 15:13, test 2/2) was staged: committed 06deed4b5.
- Registry rules applied (motion-quality-gating): same-tick before/after at 64 and 32 px/m on game frames; the
  dissolve's read judged on the held beat k+10..k+40, where the ranking film said it fails.
- 15:45 ray gun mask: KillDissolveMask (split out of KillDissolveFx, size ratchet) fits an ellipse to the body's
  sprites (FIT 1.12 of the half extent); rings/motes/glow on the same ellipse via draw_set_transform. Test
  test_kill_dissolve_fit 3/3. Committed 999ec13db. Before = rg64_b (06deed4b5's tree), after = rg64_c (--rev=HEAD).
- 15:50 asset replies: A3 p55 X-ray for all 8 kinds DELIVERED 15:01 (`library/keyed/street/xray_<kind>_55_cells/1_{1,2}.png`);
  the asset lane has nothing open for me and asks for the next request. Sent A6 and A7:
- REQUEST assets: (A6) the hand cannon exit wound, beat = the blowback's aftermath: the body lies face-down ~3 m off
  along the shot, and its back is blown open where the round left. One drawn wound per frame, seen from above at 70 deg,
  laid OVER the lying body's back: a ragged torn hole in the jacket (cloth flaps curled out), red-and-ink meat inside,
  two or three cream rib ends and the spine's knuckles showing, a short red spatter tongue fanning out on ONE side (the
  shot direction = +x of the cell). 2 frames: 1 fresh (wet red, bright cream bone), 2 dried (darker red, matte).
  160 x 160 cells, the hole ~90 px across, transparent outside. One set serves every kind (the cloth flap colour is a
  neutral grey that reads on navy, grey and brown jackets); a cop-navy variant as frame 3 if cheap. p70, plus a p55
  set squashed ~0.8 vertically. Name `fx/exit_wound_70_cells/1_{1,2,3}.png` and `fx/exit_wound_55_cells/...`.
- REQUEST assets: (A7) the ray gun remains, beat = the dissolve's aftermath: the body is eaten to dust by the hot ring
  and what stays on the street is a low grey-cream ash heap with a drawn SKULL half sunk in it, two or three rib arcs
  and a forearm bone poking out, the empty uniform crumpled beside it (cop navy for frame set 1, neutral grey cloth for
  set 2), still glowing amber in the ash's cracks on frame 1, cooled on frame 2. 256 x 160 cells (the heap is wider
  than tall, ~220 px wide), transparent outside, ink-and-cream riso, no red (the ray cauterises). p70, plus p55.
  Name `fx/ray_remains_70_cells/<set>_{1,2}.png` (set 1 navy, set 2 grey) and `fx/ray_remains_55_cells/...`.
- MILESTONE 999ec13db ray gun ellipse mask: films rg64_b/rg64_c and rg32_b/rg32_c (06deed4b5 vs 999ec13db, chapter
  ray_gun, combo, kill at t49): before = legs in a disc; after = the whole cop lit in the glow (t50-80), then eaten
  inward by the hot ring onto the dust pile (t82-109), at 64 and 32 px/m.
  `evidence/n16-kills-polish/ray_gun_ellipse_mask_ab_{64ppm_t50-89,64ppm_t82-109,32ppm_x2_t50-109}.png`. KILLS 11 -> 14.
- 15:55 FOUND (burn ranking film t130-170 + code): KillCharFx's embers, smoke and flakes sit on the body group's origin
  (the walker card's feet), the ray gun's bug again; at 64 px/m the standing char cop shows no embers on him. Fixed in
  the tree with a shared `KillFigure` (the body's own sprite box; KillDissolveMask.fit now uses it). Plasma hole: a
  16-tick cream bloom under the drawn ring (BLOOM_TICKS; the 32 px/m pop Call). p55 X-ray: ART_55 (8 kinds, packed by
  `tools/art/xray_cells.py --pitch=55`), chosen when ViewMode.shared().art == "p55".
- REQUEST assets: (A8) the burn death's collapse, beat = after the charred man stands smoking (~55 ticks), he
  crumbles where he stands instead of only fading: 3 frames per kind, same cell format and scale as the it272/it359/
  it363 char cells (`p70/<kind>_char_hit.png`: 5 facings x 344 x 256, feet on the cell's FOOT_Y line), facing 1
  (towards the camera) is enough for a first pass: (1) knees buckle, the char body sagging, a shoulder breaking off,
  ember cracks wide and bright amber; (2) slumped on its knees, half the torso caved into ash, the SKULL showing
  through the burnt face, rib arcs through the chest; (3) a low ash heap with the skull and a forearm bone on top, the
  cap/helmet/hood (the kind's gear) charred on the heap. Ink and cream, ember amber, char grey; no red. Kinds first:
  cop_patrol, thug, ped_hood, cop_riot (the four most burnt in the reels), then swat, ped_cap, ped_punk, ped_jogger.
  Name `street/<kind>_char_collapse_70_cells/1_{1,2,3}.png`.
- MILESTONE ab2de6592 + 6c52eaa7d plasma bloom under the drawn ring: film ph32_c vs ph32_d (a56501ee5 vs 051802ce0,
  32 px/m, kill t55): the 16-tick 0.55 bloom was only a faint halo for ~5 ticks -> 6c52eaa7d alpha up to 0.83, held ~8
  of 20 ticks (re-filming ph32_e / ph64_e).
- MILESTONE 051802ce0 + b2c4051c2 burn embers/smoke on the figure: film burn64_a vs burn64_b (chapter flamethrower,
  kill t130): before, the "embers" were a hot scrap on the street at his feet and the smoke rose from his boots; after,
  the smoke rises off his shoulders and head, the embers at mid-body, but at 0.5 of the box's half-width they floated
  beside him (a card cell is ~2x the man's width) -> b2c4051c2 0.2 x 0.5 (re-filming burn64_c, burn32).
- 16:10 commits 4329ed869 p55 X-ray (A3 it426), unit 17/17 on the it4 tests (test_kill_figure 4, dissolve_fit 3,
  shock_xray +1, gib_cut_figure_hat 2).
- 16:20 films: ph32_e/ph64_e (6c52eaa7d): the bloom now pops t55-66 and is gone by t70 at both zooms
  (`evidence/n16-kills-polish/plasma_hole_bloom_ab_{32ppm_x2_t55-80,64ppm_t55-70}.png`). burn64_c (b2c4051c2): the
  embers on the figure were HIDDEN under his card (KillCharFx z 4, his parts reach +30) -> 6963740ef z 40; burn64_d:
  ember cracks glow on his shoulders and chest, smoke rises off his head
  (`evidence/n16-kills-polish/burn_embers_on_figure_ab_64ppm_x2_t150-250.png`). x55_a/x55_b (tilt = p55, electro,
  kill t116): the p55 set reads as the p55 cop (face under the cap, legs to the feet) but stood ~80% of the 2.0 m p55
  card -> KillXray.view_scale() (2.0/1.7 at p55; uncommitted, unit queued)
  (`evidence/n16-kills-polish/electro_xray_p55_set_ab_tilt64ppm_x2_t119-146.png`).
