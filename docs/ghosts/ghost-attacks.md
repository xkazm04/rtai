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
| **Ohm** | the machine killer: stuns a group, burns robots and cars | forked bolt (melee, every 0.5 s) | 0.5 human (+ 1.2 s stun) / 2 x machine_k 3 = 6 robot | 30 deg cone, 11 m, forks to 2 more within 3 m | 0.5 s | a patrol cop in 2 bolts, stunned (cannot shoot) between; electro X-ray kill | thug in 1 | 12 x machine_k 3 = 36 of 100 per bolt: dented, smashed, wrecked on the 3rd bolt (1 s; car nearest the aim when no body is in the cone; was 20 flat, 2026-11-05 it10) |
| | | mass (upgrade_tier 1, data hook only) | as single | arcs to up to 6 bodies within 8 m | | | | |

Per activation (measured, `--bot=ghosts`, arena 32 px/m, windowed, 60 Hz):
- Tonnage: 10 of 10 down (3 + riot + car, far pair, wave 2 of 3 + riot + car), 2 slams, 2 cars crushed,
  1 activation of 8 s, Rivet never under 92 hp (`evidence/ghosts-tonnage-32.json`).
- Dent: 5 of 5 down (2 struck in group A, 2 struck + 1 gibbed in group B), 1 seize, 1 blast, the car stopped on
  the wall line (`evidence/ghosts-dent-32.json`, `scenario_ghost_attacks`).

- Dent rides (iteration 5, `dent.ride` 1): Rivet sits on the seized car's roof for the whole link (>= 30 ticks
  in the scenario beat) and hops 4 m clear as it blows; the blast still hits hostiles only, so riding costs him
  nothing but the tether's reach: he takes the fire aimed at the car's path instead of standing back.
- The robot victim (iteration 5) is drawn on the robot thug's rig and dies the power-down death in oil: Ohm's
  machine_k bolt (1 bolt) and Kerf's robot cut (2 cuts) now land on a visible machine.
- Gore per ghost (iteration 6): Tonnage's crush and Dent's blast bleed (red is blood); Kerf's cut (`cauterised`)
  and Ohm's bolt (`electrocuted`) are dry kill kinds, so under `--gore=reduced` (no signature kill) their humans
  drop whole with no red pool. scenario_ghost_attacks holds every Kerf/Ohm human kill to a dry kind.

Madness cost and cooldowns are unchanged from powers.json tonight (Tonnage 25 / 20 s, Dent 15 / 12 s).

Kerf per activation (measured, `--bot=ghosts --ghost=kerf`, arena 32 px/m, windowed, 60 Hz): 5 of 5 down
(3 patrol + riot cop split, the robot thug in 2 cuts), 1 dash + 7 slices = 8 blinks, first kill 0.5 s after the
soul goes on, the last human 2.2 s after it, Rivet at 54 hp (the cops and the robot's tazer shot at him: Kerf has
no armour; `evidence/ghosts-kerf-32.json`, `scenario_ghost_attacks`). Iteration 7: until then the robot's two cuts
were dropped (the stand-in boss brain is only `exposed` while its tazer is spent, and CombatArena.damage skips an
unexposed body), so the claw finished it after the form ended; the Kerf beat now holds it exposed like Ohm's, and
the scenario needs the robot to fall to a ghost's own kill kind (`robot_ghost`: Kerf `cauterised`, Ohm
`electrocuted`). Madness 20, cooldown 10 s (powers.json).

Ohm per activation (measured, `--bot=ghosts --ghost=ohm`, arena 32 px/m, windowed, 60 Hz): 5 of 5 down (the robot
stand-in to the first bolt, the three-cop knot in two forked bolts, the riot cop in five), then the cruiser burnt
out in 5 more bolts: 16 bolts, 12 bodies struck, Rivet untouched at 100 hp (the stuns keep the cops from firing;
`evidence/ghosts-ohm-32.json`, `scenario_ghost_attacks`). Madness 20, cooldown 14 s (powers.json).

Iteration 3 (2026-11-05 02:00, GhostPilot drives all four; the attacks wait for the settled form):
- Through the real switch (G selects, Q transforms, attack after enter_s): the four arena beats still 5/5 or
  10/10 (`scenario_ghost_attacks`, `evidence/scenario-ghost-it3.log`). Kerf's walk is now the form row's 12 m/s
  (was speed_k 1.5 x 6.75 = 10.1); its 6 s duration includes the 0.5 s transformation.
- City block (`--arena=city`, after the placement fix): Tonnage 10/10 + 2 cars crushed, Rivet 100 hp; Dent 5/5,
  1 seize, 5 strikes, 1 blast (blown on command in B); Kerf 5/5 (8 blinks); Ohm 5/5 (11 bolts, 3 car bolts).
- Ohm upgrade_tier 1 (mass arc, `--tier=1`): the three-cop knot down at tick 119 (tier 0: 149), 5/5
  (`evidence/ghosts-ohm-mass-32.json`): the tier is worth one bolt on a group of five; a quest reward can also
  raise human_damage if it should feel bigger.

Quest 1 on the city (iteration 11, the four `scenario_quest1_<ghost>` scenarios: the shipped quest session, dock
guards spawned beside Rivet after a 420-tick warm-up, a scripted pad through the bound actions, 60 Hz):

| Ghost | Pad | Outcome (one seed, replayed twice: same counts and state hash) | Planted fault caught |
|---|---|---|---|
| Tonnage | Q; walk to the start-side ghost car; melee every 20 in reach | 1 slam, 3 bodies hit, the car flattened (WRECK), 4 kills | `car_crush_m` 0: the car stands |
| Dent | G; Q; fire every 20 (stick on the nearest guard); melee at 200 | 1 seize, 4 strikes, 4 kills, 1 blast, 131 riding ticks | `ghost_cars` []: 0 seizes, 12 frayed misses |
| Kerf | G G; Q; melee every 20 (stick on the nearest guard) | 6 blinks, 5 slices, 5 kills (all five guards) | `human_damage` 0: 0 kills |
| Ohm | G G G; Q; melee every 20 (guards, then the nearest car) | 9 bolts, 10 struck, 5 kills, 3 car bolts, the car WRECK | `machine_k` 0: the car stands |

Read across: Kerf clears five spread guards fastest and alone (one per press), Tonnage takes a group and a car
in one slam but must walk to it, Dent needs a car on the line, Ohm is the slowest on humans and the only one
that wrecks a car from range.
