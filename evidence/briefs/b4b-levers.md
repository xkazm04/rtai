# Brief b4b-levers (lane foes, run n31): enemies open fire (item 3, part B, first levers)

Worktree (your cwd): `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n31-foes`.
Read `evidence/briefs/b4-open-fire.md` (the whole item 3 brief: owner's words, measured BEFORE, bars, guard
rail, repo law, owned files) and `AGENTS.md` first. This brief narrows Part B for one call.

**Hard stop: 23:48, report and END** (the director's session, and with it yours, stops at 23:56).
First commit by **23:25**. Never end with uncommitted work or a commit stuck in the pre-commit hook (the hook
can take ~12 minutes here: start your last commit by 23:33).

## State when you start
- Item 2 (FoeGait, FIGHT 0.45x may fire, TRAVEL full speed no fire) is on HEAD; b2b re-pinned its tests.
- b4a (Part A) may still be running until 23:30: it owns `tools/gauntlet/waiting*` and
  `project/dev/foes_n31/waiting_*` and holds the lane Godot lock `build/n31/godot.lock` while it measures.
  Do not edit its files. Use `tools/gauntlet/waiting.mjs` as it is at HEAD (check `git log` for b4a's commits;
  if its new idle definition / pressing share has landed, report those columns too).
- The gait measurement (HEAD before levers) is b4a's `evidence/n31/foes/waiting-gait/` if it exists by then;
  otherwise lever 1's run file set is compared to `evidence/n31/foes/waiting-main/`.

## Do (in order; one lever = one commit)
1. **Lever 1, code first (no Godot needed):** `squad.max_shooters_share` 0.35 and `squad.max_shooters_min` 3
   in `enemies.json` (+ schema), read in `project/features/combat/ai/enemy_roster.gd`, used where the ranged
   cap is read (`project/features/combat/ai/enemy_squad.gd` L41/L55):
   `slots = max(min, ceil(share * ranged_alive))` with `ranged_alive` = non-melee wave members alive; when the
   share key is absent use `max_shooters` (legacy). **`foe_rocket.gd` L52/L91 also reads `max_shooters` for the
   rocket count: leave the rockets on the fixed `max_shooters`** (rocket troopers keep their own mind).
   A unit test on the slot rule (13 ranged alive -> 5, 4 -> 3, 2 -> 3 i.e. all, absent share -> 2).
   Run `node tools/tests/run_unit.mjs --changed`, lint, commit.
2. **Measure lever 1:** average bot, seeds 1-10, `--waves=7` (same command b1 used for the BEFORE; see
   `evidence/n31/foes/waiting-main/waiting.md` header and `tools/gauntlet/waiting.mjs --help`) into
   `evidence/n31/foes/waiting-l1-shooters/`. Novice only if time remains. Put lever 1 in
   `evidence/n31/foes/item3-compare.md` (append a column / section; if b4a is still writing that file, write
   `evidence/n31/foes/item3-levers.md` instead). Then run the full unit suite and scenarios; re-pin what the lever
   moves with a comment `n31 foes lever 1`; ONE `docs/decisions.md` line
   (`- [2026-11-25] DECISION foes n31 max_shooters share: fixed 2 -> max(3, ceil(0.35 x ranged alive)), measured <idle, react p50/p90, firing/s, damage w1-4 sum vs 62.9>, rejected <...>`). Commit.
3. **Lever 2 (only if lever 1 committed by 23:25):** `attack_m` patrol 14 -> 20, SWAT 20 -> 26, contractor
   15 -> 20 (`preferred_m` unchanged), measured the same way into `waiting-l2-reach/`, decisions line, commit.
   If damage w1-4 (average) leaves 53.5..72.3, keep the commit but say so in bold in your report.

## Bars (for the report, not to chase in this call)
React in range median <= 1.0 s, p90 <= 2.5 s; idle share < 35 % (new definition if b4a landed it);
pressing share >= 0.6; guard rail: average bot damage w1-4 sum within 53.5..72.3 (BEFORE 62.9).

## Godot
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/foes` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
Lane lock `build/n31/godot.lock` (exclusive create, content `b4b <pid>`; wait while another tag holds it,
re-check every 30 s; delete only yours). Godot only through repo tools (runGodot), never raw.
`mem-budget: waiting` = machine full, not a hang. Mutate (if time remains after lever 1's commit):
`node tools/mutate/mutate.mjs --file=project/features/combat/ai/enemy_squad.gd --max=20 --lines=<changed> --tests=<covering tests>`.

## Owned files (allowlist; anything else: stop and write a NEED)
`project/features/combat/ai/**`, `project/features/combat/squad/**` except `*_card_view.gd`,
`project/data/tables/enemies.json` (AI fields of existing rows, `squad`) + `project/data/schemas/enemies.schema.json`,
tests and pins the lever moves (`project/tests/**`), one appended `docs/decisions.md` line per lever,
`evidence/n31/foes/**`. Forbidden: `tools/gauntlet/waiting*`, `project/dev/foes_n31/**`, `combat.json`,
`weapons.json`, hit/hurt radii, melee reach, wave composition, the wave 5 stomp, prologue, player, souls, kills.

## Repo law
Typed GDScript, warnings are errors, ~200 lines per file (hard 300), functions <= 40 lines, <= 5 params,
`Log` not `print`, no global RNG. Stage per path, `git commit -- <paths>`; banned: `git stash`,
`git add -A/./-u`, `git commit -a`, `reset --hard`, amend, rebase, push, `--no-verify`. Message ends with
`Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Fix lint and format findings in your own edit and go
on. Hook fails on `kill_reel_*.break.test.mjs` = stale class cache: Godot `--import`, commit again.

## Report (final message)
Commits, commands with result lines, the table main | gait | lever 1 (| lever 2) with bars and guard rail,
digests re-pinned, mutate score if run, what you could not do.
