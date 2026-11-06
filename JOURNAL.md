# JOURNAL - lane weapons (d8, 2026-11-06)

Branch `d8-weapons` cut from main `0bea8b93`. Evidence: `C:\Users\kazda\kiro\gtai-masters\d8\weapons\`.

## 14:10 iteration 1 (BUILD)
- Read: AGENTS.md, view.json (tilt = 55 deg, cards, cast_k 1.2 already), view REPORT (owed: draw
  order of overlays), held_classes.json, rivet_held_view.gd, docs/polish/ranged.md (capture recipe).
- Registry rules applied: motion-quality-gating (score per dimension on what is visible, unfilmed = ?,
  correctness is the floor), concept-scene-parity (judge in the live path, not on a sheet),
  generative-artifact-gating (look at every generated sheet, key + despill before use).

## 14:15-15:05
- FRICTION: the first audit batch (18 weapons, tilt, 48 px/m, `audit/*_48_before.mp4` in
  scratch) ran while I edited rivet_held_view.gd: 6 films (chainsaw, flamethrower, gatling,
  homing_shard, mini_nuke, rocket_launcher) carry 24 parse SCRIPT ERRORs from my half-landed class.
  They are CONTAMINATED; re-film them with `--held-pitch=off`. The other 12 are clean (0 errors).
- Audit observation (not yet scored per weapon): at 32-48 px/m under tilt every held gun is the
  top-down part, a dark ink lozenge beside the claw; tracers do leave the drawn tip (HeldMuzzle n7).
- MILESTONE `ea380dba`: HeldPitchArt + weapon_held_pitch.json (keyed by pitch "55"), the four
  sidearms as three-quarter parts (gen55b, made from the shipped pickups; the gen55 v1 from the
  r1_w1 sheet was rejected because those guns are not the ones Rivet picks up). Mirrored on a left aim.
- DECISION (also in docs/decisions.md): per-pitch held part, flip about the barrel line, `top` untouched.
- Look check at 64 px/m: first cut (size_k 0.85, no rim) read WORSE than the before (muddy, no
  cream rim). Fixed with WeaponArt's paper rim on the pitch part + size_k 1: now the pistol reads
  as a pistol with a body and grip (gtai-masters/d8/weapons/pistol_tilt_64_before_after.png).
- Generated, not yet cut: gen55/out/longguns_55.png (5 long guns, from r2_w5: CHECK against the
  shipped pickups first, regenerate from the pickups as for sidearms), gen55/out/blades_55.png.
- Tools in scratch `gtai-d8/scratch/weapons/`: film2.sh (OUT, EXTRA env), gen.mjs (9 min lock cap),
  cut.py (key+split+muzzle), grip.py (grip guess + preview; set grips by eye), table.py.

NEXT:
1. Full `node tools/tests/run_unit.mjs` + scenarios + director reel top and tilt (not run this session: only the
   targeted tests and lint ran).
2. Write docs/polish/weapons-tilt.md: score the 12 clean films + re-film the 6 contaminated; rank.
3. Long guns: regenerate from the shipped pickups (assault-rifle, plasma_rifle, electro_gun, ray_gun,
   homing_shard), cut with ROWS=1, grips by eye (the long-gun hold is two-claw: check fore_u lands
   under the barrel on the new part), then blades (katana, plasma_sword, electro_baton).
4. The flip: check the up/down aims (the grip sideways) and the sweep of a blade; the claw cell
   still draws over the grip.

## 14:39 iteration 2 (BUILD)
- Full unit run on d87722f9: 1413 passed, 0 failed (item 1 of the last NEXT).
- Re-filmed the 6 contaminated audit films with `--held-pitch=off`: all 0 SCRIPT ERROR.
- MILESTONE `fc66d277`: docs/polish/weapons-tilt.md (the audit, all 18 scored H/F/L, weakest first);
  long guns (plasma rifle, electro gun, ray gun, homing shard) and blades (katana, plasma sword,
  electro baton) as held_55 parts, generated from the shipped pickups (gen55c, image.want + lock,
  84 s per job), grips by eye.
- FOUND: the held_55 imports had mipmaps OFF (the shipped held parts have them ON); a 600 px part
  drawn 40-60 px wide aliased. All 11 now mipmapped.
- FOUND: the GUN print (print_part gun_tan) inks only luma < 0.1 and flattens the rest into one tan
  band, so a generated part with mid-brown line work printed as a blob. Print prep (scratch
  prep.py 0.17 2): line work to solid ink, grown 2 px; mid tones stretched. Applied to the 7 new parts.
- MILESTONE `ce6ed14d`: HeldPitchArt.stand: the part undoes the camera's sin(pitch) ground squash
  (drawn for the raised camera already, like RigHeadCard) and thins to EDGE_ON_K 0.5 as the barrel
  turns up/down the screen. Seen at 48 px/m (scratch stand/cmp2.png): the aimed plasma rifle and ray
  gun read as guns with a grip and body; the nose-down carry is a slim tube instead of a blob.
  `--held-pitch=squash` = the before. DECISION in docs/decisions.md.
- MILESTONE `258173e0`: ShotLift: drawn rounds, body/metal hits and enemy muzzle stars at gun
  height (1 m, ViewMode.lift_px) under tilt + a faint ink ground shadow under the round; ground
  hits stay down; `--shot-lift=off`. Fixes the audit finding "flamer hit spark at the feet".
- FRICTION (again): editing scripts while films run contaminates them (3 ev/64_after films with
  thousands of errors). Rule for myself: no edits under project/ while a film batch runs; re-filmed.
- Scenarios (on ce6ed14d, while 3 films ran): 52 ran, 1 failed = city_chase 2 ms nav budget
  (3497 us max), contention, not my files; re-run with run_scenarios.mjs --only=city_chase.
- Registry rules applied: generative-artifact-gating (looked at every sheet; grips by eye; rejected
  the unprepped print by looking at it in the live path), motion-quality-gating (scored only visible
  dims, `?` for unseen; judged in motion at 48), concept-scene-parity (the sheet looked right; the
  live print did not; judged in the live path), sprite-and-atlas-production (mipmaps for parts drawn
  far below source size).
- tool note: `node tools/godot/check.mjs` on weapon_fx_art.gd says "Failed to compile depended
  scripts" even though the unit run loads it with 0 SCRIPT ERROR (check-only quirk; don't trust it there).
- 5e3d8e25: ShotLift ground shadow 0.38/5 px (0.22/3 px was invisible); seen at 48 (ev/lift2.png).
- Director reel on 258173e0: top 19/19, tilt 19/19, 0 SCRIPT ERROR each (scratch reel_top.log,
  reel_tilt.log). city_chase alone (run_scenarios.mjs --only): 1 passed (so it was contention).
- Evidence: gtai-masters/d8/weapons/frames.json (8 entries). HONEST: at 32 px/m the long-gun after
  is bigger and muddier than the slim top-down part; at 48 and 64 it reads clearly better.
- FOUND (not fixed): at 64 px/m the plasma rifle floats ~10 px above-left of the claw;
  RivetCarryAngle.place_beside / the two-claw hold places it by the top-down geometry.
- FOUND: the gunplay bot with --weapon=katana: I could not confirm a katana is drawn (the frames
  show a gun-like part); blades unverified in the live path.
- MILESTONE c9828312: the long-gun float fixed. RivetCarryAngle.place_beside cleared the head by
  half the TEXTURE height; the 55 part is twice as tall (side body + grip), so the gun was pushed
  off the claw. HeldPitchArt.half_thickness gives the top-down barrel thickness for a pitch part
  (top unchanged). Seen at 64 px/m: gtai-masters/d8/weapons/plasma_rifle_tilt_64_float_fix.png.
  NOTE for chars: this touches one line of features/player/rivet_carry_angle.gd (held placement,
  not a hold class); top is bit-identical (no pitch rows under top).

NEXT (iteration 3):
1. Read the director reel result for c9828312 (scratch reel2_tilt.log / reel2_top.log; started 15:21).
   If it isn't 19/19 with 0 SCRIPT ERROR in both views, fix that first.
2. The 32 px/m read (the shipped zoom): the long-gun 55 parts are bigger and muddier than the top-down
   silhouette. Options:
   - size_k 0.8 per row (one data value);
   - a held LOD below ~40 px/m (WeaponArt has `small` parts for top: make 55 small parts, prepped
     harder: ink 0.22, grow 3, fewer plates).
   Film both at 32 and pick; a Call for the owner if it stays a judgement call.
3. Blades: film them in melee (the director reel's katana / plasma_sword_deflect / electro_baton
   chapters with --view=tilt --ppm=48 --write-movie, not the gunplay bot) and check the grip, the
   flip on a left swing, and the sweep (MeleeSwing) with the three-quarter part.
4. Heavy, tube and thrown parts: chainsaw, flamethrower wand, gatling, rocket launcher, mini nuke,
   molotov. Generate from the shipped pickups (gen55c recipe, image.want + lock), cut, prep.py
   0.17 2, grips by eye, mipmaps ON in the .import.
5. FX at height, still owed: the flame tongue (CONE jet) and the electro arc start at the drawn tip
   (check the films); the melee smear in the tilted plane.
6. The sidearms (iteration-1 parts) were never print-prepped: run prep.py on them and compare at 48.
7. Clean scratch (3.6 GB, mostly audit mp4s) before the freeze: keep only what frames.json and
   docs/polish/weapons-tilt.md name.
- 15:25 DONE from NEXT: (1) the director reel on c9828312 is tilt 19/19 and top 19/19, 0 SCRIPT ERROR;
  the full unit run is 1418 passed, 0 failed. (6) 094a0661: the sidearms are print-prepped (a small
  gain at 48 px/m, gtai-masters/d8/weapons/pistol_tilt_48_prep_zoom4x.png).
  The rest of NEXT stands (2, 3, 4, 5, 7).
## 15:28 iteration 3 (BUILD)
- 15:28 Read JOURNAL, git log. Image lock held by the assets lane: touched image.want, gen.mjs waited.
- gen55d (image.want + lock, 82 s + 75 s): heavy_55d (chainsaw, gatling, flame wand: the ref strip
  had the tanks masked out so only the wand is drawn) and tubes_55d (rocket tube, mini-nuke, molotov),
  both from the shipped pickups. Looked at both sheets: designs match the pickups, three-quarter, clean
  green, vermilion only on the warhead stripes / hazard plate / rag (as on the shipped art).
- Cut (cut.py tol 14), grips by eye on a 50 px grid (chainsaw on the engine at the bar line, gatling
  and flame wand on the pistol grip, tubes on the pistol grip, molotov mid-bottle), prep.py 0.17 2.
  Tubes get an `empty` part (warhead cut away right of the front ring) so HeldTube's spent-tube swap
  works on the pitch part (it would have put the top-down empty texture on the 55 sprite).
- 32 px/m read (NEXT 2): `small` held_55 parts (tools/art/held_pitch_small.py: held_small.py's
  re-tone on the UNPREPPED cut; re-toning the prepped part keeps its grown ink and stays a blob, seen
  in the print sim) swapped by HeldLod below held_small_below_ppm (56), as for `top`.
  Filmed at 32 tilt, same seed, `--held-small=off` = before (scratch lod32/cmp32.png): pistol and
  plasma rifle nearly identical; Gloria goes two-tone dark (as under top). HONEST: a marginal gain;
  the 32 px/m issue is the part's size and silhouette (a pale club), not its tones.
- Row moved to its own class HeldPitchRow (held_pitch_art.gd stayed under 200 lines).
- NOTE for chars: features/player/held_tube.gd: HeldTube.apply asks HeldPitchArt.row_of first (a
  pitch part swaps to its own empty part); top unchanged (no pitch rows under top).
- MILESTONE 7d93ac4a: the six heavy/tube/thrown 55 parts + tube empties + small cells (16 films at 48 and
  32 tilt, all 0 SCRIPT ERROR). Seen at 48: rocket tube and mini-nuke clearly better (flared back, sight,
  grip, fins); flame wand better (hose); chainsaw reads at the hip (director chapter); Gatling WORSE
  (a fat tan tube); baton no gain.
- FOUND: the D4 print sim in held_small.py does not model the gun print the held parts use; judge
  held parts only in the live path.
- MILESTONE 8c64bdeb: the 55 plasma sword's coil hilt printed as an ink blob at 48; its small cell fixes
  it (gtai-masters/d8/weapons/plasma_sword_tilt_48_full_vs_small_zoom.png).
- Melee films: director chapters with `--chapter=<id>` (scratch melee.sh), not the gunplay bot (which
  never wields a blade: the frames show a gun in the claw and the chainsaw at the hip).
- Gates on 8c64bdeb: full unit 1420 passed / 0 failed; director reel headless top 19/19 and tilt 19/19,
  every chapter all down, 0 SCRIPT ERROR; lint 15/15.
- 58981c79: weapons-tilt.md iteration 3 table + DECISION (small cells for pitch parts) in docs/decisions.md.
- Evidence: gtai-masters/d8/weapons/frames.json now 14 entries (tubes, blades, heavy, plasma sword zoom first).
- MILESTONE f0651a19: the Gatling keeps its top-down part under tilt (55 row `enabled: false`, the art
  stays). Filmed 3 variants at 48 (size_k 1, 0.85, small without close_gaps): all a pale club; the slim
  top-down bundle reads more as a rotary gun (gtai-masters/d8/weapons/gatling_tilt_48_variants.png).
  DECISION in docs/decisions.md.
- Flame jet at 48 tilt (scratch heavy48/fl_zoom.png): on a nose-down aim the jet leaves the wand's tip
  by Rivet's legs; body flames on the cop, the burst on the ground. F = 2.
- 32 px/m size A/B (plasma rifle, size_k 1 vs 0.8; gtai-masters/d8/weapons/plasma_rifle_tilt_32_size_k.png):
  0.8 a touch slimmer, still a pale club. Kept 1 (detail at close range is the brief's weight). Call for
  the owner: size_k per zoom, or a slimmer drawn part for 32.
- FRICTION: I queued a "size_k 1" film after a data edit to 0.8 in one chain; it read 0.8. Discarded it.
  Rule: one data state per film chain.
- Registry rules applied this session: motion-quality-gating (judged in motion on the live path, `?` for
  unseen dims, a regression found and reverted to the before: Gatling); generative-artifact-gating
  (looked at every sheet before cutting; masked the tanks out of the flame reference; rejected the D4
  sim as a judge for gun-print parts); concept-scene-parity (every call made on filmed frames, not on
  the sheet); sprite-and-atlas-production (mipmaps on every new import; same-canvas LOD cells so grip
  and muzzle stay valid); depth-ordered-layered-art (the rim copies swap with the LOD cell, Rim%d names).
- 15:58: gen55g: a regenerated 55 Gatling (dark barrels with gaps, compact receiver), image.want + lock.
- MILESTONE 5c71e55e: the regenerated 55 Gatling (gen55g, 64 s; dark gunmetal barrels with gaps, compact
  receiver; scaled 0.4, prep.py 0.17 2, no small cell: the re-tone would lift the barrels) is drawn again
  (`enabled: true`). At 48 aimed it reads as a rotary gun with receiver depth (on par with or better than the
  top-down part); carried nose-down it is a thin dark stick. DECISION (supersedes f0651a19's) in decisions.md.
- Gates on 5c71e55e: full unit 1421 passed / 0 failed; director reel headless top 19/19 and tilt 19/19, all
  down, 0 SCRIPT ERROR; lint 15/15.
- Evidence: gtai-masters/d8/weapons/frames.json (15 entries) + weapons_tilt_set_combined.mp4 (49 s, full
  frames). Removed pistol_tilt_48_prep_zoom4x.png from masters to stay at 15 (the iteration-2 line above
  names it; the source film is gone too, so it is not re-makeable: it was a small prep gain).
- Scratch cleaned: superseded film mp4s deleted (4.7 GB -> ~2.2 GB); kept audit/, heavy48/, lod32/, melee/
  (the before/after sources of the masters stills).

## Calls for the owner (for REPORT)
- Gatling under tilt: the regenerated 55 part (default, 5c71e55e) vs the top-down part (`enabled: false` in
  weapon_held_pitch.json). See gtai-masters/d8/weapons/gatling_tilt_48_regen_before_after.png.
  Exe (showcase preset, main scene = the arena): `RTAI.exe -- --weapon=gatling --bot=gunplay --lone --cam=fight --ppm=48 --view=tilt --rigs` (+ `--held-pitch=off` for the before); these are the flags of every film here (scratch film2.sh), not yet run on an exported exe.
- Long guns at 32 px/m: size_k 1 (default) vs 0.8 (slimmer, still a pale club):
  gtai-masters/d8/weapons/plasma_rifle_tilt_32_size_k.png. One value per row.

NEXT (iteration 4):
1. DONE 16:05: scenarios on 5c71e55e: 52 passed (headless).
2. Electro baton at 48: no gain over the before (a thin stick, a dark coil). Try a regenerated part with a
   thicker cream body and fewer coils, or `enabled: false` (judge on the director chapter, melee.sh).
3. The melee smear in the tilted plane (MeleeSwing) and the electro arc at the drawn tip: film the
   electro_gun and the electro_chain chapter at 48/64 and score F.
4. 32 px/m long guns: the 55 parts read as pale clubs. Try a darker/inked small cell for the long guns
   only (like the Gatling fix: contrast, not lift), or a slimmer re-cut; film at 32 and pick.
5. Assault rifle (Gloria?) row in the audit was `?` (bot leaves the crop): film with a wider crop.
6. Freeze 18:30: export the exe (int-day recipe in docs/decisions.md), REPORT.md by 18:40.
- 16:09 NEXT 2 tried: gen55h, a regenerated bolder baton (56 s, image.want + lock). Filmed at 48 in its director
  chapter (scratch baton_cmp.png): the ink-wrapped grip prints dark and the copper band reads reddish at
  game size (too near the blood/vermilion law); no better than v1. REJECTED, reverted (art not committed).
  Next try for the baton: a pale wrap, the copper band brass-toned, or `enabled: false`.
- 16:12 NEXT 3 started: filmed electro_gun at 48 tilt (scratch arc/electro_gun_48_after.mp4, 0 SCRIPT ERROR).
  The auto-crop (vermilion collar) locked onto the cops' tracers instead (they fly at height with their
  ground shadows, as ShotLift intends); no arc frame found by the cream-pixel search. The arc origin is
  UNSCORED (?); next session: step the film by hand round Rivet's shots (or use the electro_chain chapter).
- Session end 16:13. Branch head is clean; every item above is committed. NEXT (iteration 4) above stands,
  with 1 done and 2 tried (baton regen rejected).
## 16:12 iteration 4 (BUILD)
- 16:13 Read JOURNAL, git log; no REQUESTs to weapons in the other lanes' journals.
- FOUND (code): the flame jet's tongues and embers drew at s.pos, the sim's GROUND line, while the nozzle
  lick sits at the drawn wand tip (HeldMuzzle): under tilt the stream ran along the floor, below the gun.
- MILESTONE a06036e6: ShotLift.jet lifts the jet to gun height and pulls it onto the drawn wand tip near
  the nozzle (let go by 2 m); embers follow. Top: ZERO lift (unit test). Filmed at 48 tilt, same bot,
  `--shot-lift=off` = before: the stream now leaves the wand tip; the tongues reach the cop's chest
  (gtai-masters/d8/weapons/flamethrower_tilt_48_jet_before_after.png). Flame F: 2 -> 3 (start at the tip).
- FRICTION: film.sh ignores OUT (hard-coded audit/); films launched with `( ... &)` in a Bash call die with
  the call; use run_in_background. A `var tip` in jet() shadowed a new `tip()` (warning = error): the
  films that started on it were killed and discarded.
- Electro gun at 48 tilt (director chapter electro_gun): the arc leaves the drawn coil tip at gun height
  and the shock lands on the body (2). But the CHARGE crackle (FightChargeArt.crackle: gathering arcs + a
  cream core) drew at the ground muzzle point by Rivet's feet (scratch arc/shots.png). Fix: ShotLift.claw_at
  (HeldMuzzle under tilt, the ground point under top). Renamed from tip() (a local var shadowed it).
- MILESTONE ddf61c87: the charge crackle gathers on the drawn coil tip at gun height; same fight, before vs
  after: gtai-masters/d8/weapons/electro_gun_tilt_48_charge_before_after.png.
- REVERTED (unfilmed): raising the reload ring above the tall rig's head under tilt. No reload showed in the
  filmed pistol fight (collar-cropped frames, scratch arc2/ring_crops.png), so it is left as an open item.
- Katana smear (melee/katana_48_after.mp4): drawn in the squashed ground plane about the grip, i.e. the
  tilted plane at hand height; only faintly visible under the hit star at 48 px/m (F 1). No change.
- 32 px/m long guns (NEXT 4): two small-cell variants from the raw cut (scratch tt32 = held_small.two_tone,
  mix32 = 55 % two-tone over the re-tone), filmed one data state at a time (vary.sh: copy, --import, film).
  FRICTION: films after a PNG swap need `--import` first (the run uses the .godot cache).
- MILESTONE df1ee16c: the 55 small cells (drawn below 56 px/m) of plasma rifle, electro gun and ray gun
  are two-tone (held_pitch_small.py TWO_TONE). Filmed at 32 tilt, same bot: re-tone (shipped) = a pale club
  merging with the visor and legs; two-tone = a dark gun with pale details, also in the nose-down carry; the
  55 % mix stayed muddy (scratch tt32/pr_cmp*.png, eg_cmp.png). Still:
  gtai-masters/d8/weapons/longguns_tilt_32_twotone_before_after.png. DECISION in docs/decisions.md.
- frames.json: + flame jet, + charge crackle, + 32 two-tone; - gatling variants (superseded), - plasma
  rifle float fix, - the old 32 pair (superseded). Still 15.
- Baton (NEXT 2): compared before (top-down part) / 55 full / 55 small in its chapter at 48 (scratch
  baton_ab.png): the top-down part is the darker, higher-contrast stick; the 55 parts are a pale tube with a
  dark tip. Queued: a two-tone 55 small cell for the baton and the homing shard (scratch vary2.sh).
- Gates on df1ee16c: full unit 1423 passed / 0 failed; director reel headless top 19/19 and tilt 19/19, every
  chapter all down, 0 SCRIPT ERROR; lint 15/15 (pre-commit).
- vary2 (two-tone small cells, filmed; same seed): homing shard at 32 tilt = a dark gun with pale crystals and a
  flared muzzle instead of a pale blob: TAKEN (gtai-masters/d8/weapons/homing_shard_tilt_32_twotone_before_after.png).
  Electro baton at 48 in its chapter = a solid black stick, its pale bands gone: REJECTED (scratch tt4/baton_cmp.png).
  The baton keeps its 55 cells; of the three, the top-down part reads best (dark shaft, pale bands, prongs).
- 80864ce8: NEXT 5 closed: "assault rifle" is not a weapon (the arena kept Gloria).
- MILESTONE (reload ring): under tilt the ring sat on Rivet's visor; lifted 1.2 gun heights it floats above the
  head (rocket tube at 48 tilt, same bot, `--shot-lift=off` = before, frame 320):
  gtai-masters/d8/weapons/reload_ring_tilt_48_before_after.png. `--changed` unit run 1407 passed / 0 failed.
- frames.json: + reload ring (6), - ray_gun_tilt_64_after.mp4 (a plain clip). 15 entries.
- Registry rules applied this session: motion-quality-gating (every change judged on the live path in motion,
  same bot before/after, one data state per film chain; the baton two-tone rejected on film; the reload-ring
  edit was reverted until a film showed it, then re-landed with evidence); generative-artifact-gating (no new
  generations; the two-tone cells derived from the already-gated cuts, pixel-checked against the filmed ones);
  concept-scene-parity (32 px/m calls made on game frames, not on the part sheet); sprite-and-atlas-production
  (small cells on the same canvas, so grip and muzzle stay valid; .import untouched); depth-ordered-layered-art
  (the FX lifts keep the ground marks on the ground: fire patches, dust).

## Calls for the owner (add to REPORT)
- The 55 long guns at 32 px/m: two-tone small cells (default, df1ee16c/f93334a1) vs the re-tone (drop the ids
  from TWO_TONE in tools/art/held_pitch_small.py and re-run it). See
  gtai-masters/d8/weapons/longguns_tilt_32_twotone_before_after.png. Exe:
  `RTAI.exe -- --weapon=plasma_rifle --bot=gunplay --lone --cam=fight --ppm=32 --view=tilt --rigs`.

- Electro baton under tilt at 48 (its director chapter, same seed): the top-down part (dark shaft, pale bands,
  prongs) vs the 55 part (pale tube, dark tip) vs the 55 small cell. Default kept: the 55 cells (more side
  detail at 56+ px/m). Alternative: `enabled: false` on the baton row of weapon_held_pitch.json. See
  gtai-masters/d8/weapons/electro_baton_tilt_48_topdown_vs_55.png. Exe:
  `RTAI.exe -- --bot=reel --reel=director --chapter=electro_baton --loadout=pistol --ppm=48 --view=tilt --rigs`
  (+ `--held-pitch=off` for the top-down part).

NEXT (iteration 5):
1. DONE 16:48: gates on 530d0f7b: director reel top 19/19 and tilt 19/19, all down, 0 SCRIPT ERROR; scenarios
   52 ran, 0 failed (headless). (Was: read the gate result; if not 19/19 + 0 SCRIPT ERROR in both
   views and scenarios green, fix that first.
2. DONE 16:50 (70 s, four captioned iteration-4 segments appended). Was: refresh the combined clip (gtai-masters/d8/weapons/weapons_tilt_set_combined.mp4, iteration 3) with today's
   FX: the flame jet from the tip, the charge on the coil, the two-tone long guns at 32, the reload ring.
3. Melee smear at height: F 1 (faint under the hit star at 48). Try a stronger ink band (INK_A) for the
   tilted view only, or keep. Film the katana chapter at 48/64.
4. Electro baton: now an owner call (above). Optional: a pale-wrap regen, filmed in its chapter.
5. Freeze 18:30: export the exe (int-day recipe in docs/decisions.md) to build/export/windows/RTAI.exe, run
   `node tools/evidence/run.mjs --no-bench`, write REPORT.md by 18:40 (Calls for the owner above and in the
   iteration-3 block).
6. Scratch is 2.8 GB: before the freeze delete what frames.json and weapons-tilt.md do not name.
- Session end 16:48. Branch head clean; every item above committed.
