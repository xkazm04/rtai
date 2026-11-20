# n21-kerf brief 02b (resume of 02 wire): fix the overhead blades, then finish what 02 left

Same rules and allowlist as brief 02. **Wall-clock hard stop: 13:55. Commit deadline: 13:50.** Fix lint and
format findings in your own edits and go on. Never amend, never rebase. Stage per path.
`export APPDATA=C:/Users/kazda/kiro/gtai-n21/appdata/kerf` before every Godot run. Mutate `--max=20`.

## What the director saw (`C:\Users\kazda\kiro\gtai-masters\n21\kerf\wire\qa_film.png`, overhead, tick 158, and `qa_64.png`)
The tilt body is right. The OVERHEAD is not yet the plate's swallow:
1. **The overhead arms are open too wide** (`C:\Users\kazda\kiro\gtai-masters\n21\kerf\kerf_poses_64.png`,
   overhead row). CRUISE is right: a clean arrow, both blades swept back. HOVER, TURN and HIT spread the upper arms
   about 90 degrees off the spine, so on a diagonal facing one crescent reaches level with or ahead of the helmet
   and the figure reads as a "T" or a star, not the plate's swallow. Required: in every pose but CUT, both upper
   arms at most about 50 degrees off the spine toward the tail (HOVER ~45, TURN asymmetric but both behind the
   shoulder line, HIT ~55 with the flinch), the two blades mirror images about the spine (check `flip_v` on one
   side: the crescent's convex edge OUTWARD, its tip curving BACK toward the tail), and every blade TIP behind the
   shoulder line. Only CUT may put the right blade ahead (thrust along the facing).
   Make `test_kerf_ronin_top.gd` check the TIP, not only the arm angle: transform the blade texture's tip pixel
   (from `parts.json`, or measured in the cutter) to world space and assert it is behind the shoulder line and on
   its own side, for both sides, for every pose but CUT.
2. **Ragged outline.** The top part sheet's teal flame fringe makes the silhouette noisy at 32 and 64 px/m (the
   tilt cells do not have it). Trim it in your cutter (`tools/art/kerf_n21_cut.py`: erode the outer glow band but
   keep the black ink line; re-run it, it is deterministic) or, if that loses the ink, tone the glow down in the
   rig. The top view should read as clean as Dent's top rig.
3. **Labels.** Evidence labels show mojibake (`Ä,â€šĂ`): write the label text as UTF-8 or ASCII ("70 deg tilt").
4. Then finish brief 02's list (whatever is not committed yet: the shared tail decision, legacy byte compare,
   `kerf_plate_vs_game.png`, `kerf_guard_32.png` with tilt 70 / tilt 55 / top, `kerf_poses_64.png`,
   `kerf_move_32.mp4` + poster, `kerf_move_before_after_32.png`, tests, quick gate, mutate on `kerf_spectral.gd`,
   `kerf_ronin_drawn.gd`, `kerf_ronin_top.gd`).

## Final message
Commits, what the blade fix was, the tip test, test/gate counts, mutate scores, legacy compare, evidence paths,
anything undone.

## Director's notes (13:05)
- `tools/gate/quick.mjs` fails its Godot parse step on scripts nobody touched (`res://features/characters/cut_rig.gd`
  fails the same way: the standalone `--check-only` cannot resolve autoloads). That is tooling, not you: run
  `node tools/gate/quick.mjs --no-godot` and rely on `run_unit.mjs --changed` + `--select=` for the parse check.
  Do not spend time on `tools/godot/check.mjs`.
- Priority if time runs short: item 1 (the swallow + tip test) and item 2 (the fringe) committed first; then the
  re-shot `kerf_poses_64.png` and `kerf_guard_32.png` (overhead row); the move film last.
