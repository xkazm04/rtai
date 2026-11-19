# Brief 06 `flip-on` (lane move, n19): decide whether vault and cover ship on, and prove the off switch

Before ANY Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/move`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
Rendering runs: `--rendering-driver d3d12`; windowed runs `--position 0,1440`. One Godot process at a time.
Never kill processes by name. Commit each step as it lands: this session is stopped at 75 minutes.

## Context
Vault (`player_vault.gd`, `vault_probe.gd`, `vault_city.gd`) and cover (`player_cover.gd`, `cover_query.gd`) are
built and evidenced on this branch, both `enabled: false` in `project/data/tables/rivet_motion.json`, switched by
`--vault/--no-vault`, `--cover/--no-cover`. The owner's rule: a behaviour that changes how the game plays ships
**on** only when its evidence is complete; and only the `gfx` lane may re-bless any sim, replay, parity or bake
digest tonight. So "on" is allowed only if no committed golden/digest moves.

## Work, in order (commit each)
1. **Off is truly off.** A unit or scenario check that, with both flags off, the arena and quest-1 stages step
   byte-identically to the moves never existing: the cover action bit stays masked, no vault probe changes the
   roll, `write_state` writes nothing. If such a check already exists, name it in your report instead.
2. **Trial flip (do not commit yet).** Set `vault.enabled` and `cover.enabled` to `true`, then run the FULL
   scenario suite (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`) and the full unit run
   (`node tools/tests/run_unit.mjs`). List every scenario/test whose result, digest or golden moves versus the
   same runs with both `false`. Also check `node tools/tests/run_parity.mjs` is unaffected.
3. **Decide per move, from that list:**
   - Nothing moves -> commit `enabled: true` for that move, plus one line appended to `docs/decisions.md`:
     `- [2026-11-19] DECISION move/<vault|cover>-on: ...` (what the evidence was, how to switch it off).
   - Something moves only because a scripted bot/test rolls next to a crate (behaviour change, not a bug) -> if
     the moved thing is a golden or digest: keep `enabled: false`, report it precisely (which golden, which
     tick, why). Do NOT re-bless any golden or digest. If it is an assertion in a move-owned test, fix the test
     so it pins the flag it means.
   - A test reveals a real bug -> fix it (red test first), then re-run step 2.
4. **Replay round trip with the moves used.** Record a short arena replay in which Rivet vaults a crate, snaps to
   cover, peeks, fires and leaves (scripted input is fine; reuse the vault/cover course tapes), then
   `"$GODOT_BIN" --headless --path project -- --replay=<file>` must exit 0. If the replay does not carry the
   flag state and a flag mismatch would diverge it, make the header carry it (a one-line, append-only change in a
   replay header writer you own, or report the file and line if it is not ours).
5. **Mutation scores.** Commit, then `node tools/mutate/mutate.mjs --file=features/player/player_cover.gd --max=20 --json`
   and the same for `features/player/cover_query.gd`. For each surviving mutant that is a real gap (not an
   equivalent mutant), add a test that kills it, commit, and quote before/after `killed/(killed+survived)`.

## Not yours
`features/combat/**`, `features/arena/**` (ai lane; `arena_rigs.gd` already has our 3 lines, add none),
`features/characters/**` (anim; at most the two call sites brief 05 named), `features/city/**`, `native/**`, any
golden/digest file. Quest 1's dumpster hide stays as it is (its replay must not change).

## Repo law
AGENTS.md + STANDARDS.md; typed; functions <= 40 lines; files ~200 (hard 300); `Log`; commit `.uid` files.
Stage per path; no stash, add -A, reset --hard; never push; never stage JOURNAL.md or evidence/. Keep existing
doc comments. Commits `move: ...` with `Co-Authored-By: GPT-6.2 Astra <noreply@openai.com>`.

## Acceptance (I check after you)
`node tools/gate/quick.mjs` + lint clean; `run_unit.mjs --changed` and `--fast` green; full scenarios green;
`git status` clean; your report lists: the step-2 table (scenario/test, off result, on result), the decision per
move with the decisions.md line, the replay round-trip exit code, both mutation scores before/after.
