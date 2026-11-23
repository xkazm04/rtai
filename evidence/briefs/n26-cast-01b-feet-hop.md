# Follow-up n26-cast-01b: planted feet WITHOUT a teleporting body

The director stopped your session at 11:47 to correct course (nothing you did was lost: your staged and unstaged work is
still in the worktree; check `git status` first and kill any Godot you had running only if it is yours).
**New hard stop 12:30 local. Commit deadline 12:20.** Same rules, same APPDATA/GODOT_BIN exports, same allowlist as the
first brief, PLUS: `project/features/arena/arena_wave_cards.gd` is allowed (answer to your question: yes, add the shared
patrol contact placement there, smallest possible edit, keep every other archetype's path as on main).

## The problem
Your re-cut patrol passes the contact rule (0.15 px) but its body jumps up to 40.50 px between two rendered frames at
32 px/m (down-right, 70, retreat). That is about 1.25 m: the cop teleports. The owner will not accept that; a hop larger than
one drawing's step reads as a glitch, not as a stride.

## The rule, tightened (update `docs/art/cast-checklist.md` Feet row and the tool's PASS)
PASS needs BOTH: support-sole contact travel <= 2 px at 32 px/m AND the largest body jump between two consecutive
rendered frames <= 12 px at 32 px/m (0.375 m), at every gait and speed the game uses.

## How (preferred; build it so the step length is one named constant the owner can change)
Advance the walk drawing by GROUND DISTANCE, not by a speed-scaled stride: one drawing per fixed step
(`STEP_M`, start at 0.35 m, the far/quest cards' current 1.4 m / 4). Then the hop at any speed is exactly one step
(0.35 m = 11.2 px at 32 px/m) and the in-cell support-foot shift you re-cut is the same for every speed, so ONE re-cut
plants the foot at walk, retreat, arrival and run. Faster gaits simply change drawings more often. If a gait's
legs then cycle visibly too fast, say so with the number (drawings per second) instead of lengthening the step.
Keep it scoped to the patrol cop's walk and armed walk (near rig, far/quest cards, wave cards); other archetypes stay as on main.

## Deliver before the commit deadline
1. Tool table re-run (before = `0779185ac`, after = your tree): patrol cop all gaits/pitches/facings, contact px AND body jump
   px, PASS/FAIL under the tightened rule; update `docs/art/cast-audit.md` "Planted feet, n26" (also keep the before rows of
   every other archetype you measured; they are the list the next calls fix).
2. Commits: tool + test; cop re-cut + placement (+ `.import`, provenance lines); audit table. Unit tests for the placement
   (`--changed` green), `node tools/gate/quick.mjs` before each commit.
3. Mutate the main placement file: `node tools/mutate/mutate.mjs --file=<file> --max=20 --lines=<changed lines>`.
4. Stills: `C:\Users\kazda\kiro\gtai-masters\n26\cast\feet_cop_patrol_before_after_64ppm_tilt{70,55}.png` (sole dots per
   rendered frame, contact span bracketed, ground mark, before left / after right, same tick and zoom).
5. A clip for the owner to judge the hop: `C:\Users\kazda\kiro\gtai-masters\n26\cast\feet_cop_patrol_before_after_32.mp4`,
   before and after side by side, a cop walking then running across a fixed ground grid, 15 to 25 s, 1920x1080, 60 fps
   (ffprobe it). If time runs out, the clip is the thing to drop, not the commits.

Do not start the lancer, door carrier, clamshell or pile-driver in this call. End with the usual report (commits, table,
mutate score, quick gate, paths, what you could not do).
