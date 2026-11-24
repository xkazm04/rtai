# Brief n28-02b-homing-shard-finish: finish the homing shard test from its round state

You are the builder (an in-session subagent: the builder.mjs account hit its weekly limit at 17:44, so the director runs
you directly). Worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n28-keys`): **`cd` there in every shell
command** (your default cwd may differ). Repo law: `AGENTS.md`, `STANDARDS.md` in that worktree.

**HARD STOP: report and END by 19:12 whatever the state. Commit the homing shard grids by 18:50 if they pass; the
evidence commit by 19:05.** Check `date` often. The pre-commit hook can take ~12 min on this machine: start the grid
commit no later than 18:50. Small commits, staged per path, `git commit -- <paths>`. No amend, no rebase, no stash, no
`add -A/./-u`, no `commit -a`, no `reset --hard`, never push. Fix lint and format findings in your own edit and go on.
Do not start subagents or other model CLIs; the only model tool allowed is the image tool `C:/Users/kazda/kiro/gtai-art/gen.mjs`.

## Read first, then do exactly the brief `evidence/briefs/n28-02-homing-shard.md`, except:
- **Skip Part 0** (the dash checks) unless the grids are committed before 18:50 and Godot starts at once; then only
  `node tools/tests/run_unit.mjs --select=test_pressure_takes,test_bot_dash,test_player_motion_dash`, quote its line.
- The round `C:/Users/kazda/kiro/gtai-art/rivet-n28/homing_shard/` is already far along: read its `STATE.md`. **Edit A is
  done: 2 images used** (`out/edit_a_walk_sheet.png`, `out/edit_a_run_sheet.png`, both 1536x1024, the donor layouts in
  `refs/`). The walk sheet was already cut and compared (`cand1/raw_walk.png`, `keep_walk.png`, `metrics_walk.json`,
  `montage_walk.jpg`: donor | raw | legs-kept). Image cap for this call: 8 more (10 total). Update `STATE.md` after every step.
- The director looked at `cand1/montage_walk.jpg`: the **raw** walk cells read right (shard in both hands, legs as the
  donor, metrics dome/sole 0); the **legs-kept** cells carry plasma-rifle remnants (the tan stock below the seam, e.g. row 1)
  so legs-kept fails "no plasma rifle remnant" wherever the weapon dips below the hip line. Prefer raw; use legs-kept only
  for a row where its seam has no remnant (prove it: no donor-rifle pixels left, by a diff mask).
- The run sheet edit is not cut yet. At thumbnail size the back rows (facing 5, and the back three-quarter rows) may draw
  the collar as a twisted band: check every cell at full size for a rigid flat collar with straight stripes. Rows that
  fail: one single-row or 4-row re-edit each from the remaining images.
- Memory: the run's 8 GB cap is at ~3 GB now; set `GTAI_GODOT_EST_MB=600` for headless runs, 1000 for renders, so a
  launch fits. If a Godot launch still waits > 10 min, write `FRICTION mem-budget <min>` and ship what does not need it
  (the round, STATE.md, the evidence md with the image-side table) without the in-game numbers; then do NOT wire the pngs.
- Everything else (bars, ship-only-if-16/16, wiring, allowlist, forbidden paths, evidence files, report format) is the
  n28-02 brief, word for word. Before frames: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/keys`,
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`, `--rendering-driver
  d3d12`, windowed `--position 0,1440`, one Godot at a time, never raw Godot, free your own processes by PID only.

Report and END (final message): `IMAGES n` (round total), rows passed raw / legs-kept / re-edit, the per-row table path,
foot_slide beside the plasma rifle's, commit shas, stills/clip paths + ffprobe line, what STATE.md says is next, and your
recommendation for the next four weapons (route, images each, prompt changes).
