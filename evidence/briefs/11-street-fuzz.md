# Brief 11 `street-fuzz` (lane move, n19): prove "never inside a solid" in the real quest-1 city, with traffic

Before ANY Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/move`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
Rendering runs: `--rendering-driver d3d12`; windowed runs `--position 0,1440`. One Godot process at a time.
Never kill processes by name. Commit each step as it lands (stage per path, no `git add -A`, no stash):
this session is stopped at 75 minutes. Freeze 07:30: nothing after it. Tonight favours robust engine behaviour
over new surface; vault and cover are ON by default (data), `--no-vault` / `--no-cover` turn them off.

## Why
`scenario_moves_fuzz` (yours, 552e02a95) fuzzes vault + cover in the pit arena and the arena's city block. Both
have no traffic and no peds. Quest 1 runs on the same `CollectCallStage` + `StagePilot` + `PlayerMotion` (so the
vault is live there), over the real baked city with parked cars, kerb furniture, moving traffic and peds. Nothing
fuzzes the vault there. "Zero ways to end up inside a solid" is the lane's headline judgement.

## 1. Establish (no code yet, 10 min max)
Read `project/boot/collect_call/quest1_session.gd`, `collect_call_stage.gd`, `features/player/vault_probe.gd`,
`vault_city.gd`. Answer in your final message: in the quest-1 stage, which solids does the vault probe see (static
cells, parked cars, furniture; moving cars?) and what does `VaultTrial.forbidden_contact` check there. If the vault
cannot fire at all in quest 1 (no probe source), say so, and fuzz the city block arena's richest street instead,
adding the quest-1 gap to the final message: do NOT wire new systems.

## 2. `scenario_moves_street` (new scenario, tests only)
- The quest-1 stage (or the richest city stage the vault runs in), a fixed seed, a hostile `MovesFuzzTape`-style
  tape through the real pilot input path (sprint at kerb furniture and parked cars, roll presses, cover presses,
  turns mid-vault, vaults into the road while traffic passes). Aim bursts at the nearest vaultable prop so vaults
  actually start (reuse 2923e2528's nearest-occupied-cell idea).
- After every whole stage step check `VaultTrial.forbidden_contact` (the shared checker, not a laxer copy), plus:
  Rivet's centre never inside a STATIC solid cell or a PARKED car's footprint at the end of a tick. A moving car
  pushing him is ordinary collision, not a fault: count it separately (`car_contacts`), do not fail on it.
- Run the tape twice on fresh stages: per-tick positions equal, final digest equal, counts printed
  (`ticks, vault_starts, vault_refusals, landings, snaps, cover_refusals, airborne_ticks, overlaps, car_contacts`).
  Every movement counter must be non-zero (coverage guard), overlaps must be 0. At least 6,000 ticks if it runs
  in under ~60 s; otherwise say the length and why.
- Off control: the same tape with `--no-vault --no-cover`: 0 vault starts, 0 snaps.
- Must not change quest 1's own replay or any digest: you add a scenario, you do not touch the quest.
- Register it in the scenario list the way `scenario_moves_fuzz` is registered; keep it under the scenario
  suite's budget (if it is slow, put it in the slow tier the same way other slow scenarios are).

## 3. If it finds a way into a solid
Fix it in `features/player/**` only, with a red-before unit test that reproduces the exact case (position,
heading, prop) from the fuzz, then the fuzz green. Each fix its own commit. Re-run `scenario_moves_fuzz` and
`rivet_vault` after any fix. If a fix would need `features/city/**` or `boot/**` beyond a one-line call site,
stop and describe it instead.

## 4. Evidence
A 32 px/m clip (10 to 20 s, tilt 70, `--rendering-driver d3d12`) of the street run's densest vault stretch to
`C:/Users/kazda/kiro/gtai-masters/n19/move/street/street_32.mp4` and one 64 px/m still of a vault over a parked
car bonnet or kerb furniture (`street/`), with an `INDEX.md` line each. Look at them and say what you saw.
Then run `node tools/gate/quick.mjs` and `node tools/tests/run_unit.mjs --changed`; quote both.

## Not yours
`features/arena/**`, `features/combat/**` (ai), `features/characters/**` (anim), city/police/native (gfx), any
golden or digest file, `project/boot/**` beyond an existing call site, `docs/decisions.md` (unless a fix changes
behaviour: then ONE appended line).
