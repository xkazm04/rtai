# JOURNAL: lane rivet-motion (branch e-motion), evening run 2026-11-03

## Iteration 1 (20:50-21:35, BUILD)
- Read: brief, AGENTS.md, d5-cast REPORT (size_k 1.2 hunched guard, rig_footprint.gd), RivetPlan,
  BodyPlan, RigArm, T2 concept. answers.json empty at 20:50.
- Registry: not read this iteration (time); owed next iteration before the locomotion design
  (`realtime-combat-semantics`, `motion-quality-gating`).
- Measured T2 by eye on the 1104x1472 image: shoulder to wrist ~390 px, hip to sole ~480 px
  (arm:leg ~0.8), claw ~130 px (~0.27 of the leg), forearm about a third of the torso width.
  The day rig: upper 159 + fore 182 = 341 vs thigh 166 + shin 137 = 303 (1.13).
- MILESTONE: `RivetPlan.ARMS` [arm_k, hand_k, arm_w] per form; BodyPlan gains `hand_k`, `arm_w`;
  RigArm thins the arm segments and scales the claw. Default (base) = T2 ratio (0.72, 0.78, 0.8);
  `mild` (0.85, 0.9, 0.9) and `day` (the day's arms) kept as A/B forms. King (open form) unchanged.
  Guard and hang targets scale about the shoulder so the guard stays inside the shorter reach.
  Sim untouched (radius 0.6 m), so replay/parity cannot move. Look goldens may move (Rivet in frame).
- Footprint (rig_footprint.gd, headless): day 1.90 x 2.05 m, mild 1.72 x 2.01, base 1.68 x 1.97;
  cop 1.27 x 1.88, ped 0.69 x 1.34. Width is now the torso + hose, not the arms.
- Evidence: `gtai-masters/eve/rivet-motion/frames/rivet-proportions-vs-t2-128ppm.png` (T2 beside
  day | mild | T2-ratio | cop | ped, idle and walk-in-place), 32/48 px/m crops; dev scene
  `project/dev/rivet_motion/lineup.gd`.
- ASK rivet-motion-1 written 21:13 (A = T2 ratio default, B = mild, C = keep). Switching = edit
  `RivetPlan.ARMS[FORM_BASE]` (one row).
- FRICTION: `--check-only` on a dev script fails on autoloads (`Log`) - expected; the windowed run
  was fine.
- Gates at 5dc151c + test fix: lint 13/13 (pre-commit hook), unit 538/538 (after updating
  `test_rivet_plan_is_the_cutout_lanes` to pin the day form's 159 and the base's scaled length),
  scenarios exit 0 (19 incl. the 60 s replay). Look goldens / evidence run NOT run this iteration:
  Rivet's arms are in the look golden frames, so they may need a dated re-bless (next iteration).
- Owner page: `gtai-masters/eve/rivet-motion/frames.json` (4 entries so far).
- Found for item 2: the sim side already does twin-stick (TopDownMover faces the aim at
  `turn_dps`, strafe_scale slows off-facing moves) and RigGait already steps the feet along
  `vel_in`. What is missing is the HIPS: the pelvis and the knee poles stay on the aim facing, so a
  strafe crosses the legs and a backpedal reads as a forward walk.
- NEXT: (1) re-read answers.json (rivet-motion-1). (2) Run `node tools/evidence/run.mjs --no-bench`
  to see whether the look goldens moved; if so, re-bless once with a decisions.md line.
  (3) Item 2: add `CutRig.hip_yaw` (Rivet-only via `BodyPlan.hip_follow`, default 0 so cops and
  peds stay byte-identical): target = wrap(vel angle - facing), folded by PI when |x| > 100 deg
  (backpedal), clamped to `hip_twist_max` (~70 deg), springed; pelvis.rotation += hip_yaw, the
  knee pole in `_solve_leg` rotated by hip_yaw. Then a 32/48 px/m clip of Rivet circle-strafing
  a fixed aim point (dev scene in `project/dev/rivet_motion/`, `--fixed-fps 60`), plus the turn
  rate number. (4) Locomotion clips (item 3), registry subjects first.

## Iteration 1, continued (20:56-21:20)
- The clock read 20:56 after the proportions commit, so I carried on with NEXT.
- Look goldens: the evidence run at 0287cec passed them unblessed (11/11, worst 0.42; block 5/5)
  and parity was exact. Its unit and scenario FAILs came from my edits landing mid-run ("tree
  changed during run"). Scenarios re-run alone: exit 0 at bf41369.
- FRICTION (shared env): `test_save_slots` fails 13-46 asserts with error 16, even run alone.
  project.godot sets `use_custom_user_dir` ("RTAI Uprising"), so every lane's worktree writes
  the same %APPDATA% save dir and concurrent gate runs collide. Not this lane's code (the rig is
  view-only). For the Director: re-run it on a quiet machine before calling it red.
- MILESTONE bf41369, twin-stick hips: `RigHips` (the hips' yaw follows the walk, folds on a
  backpedal past 105 deg, clamps at `hip_twist_max` 70 deg, spring k 140). Rivet only
  (`hip_follow` 1). The strafe foot gauge went 0.4 -> 148 part px (test_rig_hips: the planted
  locked rig has to measure narrower). Clips `clips/strafe-hips-{32,48,96}ppm.mp4`.
  Honest read: from straight above the torso hides most of the legs, so the hips help a little
  and the stride has to get visible (item 3).
- MILESTONE 02524d3, claw combo as data: `data/tables/rivet_melee.json` (+ schema),
  `MeleeTable`/`MeleeHit`/`MeleeCombo` in features/player. Buffered chain at `cancel_ticks` 4,
  `combo_window_ticks` 12, the finisher ends the chain. The shock numbers are in the table; its
  logic comes next. Not wired into quest 1 (its replay log has no combo; the arena plugs it in).
- MILESTONE a692b60, strike pose: `RigClips.strike()` (windup anticipation twist, ease-out
  extension on the active frames, smoothstep recovery); hit 1 claw, hit 2 torch arm (twist
  mirrored), hit 3 both hands. Clip `clips/combo-claw-{48,96}ppm.mp4` on a 3-dummy line.
- Feel numbers (measured, data-true at 60 Hz; not input latency):
  - claw lands at 5 ticks = 83 ms after the press;
  - a mashed chain lands at 0 / 267 / 533 ms;
  - the chain recovers at 56 ticks = 0.93 s;
  - the finisher knocks back 2.5 m.
  Input-to-motion latency is NOT measured yet (it needs the live input path).
- REQUEST 1 -> gunplay: the shared hit flash (`RigClips.hit` -> `set_tint`) paints a struck
  ped/cop vermilion-red. That breaks "red is blood only". Your hit-feel module should own a
  non-red flash (cream/white).
- Registry applied (motion-quality-gating): craft, responsiveness and integrity are reported
  separately; the dimensions are defined by what is visible (gauge, landing tick); no latency
  number was made up.
- Owner page `gtai-masters/eve/rivet-motion/frames.json`: 10 entries.
- NEXT (iteration 2):
  1. answers.json (rivet-motion-1).
  2. Charged shock: `MeleeShock` (hold to charge from `charge_min` to `charge_full`; release =
     stun scaled by charge, chain hops to metal within `chain_radius_m`) + a test with a planted
     fault + a clip.
  3. Sprint (held key, above 5 m/s, owner C19) and dodge roll (i-frames, recovery) in a
     `PlayerMotion` + table rows. The sprint key needs an input_actions row (shared file: a
     minimal change, logged).
  4. Visible stride: try `gait_scale` > 1 for Rivet and a feet-ahead lean at run; measure the
     foot reach past the torso silhouette at 32 px/m.
  5. `arena_stations/rivet-motion.json` once the arena lane's station schema exists (check
     their branch or docs; otherwise propose one).
  6. Melee weapons framework (`melee_weapons.json`: baton, katana) on MeleeCombo rows.

