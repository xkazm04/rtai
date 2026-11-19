# Brief 09 `solid-fuzz` (lane move, n19): prove there is no way into a solid with both moves on

Before ANY Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/move`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
Rendering runs: `--rendering-driver d3d12`; windowed runs `--position 0,1440`. One Godot process at a time.
Never kill processes by name. Commit each step as it lands: this session is stopped at 75 minutes.

## Context (what the director found)
- Vault and cover are ON by default since b9d072b45. The owner judges the lane on "zero ways to end up inside a
  solid (a fuzz scenario over the arena and a city block)", replay identity, and how cleanly the flags switch off.
- `scenario_rivet_vault` fuzzes **aimed vault approaches** over the pit arena and the city-block arena
  (`VaultTrial.stage_for(city)`). `scenario_rivet_cover` fuzzes **cover presses** over the pit arena only. Neither
  mixes the two, and neither drives free, hostile input (sprint into a wall then roll, cover press mid-roll, vault
  landing beside a station then cover, leave cover by rolling, peek at a corner next to a city cell, a guard
  shoving Rivet while he is in cover or airborne).
- `PlayerCover._enter` only accepts `ArenaStage` and spots with `protects_shots` (station boxes), because the
  arena's shot-stop rule (`ArenaWalls.blocks`) only knows stations. City props never stop a shot, so cover
  correctly refuses there. Keep that: do NOT make city props cover (that would be a fake protection).

## Work, in order (commit each)
1. **`scenario_moves_fuzz`** (`project/tests/scenarios/`, ours; a helper beside `vault_trial.gd` if it needs one):
   a seeded random-input monkey (the seed from the scenario, RNG only through a local
   `RandomNumberGenerator` seeded from a constant, as the other scenarios do) that drives the real stage through
   the pilot's input path (the same `InputSource`/`TickInput` way `scenario_moves_replay.gd` uses, not by writing
   positions), with both moves on, for at least 6,000 ticks on the pit arena and 6,000 on the city-block arena.
   Input mix per burst of 6 to 40 ticks: a stick direction (biased toward the nearest station or city solid 60 %
   of the time), sprint held or not, and one of: nothing, roll, cover, fire, roll then cover within 0 to 8 ticks,
   cover then roll. Respawn Rivet at a clear random spot near a solid every 600 ticks or when he dies.
   Hostiles stay as the stage spawns them (they shove and shoot), so the bodies pass is exercised.
   **Every tick, after the stage's whole step**, assert: Rivet's body circle overlaps no station box, no city
   cell solid, no parked car hull (the same tests `scenario_rivet_cover`/`scenario_rivet_vault` use for
   "forbidden overlap"; reuse their checker, do not write a laxer one). Count and print: ticks, vault starts and
   landings, cover snaps, peeks, leaves, refusals, roll-cancelled covers, ticks airborne, ticks in cover, and the
   overlaps (must be 0). Run the whole tape twice: identical final digest and identical position trace.
   A failure prints the tick, seed, the last 20 inputs and the solid it hit, so the director can replay it.
2. **If it finds an overlap: fix the cause** in `features/player/**` (ours), with a unit test that is red before
   the fix and green after, and re-run. Report each one found (tick, what happened, the fix). Do not loosen the
   checker, do not filter the case out of the fuzz.
3. **Flags switch cleanly.** In the same scenario (or a sibling), run a short tape with `--no-vault --no-cover`
   semantics (however `test_moves_off.gd` pins them) and assert no vault start and no cover snap ever happens and
   the digest equals a run where the vault/cover inputs are replaced by nothing-and-roll. If that equality is not
   the right statement for this code, state the right one and assert it.
4. Add the scenario to the suite the way the others are registered, run the full scenario suite once (quote the
   line), and `run_unit.mjs --changed`.

## Not yours
`features/arena/**`, `features/combat/**` (ai), `features/characters/**` (anim), city/police/native (gfx), any
golden or digest file, `project/boot/**` beyond an existing call site.

## Repo law
AGENTS.md + STANDARDS.md; typed; functions <= 40 lines; files ~200 (hard 300); `Log`, never `print`; no global
RNG; commit `.uid` files. Stage per path; no stash, add -A, reset --hard; never push; never stage JOURNAL.md or
evidence/. Keep doc comments. Commits `move: ...` with `Co-Authored-By: GPT-6.2 Astra <noreply@openai.com>`.

## Acceptance (I check after you)
`run_scenarios.gd -- --only=moves_fuzz` passes with the counts printed and 0 overlaps, twice identical; full
scenario suite green; quick gate + lint clean; `git status` clean. Then continue with
`evidence/briefs/08-car-doors.md` in this same session if time is left (commit as you go).
