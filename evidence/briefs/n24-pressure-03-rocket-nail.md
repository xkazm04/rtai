# Brief n24-pressure-03: Rivet's rocket in his weapon's colours, Gloria's nail small

You build for lane `pressure` of RTAI (Godot 4, internal id `gtai`) in this worktree, branch `n24-pressure`.
Read `AGENTS.md` before you start. STANDARDS.md binds.

**Wall clock: hard stop HARDSTOP. Last commit by COMMITBY.**

The pre-commit hook takes about 10 minutes on a table commit: start your last commit no later than COMMITBY.

**Godot is the director's until GODOTFREE.** The director runs one gauntlet batch (a Godot process of this lane) from
your start until GODOTFREE. Until then: read, design, write the code and the tests, but launch no Godot, no unit run,
no gate, no render (the lane gets one Godot at a time). After GODOTFREE Godot is yours alone.


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
- tests named for these files; new `project/dev/gauntlet/round_sizes.gd`; `docs/decisions.md` append-only
Forbidden: every other lane's files (player melee/motion, souls, characters, art, input_actions.json).

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
