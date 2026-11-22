# Brief m3 (lane moves, n23): overkill carry, then second ranks in the bonus pool

Wall clock: start 03:46. **Commit deadline 04:50. Hard stop 05:00** (report and exit even if unfinished; commit overkill carry first, ranks second).

## Setup for every shell and every Godot run
- `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/moves`
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- One Godot process at a time. Windowed runs: `--position 0,1440`. Kill only your own PIDs. No native rebuild, no bench.

## Where we are
Earlier sessions built the `moves` block in `project/data/tables/combat.json` with its loader and the `moves{<id>: count}` wave tally in `project/features/combat/moves/`, plus Ohm short-circuit, Tonnage armour crack and Kerf blink behind. Read `git log --oneline -15` and those files first and reuse them. Same law: nothing is a constant in code, `enabled: false` = byte-identical to `main`, hashed state only written when non-default.

## 1. Overkill carry (`overkill_carry`), a weapon effect won from a bonus card — commit first
Row in `moves`: `"overkill_carry": { "enabled": true, "radius_m": 3.0, "carry_k": 1.0, "hops": 1, "rank_2": { "radius_m": 4.5, "hops": 2 } }` (shape is yours to refine; every number lives in the row).
- Only active once Rivet holds the bonus (rank 1 or 2) in the gauntlet run. Without the bonus nothing changes anywhere (quest 1, arena, scenarios untouched).
- When a hit from Rivet (any weapon he holds, hands/claw included; not his ghost forms: decide and say) kills an enemy and the damage was more than the kill needed, the **leftover** (`amount_after_armour - hp_before`, in the units `CombatArena.damage()` uses after `FoeArmor.impact` and `damage_k`) times `carry_k` is dealt to the **nearest living hostile within `radius_m`** of the dead one (ties: lowest id or earliest in `arena.hostiles`, deterministic). The carried hit passes through the normal damage path (armour applies, its `hit_dir` from the dead to the new target), with a weapon id of its own (e.g. `overkill_carry`) so it is countable and never re-triggers itself at rank 1: **rank 1 carries once and a carried kill does not carry again** (decided). Rank 2 allows `hops` (2) = the carried kill may carry once more, reaching `radius_m` 4.5.
- No enemy in range: nothing happens, nothing counts.
- `CombatArena.damage()` (`project/features/combat/combat_arena.gd`, at its 255-line cap, shared): **one-line call site only** (e.g. `MoveCarry.after_kill(self, victim, amount, ...)` capturing the leftover before `victim.take`), all logic in your own file under `project/features/combat/moves/`. Be careful with re-entrancy (the carried damage calls `damage()` again) and with the kill signals order.
- Count one use per carried hit that dealt damage.
- View (not hashed): a short arc from the dead to the hit target (a few frames, ~0.15-0.25 s), white-hot / amber (colour law: no red, no teal, no blue). Own view file; hook it where kill/hit views are drawn with at most one call-site line.
- Tests: leftover carried at `carry_k` to the nearest in range; none in range = nothing, no count; exact-kill (no leftover) = nothing; rank 1 carried kill does not carry again; rank 2 hops twice and reaches 4.5 m; armour on the second target applies; not held = no carry; `enabled: false` = no carry and no offer.

