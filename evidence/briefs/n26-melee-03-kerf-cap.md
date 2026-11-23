# Brief n26-melee-03-kerf-cap: cap Kerf's deployed cut on bosses

Lane `melee`, branch `n26-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`.
**Hard stop HARDSTOP wall clock. Last commit by COMMITBY.** Commit what is green; revert your own unfinished edits
with `git checkout -- <path>`; list the rest in your report. Never stop to ask: at a fork, pick what best serves
the owner's words, record a DECISION line, go on.

## The owner's pick
"Cap Kerf's deployed cut on bosses." Today Kerf's deploy one-shots everything, the war machine included
(`docs/day/2026-11-23/n24-ghost/REPORT.md`, Call 5). Contract (wire names, use exactly):
`project/data/tables/ghost_attacks.json` `deploy.kerf.boss_damage_cap` = the share of a boss's max health one
deployed cut may take. Pick it so a gauntlet boss wave still lasts **25 to 30 s with Kerf**.

## What exists
- The deploy strike: `project/features/souls/ghost_deploy_strike.gd` `_kerf` (`robot_damage` / `human_damage`
  from `attacks`, `_hit(..., &"deploy_kerf")`); the table class reading `ghost_attacks.json` (find it from the
  strike); schema `project/data/schemas/ghost_attacks.schema.json` (or the matching name).
- "Boss": the gauntlet's boss wave is every `boss_every` (5) waves with `war_machine` as the boss
  (`project/features/gauntlet/gauntlet_composer.gd` `BOSS`); arena bosses are `arena.boss`. Decide what counts as
  a boss for the cap: `arena.boss`, plus the composer's boss slot in a boss wave (and the archetype rows flagged
  boss if any). Write the rule in a DECISION. If the war machine in a NON-boss wave is not a boss, say so.
- Measuring tools: `project/dev/ghost-forms/deploy_worth*.gd` (the worth probe: off/on pairs, seeds 1..10),
  `project/features/souls/ghost_deploy_bot.gd` (the test player's deploy rule), the gauntlet test player
  (`project/features/gauntlet/bot/`, `node tools/dev/run.mjs gauntlet --bot ...`; read its flags).

## Build
1. `boss_damage_cap` in the table + schema (+ the table doc string), read by the Kerf strike: damage on a boss =
   `min(damage, cap * boss.max_hp)`. Every other target unchanged.
2. Measure the boss wave (wave 5, and wave 10 if it is reachable cheaply) on seeds 1..10, three arms:
   `no_kerf` (Kerf never deployed), `kerf_uncapped` (today, Kerf deployed at the boss whenever off cooldown),
   `kerf_capped` (the shipped cap). Per seed: boss wave duration (s), boss time-to-kill, Rivet health lost,
   Kerf deploys and the damage each did. A probe that starts directly at the boss wave with a fixed loadout is
   fine (a dev entry under `project/dev/ghost-forms/`, declared `const KNOWN_FLAGS`), as long as you say how it
   differs from a real run. Pick the cap so `kerf_capped` has its mean (and most seeds) inside 25 to 30 s; if
   `no_kerf` is itself outside 25 to 30 s, report that as it is and pick the cap so that Kerf shortens the wave by
   at most what one deploy should (decide and say why). Results: `evidence/n26/kerf-cap/boss-wave.json` + `.md`
   (table per arm: mean, min, max, CI95).
3. Unit tests: the cap applies to a boss and to nothing else; cap 1.0 equals today; the boss still dies to
   Kerf + other damage.
4. Tape identity: main is gate-green, so no BEFORE suite: run the scenarios (`--only=<touched>` first, then all) and shipped tapes AFTER; 60 s replay `cbeb734ff9b97c41` and native parity
   identical. A moved digest: old -> new + reason; re-pin only when caused by this cap, with a
   `docs/decisions.md` line (`- [2026-11-23] DECISION n26 melee: ...`).
5. Review stills: Kerf's cut on the war machine before (it dies) and after (it lives, the cap's damage shown), 32
   and 64 px/m, to `evidence/n26/kerf-cap/frames/`.
