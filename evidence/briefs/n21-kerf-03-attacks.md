# n21-kerf brief 03: blink and blink-slice on the Swarf Ronin, charge slots, attack films

Lane `kerf`, worktree `C:\Users\kazda\kiro\gtai-wt\n21-kerf`, branch `n21-kerf`. VISUAL night: the sim decides
every timing (everything resolves on the press tick); only what is drawn changes. No sim, replay, parity or bake
digest may move. Kerf's `look` row stays `legacy` in this package.

**Wall-clock hard stop: HARDSTOP. Commit deadline: COMMITBY.** Commit in small steps. Fix lint and format
findings in your own edits and go on. Never amend, never rebase. No `git stash`, no `git add -A/./-u`, no
`commit -a`, no `reset --hard`. Stage per path. Before every Godot run:
`export APPDATA=C:/Users/kazda/kiro/gtai-n21/appdata/kerf`. Godot:
`C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe` (`--rendering-driver d3d12`
for rendering, `--position 0,1440` on any windowed run). One Godot process at a time; free your own by PID.

## Allowlist (any other path: stop and report `NEED <owner>: <file> <why>`)
Same as brief 02: `project/features/souls/kerf_*` and `art/kerf/**`, Kerf's files under `art/view/p70|p55`,
`project/tests/unit/test_kerf_*`, Kerf's `ghost_hover.json` row, `project/dev/ghost-powers/kerf_beat.gd`,
`project/features/hud/art/ghost_chips/kerf_*`, `tools/art/kerf_n21_*`, `docs/decisions.md` (append one line),
the three Kerf call sites in `project/features/combat/kills/` (`KerfVictim`, do not widen them), and scratch
under `C:\Users\kazda\kiro\gtai-masters\n21\kerf\`.

## What the owner wants kept EXACTLY (n20's blink-slice read)
"I would keep similar attack move and impact on human target is beautiful." On the press tick: the after-image
stands where he left, in the pose he left in; one thin straight slot runs from it through the target; Kerf is
already past the target; the target is WHOLE and standing on the press tick and reacts a few frames later; no
star, no flash on the victim. See `C:\Users\kazda\kiro\gtai-masters\n20\kerf\slice_strip_top_32.png` and
`kerf_attack_32.mp4`. `kerf_echo.gd`, `kerf_slot.gd`, `kerf_victim.gd` and the three kill call sites carry it.
Re-fit it to the new body; do not redesign it.

## The work
1. **Charge slots.** The three glowing slots (chest in the toward cells, back plate in the away cells, back
   plate on the top-view torso) ARE the three blink charges. A spent charge's slot goes dark (dark steel, ink
   colour of the plate, not black holes) and relights over its recharge (`KerfStage.charges`,
   `recharge_k()`; one charge back per second), as a short bright relight, not a slow fade. Use the slot
   centroids in `project/features/souls/art/kerf/ronin/cut.json` (per cell, per tilt; the top torso). Which slot
   goes dark first: the rightmost on the page in the toward view (so the count reads left to right like a
   gauge); mirror the order for flipped cells. The overlay must follow the cell exactly (frame, flip, scale,
   the mount's bank and lean) and be absent where the cell has no slots (profile). It must read at 32 px/m: if a
   single dark slot is too small to see, darken a slightly larger rounded patch over it. Unit-test the
   charges -> lit-slots mapping and that a cell with no slots draws none.
2. **Slice arrival.** On the press tick he is drawn in CUT: the right blade thrust forward along his new facing,
   so the blade that cut is visible in the frame where he reappears, past the target. Check his arrival facing
   (the sim sets `rivet.facing` back toward the target after a slice): the CUT blade must point AWAY from the
   victim along the cut line (the way he travelled), not back at it. If the sim's facing points back at the
   target, draw CUT along the travel direction (`trail_to[-1] - trail_from[-1]`) for the CUT/RECOVER ticks
   instead; view only. Then RECOVER, then his normal pose. Same in tilt 70, tilt 55 and the top rig.
3. **After-image pose.** The echo must show the pose he left in: when a target was locked before the press,
   that is COCK (the wind-up), facing the target. Check the echo captures the frame BEFORE the pose switches to
   CUT on the press tick (it captured the old body correctly on n20; the order may change with the new drawer).
4. **Sparks on the slot** (as on the plate): a few tiny pale aqua-white sparks hanging along the slot line for
   the slot's life, drifting a little, fading with it. Never within `target.radius_m + 0.3 m` of the victim's
   position, never a star or flash. Teal/aqua only (teal is for souls). Off under `--reduced-motion`. View only,
   seeded from the blink's tick (no global RNG: repo rule 9).
5. **Plain blink** (no target): BLINK pose at arrival, the after-image in the pose he left, one slot spent.
6. **Kerf beat.** `project/dev/ghost-powers/kerf_beat.gd` drives the attack take of the films: make sure it shows a
   wind-up (a locked target for about half a second before the press), one slice on a human guard, and one plain
   blink, inside 5 s.

## Evidence (into `C:\Users\kazda\kiro\gtai-masters\n21\kerf\`)
- `slice_strip_top_32.png`: one blink-slice from the top view at 32 px/m, frames at the press tick, +3, +15
  (label the ticks), was / is / cut readable: the after-image, Kerf past the target with the blade forward, the
  slot, the whole victim, then the victim reacting. Same layout as n20's strip. And `slice_strip_70_32.png`.
- `slice_before_after_top_32.png`: n20's strip above, yours below (same ticks).
- `charges_3views_64.png`: 64 px/m, three columns (toward tilt 70, away tilt 70, top) x four rows (3, 2, 1, 0
  charges): the count must read in every panel. Plus one row at 32 px/m.
- `kerf_attack_32.mp4` + `.jpg` poster and `kerf_close_64.mp4` + `.jpg` through `tools/film/ghost_films.mjs`
  (Kerf, `--ghost-look=spectral`, tilt 70 above, top below).
- Legacy unchanged: the legacy slice strip at the same ticks byte-identical to before your change (quote it).

## Tests, gate, mutate
`node tools/tests/run_unit.mjs --changed`, then `--select=` every `test_kerf_*`, then `node tools/gate/quick.mjs`.
Check the sim did not move: run the scenarios that cover Kerf (`quest1_kerf` and the replay:
`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd -- --only=<names>`; read the runner for the
exact flag) and quote the replay digest before and after. After the code commit:
`node tools/mutate/mutate.mjs --file=<your main changed file> --max=20` (changed lines); quote the score.

## Final message
Files changed, commits, test/scenario results with counts and digests, mutate scores, the arrival-facing finding
(item 2), every evidence path, and anything left undone.