## Iteration 1, last entries (21:16-21:22)
- MILESTONE a6f231c: `MeleeShock` (charge, scaled stun, metal-only chain) + test_melee_shock
  (4/4, planted zero-radius fault caught). Scenarios exit 0 on the combo tree (a692b60).
- Stride probe (`dev/rivet_motion/stride_probe.gd`, headless; evidence/rivet-motion/stride-probe.txt):
  max foot reach from the body centre, in m:

  | gait_scale | walk 1.6 m/s | run 4.5 m/s | sprint 5.6 m/s |
  |---|---|---|---|
  | 1.0 | 0.53 | 0.73 | 0.73 |
  | 1.3 | 0.68 | 0.92 | 0.92 |
  | 1.6 | 0.83 | 1.12 | 1.12 |

  At 1.0 the feet stay inside Rivet's idle footprint half-length (~0.84 m with the arms). That
  is why the legs barely read from above. The stride also stops growing past RUN_SPEED (5 m/s),
  so a sprint shows a faster cadence but no longer reach; the sprint pose needs its own
  stride/lean.
  A torso half-length measure was tried and dropped: it grew with distance travelled, so it was
  not trustworthy.
- NEXT (adds to the list above): try Rivet `gait_scale` 1.3 (+ a sprint stride band above
  5 m/s) and judge it in a 32 px/m clip against the hips A/B. Footfalls stay world-planted (no
  skating by construction); check the cadence still reads natural. If the look is a fork, ASK it
  (rivet-motion-2: stride 1.0 / 1.3 / 1.6 clips).
