# Move kill times

All 260 timed fights on `a8a060feb` ended in a kill. Each pair uses the same seed (1–10), pilot, enemy positions, starting cooldowns and gun spread. Time starts at the first combat input with the form settled and the weapon drawn. A cluster kill requires all three enemies to die.

The time columns are medians at 60 ticks/s. Δ is the median paired on-minus-off difference. Faster counts seeds where the enabled arm finished earlier. Rivet HP lost, first-slice damage and slices to kill are medians. Uses are totals across ten seeds. The JSON includes per-seed measurements and keeps the original stationary turret row under `before_fix`. The probe ranks a 30 s timeout after any kill, including a kill on tick 1800.

| Move | Target | Weapon | Off (s) | On (s) | Paired Δ (s) | Faster | Rivet HP lost off/on | Uses off/on | First slice HP off/on | Slices to kill off/on |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Ohm short circuit | sentry turret (stationary, before fix) | pistol | 7.83 | 7.83 | 0.00 | 0/10 | 0.0/4.0 | 0/20 | — | — |
| Ohm short circuit | sentry turret (stationary) | pistol | 7.83 | 7.83 | 0.00 | 0/10 | 0.0/0.0 | 0/20 | — | — |
| Ohm short circuit | sentry turret (flanking) | pistol | 4.02 | 4.02 | 0.00 | 0/10 | 0.0/0.0 | 0/17 | — | — |
| Ohm short circuit | shield robot | pistol | 13.18 | 1.88 | -11.30 | 10/10 | 0.0/0.0 | 0/10 | — | — |
| Tonnage armour crack | war machine | pistol | 17.53 | 11.83 | -5.70 | 10/10 | 77.4/41.4 | 0/10 | — | — |
| Kerf blink behind | shield robot | kerf slice | 0.02 | 0.02 | 0.00 | 0/10 | 0.0/0.0 | 0/10 | 19.8/99 | 1/1 |
| Kerf blink behind | war machine | kerf slice | 0.02 | 0.02 | 0.00 | 0/10 | 0.0/0.0 | 0/10 | 49.5/148.5 | 1/1 |
| Kerf blink behind | sentry turret | kerf slice | 0.02 | 0.02 | 0.00 | 0/10 | 0.0/0.0 | 0/10 | 24.75/99 | 1/1 |
| Overkill carry R1 | 3 × patrol cop | hand cannon | 1.82 | 0.98 | -0.83 | 10/10 | 1.2/0.0 | 0/10 | — | — |
| Overkill carry R2 | 3 × patrol cop | hand cannon | 1.82 | 0.10 | -1.72 | 10/10 | 1.2/0.0 | 0/20 | — | — |
| Overkill carry R1 | 3 × patrol cop | pistol | 0.65 | 0.65 | 0.00 | 0/10 | 0.0/0.0 | 0/0 | — | — |
| Overkill carry R2 | 3 × patrol cop | pistol | 0.65 | 0.65 | 0.00 | 0/10 | 0.0/0.0 | 0/0 | — | — |
| Overkill carry R1 | 3 × robot thug | hand cannon | 4.20 | 3.37 | -0.83 | 10/10 | 0.0/0.0 | 0/10 | — | — |
| Overkill carry R2 | 3 × robot thug | hand cannon | 4.20 | 3.37 | -0.83 | 10/10 | 0.0/0.0 | 0/10 | — | — |
| Overkill carry R1 | 3 × robot thug | pistol | 5.12 | 5.12 | 0.00 | 0/10 | 1.8/1.8 | 0/0 | — | — |
| Overkill carry R2 | 3 × robot thug | pistol | 5.12 | 5.12 | 0.00 | 0/10 | 1.8/1.8 | 0/0 | — | — |

### Closest n22 cells

Median seconds per stationary target, **front / rear**. The claw is the closest melee comparison for Kerf. The carry rows above time three live enemies. [Enemy time to kill](../foes/ttk.md)

- Sentry turret — pistol **9.57 / 1.87**, claw **7.07 / 1.47**.
- Shield robot — pistol **16.02 / 2.37**, claw **11.47 / 2.13**.
- War machine — pistol **16.27 / 5.22**, claw **11.73 / 4.00**.
- Patrol cop — hand cannon **0.10 / 0.10**, pistol **0.12 / 0.12**.
- Robot thug — hand cannon **0.93 / 0.93**, pistol **1.37 / 1.37**.

### What the pilot measured

- **Ohm, stationary.** Rivet held a pistol at 8 m, released bolts on cooldown and fired between casts. Before the fix the turret fired 0/85 rounds off/on across ten seeds. Its short circuit had replaced the ordinary stun and allowed fire during immunity. After the fix it fired 0/0. Bolts every 0.5 s renew the ordinary 1.2 s stun in both arms. The turret keeps its 0.25 frontal pistol multiplier. Against the shield robot, short circuit opens the frontal arc to full pistol damage.
- **Ohm, flanking.** Both arms used the same walk-speed strafe toward the rear arc and fired between bolts while the turret was quiet. The pilot held movement and gunfire on a round or a sweep toward Rivet. The turret fired 0/0 rounds off/on. Both arms reached the kill sooner than the stationary pilot, with 0/0 rear pistol hits. Ordinary stun already gave both arms the full opportunity to strafe. Adding short circuit saved no ticks.
- **Tonnage** started 3.1 m from the walker, stepped back on the foot-ring tell, then released the stick. Every run dodged one stomp, landed one press during recovery and followed it with frontal pistol fire. The open plate took 1.0× pistol damage for 4 s before returning to 0.5×. Shots per kill fell from 49 to 33.
- **Kerf.** All three targets faced the approach on open ground, with the walker's plate closed. Each took one slice in either arm. Even a frontal hit from the 99-damage guard slice exceeds their shipped HP (shield robot 10, war machine 26, sentry turret 8). To measure damage beyond lethal HP, a separate first-hit trial repeated each seed and arm with 1,000 target HP. The table reports actual HP lost in those 60 impacts. The timed runs used shipped HP. The m2 run found that a riot cop takes full frontal slice damage.
- **Overkill carry** used base Rivet, with no bonus off and sequential `MoveCarry.grant` calls for ranks 1 and 2. The live cluster started centred 8 m ahead with 1 m between neighbours and 2 m between the outer pair. The pilot fired at the first surviving target in spawn order. A hand cannon deals 4 arena HP. It cleared the 1 HP cops in three, two or one round at ranks 0, 1 and 2. The chosen 6 HP robot thug survived the first round. Its second round carried 2 HP to a neighbour, leaving the neighbour alive and ending the chain at either rank. Both ranks saved one shot. The pistol deals exactly 1 arena HP, so finishing either enemy left zero damage to carry.

### Regression checks

The changed-unit run reported 3,680 passed, 0 failed and 2 skipped. The stats helper killed 19 of 20 sampled mutants (95%). Subtracting the disabled arm's uses survived because its test fixtures all record zero uses in that arm.

The changed Ohm line generated one deletion mutant. Removing the call leaves `legacy_ticks` unused, which fails compilation in this project. The mutation score is undefined (0 killed, 0 survived, 1 invalid). As a separate control, the two current Ohm test files passed on the fix and rejected the compiling pre-fix implementation (9 passed, 2 failed). The missing ordinary stun left the expected area effect absent.

Both mutation runs used the repository's operators and GUT oracle on committed source bytes in a scratch project under `build/dev`. The stock mutation CLI requires a separate worktree outside the lane.
