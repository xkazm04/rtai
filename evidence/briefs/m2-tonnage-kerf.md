# Brief m2 (lane moves, n23): Tonnage armour crack, then Kerf blink behind a shield

Wall clock: start ~02:35. **Commit deadline 03:35. Hard stop 03:45** (report and exit even if unfinished; commit each move as it lands, Tonnage first).

## Setup for every shell and every Godot run
- `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/moves`
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- One Godot process at a time. Windowed runs: `--position 0,1440`. Kill only your own PIDs. No native rebuild, no bench.

## Where we are
The previous session (m1) built the `moves` block in `project/data/tables/combat.json` with its loader in `project/features/combat/moves/`, the `moves{<id>: count}` wave telemetry (`MoveTally` or similar, read `git log --oneline -10` and those files first), and Ohm short-circuit. Reuse that loader and tally: add one row per move, nothing is a constant in code, `enabled: false` = byte-identical to `main`, new hashed state is written only when non-default (so the 60 s replay and the scenario tapes stay byte-identical with the moves on).

## 1. Tonnage armour crack (`tonnage_armour_crack`) — commit first
Row: `"tonnage_armour_crack": { "enabled": true, "open_s": 4.0, "open_front_k": 1.0 }`.
- Tonnage is the hauler form (`project/features/souls/hauler_stage.gd`: `stomp_damage`, `ram_damage`; form row `tonnage`). A **Tonnage hit** (any damage event from the Tonnage form) that lands on the `war_machine` while it is in its **recovery after a stomp** (`FoeWalker`, `project/features/combat/squad/foe_walker.gd`: after the melee `stomp` resolves it enters `EnemyAgent.State.RECOVER` with `h.cooldown = attack.cooldown_ticks`; recovery after the cannon shell does not count) opens its armour for `open_s`.
- While open, the machine's front multiplier is `open_front_k` (1.0) in place of its row's `shield_front_mult` (0.5). Apply it in the armour path (`project/features/combat/squad/foe_armor.gd` `k()` / `impact()`), so **every** damage source benefits while open (guns too: that is the combo; decided). The rear multiplier stays as is.
- Once per stomp: a second Tonnage hit in the same recovery does not reopen or extend. The next stomp's recovery can open it again.
- Count one use in the tally each time the armour opens.
- Cues (view only, not hashed; your own new view file under `project/features/combat/squad/`, e.g. `foe_walker_crack_view.gd`, hooked where `foe_walker_view.gd` draws): during the post-stomp recovery the machine **sags** (body lowered / squashed a few px) and its **plates lift** (front plate edges offset outward), so the window reads; while open, a **glowing split** down the front plate (hot amber/white seam; colour law: no red, no teal, no blue). Readable at 32 px/m.
- Tests: the window opens only in post-stomp recovery (not in ENGAGE, not after the shell, not during WINDUP); open lasts `open_s` in ticks then closes; front damage while open uses 1.0, closed 0.5, rear unchanged; a pistol shot from the front while open takes full damage; once per stomp; a non-Tonnage hit in recovery does not open it; `enabled: false` = no change.

