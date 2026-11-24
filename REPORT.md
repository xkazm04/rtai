# REPORT lane combat, run n28 (2026-11-24) - DRAFT (filled as items land)

Branch `n28-combat`, worktree `gtai-wt/n23-street`, cut from `main` `d0ab9d03a`; keys' dash merged as `97b49b194`
(`n28-keys` `64004a59d`, cooldown 40 -> 24). Director Opus 5.5; builder Claude Sonnet 5.5 (`builder.mjs` until it hit
the weekly limit at 17:44, then in-session Sonnet subagents from the same brief files). Films and stills:
`C:/Users/kazda/kiro/gtai-masters/n28/combat/` (`frames.json`). Final gate: TODO.

## What works

### 1. Tonnage's own mastery bar, Kerf's boss cut at 5 (`2f9bf4d76`, table `b88b7278c`, mutate `448a20e55`)
- `ghost_forms.json` `bond.master_at` 30 (unchanged), new `bond.master_at_by_form: {"tonnage": 85}`, `per_boss_cut` 3 -> 5.
  Absent forms use the general bar (tests in `project/tests/unit/test_ghost_bond.gd`).
- 85 was chosen from data: a probe arm with Tonnage's bar out of reach recorded his bond at every rest on the ten seeds;
  his bond at rest 7 is at most 80 (seed 1), so 85 is the smallest multiple of 5 that holds his first mastery to wave 8+.
- Ten seeds of the average test player (`evidence/n28/bond/mastery.md`):

| Arm | Runs with a mastery | First-mastery waves | Ghosts mastered | Kerf mastered |
|---|---:|---|---|---|
| n27 (30, cut 3) | 4/10 | 3, 3, 4, 8 | ohm, tonnage | no |
| n28 (Tonnage 85, cut 5) | 2/10 | 8, 8 | kerf, ohm | yes (seed 5, wave 10) |

- Mutate on the bar code: 7/7 killed. Film `films/bond_mastery.mp4` (32 px/m, 1920x1080, 60 fps, 28.8 s), still
  `stills/bond_chips_64.png` + `stills/bond_chips_crop_3x.png`.

### 2. No red in the deflect spark (`7e95d96fb`, rule pinned `377ebd735`, mutate `993552b23`)
- What drew it: not the spark. A turned round has its range reset so it reads as fresh, and `BareGunFx.shot` drew the
  stand-in muzzle flash (`flash_pistol`, vermilion core) for it. Proven by bisect at the guard take t105 64 px/m
  (`--feel=off` and removing the deflect marks left 539 reddish px; removing the shot draw dropped them).
- Fix: `PlayerDeflect.TURNED` meta (view only) skips that flash. Reddish px in the fleck crop: guard 162 -> 3, plasma
  sword 161 -> 0.
- Mutate on the extracted rule `BareGunFx.flashes()`: 5/6 killed (first run 0/4 on a marker-only test, fixed by the test).
- Film `films/deflect_6m_32.mp4` (1920x1080, 60 fps, 39.67 s); stills `stills/deflect_{guard,blade}_{before,after}_64.png`.
- Red audit of every combat effect, list only: `evidence/n28/red/audit.md` (28 rows, contact sheet `evidence/n28/red/cells.png`).

### 3. Electric cells in the halo look (`2d2f12f69`, tests `c214ee2c0`, notes `431f09db2`)
- `WeaponFxElectro.chain()` and `stun()` no longer draw the cream `arc`/`spark` cells with an 8-way ink outline. They
  draw live current with `ElectricArc`'s own strokes: 2 px cream core, amber halo 4.5 px at alpha 0.5 and 9 px at 0.18,
  in screen pixels at every zoom, no ink rim. The chain gets a jagged stroke from a to b and a star of 3 to 4 forks
  (0.24 m) where it lands. The daze is two small stars (0.3 m forks) on the old orbit, each with a faint ink under-halo
  (alpha 0.3) so it reads on cream paving. Kinks come from a hash of the ends and the 3-tick cell (no RNG).
- Why live strokes and not image-tool cells: the look is then exactly the wreck arcs' the owner already accepted (one
  source, `ElectricArc.strokes`), stays thin at 64 px/m where cells blur, and spends no image rolls (IMAGES 0/25).
- Before is one flag away: `--electro-cells`.
- Stills (64 px/m unless named): `stills/electro_stun_pair_64.png` (before left), `stills/electro_stun_after_32.png`,
  `stills/electro_deflect_pair_64.png`, `stills/electro_chain_pair_48dev.png` (dev view, see What does not).
  Films (32 px/m, 1920x1080, 60 fps): `films/claw_shock_robots.mp4` 27.2 s, `films/electro_gun_wrecks.mp4` 18.0 s.
- Unit `--changed` 4196 pass / 0 fail. Mutate 6/15 killed (40 %) after a test follow-up (first 2/15); survivors are
  the hash constants, the fork-bend arithmetic and the old cell path.

