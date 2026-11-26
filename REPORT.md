# n31 ghost - Tonnage drops, charges and dumps on a circle that clears a group 

Lane `ghost`, branch `n31-ghost`, worktree `C:\Users\kazda\kiro\gtai-wt\n25-yard`, base `main` `ba8e470b0`.
Gate (final, ghost slot, started 05:15 on `da97ec3be`; later commits are JOURNAL/REPORT only): `node tools/gate/run.mjs --rev=HEAD` -> `gate: PASS` (lint 19 checks, unit 4478 passed 0 failed 2 skipped, scenarios 68 passed, parity bit-exact 1200 steps + planted mutation caught at 629, selftest, release-compile 1018 loaded 0 failed), `build/gate/da97ec3be096/gate.json` (git-ignored, in this worktree).
Films and stills for the owner: `C:\Users\kazda\kiro\gtai-masters\n31\ghost\frames.json` (15 best: the four gauntlet takes main | HEAD first, then half-speed clips and beat strips; older side clips and stills moved to `extra/`).

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

### 4. Ohm, Dent and Kerf
- Ohm before (main): lab 8-cop share 45 %; play (relaxed bot fit, 10 seeds x 3 waves) 42 deploys, mean 2.98 hits, 52 % of the foes within 9 m (`evidence/n31/ghost/measure-others-main.md`, `evidence/n31/ghost/measure-ohm-play.md`).
- Ohm after: one press, he stands on the aim point, 0.3 s charge, full circle r 5 m with the body radius (`48d6fbc37`, `649a17523`); lab 8-cop 83 % (`evidence/n31/ghost/measure-ohm-head.md`); play 41 deploys, mean 3.71 hits, 68 % of near, zero whiffs (`6dcc748ed`).
- Ohm drawn in beats (`8ab450ec9`): amber creep crawling to the rim during the charge, an arc ring at the rim on the discharge, a scorch ring + burn core for 2 s + 1 s; a lighter camera kick (`hit`); drawn radius 5.10 m vs 5 at 64 px/m. The `ohm_spec_hover` sheet warning is gone.
- Ohm play take (`evidence/n31/ghost/take-ohm.md`, seed 6): wave 1 main 4 of 8 near, HEAD 7 of 12; run 10 vs 17 kills. A player: "Ohm is now one tap: he appears in the crowd, the road crackles amber out to his circle for a beat, and the whole circle drops at once, leaving a burn ring."
- Dent (`87ac21445`, `8ce635db1`, `evidence/n31/ghost/measure-dent-head.md`): one press, lane from Rivet's side along the aim laid at the press, 0.25 s wind-up, body radius counted. Play mean 1.81 -> 1.79 at the same width; widths 1.3/1.6/1.8/2.0 m give 2.04/2.00/2.07/2.24 hits. View and beats (`5cef2a3d8`, `24b12bc99`, `cc2bf7da3`): Dent comes out of Rivet's side, cocks 15 ticks while a skid telegraph (tan/soot scrape lines 2 x `ram_half_m` apart) runs down the lane to a cap at the aim point, dives along it on the ram tick, and leaves a scuffed lane held 2 s + 1 s; `ram_half_m` 0.9 -> 1.3. Drawn lane width 2.44-2.69 m vs 2.6 (`evidence/n31/ghost/g18b-dent-lane-measure.txt`); strip `dent-beats-64ppm.png`. Scenarios 68/0 at `24b12bc99`.
- Dent play take (`evidence/n31/ghost/take-dent.md`, seed 6, shipped bot, wheel): wave 2 main 2 of 3 and 2 of 5 near, HEAD 3 of 3 and 3 of 4; run 8 vs 10 kills; over seeds 1-8 HEAD 1.76 hits per deploy vs main 1.84 (rams of 3+: 6 vs 4). A player: "Dent is now one tap: he pops out at your side, two scrape lines run down the road for a quarter second, then he rockets along them and drops the line, leaving a scuffed lane; he is no stronger than main's shove per deploy."
- Dent arrival (`1da987d15`, view only): the dive runs R-6..R so the body meets the ram tick. The HEAD side of the take was re-shot after it at `c2973118d` (`29805c54f`, same deploy ticks and frames): at the ram tick Dent is among the three cops with a hit star on each (`dent-arrive-take-64ppm-R.png`); in the first take the stars landed about 4 ticks before he got there. A player: "the cops drop the instant he slams into them, not a beat before he gets there."
- Kerf (`3211dfd49`, `3f0898052`, `0e8d1fb98`, `6f40d0007`): one press locks the target the deploy picker chooses (snap 2 m, cone 35, range 9, clear line); no marker. Kerf appears at Rivet's side with a thin teal sighting line and lock brackets on the target for 0.2 s (12 ticks), the lock follows the target, then he blinks behind it and cuts; a target that died or left range + 2 m = a whiff (cooldown spent); no target = refused, no cooldown. The cut leaves a 2.6 m char seam with an amber thread (measured 2.49 m, centre 0.02 m off) and a scorched star at the rear spot, held 2 s + 1 s. Strip `kerf-beats-64ppm.png`. Full unit 4453/0, scenarios 68/0, no digest moved.
- Kerf play (`evidence/n31/ghost/measure-kerf-head.md`, relaxed bot fit, 10 seeds x 3 waves; the shipped bot never fires Kerf): main 60 deploys, 1.00 hit, 0 whiffs, press -> damage 1 tick | drop 60 deploys, 0.85 hit, 9 whiffs, 12 ticks. Cause per whiff (`e485c7be1`): 6 targets killed by Rivet's own claw/katana/gloria during the wind-up, 3 behind a wall. Relock (`f86b03e38`, `4e80cd811`): a broken lock re-picks along the press's aim at the cut: whiffs 9 -> 8, mean 0.87; 6 of the 8 had no reachable foe in any direction at the cut.
- Kerf play take (`evidence/n31/ghost/take-kerf.md`, seed 10, relaxed fit, wheel): both sides 1/1 per deploy; HEAD's deploy 2 relocks (the locked cop dies to Rivet's claw, Kerf cuts the one behind); run 3 vs 6 kills. A player: "Kerf is now one tap: he stands at your side marking the cop for a fifth of a second, then blinks behind him and cuts; if Rivet kills that cop first he takes the one behind instead of wasting the press; still one kill per deploy."
- Kerf whiff refund (`0963ad16f`, `95bea4081`): a drop cut that finds nobody even after the relock leaves only `whiff_cooldown_ticks` 30 (0.5 s) instead of the 600-tick cooldown, and cues the chip. Mutate on the relock lines of `kerf_drop.gd`: 100 % (10 / 10).

