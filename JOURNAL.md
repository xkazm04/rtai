# JOURNAL - lane rivet-arsenal (night 2026-11-04)

## Iteration 1 (01:04 - 02:04)
- 01:04 read: rivet-motion REPORT (nothing wired live), arena REPORT (`--rigs` dev flag draws cast rigs; quest 1 default view still draws sprites), StagePilot (TopDownMover + electroshock jab), ArenaRigs.
- No other night lane JOURNAL exists yet; no REQUESTs addressed to rivet-arsenal.
- Registry rules applied: realtime-combat-semantics (hit test on the first active tick only, one damage chokepoint `CombatArena.damage`; i-frames gate damage via `exposed`), motion-quality-gating (every claim gets a scenario with a planted fault).
- DECISION live-melee: the claw combo (MeleeCombo over rivet_melee.json) replaces the electroshock jab in StagePilot, so quest 1, the arena and the city block all swing the same combo. The jab's single 30-tick cooldown hit is gone; the charged shock (MeleeShock) is not wired yet (needs a hold/release on the melee key). Rejected: keeping the jab and adding the combo on another key (two melee keys read worse).
- DECISION live-motion: PlayerMotion replaces TopDownMover in StagePilot (sprint bit 5, roll bit 6 already bound). Roll i-frames close Rivet to damage through `Fighter.exposed` (the existing gate).
- DECISION rig-strike: new `RigClips.Clip.STRIKE` (appended, enum values unchanged) with windup/active/recovery ticks + arm packed in clip_arg (20 bits) by `RigInput.pack_strike`; ROLL's clip_arg now carries the roll's length.
