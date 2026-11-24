# Brief n28-cast-10: which contractor height is true (measurement only, NO Godot)

Lane `cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd), branch `n28-cast`. **Hard stop 23:15 local.**
The final gate is running in this worktree: do NOT launch Godot (not even through runGodot), do NOT touch code, tests,
data or tools, do NOT run `git checkout`/`git stash`/`git reset`. You may only: read files, use ffmpeg/ffprobe/python on the
films, write scratch under `build/look/`, and append one paragraph to `docs/art/cast-audit.md` (then commit that one path:
`git commit -m "..." -- docs/art/cast-audit.md`, message ends with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`).

## The question
Director's eye on `C:\Users\kazda\kiro\gtai-masters\n28\cast\contractor_close_64.mp4` at 9 s and 18 s: Rivet ~148 px, the
spawned patrol cop (a real `patrol_cop` fighter, `project/dev/cast/cast_contractor_fight.gd:74`) ~110 px, the contractor
~82 px tall at 64 px/m. But the beside still `contractor_beside_64ppm_tilt70.png` (from `project/dev/cast/cast_contractor_lineup.gd`)
says contractor 111 / 117, patrol 87 / 88, Rivet 154 / 146, and the poses launch says contractor stand 86 at 64.

1. Measure in the close film (extract frames with ffmpeg at full 1920x1080, PNG): silhouette height (top of hat to lowest
   boot px, screen px) of Rivet, the patrol cop and the contractor, on 3+ frames where the contractor walks upright; use the
   asphalt/kerb background (a frame where he is absent, or median over frames, for subtraction). Exclude the cop's gun/arms
   only if they extend below the boots. Quote per-frame numbers and the ratio contractor / cop.
2. Read `cast_contractor_lineup.gd` (and what it calls) and explain why its contractor is 111 and the cop 87: which sheet,
   which scale, card or rig, padded ratio, rig scale of the cop. One paragraph, with file:line.
3. Say which numbers are the live game's (the film's spawn path is the game's) and whether the beside still misrepresents
   the live sizes. Append that as a paragraph "Contractor, n28: live height vs the lineup" to `docs/art/cast-audit.md` and commit it.

## Report (then END)
The table of heights per frame, the ratio, the lineup explanation with file:line, the commit sha. Never guess a number.
