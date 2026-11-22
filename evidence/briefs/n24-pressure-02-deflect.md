# Brief n24-pressure-02: a deflect that costs (pass ratio + spread)

You build for lane `pressure` of RTAI (Godot 4, internal id `gtai`) in this worktree, branch `n24-pressure`.
Read `AGENTS.md` (commands, top rules) before you start. STANDARDS.md binds.

**Wall clock: hard stop HARDSTOP. Last commit by COMMITBY.** Commit each task as it lands; an unfinished task is left
uncommitted and described in your final report.

## Machine rules (every command)

- `export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/pressure` and
  `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'` before any Godot,
  test, gate or tool run. Anything that renders: `--rendering-driver d3d12`; windowed runs `--position 0,1440` (never
  the main display).
- One Godot process at a time for this lane (you are the only one now). Free your own processes by PID; never kill by
  name. Never touch `main`, other worktrees, or push. Fix lint and format findings in your own edit and go on.

## Git law

Stage per path, one commit per task, message `pressure: <what>`, ending with
`Co-Authored-By: GPT-6.2 Astra <noreply@openai.com>`. Banned: `git stash`, `git add -A/./-u`, `git commit -a`,
`reset --hard`, `--amend`, rebase, merge. `node tools/gate/quick.mjs` before each commit. Commit `.uid` with any new `.gd`.
Do not touch `JOURNAL.md`, `REPORT.md`, `evidence/briefs/`.

## Allowlist (any other path: stop that task and report `NEED <lane>: <file> <why>`)

- `project/features/player/player_deflect.gd`, `player_guard.gd`, `player_guard_input.gd`, `player_guard_pose.gd`,
  `player_guard_view.gd`, `guard_tuning.gd`; new files `project/features/player/deflect_*.gd`
- `project/data/tables/combat.json`: ONLY the `guard` block and a new `deflect` block (the `moves` block is lane ghost's,
  the rest is not yours); `project/data/schemas/combat.schema.json` for those two blocks only
- `project/features/combat/enemy_round_look.gd`, `enemy_rounds.gd`, `shot_draw.gd`, `project/features/combat/weapons/gun_fx*.gd`
- `project/features/gauntlet/**`, `project/dev/gauntlet/**` (the test player, measurement scripts), `tools/gauntlet/**`
- tests named for these files and new `project/tests/unit/test_deflect_*.gd`; moved expected digests (list each)
- `project/boot/launch_args.gd` `KNOWN_FLAGS` append-only; `docs/decisions.md` append-only, one line per decision
- `project/features/combat/combat_arena.gd`: one-line call sites only (at its size cap); name the line in your report

Forbidden: `project/features/player/player_melee.gd` and every `melee_*.gd` (lane melee; `PlayerMelee` calls
`PlayerDeflect.bat` at `player_melee.gd:52`: put the rule INSIDE `PlayerDeflect`), `input_actions.json`,
`rivet_motion.json`, `melee_weapons.json`, `ghost_*.json`, `powers.json`, `project/features/souls/**`,
`project/features/characters/**`, any art.

## What is there today (verify it)

- `PlayerDeflect.send_back` (`player_deflect.gd`) turns a round exactly at its shooter, 100% of rounds, damage
  `BACK_DAMAGE` 1.0. Two callers: the held guard `PlayerGuard.deflect` (`player_guard.gd:65`, only `Shot.SMALL` rounds in
  the front arc, drains the meter) and the plasma sword's timed bat `PlayerDeflect.bat` (any round in reach in front,
  including large ones today).
- The rule on large rounds: the guard never takes them; the bat does. Keep that.

## Task 1 - the `deflect` block and the rule (one commit)

Owner, verbatim: "Deflecting seems to be too OP, spread angle of deflected bullets so they won't always hit the
shooter, create mechanic of throughput ratio of the deflection. At start 50% basic projectiles will be deflected, 50% go
through and cause damage. With time we can have equipment and bonuses to support the deflection in game".

New block `combat.json` `deflect` (wire names are fixed by the lane contract):
`pass_ratio` 0.5 (share of basic rounds a deflect would have sent back that instead go through and hurt Rivet),
`pass_ratio_k` 1.0 (documented multiplier for later equipment/bonuses: effective pass = clamp(pass_ratio * pass_ratio_k, 0, 1)),
`spread_deg` 12 (half-angle: a sent-back round flies at its shooter turned by a uniform draw in [-spread, +spread]),
`basic_rounds` (array of the round kinds that count as basic: `small`; large rounds and blasts are never subject to this
rule: a bat on a large round keeps today's behaviour), plus a `doc` string. Schema.

- The pass/back roll and the spread draw come from the RNG registry stream `&"deflect"` (find how other features get a
  registry stream, e.g. `ctx.rng.stream(&"gunplay")` in `features/combat/weapons/gunplay_hook.gd:44`). No global rand.
- Both paths: the guard (a passed round is not deflected, it goes on and hits Rivet with its full damage and the normal
  hit reaction; decide and say whether it still drains the meter: suggestion yes, half) and the bat (a passed round is
  left on its course).
- Replays: a tape with no deflect must stay byte-identical. If creating the stream or reading the table changes a
  digest of a tape that never deflects, make it lazy. Tapes that contain deflects will move: list each with a reason and
  add one dated `docs/decisions.md` line.
- Unit tests: with a seeded registry, of 1000 basic rounds about 50% (within a stated tolerance) pass; `pass_ratio_k` 0.5
  halves it; a large round on the bat is always sent back; every sent-back direction is within `spread_deg` of the
  shooter direction; same seed -> same rolls.

## Task 2 - the player can read which half he got (one commit)

A round that goes through must look different from a deflected one: a different spark at the contact point (not teal:
teal is souls only; not red: blood only; vermilion only for danger; amber is allowed for heat/overload: suggestion a
short white-hot spark that breaks, or the guard rim flickering) and Rivet's normal hit reaction. View only, not replay
state (like today's `_spark`). Still image proof: render one frame of each (deflected vs passed) at 64 px/m with the
repo's frame tools (`tools/film/`, see `tools/README.md`) to `C:\Users\kazda\kiro\gtai-masters\n24\pressure\` and name
the files in your report.

## Task 3 - the hit-share table (one commit: tool + result)

A headless dev measurement `project/dev/gauntlet/deflect_share.gd` (runnable via `node tools/dev/run.mjs`, declare
`const KNOWN_FLAGS`): one pistol shooter at 6, 12 and 20 m firing into a held guard (and, if the plasma sword can be held
in the harness, the bat) for N rounds each (N >= 300): share passed, share sent back, share of sent-back rounds that hit
their shooter, at `spread_deg` 6, 12 and 20. JSON + markdown to `evidence/n24-pressure/deflect/`. Commit with the tool.
If 12 degrees still hits the shooter at 6 m almost always, say so and propose a value.

## After each code commit

`node tools/mutate/mutate.mjs --file=project/features/player/player_deflect.gd --max=20 --lines=<changed lines>`; quote
killed/(killed+survived).

## Report (your final message)

Per task: done / not done, commit sha, files, checks run with result lines, the hit-share table, moved digests with
reasons, every NEED.
