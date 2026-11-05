# Servo, Act 2's boss: moveset (designed before it is built)

Target: `pof/games/gtai/art-direction/targets-2026-11-05-bosses/img/boss_servo.jpg` (r4 b5).
Servo is a collaborator and scab: a courier-hub robot that delivers for the human corporations
(crates stencilled **CS**). His back is a launch rack of delivery drones. The drones are the
fight's identity; Servo himself is the slow, heavy hub that aims them.

Numbers here are the first draft; the live values are in `project/data/tables/servo.json` and
are re-measured by the bot (`--bot=boss --boss=servo`). Never call a number balanced without the
measured table at the end of this file.

## 1. Body and the top-down read (32 px/m, straight above)

The sheet's 90-degree panel is the read: a **wide bar of rack cells** (two wings of 2x3 drone
bays, about 5.4 m across and 1.6 m deep) with the slim **visor head and cargo belly** in the middle
and the two **round hover pads** hanging at the sides on long arms. Two long walker legs step under
the bar. At 32 px/m that is ~173 px wide against Rivet's ~35 px: four to five Rivets across, never
mistaken for a cop (no blue), a car (legs and pads move) or the crowd.

- Palette: bone/tan plates (the print's light tan), gunmetal joints, **hazard stripes in a
  muted orange-brown** on the rack ends and pads (not vermilion: vermilion is reserved for danger,
  so it appears only on the scanner beam, the drop markers and the kamikaze drones' tells).
- Layers (depth order, top-down): legs (lowest) < pads + arms < belly + head < rack wings
  (top) < drones docked in the rack cells (the rack is its own animated layer: each of the 12
  cells shows a docked drone, empty after launch, refilled during the dock window).
- The drone: a small quad-rotor with a CS parcel slung below; ~0.7 m across (22 px at 32 px/m),
  four rotor discs read as a + shape; its **shadow on the ground** is the read of where it is,
  offset by its height.

## 2. Telegraph rules (the enemy-ai rules, scaled up for a boss)

- Every attack has a **windup** with a tell drawn on the ground in vermilion, the aim **tracks
  then locks** `aim_lock_s` before the active window (enemy-ai: 0.2 s; Servo: 0.3-0.5 s, he is
  big and the drops land on a spot, not on Rivet), and moving after the lock dodges.
- A thin tell while tracking, a thick one once locked (the cop gun-line rule).
- Every drop shows its **marker on the ground for at least 0.6 s** before the package lands: a
  dashed ring the size of the blast, filling as the package falls; the drone's shadow sits on it.
- Hit reactions never cancel an active window. A heavy hit (rocket, Tonnage slam, a seized-drone
  blast, Ohm's bolt) during a **windup** spends one poise; at 0 poise the windup is cancelled
  into a stagger (poise refills each phase).
- At most **8 drones alive** at once (6 in phase 1); at most 2 attacks' tells on screen at once.
  Never noise: the ground marks are the read, the drones are the dressing.

## 3. Attacks

| id | Telegraph (windup + tell) | Active | Recovery / punish | Counterplay |
|---|---|---|---|---|
| `scan_lock` | Servo plants, visor slit glows; a thin vermilion beam sweeps a 70 deg arc (1.1 s). Crossing Rivet it **tracks** (thin), then **locks** 0.4 s before the end: thick beam + a vermilion ring stamped on Rivet's spot | The ring becomes the **mark** (lasts until the wave drops) | 0.9 s, stationary: the punish window (x1.25) | Break line of sight behind a crate or bay pillar while it tracks (beam blocked = no mark); or just leave the marked spot |
| `drop_wave` (follows a mark) | 3 drones (phase 1) launch from the rack cells (0.5 s, cells go empty), fly to the mark in a loose V, hover 0.7 s over **their own drop rings** (dashed vermilion, 1.6 m) | Packages fall 0.35 s. Each package is `bomb` (blast 1.6 m, 22 dmg) or `crate` (a CS crate that stays 12 s as an obstacle and cover, 3 hp) by the `servo_swarm` stream | Drones return to dock (1.6 s): the **dock window**, Servo's rack is open, x1.5 damage | Leave the rings; shoot drones before the drop (they die in 1 hit and drop their parcel early, where they are) |
| `rotor_dash` | The pads spin up, a dust ring, a vermilion **lane arrow** (2.4 m wide) drawn along the dash line, tracking Rivet; locks 0.35 s before go (windup 0.9 s) | 14 m at 22 m/s; 30 dmg + knockback; smashes crates in the lane | 1.2 s skid and vent: punish x1.5 | Sidestep after the lock; Kerf blinks through the lane to behind him |
| `package_carpet` (phase 2) | 4-5 drones form a **line** and fly a lane across the yard; the lane is painted first (dashed stripes, 1.4 s), 1-2 lanes at once with a clear gap | Parcels every 1.5 m along the lane | Drones dock (1.6 s) | Read which lane is safe; stand in the gap |
| `bay_hop` (phase 2) | Rotors lift Servo; his shadow slides to another loading bay; a **landing ring** (3 m) fills 0.8 s | Landing 20 dmg in 3 m | 1.0 s landing settle: punish x1.25 | Stay out of the ring; Tonnage's slam hits him on landing |
| `kamikaze` (phase 3) | The damaged rack spits drones (sparking); each draws a **vermilion dive line** from itself to a ground point at Rivet (thin, tracking 0.6 s, locks 0.3 s) | Dives, 2.2 m blast, 18 dmg | none (each drone is spent) | Step off the line after the lock; shoot or chain them in the air |

Phase 3 changes `rotor_dash`: cooldown halves; **two dashes in a row overheat him**: a 2.5 s vent
(steam, glowing pads), the fight's biggest punish (x2).

## 4. Phases

| Phase | hp | Attacks | What changes (read at a glance) |
|---|---|---|---|
| 1 **the depot** | 100-65% | `scan_lock` -> `drop_wave`, `rotor_dash` | Teaches the loop: mark, drop, dock window, dash. Max 6 drones. Crates from the drops build up as cover. |
| 2 **rush hour** | 65-30% | + `package_carpet`, `bay_hop`; waves of 4-5 | Transition (2 s, invulnerable): a horn, the **conveyor starts** (it carries crates and Rivet along a belt across the yard) and the bay doors roll up; Servo starts hopping between bays. Max 8 drones. |
| 3 **overtime** | 30-0% | `kamikaze`, `rotor_dash` (overheat), `scan_lock` -> short waves | Transition (2 s): half the rack blows off (sparks; the silhouette loses one wing's cells); drones fly kamikaze; Servo dashes often, overheating. |
| defeat | 0 | - | Servo sinks to his pads, the rack's last drones drop dead around him, the visor goes dark; parcels spill; stinger. |

**As built (iteration 3, render beats in `servo_shift.gd` / `servo_fall.gd`, the sim's in
`ServoSwarm.ground`):** into rush hour he rises 8 % on revving pads while the rack reloads in a
ripple, bay by bay (the conveyor starts at the phase's first tick). Into overtime the failing wing
shakes harder and spits sparks through the 2 s; at the phase's first tick it blows off in six
pieces of debris and a ring, and the socket smokes until the end. The defeat: a white flash and a
spark burst, the pads spin down and sag in, the body slumps forward with one settling bounce and
greys out over 1.5 s, the head droops, the docked drones spill off the rack, the flying ones crash
onto their shadows (a carried crate lands, a bomb is a dud: nothing hurts Rivet after the defeat)
and the rack smoulders for good. Not yet: the horn and the bay doors rolling up; the stinger and
the boss loop come with the framework's music (n7-king's iteration-3 item).

## 5. Ghosts and Rivet's weapons in the fight

- **Dent** (seize a vehicle): a drone is a vehicle. G seizes the drone nearest the aim line (teal
  tether): Rivet steers it into Servo (blast 60, spends one poise) or into a swarm. In phase 2
  the depot's **delivery van** at bay 3 is seizable: ride it and ram Servo (stagger).
- **Ohm** (forked bolt, forks within 3 m): drones fly in formation 1.2-1.6 m apart, so a bolt
  **chains through a swarm** (each drone 1 hp, robot); the tier-1 mass arc clears a wave. On
  Servo: machine_k damage and a stun scaled by the boss stun_k (0.33); a bolt during the
  `rotor_dash` windup spends poise.
- **Kerf** (blink-and-slice line): the blink line **cuts every drone it crosses** (a line of a
  `package_carpet` formation); blinking through the dash lane puts Rivet behind Servo in the vent.
- **Tonnage** (plates 0.3, press slam): plates make packages survivable; the slam breaks crates
  and hits Servo on a `bay_hop` landing; it cannot hit drones in the air.
- **Rivet's weapons:** any gun kills a drone in one hit (they are the light targets); the
  flamethrower clears a hovering V; the rocket is the punish tool for the vent; melee on the legs
  in the dock window.

## 6. Envelope (judged by the bot)

- Fight 60-150 s (boss class); each phase 20-60 s; dead zone = no consequential event for >= 4 s.
- Rivet damage taken by a dodging bot: under 60% of hp per phase on average; a standing bot must
  lose (proof the attacks bite).
- Hit rate per attack: standing >= 0.6, dodging <= 0.25 (the enemy-ai pit measured 0.50 / 0.24).

## 7. Measured (the bot)

Not measured yet.