- 21:21 ASK rivet-motion-2 (stride 1.0 / 1.3 / 1.6, default B = 1.3). Clips:
  `clips/stride-1.0-vs-{1.3,1.6}-{32,96}ppm.mp4`; strafe_clip gained `--stride=<k>`.
  The default is NOT applied yet: next iteration sets `p.gait_scale` in RivetPlan from the
  answer (one line).
- frames.json: 12 entries.
- NEXT (first thing in iteration 2): answers.json -> apply rivet-motion-1/2. Then the order is
  the shock rig pose + clip, sprint + roll (PlayerMotion), the arena station file, then melee
  weapons (baton, katana).
- 21:22 ANSWER rivet-motion-1 = A (T2 ratio 0.72), at 19:57Z. It was already the default in
  code (5dc151c), so nothing to switch. Owner note: the lineup frame's labels were the reverse of
  the option keys. My mistake: the frame read "A day | B mild | C T2" while the ASK keyed
  A = T2. Relabelled the frame to the ASK keys at 21:23. Lesson: generate frame labels from the
  ASK's own keys. Owner follow-up: "if he still reads too large, propose a lower guard pose
  next". That becomes a candidate rivet-motion-3 (a lower guard, hand_z) if the stride does not
  fix the read.
- Unit on f053e6f: every failure is in `test_save_slots` (13 tests, 358 asserts in its
  1000-write loop, plus a save_kit index error from the same collision). It's the shared
  user-dir collision noted above; all other suites pass.
- 21:25 Confirmed the save-slot flake is environmental: `test_save_slots` on merged main
  (int-day, baf2e80) gave 15 pass / 1 fail at 21:24; on e-motion one minute later, 16/16 pass.
  No save code differs from baf2e80. Gates at session end: lint 13/13; unit = everything except
  this flake (it passed alone at 21:25); scenarios exit 0 (a692b60); parity exact and look goldens
  11/11 unblessed (0287cec evidence run). Session ends 21:35.

## Iteration 2 (21:27-22:12), BUILD
- 21:27 Read: JOURNAL, git log, answers.json (rivet-motion-2 not yet answered at start).
- MILESTONE 9d92fe4, sprint + dodge roll as data: `PlayerMotion` (features/player) over
  TopDownMover, `data/tables/rivet_motion.json` (+ schema). Sprint is a held key (owner C19):
  6.2 m/s, above the 5.0 m/s tackle line (bodies.json rivet run_mps). While sprinting the facing
  follows the walk at 320 dps, and the speed only rises once the stick is within
  min_forward_dot 0.4 of the facing. Roll: 3.2 m in 22 ticks on an ease-out curve (exact
  distance), i-frames on ticks 2-14, 10 recovery ticks with the stick x0.35, 8 cooldown ticks.
  test_player_motion 6/6, with two planted faults (sprint at walk speed misses the line;
  i-frames past the roll are a table error).
  Shared-file change: input_actions.json gained `sprint` (bit 5: Shift, pad L3) and `roll`
  (bit 6: Ctrl, pad B; B is also handbrake, and the context decides, like Space for
  melee/handbrake). Not wired into quest 1's StagePilot, so its replay hash and goldens are
  untouched; the arena plugs PlayerMotion in.
