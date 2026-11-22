# Brief n24-pressure-03: Rivet's rocket in his weapon's colours, Gloria's nail small

You build for lane `pressure` of RTAI (Godot 4, internal id `gtai`) in this worktree, branch `n24-pressure`.
Read `AGENTS.md` before you start. STANDARDS.md binds.

**Wall clock: hard stop 23:26. Last commit by 23:14.**

The pre-commit hook takes about 10 minutes on a table commit: start your last commit no later than 23:14.

**Godot is the director's until 22:34.** The director runs one gauntlet batch (a Godot process of this lane) from
your start until 22:34. Until then: read, design, write the code and the tests, but launch no Godot, no unit run,
no gate, no render (the lane gets one Godot at a time). After 22:34 Godot is yours alone.


## Machine rules, git law

As in `evidence/briefs/n24-pressure-02-deflect.md` sections "Machine rules" and "Git law" (read them: APPDATA and
GODOT_BIN exports, one Godot at a time, `--rendering-driver d3d12`, `--position 0,1440`, stage per path, no stash / add -A /
amend / rebase / merge, `node tools/gate/quick.mjs` before each commit, fix lint and format in your own edit and go on).

## Allowlist (any other path: stop and report `NEED <lane>: <file> <why>`)

- `project/data/tables/weapons.json`: ONLY look fields of the `gloria` and `rocket_launcher` rows (e.g. `tracer_len_m`,
  a new look key you add and describe in the schema) and the `enemy_fire` block; `project/data/schemas/weapons.schema.json`
  for a new look key
- `project/features/combat/enemy_round_look.gd`, `shot_draw.gd`, `project/features/combat/weapons/gun_fx*.gd`,
  `project/data/tables/gun_fx.json` (+ its schema)
- `project/data/tables/combat.json` `assault_rifle.cooldown_s` only (task 0b); `enemies.json` `weapons.rocket.speed_mps` only (task 0c); `tools/debt/baseline.json` through the debt tool only (task 0a);
  `project/dev/gauntlet/deflect_share*` and `evidence/n24-pressure/**` (task 0a)
- tests named for these files; new `project/dev/gauntlet/round_sizes.gd`; `docs/decisions.md` append-only
Forbidden: every other lane's files (player melee/motion, souls, characters, art, input_actions.json).

## Task 0a - commit the deflect hit-share probe (first, 5 minutes, no Godot)

Your previous call left `project/dev/gauntlet/deflect_share.gd` (+ `.uid`, `.tscn`) and `evidence/n24-pressure/deflect/`
uncommitted because the probe raises the `project/dev/gauntlet` debt metric (919 -> 1087 lines). The director allows it:
`node tools/debt/debt.mjs --update --accept-regression="deflect_share probe for n24 pressure"`, then commit the probe,
the evidence and `tools/debt/baseline.json` together (per path).

## Task 0b - the prologue survives the faster rifle (after 22:34, one commit; stop it at 23:00 whatever the state)

`prologue_pilot` and `prologue_checkpoint` die to SWAT + Mulroney (33.7 and 39.2 HP/s) since brief 01b set
`combat.json` `assault_rifle` (the quest/prologue rifle row) `cooldown_s` 1.4 -> 0.5 with `aim_lead` 0.9 and
`damage_vs_rivet` 0.6 -> 1.2. Restoring 1.4 makes both pass (your finding). The prologue's script and lines are not ours
and its scenarios must pass. Find the SHORTEST `cooldown_s` of that row at which both prologue scenarios pass (try 0.8,
then 1.0, then 1.2; `run_scenarios` with `--only=prologue_pilot,prologue_checkpoint`), keep the doubled damage and the
lead, and commit that one value. You may edit ONLY that row's `cooldown_s` in `combat.json` (allowlisted for this task).
Then re-run every scenario whose name contains `quest` or `prologue` or `replay` and quote the line (quest 1 digest
`a113296dbccc` must be unchanged or explained). One `docs/decisions.md` line (append at the END): the value, why.

## Task 0c - the rocket stays dashable (with 0b, one commit)

After merging n24-motion, `res://tests/unit/test_player_motion_dash_dodge.gd:60` `test_rocket_from_five_eight_and_twelve_metres`
fails at 5 m: our rocket (`enemies.json` `weapons.rocket.speed_mps` 9 -> 16) lands in 19 ticks, before a 15-tick
reaction plus the dash clears the splash. The owner wants the dash to dodge big projectiles, so the rocket must stay
dashable after a human reaction. That test is motion's: do NOT edit it. Find the HIGHEST `speed_mps` (try 14, 13, 12)
at which that test passes, set it, re-run `test_player_motion_dash_dodge` and the rocket tests
(`node tools/tests/run_unit.mjs --select=test_player_motion_dash_dodge,test_foe_rocket_sites` and any test whose name
contains `rocket`); commit it with 0b or alone. One `docs/decisions.md` line at the END.

## Order

0a, then write tasks 1 and 2's code and tests (no Godot before 22:34), then after 22:34: 0c, 0b (stop 0b at
23:00 whatever its state and report it), then tasks 1 and 2's renders, tests and commits.

## Task 1 - Rivet's rocket (one commit)

Owner: "Blue rocket does not fit style of the weapon". Rivet's `rocket_launcher` row carries `"round": "large"`, the
tag last night's lane painted ice blue for ENEMY rounds (`enemy_round_look.gd`, `shot_draw.gd`, `gun_fx_rounds.gd`...).
First find the exact path that paints Rivet's own rocket blue on screen (render a still of Rivet firing the rocket at
32 px/m before you change anything: that is the "before"). Then draw Rivet's rocket in his weapon's colours: steel body,
amber exhaust (amber is allowed for heat), no ice blue; vermilion only if it marks danger. Enemy large rounds stay ice
blue (owner's keep). Do not change `round` if it changes the sim (guard/deflect rules read the size): change the look
path instead, keyed on `from_rivet` or the weapon. A unit test: Rivet's rocket colour != enemy large colour; an enemy
large round keeps `EnemyRoundLook.LARGE_*`.

## Task 2 - Gloria's nail (one commit)

Owner: "Gloria projectile is huge for initial pistol weapon it should be". Gloria is the first gun, a nail gun: its
round must be a small fast nail, clearly smaller than every later gun's round. Measure the DRAWN size (length and width in
pixels at 32 px/m, from a rendered frame or from the draw code's numbers, say which) of every player round: gloria,
pistol, assault_rifle, hand_cannon, plasma_rifle, gatling, rocket_launcher, flamethrower and every other gun row with
`enabled: true`. Write `project/dev/gauntlet/round_sizes.gd` or compute from code, output a table to
`evidence/n24-pressure/rounds/sizes-before.md` and `sizes-after.md`. Make Gloria's the smallest drawn round (a thin
steel nail with a short bright trail; it may stay fast). Before beside after stills of Gloria firing and the rocket at
32 and 64 px/m, same tick, to `C:\Users\kazda\kiro\gtai-masters\n24\pressure\` (use `tools/film/` - see `tools/README.md`
for the same-tick before/after tool). Name the files.

## Replays

Look changes must not move any sim/replay digest. If one moves, stop and report why.

## After each code commit

`node tools/mutate/mutate.mjs --file=<main changed .gd> --max=20 --lines=<changed lines>`; quote the score.

## Report

Per task: done / not done, commit sha, files, checks with result lines, the round-size table before and after, still
paths, every NEED.
