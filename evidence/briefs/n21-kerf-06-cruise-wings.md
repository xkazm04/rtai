# n21-kerf brief 06: an off-by-default open-wing CRUISE for the owner's Call (overhead only)

Lane `kerf`, worktree `C:\Users\kazda\kiro\gtai-wt\n21-kerf`, branch `n21-kerf`. VISUAL night: no sim, replay,
parity or bake digest may move. Kerf's row is `spectral`; everything shipped stays as it is BY DEFAULT.

**Wall-clock hard stop: 17:00. Commit deadline: 16:56.** One or two small commits. Fix lint and format findings in
your own edits and go on. Never amend, never rebase. No `git stash`, no `git add -A/./-u`, no `commit -a`, no
`reset --hard`. Stage per path. Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n21/appdata/kerf`.
Godot: `C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe` (`--rendering-driver d3d12`
for rendering, `--position 0,1440` on any windowed run). One Godot process at a time; free your own by PID.
If you cannot commit a green change by 16:56, commit nothing and say why.

## Allowlist (any other path: stop and report `NEED <owner>: <file> <why>`)
`project/features/souls/kerf_ronin_top.gd`, `project/tests/unit/test_kerf_*`, `project/boot/launch_args.gd`
(append ONE line to `KNOWN_FLAGS` only), `docs/decisions.md` (append one line), scratch under
`C:\Users\kazda\kiro\gtai-masters\n21\kerf\scratch\brief06\`.

## The item
From the top, CRUISE (12 m/s) reads as an arrow more than a person: `KerfRoninTop.WING_FAST = Vector2(43, 20)`
(sweep from the rear spine, upper arm / blade) folds both crescents tight along the body. The owner will judge
whether a wider cruise spread reads more as "a legless robot with hands as blades". Build the alternative so it is
one flag, OFF by default:

- `--kerf-cruise-wings=open` (declare `"--kerf-cruise-wings"` in `KNOWN_FLAGS` next to `--kerf-glide`). When set,
  the CRUISE sweep is `Vector2(62, 40)` (still swept back, tips never forward of the shoulder line, wider than
  rest's 45/34 at the shoulder only slightly so it stays a swallow, not a star). Anything else or absent: the
  current `WING_FAST`, byte-identical. Read the flag once (a static/const-time read like `kerf_spectral.gd:11`), not
  per frame. Keep `_sweep` static and its other branches untouched; CUT's off-hand `WING_FAST` stays the default
  value even with the flag (only the CRUISE branch changes).
- A unit test in `test_kerf_*` (the existing Ronin top test file if there is one) that the default CRUISE sweep is
  still `Vector2(43, 20)` and that the open value is `Vector2(62, 40)` (expose the choice through a tiny static
  helper taking a bool, so the test needs no launch args).
- One decisions line: `- [2026-11-20] DECISION kerf: --kerf-cruise-wings=open (off) widens the overhead CRUISE
  sweep 43/20 -> 62/40 for the owner's arrow-vs-person Call; default unchanged.`

## Evidence (only after the commit, may run past 16:56 but not past 17:00)
A same-tick pair of the top view in CRUISE at 64 px/m and 32 px/m, default left, `--kerf-cruise-wings=open` right,
to `C:\Users\kazda\kiro\gtai-masters\n21\kerf\call_cruise_wings_open.png` (use the film tool / ghost_review driver
the way `kerf_move_32.mp4` was shot; pick a tick in steady cruise). If there is no time for it, say so; the
director shoots it.

## Checks
`node tools/tests/run_unit.mjs --changed`, `node tools/lint/lint.mjs`. Default render unchanged is proven by the
test plus the flag being off; do not re-shoot shipped films.

## Final message
Commit sha(s), test counts, lint line, the evidence path or why it is missing.
