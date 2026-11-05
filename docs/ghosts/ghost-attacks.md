# The four ghosts' attacks: roles, numbers, TTK (lane ghost-powers, night 2026-11-05)

Tuning lives in `project/data/tables/ghost_attacks.json` (one block per ghost, `upgrade_tier` 0) and the
old soul blocks in `powers.json` (`hauler` = Tonnage, `gearbox` = Dent). Victim hp: patrol cop 1, riot cop
2.5 (the pit's armour), robot thug 6, robot gunner 4 (`enemies.json`); a car 100 (`vehicle_handling.json`).
Base Rivet for comparison: pistol / claw, one human per hit, robots in 4-6 hits.

| Ghost | Role | Attack | Damage | Reach | Cadence | Humans | Robots | Cars |
|---|---|---|---|---|---|---|---|---|
| **Tonnage** | the wall: walk into fire, flatten a group | press slam (melee) | 3 (all in radius) | 4 m ring, 2 m crush, 3.4 m car crush, 0.9 m ahead | 0.5 s telegraph, 2.5 s cooldown | a group per slam (flattened inside 2 m, thrown beyond) | thug in 2 slams | wrecked outright |
| | | ram (move > 3 m/s) | 2 | body contact | once per body per activation | 1 per contact (thrown aside) | thug in 3 | 40 hp |
| | | plates | takes 0.3 of every hit | | while on (8 s) | | | |
| **Dent** | the bomber: turn the street's cars into missiles | seize + steer (G) | car hit 2 | lock 3 m round the aim point (9 m ahead), range 22 m | 6 s link, 12 s cooldown | 1 per hit (thrown off the bonnet) | | |
| | | overload blast | 6 | 4.5 m | armed after 0.9 s (arm_k 0.3 x 3 s); on impact / melee / full heat | all in radius (gib) | thug in 1 | the seized car wrecked |
| **Kerf** | the assassin: pick one target out of a group, fast | blink-slice (melee with a target in a 35 deg cone, 9 m, clear line) | 99 human / 4 robot | blink to 0.9 m past the target along a straight teal line | chain of 3, one charge back per 1 s, 0.3 s apart | one-shot (split, teal-white cauterised edge) | thug in 2 | no |
| | | dash (melee with nothing in the cone) | 0 | 4 m blink | spends a charge | | | |
| | | speed | walk x1.5 | | while on (6 s) | | | |

Per activation (measured, `--bot=ghosts`, arena 32 px/m, windowed, 60 Hz):
- Tonnage: 10 of 10 down (3 + riot + car, far pair, wave 2 of 3 + riot + car), 2 slams, 2 cars crushed,
  1 activation of 8 s, Rivet never under 92 hp (`evidence/ghosts-tonnage-32.json`).
- Dent: 5 of 5 down (2 struck in group A, 2 struck + 1 gibbed in group B), 1 seize, 1 blast, the car stopped on
  the wall line (`evidence/ghosts-dent-32.json`, `scenario_ghost_attacks`).

Madness cost and cooldowns are unchanged from powers.json tonight (Tonnage 25 / 20 s, Dent 15 / 12 s).

Kerf per activation (measured, `--bot=ghosts --ghost=kerf`, arena 32 px/m, windowed, 60 Hz): 5 of 5 down
(3 patrol + riot cop split, the robot thug in 2 cuts), 1 dash + 7 slices = 8 blinks, first kill 0.5 s after the
soul goes on, the last human 2.2 s after it, Rivet at 54 hp (the cops and the robot's tazer shot at him: Kerf has
no armour; `evidence/ghosts-kerf-32.json`, `scenario_ghost_attacks`). Madness 20, cooldown 10 s (powers.json).

## Planned (not built yet): Ohm

| Ghost | Role | Attack | Damage | Reach | Cadence | Humans | Robots | Cars |
|---|---|---|---|---|---|---|---|---|
| **Ohm** | the machine killer | forked bolt (fire) | 1 human (+ 1.2 s stun) / 2 x machine_k 3 = 6 robot or car | 11 m, forks to 2 more within 3 m | 0.5 s | stun, burns, then the electro X-ray kill in teal | thug in 1 | 6 of 100 per bolt |
| | | mass (upgrade_tier 1, data hook only) | as single | arcs to up to 6 machines within 8 m | | | | |
