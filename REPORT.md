# n31 ghost - Tonnage drops, charges and dumps on a circle that clears a group (DRAFT, session 4)

Lane `ghost`, branch `n31-ghost`, worktree `C:\Users\kazda\kiro\gtai-wt\n25-yard`, base `main` `ba8e470b0`.
Draft written 00:30 by the director; final sections (gate line, ledger totals, Ohm and later ghosts) are filled at 07:40.

## What works

### 1. The complaint measured on main (item 1)
- Tool `tools/ghost/deploy_measure.mjs` + dev scenes `project/dev/ghost_n31/` (lab: 4/8/12-cop cluster shapes taken from gauntlet play; play: 10 seeds, the average bot drops Tonnage whenever ready on the densest cluster in range). Tables: `evidence/n31/ghost/measure-main.md`.
- Main: the half-disc of 4 m hits 4.33 of an 8-cop cluster (54 %); in play 106 deploys hit 2.80 mean (median 3), killed 2.33, 2 hit nobody. A human-like press holds the key 0.9 s (54 ticks) to aim before anything happens.

### 2. The new Tonnage deploy (item 2)
- One press, no marker, no hold: Tonnage lands on Rivet's aim point (within 6 m, wall-clipped), stands charging 0.45 s (27 ticks), then dumps on a FULL circle of 6.5 m around him (victim body radius added); Rivet is never hit. Commits `d7db0eb24`, `0f81d27dd`; tests `test_tonnage_drop*.gd`, `test_tonnage_drop_edge.gd`.
- Numbers (main -> HEAD, `evidence/n31/ghost/measure-head.md`, JOURNAL 22:17): lab 8-cop share 54 % -> 85 %; play 8 waves mean hits 2.80 -> 3.94, kills 2.33 -> 3.39, zero-hit deploys 2 -> 0, median 3 -> 3; play 3 waves mean 3.21 -> 4.22, median 3 -> 4.
- Play take (the owner's mode): gauntlet, wheel controls, `--pick-view`, seed 3, main | HEAD side by side, `take-drop-main-vs-head-32ppm.mp4` (27.70 s): the filmed deploys kill 3/3/2 on main and 3/8/9 on HEAD (`evidence/n31/ghost/take-drop.md`).
- **What a player feels:** Tonnage now lands where you point with one press, hangs a beat with cracks running out, then flattens the whole pack in one dust ring instead of clipping two or three.

### 3. The deployment drawn in beats (item 3)
- Arrival (fall from 3 m, growing shadow, squash, dust), charge (cracks crawl outward and reach the true radius exactly on the dump tick: the telegraph, no UI ring), dump (slam cell, ink shock ring + dust ring at the radius, debris, camera kick), aftermath (crater + cracks held 2 s, 1 s fade, he lifts away). Commits `b8e1739eb`, `16ccdb99b`, `f12b3726f`; 8 generated images (IMAGES 8/60 for Tonnage).
- Drawn radius in the 64 px/m dump frame: 6.45-6.47 m against 6.5 m (bar +-0.25 m).
- Kills by the dump play the press crush inside `crush_m` and the thrown wave death beyond (`5d0f98ccd`, `a96de13c0`), stills `dump-kill-{before,after}-64ppm.png`; see the NEED below for the gauntlet street.
- Films: `take-drop-head-64ppm-halfspeed.mp4` (15.22 s), `tonnage-beats-{32,64}ppm.png`, `dump-dust-d2-{before,after}-64ppm.png`.

### 4. Ohm (done) and Dent (in progress)
- Ohm before (main): lab 8-cop share 45 %; play (relaxed bot fit, 10 seeds x 3 waves) 42 deploys, mean 2.98 hits, 52 % of the foes within 9 m (`evidence/n31/ghost/measure-others-main.md`, `evidence/n31/ghost/measure-ohm-play.md`).
- Ohm after: one press, he stands on the aim point, 0.3 s charge, full circle r 5 m with the body radius (`48d6fbc37`, `649a17523`); lab 8-cop 83 % (`evidence/n31/ghost/measure-ohm-head.md`); play 41 deploys, mean 3.71 hits, 68 % of near, zero whiffs (`6dcc748ed`).
- Ohm drawn in beats (`8ab450ec9`): amber creep crawling to the rim during the charge, an arc ring at the rim on the discharge, a scorch ring + burn core for 2 s + 1 s; a lighter camera kick (`hit`); drawn radius 5.10 m vs 5 at 64 px/m. The `ohm_spec_hover` sheet warning is gone.
- Ohm play take (`evidence/n31/ghost/take-ohm.md`, seed 6): wave 1 main 4 of 8 near, HEAD 7 of 12; run 10 vs 17 kills. A player: "Ohm is now one tap: he appears in the crowd, the road crackles amber out to his circle for a beat, and the whole circle drops at once, leaving a burn ring."
- Dent (`87ac21445`, `8ce635db1`, `evidence/n31/ghost/measure-dent-head.md`): one press, lane from Rivet's side along the aim laid at the press, 0.25 s wind-up, body radius counted. Play mean 1.81 -> 1.79 at the same width; widths 1.3/1.6/1.8/2.0 m give 2.04/2.00/2.07/2.24 hits. View and beats: session 5.

## What does not
- (fill at 07:40)

## What blocked or slowed you
- Session 1: a measure-on-main builder shared the tree with an edit builder (numbers had to be re-taken in a temp worktree), ~15 min.
- Session 1: our scenario run killed by another lane's builder (PID mix-up), one re-run.
- Session 2: the lane Godot lock held ~30 min by mutate runs, delaying the art builder's first still, ~30 min.

## Calls for the owner
- Where Tonnage drops: aim point (shipped) vs on Rivet: at 5.5 m in play the aim point hit 3.86 mean vs 1.17 on Rivet (25 of 54 Rivet drops hit nobody). One data value (`drop_at`).
- Charge 0.45 s: costs about 16 points of share in the lab (cops walk out): it is the counterplay he asked for; one data value (`charge_s`).
- Radius 6.5 m, dump damage 3 (kills a patrol cop, a riot front takes x0.2): the 8-wave play median stays 3 (the bot drops at >= 3 bodies); 7 m is the screen limit.
- Ohm radius 3.5 -> 5 m at a 0.3 s charge (play 2.98 -> 3.71 hits per deploy).
- Bond and mastery with more kills per deploy (Tonnage, 8 waves, shipped bot): bond per deploy 9.3 -> 13.5 (+45 %), median mastery wave 4 -> 3; a bar of about 100 would restore wave 4. Not changed.
- Dent width: `ram_half_m` 0.9 -> 1.3 halves the whiffs (11 % -> 6 %); no width under 2 m reaches a mean of 2.5 hits because the bot fires Dent at 2 bodies.

## Merge notes
- `NEED melee`: the gauntlet street attaches no `BrutalityHook`, so signature kills (incl. the Tonnage crush from the deploy) do not draw in gauntlet play; `NEED melee`: apply `evidence/n31/ghost/ohm_deploy_kills.patch` (`also_weapons: ["deploy_ohm"]` on the `ohm_shock` row) so Ohm deploy kills play the shock death.
- Digests: scenarios 68/68 at 6.5 m, no digest moved (JOURNAL 23:04).

## Next steps
- (fill at 07:40)

## Builder ledger
- (fill at 07:40 from JOURNAL `BUILDER` lines)
