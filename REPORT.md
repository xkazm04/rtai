# REPORT lane melee (n26, 2026-11-23): hands, electric finishers, Kerf's cap, earning a ghost

Branch `n26-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, cut from `main` `0779185ac`; carries the
keys lane's `MILESTONE 8d8bb3787` (merged at 13:41). Builder (Astra) hit its account limit at 16:13; everything
after that is the director committing Astra's finished work unchanged and filming with the existing tools.

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
- A **riot cop with his shield raised to the front** takes the first rake on the shield, which opens for 40 ticks;
  the second rake kills him (m1's decision, the same rule the owner kept for the katana). In the owner film
  (one click per victim) he therefore stands: patrol cop t110, SWAT t474, contractor t656, rocket trooper t838
  die to one click; the riot cop goes 2 -> shield open.
- Evidence: `evidence/n26/hands/frames/review-32.jpg`, `review-64.jpg`, `evidence/n26/hands/scenarios.md`;
  owner film `films/hands_kills_before_after.mp4` (n24 left, n26 right, same tool, seed and ticks, 16 s).

### 2. Electric finishers on robots
- The electro gun's direct hit and the claw's full discharge shut a robot down at the electro baton's tiers
  (light robots in one contact; shield robot and turret overload 150 ticks then execute; war machine 30-tick
  stun; bosses, brain bodies, humans, chain hops and partial discharges unchanged), each with its own finish:
  claw = clamp, lift on the arc, core burst, smoking wreck; gun = bolt in, X-ray lock of the frame, plates out,
  topple (`2c3343098`, `robot_finishers.json`).
- Evidence: `evidence/n26/electric/verification.md` (68/68 scenarios, 60 s replay `cbeb734ff9b97c41`, parity
  1200 exact), `evidence/n26/electric/frames/claw_shock-32.jpg`, `electro_gun-32.jpg`; mutate 9/9 valid
  (`evidence/n26/electric/mutate.md`).
- Owner film `films/electro_gun_robot_finish.mp4` (15.5 s, real time then the hit at quarter speed): one bolt
  at 0.79 m shuts the 6 HP robot thug down at t106. Same take, the plain claw on the next four robots: thug
  6 -> 5, gunner 4 -> 3, shield robot 10 -> 9.6, war machine 26 -> 25.5, no kill (robots stay immune).
  The claw's full discharge has stills only (`stills/claw_shock-64.jpg`): a charged-claw take needs new film
  code the builder could not write.

### 3. Kerf's deployed cut on bosses capped
- `ghost_attacks.json` `deploy.boss_damage_cap` = 0.10: one deployed cut takes at most 10 % of a boss's max HP
  after armour (war machine rear cut 6 -> 2.6 HP) (`cf26818eb`).
- Boss wave, ten seeds, expert test player (`evidence/n26/kerf-cap/boss-wave.md`): wave 5 clear 15.49 s without
  Kerf, 13.20 uncapped, 14.34 capped (10/10 each); wave 10: 34.80 / 24.61 / 28.68 s (4, 3, 3 clears of 10).
  Mutate 19/20 (`evidence/n26/kerf-cap/mutate.md`).

### 4. Earning the transformation
- **Bond** (`ca3d2cc40`, `project/features/souls/ghost_bond.gd`): each ghost fills its own run-local bond from its
  deploys: `per_kill` 4 per deploy kill, `per_stun` 3 per successful deploy stun, `master_at` 25, `enabled` true
  (`ghost_forms.json` `bond`). Quest 1 tapes end with all four bonds at 0 (`evidence/n26/bond/tapes.json`).
- **Offer** (`30daba829`): a full bond reserves one of the three cards at the next gauntlet rest (layout, slot
  keys and one-pick cost unchanged); a declined mastery stays eligible. Taking it unlocks that ghost's full
  transformation for the rest of the run (`transform_unlocked` stays the global dev override). The test player
  takes a mastery card when it appears (`bot_pick.gd`). Each wave row in the result file carries
  `bond{<form id>: value}`. Tests: `project/tests/integration/test_gauntlet_mastery.gd`,
  `project/tests/unit/test_ghost_bond.gd`. Mutate GhostBond 17/20 = 85 % (`evidence/n26/bond/mutation.json`).
- **T** transforms into the mastered ghost deployed last (with one mastered, that one); with none mastered T does
  nothing.
- **Chip ring** (`d980ca3c6`, `project/features/souls/ghost_bond_ring.gd`): a teal arc inside each owned
  ghost's HUD chip fills from the top as its bond grows; at 25 the crown opens with a teal diamond until the
  card is taken. Unit `project/tests/unit/test_ghost_bond_ring.gd` (3 tests); full unit run 4030 passed 0 failed.
- **Mastery, ten seeds** (average test player, greedy picks, wheel controls, to wave 15 or death;
  `evidence/n26/bond/mastery.md`): tuned 1 / 0.5 / 25 -> **4 / 3 / 25**, because 1 / 0.5 gave one mastery in ten
  runs. Now 6 of 10 runs master a ghost; the first mastery comes at the rests of waves 2, 4, 4, 8, 8, 8 (median
  of the six 6; median of all ten 8, counting the four that died unmastered as late). Target "first mastery
  between wave 8 and 15": **met only at the low edge**: half the first masteries land before wave 8, mostly
  Tonnage on early packs. Which ghost: Ohm on seeds 5, 7, 8; Tonnage on 1, 2, 8, 10. Dent was owned on one seed
  only (8/25); Kerf never mastered (boss cuts deal damage without the kill). Longest wave 39.30 s, none near the
  180 s stall limit. The transformation is used after mastery: seed 5 entered Ohm 5 times, seed 8 Tonnage 6
  and Ohm 2.
- Owner film `films/bond_fill_mastery_ohm_seed5.mp4` (37.9 s, live gauntlet seed 5, same ticks as the measure:
  wave 9 starts at 11432 in both): Ohm's ring fills over waves 7-8, closes with the diamond, the test player
  takes `master_ohm` at the wave 8 rest, and about 34 s in Rivet enters Ohm. Stills
  `stills/bond_ring_fill_sequence_32.png`, `stills/ohm_transform_after_mastery_32.png`.

## Gate
`node tools/gate/run.mjs --rev=HEAD --reels` on `0f3111024` (16:43-17:39): **`gate: PASS`**; lint 19/19, unit
4046 passed 0 failed, scenarios 68/68, parity 1200 steps exact (planted mutation caught at 629), selftest,
export-audit 973 loaded 0 failed, reels exit 0. `gate.json`: `build/gate/0f3111024e95/gate.json` (git-ignored).
Commits after `0f3111024` touch only `JOURNAL.md`, `REPORT.md` and `evidence/n26/bond/mutate-ring.txt` (inert).
Tapes: 60 s replay `cbeb734ff9b97c41`, quest 1 tape and checkpoints identical, parity digest `94b2865f7f17d778`;
one deliberate re-pin (`rivet_claw` scenario, decision line).

## What does not
- The bond film is a screen capture of the live window (about 27 fps, not tick-exact), and the card screen is not
  drawn when the test player picks, so the offer is seen only as the ring closing at the rest; the pick is in
  the run log and result rows. A tick-exact film needs the bond film entry the builder could not build.
- The chip ring's mutate score is weak: **11.1 %** (2 killed / 18 valid, 2 invalid, 20 of 58 sampled;
  `evidence/n26/bond/mutate-ring.txt`). Its tests pin the fill fraction and the arc angles; every draw call
  (track, fill, diamond) survives deletion: nothing renders the chip in a test.
- Half the first masteries land before wave 8 (4 / 3 overshoots for Tonnage); Kerf is never mastered.
- Wave 5's boss falls in 15.5 s even without Kerf: no cap can bring that wave into the 25-30 s band (a cap only
  gives back what Kerf took). Wave 10 capped is inside (28.68 s mean).

## What blocked or slowed you
- **Astra usage limit, 16:13** (all lanes): m4b died at 34 min; its two finished parts (tuning, chip ring) were
  committed unchanged after checks (`7cf5b9e20`, `d980ca3c6`). Lost: the films call m5 (bond film entry,
  charged-claw take), and the quality pass on the weakest item. About 110 min of builder time.
- m1 and m2 each ran into the 75 min cap without a final report (about 20 min of re-reading their trees); m1
  spent ~25 min on a BEFORE scenario run on main.
- Two pre-commit retries on the tooling test `morning_run.break.test.mjs` (timing under load, ~10 min).

## Calls for the owner
- **T = the mastered ghost deployed last** (with one mastered, that one). Alternative: T cycles through the
  mastered ghosts (a small change in `project/features/souls/ghost_forms.gd`).
- **Riot cop's raised shield eats the first bare-hand rake** (opens 40 ticks, the second kills), like the katana
  you kept. Alternative: hands ignore the shield. Film: `films/hands_kills_before_after.mp4` at 4.5-7.5 s.
- **Wave 5's boss is short without Kerf** (15.5 s): the 25-30 s target needs boss HP, not a Kerf cap. Wave 10 is
  inside (28.68 s capped). Stills `stills/kerf-before-64.png` / `kerf-after-64.png`.
- **Mastery pace**: 4 / 3 / 25 gives 6 of 10 runs a mastery, but half of them before wave 8 (Tonnage on early
  packs); Kerf is never mastered (his boss cuts damage without killing). Options: count Kerf's boss damage as a
  stun-sized award, or raise `master_at` to ~30 (pushes the early Tonnage cards to 8-10 and costs one of the six).
  The mastery card replaces one of the three draws, and the test player always takes it: seed 1 spent its wave 4
  pick on it and died at 5 (it reached 13 with the Dent pick).
- Electro gun finish: thug and gunner rows look alike (same frame art); the claw discharge arcs read as white
  zig-zag glyphs at 64 px/m.

## Merge notes
- TOUCH keys-lane files (each small): `project/features/souls/ghost_deploy.gd:54`,
  `project/features/souls/ghost_pilot.gd:103` (bond recorded after a release; T via `press_transform`),
  `project/features/souls/ghost_form_hud.gd` (1 line), `project/features/souls/ghost_form_layout.gd`
  (+`chip_center`), `project/features/souls/ghost_form_view.gd` (+3, ring mount). This branch already carries
  keys `MILESTONE 8d8bb3787`.
- **NEED from pressure, not applied here**: Kerf's slice can carry Rivet through a thin wall
  (`project/features/souls/kerf_stage.gd:118`). The 6-line patch and pending test `test_gauntlet_kerf_wall.gd`
  are on `n26-pressure` (its stall cause note, evidence/n26-pressure/stall/cause.md on that branch). Apply at merge; it is souls code but
  the builder was gone and the director does not edit product code.
- NEED yard: Dale Winnick spawns as a plain `patrol_cop`; to exempt him as named, the yard spawner sets
  `MeleeLethal.NAMED` meta on him. The prologue does not mount the signature-death renderer, so hand deaths do
  not show there.
- NEED story: a quest-checkpoint mastery offer needs one hook in `project/boot/quest1_game.gd:149`; tonight the
  offer is at gauntlet rests only.
- Re-pinned: `rivet_claw` scenario (decision line, 2026-11-23). Root `JOURNAL.md`/`REPORT.md`: keep each lane's.

## Next steps
- A bond film entry (prefill a bond, the ring at 24 -> 25, the card, T) and a charged-claw robot take.
- Mastery pace per the call above; Kerf's path to a bond.
- Electro gun: separate thug and gunner wreck art.

## Films for the owner
`C:/Users/kazda/kiro/gtai-masters/n26/melee/` with `frames.json` (15 entries, best first): hands before/after
(16 s), bond fill and mastery (37.9 s), electro gun robot finish (15.5 s), robots vs blade and baton (18 s);
stills: rake deaths at 32 and 64, bond ring sequence, Ohm transformation, electro gun 64 sequence and tier sheet,
claw discharge sheets 32/64, Kerf before/after 32/64. Film paths in this REPORT are relative to that folder.

## Astra ledger
| call | minutes | verdict |
|---|---:|---|
| m1-hands | 75 (cap) | accepted |
| m2-electric | 75 (cap) | accepted |
| m3-kerf-cap | 64 | accepted |
| m4a-bond-core | 50 | accepted |
| m4b-bond-hud | 34 | abandoned by the account limit; finished parts salvaged and committed |

Five calls, 298 min. What I would brief differently: hard stop 60 min after launch with "report and END" from
the first call (the first two hit the 75 min cap silently); films brief before the last feature, not after it,
so a limit cannot take the owner's films; and commit-as-you-go every finished part (m4b left two finished parts
uncommitted when it died).
