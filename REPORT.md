# REPORT: lane n6-ghost-forms (branch `n6-ghost-forms`), night run 2026-11-04 -> 11-05

DRAFT written in iteration 4 (02:30); the report session at 08:40 finishes it. Until this iteration the
root REPORT.md on this branch was n5-cast's (it came in through a merge); n5-cast's own copy is on its
branch. `M:` = `C:\Users\kazda\kiro\gtai-masters\n6\ghost-forms\`, `E:` = `evidence/` here.

The owner's order for this lane: "create these characters, animate transformation between characters".

## What works

### 0. The frame
- **GhostForms** (`features/souls/ghost_forms.gd`), a state machine over `data/tables/ghost_forms.json`:
  base, entering, settled, switching, exiting. Enter 0.5-0.9 s and exit 0.5-0.7 s, each in two stages around
  one in-between pose; form to form goes through a 0.35 s teal flash with no pass through base (DECISION).
  A switch taken mid-transformation is refused, and a planted one is caught by `check()` (unit).
- **One SoulPowers** behind every ghost: one form at a time, one Madness meter, the existing cooldowns as the
  cost model (rows in `powers.json`; `tonnage -> hauler` and `dent -> gearbox` keep the old ids as aliases).
  Each row has `upgrade_tier` 0, the slot for the per-act quest upgrades.
- **Input** (DECISION): Q / LB (`power_hauler`) transforms into the selected ghost or back to base; G / RB
  (`power_gearbox`) picks the next ghost in base, or switches straight to it in a form. The bits are looked up
  by action name. Rejected: a radial menu, one key per form.
- **GhostPilot** on StagePilot drives the live game paths (`--arena`, `--arena=city`, quest 1). The attacks
  (lane ghost-powers) fire only while the form is settled. A transformation roots Rivet to a fraction of his walk.
- **GhostFormHud**, a D5 card: four chips with each ghost's mark, the current form in teal, the next pick with
  the key hint, the cooldown sweep, the Madness bar with the selected cost notch.
- **GhostMorphFx**: a teal burst, seams opening, cream steam puffs under one ink rim, sparks. **Camera beat**:
  one CameraRig shake at the in-between pose (`crash` for Tonnage, `hit` for the light forms), inside
  camera.json's budget and scaled down under reduced motion.
- **Data**: every form row holds footprint radius, body class, top speed, acceleration, turn rate, size,
  enter/exit time, gait, the attack anchors for ghost-powers, and the name key.

### 1. Tonnage (the big form, "Rivet's transformed form" DECISION)
- TonnageRig from a Codex part sheet: a 2.3 m crown with the hazard brow and hoses, four piston legs at the
  corners, the stamp gait, momentum (4.2 m/s, accel 5), radius 1.3 m on the big body class.
- Proof: `M:tonnage-live-arena-32ppm.mp4`, `M:frames/tonnage-live-before-after-target-32ppm.png`. The 64 px/m
  slow clip and the city clip were deleted at the frames.json cap in iteration 3; they need re-filming.

### 2. Dent (the lurching brawler)
- DentPlan on base Rivet's CutRig with its own raw parts (yellow crash-test discs). DentLurch is the stagger:
  roll and yaw per stride, a limp. GhostAura is the breathing teal pool under the light forms.
- Proof: `M:dent-gait-ab-32ppm.mp4` (before | after), `M:dent-morph-64ppm-slow3x.mp4`,
  `M:frames/dent-live-vs-target-64ppm.png`.

### 3. Kerf (the fast one)
- KerfRig from a Codex part sheet: an arrow hull, emitter arms held in guard, blade legs trailing and sweeping
  back with speed, a hover bob, 12 m/s. The rig snaps with the blink (no tween).
- Proof: `M:kerf-tour-arena-32ppm.mp4`, `M:kerf-morph-64ppm-slow3x.mp4`, `M:frames/kerf-live-vs-target-64ppm.png`.

### 4. Ohm (the mage), iteration 4
- OhmRig from a Codex part sheet (r4 `ohm_parts`): a domed riveted shell with goggles, a cable beard, a copper
  hose, stubby feet, and two long arms with copper electrode fingers. Shell 0.8 m, so Ohm is smaller than Rivet.
- The cane gait: the right arm plants ahead and is left a stride behind, then swings; the gait advances with
  ground covered. The left arm holds its electrodes at the bolt's hands.
- Proof: `M:ohm-tour-arena-32ppm.mp4`, `M:ohm-tour-city-32ppm.mp4`, `M:ohm-morph-64ppm-slow3x.mp4`,
  `M:frames/ohm-morph-64ppm-keys.png`, `M:frames/ohm-live-vs-target-64ppm.png`.

### 5. All four
- `M:forms-cycle-all-32ppm.mp4` (15 s, `--bot=forms --form=all`): base, Tonnage, Dent, Kerf, Ohm, base, plus
  `M:frames/forms-cycle-all-32ppm-keys.png`.

### Gates (iteration 4, on 25b040bb)
- lint 13/13; unit 974/0 (`E:unit-iter4.log`); scenarios 47/0 (`E:scenarios-iter4.log`).
- Not yet run on this head: the evidence runner and the director reel.

## What does not work / is open
- At 32 px/m Ohm's arms and Kerf's limbs are thin; the bodies read mainly through the teal pool and the marks.
- The Tonnage 64 px/m slow clip and city clip need re-filming (see section 1).
- Ghost apparitions for the voice moments are not started.

## Calls for the owner
- **Rust steel on a teal pool, or fully teal ghosts?** The targets draw the ghosts teal all over. Ours print
  the machine body (gunmetal, rust, Dent's yellow discs) with teal seams, glow and a soul pool, which follows
  the brief's "machine body printed in the game's ink look, with teal soul seams and glow". Compare
  `M:frames/ohm-live-vs-target-64ppm.png`, `M:frames/dent-live-vs-target-64ppm.png` and
  `M:frames/kerf-live-vs-target-64ppm.png`. The alternative is one modulate per rig.

## Next steps
- Thicker silhouettes at 32 px/m (Ohm's arms; a pale rim on Kerf and Ohm), then A/B.
- Re-film Tonnage's 64 px/m slow and city clips.
- Final gates (evidence runner, director reel), then the apparitions if time allows.
