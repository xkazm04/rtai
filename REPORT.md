# REPORT lane melee (n26, 2026-11-23): hands, electric finishers, Kerf's cap, earning a ghost

Branch `n26-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, cut from `main` `0779185ac`; carries the
keys lane's `MILESTONE 8d8bb3787` (merged at 13:41). DRAFT (session 4): final numbers, films and gate line land
after the freeze.

## What works

### 1. Bare hands one-shot humans
- One claw swing kills the patrol cop, riot cop, SWAT, contractor, rocket trooper, plain guard and (since
  `03f42c220`) the appliance warden. Each archetype has its own drawn rake death with blood (`912cf4552`,
  `project/features/combat/kills/`, `signature_kills.json`).
- Exempt: **Mulroney** (the prologue's named human with the shotgun, `melee_named_human` meta: a named
  character must not fall to one swing) and every boss
  row. Robots stay immune to the plain one-swing kill.
- Prologue (fought with hands), pilot seeds 1..5 before and after: identical on every seed (patrol 1851-1876
  ticks, squad 2097-3470 ticks, lowest HP 0 on seeds 1, 3, 5 on main too): the prologue humans have 1 HP and
  already died to one claw contact (`evidence/n26/hands/prologue-after.md`). No NEED for the yard lane.
- Evidence: `evidence/n26/hands/frames/review-32.jpg`, `review-64.jpg`, `evidence/n26/hands/scenarios.md`.

### 2. Electric finishers on robots
- The electro gun's direct hit and the claw's full discharge shut a robot down at the electro baton's tiers
  (light robots in one contact; shield robot and turret overload 150 ticks then execute; war machine 30-tick
  stun; bosses, brain bodies, humans, chain hops and partial discharges unchanged), each with its own finish:
  claw = clamp, lift on the arc, core burst, smoking wreck; gun = bolt in, X-ray lock of the frame, plates out,
  topple (`2c3343098`, `robot_finishers.json`).
- Evidence: `evidence/n26/electric/verification.md` (68/68 scenarios, 60 s replay `cbeb734ff9b97c41`, parity
  1200 exact), `evidence/n26/electric/frames/claw_shock-32.jpg`, `electro_gun-32.jpg`; mutate 9/9 valid
  (`evidence/n26/electric/mutate.md`).

### 3. Kerf's deployed cut on bosses capped
- `ghost_attacks.json` `deploy.boss_damage_cap` = 0.10: one deployed cut takes at most 10 % of a boss's max HP
  after armour (war machine rear cut 6 -> 2.6 HP) (`cf26818eb`).
- Boss wave, ten seeds, expert test player (`evidence/n26/kerf-cap/boss-wave.md`): wave 5 clear 15.49 s without
  Kerf, 13.20 uncapped, 14.34 capped (10/10 each); wave 10: 34.80 / 24.61 / 28.68 s (4, 3, 3 clears of 10).
  Mutate 19/20 (`evidence/n26/kerf-cap/mutate.md`).

### 4. Earning the transformation
(to fill: GhostBond, offer at the rest, unlock, chip ring, mastery table)

## What does not
- Wave 5's boss falls in 15.5 s even without Kerf: no cap can bring that wave into the 25-30 s band (a cap only
  gives back what Kerf took). Wave 10 capped is inside (28.68 s mean).

## Calls for the owner
- **T = the mastered ghost deployed last** (with one mastered, that one). Alternative: T cycles mastered ghosts.
- **Wave 5's boss is short without Kerf** (15.5 s): the 25-30 s target needs boss HP, not a Kerf cap.
- Electro gun finish: thug and gunner rows look alike (same frame art); claw discharge arcs read as white glyphs.

## Astra ledger
| call | minutes | verdict |
|---|---:|---|
| m1-hands | 75 (cap) | accepted |
| m2-electric | 75 (cap) | accepted |
| m3-kerf-cap | 64 | accepted |
