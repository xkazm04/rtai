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

### 5. Medians on the merged tree
TODO

## What does not
TODO

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
3. **The gauntlet HUD**: the "ATTACK CLAW" prompt covers the lower half of chip numbers 1-3 and chip 1 is cut by the
   left screen edge at 1080p (`stills/bond_chips_crop_3x.png`). Not combat's file; for keys/HUD.

## Merge notes
- `project/boot/collect_call/view/bare_gun_fx.gd` (no lane owns it) gained the turned-round skip.
- `rivet_motion.json` is keys' file: merged from `n28-keys` `64004a59d`, never edited here.
- Root `JOURNAL.md` / `REPORT.md`: keep each lane's own on an add/add conflict.

## Next steps
TODO

## Builder ledger
TODO
