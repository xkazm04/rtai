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
