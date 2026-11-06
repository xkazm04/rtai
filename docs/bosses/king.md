# King: Act 1 boss (moveset)

Lane n7-king, 2026-11-05. Target: `pof/games/gtai/art-direction/targets-2026-11-05-bosses/img/boss_king.jpg`
(r5 k3, Codex 0.166). Owner: "follow original king's approach to cover the character and his gang in
luxury and wealth. Keep name King". Numbers live in `project/data/tables/bosses.json` (`bosses.king`);
this page is the design they implement. Framework: `project/features/bosses/` (shared with servo).

## Who he is, at game zoom
REG-1, the original press king: a squat hydraulic press-operator robot, about 1.6x Rivet's bulk, two
piston arms ending in flat press plates (gold-leafed), a dented tin crown under a heavy jewelled one,
a vermilion fur-lined cape (vermilion is allowed here by verdict: the King's cape), a shoulder
megaphone, gold chains. He rides a gilded black stretch car with a throne on its back and a gold hood
cannon; his gang (grey bodyguard bots in gold chains and black visor shades) push it and ride on it.

**The top-down read (the sheet's 90-degree panel is the brief):** a long black slab with a gold rim,
a gold cannon barrel forward, the throne mid-car with a vermilion fan (the cape) and a white fur
edge, a gold crown disc; four grey heads at the corners. On foot: a wide grey disc between two gold
plates, a vermilion cape fan behind, a gold crown. Nothing else on the street is that long, that
black-and-gold, or carries vermilion at that size, so he reads against Rivet (tan), cops (blue) and
the crowd (paper greys).

## The telegraph rules (enemy-ai's, scaled up for a boss)
- Every attack has a **windup** (the tell) of at least 1.0 s, an **aim that tracks then locks**
  `aim_lock_s` before the active window (0.3-0.45 s, against enemy-ai's 0.2 s for a cop: the zones
  are bigger), an **active** window and a **recovery**.
- **The tell draws the real zone** (`BossTellView` from `BossZone`, the same numbers that land the
  hit): a thin vermilion outline that firms up while the aim tracks; at the lock it fills and
  thickens. Moving out after the lock always dodges; the planted fault (lock off) is caught by
  `test_boss_fight.gd`.
- **The punish window** is the first `punish_s` of each recovery: hits take `punish_k` (1.25-1.5).
- **Hits never cancel an attack.** A phase change cuts a tell but never an active attack or its
  recovery; the transition (2.5 s) is invulnerable and plays the phase change.
- **Floors (registry encounter-balance-simulation):** reference hit = Rivet's 100 hp. No single hit
  over 30 % of it (the ram, 30). A death inside 5 s of the fight's start is a fail.

## Phase 1: the procession (hp 100-66 %)
The throne-car rolls down the boulevard, the gang riding the running boards. It keeps 12 m off
Rivet (`KingMoves.CAR_KEEP_M`) so the ram has room.

| Attack | Tell (windup / lock) | Active | Recovery (punish) | Counterplay | Punish |
|---|---|---|---|---|---|
| **Ram** (charge, 22 m x 3.2 m lane, 15 m/s, 30 dmg) | 1.3 s / 0.45 s: the engine revs (body shake), headlights flare, the car backs off 1 m; the lane draws from the grille | 1.4 s along the locked line | 1.6 s (1.2 s x1.5): the car skids, the gang hops off to push it straight | step sideways out of the lane after the lock; walls stop the car | shoot the stalled car; Tonnage's slam or Kerf's chain on the pushing gang |
| **Coin fan** (cone, 14 m, 50 deg, 10 dmg per hit; was 14, tuned it5) | 1.0 s / 0.3 s: the hood cannon swings to Rivet and glows | 0.6 s: a hail of gold coins down the cone | 0.9 s (0.6 s x1.25) | get inside 3 m (under the barrel) or out of the cone's side | close in during the recovery |

## Phase 2: the court (hp 66-33 %)
**Transition (2.5 s):** the car hits a hydrant and stalls (wrecked, smoking); the gang leaps off
(4 adds, `robot_thug` archetype re-dressed as the rich gang); King stays enthroned on the stopped car
and rules. Every 14 s, if fewer than 6 stand, more gang arrive.

| Attack | Tell | Active | Recovery (punish) | Counterplay | Punish |
|---|---|---|---|---|---|
| **Coin fan** (as phase 1, from the stopped car) | 1.0 s / 0.3 s | 0.6 s | 0.9 s | as above; use the gang as cover (the coins hit them too, later) | close in |
| **Decree** (no zone; buffs the gang 6 s: x1.3 damage, x1.2 speed) | 1.2 s: King raises the megaphone, a vermilion shout ring pulses | 0.5 s: the shout | 1.8 s, all of it punish x1.5 | interrupt nothing (hits never cancel), so kill gang before it lands or step away from them | the longest punish window in the fight: the best moment to hit King |

## Phase 3: the king on foot (hp 33-0 %)
**Transition (2.5 s):** King stands and, from 45 % into the transition, steps down off the car's
right side with his cape (`KingBeats`, `KingMoves.step_down`); the car stays where it stalled,
smoking (render only so far: not yet cover); the remaining gang stays (they are not refreshed).

| Attack | Tell | Active | Recovery (punish) | Counterplay | Punish |
|---|---|---|---|---|---|
| **Press slam** (a leaping circle: the 3.2 m ring tracks Rivet up to 6 m out, `leap_m`; 28 dmg; a shockwave ring and a coin shower on impact) | 1.1 s / 0.35 s: both plates rise over the head while the thin ring follows Rivet; at the lock the ring fills and King hops onto it | 0.25 s | 1.3 s (1.0 s x1.5): plates down in the cracked street | leave the filled ring after the lock (a 3.6 m step, or a roll) | the plates are down: free hits from close range |
| **Charge** (10 m x 2 m lane, 11 m/s, 24 dmg) | 1.0 s / 0.35 s: shoulder dips, cape flares | 0.9 s | 1.4 s (1.0 s x1.5): he stumbles | sidestep after the lock | shoot his back while he stumbles |
| **Coin fan** (from the megaphone hand: a shorter, faster fan; first pass reuses phase 1's row) | 1.0 s / 0.3 s | 0.6 s | 0.9 s | as above | as above |

## Defeat
At 0 hp: the crown falls first (spins on the street), the press plates hiss and drop, King sags to
his knees and powers down (oil, never red: a robot), the cape settles. The gang runs. The boss
stinger plays and the loop fades (`assets/audio/sfx/boss_stinger_01.wav`, `boss_loop_01.ogg`).

## How Rivet's weapons and the four ghosts meet the fight
King's body is an arena hostile (`Fighter.brain_owned`), so everything that hits anyone hits him;
the framework routes the hp through `BossFight.hurt()` (punish window, phase floors, invulnerable
transitions).
- **Guns** (pistol, rifles, the Gatling, rockets, molotov): full damage. Rockets and molotovs are
  the punish-window tools; the car in phase 1 is the big target.
- **The claw / melee:** full damage; the punish windows are long enough to close in (1.0-1.8 s).
- **Tonnage** (plates 0.3, press slam, ram): Rivet can tank one ram with the plates on (30 -> 9);
  his slam wrecks parked cars that shield the gang and flattens the gang adds; on King it is a big
  hit, never a stagger.
- **Dent** (seize, ride, steer a car, overload blast): the counter to the procession. A seized car
  rammed into the throne-car during its recovery is the phase 1 highlight. Phase 2 (stalled car):
  ram the gang. Locked in quest 1 until his act (d7-calls), so it is a replay-strength option.
- **Kerf** (blink-slice chain, robots take 4): blinks through the gang in phase 2; on King each cut
  is a hit; a blink to behind King during the charge's recovery is the read.
- **Ohm** (forked bolt, stun 1.2 s, machine_k 3 on robots): King and his gang are robots, so Ohm is
  strong here (x3). A stun on King **during IDLE or a tell** cancels the tell and dazes him 0.6 s
  (half a human's stun: a boss resists); in an active window or recovery it only deals damage
  (hits never cancel an attack). NOT BUILT YET (iteration 2+).

## Numbers (first pass; measured, not balanced)
Iteration 1 (seed fixed, n=1 per bot, CONTENDED, Rivet on the arena's default weapon):
dodging bot kills King in 68.5 s and takes 128; the standing bot leaves him at 7 % after 90 s and
takes 254. The coin fan hits the dodging bot 7 of 8 times: it is not dodgeable sideways from 8 m.
Envelope for this fight (boss: long build, late climax; registry combat-pacing-and-dramatic-arc):
60-120 s for a player who reads the tells, Rivet's damage taken 40-80 % of his hp without a death,
every attack's hit rate against the dodging bot under 35 % and against the standing bot over 60 %
(it must be readable and still threaten). Next: n >= 10 seeds per bot, per-attack damage share
(over 30 % from one attack is a finding), then tune.

Iteration 2 (King's boulevard, the walk and adds fixes, the rigs; seed fixed, n=1 per bot,
CONTENDED; `evidence/king/bot-{dodge,stand}-it2d.json`): the dodging bot kills King in 81.9 s and
takes 30 from King and the gang (King 1 of 17 attacks landed: one ram; gang 5 of 16), no death;
the standing bot kills him in 88.5 s, King lands 13 of 17 (coin fan 9/9, ram 2/2, two late body
hits), the gang 11 of 20, one death. Both inside the 60-120 s envelope; the middle (a bot that
reads about 70 % of tells) is still unmeasured, so this is not called balanced.

## Build order and state
1. Framework + this moveset: done (iteration 1).
2. Body: a KingPlan cutout rig from new part sheets (gold plates, jewelled crown, fur cape, chains),
   the throne-car as a boss-owned vehicle (DECISION below), the rich gang variant. NOW (iteration
   2): King on `KingPlan(1.55)` and the gang on `GangPlan` (the thug in gold chains and a black
   visor, `tools/art/gang_parts.py`) through `KingRigs`; the car, the cape, the coins and the gold
   accents at game zoom (`KingAccents`) are drawn; `--boss-shapes` is the drawn first pass.
   Iteration 3: King's chest and press arms print gold (print swap 5, `KingRigs.king_plan`, a
   DECISION instead of a part sheet: the sheet's gold is lost to the stickers at 32 px/m); every
   attack plays on the rig from its windup; the leaping slam with `KingShock`; the stall smoke,
   the step-down and the car left behind (`KingBeats`); the crown falls on the defeat; the boss
   music in the arena (`BossMusic`).
3. Phase 1, 2, 3 as above; the arena: King's boulevard (dev-arena area `boulevard`, 80 x 30 m:
   planters, centre line, plaza plinths; iteration 2); the bot's numbers; clips.

DECISION (iteration 1): the throne-car is a **boss-owned vehicle** drawn and driven by King's own
moves, not a city-sim car. The sim's cars are a fixed set driven by traffic and Dent's seize; a
6.6 m stretch body with a throne, a gang and a scripted ram would need a new sim car class and
parity re-bless. The alternative (a re-skinned sim car) stays open if the owner wants Dent to be
able to seize the throne-car itself.
