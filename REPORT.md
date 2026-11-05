# REPORT: lane n6-ghost-forms (branch `n6-ghost-forms`), night run 2026-11-04 -> 11-05

Written through the night (first draft in iteration 4, 02:30); final as of the 08:30 freeze (iteration 14), gate line updated in iteration 17 (08:37); every `M:`/`E:` path re-checked in iteration 18 (08:42). Until iteration 4 the
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
- Proof: `M:dent-gait-ab-32ppm.mp4` (before | after), `M:frames/dent-live-vs-target-64ppm.png`; Dent's
  transformation at 64 px/m only as form to form (`M:forms-switch-64ppm-slow3x.mp4`, Tonnage -> Dent). The
  base -> Dent slow close-up was filmed but deleted at the frames.json cap in iteration 4 (see "What does not work").

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
- **The kick per bolt** (iteration 6, for ghost-powers, REQUEST 8): on each bolt the guard hand thrusts 0.2 m into
  the prongs and eases back over 0.25 s, the shell twists 16 deg and recoils 0.1 m, and the cane holds its plant.
  Halved under reduced motion. The request's size (0.12 m, 9 deg) did not read at 64 px/m, so it was raised.
  Before/after at the same ticks: `M:frames/ohm-bolt-kick-ab-64ppm.png`; clips
  `M:ohm-bolt-kick-64ppm-halfspeed.mp4` and `M:ohm-bolt-kick-city-32ppm.mp4` (the twist reads at 32 on every bolt).

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
- **On the shipped quest 1** (iteration 6, DECISION): the sprite-cast quest 1 had no ghost view, so the whisper
  showed only rings. `StoryVoice` (`boot/collect_call/view/story_voice.gd`) now draws the apparition there, in the
  city's actor layer. It is view only: headless runs have no view, so scenarios and replay are untouched. Proof:
  `quest1.tscn` as shipped, played through real pad events (`dev/ghost-forms/quest1_shipped_main.gd`). At b1's
  dumpster whisper Tonnage rises in teal beside Rivet inside the rings, then fades:
  `M:story-voice-quest1-shipped-32ppm.mp4`, and the same-frame A/B (flag off/on)
  `M:frames/story-voice-quest1-shipped-ab-32ppm-x2.png`. The alternative is one data value: `ghost_forms.json`
  `story_voice` false. The apparition draws over a cop walking past.
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

### 7. The forms on the shipped quest 1 (iteration 7, DECISION)
- The shipped quest 1 (the sprite cast, no `--rigs`) already ran the ghost forms in the sim: Q / LB transformed
  Rivet. On screen, though, only the old Hauler sprite growth showed, and Dent, Kerf and Ohm drew plain Rivet.
  **StoryForms** (`boot/collect_call/view/story_forms.gd`) now draws them there with the same GhostFormView as the
  arena: the bodies, the teal transformation, the camera beat and the HUD card. Rivet's sprite steps out while a
  body stands in, and his health bar rides above Tonnage. The ghost voice there is now the selected ghost, and it
  stays silent while Rivet is in a form. The alternative is one data value: `ghost_forms.json` `story_forms` false.
- Proof: `quest1.tscn` as shipped, played through real stick and Q / G key events
  (`dev/ghost-forms/quest1_forms_main.gd`), 0 SCRIPT ERROR. `M:story-forms-quest1-shipped-32ppm.mp4` (19 s: walk,
  Tonnage, out, Dent, Kerf, Ohm, out), and before/after at the same frames
  `M:frames/story-forms-quest1-shipped-ab-32ppm.png`.
- **Ohm's teal soul seams** (DECISION): at 32 px/m on that asphalt Ohm's dome read as an olive blob, because the
  art's hairline seams are lost at 26 px. OhmSeams draws two row seams, the spine and two teal goggle lenses on the
  shell. It turns and kicks with the shell. Before/after at the same frames:
  `M:frames/ohm-seams-quest1-ab-32ppm-x3.png`. The maroon edge pixels in that still are video-encoder ringing; the
  lossless frame is `M:frames/ohm-seams-lossless-32ppm-x8.png`. In the arena with the bolt:
  `M:frames/ohm-seams-arena-ab.png`. The dev flag `--no-seams` gives the A/B before.
- **The form card folds beside the story's subtitle box** (DECISION): while a line is up, the card shows the one
  chip that matters (the current form; in base the selected ghost) with its Madness bar, and it unfolds when the
  line closes. Before, the box hid the last three chips, and the chip peeking out showed Tonnage while Rivet was
  Dent. Before/after at the same frames: `M:frames/form-card-fold-quest1-ab-32ppm.png`. The shipped clip
  `M:story-forms-quest1-shipped-32ppm.mp4` was re-filmed on that head.

