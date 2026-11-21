# Brief a1-iface: guard lane interface commit + round sizes (lane `guard`, run n22)

Wall-clock HARD STOP: 01:20 local (check `date`). Commit deadline for part A: 00:55. Part B commit by 01:15.
If you cannot finish part B by 01:15, commit what is green and report what is left.

Before every Godot or gate run: `export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/guard` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Headless only in this call; no windowed runs. Never kill processes by name, only your own by PID.

Read first (briefly): `AGENTS.md`, `STANDARDS.md` (skim), `tools/README.md` (the kit: `tools/gate/quick.mjs`,
`tools/godot/check.mjs`, `tools/tests/run_unit.mjs --changed`).

## Context (what the director already knows)
The night's design: a held right-mouse **guard** that deflects small hostile rounds in a front arc with a meter;
large rounds (rockets, cannon shells, thrown) ignore the guard. A weapon wheel (slot 0 = hands) comes later behind
`--controls=wheel`. Tonight four lanes share a wire contract; this call commits the guard lane's part of it as a
small *working* skeleton that other lanes will merge from the tag `n22-guard-iface`. Names below are wire
identifiers: use them exactly, never rename them afterwards.

Anchors:
- `project/core/replay/tick_input.gd`: `buttons` is 32 bit; `project/data/tables/input_actions.json` gives each action
  its bit; bits 16..28 carry aim/heading/reach, bit 29 is `cover`. Bits 30 and 31 look free: verify.
- `project/features/player/player_actions.gd` (`PlayerActions.install`, InputMap from the table), `live_input.gd`.
- `project/features/combat/shot.gd` (`Shot`, `Shot.fire(shooter, dir, CombatTuning.Weapon)`), `project/features/combat/combat_tuning.gd`
  (`CombatTuning.Weapon`, loads `combat.json` / the `weapons` block of `enemies.json`), `project/features/combat/weapons/weapon_spec.gd`
  (`WeaponSpec`, rows of `weapons.json`); wherever a Shot is created from a `WeaponSpec` (find it: GunHand / arena_projectiles).
- `project/boot/launch_args.gd` `KNOWN_FLAGS` (append one line; then accept the debt ratchet with
  `node tools/debt/debt.mjs --update --accept-regression="--controls for n22 guard"`).
- `project/features/player/player_deflect.gd` `bat()` (the plasma sword reflect; leave it deflecting every size).

## Part A: interface commit (then `git tag n22-guard-iface`)
1. Input action `guard`: a new row in `input_actions.json` on a free bit (30 if free), default mouse binding right
   button, no keyboard key, gamepad: pick a free shoulder/trigger if one is free else none (say which). Schema updated if
   it needs to be. A TickInput bit constant reachable by code (follow how other actions expose their bit, e.g. a
   `PlayerActions`/`PlayerCommand` constant `BIT_GUARD` or the table lookup used for `cover`).
2. Controls mode: launch flag `--controls=wheel|legacy`, default `legacy`, declared in `KNOWN_FLAGS`, parsed in ONE
   small new class `project/features/player/controls_mode.gd` (`class_name ControlsMode extends RefCounted`) with
   `static func wheel() -> bool` and `static func id() -> StringName` (`&"wheel"`/`&"legacy"`), unknown values fall back to
   legacy with a `Log` warning. **Under legacy nothing changes**: right mouse stays `melee`, and the `guard` action is
   never set in any TickInput (bind RMB to `guard` only when wheel is active, or mask the bit under legacy: pick the
   cleaner way and write a one-line DECISION in `docs/decisions.md`). Under wheel: RMB -> `guard` only (no longer
   `melee`; Space stays `melee`). Nothing reads the guard bit yet in part A, that is fine.
3. `Shot.size: StringName`, default `&"small"`, with constants `Shot.SMALL := &"small"`, `Shot.LARGE := &"large"`.
   Set it at every place a Shot is created from a weapon row: from `CombatTuning.Weapon.round` and from
   `WeaponSpec.round` (new typed fields, `StringName`, default `&"small"`), read from a row key `"round"`
   (`"small"|"large"`, absent = small, any other value = load error / failing validation as the loaders do for other
   bad values). Add `"round"` to `weapons.schema.json`, `enemies.schema.json` (weapons block) and `combat.schema.json`
   (its weapons block, if it has one) as an optional enum. Do NOT put `size` into any replay hash, digest or state
   serialisation: the 60 s replay must not move.