6. `node tools/mutate/mutate.mjs --file=project/features/souls/ghost_deploy_strike.gd --max=20 --lines=<changed>`.

## Files you may edit (allowlist). Any other path: stop that part and report a NEED.
`project/features/souls/**` EXCEPT the files that read the deploy keys or draw the deploy HUD chips (the keys
lane is editing those right now: `ghost_deploy.gd` input reading, `ghost_form_hud.gd`, `ghost_hud_hints.gd`,
`ghost_chip_glyph.gd`, `ghost_card.gd`; if you must touch one, stop and report a NEED),
`project/data/tables/ghost_attacks.json`, `ghost_forms.json` and their schemas, `project/dev/ghost-forms/**`,
new tests under `project/tests/unit/` / `project/tests/integration/`, existing tests only where they assert
Kerf's uncapped boss kill (list each), `docs/decisions.md` (append one line at a time), `evidence/n26/**`,
`tools/debt/baseline.json` via `node tools/debt/debt.mjs --update` (`--accept-regression="<reason> for n26 melee"`),
`project/boot/launch_args.gd` `KNOWN_FLAGS` append only.
Forbidden: `input_actions.json`, `rivet_motion.json`, player movement/input files, `combat.json`, existing rows of
`enemies.json` / `weapons.json`, `project/features/gauntlet/**` (read only; a bot change there is a NEED),
`project/boot/prologue/**`, `prologue_stage.json`, cast art, `cast_cards.json`, root `JOURNAL.md`/`REPORT.md`.

## Repo law (binding)
- AGENTS.md and STANDARDS.md: typed GDScript, ~200 lines per file (hard 300), functions <= 40 lines, <= 5 params,
  `Log` not print, no global RNG, JSON data with a schema, `.uid` committed with every new `.gd`, Godot `--import`
  after new scripts before commit.
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/melee` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`;
  `--rendering-driver d3d12` for renders; windowed `--position 0,1440`. One Godot process at a time; kill only
  your own PIDs.
- `node tools/gate/quick.mjs` before each commit; fix lint and format findings in your own edit and go on. Stage per
  path; no amend, rebase, stash, `add -A/./-u`, `reset --hard`; never push.

## Report at the end
Commits, the cap value and why, the three-arm table, the boss rule, tape list, mutate score, still paths, not done.

## Addendum (director)
- The branch carries the keys lane's milestone `8d8bb3787` (merged before this brief): ghosts deploy on number
  keys, and the test player deploys any owned ghost that is off cooldown (`ghost_deploy_bot.gd`,
  `project/features/gauntlet/bot/bot_forms.gd`). Use that for the `kerf_*` arms; the `no_kerf` arm removes Kerf from
  the owned set (dev-only, in your probe), not by editing the bot.
- Brief 02 (electric finishers) is on the branch: the electro gun / claw discharge now finish robots. If the boss
  wave's robots die faster because of it, say so in the table (it is the shipped game now).
- Keep the probe cheap: one Godot at a time, headless, `--fixed-fps 60`; if 3 arms x 10 seeds of the real
  gauntlet to wave 5 do not fit in 25 min, start at the boss wave with a fixed loadout and say so.

## Also in this call (do first, 15 min max, then the cap)
- 0a. The appliance warden loses the claw exemption (brief 02 proved the five prologue pilot timelines identical
  without it, `evidence/n26/hands/prologue-after.*`; decision line of 2c3343098): remove `appliance_warden` from
  `rivet_melee.json` `claw.never_finish`, update the three unit-test fixtures listed in
  `evidence/n26/hands/prologue-after.md` (these test edits are in scope now), append a decision line saying the
  exemption is gone, commit.
- 0b. Owed mutate (cap each at `--max=10` on changed lines, run in the background of your other work is NOT allowed:
  one Godot at a time; run them last, after your cap commit, only if 15 min remain): `project/features/player/robot_finish.gd`
  (from 2c3343098) and `project/features/player/melee_lethal.gd` (from 21f4fd10c). Scores to
  `evidence/n26/electric/mutate.md` / `evidence/n26/hands/mutate.md`, committed.
