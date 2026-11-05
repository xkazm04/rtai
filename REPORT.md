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
- Proof: `M:frames/tonnage-live-before-after-target-32ppm.png`, `M:tonnage-morph-64ppm-slow3x.mp4`,
  `M:tonnage-tour-city-32ppm.mp4` (both re-filmed in iteration 4).

### 2. Dent (the lurching brawler)
- DentPlan on base Rivet's CutRig with its own raw parts (yellow crash-test discs). DentLurch is the stagger:
  roll and yaw per stride, a limp. GhostAura is the breathing teal pool under the light forms.
- Proof: `M:dent-gait-ab-32ppm.mp4` (before | after), `M:dent-morph-64ppm-slow3x.mp4`,
  `M:frames/dent-live-vs-target-64ppm.png`.

### 3. Kerf (the fast one)
- KerfRig from a Codex part sheet: an arrow hull, emitter arms held in guard, blade legs trailing and sweeping
  back with speed, a hover bob, 12 m/s. The rig snaps with the blink (no tween).
- Proof: `M:kerf-morph-64ppm-slow3x.mp4`, `M:frames/kerf-live-vs-target-64ppm.png`, `M:kerf-rim-ab-32ppm.mp4`.

### 4. Ohm (the mage), iteration 4
- OhmRig from a Codex part sheet (r4 `ohm_parts`): a domed riveted shell with goggles, a cable beard, a copper
  hose, stubby feet, and two long arms with copper electrode fingers. Shell 0.8 m, so Ohm is smaller than Rivet.
- The cane gait: the right arm plants ahead and is left a stride behind, then swings; the gait advances with
  ground covered. The left arm holds its electrodes at the bolt's hands.
- Proof: `M:ohm-tour-city-32ppm.mp4` (with the rim), `M:ohm-morph-64ppm-slow3x.mp4`,
  `M:frames/ohm-live-vs-target-64ppm.png`. The arena clip was filmed (0 SCRIPT ERROR) but dropped at the
  frames.json cap.

### 5. All four
- `M:forms-cycle-all-32ppm.mp4` (15 s, `--bot=forms --form=all`): base, Tonnage, Dent, Kerf, Ohm, base.
- Form to form at 64 px/m: `M:frames/forms-switch-tonnage-dent-64ppm-keys.png`, `M:forms-switch-64ppm-slow3x.mp4`.
  Tonnage collapses into the teal ring and Dent stands up out of it in about 0.2 s, with no pass through base.
- Reduced motion: `M:frames/ohm-morph-reduced-motion-ab-64ppm.png` (same ticks). The burst ring keeps one size,
  the plates fly less, and the stages and end pose stay the same.
- **The cream sticker rim** (GhostRim, DECISION): the characters' own rim under Kerf's and Ohm's limbs and body,
  so their thin limbs hold on asphalt at 32 px/m. Proof: `M:frames/ohm-rim-ab-32ppm-x2.png`, `M:ohm-rim-ab-32ppm.mp4`,
  `M:kerf-rim-ab-32ppm.mp4`. The A/B flag is `--no-rim`.
- **Draw order**: the ghost bodies now draw above every rig part. Before the fix, cops' heads and arms covered
  Tonnage in the city: `M:frames/tonnage-city-z-ab-32ppm-x2.png`.
- Tonnage re-filmed on the live path: `M:tonnage-morph-64ppm-slow3x.mp4`, `M:tonnage-tour-city-32ppm.mp4`.

### 6. The voice moments (iteration 5): a teal apparition beside Rivet
- **GhostApparition** (`features/souls/ghost_apparition.gd`, DECISION): when a ghost speaks, its own body (a copy
  of its form rig) appears at Rivet's left shoulder, turned in to him and tethered by a teal hairline. Every part
  draws through `ghost_apparition.gdshader`: ink becomes deep teal, paper and steel pale teal, the sticker rims
  a teal glow edge, with faint scan bands. It flickers in (0.3 s), holds 2.5 s and fades (0.6 s). Tonnage's is
  drawn at 0.6 scale, as a voice rather than the 3x body.
- The cue is the stage's `whispers_spiked` (quest 1's whisper beats, Kilohm's line, the tazer hit, the fire)
  while Rivet is in base; the selected ghost speaks. In a form the ghost is Rivet, so nothing shows. The dev
  flag `--apparition` cycles the four every 4 s.