## 2. Second ranks (`_2` rows) — commit second
- `project/data/tables/gauntlet_bonuses.json` has kinds `ghost` (4), `stat` (10: these already come in two sizes, `_10` and `_25`) and `weapon` (12). **There is no weapon-effect bonus today**: overkill carry is the first. So the pool gains a new kind `effect` with two rows: `effect_overkill_carry` (ref `overkill_carry`, rank 1) and `effect_overkill_carry_2` (rank 2, new optional key `"requires": "effect_overkill_carry"`; pick a ref / rank encoding that keeps the card title distinct and the draw simple, e.g. ref `overkill_carry_2`, and say which). Pick sensible `min_wave` / `weight` (e.g. rank 1 min_wave 3 weight 2; rank 2 min_wave 6 weight 2) and record them. **Do not invent other effects.**
- Schema `project/data/schemas/gauntlet_bonuses.schema.json`: kind enum gains `effect`, optional `requires` (an id pattern). Keep the `k` rule for `stat` intact.
- The draw `project/features/gauntlet/gauntlet_draw.gd` and the apply `project/features/gauntlet/gauntlet_bonus_apply.gd` are the street lane's files: **at most two one-line call sites in each** (e.g. a `continue` guard calling your `MoveBonus.offerable(row, taken, ...)` in the pool loop, and an `"effect": return MoveBonus.apply(_stage, row)` arm in the match), all logic in your own file. Rules: a row with `requires` is offered only when the required id was taken earlier in the run; a rank-1 effect already taken is not offered again; **an `effect` row whose move is `enabled: false` is skipped entirely**, so with overkill carry off the pool, the RNG draws and every offer are exactly `main`'s (verify: same gauntlet seed, same `--bot`, result JSON identical to a run on the table without the new rows).
- Card text: titles come from `tr("GAUNTLET__%s__%s" % [kind, ref])` and `tr("GAUNTLET__KIND__%s")` in `project/dev/gauntlet/gauntlet_pick_card.gd` (street's file, do not edit). Add the new keys (`GAUNTLET__KIND__EFFECT`, the two titles, and a plain-words line if the card has one) to `project/data/loc/en.po` (append only; and any other locale file the po lint requires). Plain words, e.g. rank 1 "Overkill carry: damage past a kill jumps to the nearest enemy within 3 m", rank 2 "Overkill carry II: the jump chains once more and reaches 4.5 m".
- Tests: `requires` honoured (not offered before rank 1, offered after); rank 1 not offered twice; effect rows skipped when disabled and the offers equal the old table's for a fixed seed; apply of rank 1 and 2 sets the held rank.

## Files you may edit (allowlist; any other path: stop and report a NEED)
- `project/data/tables/combat.json` (`moves` block only), `project/data/schemas/combat.schema.json` (`moves` only)
- `project/data/tables/gauntlet_bonuses.json`, `project/data/schemas/gauntlet_bonuses.schema.json`
- `project/features/combat/moves/**`, `project/features/souls/**`, `project/features/combat/ai/**`, `project/features/combat/squad/**` except `foe_shield_view.gd`
- `project/data/loc/en.po` (append your keys only)
- one-line call sites only (name each in the report): `combat_arena.gd`, `gauntlet_draw.gd` (<= 2), `gauntlet_bonus_apply.gd` (<= 2)
- new tests `project/tests/unit/test_move_*.gd`, `test_overkill*.gd`, `test_bonus_rank*.gd` (+ `.uid`)
- **Forbidden:** `project/features/player/**`, `project/features/gauntlet/bot/**` (the bot's pick values are the loop lane's: if the bot cannot score an `effect` card, report it, do not edit), `project/dev/gauntlet/**`, `tools/gauntlet/**`, `project/boot/**`, `gauntlet.json`, `enemies.json`, the `blast`/`guard` blocks, `rivet_blast.gd`, `shot*.gd`, `run_scenarios.gd`, tapes, goldens, `bosses.json`, other worktrees. No existing number changes.

## Checks
1. `node tools/tests/run_unit.mjs --changed` green; `node tools/lint/lint.mjs` green (fix lint and format findings in your own edit and go on).
2. `node tools/gate/quick.mjs` before each commit.
3. After each commit: `node tools/mutate/mutate.mjs --file=<main file> --max=20 --lines=<changed lines>`; quote the score.
4. One commit per change, staged per path with `.uid` files. No `add -A/./-u`, `commit -a`, stash, amend, rebase, reset --hard, push. Debt ratchet: shrink, or `--accept-regression="<what> for n23 moves"`.
5. Repo law: typed, ~200 lines/file (hard 300), functions <= 40 lines, <= 5 params, `Log`, no global RNG.

## Report at the end
Files, commits, call sites in other lanes' files, results, mutate scores, the rank table (effect, rank 1 numbers, rank 2 numbers, min_wave, weight), the byte-identity check (seed, both result hashes), anything left undone.

## 0. First, a 10-minute Kerf follow-up (own commit, before overkill carry)
- `project/tests/unit/test_kerf_behind.gd`: the m2 mutate survivor (target-minus-origin flipped to target-plus-origin in `KerfBehind.resolve`) lived because every fixture starts Rivet at the origin. Add a case with Rivet away from zero so that mutant dies; re-run `node tools/mutate/mutate.mjs --file=project/features/souls/kerf_behind.gd --max=20` and quote the score.
- Check whether Rivet ends a behind-landing **facing the target's back** (the move's rule). If he does not, set his facing toward the target after the landing (in `kerf_behind.gd` / the one call-site line in `kerf_stage.gd`), with a test; with `kerf_blink_behind.enabled: false` nothing changes.
- Add to the allowlist for this item: `project/tests/unit/test_kerf_behind.gd`.

## Also
- Do not amend or rebase. Leave `build/dev/m1-ohm-prologue-baseline` in place (the m4 byte check uses it).
- The street lane is also editing `gauntlet_bonus_apply.gd` and `gauntlet.json` tonight: keep your call sites to the one-line form so the morning merge is a trivial conflict at worst.
