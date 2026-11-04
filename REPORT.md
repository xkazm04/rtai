# REPORT (written 16:40 in iteration 5, updated 17:55 in iteration 8, final 18:45 in iteration 14) - day lane combat-notes, 2026-11-04

Branch `d6-combat-notes`, cut from main `a1275c82`. Clips are in
`C:\Users\kazda\kiro\gtai-masters\d6\combat-notes\` (`frames.json`: 12 entries, newest and best first).
Gates on 34bc64e6: lint 13/13, unit 974/974, scenarios 46/46, parity bit-exact (planted mutation
caught at step 629), selftest pass (log: `evidence/combat-notes/gates-34bc64e6.log`; re-run with
`node tools/evidence/run.mjs --no-bench`). Everything after 34bc64e6 is JOURNAL/REPORT/evidence only
(`git diff --stat 34bc64e6 HEAD`). A copy of `frames.json` is in `evidence/combat-notes/`.
No bench was run: this lane makes no performance claim.
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
- **Tests.** `test_shock_jolt`, `test_shock_spits` (`--soft-shock` = the night's, planted).
- **Clips.** `electro_jolt_ab_48ppm_64slow`, `electro_spits_ab_32ppm_64slow`,
  `electro_chain_ab_48ppm_64slow`, `electro_drop_decay_ab_48ppm`.

## 3. Plasma rifle
- **The kill.** The body is kicked 0.3 m back along the bolt on the hit tick, held, then thrown
  further. The wound smokes.
- **A bolt that does not kill.** The body staggers for 0.55 s from the hit frame instead of a
  0.24 s flinch, and a 0.13 m glowing, smoking scorch appears on the chest.
- **Tests.** `test_plasma_wound` (`--no-plasma-heat` = the night's, planted).
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
- **The melee kill.** No claw or baton kill played a death before: the sim lands Rivet's melee kills
  without the event the reaction layer listened to, so the victim dropped into the rig's default
  X-sprawl where he stood, often under Rivet. Now he folds over the blow and topples 0.9 m clear,
  along Rivet -> victim. (Katana, chainsaw and plasma sword keep their signature kills.)
- **Tests.** `test_melee_swing`, `test_melee_smear_linger`, `test_rig_clips`,
  `test_strike_over` and `test_melee_kill_death` each catch the night's behaviour, planted as a fault.
- **Clips.** `melee_swing_ab_48ppm_64slow`, `melee_baton_ab_48ppm_64slow`,
  `baton_smear_linger_ab_48ppm_64slow`, `claw_over_ab_64ppm_32ppm`, `claw_death_ab_48ppm_64slow_32`,
  `city_melee_swing_ab_48ppm`, `city_melee_death_ab_48ppm`.

## Calls for the owner
1. **The two-handed grip on the katana and the plasma sword.** It is built and OFF
   (`--two-hand-grip`; `test_two_hand_hilt`). The off wrist closes on the hilt (0-4 px), but Rivet's off arm ends in a
   torch tool, not a claw, so the tool draws across the blade. The options:
   - the redesigned Rivet gets an off claw, and the grip turns on;
   - one-claw blades are accepted, and the flag is deleted.

   Evidence: `call_two_hand_grip_katana_64ppm.mp4` (default vs flag) and
   `two_hand_grip_probe_rig.png`.

## Weak or not done
- **The claw jab reads only on the hit frames.** The cops walk into Rivet, so at contact he stands
  inside the victim. The arm now draws over the victim (a grey bar across the blue chest at
  32 px/m), and the body now topples clear after the kill, but the approach still overlaps.
  Spacing between fighters is sim/AI (a replay change), so it is not touched.
- **A melee hit that does not kill plays no wound.** Riot cops and SWAT have 2 hp against the
  claw's 1 and the katana's 1.5, so their first cut or jab shows no flinch, spin or fold (the
  baton's stun does show). I found this at the end of the day and did not build it, because there
  was no time to film and gate it before the freeze. The fix is view only, like the melee death: a
  `wounded` signal from CombatArena.damage on a non-lethal hit, played once per strike so the
  chainsaw grind does not restart it every tick. The design is in JOURNAL (18:15).
- **Quest 1 shows none of this lane's work.** Rivet fights with the pistol there.
- **The electro chain is filmed in the arena only.** The city pit spreads its cops beyond the
  chain's jump range.
- **The plasma sword's visual asset** waits for the image rounds (not this lane's).

## What blocked me, and for how long
Nothing blocked the lane outright. The friction, from JOURNAL:
- **About 15 min (13:40-13:58).** The unit gate would not start ("import exit -1"). First, two runs
  had no `GODOT_BIN` set (my mistake). Then one ran in parallel with renders. The fix was to re-run it
  alone. A new `class_name` also needed a `--headless --import` before film runs saw it.
- **About 20 min (14:33).** Lint failed with no output: the 810 `.gd` paths went past the Windows
  command-line cap. Fixed in `tools/lint/lint.mjs` (batches of 200).
- **About 15 min (17:39-17:58).** 14 masters had frozen video gaps: `cut_ab.sh` trimmed the video but
  not the audio. All 14 were re-encoded as video only, and both cut scripts now drop the audio.
- **Lost time.** The first shard A/B came out byte-identical (`LaunchArgs` does not see arena args
  after `--`). `timeout` around the film scripts exits 127 in this shell. Arcs were drawn under the rigs.
- **The last 4 iterations (18:12-18:40).** No code: there was too little time before the freeze to
  film and gate the melee wound (see below).

## Next steps
1. **The non-lethal melee wound.** Follow the JOURNAL DESIGN (iteration 10, 18:15):
   - a view-only `wounded` signal from CombatArena.damage;
   - a small MeleeWound class beside ReactLink;
   - a re-entry gate for the chainsaw grind;
   - a unit test with a planted no-wound;
   - film the claw against a riot cop at 48 px/m real time and at 64 px/m 0.4x, with
     `--soft-swing` as the before.
2. **The two-hand grip call.** Once the redesigned Rivet lands, either turn the grip on (if he gets an
   off claw) or delete the flag.
3. **The plasma sword's visual asset.** Once the image rounds deliver it, re-film the plasma sword's
   combo with the current swing and smear.
4. **The claw approach overlap.** This needs fighter spacing in the sim/AI, a replay change. Leave it
   to a lane that owns the AI.
5. **Quest 1.** Give Rivet a melee weapon there, so this lane's work is seen in the quest path.