- **Rivet's health bar clears each body** (iteration 9, DECISION): Kerf's front blades reach about 1.6 m forward
  and crossed the bar at 1.2 m. The bar height is now one data value per form, `ghost_forms.json` `bar_m` (Kerf
  1.9, Tonnage 2.35, Dent and Ohm 1.2). Before/after at the same frames: `M:frames/kerf-bar-quest1-ab-32ppm-x3.png`.
  Through a transformation the bar eases between the two bodies' heights instead of snapping at the midpoint
  (`M:frames/bar-ease-tonnage-entry-ab-32ppm-x2.png`).
- **The 64 px/m close-up on the shipped path** (iteration 9): the same driver with `-- --ppm=64` (the game's own
  zoom). `M:frames/story-forms-quest1-keys-64ppm.png` (Rivet, the teal burst, the press settled; Dent, Kerf and Ohm
  settled), `M:story-forms-quest1-shipped-64ppm.mp4` (19 s) and `M:story-forms-quest1-tonnage-64ppm-slow3x.mp4`
  (Tonnage in and out, 3x slow). 0 SCRIPT ERROR.

### Gates (iteration 7)
- On 91b6b866 (the forms on the shipped quest 1), still tree: evidence runner `--no-bench` all PASS. Lint 13/13,
  unit 1000/0, scenarios 47, parity bit-exact (mutation caught at 629), look goldens 11/11 (worst 1.22), block
  5/5 (worst 1.38), no re-bless (`E:evidence-run-it7.log`). Director reel on 299a5772: 16/16 chapters down, 0
  SCRIPT ERROR (`E:director-reel-it7.log`).
