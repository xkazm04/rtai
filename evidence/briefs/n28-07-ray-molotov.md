# Brief n28-07-ray-molotov: finish the ray gun's p70 grids, then the molotov's

You are the builder (in-session subagent; builder.mjs is out of account). Worktree
`C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n28-keys`): **`cd` there in every shell command**. Repo law:
`AGENTS.md`, `STANDARDS.md`.

**HARD STOP: report and END by 20:35 whatever the state. Commit the ray gun by 20:02; the molotov by 20:28 only if it
passes in time (otherwise leave its round resumable under `gtai-art/rivet-n28/molotov/`, nothing under project/, and say
so).** Check `date` often. Small commits, staged per path, `git commit -- <paths>`. No amend, rebase, stash,
`add -A/./-u`, `commit -a`, `reset --hard`, push. Fix lint and format findings in your own edit and go on. No subagents,
no model CLI except the image tool `C:/Users/kazda/kiro/gtai-art/gen.mjs`. Godot: `export
APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/keys`,
`GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`, `GTAI_GODOT_EST_MB=600`
(1000 for renders), `--rendering-driver d3d12`, windowed `--position 0,1440`, one Godot at a time, never raw, free your own
processes by PID only (never by name; the Codex desktop app's `codex.exe` 4380 / 30912 are not yours).

Route, bars, wiring, evidence, allowlist and forbidden list: exactly `evidence/briefs/n28-03-nuke-ray.md` (read it) and
`evidence/briefs/n28-06-molotov-sword.md` (the molotov half), widened to the molotov's files:
`project/features/characters/art/view/p70/rivet_{walk,run8}_eq_{ray_gun,molotov}*` and the mini-nuke grid stills
`grid_mini_nuke_64/_32.png` (evidence only). Accepted examples: homing shard 3ea5cf48c / 6d27d55a0, mini-nuke 2f5dde79d /
82760ae9e. Images: cap 6 for this call (count attempts), one `gen.mjs` job at a time.

## Part 1, ray gun (round `C:/Users/kazda/kiro/gtai-art/rivet-n28/ray_gun/`, read its `STATE.md` first)
- The run-sheet edit is already in `out/edit_a_run_sheet.png` (counted). Codex said it moved "some boot pixels": check
  each run row's legs against the donor (leg IoU as for the homing shard, bar >= 0.85; sole y within 2 px); list it.
- The walk-sheet edit (fixed one-hand prompt in `scripts/mkjobs.py`, `jobs.json` walk-only) has **not returned twice** (12-15
  min, no file under `~/.codex/generated_images/`). Do not wait 15 minutes a third time on the same job. Instead:
  **(a)** split the donor walk sheet into two half sheets (facing rows 1-4 and rows 5-8, each with its own layout line in the
  prompt) and run them one after the other; give each 10 minutes (look under `~/.codex/generated_images/` for a new
  file every 2 minutes: when the image exists but `out/` stays empty, copy it by hand and stop that job's processes by PID).
  **(b)** If a half also stalls: the ray gun is a one-hand pistol-grip gun, so use the **pistol's** p70 walk sheet
  (`rivet_walk_eq_pistol.png`) as image 1 for the walk half sheets instead (its legs are the plasma rifle's family; record
  which rows used which donor, and the stride rows then come from the donor actually used; check the pistol rows'
  `rivet_motion.json` values and copy them for those rows).
- While an image is pending, do the Godot work: render the stop-gap column for the ray gun and add it to the mini-nuke
  grids (`grid_mini_nuke_64/_32.png` shipped without it) from a temp worktree at `ff1586958` (`git worktree add
  build/wt-before-ray ff1586958`; the mini-nuke stop-gap from `git worktree add build/wt-before-nuke 6d27d55a0`; `git
  worktree remove` both afterwards). Row labels in plain ASCII (n, ne, e, ...), never overprinting.
- Ship only at 16/16 rows; then grids, `evidence/n28-keys/grid_ray_gun.md`, frames.json entries, commits as the mini-nuke's.

## Part 2, molotov (round `C:/Users/kazda/kiro/gtai-art/rivet-n28/molotov/`, new, own `STATE.md`)
Start it as soon as the ray gun is committed or at 20:02 at the latest (then leave the ray gun round resumable with an exact
"Next" line). Donor: the plasma rifle's p70 walk and run sheets; image 2 = `rivet_eq_molotov.png` (+ `_left`). Prompt as
the ray gun's fixed one: the bottle in one claw exactly as in image 2, its rag wick lit only as on the strip (amber flame
only, no red, no teal), the other arm as in image 2, legs, boots and soles pixel-identical to image 1, the held part
inside its own cell, the collar a rigid orange-and-black hazard collar with straight stripes, never rope or cloth. Use half
sheets from the start if the full-sheet ray gun walk failed. Fallback donor for a row that fails on the arms: the pistol's
sheet (record it). Same bars, 16/16 to ship.

## Report and END (final message)
`IMAGES n` (attempts) per weapon, which donor per row, rows passed, leg IoU per run row, foot_slide beside the donor's,
commit shas, still paths, each round's STATE.md "Next", and any hint about why the walk edit stalls.
