# JOURNAL: ghost-powers (branch e-powers)

## 2026-11-03 iteration 1 (20:53-21:38), BUILD

- 20:53 read: brief, collisions/vehicles/d5-cast reports (body classes, `soul_hijack_traffic`, `RivetPlan.FORMS`).
  answers.json empty.
- Registry applied: `ability-authoring-to-engine` (the three agreements: power ids/bark ids/actions are a closed
  namespace in powers.json, a strict schema, and runtime proof from the engine's own run: the scenario, not a summary);
  `realtime-combat-semantics` (reaction budgets: Hauler morph 0.4 s = bottom of the 0.4-1.5 s wind-up band).
  Deviation: the stomp has no wind-up yet (instant), outside the band; next iteration adds ~0.3 s telegraph.
- MILESTONE 837d778: framework (SoulPowers/PowerDef/PowerTable), HaulerForm, GearboxLink, powers.json + schema,
  bodies.json `rivet_ghost` live with 9 rules, RivetBody.body_class (minimal change in features/bodies, default
  unchanged), RivetPlan.FORMS `hauler` (2.6). 18 unit tests; full unit run 555/555.
- SHARED FILE a0b700e: `input_actions.json` +2 rows: power_hauler (bit 5, Q, joy 9 LB), power_gearbox (bit 6, G, joy 10 RB).
- MILESTONE b67c943: `arena_stations/ghost-powers.json` (hauler_pad, gearbox_pad on the pad rect). The arena lane's
  `arena_station.schema.json` and its lint hunk (`tools/lint/lint.mjs`) are byte-identical copies of e-arena a2467d8
  so the merge is clean. If arena changes either before 00:00, take theirs.
- MILESTONE ae1dbe7: `scenario_souls_powers`: tank at 4.2 m/s knocks down a human in the real city sim (base Rivet at
  the same speed: 0 knockdowns, planted), knocks down a robot (base: blocked), stomp 6/6 ring (r=0 planted: 0),
  Gearbox car turns onto a robot 17 m off-axis and wrecks at 14 m/s in 1.42 s (turn 0 planted: never reaches).
- FRICTION: GUT loads with return_value_discarded as error: `connect()` needs `@warning_ignore`, `append()` on
  Packed arrays too. `test_save_slots` fails a different case each run when other lanes run the suite at the same
  time (shared `user://test_save`), not this lane's code; the first full run was 555/555.
- ASK ghost-powers-1 (Gearbox control: aim-to-steer vs target-and-launch), default A.
- 21:16 REJECTED frames: `king_showcase.gd -- --rivet-form=hauler` renders Rivet unchanged (base vs hauler frames
  differ only around King's idle; PIL diff bbox 675,185-991,513). RivetPlan.form is set before super._ready, so the
  showcase's Rivet must come from elsewhere (not RigPool.plan_of?). Not chased this session; frames deleted, none
  published. frames.json is empty on purpose: no power is shown in motion yet.
- Gates at f6d23a6: lint 13/13, unit 555/555 (first full run; later runs lose 1-11 save-slot cases to the shared
  user:// contention), scenarios 20/20 exit 0. No bench run (logic only, nothing on the frame path yet).

NEXT:
1. Re-read answers.json (ghost-powers-1). A dev scene `project/dev/ghost-powers/powers_pad.gd` on the real rig
   (start from `dev/showcase/rig_showcase_run.gd`): Rivet + a crowd + 2 robots (BodyContact) + 2 cars. Wire
   SoulPowers.tick, HaulerForm.step -> Rivet's velocity and `RivetBody.body_class`, and the rig scale =
   base * lerp(1, 2.6/1.2, morph_k) (find why --rivet-form did not reach the showcase Rivet first).
   Teal ghost tint on the tank's parts (souls' colour) via the part material.
2. Clips at 32 and 48 px/m (--fixed-fps 60, 10-20 s): Hauler morph + ram + stomp into a wave; Gearbox lock + drive
   into robots. Numbers: knockdowns per activation, time transformed, time to hit.
3. ASK ghost-powers-2 with those clips: the tank look (A scaled Rivet parts + teal, B scaled + armour plates,
   C new art: ask before generating) and duration/cooldown (8 s / 20 s now).
4. Stomp wind-up ~0.3 s (registry band), a stomp input (melee while transformed?), ram damage to cars through
   VehicleService; Gearbox through `VehicleService.soul_hijack_traffic(slot)` in the city block.
- 21:20 MILESTONE: stomp wind-up 0.3 s (`stomp_windup_s`; HaulerForm.arm/stomp_due/windup_k), closes the registry
  deviation above. Unit test checks it sits in the readable band.
- 21:24 CORRECTION: the 21:16 rejection was my misread. Rivet is the centre figure (U torso); King (1.3) is the lower
  left one. Re-rendered base and hauler: the form DOES apply (Rivet 2.6x grips both cops). Frames restored under
  gtai-masters/eve/ghost-powers/frames/form-{base,hauler}/ and listed in frames.json (4 stills, no clips yet).
- ASK ghost-powers-2 (tank look: A scaled+teal, B bulked short-arm from existing parts, C new art), default B: a
  plain scale-up keeps the long arms the owner disliked on base Rivet. NEXT step 1 should build B as a FORMS-like
  plan override (arm lengths) so A/B/C is one flag.
- 21:23 FRICTION/REQUEST 1 -> autosave owner (or the Director): `project.godot` has `use_custom_user_dir=true`, so all
  seven worktrees share one `user://`; `test_save_slots.gd` (user://test_save) fails 1-136 asserts per run while
  other lanes run the suite. Every failure in this lane's evidence run (549/557) is in that one file. Suggest a
  per-checkout test dir (e.g. `user://test_save_<hash of res:// path>`). Not changed here (outside lane scope).
- 21:23 Evidence gate (`run.mjs --no-bench`, at 7a7cb3c): lint PASS 13/13, scenarios PASS 20/20, parity PASS (bit exact,
  planted mutation caught at step 629), selftest PASS (look goldens 11/11, block goldens 5/5, worst 0.00). unit FAIL:
  every one of the failing asserts is in `test_save_slots.gd`, plus one script error in `tests/support/save_kit.gd:56`
  (REQUEST 1, shared user://); "tree changed" = my JOURNAL commit during the run. Earlier the same tree ran 555/555
  when no other lane was testing. No bench: nothing on the frame path changed (logic and data only).
  Summary: evidence/ghost-powers/evidence-gate-iter1.txt.

NEXT (supersedes the NEXT above where they differ):
1. Re-read answers.json for ghost-powers-1 (Gearbox control) and ghost-powers-2 (tank look); apply them.
2. Powers dev scene `project/dev/ghost-powers/powers_pad.gd` on the real rig (start from RigShowcaseRun; the
   `--rivet-form` path works). Wire SoulPowers.tick, HaulerForm.step/arm/stomp, RivetBody.body_class, the rig scale
   lerp by morph_k, a teal tint; Gearbox on a VehicleService car (`soul_hijack_traffic`).
3. Clips at 32 and 48 px/m (--fixed-fps 60): Hauler vs a wave, Gearbox into robots; numbers per activation.
4. Build the tank look option B (short thick arms from existing parts) as a form override so A/B/C is one flag.

## 2026-11-03 iteration 2 (21:25-22:10), BUILD

- 21:25 read JOURNAL, git log, answers.json (nothing for this lane yet at start).
- MILESTONE 88ec340/faedfab: Hauler on the REAL city sim. `HaulerCity` (features/souls) drives Rivet's target by
  the form's heavy movement, keeps `RivetBody.body_class` in sync, and turns a due stomp into a one-step
  `RivetBody.pulse` (minimal change in features/bodies, default zero: goldens unmoved). scenario_souls_powers adds
  `stomp_city`: a 6-person ring floored, 2 people 6 m out untouched; planted no-pulse = 0. Scenario passes.
- MILESTONE d2ccb17: `dev/ghost-powers/powers_clip.tscn` (bodies_clip's real World + CityView + rigs, one tick per
  frame): activate at 1 s, drive east through 12 people, coast, arm the stomp at 7 s in a group of 9, shrink at 9 s.
  Numbers (deterministic, 32 and 48 px/m identical): 10 knockdowns per activation (6 by the stomp), 8.0 s
  transformed; `--before` (base Rivet, same path and speed): 0 knockdowns.
- 21:40 ANSWERS: ghost-powers-1 = A, ghost-powers-2 = B, both "default as a placeholder" (owner 21:25: not judgeable
  without the full hit chain in the final look; re-ask only with real-time clips in that look; depth before breadth).
  Applied: the Hauler is this lane's ONE finished power for the 00:00 sample; Gearbox waits. Recorded in decisions.md.
- MILESTONE 3f0d1c4: `HaulerLook` (features/souls): grows/tints Rivet's rig by morph_k; `look=bulked` shortens both
  arm segments to look_arm_k 0.6 on Rivet's shared plan, restored exactly at morph 0 (3 unit tests pass).
- MILESTONE 7f4f715: the stomp's hit chain in the clip: wind-up = rig swell (+12 %), no debug telegraph circle;
  landing = camera.json shake `crash` + hit-stop `boss_hit` (8 rendered frames, sim held); an inked shock ring
  (wobbled polyline, ink + thin soul-teal edge, grit) instead of the clean teal circle. Clips: clips/hauler-feel/.
- Registry applied: realtime-combat-semantics (hit-stop/shake on the heavy hit; wind-up stays readable: morph 0.4 s,
  stomp 0.3 s). Tuning note (my call per owner 21:25): 0.3 s stomp wind-up is below the 0.4 s band floor; acceptable
  for the player's own move (enemies read the swell), revisit when enemies must dodge it.
- Owner-direction gaps for the Hauler hit chain still open: no sound cue fired (bark ids exist, no audio call), no
  robot victims (sparks/oil) in the city clip, no attacker anim for the stomp beyond the swell (a raised-claws
  slam pose would sell it), the morph is a scale lerp (no ink burst).
- FRICTION: Python on Windows writes CRLF: always open(..., newline='\n') when editing repo files.
- MILESTONE 6a5940b: `--cops` (3 patrol cops in the stomp group): they walk in on the tank and are rammed first;
  8 knockdowns, 3 by the stomp. Blood in these clips is the city's own traffic (the --before run has a
  car-struck cop bleeding too), not the power.
- MILESTONE ece49cb: sound hook: `HaulerCity.cued(id, at, tick)`: morph_cue `servo` at the morph, stomp_cue
  `crash` at the landing (temp audio_cues ids; powers.json). The clip records them: servo@60, crash@438.
- MILESTONE 7564956: the stomp is posed (attacker animation): wind-up raises both claws overhead, the landing slams
  them forward and down (HaulerLook wk/slam_k on the plan's hand_ready/hand_relax; restored exactly at rest).
  Headline clip: gtai-masters/eve/ghost-powers/clips/hauler-slam/hauler-slam-32ppm.mp4 (60 fps, every tick).
- Gates at a4bcb1f-ish: lint 13/13 (every commit), scenarios 20/20 (evidence/ghost-powers/scenarios-iter2.txt),
  unit 560/560 (unit-iter2.txt, ran at 6a5940b; test_hauler_look re-run 3/3 after the pose change). No bench:
  the power runs only in the dev clip; nothing on the game's frame path changed (RivetBody.pulse defaults to 0).
- frames.json: 13 entries, headline = the slam clip; the old clean-ring clip dropped.

NEXT (iteration 3; owner 21:25: depth before breadth, the Hauler is the one finished power):
1. Re-read answers.json. Re-ask nothing until the Hauler clip has the full hit chain in the final look.
2. Arena: if e-arena's scene is on main/this branch, mount the Hauler on the powers pad (stations file exists)
   against the cast rigs: a patrol cop and a robot thug (BodyContact robots) with full reactions: robots get
   sparks/oil on the stomp and ram (red only on humans). Until then the city clip is the proof.
3. The Hauler in the playable loop: bind `power_hauler` (Q/LB) to SoulPowers.try_activate in the quest/arena
   session; stomp on melee click while transformed (arm()); HaulerCity on the session's CitySystem.
4. Hit chain gaps: a real stomp sound (audio lane REQUEST or a cue row), an ink burst / dust puff on the morph
   instead of a pure scale lerp, a short screen-space crack decal where the stomp lands (D5 grime).
5. Gearbox only after the Hauler is judged finished (aim-to-steer placeholder, ghost-powers-1).
- 22:00 MILESTONE: a lingering ink crack at the stomp point (9 kinked rays 1.4-2.7 m, 2 s hold, 1.5 s fade), and the
  shock layer moved under the rigs (ground level). FIRST PASS ONLY: the rays read as thin straight lines
  ("spider legs"), not the D5 crack decals the ground already has (the cracked-asphalt marks seen in every city
  frame). Next: stamp the D5 ground crack art (or bake one stomp crack sprite) instead of polylines. The headline
  clip (hauler-slam) predates the crack; the crack stills are in clips/hauler-crack/.
- 48 px/m slam clip added (clips/hauler-slam/hauler-slam-48ppm.mp4); frames.json has 14 entries.
