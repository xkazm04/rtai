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