- MILESTONE 25a1efc: RivetPlan GAIT_SCALE 1.3 (ASK rivet-motion-2 default B) and SPRINT_STRIDE
  0.2 (BodyPlan.sprint_stride, RigGait: the stride keeps growing from 5 m/s up to 6.2 m/s).
  RigClips.roll(duration) now takes the sim's roll length, so the tuck lasts 367 ms, not the
  spike's 450 ms.
- MILESTONE 964f52e: motion course dev scene (`dev/rivet_motion/motion_course.gd`). The real
  PlayerMotion runs a scripted course: a strafe box around an aim mark, sprints both ways, rolls
  out of a sprint and from a stand. A state label and an ink i-frame ring are on screen. Clips:
  `gtai-masters/eve/rivet-motion/clips/motion-course-{32,48}ppm.mp4` (12.8 s, --fixed-fps 60),
  plus the sheet `motion-course-48ppm-sheet.png`.
- Feel numbers (sim-true on the 60 Hz tick; `dev/rivet_motion/motion_probe.gd`;
  evidence/rivet-motion/motion-probe.json):

  | | top | to 90 % | stop distance | stop time | 180-degree turn |
  |---|---|---|---|---|---|
  | walk | 4.5 m/s | 150 ms | 0.22 m | 117 ms | 250 ms |
  | sprint | 6.2 m/s | 350 ms | 0.43 m | 167 ms | 550 ms |

  - Roll: 367 ms, 233 ms of i-frames, 667 ms lockout (roll + recovery + cooldown).
  - Input to motion: Rivet moves on the press tick (0 ticks of sim latency). The display latency
    (sample to presented frame) is NOT measured.
