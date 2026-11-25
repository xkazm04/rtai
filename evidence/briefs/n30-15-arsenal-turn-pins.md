# n30-15 arsenal-turn-pins (keys lane, run n30) - sonnet, 25 min

Launched 13:40. **Commit by 14:00. Report and END by 14:08** (hard stop, wall clock).
cwd: `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n30-keys`). Before every Godot run:
`export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/keys` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
You are the only Godot user of this lane now (lane lock `build/n30-godot.lock`: create it with your tag
`n30-15` and your shell pid, delete it when you end; nobody else holds it).

## Goal
Mutate on `project/dev/rivet_arsenal/arsenal_turn_rec.gd` scored 16.7 % (killed 1 / 6; lines 54-55 `_equip`,
168 fire bit, 169 slot bit). Survivors: the `_equip` loop count (6 steps), its rule `slot if i == 0 else -1`
(slot key pressed on the first step only), and the fire bit in `TurnPad.sample` (line 167-168).
The unit test `project/tests/unit/test_arsenal_turn.gd` pins only the slot bit. Pin the rest.

## Do
1. `_equip` needs the arena (`await _step()`), so extract a pure static helper in `arsenal_turn_rec.gd`, e.g.
   `const EQUIP_STEPS: int = 6` and `static func slot_on_step(step: int, slot: int) -> int` (returns `slot` on
   step 0, -1 after), and make `_equip` use both. Behaviour identical.
2. Tests in `test_arsenal_turn.gd`: (a) `slot_on_step` returns the slot on step 0 and -1 on steps 1..EQUIP_STEPS-1
   for every slot of `RivetCarry.SLOT_ACTIONS`; (b) `EQUIP_STEPS == 6`; (c) `TurnPad.sample` with `fire=true`
   sets `1 << actions.bit(&"fire")` and with `fire=false` clears it, and the fire bit does not set any slot key
   (and a slot does not set fire). Typed GDScript, functions <= 40 lines.
3. `node tools/tests/run_unit.mjs --select=test_arsenal_turn` green.
4. `node tools/gate/quick.mjs` (or the pre-commit hook) green; fix lint and format findings in your own edit and go on.
   If the debt ratchet rises on dev/test LOC, `node tools/debt/debt.mjs --update --accept-regression="arsenal turn pins for n30 keys"`.
5. Commit per path: `git add <each path>` then `git commit -m "test(keys n30): arsenal turn recorder pins the equip step rule and the fire bit"`
   (end the message with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`). Never amend, rebase, stash, `add -A/./-u`, `commit -a`.
   If the pre-commit hook fails on `tools/film/kill_reel_*.break.test.mjs`, run one Godot `--import` and commit again (never skip the hook).
6. After the commit: `node tools/mutate/mutate.mjs --file=project/dev/rivet_arsenal/arsenal_turn_rec.gd --max=10 --lines=<the changed lines incl. _equip, slot_on_step, 167-170> --tests=test_arsenal_turn`
   with a 15-minute wall cap (kill only your own process tree by PID if it overruns). Quote killed/(killed+survived).
   Bar: the 5 earlier survivors killed (score >= 80 %). Append a `## n30-15 mutate` section to `evidence/n30-keys/arsenal_turn.md` with the
   command, score, survivors, and commit it (per path).

## Allowlist (any other path: stop and report a NEED)
`project/dev/rivet_arsenal/arsenal_turn_rec.gd`, `project/tests/unit/test_arsenal_turn.gd`, `evidence/n30-keys/arsenal_turn.md`,
`tools/debt/baseline.json` (through the debt tool only). Forbidden: other lanes' files (combat kills, cast, prologue yard), `docs/decisions.md`.

## Report (last message)
Files, commits (sha), commands run with their result lines, the mutate score and survivors, what you could not do.
