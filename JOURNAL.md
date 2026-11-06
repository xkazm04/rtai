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