### 4. Two troopers against the shorter dash
(table `6b1d459c8`, film notes `b9df9127b`; keys' dash `64004a59d` merged as `97b49b194`)
- Take `pair_dash` (Rivet circles two rocket troopers at 10 m and dashes across each rocket line), seeds 1 to 10, 25 s.
  Before = this HEAD with `dash.cooldown_ticks` 40 toggled uncommitted (it reproduces n27 exactly: seeds 3 and 5 lose
  50.9 and 40.6 HP, median 4.6); after = dash 24. Table: `evidence/n28/troopers/seeds.md`.

| pair_dash, 25 s | dash 40 (n27) | dash 24 (n28) |
|---|---:|---:|
| HP lost seed 3 | 50.9 | 5.1 |
| HP lost seed 5 | 40.6 | 1.6 |
| HP lost median (10 seeds) | 4.6 | 4.5 |
| HP lost worst | 50.9 | 8.7 |
| Downs | 0/10 | 0/10 |
| Splash / direct hits | 42 / 1 | 37 / 0 |

- The shorter cooldown covers the second rocket: on the drifting seeds Rivet now dashes 15 and 16 times instead of 13.
  The other eight seeds are unchanged to a tenth of an HP; the gain is all in the two seeds where the rockets left 36 to
  49 ticks apart.
- Film `films/trooper_pair_32.mp4` (seed 3, "n27 dash 40" left, "n28 dash 24" right, 1920x1080, 60 fps, 25.0 s). Stills
  `stills/pair_dash_late_{before,after}_64.png` at tick 1186 (the second rocket of the 1151 volley): before, Rivet stands
  in the blast at HP 78.4; after, he is clear of it at HP 95.9.

### 5. Medians on the merged tree, and what kills the test player (`a528b3bab`)
- Batches: ten seeds a profile, 40-wave gauntlet, salts 0 and 1, on this HEAD with the tables toggled per arm (the
  toggles were restored at once; `git diff -- project/data/tables` clean after): `main` = `d0ab9d03a`'s `ghost_forms.json`
  and `rivet_motion.json`, `keys` = main's bond + dash 24 (salt 0), `combat` = HEAD (dash 24 + Tonnage 85 + cut 5).
  Table: `evidence/n28/medians/medians.md`; compare main vs combat: `evidence/n28/medians/compare_s0.md`.

| median death wave (salt 0 / salt 1) | n27 after melee | n28 main | n28 keys | n28 combat | null floor main / combat |
|---|---:|---:|---:|---:|---:|
| novice | 5 / 5 | 5 / 5 | 5 / - | 5 / 5 | 0.3 / 0.3 |
| average | 8 / 5 | 8 / 5 | 8 / - | 8 / 5 | 3.6 / 4 |
| expert | 8.5 / 9 | 8.5 / 9 | 8.5 / - | 8.5 / 9 | 1.6 / 3.2 |

- Neither the shorter dash nor the bond changes move a median; `main` reproduces n27's after-melee column and floors exactly.
- **The wave 5 stomp is what ends novice and average runs** (`evidence/n28/medians/killers.md`, combat arm): it is the last
  blow in 8 of 9 novice deaths in wave 5 (16 of 17 over both salts, 94 %) and 3 of 4 average ones (9 of 10, 90 %); the
  player takes a median 81 (novice) and 100 (average) HP in that wave. Expert deaths spread over waves 7 to 11 (sentry
  turret first, 4 of 10). This is the number for the owner's stomp play-test; no value was changed.

### 6. blade6's third rifleman fires (`55f8d0778`, mutate note `8d18ddf1a`)
- The sword take picked its shooter by `beat / gap_ticks` (36-tick beat, 18-tick gap), so only riflemen 1 and 2 ever
  fired. It now rotates by rounds fired (44 / 43 / 43 rounds on blade6; `guard6` and `blade6_spaced` unchanged), pinned
  per rifleman in `project/tests/unit/test_pressure_takes.gd`.
- The return share is unchanged, seed by seed: 91 of 334 turned rounds hit, 27.2 % [22.7, 32.3] as in n27
  (`evidence/n28/deflect/blade6_three.md`): Rivet stands and all three riflemen are at 6 m, so only the shooter changes.
- Film `films/deflect_6m_32.mp4` re-taken (1920x1080, 60 fps, 39.67 s): three riflemen in shot on the sword side.
  Mutate on `pressure_rifles.gd`: 3 of 7 killed before the time cap (the shooter line was not reached).

## What does not
- No in-game electro chain hop still: no shipped take puts two targets in hop range; the chain pair is a dev view at
  48 px/m (`stills/electro_chain_pair_48dev.png`).
- The in-flight electro bolt (`arc` cell zigzag before the hop) is still the thick ink-rimmed cell; only the chain hop and
  the daze moved to live current (this run's pick named the hop and stun cells). Owner call 4.
- Electric mutate 40 % (6/15): the hash constants and the fork-bend arithmetic are unpinned (look-only code).
- Tonnage is never mastered on the ten seeds at 85 (call 1).
- The keys arm of the medians ran one salt only (no floor of its own); it matches main and combat on salt 0.
- Red outside blood remains in other combat effects (the audit lists 28 rows); only the deflect fleck was fixed.

## What blocked or slowed you (minutes each)
- Memory budget (~35 min, 16:50-17:36): the lane sessions held the cap at 6.2-7.6 GB, so the default 1200 MB Godot
  estimate waited up to 30 min a launch; headless runs moved to `GTAI_GODOT_EST_MB=600`, renders 1000.
- `builder.mjs` hit the weekly limit at 17:44 (every lane): two calls lost (c1 abandoned by me at 35 min while it waited
  on memory, c1b died at 38 min after finishing the probe). Fallback: in-session Sonnet subagents from the same briefs.
- Temp worktree at main for the "before" arm (12 min): `--import` segfaulted after 4.5 min. Replaced by a data toggle on
  HEAD (journal 19:22).

## Calls for the owner
1. **Tonnage's bar 85 means he is never mastered on the ten seeds**: his bond reached 85 on seeds 1 and 8 (waves 8 and 9),
   but both runs died before the next rest. A bar of 65 to 70 would give wave 7-8 masteries on seeds 1, 2 and 8 (probe
   curves). One data value: `bond.master_at_by_form.tonnage`.
2. **The red audit** (`evidence/n28/red/audit.md`): fire cells drawn red (blast fireball, flame, molotov rag), a
   vermilion core in every muzzle flash, the plasma sword's red hilt rings, Mertz's tazer and the burst-arc zigzag drawn
   vermilion (electric should be amber). Which to repaint, and by which lane?
3. **The wave 5 stomp** (no value changed): it ends 94 % of novice and 90 % of average wave 5 deaths, about 81 and 100 HP
   taken in that wave (`evidence/n28/medians/killers.md`). The number is yours after you play it.
4. **The in-flight electro bolt**: still the old ink-rimmed zigzag cell while the hop and the daze are live halo current
   (`stills/electro_stun_pair_64.png`). Redraw it the same way next run?
5. **The gauntlet HUD**: the "ATTACK CLAW" prompt covers the lower half of chip numbers 1-3 and chip 1 is cut by the
   left screen edge at 1080p (`stills/bond_chips_crop_3x.png`). Not combat's file; for keys/HUD.

## Merge notes
- `project/boot/collect_call/view/bare_gun_fx.gd` (no lane owns it) gained the turned-round skip.
- `rivet_motion.json` is keys' file: merged from `n28-keys` `64004a59d`, never edited here.
- Root `JOURNAL.md` / `REPORT.md`: keep each lane's own on an add/add conflict.

## Next steps
- The owner plays the wave 5 stomp and gives the number (call 3); Tonnage's bar (call 1) is one data value.
- An in-game electro chain take: two thugs within hop range of one electro bolt, filmed with and without `--electro-cells`.
- Redraw the in-flight electro bolt in the halo look (call 4); repaint what the red audit lists, by owner pick (call 2).
- Pin the electro hash and fork arithmetic (mutate 40 %) and finish the `pressure_rifles.gd` mutate run (3/7 partial).

## Builder ledger
| call | how | minutes | cost | verdict |
|---|---|---:|---|---|
| c1-bond | builder.mjs | 35 | ? | abandoned (its first Godot run sat in `mem-budget: waiting`) |
| c1b-bond | builder.mjs | 38 | $0.61 | abandoned (weekly limit; the probe arm was done) |
| c1c-bond | subagent | 36 | not metered | accepted |
| c2-deflect | subagent | 9 | not metered | accepted |
| c2b-audit | subagent | 11 | not metered | accepted |
| c6a-chip-still | subagent | 1 | not metered | accepted (it proved my review wrong: the still was 64 px/m) |
| c3a-electric-before | subagent | 3 | not metered | accepted |
| c4a-troopers-after | subagent | 1 | not metered | accepted |
| c4b-troopers-before | subagent | 12 | not metered | bounced (temp worktree import segfault) |
| c3b-electric | subagent | 42 | not metered | accepted |
| c4c-troopers-before | subagent | 5 | not metered | accepted |
| c5b-medians | subagent | 1 | not metered | accepted |
| c6b-rifleman-chain | subagent | 75 | not metered | accepted (part A; part B chain still not reached) |

Brief differently: for a "before" arm whose difference is data, toggle the data on HEAD from the first brief instead
of a temp worktree; ask for an in-game frame of the effect itself (the chain still fell back to a dev view because the
named take tick showed the bolt, not a hop).