### 5. A refused ghost press answers (raising the weakest point: one-press ghosts made a refused press silent)
- `8159b5fa0`, `1f52464e1`, `3aa0be020`: every refused press (cooldown, busy, locked, no target, a Kerf whiff) is counted once (`GhostDeploy.refusals`, view-only, not replayed) and the refused ghost's HUD chip jolts sideways 6 px with an amber rim for 18 frames (`GhostRefusalCue`); a cooldown refusal also flashes the cooling arc. Tests `test_ghost_refusal_cue.gd` (the shake size and decay, the 18-frame end, the arc flash only on a cooldown refusal pinned by `32944e65a`, `e2d1d3792`); mutate on `ghost_refusal_cue.gd` 91.7 % (11 / 12; was 37.5 % before those tests); scenarios 68/68, no digest moved. Strip: `refusal-cue-strip.png` (before: `refusal-cue-strip-before.png`): Kerf with no target shows an amber outline for +1..+8 frames; Tonnage on cooldown flashes its cooling arc white.
- A player: "A ghost key that cannot fire now answers: its chip jolts sideways with an amber rim for a third of a second, and a Kerf cut that finds nobody costs half a second instead of the full ten."

## What does not
- **Dent is no stronger than main per deploy**: 1.76 hits vs main's 1.84 over seeds 1-8 (rams of 3+: 6 vs 4). The one-press lane, the wind-up and the wider ram (`ram_half_m` 1.3) changed how he reads, not what he does: the bot fires him at 2 bodies, and no width under 2 m reaches a mean of 2.5. A balance call, not changed.
- **Kerf still whiffs 8 of 60 relaxed-bot drops**: 6 of the 8 had no reachable foe anywhere at the cut. They are now cheap (0.5 s) and cued, not prevented.
- **Kerf view**: the sight line is hidden by the body at 1 m range; a relock shows no sign that the lock moved; the seam and scorch lie mostly under the body at 64 px/m.
- **The probe cops are not drawn** in the Ohm, Dent and Kerf lab probes (the effects and ghost bodies are); the gauntlet takes show the real cops.
- **Signature kills in the gauntlet**: deploy kills draw the Tonnage crush only where a `BrutalityHook` is attached; the gauntlet street attaches none, and the Ohm/Kerf rows wait for melee to apply our patches (Merge notes).
- **The refusal cue** is shown on a HUD probe fed through `GhostRefusalCue.notice`, not through a real press in the gauntlet; no in-gauntlet take of a refused press.
- **Item 5 not started**: the effect card face is drawn by `project/dev/gauntlet/gauntlet_pick_card.gd` (shared read-only tonight); the heat parts to amber is colour polish with no play value tonight.

