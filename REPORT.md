# REPORT lane melee (n24, 2026-11-22), branch `n24-melee`, worktree `n23-street`

DRAFT (session 4, 22:25): P5 rows (live telemetry, owner films), the final gate line and frames.json land later.

Owner, verbatim: "Melee weapons double-attack on one click look horrible, we need on unique swing per weapon, with
unique brutal animation per human enemies as it should one-shot them. For robot enemies we will need electric
weapons to have similar effect" and "Remove cursors for melee weapons, as they shapes are confusing".

Root for film paths: M = `C:/Users/kazda/kiro/gtai-masters/n24/melee`.

## What works

| Item | Evidence | Number |
|---|---|---|
| Cause of the double swing found | JOURNAL 17:24: with a melee weapon the swing press was LEVEL (held fire reads as a press every tick, `rivet_wheel.gd` `swing_pressed`), `MeleeCombo.press()` buffered it during hit 1 and `step()` chained hit 2 | before: 2 hit starts per 6-tick click for hands, katana, baton, plasma (M/compare/starts.json) |
| One click, one swing, per weapon | `5e4b69c76`, table value `single_swing` (true) in `melee_weapons.json` + `rivet_melee.json`; old chains kept behind `single_swing: false` | swings per click 1.0 for all five (film shot); live fight: P5 |
| Own swing per weapon | per-weapon `swing` row + `swing_style` rake/drive/crack/cut/sweep; M/compare/after-study-64.jpg | windup/active/recovery ticks, reach: claw 5/3/13 1.40 m; chainsaw 12/4/18 1.65 m; baton 4/3/14 1.55 m; katana 7/4/16 2.10 m; plasma 8/6/19 2.20 m |
| Plasma sweep narrowed to its drawn arc | `e2f881f42`: cone_dot -1 (a 360 spin) -> -0.2 (about 203 deg front); deflect active window kept | |
| One swing kills a human, per weapon x type | `2dfefbbc7` `MeleeLethal` + `MeleeContact`; per-victim variants in `signature_kills.json` (weapon x archetype, falls back to the weapon row); M/kills/*_64.png, M/kills/variants | patrol, riot, SWAT, contractor, rocket trooper x katana / chainsaw / baton / plasma |
| Riot shield rule per weapon | `2dfefbbc7`, row fields `vs_shield`, `shield_break_ticks` | katana: blocked from the front, shield shoved open 40 ticks, next cut kills; plasma and baton: through; chainsaw: through at the end of its committed grind |
| Electric finisher on robots | `e04b93990` `melee_shutdown.gd` + `robot_shutdown_fx.gd`; M/electric (4 clips 1920x1080 60 fps 15.2 s) | baton: robot_thug / robot_gunner shut down in one swing; shield_robot / sentry_turret overloaded 150 ticks then executed by the second swing; war_machine normal damage + 30-tick stun; bosses never |
| No melee cursor | `5a40e1370`, M/cursor/compare.png | hands + melee weapons show the system arrow; plain dot one const away (`WeaponCursor.PLAIN_DOT`) |
| Baton kill on a human shows the shock | `9f8d6c8f8` `kill_cook_art.gd`: contact flash, 20-tick seizure, white/blue/amber current over the body, then the throw; M/kills/p4/electro_baton-32.png, -64.png | before: nothing visible until +16 |
| Plasma kill is hot and bloody | `4bdda2843` `kill_plasma_art.gd`: hot streak on the cut (comic star off), edges white-hot -> amber over 40 ticks, blood fan + pool (view only, no combat RNG); M/kills/p4/plasma_sword-32.png, -64.png | 5 human types before/after |
| Robot wreck reads at 32 px/m | `f6978fc2f` `robot_shutdown_fx.gd`: bigger white-core amber arcs, wreck keeps its gunmetal plates; M/kills/p4/robot-shutdown-32.png, -64.png | before: pale cut-out |
| Decision lines | `7144b8a1a` docs/decisions.md: cursor, claw, robo_tazer | |
| Gate on `f6978fc2f` | `node tools/gate/run.mjs --rev=f6978fc2f` PASS, `build/gate/f6978fc2f8fe/gate.json` | lint 19/19, GUT 3811/0, 67 scenarios, parity 1200, release-compile 934/0 |
| Shared arena kept to call sites | `4832ca100` | `combat_arena.gd` 2 changed lines vs `b3f4727c0` |
| Tests | GUT 3792 pass / 0 fail (P3); mutate `melee_combo` 4/4, `melee_lethal` 8/12 (66.7%), `melee_shutdown` 15/20 (75%) | parity 1200 exact, bake + pinned 60 s replay held (P1) |

## What does not

- The chainsaw grind still draws a white electric zigzag on its victim (also on main): the saw's `stun_ticks` 16
  goes through the electric stun, drawn by the shared `fight_areas_art.gd`. Fix brief written (P6,
  `evidence/briefs/n24-p6-saw-hold.md`); still: M/kills/p4/chainsaw-64.png.
- The right-facing baton contact frame: needs `rivet_windup.gd` routing or new strip art (not this lane's files);
  still: M/kills/p4/baton_strike-64.png.
- Mutate `kill_plasma_art.gd` 1/19 (5.3%) after P4: tests follow in P5.
- `tools/godot/check.mjs` on `kill_styles.gd` / `signature_kills.gd` fails standalone ("Failed to compile depended
  scripts" at `rig_clips.gd:0`) on `b3f4727c0` too (`build/p4-base-check.log`): pre-existing; the gate is green.
- The "contractor" is drawn as a blue cop body: cast's art, not this lane's.
- Seven archived quest tapes diverge at tick 60 on BOTH `b3f4727c0` and this branch (pre-existing).

## What blocked or slowed you

- Godot's movie writer encoded 1280x800 despite a 1080p request; mp4s rebuilt from native 1080p frames (about 15 min, P1).
- P2 rewrote the shared `combat_arena.gd` header to fit its cap; bounced and restored in P3 (about 20 min).
- `tools/godot/check.mjs` on `kill_styles.gd` / `signature_kills.gd` reported dependency cascades (P4 item 0).

## Calls for the owner

1. Hands (the claw) are NOT a one-shot on humans: the owner said "melee weapons"; hands are the quick claw with
   normal damage. One value away: `rivet_melee.json` `kills_human`.
2. Cursor: the system arrow for hands and melee weapons (keeps a pointer for aim); rejected "no cursor at all"
   (the player loses where Rivet faces). A plain dot is `WeaponCursor.PLAIN_DOT`. Still: M/cursor/compare.png.
3. `combat.json` `robo_tazer.damage` 46 is NOT doubled: it is Quartermaster Mertz's boss weapon, not a wave
   enemy, and boss designs do not change tonight. One value away.
4. Katana vs a raised riot shield is the one blocked swing (shoves the shield open 40 ticks); the others go through.
5. Which weapons count as electric: today only the electro baton. Proposed next: the electro gun's direct hit and
   the claw's fully charged discharge.

## Merge notes

- `project/features/combat/ai/enemy_pit.gd` `hurt()` gains an optional `melee: MeleeCombo = null` and its
  front-shield multiplier moved into `MeleeShutdown.pit_damage(...)` (2 call-site lines). ai/** fire timing is
  pressure's: a conflict there is likely; keep both (pressure's timing, this call).
- `combat_arena.gd`: 2 lines in `damage()` (`MeleeLethal.damage_scale`, `MeleeLethal.death_kind`).
- Scenario expectations moved: rivet_katana 3 -> 6 kills, rivet_chainsaw 1 -> 5 (decision lines).
- NEED pressure (JOURNAL 18:39, 21:08): the test player's melee numbers and the baton vs robots.

## Next steps

- (filled at the end)

## Astra ledger

| Call | Minutes | Verdict | Brief differently |
|---|---|---|---|
| p1-one-swing | 73 | accepted | ask for 1080p frames from the start (movie writer) |
| p2-one-shot | 71 | accepted, follow-ups into P3 | name the size-capped shared file's line budget up front |
| p3-electric | 72 | accepted | ask for the 32 px/m look check before committing a look |
| p4-kill-looks | 69 | accepted (2 items stopped at the allowlist) | trace a mark to its data row before naming the file to fix |