- MILESTONE b750f1b: `arena_stations/rivet-motion.json`, two stations. `rivet_motion_course`
  (16 tunables, a tackle crowd patch) and `rivet_melee_line` (3 human dummies 1.2 m apart, 3
  metal dummies 2 m apart plus a far one for the chain, every claw/shock tunable). It validates
  against e-arena's `gtai.arena-station/1`. The schema and the lint mapping are byte-identical
  copies of e-arena a2467d8 (lane field `rivet_motion`: that schema's pattern has no hyphen).
  REQUEST 1 -> arena: a metal dummy kind (the shock's chain needs to know metal; kind `enemy`
  is used until then); and array-row tuning keys by index (`rivet_melee.claw.hits.0.windup_ticks`).
- Gates at 25a1efc + course: lint 13/13, unit 556/556, scenarios exit 0.
- 21:46 ANSWER rivet-motion-2 = B (1.3), already applied in 25a1efc. Owner direction 21:25
  (binding): "not judgeable in this state ... the visual impression is the key". Depth before
  breadth: the full hit chain in the D5 look on real rigs, asks only with real-time clips in
  the final look. Consequences for this lane:
  - melee weapons (baton, katana) are deferred, because they are breadth;
  - the claw combo becomes the one finished melee move: windup, hit-stop, a non-red flash,
    shake, knockback, the cop's flinch/stagger/knockdown/death, blood, the sound hook;
  - plus Rivet's locomotion, in one 20-40 s clip at 32 px/m, in D5.
  The robot thug rig is not on this branch (enemy-ai's?): REQUEST 2 -> enemy-ai.
- MILESTONE (21:49): claw combo impact in combo_clip: hit-stop 3/3/7 ticks, a decaying
  deterministic shake 2/2.5/7 px, the cop dies on the finisher (DEATH sprawl), the peds are
  knocked down and get up. Clips `combo-claw-impact-{32,48}ppm.mp4` and a death sheet.
  FRICTION: the struck cop still flashes vermilion. That's the shared rig tint, REQUEST 1 ->
  gunplay; e-gunplay's HitFeel owns a victim flash, so the fix lands with it.
- Gunplay's HitFeel on e-gunplay (`features/combat/hit_feel/hit_feel.gd`, `hit_feel.json`):
  - `land(target_id, hit_class, dir, lethal, tick) -> int` (the hit-stop ticks);
  - classes light/medium/heavy/blast/...; the claw finisher is `heavy` (hitstop melee_hit,
    shake hit, stagger 24 ticks);
  - a `reaction(target_id, kind, dir, ticks)` signal for the victim's animation.
  Plan: give each `rivet_melee.json` hit a `hit_class` (claw_1/2 -> a light melee class with a
  short stop; REQUEST 3 -> gunplay: a `melee_light` class, since `light` has no hit-stop).
- frames.json: 15 entries (motion course x3 and the impact clip/death added; the raw lineup and
  the 1.6 stride A/B dropped).
- Registry applied (motion-quality-gating): responsiveness numbers are sim-true, and the
  display latency is named unmeasured. The clips use the real state machine (PlayerMotion,
  MeleeCombo), not a hand-keyed animation.
- 21:53 MILESTONE 8dc9aa4: `RivetD5Post` (dev/rivet_motion) puts the look_d5 print over the
  combo and course clips, using D5ShowcaseRun's recipe. That commit also carries the member-order
  lint fix; the earlier D5 commit was blocked by the pre-commit lint, so everything landed
  together. Finding: look_d5.params zoom_amount is 0 at 32 px/m, 0.35 at 48 and 1.0 at 64. At
  32 px/m a "D5" clip is pixel-identical to D4 (the encoded files matched byte for byte, so
  they were deleted, not published). At 48 the print only warms the paper. Most of what makes
  D5 is the venue and floor art (D5ArenaRun: king_arena.png, D5 roofs), not the overlay.
  Clip: `combo-claw-impact-d5-48ppm.mp4`. frames.json: 15 entries.
- Gates at the end of the session: lint 13/13 (500 files). Unit 556/556 and scenarios exit 0
  at 25a1efc (the later commits are dev-scene only, plus the station JSON and lint mapping,
  which lint covers). Evidence/parity/bench were not run this iteration. The bench was skipped
  on purpose: no runtime path changed, since PlayerMotion is not wired into the game.
- NEXT (iteration 3), under the owner's 21:25 direction (depth, the full hit chain, real rigs, D5):
  1. answers.json first.
  2. The sample clip (20-40 s, 32 px/m, plus 48), all in one scene:
     - Rivet on the arena floor (D5 venue art: e-arena's floor once merged, else D5ArenaRun's
       king_arena.png);
     - he walks, strafes, sprints into a ped (the tackle knockdown), rolls, then claw-combos a
       patrol cop to death.
     - Merge the motion course and the combo clip into one runner (PlayerMotion + MeleeCombo).
  3. The full hit chain on the claw:
     - blood on the human: CombatBlood fed a death or hit cue at the landing tick (see
       `features/fx/combat_blood.gd` listen()/FxTriggers.cued);
     - the stagger in the direction of the hit (CutRig.hit already shoves; scale it per hit);
     - a non-red flash (REQUEST 1);
     - a sound hook: Events/audio cue `melee_hit`, if audio_cues has one; else a REQUEST to audio.
  4. Wire HitFeel when it is on this branch: add `hit_class` per `rivet_melee.json` hit
     (claw_3 = heavy); until then the clip constants HITSTOP_TICKS/SHAKE_PX stand in.
  5. The tackle animation: Rivet's shoulder-lead pose above 5 m/s (c_lean with a sprint lean),
     plus a sprint lean in RigPose. The sprint currently reads only through cadence and stride.
  6. Only then: the baton and the katana (deferred by the 21:25 direction).
- 21:57 MILESTONE: sprint lean in RigPose. A plan with a sprint stride moves the body up to
  30 part px ahead of the hips between 5 and 6.2 m/s. It is subtle at 48 px/m
  (`clips/sprint-lean-before-after-48ppm-2x.png`), so it is not yet a readable sprint pose;
  NEXT item 5 still stands (a shoulder lead and arm pump for the tackle).
  motion-course-48ppm.mp4 was re-encoded with the lean. Unit 556/556, exit 0.
  FRICTION: run_unit.mjs without GODOT_BIN exported reports "exit -1" on every step but still
  prints "556 passed". Always export GODOT_BIN in the same shell call.
- 21:59 Gates at HEAD (the sprint-lean commit): lint 13/13, unit 556/556 (exit 0),
  scenarios 19 ran / 0 failed. Quest 1's bound-input run replays identical: the new sprint/roll
  input rows do not move its hash. Evidence/parity/bench were not run (no sim or runtime path
  changed). Session ends; NEXT is the iteration-3 list above.

## Iteration 3 (22:01-22:45), BUILD
- 22:01 Read: JOURNAL, git log, answers.json. No new answers for this lane (rivet-motion-1 = A
  and -2 = B are both already applied). The owner's 21:25 direction still governs: depth, the
  full chain, real rigs, the D5 look, asks only with real-time clips.
- Item: the sample reel (NEXT 2+3), `dev/rivet_motion/rivet_reel{,_run}.gd` + `reel_victim.gd`.
  One scene on King's D5 arena floor (king_arena.png 12 m in asphalt, look_d4 + the D5 print),
  driven by the real state machines:
  - PlayerMotion strafes a box around an aim mark;
  - Rivet sprints into a ped, and bodies.json's `rivet_base -> human` rule decides the contact
    from the closing speed (the collisions lane's table; knockback_m/down_s from the row);
  - he rolls out and walks up to a patrolling cop, which turns to face him inside 4 m;
  - MeleeCombo claws the cop to death: hit-stop 3/3/7, a decaying shake, the knockback, the
    sprawl, and CombatBlood.kill_human (the d5-combat lane's spray and pool) on the finisher.
  The shared vermilion hit flash is suppressed in the reel (`flash` = false). Red is blood only,
  and REQUEST 1 -> gunplay still stands.
- MILESTONE e771e93 (22:12): the reel ran clean once the parse warnings were fixed. Measured
  run (48 px/m, 796 ticks, 13.3 s):
  - tackle contact at tick 447, 6.03 m/s, so `knockdown` (0.4 m slide, then down);
  - claw 1/2/3 land at ticks 568/579/595, and the cop dies on claw 3;
  - CombatBlood sprays along the blow, and the pool follows the slide.
  Fixed on the way:
  - the walk's momentum carried into the sprint and Rivet missed the ped's lane, so a 0.4 s
    "east" set-up beat comes before the sprint;
  - the 2.5 m finisher knockback threw the corpse over the arena rim, so the cop patrols
    x 3.6, y -1.8..1.4;
  - the cop overlapped Rivet's strafe box.
  The clips are cropped to the 12 m arena (the 48 px/m frame shows 26 m, so the floor filled
  under half of it), at the same px/m:
  - `clips/rivet-reel-48ppm.mp4` (720x720) and `clips/rivet-reel-32ppm.mp4` (480x480);
  - the stills `clips/rivet-reel-48ppm-sheet.png`.
  Honest read: the chain reads at 48 (tackle, sprawl, claws, the kill in its blood). At 32 the
  bodies are small, and look_d5's print is 0 there.
- FRICTION: a parse error in the run script (`-s` launcher loads it at run time) does not exit:
  Godot idles and --write-movie wrote 10k frames (200 MB) until `timeout` killed it. Always do
  a headless run of a new runner first (that run exits and prints the parse errors).
- FRICTION: python `open(p,'w')` on Windows wrote CRLF into rig_pose.gd; caught by git's
  warning, fixed with sed before committing. Use `newline=''`.
- MILESTONE c2f6c15: the tackle read. Above 5 m/s the claw shoulder leads (0.5 rad at 6.2 m/s)
  and the torso swing drops 60 %, on top of the sprint lean (Rivet only). Before/after still:
  `clips/tackle-shoulder-before-after-48ppm-2x.png`. Visible at 2x, modest at 1x; the arm pump
  is still owed. Unit 556/556 on it.
- MILESTONE 936b6a1: `test_rivet_tackle_chain` (4/4). PlayerMotion's sprint against bodies.json
  rivet_base -> human: a sprint from a stand crosses run_mps after **0.84 m** and knocks down;
  a walk never does. Planted faults caught: run_mps above the sprint top, a 0.5 m run-up.
- frames.json: 15 entries (the reel 48/32, the reel sheet and the tackle before/after added;
  dropped the 48 px/m proportion crop, the two impact-less claw clips and the answered
  stride A/B).
- decisions.md: the tackle read line.
- 22:20 answers.json re-read: 10 answers, nothing new for this lane.
- No ASK this iteration. The reel is the first clip that meets the owner's 21:25 bar for this
  lane: real rigs, the D5 venue floor, the full claw chain, blood. The Director can show it as
  is. The next ask should come from it (rivet-motion-3: a lower guard, if Rivet still reads
  large beside the ped; at 48 px/m he is clearly bigger than the ped, about the cop's bulk).
- MILESTONE 012f4ef: sprint arm pump. At the sprint top the counter-swing grows 50 % and the
  hands tuck 35 % toward the body (Rivet only, via `RigPose.sprint01`). Still:
  `clips/sprint-pump-before-after-48ppm-2x.png` (shoulder lead only vs plus the pump). The
  sprint now reads through four cues: cadence, stride, lean, and shoulder plus pump. Both reels
  were re-recorded with it (same ticks; the sim is untouched). Unit 560/560.
- Gates at 012f4ef (`node tools/evidence/run.mjs --no-bench`, 22:29): lint 13/13 (504 files),
  unit 560/560, scenarios 19/19, parity exact (mutation caught at step 629), selftest look
  goldens 11/11 (worst 0.46) and block goldens 5/5 with NO re-bless. Earlier: scenarios at
  936b6a1; the pump commit is view-only). The bench was skipped: no runtime path changed, since
  PlayerMotion is still not wired into the game and the rig changes fire only above 5 m/s.
- frames.json: 15 entries (sprint pump still added, the 32 px/m hips clip dropped).
- Look: the torch tip on Rivet's left forearm is teal in the D5 print. That's existing art,
  not this lane's, and teal is for souls only. For the Director / d5-cast: check whether the
  torch tip counts as a soul.
- NEXT (iteration 4 / night run):
  1. answers.json first.
  2. Show the reel to the owner, through the Director: `clips/rivet-reel-48ppm.mp4`. Then ASK
     rivet-motion-3 from it: a lower guard vs today's, if Rivet reads large beside the ped. At
     48 px/m he is about the cop's bulk and clearly bigger than the ped.
  3. The hit flash: still vermilion in the shared shader (print_part / look_d5_part `tint` ->
     VERM). REQUEST 1 -> gunplay. When HitFeel lands, swap the reel's HITSTOP/SHAKE constants
     for `HitFeel.land(...)` plus a `hit_class` per rivet_melee.json hit.
  4. A Rivet contact beat on the tackle (a brief recoil or shoulder-drive on the rig at
     contact); today only the victim reacts.
  5. A longer reel (20-40 s): add the charged shock once a metal target rig exists
     (REQUEST 2 -> enemy-ai: the robot thug), and a second cop that shoots (gunplay's tell).
  6. Then the deferred breadth: melee weapons (baton, katana) on MeleeCombo rows.

## Iteration 4 (22:31-23:16), BUILD
- 22:31 Read: JOURNAL, git log, answers.json. Nothing new for this lane (10 answers; -1 and -2
  already applied). Item: brief 4b, the melee-weapon framework plus the electro baton and the
  katana ("tonight"; the chainsaw and plasma sword come in the night run).
- Registry rules applied (realtime-combat-semantics, as read in iteration 1): the timing is data
  per phase (windup / active / recovery), and one landing tick per hit; a thrust that travels
  is shown by the attacker's motion, not by a longer hitbox. No deviation.
- MILESTONE 5aaaa51: the framework.
  - `data/tables/melee_weapons.json` plus schema `gtai.melee-weapons/1`. It is a separate
    table, so it never conflicts with gunplay's weapons.json.
  - Each weapon is a combo in the claw's shape, plus per-hit `stun_ticks` / `chain_hops` /
    `lunge_m` and per-weapon `move_mult` / `chain_radius_m` / `length_m` / `grip`.
  - `MeleeTable.weapon(id)` loads a weapon into the same shape; `weapon_ids()` lists them for
    the panel.
  - `MeleeCombo` gained `lunge_step_m()` (lunge_m spread over windup + active, 0 in recovery)
    and `move_scale()`.
  - The baton: 2 jabs (stun 30 ticks), then an overhead crack (stun 90, arcs to 2 metal
    targets within 2.5 m); move_mult 0.85.
  - The katana: 2 wide slashes at 2.1 m reach, then a 2.4 m lunge thrust (2.5 m travel,
    knockback 1.2); move_mult 0.7.
  - Mashed 3-hit chain: the baton is faster than the claw (tested).
  - All 46 new values are tunable on the melee line station.
  - `test_melee_weapons` passes 9/9, with 3 planted faults: a missing weapon, a string
    move_mult, a lunge stretched into the recovery.
- MILESTONE edb694d: the weapons on screen.
  - `features/player/melee_weapon_view.gd` draws the prop from the fist along the forearm, at
    length_m, with the D5 ink outline. Slashes sweep +-1.1 rad (two-hand) or 0.7 (one-hand),
    alternating sides, with a 4-tick smear. A thrust never sweeps. Baton hits zap the struck
    body for its stun_ticks.
  - Colours: pale blue-white electric and steel; no teal, no vermilion.
  - `combo_clip.gd -- --weapon=<id>`: Rivet stands off at the weapon's reach, and the lunge
    stops 0.8 m short of a body.
  - Measured: katana_1/2 land at 1.79 m, katana_3 at 0.75 m after the lunge; the baton
    lands at 1.30 m.
  - Clips: `clips/weapon-{katana,electro_baton}-48ppm.mp4` plus `-sheet.png`.
  - Honest read: the katana's sweep and thrust read, the smear is faint, and the blade is a
    thin pale line at 1x. The baton (0.7 m) is mostly hidden by the guard at 1x; the stun zap
    carries its read. The shared vermilion hit flash still tints the ped (REQUEST 1 -> gunplay).
- FRICTION: the first unit run after the view said "exit -1" because GODOT_BIN was not
  exported in that shell, and the 568 shown was the stale junit count. Export it in every call.
- The arena lane (e-arena-56) sent 3 layout notes on my station. Applied in b03f575:
  - the metal dummies are `kind: metal`;
  - the humans are 2 m apart at x 0/2/4 (rings 0.8 m overlapped at 1.2 m), and the metals sit
    at 6/8/10 plus 14 (past the 3 m chain radius);
  - the course props and tackle_crowd moved onto the course rect (x -42..-4).
  SHARED FILE: `data/schemas/arena_station.schema.json` was taken verbatim from e-arena
  ab3d26d (it adds kind metal), so it merges clean. I replied to the arena lane.
  REQUEST 1 -> arena is closed (the metal dummy kind exists).
- decisions.md: the melee weapons line.
- frames.json: 15 entries. Added the katana clip and sheet and the baton clip. Dropped the
  motion course at 48 and its sheet, and the claw impact clip at 32 (the reel supersedes them).
- No ASK: the owner's 21:25 bar is a real-time clip in the final look, and these props are
  placeholders without weapon art. Ask the night run with weapon art (codex image_gen) on the
  props: `rivet-motion-3` is a clip of each weapon against the dummy line.
