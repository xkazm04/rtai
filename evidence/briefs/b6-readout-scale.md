# Brief b6-readout-scale: the wheel shows at the opening; the painted guard keeps Rivet's size

Two parts. **Part A first and committed on its own; Part B only after A is committed.**

Lane `controls`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls`, branch `n23-controls`.
**Hard stop: 07:50 wall clock (check `date`). Commit deadline: 07:45.** If the fix is not proven by the commit deadline, commit nothing product-side and report what you measured.
Read `evidence/briefs/n23-controls-common.md` first: environment and repo law bind this brief.

## Part A: the wheel readout at the opening (do first, own commit)
Your b5 films found it (`evidence/controls-flip/films.md`): `project/features/player/wheel_readout_view.gd` draws the owned entries only for 60 ticks after a selection change; at launch `switched_tick` is -1 and a scroll with only hands leaves it alone, so quest 1 and the arena open with no wheel on screen. The owner wants to see the game open on hands with the wheel.
1. Show the readout (Hands lit, the other owned entries listed/dimmed as today) for the first 60 ticks of a run, and for 60 ticks after any weapon_next/weapon_prev press even when the selection does not change (only hands owned). Keep the fade as today.
2. **No replay digest may move.** Prefer a view-only change (the view keeps its own "shown since" tick). If the press with no change can only be seen by touching the wheel model, add a field that is not hashed into replay state and prove it: replay_60s `cbeb734ff9b97c41...`, quest1_input, rivet_deflect byte-identical.
3. Unit test for both cases (tick 0..59 visible, 60+ hidden without a switch; scroll with only hands shows it). `node tools/tests/run_unit.mjs --changed` green. Mutate `--file=project/features/player/wheel_readout_view.gd --max=20 --lines=<changed>`; quote the score.
4. Re-shoot with the existing drivers (`project/dev/controls/{quest,arena}_opening_film.*`, same commands as in films.md): `quest1_wheel.mp4`, `arena_wheel.mp4`, and stills `quest1_wheel_opening.png` (quest frame ~280 -> pick a frame inside the first 60 ticks after the card so the readout shows Hands), `arena_wheel_hands.png` (tick < 60 with the readout). Overwrite; update `films.md` rows and the frames.json notes. Look at every frame yourself.
5. Commit the view + test (one commit), then the evidence (another).

Allowlist for Part A: `project/features/player/wheel_readout_view.gd`, its unit test (`project/tests/unit/test_wheel_readout*.gd`, new or existing), `project/features/player/rivet_wheel*.gd` only if step 2 forces it, `project/dev/controls/**`, `evidence/controls-flip/films.md`, the masters folder.

# Part B: the painted guard figure keeps Rivet's size

## The defect
`5b46a21f1` added the painted guard strips (`project/features/characters/art/view/{p70,p55}/rivet_guard.png`, cut by `tools/art/rivet_guard.py` from the masters). In `C:\Users\kazda\kiro\gtai-masters\n23\controls\guard_phases_64.png` the helmet in "First in-between", "Second in-between", "Held" and "Stagger" is visibly smaller than in "Rest" (about 10 to 15% at 32 and 64 px/m), so Rivet shrinks as the guard rises. The crouch (`HEIGHT = (0.96, 0.90, 0.83, 0.98)`) is wanted; the smaller helmet is not.

Likely cause (verify, do not assume): `prepare()` scales x by `base["head_w"] / figure["head_w"]` but forces the height to `base["h"] * HEIGHT[phase]`; on a guard figure the measured `head_w` probably includes the raised forearms/claws or the collar beside the helmet, so `sx` comes out too small, and the forced height then squashes or stretches the aspect.

## Do
1. Measure first: for every cell of both strips (p70, p55; 4 phases x 5 facings) print the helmet dome width and the figure aspect against the rest cell of the same facing in `rivet_frames.png`. Put the table in `evidence/controls-flip/guard-scale.md` (before).
2. Fix the cutter so the helmet width matches the rest cell within 5% in every cell and the figure keeps its painted aspect (one uniform scale per figure; the crouch comes from the painting plus at most a small vertical factor, say so if you keep one). Re-cut both strips from the same masters (no new generation), run `"$GODOT_BIN" --headless --path project --import`.
3. Re-measure (after) in the same table. Re-shoot with the existing driver `project/dev/controls/guard_pose_film.*`: `guard_phases_64.png`, `guard_pose_32.png`, `guard_pose_64.png` to the masters folder (overwrite; keep the old ones as `*_b4.png` beside them so the owner can compare), no spark. Look at every frame yourself.
4. `node tools/tests/run_unit.mjs --changed` green; `test_guard_view` green; replay_60s, quest1_input, rivet_deflect byte-identical (the strips are view only).
5. Commit: the cutter, both strips with their `.import`, the evidence md. One commit, through the hook.

## Allowlist for Part B
`tools/art/rivet_guard.py`, `project/features/characters/art/view/{p70,p55}/rivet_guard.png(.import)`, `project/dev/controls/**`, `evidence/controls-flip/guard-scale.md`, the masters folder above. Any other path: stop and report a NEED.

## Report
Before/after helmet-width table summary (worst cell before and after), the commit sha, the stills, test and replay lines.
