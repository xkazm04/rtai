# Brief b4-open-fire (lane foes, run n31): enemies open fire (item 3, part 1)

Worktree (your cwd): `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n31-foes`.
Hard stop: **60 minutes after launch, report and END**. First commit within **25 minutes**; commit each
finished lever as soon as its checks pass. Never end with uncommitted work or a commit stuck in the hook.

## The owner's words
"AI is waiting to shoot too much, cops are just waiting until I can closer to start shooting".

## What we know (measured, `evidence/n31/foes/waiting-main/waiting.md`, main ba8e470b0, 10 seeds)
- Average bot, waves 1-4 + 6-7, ranged: idle share 89 %, react-in-range p50 1.05 s / p90 6.15 s, react at
  any distance p50 3.37 / p90 8.72 s, never fired 173 of 569, enemies firing per second 1.02 with 6.4 ranged
  alive, token share 25 %. Damage taken per wave (average bot) w1-4: 12.5 / 10.6 / 22.6 / 17.2 (sum 62.9);
  novice 17.5 / 16.1 / 33.6 / 26.5 (sum 93.7).
- Cause (code): `enemies.json` `squad.max_shooters` 2 (`project/features/combat/ai/enemy_squad.gd` hands
  out the ranged tokens), patrol `attack_m` 14 with sight 24, patrol/contractor `cover_bias` 1 (every token-less
  one hides when a box is within 8 m), the rest orbit (`SquadMind._plan`, ring `lerp(attack_m, preferred_m,
  aggression)`).
- HEAD now has item 2 (FoeGait: FIGHT walk 0.45x may fire, TRAVEL run may not; `--foe-moves=legacy|split`).

## Part A: fix the idle definition first (tools/gauntlet + project/dev/foes_n31, b1's probe)
The probe counts the cooldown between two bursts as idle, so a cop firing non-stop scores ~65-70 % idle.
Change it (keep the old column, rename it `idle_strict`): an enemy-tick is **engaged** when it fired a round
within the last `burst duration + cooldown + 0.1 s` of the weapon it actually fires (read from the tuning /
enemies.json weapon it uses), or is in WINDUP/FIRE, or is in the FoeGait settle window. `idle share` =
clear-line-in-range ticks not engaged / clear-line-in-range ticks. Add **pressing share**: share of wave
ticks with >= 3 ranged alive where (engaged + advancing) >= max(3, ceil(ranged_alive / 3)); advancing = in
TRAVEL (or legacy) with a velocity component toward Rivet > 0.5 m/s, or moving to a firing spot. Add
`--rev` A/B in one table: `waiting.mjs --compare=<dirA>,<dirB>` prints main | HEAD columns of the headline.
Re-aggregate the BEFORE with `--from` (no new runs needed if the run files carry per-tick data; if they do
not, re-run main with `--rev=ba8e470b0`) and commit `evidence/n31/foes/waiting-main/` updated. Unit-test the
engaged rule on a fixture.

## Part B: levers, one at a time, each measured (average + novice, seeds 1-10, `--waves=7`), each a commit
Bars (ranged kinds, average bot, waves 1-4 + 6-7): react in range median <= 1.0 s and p90 <= 2.5 s;
idle share (new definition) < 35 %; pressing share >= 0.6. **Guard rail**: average bot damage taken,
sum of waves 1-4 means, within +-15 % of 62.9 (53.5..72.3); report each wave and novice too.
Measure HEAD (item 2 alone) first: `evidence/n31/foes/waiting-gait/`. Then, in this order, stop when bars hold:
1. `max_shooters` as a share: new `squad` values `max_shooters_share` 0.35 and `max_shooters_min` 3:
   slots = `max(min, ceil(share * ranged_alive))` (keep `max_shooters` as the legacy fallback when share is
   absent). Code in `enemy_squad.gd` / `arena_squad.gd` (find where the cap is read).
2. `attack_m`: patrol 14 -> 20 (its pistol reach), SWAT 20 -> 26, contractor 15 -> 20; keep `preferred_m`.
3. `cover_bias`: patrol and contractor 1 -> 0.5.
4. (if still short) a token-less ranged enemy advances to a firing spot (inside `attack_m`, clear line) in
   TRAVEL instead of orbiting: in `SquadMind._plan`, the strafe ring for token-less = `attack_m - 1`.
After each lever: the table into `evidence/n31/foes/waiting-<lever>/`, one line in `docs/decisions.md`
(`- [2026-11-25] DECISION foes n31 <lever>: <before> -> <after>, measured <headline + damage>, rejected ...`),
digests the lever moves re-pinned in the same commit (run the unit suite + scenarios), one commit.
If a lever breaks the guard rail, keep it only if the next lever is the per-kind weapon (part 2, a later
brief) and say so; otherwise revert that lever's data (a new commit) and report.

## Acceptance
- `node --test "tools/gauntlet/waiting*.test.mjs"` green, lint green, `node tools/tests/run_unit.mjs` green,
  scenarios green after each commit that touches project/.
- `evidence/n31/foes/waiting-*/waiting.md` for every measured setting, and one compare table
  `evidence/n31/foes/item3-compare.md` (main | gait | each lever).
- After the code commit: `node tools/mutate/mutate.mjs --file=project/features/combat/ai/enemy_squad.gd
  --max=20 --lines=<your changed lines> --tests=<the tests covering it>`; quote killed/(killed+survived).

## Repo law (read AGENTS.md first)
- Typed GDScript, warnings are errors, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log`
  not `print`, no global RNG. New `.gd` -> commit its `.uid` (Godot `--import` before the commit).
- Stage per path, `git commit -- <paths>`. Banned: `git stash`, `git add -A/./-u`, `git commit -a`,
  `reset --hard`, amend, rebase, push, `--no-verify`. Message ends with
  `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Fix lint and format findings in your own edit and go on. If the hook fails on a
  `kill_reel_*.break.test.mjs`, the class cache is stale: run a Godot `--import`, commit again.
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/foes` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
  **One Godot at a time for the whole lane**: hold `build/n31/godot.lock` (exclusive create, content
  `b4 <pid>`; wait while another tag holds it, re-check every 30 s; delete it when your Godot exits; never
  delete a lock that is not yours). Another builder (b3, films) shares it.
- Never touch `main`, other worktrees, `C:\Users\kazda\kiro\pof`. No Codex, no API keys.

## Owned files (allowlist; any other path: stop and write a NEED in your report)
- `project/features/combat/ai/**`, `project/features/combat/squad/**` except `*_card_view.gd`,
  `project/data/tables/enemies.json` (AI fields of existing rows, `squad`) + its schema,
  `project/dev/foes_n31/waiting_*`, `tools/gauntlet/waiting*`, `tools/gauntlet/fixtures/waiting/**`,
  tests and pins your change moves, appended lines in `docs/decisions.md`, `evidence/n31/foes/**`.
- Forbidden: `project/dev/foes_n31/play_take.*` and `tools/gauntlet/play_takes*` (b3), `combat.json`,
  `weapons.json`, hurt/hit radii and melee reach, wave composition (`enemy_waves`, gauntlet wave tables),
  the wave 5 stomp, prologue, player, souls, kills, `*_card_view.gd`.

## Report (your final message)
Files, commits, commands with result lines, the compare table (main | gait | levers) with the bars and the
guard rail, which bars hold and which do not, mutate score, digests re-pinned, what you could not do.
