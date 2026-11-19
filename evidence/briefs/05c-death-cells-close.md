# Brief 05c (lane anim, tag death-cells-close, resume): close B and D, leave a clean tree

Same machine law as 05/05b. Short session: no new art, no new films.

## Director's verdict (looked at `B/real-{before,after}-64.jpg`, `thug_claw_throw.png`, RESUME.md)
- B accepted for the **eight human peds** (cap, elder, hat, hood, jogger, punk, shopper, worker): the real card hood
  switches from `ped_hood_between_fall` to its own supine throw at t127, reads at 64 px/m.
- `thug_claw_throw.png` is the box-head robot. Robots die on the power-down route and never reach `KillFallCells`, so
  in game the grid is dead art. Do NOT ship it.
- D worker burn: blocked by combat's invariant (a burning kind needs a standing char set; none delivered). Do NOT ship.

## Do
1. Commit B: the 8 ped PNG + .import, their `signature_kills.json` entries (no thug entry), `test_claw_card_victims.gd`
   (+ .uid) with the thug case adjusted to what ships (assert the robot thug keeps today's path / no grid),
   `test_kill_throw_art.gd`, `kill_cells_pack.py`, provenance lines for the 8 only (remove the thug line). The dev capture
   scenes under `project/dev/arena/card_victim_*` + script: commit them only if they pass lint (`KNOWN_FLAGS` declared,
   layers) and are useful to re-film; otherwise delete them. `run_unit.mjs --changed` green, `quick.mjs --no-godot`
   green. One commit, staged per path.
2. Move `thug_claw_throw.png` (+ .import) and every worker-burn PNG/.import out of `project/` to
   `C:/Users/kazda/kiro/gtai-masters/n19/anim/death-cells/held/` (not git). Restore `street_walker_hit.gd`,
   `street_hit.py`, `test_street_walker_burn.gd` to HEAD with `git checkout -- <path>` per path (no stash, no reset).
   Leave any packer improvement only if it is used by B's commit.
3. Write `evidence/death-cells/NEED-ai.md` (overwrite) with two short requests, each with the evidence path:
   (a) the robot thug's lethal claw goes down the power-down route; the drawn robot throw grid waits in
   `gtai-masters/n19/anim/death-cells/held/` if ai wants the claw to throw robots; (b) the worker burn pair waits for a
   standing char set or a relaxation of `test_every_burning_kind_has_a_drawn_char_cell`; (c) the claw-kill rifle lies
   ~0.86 m from the patrol boots vs the owner's 0.5 m (A/after-64.jpg). Commit `evidence/death-cells/` (md + small json
   only, no images).
4. Finish with `git status --short` showing no modified tracked product files and no untracked files under
   `project/`, `tools/`, `steam/`. Report: commits (sha + subject), test lines, final `git status --short`.
