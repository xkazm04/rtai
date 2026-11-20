# n21-kerf brief 05: two small quality fixes on the shipped Swarf Ronin

Lane `kerf`, worktree `C:\Users\kazda\kiro\gtai-wt\n21-kerf`, branch `n21-kerf`. VISUAL night: no sim, replay,
parity or bake digest may move. Kerf's row is already `spectral` (90f948645); everything accepted so far stays.

**Wall-clock hard stop: 16:45. Commit deadline: 16:40.** Small commits. Fix lint and format findings in your own
edits and go on. Never amend, never rebase. No `git stash`, no `git add -A/./-u`, no `commit -a`, no
`reset --hard`. Stage per path. Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n21/appdata/kerf`.
Godot: `C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe` (`--rendering-driver d3d12`
for rendering, `--position 0,1440` on any windowed run). One Godot process at a time; free your own by PID.
Mutate: `node tools/mutate/mutate.mjs --file=<file> --max=20` on changed lines only. After any new PNG: headless
`--import`, commit the `.import` with it.

## Allowlist (any other path: stop and report `NEED <owner>: <file> <why>`)
`project/features/souls/kerf_*`, `project/features/souls/art/kerf/**`, Kerf's files under `art/view/p70|p55`,
`project/tests/unit/test_kerf_*`, `tools/art/kerf_n21_*`, `docs/decisions.md` (append one line), scratch under
`C:\Users\kazda\kiro\gtai-masters\n21\kerf\scratch\brief05\`.

## 1. The profile HOVER shows one blade (the more important one)
At rest facing east or west in tilt 70 and 55, the HOVER cell is a near-profile and the far crescent is hidden
behind the body: he reads as a one-armed figure (see `kerf_transform_strip_32.png` tick 91 and the last frames of
`kerf_move_32.mp4`). The brief's law: "head, neck, shoulders, chest, two arms, at every facing". Make the far
crescent's tip show above and behind the helmet in those profile HOVER cells, view only. Cheapest honest route
first: a sprite cut (by script, `tools/art/kerf_n21_*.py`) from the SAME cell's near crescent, mirrored, drawn
behind the torso, darkened about 25 percent (it is farther away), its tip above the helmet line, never below the
chest. Only the profile HOVER cells (and their 55 twins); every other cell unchanged, proven by a byte compare of
a non-profile frame before/after. If it looks pasted on at 64 px/m, do not ship it: say so and stop item 1.
Evidence: before/after pair at the same tick at 32 and 64 px/m, tilt 70 and 55
(`scratch/brief05/profile_before_after.png`), and copy the final pair to
`C:\Users\kazda\kiro\gtai-masters\n21\kerf\kerf_profile_far_blade.png`.

## 2. A thin wiggly thread trails the overhead ribbon (only if 1 is done by 16:25)
In the top view a one-pixel teal zigzag thread trails off the ribbon's end (`kerf_close_64.jpg` at about x 1350..1420,
y 670..700; `kerf_hit_strip.png` top rows). It is probably the shared short vapour. Hide or shorten it from Kerf's
side only (his own mount/rig; the shared tail file is polish's: if it needs that, write `NEED polish:` and stop).

## Then
Re-shoot `kerf_move_32.mp4` and `kerf_close_64.mp4` (+ posters) with `tools/film/ghost_films.mjs` if either fix
landed. `node tools/tests/run_unit.mjs --changed`, the legacy byte compare, and `quest1_kerf` / `replay_60s`
digests unchanged.

## Final message
Commits, what each fix did (or why it was stopped), counts, digests, mutate scores, evidence paths.
