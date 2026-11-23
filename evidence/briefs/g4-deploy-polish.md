# Brief g4-deploy-polish (lane `ghost`, n24): what the Director's review of g2/g3 found

Hard stop: 22:25 wall clock (check `date`; killed at 75 minutes). Last commit by 22:20. Commit each part as it goes green; fix lint and format findings in your own edit and go on.

## Context
Your calls g1-g3 built and measured the ghost deploy (`git log --oneline -20`). The Director looked at every still in `C:/Users/kazda/kiro/gtai-masters/n24/ghost/` and a frame grid of `deploy_all.mp4`. Ring, Kerf, Tonnage and Dent read. These are the faults, in priority order.
Director's notes after g3 (read first):
- Your f04829845 already lifts Ohm's body to the FX band. Re-shoot the Ohm still and close-up FIRST; do part 1's fallback only if his silhouette is still hidden.
- Masters are still heavy after crf 18 (deploy_all.mp4 428 MB for 24 s; 64 px close-ups 75-125 MB for 7 s). For the owner's copies use `-crf 23 -preset slow -pix_fmt yuv420p -an`, aim <= 60 MB for a 24 s clip; ffprobe 1920x1080, 60 fps, same frame count; replace in place.
- HUD (`project/features/souls/ghost_form_hud.gd`, ghost-owned): in `deploy_ohm-64-f0121.png` the chip row sits straight on a street bench and the chips mix with its slats. Give the row a backing plate (ink at about 55% alpha, rounded, 6 px padding) so the chips read on any ground. Its own commit, a before/after crop of the HUD at the same tick.
- deploy-worth: the seed reaches only the RNG context; every seed starts from the same formation, so the ten pairs are near copies (Kerf and Dent CIs collapse to one value). Part 6 below.
- Dent's encounter is trivial (the off arm clears five cops in 1.17 s; the ram kills all five on the release tick). Part 6 below.

## What to build
0. **First, 5 minutes**: g3 left the probe staged: `project/dev/ghost-forms/deploy_worth*.gd` (+ `.uid`) and `tools/debt/baseline.json`. Run `node tools/gate/quick.mjs` and commit them as one commit ("Add the paired deploy worth probe"). Do not re-run the probe for this.
1. **Ohm must read.** In `deploy_ohm-64-f0121.png` Ohm's apparition is mostly hidden under the sentry turret and the shield robot he shorts: only the bolts read. Fix it in the deploy view, not the sim: draw the deployed ghost body above the machine rigs it strikes (z over the actors it targets) with the apparition wash keeping it translucent, OR (if z cannot go above without breaking the print layers) place Ohm's drawn body at the near edge of his short-circuit ring toward Rivet, with the bolts leading from him to each machine. Re-shoot the Ohm still and close-up; the Director must see Ohm's whole silhouette.
2. **A decision line**: append to `docs/decisions.md` (one line, append only): `- [2026-11-22] DECISION n24 ghost deploy cost: a deploy costs only its per-ghost cooldown (deploy.<form>.cooldown_ticks), no Madness charge, one ghost out at a time; the owner named range only. Rejected: a soul charge per deploy (one value to add later as deploy.<form>.madness_cost). Mastery (transform_unlocked) stays false in the gauntlet and the live game; story mode keeps the transformation for quest 1's beats.`
3. **frames for the owner**: a 32 px/m clip of 15 to 25 s where Rivet keeps strafing and firing while EACH ghost is held (the ring visible for at least 1 s) and released, real speed, plus a still of each form's ring with its target mark (Kerf chevron behind a snapped target, Ohm radius, Tonnage stomp area, Dent ram lane) at 64 px/m. Names: `deploy_hold_<form>-64-fNNNN.png`. ffprobe each clip.
4. Skipped tonight (the story accessor sits outside the allowlist); the Director carries it to REPORT.
5. `node tools/mutate/mutate.mjs --file=project/features/souls/ghost_deploy_strike.gd --max=20` and the same for `ghost_deploy_spot.gd`; quote both scores; add a test for any surviving mutant that marks a real gap.

6. (Last, if parts 1-5 are committed with 20 minutes left.) Seeded formation jitter in the deploy_worth probe: each hostile's start moves by up to 1.5 m in x and y from a registry stream (`ctx.rng.stream(&"deploy_worth")`, same in both arms of a pair), and Dent's encounter spreads the five cops over 3-6 m gaps and lets them advance before the first release is possible (no deploy before tick 120). Re-run all four forms over seeds 1..10, rewrite `evidence/ghost/deploy-worth.md/.json` (keep the old file's numbers as a "fixed formation" section), commit.

## Checks
`export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/ghost` and `GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe` before every Godot run; `--rendering-driver d3d12` for renders; windowed runs only with `--position 0,1440` (second monitor); one Godot at a time; free your processes by PID. `--import` after new files, commit `.uid`. Lint green; `node tools/tests/run_unit.mjs --changed` green; the full scenario suite green with `replay_60s` final `cbeb734ff9b97c41`; `node tools/gate/quick.mjs` before each commit.

## Files you may edit
`project/features/souls/**`, `project/dev/ghost-forms/**`, `project/dev/ghost-powers/**`, `project/dev/moves/**`, `project/tests/unit/test_ghost*`, `project/data/tables/ghost_attacks.json` (deploy block), `ghost_forms.json`, `docs/decisions.md` (append the one line), `tools/debt/baseline.json` through the debt tool, `evidence/ghost/**` (part 6), `C:/Users/kazda/kiro/gtai-masters/n24/ghost/**`, a one-line call site in `project/boot/collect_call/stage_pilot.gd` (part 4 only; name it). Any other path: stop that part and report a NEED. Forbidden: `enemies.json`, `weapons.json`, `input_actions.json`, `project/features/player/**`, `project/features/gauntlet/**`, `project/features/hud/**`, `project/features/characters/**`, `project/features/combat/squad/**`, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/`.

## Repo law
Typed GDScript, warnings are errors; ~200 lines per file (hard 300), functions <= 40 lines, <= 5 parameters; `Log` not print; render reads sim state, never writes it; RNG only through the registry. Stage per path, one commit per change, no `git add -A/./-u`, no stash, no `reset --hard`, no amend, no rebase, never push.

## Report
Commits (sha + subject), check lines (lint, unit, scenarios with the replay_60s digest, mutate scores), film and still paths with ffprobe duration and size, what you saw in each still.
