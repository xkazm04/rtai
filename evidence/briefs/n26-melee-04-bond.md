# Brief n26-melee-04-bond: earn each ghost's transformation through a bond

Lane `melee`, branch `n26-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`.
**Hard stop HARDSTOP wall clock. Last commit by COMMITBY.** Commit what is green; revert your own unfinished edits
with `git checkout -- <path>`; list the rest in your report. Never stop to ask: at a fork, pick what best serves
the owner's words, record a DECISION line, go on.

## The owner's pick: "Earning the transformation: build it as proposed"
The proposal (`docs/day/2026-11-23/n24-ghost/REPORT.md`, "How the player could earn the full transformation"):
1. Each ghost has its own **bond**, filled by that ghost's deploys that do their job: `per_kill` per kill and
   `per_stun` per stun by `deploy_<form>`. Empty releases earn nothing.
2. At `master_at` (about 25) the next checkpoint offers "Master <ghost>" (a card in the gauntlet's rest draw; a
   quest checkpoint in the story). Taking it unlocks THAT form's full transformation for the rest of the run.
3. Ghosts now deploy on their own number keys 1 to 4 (keys lane: 1 Dent, 2 Kerf, 3 Ohm, 4 Tonnage, the
   `ghost_forms.json` order). **T transforms into the mastered ghost deployed last** (with one mastered ghost, that
   one); T does nothing with none mastered. The transformation keeps its Madness cost and cooldown; the deploy
   keeps its own.
4. The bond shows on the ghost's HUD chip so the player sees it fill (a thin teal arc/ring that fills to master_at,
   and a distinct "ready to master" look at full; mastered = a closed ring). Teal is the soul colour: correct here.

Contract (wire names, use exactly): new block `bond` in `project/data/tables/ghost_forms.json`:
`{ "per_kill", "per_stun", "master_at", "enabled" }` (+ schema + doc). Mastering sets that form's transformation
unlocked for the run; `transform_unlocked` stays the global dev override (true = every form, as today).
Gauntlet result file: each wave row may carry `bond{<form id>: value}` (add to
`project/data/schemas/gauntlet_run.schema.json`, optional, sorted keys). Values that stay off the tape: do not
change any shipped tape's digest (the bond is derived from kills/stuns already in the sim; if you put it in hashed
state, every shipped tape must still replay identical: check).

## What exists
- Per-wave deploy tallies: `project/features/souls/ghost_deploy_tally.gd` (`_casts`, `_kills`, stun ticks: the stun
  count is not per form today; make it per form). `GhostDeployStrike.release_form/release_kills/stunned_count`.
- `GhostFormTable.transform_unlocked` (`project/features/souls/ghost_form_table.gd:19`), read by
  `ghost_deploy_bot.gd:58` and `ghost_form_hud.gd:70`; dev entries set it in `project/dev/ghost-forms/**` and
  `project/dev/ghost-powers/**`. Mastery story check: the n24-ghost REPORT "What does not" (`GhostPilot.shipped()`).
- Gauntlet rest draw: `project/data/tables/gauntlet_bonuses.json` (rows id/kind/min_wave/ref/weight),
  `project/features/gauntlet/gauntlet_draw.gd`, `gauntlet_bonus_apply.gd`; the test player picks in
  `project/features/gauntlet/bot/bot_pick.gd` (`pick(offered, wave, carry_ref)`); the deploy rule of the test
  player: `project/features/souls/ghost_deploy_bot.gd` (deploys the loaded ghost only: with number keys it must
  deploy any owned ghost that is off cooldown and has a target; prefer the one with the best target).
- Quest 1: script, rules, tapes and checkpoints do not change. The story offer is built behind `bond.enabled` and
  only ever appears after master_at effective deploys, which quest 1's tapes never reach: prove that (bond values
  at the end of each quest 1 tape) rather than assume it. If a story checkpoint offer cannot be built without
  touching quest files, build the gauntlet offer only and report a NEED for the story one.

## Build, in order (commit each when green)
1. `GhostBond` (new RefCounted in `project/features/souls/`): fill per form from deploy kills/stuns, `ready(form)`,
   `master(form)`, `mastered(form)`, `last_deployed_mastered()`; the per-form unlock in the form table; T picks
   the mastered ghost deployed last. Unit tests: fill, threshold, no fill on an empty release, the offer appears
   at the next checkpoint only after master_at, taking it unlocks only that form, T with 0 / 1 / 2 mastered,
   `transform_unlocked` true still unlocks all.