- Proof: `M:frames/voices-four-64ppm-keys.png` and `M:ghost-voices-arena-64ppm.mp4` (all four in turn),
  `M:ghost-voices-city-32ppm.mp4` (they hold on asphalt at 32), and the before/after at the same tick,
  `M:frames/voice-dent-ab-64ppm.png`. Unit test_ghost_apparition (envelope, one body, the whisper cue).
- On quest 1's real whispers: `M:frames/voice-quest1-real-whispers-48ppm.png`
  (`dev/ghost-forms/voice_quest1.gd`). Quest 1 is played by CollectCallBot as the scenario does, and the
  apparition is bound to the play's own event bus. The b1 dumpster whisper (tick 123) and Kilohm's line ("Hold
  still. You've been mutter...", tick 9626) both bring Tonnage's apparition up inside the whisper rings.
- Dent at 32 px/m (iteration 4's open point): he already carries CutRig's cream halo like the cops, so no change
  was needed (`M:frames/dent-city-halo-32ppm-x3.png`).

- **Dent on the car ride** (for ghost-powers, REQUEST 7): braced on the roof instead of striding at the car's
  speed, a buck on each strike, a hop on the blast. Before/after at the same ticks:
  `M:frames/dent-ride-braced-ab-32ppm-x1.5.png`; clip `M:dent-ride-braced-city-32ppm.mp4`.

### Gates (iteration 5)
- Final, on 8b6327f3 (the voices, `--teal-forms`, Dent's ride, both merges), still tree: evidence runner
  `--no-bench` all PASS: lint 13/13, unit 986/0, scenarios 47, parity bit-exact (mutation caught at 629), look
  goldens 11/11 in tolerance, no re-bless (`E:evidence-run-iter5-final.log`). Director reel 16/16 chapters down,
  0 SCRIPT ERROR (`E:director-reel-iter5-final.log`).
- On 56dae388 (the voices), the evidence runner `--no-bench` on a still tree (`E:evidence-run-iter5.log`): lint
  13/13, unit 981/0, scenarios 47, parity bit-exact (planted mutation caught at step 629), selftest with look
  goldens 11/11 in tolerance (worst 1.21), so no re-bless.
- On 633fb9d7: director reel 16/16 chapters down, 0 SCRIPT ERROR (`E:director-reel-iter5.log`).

### Gates (iteration 4)
- On 25b040bb: lint 13/13; unit 974/0 (`E:unit-iter4.log`); scenarios 47/0 (`E:scenarios-iter4.log`).
- On 70a6297a: director reel 16/16 chapters down, 0 SCRIPT ERROR (`E:director-reel-iter4.log`).
- On 19ae646c, the evidence runner `--no-bench` (`E:evidence-run-iter4.log`): lint, scenarios 47, parity (exact,
  planted mutation caught) and selftest all pass; look goldens 11/11 and block goldens 5/5 are within tolerance,
  so no re-bless. The unit step reads FAIL only because the tree changed during the run (I edited JOURNAL.md
  while it ran); the suite itself was 974/0. Re-run it on a still tree.
- On d4996f44 (the draw-order fix): scenario_ghost_attacks 1/0.

## What does not work / is open
- In the shipped quest 1 path (the sprite cast) GhostFormView is not attached, so the voices show there only
  under `-- --rigs` or in the dev grabber below. Attaching the ghost view to the sprite cast is not done.

## Calls for the owner
- **Rust steel on a teal pool, or fully teal ghosts?** The targets draw the ghosts teal all over. Ours print
  the machine body (gunmetal, rust, Dent's yellow discs) with teal seams, glow and a soul pool, which follows
  the brief's "machine body printed in the game's ink look, with teal soul seams and glow". Compare
  `M:frames/ohm-live-vs-target-64ppm.png`, `M:frames/dent-live-vs-target-64ppm.png` and
  `M:frames/kerf-live-vs-target-64ppm.png`. **Same-tick A/B: `M:frames/forms-teal-ab-32ppm.png`** (top as
  built, bottom with the dev flag `--teal-forms`, which gives the form rigs the voice apparitions' material). Fully
  teal reads strongly at 32 px/m but loses Dent's yellow discs and Tonnage's hazard stripes. Shipping it would
  mean turning that flag into a default.
- **Should the voice apparitions show in quest 1?** They are cued by every whisper while Rivet is in base,
  including quest 1's whisper beats, where the player has not yet met the ghosts by name. The alternative is
  to cue them only from the scientist's questline lines; that change is one connect in GhostApparition.bind.

## Next steps
- Give the shipped sprite-cast quest 1 a ghost view (or at least the apparition), if the owner wants the
  voices there.
- Final gates on a still tree (the evidence runner).
