# n30-07 arsenal turn recorder fires again (lane keys)

Bug: `project/dev/rivet_arsenal/arsenal_turn.gd` (driver of `arsenal_turn_rec.gd`) exited 1 at HEAD with
`no attack for pistol at octant 0` (Gloria alike). Cause (evidence/n29-keys/gloria_strips.md, n29-15): with `wheel_inventory`
on, `RivetCarry.take` selects nothing and the first `session.step()` runs the hands-first wheel, which stows the gun.

Fix (commit 020878888): `TurnPad.slot` ORs the weapon's slot key bit (`RivetCarry.SLOT_ACTIONS[slot]`) for the first of 6
steps (`_equip`, called right after `take`); the still crop `Vector2i(204, 194)` -> `(404, 294)`, base 164 -> 214 (the stock crop clips diagonal flashes). dev_loc rose 39253 -> 39264, accepted in `tools/debt/baseline.json` with a reason.

Test: `project/tests/unit/test_arsenal_turn.gd::test_turn_pad_presses_the_weapon_slot_key_only_while_a_slot_is_set`.
Red: with the `if slot >= 0:` guard in `TurnPad.sample` replaced by `if false:` the test fails (`[0] expected to equal [2048]`);
on the unfixed code it does not parse (no `slot`). Green: 6 of 6 in the file; `--changed` 742 passed.
Limit: a whole-arena unit test (equip then fire) was tried and dropped: the GUT arena starts with Gloria granted, so `take(pistol)` is
displaced there and the weapon assertion does not reproduce the n29 run state. The end-to-end proof is the real runs below.

Runs (runGodot, `-s res://dev/rivet_arsenal/arsenal_turn.gd -- --weapon=<w> --pitch=p55 --ppm=64`, d3d12, `--position 0,1440`):
- HEAD driver, pistol: exit 1, `no attack for pistol at octant 0`.
- fixed, pistol: exit 0; fixed, gloria: exit 0; each 8 `octN_rest` + 8 `octN_fire` + `reload` in `build/n30-07/<weapon>/`.
- Stills by eye: `gtai-masters/n30/keys/arsenal/{pistol,gloria}_oct{1,7}_fire.png`. Flash whole at the muzzle in pistol oct1, oct7 and gloria oct1;
  gloria oct7 the top spike reaches the crop top edge (crop, not the sprite); no clipped flash otherwise.

Mutate: NOT scored. Two runs (--max=10 over 7 lines, then --max=4 over 54-55,169-170) hit their budget in the baseline test run of the temp worktree (4 of 9 mutants chosen, none judged). The hand mutation above is the only fault shown caught.

## n30-15 mutate

Commit 4ee6f7b27 (adds `EQUIP_STEPS`, static `slot_on_step`, two pin tests in `test_arsenal_turn.gd`).

Command: `node tools/mutate/mutate.mjs --file=project/dev/rivet_arsenal/arsenal_turn_rec.gd --max=10 --lines=3,57-62,172-176 --tests=test_arsenal_turn`
Score: 100.0 % = killed 4 / (4 + 0) on the pad lines (fire bit 175 and slot bit 176-177 all killed).

Command: `... --max=20 --lines=1-70,170-180 --tests=test_arsenal_turn` (wider, includes the untested runtime `_ready`/`_record`)
Score: 35.0 % = killed 7 / (7 + 13). Killed: `slot_on_step` line 56 (3 mutants), pad lines 170/176/177. The
`_equip` loop count has no mutant of its own now (a const literal is not mutated; `EQUIP_STEPS == 6` is pinned by a test).
Survivors (all outside the n30-15 target, need the arena to run): `_ready` lines 32, 33, 39, 45; `_record` lines 68, 70;
pad line 178 `TickInput.new(bits, 0, 0)` literal 0 -> 1 (axes/extra args, not pinned).
