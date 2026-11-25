# Brief n29-01d-hud-handheld: the gauntlet HUD at the handheld size, one still (lane keys, run n29)

Builder for lane `keys`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n29-keys`). Repo law: `AGENTS.md`. No images, no product change.

## Wall clock (run `date +%H:%M` first and often)
`05:31` launched. **Commit the evidence by `05:58`.** **Report and END by `06:08`.**

## Why
Owner: fix the gauntlet HUD (claw prompt over the chip numbers, chip 1 cut by the screen edge) "and at the handheld size if the
layout has one". It has: `GhostFormLayout.compact()` (`project/features/souls/ghost_form_layout.gd`) is picked by the
device profile (`--device=<devices.json id>`, `project/boot/launch_args.gd` line ~112, `devices.json`). The 1080p pair is done
(`evidence/n29-keys/hud.md`); a 1280x800 still was never made: a movie-writer run was refused by the permission system last time.

## Do
1. Find the deck row in `project/data/tables/devices.json`. Render the bond film the same way `evidence/n29-keys/hud.md` (01b
   section) did, adding `--device=<deck id>`, through `node tools/dev/run.mjs <entry> --windowed --position 0,1440 ... -- <verbatim>`
   or the same command the 01b call used (read hud.md for it). If `--write-movie` is refused, use the entry's own frame-capture
   (`GTAI_FILM_FROM/TO`) as 01b did. Get one frame where the chip strip and (if the bot acts) the caption are on screen, at the
   device's window size (1280x800 expected), HEAD only.
2. Before: the same run at `c649a15d6` only if a temp worktree is quick to make (copy `project/native/bin`, `project/.godot`,
   `project/data/generated/city` in; `%LOCALAPPDATA%\Temp\gtai-keys-hh-<sha8>`, removed with `git worktree remove --force` before END).
   Else HEAD only, say so.
3. Measure on the frame: chip 1 plate left edge x (>= 8 px), every plate inside the strip, caption vs strip overlap (0 px).
   Stills: `C:/Users/kazda/kiro/gtai-masters/n29/keys/hud/hud_handheld_after.png` (+ `_before.png`, + a 3x nearest crop of the
   strip `hud_handheld_crop_3x.png`). Look at them (Read the PNG). Add a `## n29-01d handheld` section to `evidence/n29-keys/hud.md`
   and commit it alone: `git commit -m "evidence: n29 keys HUD at the handheld size" -- evidence/n29-keys/hud.md`.
   Add an entry to `C:/Users/kazda/kiro/gtai-masters/n29/keys/frames.json` only if the films builder's frames.json is done
   (`build/n29-films.done` exists); else name it in the report.

## Godot
`export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Godot is shared with the films
builder through the mutex `build/n29-godot.lock`: before EVERY Godot step take it with `(set -o noclobber; echo "handheld $(date +%H:%M)" > build/n29-godot.lock)`
(fails while held: re-try every 60 s; older than 25 min = stale, delete it) and `rm build/n29-godot.lock` as soon as that step ends.
On END delete it if yours and create `build/n29-handheld.done`. Windowed runs `--position 0,1440`, d3d12. Only through repo tools.

## Allowlist
`evidence/n29-keys/hud.md`, `C:/Users/kazda/kiro/gtai-masters/n29/keys/hud/**`, `build/**`, your temp worktree. Everything else read
only (a dev-scene change needed: report a NEED). Banned: amend, rebase, `git stash`, `git add -A/./-u`, `commit -a`, `reset --hard`.
Free only your own processes, by PID; never delete anything in Temp you did not create.

## Report (short), then END
Command used, window size, measurements, still paths, commit sha, what you could not do.
