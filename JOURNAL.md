# JOURNAL - lane rivet-arsenal (night 2026-11-04)

## Iteration 1 (01:04 - 02:04)
- 01:04 read: rivet-motion REPORT (nothing wired live), arena REPORT (`--rigs` dev flag draws cast rigs; quest 1 default view still draws sprites), StagePilot (TopDownMover + electroshock jab), ArenaRigs.
- No other night lane JOURNAL exists yet; no REQUESTs addressed to rivet-arsenal.
- Registry rules applied: realtime-combat-semantics (hit test on the first active tick only, one damage chokepoint `CombatArena.damage`; i-frames gate damage via `exposed`), motion-quality-gating (every claim gets a scenario with a planted fault).
- DECISION live-melee: the claw combo (MeleeCombo over rivet_melee.json) replaces the electroshock jab in StagePilot, so quest 1, the arena and the city block all swing the same combo. The jab's single 30-tick cooldown hit is gone; the charged shock (MeleeShock) is not wired yet (needs a hold/release on the melee key). Rejected: keeping the jab and adding the combo on another key (two melee keys read worse).
- DECISION live-motion: PlayerMotion replaces TopDownMover in StagePilot (sprint bit 5, roll bit 6 already bound). Roll i-frames close Rivet to damage through `Fighter.exposed` (the existing gate).
- DECISION rig-strike: new `RigClips.Clip.STRIKE` (appended, enum values unchanged) with windup/active/recovery ticks + arm packed in clip_arg (20 bits) by `RigInput.pack_strike`; ROLL's clip_arg now carries the roll's length.
- 01:10 MILESTONE gates on 7e8157d7: lint 13/13, unit 701/701, scenarios 28/28.
- 01:13 FRICTION first live clip: the arena range dummies go unexposed 30 ticks after any hit (built for gun TTK), so a combo counted only its first claw -> built a station with real cops instead (ArenaClawCops hook, arena_stations/rivet-arsenal.json).
- 01:18 BUG found in the live arena (not visible in the evening's dev reel, which used a 0.45 m slack): the jab's knockback pushed the cop out of the backhand's reach. DECISION claw step-in (lunge_m 0.4/0.5). After: 7/7 claws land, 3 cops down, 0 whiffs.
- 01:21 MILESTONE scenario_rivet_claw (real ArenaSession + ArenaRivetBot, replay identical, planted no-step-in caught). Commit 2df4f3b8.
- Feel numbers in the live arena (sim-true, 60 Hz; scenario telemetry `evidence/rivet-arsenal/rivet-claw-telemetry.json`): sprint top 6.20 m/s; input latency 0 ticks in the sim (arena telemetry `input_latency_ticks` all 0); claw finisher at tick 31 after the first press when mashed (516 ms, test_live_melee cadence test, exact). DISPLAY latency (input to pixel) still UNMEASURED: needs a live-window probe.