- **Final, on 1f717c6f** (the forms on the shipped quest 1, Ohm's seams, the folding card), still tree: evidence
  runner `--no-bench` all PASS: lint 13/13, unit 1002/0, scenarios 47, parity bit-exact (mutation caught at 629),
  look goldens and block goldens in tolerance, no re-bless (`E:evidence-run-it7-final.log`). Director reel on
  5019d2f8: 16/16 chapters down, 0 SCRIPT ERROR (`E:director-reel-it7-final.log`).
- On 457e9551 (Ohm's seams): lint 13/13, unit 1001/0; director reel 16/16 chapters down, 0 SCRIPT ERROR
  (`E:director-reel-it7-seams.log`).

### Gates (iteration 9)
- On 95aa969e (merged n6-ghost-powers 9b5ae95f and n5-cast 31e665fa, Kerf's bar, the 64 px/m driver), still
  tree: evidence runner `--no-bench` all PASS: lint 13/13, unit 1008/0, scenarios 47, parity bit-exact (mutation
  caught at 629), look goldens 11/11 (worst 1.22), block goldens 5/5 (worst 1.38), no re-bless
  (`E:evidence-run-it9.log`). Director reel on d5e2f3e5: 16/16 chapters down, 0 SCRIPT ERROR
  (`E:director-reel-it9.log`).
- **Final for this session, on d41ff115** (+ the n6-ghost-powers cefbcf8b and n5-cast 551ed9c6 merges and the
  bar ease), still tree: evidence runner `--no-bench` all PASS: lint 13/13, unit 1011/0, scenarios 47, parity
  bit-exact, look and block goldens in tolerance, no re-bless (`E:evidence-run-it9-final.log`). Director reel on
  b540f1aa: 16/16 chapters down, 0 SCRIPT ERROR (`E:director-reel-it9-ease.log`).

### 8. The camera keeps Tonnage clear of quest 1's subtitle box (iteration 11, DECISION)
While a subtitle line is up, the shipped quest 1 camera eases down just enough that the form's reach
(`bar_m`) clears the box (StoryForms.lift_goal_m, view only). Zero at the shipped 32 px/m and for base Rivet;
about 0.8 m for Tonnage at 64 px/m. A/B same input: `M:frames/tonnage-subtitle-lift-quest1-ab-64ppm.png`
(before, the press's lower legs sit under the box's tape; after, the whole press reads). `ghost_forms.json`
`story_lift` false = before. Unit 1013/0; director reel 16/16 on the merged head.

### 9. Ohm's glow, and all four in the city block (iteration 11, DECISION)
`M:forms-cycle-all-city-32ppm.mp4` (16 s, `--arena=city --bot=forms --form=all`): base -> Tonnage -> Dent ->
Kerf -> Ohm -> base on the city block at 32 px/m; settled keys `M:frames/forms-cycle-city-keys-32ppm-x2.25.png`.
Ohm was the weakest read there: a small rust shell with almost no glow. His soul glow is now 2.6 m wide at alpha
0.5 (was 1.9 m at 0.4). Same-input A/B: `M:frames/ohm-glow-city-ab-32ppm-x3.png`. After the change, a teal pool
marks him as possessed, like Dent and Kerf. Unit 1013/0; director reel 16/16, 0 SCRIPT ERROR.

### Gates (iteration 11)
On the merged head 8b692f82 (ghost-powers 97f49bf0 quest 1 cars, n5-cast 7005b5c8 riot crown): unit (with import)
1016/0 (E:unit-it11-merged2.log), director reel 16/16, 0 SCRIPT ERROR (E:director-reel-it11-merged2.log). On
e865146d (Ohm's glow), still tree (E:evidence-run-it11-final.log): evidence runner `--no-bench` all PASS, unit
1013/0, scenarios 47, parity bit-exact, look goldens 11/11 (worst 1.32), block 5/5 (worst 1.52). Earlier, on
9d610364, still tree (E:evidence-run-it11.log): evidence runner `--no-bench` all PASS: lint 13/13, unit
1013/0, scenarios 47, parity bit-exact (mutation caught at 629), look goldens 11/11 (worst 1.32), block goldens
5/5 (worst 1.52): no re-bless. Director reel 16/16 chapters down, 0 SCRIPT ERROR on the merged head
(E:director-reel-it11-merged.log). The all-four cycle `M:forms-cycle-all-32ppm.mp4` re-filmed on this head
(it dated from 02:27, before Ohm's and Kerf's limb fixes, the seams and the cast merges); same-frame A/B
`M:frames/forms-cycle-all-ab-32ppm-x3.png`.

### 10. Dent holds on the pale kerb (iteration 13, DECISION)
On the cream kerb at 32 px/m the beige crash-test dummy's cream sticker rim melted into the slab; only his
yellow discs and the teal pool carried him. He now has an ink keyline (GhostRim.keyline: an INK silhouette
under each cream halo of his cut rig), the die-cut line the cops get from their dark bodies. On asphalt it
makes no visible change, and it fades with the halos at close-up zooms. His teal voice apparition hides it.
Same-input A/B (`--bot=forms --form=dent --side=120`, `--no-keyline` = before):
`M:frames/dent-keyline-kerb-ab-32ppm-x3.png`; at 64 px/m `M:frames/dent-keyline-kerb-64ppm.png`; on the shipped
quest 1 `M:frames/dent-keyline-quest1-32ppm-x3.png`; clip `M:dent-kerb-city-32ppm.mp4`. Unit 1018/0 (2 new
tests); director reel 16/16, 0 SCRIPT ERROR (E:director-reel-it13-keyline.log).

### Gates (iteration 13)
Merged n6-ghost-powers d439f520 (scenario_quest1_dent) and n5-cast 84ed1bd1 (quest 1's cast sprites from the
slim rigs): unit 1016/0, director reel 16/16 (E:director-reel-it13-merged.log). On 45c69934 (the keyline),
still tree (E:evidence-run-it13.log): evidence runner `--no-bench` all PASS: lint 13/13, unit 1018/0,
scenarios 48, parity bit-exact, look goldens 11/11 (worst 1.33), block 5/5 (worst 1.53); no re-bless.
Then merged n6-ghost-powers a30a5ce3 (Tonnage crushes the quest car, Ohm burns cars out) and n5-cast 473a405e
(docs): on ebc5ed9d, still tree (E:evidence-run-it13-final.log): all PASS, lint 13/13, unit 1019/0, scenarios 48,
parity bit-exact; director reel 16/16, 0 SCRIPT ERROR (E:director-reel-it13-final.log).

### 11. Quest 1's base Rivet takes the cast lane's 32 px/m sticker tier on the story-forms path (iteration 14)
n5-cast 02e4295c (merged through ghost-powers bbc861d0) made quest 1's sprite Rivet print the gameplay sticker
tier (tan core, visor slot, hazard collar) below about 42 px/m. Our StoryForms branch of `CastView._rivet` is
on by default on the shipped quest 1, and it still drew the old cream art capture. So after the merge the
shipped quest 1 silently kept the old Rivet before and after every transformation. It now picks the art through
`_lod_art` like the rest of CastView. Same-input A/B (the shipped quest 1, real key presses):
`M:frames/quest1-sticker-rivet-forms-ab-32ppm-x3.png`, frames 100 (base), 170 (mid-morph, unchanged) and 470
(base after the exit). 64 px/m keeps the art capture, as in n5-cast. Unit 1019/0, lint 13/13.

### Gates (iteration 14, final before the freeze)
Merged n6-ghost-powers bbc861d0 (scenario_quest1_ohm, carrying n5-cast 02e4295c) as ed6d2d31. Unit 1018/1 there
was the known `test_noir_shadows` flake; the re-run gave 1019/0. Director reel 16/16 chapters down, 0 SCRIPT
ERROR (E:director-reel-it14-merged.log). On 5be03adb (the fix), still tree (E:evidence-run-it14-final.log): RESULT
all PASS: lint 13/13, unit 1019/0, scenarios 49 (ghost-powers' quest1_ohm in), parity bit-exact (mutation caught at
629), look goldens 11/11 (worst 1.33), block 5/5 (worst 1.53); no re-bless. The shipped quest 1 clip
`M:story-forms-quest1-shipped-32ppm.mp4` re-filmed on this head (sticker Rivet at both ends of each
transformation; keys `M:frames/story-forms-quest1-sticker-keys-32ppm.png`).

Then merged n6-ghost-powers 2ca168ff (Kerf path_cut_m, quest 1 kerf/tonnage scenarios) and n5-cast c7549272
(the grown Hauler sprite keeps the art capture; their REQUEST for our forms_drawn branch was already met by
5be03adb). The clean auto-merge of `cast_view.gd` left a duplicate `var art`, which was removed in the merge. On
dc9af2e6, still tree (E:evidence-run-it14-final2.log): **all PASS**, lint 13/13, unit 1020/0, scenarios 51,
parity bit-exact (mutation caught at 629), look goldens 11/11 (worst 1.33), block 5/5 (worst 1.53); no re-bless.
Director reel 16/16 chapters down, 0 SCRIPT ERROR (E:director-reel-it14-merged2.log).
Last, merged n6-ghost-powers 8d3b518a (their gate log) and n5-cast 775951e7 (the grown Hauler sprite cross-fades
sticker -> art; the merged `_rivet` keeps our single base pick and their cross-fade). On 0b738cbc, still tree
(E:evidence-run-it14-final3.log): **all PASS**, lint 13/13, unit 1020/0, scenarios 51, parity bit-exact, look
goldens 11/11 (worst 1.33), block 5/5 (worst 1.53); no re-bless. Director reel 16/16, 0 SCRIPT ERROR
(E:director-reel-it14-merged3.log). Quest 1 at 32 px/m is unchanged from the re-filmed clip. **0b738cbc is
the lane's final gated head.** Iteration 15 then merged n5-cast efa29d38 (2cc15c5f: `_lod_art(id, grow = 1.0)`,
a compatible default parameter) as 52ce7f31: lint 13/13, unit 1020/0 (E:unit-it15-merged.log), director reel
16/16, 0 SCRIPT ERROR (E:director-reel-it15-merged.log). Iteration 17 ran the full evidence runner (`--no-bench`)
on the tip 0592825f (same project tree as 52ce7f31), still tree (E:evidence-run-it17-tip.log): **all PASS**, lint 13/13,
unit 1020/0, scenarios 51, parity bit-exact (mutation caught at 629), look goldens 11/11 (worst 1.33), block 5/5
(worst 1.53); no re-bless. **The tip is the lane's final gated head.**

## What does not work / is open
- Evidence gap: no base -> Dent 64 px/m slow close-up survives (filmed in iteration 3, deleted at the 15-entry
  frames.json cap in iteration 4; found by the iteration 18 path check). Re-film with the other morph clips'
  recipe if the owner wants one per ghost; the other three ghosts have theirs.
- Otherwise nothing open in this lane's list. Dent in quest 1 now has ghost-powers' three parked ghost cars (merged
  97f49bf0): our Dent body seizes, rides braced and blows them on the shipped path
  (`M:frames/dent-ride-quest1-32ppm-x2.png`), so Dent stays selectable there (their NOTICE of 05:46 answered).

## What blocked, and for how long
- Nothing blocked the lane (no BLOCKED entry in JOURNAL across 18 iterations). The frictions, each costing one
  re-run (minutes, not hours): strict warnings-as-errors in dev film scripts (a discarded return gave 1086 SCRIPT
  ERRORs once; `--check-only` first fixed it), headless reels needing about 3x `--quit-after`, `-s` scripts
  compiling before the autoloads, the evidence runner refusing a dirty tree (logs now go under `build/` first),
  and the 15-entry frames.json cap forcing clip deletions (the Dent gap above).

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
  Since iteration 6 they show on the shipped quest 1 as well; `ghost_forms.json` `story_voice` false turns that
  off (A/B `M:frames/story-voice-quest1-shipped-ab-32ppm-x2.png`).

## Next steps
- The final gates ran on the tip 0592825f (all PASS, iteration 17). If n5-cast or n6-ghost-powers move again before the
  morning merge, merge them in and re-run the evidence runner and the director reel.
- Note for the HUD owner: quest 1's longest subtitle line runs past the bottom of its box (seen in
  `M:frames/tonnage-subtitle-lift-quest1-ab-64ppm.png`, "where you think." on the box's lower edge).
