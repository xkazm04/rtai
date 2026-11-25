# Brief n29-01e-hud-handheld-snapshot: the gauntlet HUD at 1280x800, before | after (lane keys, run n29)

Builder for lane `keys`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n29-keys`). Repo law: `AGENTS.md`.
**Evidence only: no product commit, no images.** The lane is frozen and gated; nothing under `project/` or `tools/` of this
worktree may change (check `git status --short | grep -v '^??'` is empty at END).

## Wall clock (run `date +%H:%M` first and often)
`07:02` launched. **Commit the evidence by `07:45`.** **Report and END by `07:55`.**

## Why
The owner asked for the HUD fix "at the handheld size if the layout has one". It has (`GhostFormLayout.compact()`, picked by
`--device=deck`, 1280x800). The n29-01d call could not render it: `BondFilmCapture._capture`
(`project/dev/ghost-forms/bond_film_capture.gd` line 38) quits on any frame that is not 1920x1080. Read
`evidence/n29-keys/hud.md` sections n29-01b and n29-01d first: 01b says exactly how the 1080p same-tick pair was made
(`bond_film_64.tscn`, seed 1, `--bond-prefill=16`, `--fixed-fps 60`, `GTAI_FILM_FROM/TO` 600..640, snapshot via
`tools/lib/snapshot.mjs`).

## Do
1. Make two throwaway snapshots with `tools/lib/snapshot.mjs` (as 01b did): `c649a15d6` (before) and `HEAD` (after).
   In each SNAPSHOT only (never in this worktree), change line 38's check so the capture accepts the window's own size
   (e.g. `if image.get_size().x < 640:`), so a 1280x800 frame is saved. Say in hud.md that the snapshots carried this one
   dev-only line, and that the product HUD code is the committed one.
2. Render the 01b run in each snapshot with `--device=deck` added, windowed at `--position 0,1440`, d3d12, same seed,
   prefill, ticks. Through the repo's Godot launcher (`tools/dev/run.mjs` with `--` verbatim args, or `runGodot` as 01b
   did); never a bare Godot. Confirm the frame is 1280x800 (or the deck row's size; say which).
3. Pick the same frame index in both (tick ~619). Measure on each: chip 1 plate left x (bar >= 8 px after), every number
   plate inside the strip box (yes/no per plate), caption box vs strip overlap in px (bar 0 after; say "no caption on
   screen" if the bot shows none). Write:
   `C:/Users/kazda/kiro/gtai-masters/n29/keys/hud/hud_handheld_before.png`, `hud_handheld_after.png`,
   `hud_handheld_pair_crop_3x.png` (strip region before | after, 3x nearest). Read each PNG and describe what you see.
4. Add `## n29-01e handheld (snapshots)` to `evidence/n29-keys/hud.md` (command, size, measurements table, paths) and commit
   it alone: `git commit -m "evidence: n29 keys HUD at the handheld size, before and after" -- evidence/n29-keys/hud.md`.
   Add one entry to `C:/Users/kazda/kiro/gtai-masters/n29/keys/frames.json` (keep it at 15 entries at most: replace
   `rag/strips_4x_p55.png`, the last one): `{"file":"hud/hud_handheld_pair_crop_3x.png","title":"HUD at the handheld size
   (deck 1280x800, compact layout): before | after, same tick, 3x","ppm":64,"before":"c649a15d6","note":"<your measurement>"}`
   (ppm as the bond film's own: read it from 01b; correct it if not 64).
5. Remove both snapshots (the tool's own cleanup or `git worktree remove --force` on their paths); delete only what you made.

## Godot
`export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. One Godot at a time.
Take the lane mutex before every Godot step: `(set -o noclobber; echo "handheld $(date +%H:%M)" > build/n29-godot.lock)`
and `rm build/n29-godot.lock` right after the step. A `mem-budget: waiting` line is the machine being full: wait, note minutes.

## Allowlist
`evidence/n29-keys/hud.md`, `C:/Users/kazda/kiro/gtai-masters/n29/keys/hud/**`, `C:/Users/kazda/kiro/gtai-masters/n29/keys/frames.json`,
`build/**`, your snapshots. Any other path: stop and report a NEED. Other lanes' worktrees: never. Banned: amend, rebase,
`git stash`, `git add -A/./-u`, `commit -a`, `reset --hard`. Free only your own processes, by PID; never delete anything in
Temp you did not create. If two routes fail, stop and report; do not loop.

## Report (short), then END
Commands, window size, the measurement table, still paths, commit sha, snapshot cleanup, what you could not do.