4. `combat.json` gets a top-level block `guard` with exactly these keys and these starting values:
   `arc_deg: 120, move_k: 0.45, meter_max: 100, drain_per_round: 12, refill_per_s: 40, refill_delay_s: 0.6, stagger_s: 0.8`,
   plus `melee_drain: 20` (a hostile melee hit from the front while guarding drains this instead of dealing damage).
   Schema in `combat.schema.json` (all required numbers, minimums sensible). A typed loader:
   `project/features/player/guard_tuning.gd` (`class_name GuardTuning extends RefCounted`, one typed var per key,
   `static func load_table() -> GuardTuning` or follow how `CombatTuning` loads its blocks; keep the file pattern of the repo).
5. Tests: `project/tests/unit/test_guard_iface.gd`: the guard block loads with the 8 keys; `Shot.new().size == &"small"`;
   a weapon row without `"round"` loads small and one with `"large"` loads large (both loaders); `ControlsMode` defaults
   to legacy; the `guard` action's bit is unique among all actions in the table.
6. `node tools/gate/quick.mjs`, `node tools/tests/run_unit.mjs --changed`, then commit (stage per path), then
   `git tag n22-guard-iface`. Commit message: `guard: n22 interface (guard action, Shot.size, round key, guard block, --controls)`.

## Part B: round sizes (second commit)
1. In `weapons.json` set `"round": "large"` on `rocket_launcher`, `molotov`, `mini_nuke` (rockets, thrown). Everything
   else stays without the key (= small; pistol, rifles, gatling, hand_cannon, bolts, flamethrower).
2. In `enemies.json`, ONLY in the `weapons` block, set `"round": "large"` on `cannon`. Touch nothing else in that file
   (the foes lane owns its rows, `tier` and archetypes).
3. A test (`project/tests/unit/test_round_size.gd`): a rocket from `rocket_launcher` and an enemy `cannon` shot are
   `large`; a pistol and an enemy `pistol`/`rifle` shot are `small`; `PlayerDeflect.bat()` still reflects a large round
   (unchanged behaviour).
4. Gate: `node tools/gate/quick.mjs`; `node tools/tests/run_unit.mjs --changed`; then the scenario suite once
   (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`, or `node tools/tests/run_scenarios.mjs` if it exists) and
   quote its summary line; the 60 s replay must pass unchanged. Commit:
   `guard: round sizes (rockets, thrown, enemy cannon are large)`.
5. Mutation, capped: `node tools/mutate/mutate.mjs --file=features/combat/shot.gd --max=20` (or the file you changed most) and quote the score.

## Allowlist (any other path: stop and report a NEED, do not edit)
`project/data/tables/input_actions.json`, `project/data/schemas/input_actions.schema.json`,
`project/data/tables/weapons.json`, `project/data/schemas/weapons.schema.json`,
`project/data/tables/combat.json` (new `guard` block only), `project/data/schemas/combat.schema.json`,
`project/data/tables/enemies.json` (the one `round` key on `cannon` only), `project/data/schemas/enemies.schema.json` (the `round` key only),
`project/features/player/**`, `project/features/combat/shot.gd`, `project/features/combat/combat_tuning.gd` and
`project/features/combat/weapons/weapon_spec.gd` (the `round` field only), the file(s) that construct a Shot from a
WeaponSpec (the one line that sets `size`; name them in your report), `project/core/replay/tick_input.gd` (doc comment only if needed),
`project/boot/launch_args.gd` (one KNOWN_FLAGS line), `tools/debt/baseline.json` (only through the debt tool),
`docs/decisions.md` (append one line at a time), new tests `project/tests/unit/test_guard_*.gd`, `test_round_size*.gd`,
`test_controls_*.gd` and their `.uid` files. If an existing test pins the input table (bit count, action list) it is
allowed to update that pin; name it.

Forbidden (other lanes): `project/features/gauntlet/**`, `project/dev/gauntlet/**`, `project/data/tables/gauntlet*.json`,
`project/features/combat/ai/**`, `project/features/combat/squad/**`, any enemies.json row other than the `cannon` round
key, `tools/gauntlet/**`, `docs/gauntlet-loop.md`, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`.

## Law
Typed GDScript, warnings are errors; files about 200 lines (hard 300), functions 40 lines or fewer, 5 params max; `Log` not
`print`; JSON tables with schema, sorted keys as the file already does; commit `.uid` files with new scripts (run
`"$GODOT_BIN" --headless --path project --import` once after adding scripts). One commit per part, staged per path. Banned:
`git stash`, `git add -A/./-u`, `git commit -a`, `--amend`, rebase, `reset --hard`, push. Fix lint and format findings in your
own edit and go on. No numbers of existing weapons or enemies change. Mutate capped `--max=20`.

## Report
Files changed per commit, both commit SHAs, the tag, the bit you used, how legacy keeps RMB = melee, the scenario
summary line, the mutate score, and anything you could not do.
