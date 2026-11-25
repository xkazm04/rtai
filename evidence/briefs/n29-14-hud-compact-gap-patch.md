# Brief n29-14-hud-compact-gap-patch: the handheld HUD gap fix as a tested patch, built in a snapshot (lane keys, run n29)

Builder for lane `keys`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n29-keys`). Repo law: `AGENTS.md`.
**The lane is frozen (07:15 commit bar passed) and gated with reels. Nothing under `project/` or `tools/` of THIS worktree
may change** (check `git status --short | grep -v '^??'` is empty at END). The product change is built and proven in a
throwaway SNAPSHOT and delivered as a patch file under `evidence/`, for the Director to apply at merge or the next run.

## Wall clock (run `date +%H:%M` first and often)
`07:09` launched. **Commit the evidence + patch by `07:50`.** **Report and END by `08:10`.** If the stills are not done by
07:50, commit the patch + test result first, stills after.

## Read first
`evidence/briefs/n30-keys-01-hud-compact-gap.md` (the fault, measured, and option A) and `evidence/n29-keys/hud.md` section
`n29-01e handheld (snapshots)` (exactly how the 1280x800 stills were rendered in snapshots via `tools/lib/snapshot.mjs`,
with the two dev-only snapshot edits: `bond_film_capture.gd` size check, `"--device",` in `project/dev/gauntlet/gauntlet.gd`
KNOWN_FLAGS).

## Do
1. Snapshot HEAD with `tools/lib/snapshot.mjs` (kind e.g. `hudgap`). In the SNAPSHOT:
   a. Add the unit test from the n30 brief step 2 to `project/tests/unit/test_ghost_chip_number.gd` (both layouts, labels
      "1".."4": every adjacent pair plate(n+1).left - plate(n).right >= 8 px; plate 1 left >= `number_min_x()`). Use the
      same plate-width arithmetic the existing tests in that file use; read them first. Run
      `node tools/tests/run_unit.mjs --select=test_ghost_chip_number` in the snapshot: it must FAIL on the compact layout
      (quote the failure line). If it passes on n29 code, your test is wrong: fix it.
   b. Option A: `GhostFormLayout.compact()` `l.gap = 42.0` -> `50.0` (`project/features/souls/ghost_form_layout.gd` line 37;
      never 58, see the n30 brief). Re-run
      `node tools/tests/run_unit.mjs --select=test_ghost_chip_number,test_ghost_form_layout,test_ghost_form_hud`: all green
      (quote counts). If a test pins 42, update it in the patch and say so.
   c. `gdformat --check` and `gdlint` on the two changed files (or `node tools/lint/lint.mjs` in the snapshot): clean.
   d. Write the product diff only (layout + test, NOT the two dev-only capture edits) with `git -C <snapshot> diff -- <the
      2-3 product paths>` to `evidence/n29-keys/hud_compact_gap.patch` in THIS worktree. Check it applies:
      `git apply --check evidence/n29-keys/hud_compact_gap.patch` from this worktree (check only, never apply here).
2. Stills (if time): in the same snapshot add the two dev-only edits and render the 01e handheld run (`--device=deck`,
   1280x800, seed 1, `--bond-prefill=16`, `--fixed-fps 60`, GTAI_FILM_FROM/TO 600/640, d3d12, `--position 0,1440`, through
   the snapshot's own `runGodot` exactly as 01e). Frame 20. Measure plate 1 left, plate 1-2 gap (bar >= 8 px), every plate
   inside the strip box. The n29 "after" frame is the 01e `hud_handheld_after.png` in
   `C:/Users/kazda/kiro/gtai-masters/n29/keys/hud/` (same tick, same flags): compose
   `C:/Users/kazda/kiro/gtai-masters/n29/keys/hud/hud_handheld_gap_patch_crop_3x.png` (strip region n29 | patched, 3x
   nearest). Read the PNG and say what you see: "1" and "2" must read as two plates, each under its own avatar.
   The desktop strip does not change under option A (compact only): say so from the code, no 1080p render needed.
3. Append `## n29-14 compact gap patch (snapshot)` to `evidence/n29-keys/hud.md`: the snapshot sha, the test failing on n29
   (line) and passing patched (counts), lint result, the measurement table, still path, and "apply with
   `git apply evidence/n29-keys/hud_compact_gap.patch`, then a `docs/decisions.md` line (compact gap 42 -> 50, option B
   `number_dx` rejected: strip unchanged but needs anchor tests rewritten)". Commit:
   `git commit -m "evidence: n29 keys compact HUD gap fix as a tested patch" -- evidence/n29-keys/hud.md evidence/n29-keys/hud_compact_gap.patch`
   (stage per path; the pre-commit hook may take ~12 min: wait for it, never skip it).
4. Remove your snapshot (`git worktree remove --force` on its exact path, or the tool's cleanup); delete only what you made.

## Godot
`export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. One Godot at a time.
Take the lane mutex before every Godot step: `(set -o noclobber; echo "gappatch $(date +%H:%M)" > build/n29-godot.lock)`
and `rm build/n29-godot.lock` right after the step. A `mem-budget: waiting` line is the machine being full: wait, note minutes.

## Allowlist
THIS worktree: `evidence/n29-keys/hud.md`, `evidence/n29-keys/hud_compact_gap.patch`, `build/**`.
`C:/Users/kazda/kiro/gtai-masters/n29/keys/hud/**`. Your snapshot (anything in it). Any other path: stop and report a NEED.
Other lanes' worktrees: never. Banned: amend, rebase, `git stash`, `git add -A/./-u`, `commit -a`, `reset --hard`, applying
the patch in this worktree. Free only your own processes, by PID; never delete anything in Temp you did not create. Fix lint
and format findings in your own edit and go on. If two routes fail, stop and report; do not loop.

## Report (short), then END
Snapshot path + sha, the failing and passing test lines, lint, the measurement table, still path, commit sha, snapshot
cleanup, what you could not do.
