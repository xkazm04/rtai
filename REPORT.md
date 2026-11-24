# REPORT lane melee (n27, 2026-11-24)

Branch `n27-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, cut from `main` `a3b3f1466`, `n27-keys`
`e1c4b73d9` merged in (`4a3ff4b04`, MILESTONE keys-order). Director: Opus 5.5. Builder: Claude Sonnet 5.5 (high), four
calls. Films and stills: `C:/Users/kazda/kiro/gtai-masters/n27/melee/` with `frames.json`. IMAGES 0/15.

## What works

1. **Mastery pace** (`58a1b8d07`). `ghost_forms.json` `bond.master_at` 25 -> 30; new `bond.per_boss_cut` 3: a deployed
   Kerf cut that hurts a boss without killing it earns 3 (a killing cut counts once, as a kill). The cut is credited on
   the release through `GhostDeployStrike.release_boss_cuts`. Tests: `project/tests/unit/test_ghost_boss_cut.gd`,
   `project/tests/unit/test_ghost_bond.gd`.
2. **Mastery is free** (`1a6badfc8`, flag `bond.mastery_free`, shipped true). Taking the mastery card at a rest applies
   it at once and the card leaves the hand. The rest stays open for one normal pick among the other cards. The draw and
   the RNG are untouched (the mastery slot is still reserved as last night). The test player takes the mastery, then
   picks as before. Tests: `project/tests/integration/test_gauntlet_mastery.gd`, `project/tests/unit/test_bot_pick_mastery.gd`.
3. **Ten-seed table, n26 beside n27** (`evidence/n27/bond/mastery.md`, data `evidence/n27/bond/mastery.json`), average
   test player, greedy picks, to wave 15 or death:

   | Arm | Runs with a mastery | First-mastery waves | Inside wave 8..15 | Kerf mastered |
   |---|---:|---|---:|---|
   | n26 (master_at 25, no boss cuts) | 6/10 | 2, 4, 4, 8, 8, 8 | 3/10 | no |
   | n27 pace (30 + boss cuts) | 4/10 | 3, 3, 4, 8 | 1/10 | no |
   | n27 free (30 + boss cuts + free mastery, shipped) | 4/10 | 3, 3, 4, 8 | 1/10 | no |

   Kerf is still never mastered. His best run is 28/30 on seed 5, with 4 boss cuts. The target band (first mastery at
   wave 8 to 15) is badly missed. See Calls for the owner.
4. **Bond film** (`def638f6e`, entry `project/dev/ghost-forms/bond_film.tscn`, render `evidence/n27/films/render_bond.mjs`).
   `films/bond_mastery.mp4` is 1920x1080, 60 fps, 28.8 s. It is a real game render, tick-exact on seed 2 with
   `--bond-prefill=6`. Tonnage's teal ring closes (full at tick 1765). The rest screen is held 2.5 s on a hand with the
   mastery card (tick 2463), and the mastery card leaves the hand (3 -> 2 cards). Ghost Ohm is then picked, wave 3 starts,
   and T goes into the Tonnage slam (tick 2884). The HUD strip reads 1 Dent, 2 Tonnage, 3 Kerf, 4 Ohm.
   M4_BOND_FILM_RERENDER
5. **Charged-claw film** (`e96913d1e`). `films/claw_shock_robots.mp4` is 1920x1080, 60 fps, 27.2 s: 20.5 s real time,
   then the first finish again at quarter speed. Victims: robot thug killed at tick 106, a second thug at 356, the gunner
   at 606, and the shield robot overloaded at 856 and finished at 956. The war machine is stunned 29 ticks and loses
   0.5 HP (never_finish). The 64 px/m close-up is `stills/claw_shock_64.png` (ticks 100, 112, 124, 140).
6. **Bond ring tests** (`9249226c6`, `01273d2a8`). `GhostBondRing.plan()` returns the draw commands and `_draw` replays
   them; tests pin every command. Ring mutate went from 2/18 to 16/19 (`evidence/n27/ring/mutate-ring-before.txt`,
   `evidence/n27/ring/mutate-ring-after.txt`). The two line-27 survivors are now covered by a test. The third survivor
   (antialias in `_replay`) is visible only in pixels. Pixel proof (`1d12de3f6`): three 64 px/m frames are md5-identical
   before and after the split (`evidence/n27/ring/pixel-proof.md`). `ghost_bond.gd` mutate is 18/20
   (`evidence/n27/ring/mutate-bond.txt`): one survivor is an equivalent mutant, and the one real gap now has a test
   (line 59 re-run 4/4).
M4_WORKS

## Gate
GATE_LINE

## What does not
- Mastery pace misses the owner's target: the early Tonnage masteries (waves 3 and 4) are untouched by the higher bar.
  Raising it only dropped the late masteries.
- Kerf is still never mastered in ten seeds. The boss cuts landed (up to 4 per run), but runs end first.
- In the bond film with a prefill, the chip shows no ring until the first release (the ring redraws only with the strip).
  In real play the value only changes on a release, so it is not seen.
- The war machine is only stunned by the charged claw (never_finish, by design). It is in the film but gets no finish.
- No headless pixel test for the ring: GUT runs on the dummy renderer, so `_replay`'s own draw calls are covered only
  by the pixel proof.
M4_DOESNOT

## What blocked or slowed you
- 15 min: `ghost_bond.gd` mutate timed out at 900 s in call 1. It was redone in call 3 with a test subset (481 s).
- 5 min: the keys merge conflicted in the `ghost_forms.json` `doc` text only (resolved by hand).
- 5 min: `test_ghost_form_hud.test_deploy_hint_follows_the_rebound_key` fails on this branch after the keys merge. It is
  keys' test, fixed on `n27-keys` by `3f2bb5c2e`, and clears at the Director's merge.

## Calls for the owner
1. **Mastery pace.** With your two numbers (bar 30, boss cut 3), 1 of 10 runs has its first mastery inside waves 8 to 15
   (was 3 of 10). The early ones are Tonnage at waves 3 and 4, and raising the bar does not move them. The single value
   that would meet the band best is `bond.master_at` 22: three first masteries at waves 8, 8 and 9. That is an estimate
   from the per-rest bond curves, not re-run, and three early ones remain. A per-ghost bar for Tonnage would be the real
   fix; it is not built (no tuning tonight). Evidence: `evidence/n27/bond/mastery.md`.
2. **Kerf's path to a bond.** Boss cuts work, but runs end before 30. If you want Kerf mastered at all in a normal run,
   the lever is `bond.per_boss_cut` (3 -> 5 would have put seed 5 over the bar; estimate).
M4_CALLS

## Merge notes
- TOUCH keys: `project/features/souls/ghost_deploy.gd:54` (one line: the record call gains `strike.release_boss_cuts`).
- TOUCH gauntlet rest code `project/features/gauntlet/gauntlet_waves.gd` (`choose()`, 3 lines) and
  `project/features/gauntlet/gauntlet_draw.gd` (`take` returns the rest of the hand after a free mastery).
- `n27-keys` `e1c4b73d9` is already merged (`4a3ff4b04`). Later keys commits (`3f2bb5c2e` test fix, `403a31a8f` larger
  chip numbers) are not, so the films show the smaller chip numbers.
- `gauntlet_run.schema.json` allows no extra pick field, so a free mastery is its own `run.picks` entry.
- Debt: `dev_loc` raised with `--accept-regression` for the bond film entry.
M4_MERGE

## Next steps
- The owner plays and gives the mastery numbers; then a per-ghost bar or a new `master_at`, re-measured on the same ten seeds.
- Re-film the bond film after the merge with keys' larger chip numbers.
M4_NEXT

## Builder ledger
| Call | Minutes | $ | Result |
|---|---:|---:|---|
| m1-mastery (items 1, 2, table) | 65 | 1.65 | accepted |
| m2-films (bond film, claw take) | 58 | 2.05 | accepted |
| m3-ring-tests (item 5, bond mutate) | 48 | 1.00 | accepted |
M4_LEDGER

What I would brief differently: give every mutate run a test subset and a time budget up front (call 1 lost 15 minutes
to a 900 s timeout). Name the dev card file in the film brief, so a blank mastery picture is found before the film.
