# Brief 06b `tidy` (lane move, n19): shrink a foreign-file edit, write frames.json, then brief 07

Before ANY Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/move`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
Rendering runs: `--rendering-driver d3d12`; windowed runs `--position 0,1440`. One Godot process at a time.
Never kill processes by name. Commit each step as it lands: this session is stopped at 75 minutes.

## 1. `project/features/arena/prop_occlusion.gd` belongs to the ai lane
Commit 4648dce27 rewrote about 10 lines of it (Hit.area replaced by Hit.rig, an early return, the `rigs`
local inlined). This lane may add only call sites there. Restore the file to its base text
(`git show 28302bd3c:project/features/arena/prop_occlusion.gd`) and re-apply the cover hook as at most three
added lines and zero changed or removed lines: keep `var area: Rect2`, append `var rig: CutRig` after the
existing fields, set `h.rig = rigs[i]` beside `h.area = area` in `_hits_of`, and the one call
`if CoverUpperCard.draw_hidden(self, h): continue` (a single line, gdformat permitting; otherwise the two-line
form) in `_draw`. Adapt `cover_upper_card.gd` (ours) to whatever it needs. `git diff 28302bd3c HEAD --
project/features/arena/prop_occlusion.gd` must show only `+` lines. The cover sheets must not change: re-render
`p70_64_low` and `p55_64_high` and compare pixels with the current ones (identical, or say what differs).
Commit, naming the call sites (file:line) in the message.

## 2. `C:/Users/kazda/kiro/gtai-masters/n19/move/frames.json`
8 to 15 entries, best first: `[{ "file", "title", "ppm", "before", "note" }]` (`file` relative to that folder,
`before` the matching before/stand-in file or null). Draw from `cells/` (drawn vault and cover sheets, both
clips), `vault/` and `cover/` (same-tick before/after pairs, the 32 px/m clips). Each note: one honest line of
what the frame shows. Not in git.

## 3. Then `evidence/briefs/07-walk-slide.md` in this same session.

## Repo law
AGENTS.md + STANDARDS.md. Stage per path; no stash, add -A, reset --hard; never push; never stage JOURNAL.md
or evidence/. Commits `move: ...` with `Co-Authored-By: GPT-6.2 Astra <noreply@openai.com>`.