## What blocked or slowed you
- Session 1: a measure-on-main builder shared the tree with an edit builder (numbers had to be re-taken in a temp worktree), ~15 min.
- Session 1: our scenario run killed by another lane's builder (PID mix-up), one re-run.
- Session 2: the lane Godot lock held ~30 min by mutate runs, delaying the art builder's first still, ~30 min.
- Session 8: a builder's draw-order fix (rim over the chip face) looked right in code and wrong on screen (olive tint); caught on the strip, reverted, ~8 min.
- No `mem-budget: waiting` in any session; no BLOCKED images (21 of 60 used).

## Calls for the owner
- Where Tonnage drops: aim point (shipped) vs on Rivet: at 5.5 m in play the aim point hit 3.86 mean vs 1.17 on Rivet (25 of 54 Rivet drops hit nobody). One data value (`drop_at`). Clip `take-drop-aim-vs-rivet-32ppm.mp4` (27.70 s, seed 3, same recipe as the play take, `evidence/n31/ghost/take-drop-at.md`, `05feec382`): on the aim point he lands in the pack and 8 and 9 cops go down in waves 2 and 3 (24 kills in 4 drops); on Rivet he lands on Rivet and only the 2 or 3 cops pressed against him go down while the rest shoot from outside the ring (8 kills in 3 drops, the bot's first drop waits until tick 1262 instead of 238).
- Charge 0.45 s: costs about 16 points of share in the lab (cops walk out): it is the counterplay he asked for; one data value (`charge_s`). Play clip `take-charge-045-vs-0-32ppm.mp4` (35.73 s, seed 3, aligned on deploy 1's press, `evidence/n31/ghost/take-charge.md`, `4afd6aac3`) and strip `take-charge-045-vs-0-strip.png`: in this take the charge costs nothing (24 vs 23 kills over 4 deploys; on the 12-foe deploy nobody walked out, 9 down either way). With charge 0 the cops drop on the press frame before the robot is drawn (he appears ~9 frames later in a ring of bodies); with 0.45 s he hangs over the pack, the cracks crawl out, then the same 9 go down. One seed only: the lab's walk-out cost is neither reproduced nor ruled out in play.
- Radius 6.5 m, dump damage 3 (kills a patrol cop, a riot front takes x0.2): the 8-wave play median stays 3 (the bot drops at >= 3 bodies); 7 m is the screen limit.
- Ohm radius 3.5 -> 5 m at a 0.3 s charge (play 2.98 -> 3.71 hits per deploy).
- Bond and mastery with more kills per deploy (Tonnage, 8 waves, shipped bot): bond per deploy 9.3 -> 13.5 (+45 %), median mastery wave 4 -> 3; a bar of about 100 would restore wave 4. Not changed.
- Markers: dropped for all four ghosts (Tonnage, Ohm, Dent, Kerf); each keeps `press_mode` hold as one data value. Dent's lane direction comes from the mouse aim at the press; Kerf's target from the deploy picker at the press, and a press with no target is refused (`no_target` refuse|whiff).
- Kerf whiffs: 8 of 60 relaxed-bot drops still cut nobody (6 had no reachable foe at the cut: the target died to Rivet's own swing, or every foe was behind a wall). Shipped: the relock + a whiff costs 0.5 s (`whiff_cooldown_ticks` 30; 600 = before). Alternative: refuse a lock on a foe Rivet is already finishing.
- Dent width: `ram_half_m` 0.9 -> 1.3 halves the whiffs (11 % -> 6 %); no width under 2 m reaches a mean of 2.5 hits because the bot fires Dent at 2 bodies.

## Merge notes
- `NEED melee`: the gauntlet street attaches no `BrutalityHook`, so signature kills (incl. the Tonnage crush from the deploy) do not draw in gauntlet play; `NEED melee`: apply `evidence/n31/ghost/ohm_deploy_kills.patch` (`also_weapons: ["deploy_ohm"]` on the `ohm_shock` row) so Ohm deploy kills play the shock death; `NEED melee`: apply `evidence/n31/ghost/kerf_deploy_kills.patch` (`also_weapons: ["deploy_kerf"]` on `kerf_split`).
- Shared append-only files touched: `docs/decisions.md` (15 commits of one line each, all `[2026-11-2x] DECISION ghost n31 ...`), `tools/debt/baseline.json` (14 commits through the debt tool, new dev probes under `project/dev/ghost_n31/` accepted as regressions), `steam/ai-provenance/2026-11.jsonl` (21 lines: the generated ghost cells). No `KNOWN_FLAGS` change in `launch_args.gd` (the probes declare their own). On a conflict in the baseline: `node tools/debt/merge_baseline.mjs`, then `--update`.
- The diff from `ba8e470b0` is 247 files; the large line counts are measurement JSON under `evidence/n31/ghost/` and the cluster shapes `project/dev/ghost_n31/shapes.json`.
- Digests: scenarios 68/68 at 6.5 m, no digest moved (JOURNAL 23:04); again 68/0 after Ohm, Dent and Kerf (no digest moved).

## Next steps
- The owner plays Tonnage and Ohm in the gauntlet and picks the radius, charge and drop point (Calls); then the bond bar for the bigger circle.
- Dent: decide what Dent is for (a lane shove that opens a path, or a damage tool); if damage, ram damage or a 2-body min in the bot, measured with the same seed table.
- Kerf: a visible relock (brackets jump to the new target) and the sight line drawn over the body at short range.
- Apply melee's patches and attach `BrutalityHook` to the gauntlet street so ghost kills play their signature deaths in the owner's mode.
- An in-gauntlet take of a refused press (scripted presses in the take scene).
- Item 5: effect card icons (NEED for the pick card owner), heat parts amber.

## Builder ledger
All Claude sub-agents (sonnet or opus) from the director's session, one brief each under `evidence/briefs/n31-ghost-*.md`. 36 calls, 777 minutes, 35 accepted, 1 partly bounced (g27: its tests kept, its rim-over-face draw order reverted by g29 after the strip showed the avatar tinted olive), 0 abandoned. IMAGES 21/60.
- Tonnage: g01-measure 55, g02-drop 60, g03a-prep 6, g03-beats 64, g04-take 23, g05-keys-test 1, g06-verify 44, g07-kills 32, g08-measure 20, g09-kick 22.
- Ohm: g10-ohm 26, g11-ohm-prep 5, g12-ohm-beats 30, g13-ohm-play 28, g14-ohm-take 36.
- Dent: g15-dent 18, g16-dent-prep 4, g17-dent-view 27, g18a-pack 3, g18b-dent-marks 28, g19-dent-take 25, g25-dent-arrive 10.
- Kerf: g20-kerf-prep 4, g21-kerf-drop 28, g22-kerf-marks 16, g23-kerf-measure 5, g23-kerf-take 30, g24-kerf-relock 16 + 34.
- Refusal cue: g26-refusal-cue 24, g26b-refusal-strip 9, g27-cue-tests 14 (partly bounced), g29-rim-revert 3.
- Re-film: g28-dent-refilm 8, g30-ohm-halfspeed 4 (Ohm 64 px/m half-speed 10.65 -> 18.65 s at the same deploy ticks), g31-drop-at 15 (the drop_at rivet side of the owner's call, temp worktree, no product commit).
- What I would brief differently: the 60-minute first calls (g01, g02, g03) were the costly ones; 15-30 minute calls with one checklist point were the best value, as n29 said. A measuring builder needs its own temp worktree from the start when another builder edits the measured code (g01). Give mutate its own slot, never beside a stills builder (g06 held the lock 30 min). Check the allowlist covers every test that pins a changed default before launch (g26 shipped 600 instead of 30 for that reason and needed a message).