2. The gauntlet offer: at the first rest after a form reaches master_at, a "Master <ghost>" card is offered (always,
   in addition to or in place of one drawn card: decide and say why), Loc keys for its text (no hardcoded UI text).
   The test player takes it when offered (`bot_pick.gd`, a few lines). Result rows carry `bond{}`.
3. The HUD bond on the chip: if the chip drawing files are the keys lane's (`ghost_form_hud.gd`,
   `ghost_hud_hints.gd`, `ghost_chip_glyph.gd`, `ghost_card.gd`), draw the bond in a NEW node of your own placed
   over each chip from the chip layout (`ghost_form_layout.gd` or whatever exposes the chip rects), mounted by the
   code that builds the HUD; if mounting it needs a line inside a keys file, add nothing there and report a
   `NEED keys: <file>:<line> <the one line>`; meanwhile mount it from a file you own if one exists.
4. Measure: the gauntlet test player on seeds 1..10 (profile average; expert too if time), long enough to see a
   mastery (to wave 15 or death): per seed the wave each ghost is mastered, bond per wave, transformations used.
   Target: the first mastery between wave 8 and 15. Tune `per_kill`, `per_stun`, `master_at` (start 1 / 0.5 / 25)
   until the median first mastery lands inside; say what you tried. `evidence/n26/bond/mastery.json` + `.md`.
5. Review stills: the chip filling (3 steps), the offer card at the rest, the card taken, then T and the
   transformation in use; 32 px/m tilt 70 and 64 px/m, `evidence/n26/bond/frames/`.
6. Tape identity: no BEFORE suite (main is gate-green); scenarios (`--only=<touched>` first, then all) + shipped tapes AFTER, 60 s replay `cbeb734ff9b97c41` and parity identical; any
   moved digest: old -> new + reason + `docs/decisions.md` line.
7. `node tools/mutate/mutate.mjs --file=project/features/souls/ghost_bond.gd --max=20`.

## Files you may edit (allowlist). Any other path: stop that part and report a NEED.
`project/features/souls/**` except the keys lane's deploy-input and chip-drawing files named above;
`project/data/tables/ghost_forms.json`, `ghost_attacks.json`, `gauntlet_bonuses.json` (append the mastery row(s)
only) and their schemas, `project/data/schemas/gauntlet_run.schema.json` (the optional `bond` field),
`project/features/gauntlet/gauntlet_draw.gd`, `gauntlet_bonus_apply.gd`, `gauntlet_wave_stats.gd` (bond in the wave
row), `project/features/gauntlet/bot/bot_pick.gd` (take the offer: a few lines), Loc string tables for the card
text, `project/dev/ghost-forms/**`, new tests under `project/tests/unit/` / `integration/`, `docs/decisions.md`
(append one line at a time), `evidence/n26/**`, `tools/debt/baseline.json` via the debt tool,
`project/boot/launch_args.gd` `KNOWN_FLAGS` append only.
Forbidden: `input_actions.json`, `rivet_motion.json`, player movement/input files, `combat.json`, existing rows of
`enemies.json` / `weapons.json`, other gauntlet files, `project/boot/prologue/**`, quest 1 files and tapes, cast art,
root `JOURNAL.md`/`REPORT.md`.

## Repo law (binding)
- AGENTS.md and STANDARDS.md: typed GDScript, ~200 lines per file (hard 300), functions <= 40 lines, <= 5 params,
  `Log` not print, no global RNG, no hardcoded UI text (`Loc.t()`/`tr()`), JSON data with a schema, `.uid` with
  every new `.gd`, Godot `--import` after new scripts before commit.
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/melee` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`;
  `--rendering-driver d3d12` for renders; windowed `--position 0,1440`. One Godot process at a time; kill only
  your own PIDs.
- `node tools/gate/quick.mjs` before each commit; fix lint and format findings in your own edit and go on. Stage per
  path; no amend, rebase, stash, `add -A/./-u`, `reset --hard`; never push.

## Report at the end
Commits, the bond numbers chosen and why, the mastery table (wave per ghost per seed), the HUD mount (and any NEED
keys line), the tape list, mutate score, still paths, not done.
