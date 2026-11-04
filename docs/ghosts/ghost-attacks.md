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

Per activation (measured, `--bot=ghosts`, arena 32 px/m, windowed, 60 Hz):
- Tonnage: 10 of 10 down (3 + riot + car, far pair, wave 2 of 3 + riot + car), 2 slams, 2 cars crushed,
  1 activation of 8 s, Rivet never under 92 hp (`evidence/ghosts-tonnage-32.json`).
- Dent: see JOURNAL (filled when the clip lands).

Madness cost and cooldowns are unchanged from powers.json tonight (Tonnage 25 / 20 s, Dent 15 / 12 s).
