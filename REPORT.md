# REPORT (DRAFT, written 16:40 in iteration 5) - day lane combat-notes, 2026-11-04

Branch `d6-combat-notes`, cut from main `a1275c82`. Clips are in
`C:\Users\kazda\kiro\gtai-masters\d6\combat-notes\` (`frames.json`: 12 entries, newest and best first).
Gates on 341d08e0: lint 13/13, unit 967/967, scenarios 46/46, parity bit-exact (planted mutation
caught at step 629), selftest pass. No bench was run: this lane makes no performance claim.
Everything is view-only: no sim, replay or native change.

Every change has a flag that restores the night's look. The flags are the A/B befores:
`--no-shard-flinch`, `--soft-shock`, `--no-plasma-heat`, `--soft-swing`.

Start with the overview: `all_notes_ab_32ppm.mp4` (27.7 s). It shows all nine chapters at 32 px/m,
the judging scale, real time, with the night's look on the left and now on the right.

## 1. Homing shard: the victim reacted late (reel chapter 14)
- **Cause.** The kill already landed on the landing tick. The view hid it: the 1.2 m splash drew
  the rocket's starburst and a 25-frame smoke ring over the victim, and the burst held the body
  frozen for 39 ticks before the pop.
- **Now.** A small pop of the shard's own, plus a flinch on the landing tick of every shard
  (`KillShardJolt`).
- **Tests.** `test_kill_shard_jolt` catches a planted 2-tick lag.
- **Clips.** `shard_flinch_ab_48ppm_64slow`, `city_shard_electro_ab_48ppm`.

## 2. Electro gun
- **The stun.** A stepped, off-rhythm convulsion (`ShockJolt`): the head and hat snap, arcs crawl
  over the body, and the pistol drops on the first stun tick. Short arcs now also spit out past the
  body's outline. Without them, at 32 px/m (where the body is about 20 px) the arcs stayed inside
  the silhouette.
- **The charged kill.** The skeleton flash and the plank are unchanged. The dropped pistol stays
  by the body, then inks out and sinks with it.
- **Clips.** `electro_jolt_ab_48ppm_64slow`, `electro_spits_ab_32ppm_64slow`,
  `electro_chain_ab_48ppm_64slow`, `electro_drop_decay_ab_48ppm`.

## 3. Plasma rifle
- **The kill.** The body is kicked 0.3 m back along the bolt on the hit tick, held, then thrown
  further. The wound smokes.
- **A bolt that does not kill.** The body staggers for 0.55 s from the hit frame instead of a
  0.24 s flinch, and a 0.13 m glowing, smoking scorch appears on the chest.
- **Clips.** `plasma_kick_ab_48ppm_64slow`, `plasma_armored_stagger_ab_48ppm_64slow`,
  `plasma_scorch_size_ab_48ppm_64slow`, `city_plasma_ab_48ppm`.

## 4. Rivet's melee hold and swings
- **The cause** was the same as the shard's. The sim lands a hit on the first active tick, the
  view began the cut on that same tick, and the hit-stop then froze the blade (and the claw) still
  cocked.
- **The swings now.** Anticipation, then a cut that crosses the aim line on the hit tick, overshoot
  and a held follow-through. A two-tone smear stays 4 frames after the cut. The chainsaw judders
  at the hip. The claw is at full reach on the hit tick, and while a strike extends the striking
  arm draws over the victim (at contact Rivet stands inside the cop, whose head used to cover it).
- **Tests.** `test_melee_swing`, `test_melee_smear_linger`, `test_rig_clips` and
  `test_strike_over` each catch the night's behaviour, planted as a fault.
- **Clips.** `melee_swing_ab_48ppm_64slow`, `melee_baton_ab_48ppm_64slow`,
  `baton_smear_linger_ab_48ppm_64slow`, `claw_over_ab_64ppm_32ppm`, `city_melee_swing_ab_48ppm`.

## Calls for the owner
1. **The two-handed grip on the katana and the plasma sword.** It is built and OFF
   (`--two-hand-grip`). The off wrist closes on the hilt (0-4 px), but Rivet's off arm ends in a
   torch tool, not a claw, so the tool draws across the blade. The options:
   - the redesigned Rivet gets an off claw, and the grip turns on;
   - one-claw blades are accepted, and the flag is deleted.

   Evidence: `call_two_hand_grip_katana_64ppm.mp4` (default vs flag) and
   `two_hand_grip_probe_rig.png`.

## Weak or not done
- **The claw jab reads only on the hit frames.** The cops walk into Rivet, so at contact he stands
  inside the victim. The arm now draws over the victim (a grey bar across the blue chest at
  32 px/m), but the approach still overlaps. Spacing between fighters is sim/AI (a replay
  change), so it is not touched.
- **Quest 1 shows none of this lane's work.** Rivet fights with the pistol there.
- **The electro chain is filmed in the arena only.** The city pit spreads its cops beyond the
  chain's jump range.
- **The plasma sword's visual asset** waits for the image rounds (not this lane's).