## 2. Kerf blink behind a shield (`kerf_blink_behind`) — commit second
Row: `"kerf_blink_behind": { "enabled": true }` (add a number only if the rule needs one; e.g. a clearance margin, read from the row).
- Kerf's blink-slice is in `project/features/souls/kerf_stage.gd` (`_blink`, `pick`, `_slice`; it is 208 lines: put the new logic in a new file such as `kerf_behind.gd` and keep the call sites in kerf_stage.gd to a line or two each). Today Rivet blinks along the line from him through the target to `behind_m + radius` beyond it, and the slice's `hit_dir` is that line, so a target that faces Rivet takes the slice on its front: `FoeArmor.k` gives the shield robot its 0.2 front multiplier (kind `cauterised`).
- New rule: when the target has a **blocking front arc** toward Rivet (shield robot: its row's shield arc; a riot cop **only if** its shield blocks the Kerf slice today: check and say which in your report; sentry turret / war machine have front plates too: decide by the same test "the slice would hit a front multiplier < 1.0", and say in the report which enemies it covers), the blink ends **behind the target relative to the target's own facing** (`target.pos - target.facing * (behind_m + target.radius_m)`), Rivet faces the target's back, and the slice is applied with `hit_dir` from that back side so it lands on the unshielded rear (rear multiplier). No extra damage: the gain is only the bypass.
- Only if that spot is free: not inside a wall or prop (use the same `ArenaWalls` checks the blink already uses, e.g. `blocks()` for the line and a point check / `push_out` that would move it more than a small tolerance = blocked), and inside the play space. Otherwise the blink behaves exactly as today.
- Count one use when the behind-landing happened.
- Check whether the existing squad shield cover (`foe_shield_cover.gd`: SWAT/contractors behind a shield robot) still covers a carrier hit from behind; it should not.
- Tests: shield robot facing Rivet: landing behind it, facing its back, damage = rear multiplier; target without a front arc: today's path exactly (same landing point and damage); blocked spot behind (wall): today's path; `enabled: false` = today's path; one count per behind-landing.

## Telemetry and schema
Both moves count into the same `moves{}` wave field; the run schema already has the field from m1 (extend its description only if needed).

## Files you may edit (allowlist; any other path: stop and report a NEED)
- `project/data/tables/combat.json` (`moves` block only), `project/data/schemas/combat.schema.json` (`moves` only)
- `project/features/souls/**`, `project/features/combat/ai/**`, `project/features/combat/squad/**` except `foe_shield_view.gd`
- `project/features/combat/moves/**`
- `project/features/combat/combat_arena.gd`: one-line call sites only (name each)
- new tests `project/tests/unit/test_move_*.gd`, `test_tonnage_crack*.gd`, `test_kerf_behind*.gd` (+ `.uid`)
- **Forbidden:** `project/features/player/**`, `project/features/gauntlet/**` (except the call sites m1 already made), `project/dev/gauntlet/**`, `tools/gauntlet/**`, `project/boot/**`, `gauntlet.json`, `enemies.json` numbers, `input_actions.json`, the `blast`/`guard` blocks, `rivet_blast.gd`, `shot*.gd`, `project/tests/run_scenarios.gd`, any scenario tape or golden, `bosses.json`, other worktrees. No existing enemy/weapon/ghost number changes.

## Checks (each move)
1. `node tools/tests/run_unit.mjs --changed` green; `node tools/lint/lint.mjs` green. Fix lint and format findings in your own edit and go on.
2. `node tools/gate/quick.mjs` before each commit.
3. After each move's commit: `node tools/mutate/mutate.mjs --file=<that move's main file> --max=20 --lines=<changed lines>`; quote killed/(killed+survived).
4. One commit per move (plus a separate commit for a view if you like), staged per path with `.uid` files. No `add -A/./-u`, no `commit -a`, no stash, no amend, no rebase, no reset --hard, never push. Debt ratchet: shrink what it names, or `node tools/debt/debt.mjs --update --accept-regression="<move> for n23 moves"` for a real rise.
5. Repo law: typed GDScript, ~200 lines per file (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`, no global RNG, ticks from seconds via the row (`SimClock.TICK_DT`), no frame delta in sim code.

## Report at the end
Files, commits (sha + title), call sites added in other files, test/lint/quick results, mutate scores, which enemies the Kerf rule covers and whether the riot cop blocks the slice today, anything left undone.

## Also
- Do not amend or rebase; do not touch the ignored dir `build/dev/m1-ohm-prologue-baseline` (leave it).
- Scenario check: grep the scenario setups (`project/tests/scenarios/**`) for any that use Kerf's blink-slice with a shield robot or riot cop present, or Tonnage against the war machine; list them in your report. If one exists and its tape would move, set the move `enabled: false` through that scenario's own setup (do not edit the tape).
- Prove byte-identical when off: the 60 s replay (`"$GODOT_BIN" --headless --path project -- --replay=<the 60 s replay file the scenario suite uses>`, exit 0) with both rows `enabled: true` and with them false; quote the hash line.
