# Brief n29-15-gloria-p55-flash-ingame: Gloria firing at p55 in the game, all 8 octants, 64 px/m (lane keys, run n29)

Builder for lane `keys`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n29-keys`). Repo law: `AGENTS.md`.
**Evidence only.** The lane is frozen and gated; nothing under `project/` or `tools/` of THIS worktree may change (check
`git status --short | grep -v '^??'` is empty at END). Any dev-only edit you need goes in a throwaway SNAPSHOT
(`tools/lib/snapshot.mjs`, as `evidence/n29-keys/hud.md` sections n29-01e and n29-14 did) and is described in the evidence.

## Wall clock (run `date +%H:%M` first and often)
`07:17` launched. **Commit the evidence by `07:58`.** **Report and END by `08:15`.**

## Why
`9efd28136` re-seated Gloria's p55 diagonal held strips (pad14, `HELMET_X` p55/gloria, p55 diag muzzle rows, flash scale
1.0). The only proof so far is a sheet composite (`gtai-masters/n29/keys/gloria/p55_diag_flash_64.png`): no in-game frame,
because `project/dev/rivet_arsenal/arsenal_turn.gd` (`--weapon --pitch --ppm --out`, recorder `arsenal_turn_rec.gd`)
does not fire Gloria (read `evidence/n29-keys/` notes on gloria first: `grep -rn "diag\|arsenal_turn" evidence/n29-keys/`).

## Do
1. Read `arsenal_turn.gd`, `arsenal_turn_rec.gd` and find why Gloria does not fire (not in the arsenal list? the recorder
   never pulls the trigger? no p55 shot frame?). Try the plain run first in THIS worktree (no edits):
   `node tools/dev/run.mjs` cannot pass `--rendering-driver`, so use `runGodot` as hud.md n29-01e did, e.g.
   `--rendering-driver d3d12 --position 0,1440 -s res://dev/rivet_arsenal/arsenal_turn.gd -- --weapon=gloria --pitch=p55
   --ppm=64 --out=<abs build dir>`. If it already shows the muzzle flash at the diagonals: no snapshot needed.
2. Otherwise make a snapshot of HEAD and the SMALLEST dev-only edit there (in `project/dev/**` only) that makes the recorder
   fire Gloria at each octant at p55, 64 px/m. Run the same with `--weapon=pistol` as the reference.
3. Compose `C:/Users/kazda/kiro/gtai-masters/n29/keys/gloria/p55_flash_ingame_64.png`: 2 rows (Gloria | pistol) x the 8
   octants, the frame where the flash is on, cropped around Rivet, 2x nearest. Read the PNG yourself and say per diagonal
   octant (1, 3, 5, 7): flash whole (not clipped), flash at the muzzle tip (offset in px from the barrel end), gun brass,
   body in place. Bars: 0 clipped flashes; muzzle offset <= 3 px at 64 px/m. Colour law: flash amber, no red.
4. Append `## n29-15 Gloria p55 flash in game` to `evidence/n29-keys/gloria.md` (create it if missing: then also say so;
   if the Gloria notes live in another `evidence/n29-keys/*.md`, append there): commands, the snapshot edit (diff lines),
   the table, the still path. Commit only that file:
   `git commit -m "evidence: n29 keys Gloria p55 flash in game" -- <that md>` (stage per path; the hook may take minutes).
5. Add one entry to `C:/Users/kazda/kiro/gtai-masters/n29/keys/frames.json` replacing `gloria/p55_diag_flash_64.png` (keep
   15): `{"file":"gloria/p55_flash_ingame_64.png","title":"Gloria firing at p55 in game, 8 octants, beside the pistol, 64
   px/m","ppm":64,"before":"","note":"<your measurements>"}`. Remove your snapshot and scratch; delete only what you made.

## Godot
`export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. One Godot at a time.
Lane mutex before every Godot step: `(set -o noclobber; echo "gflash $(date +%H:%M)" > build/n29-godot.lock)`, and
`rm build/n29-godot.lock` right after. `mem-budget: waiting` = machine full: wait, note minutes. Windows at `--position 0,1440`.

## Allowlist
THIS worktree: `evidence/n29-keys/*.md` (one file, appended), `build/**`. `C:/Users/kazda/kiro/gtai-masters/n29/keys/gloria/**`
and its `frames.json`. Your snapshot. Any other path: stop and report a NEED. Other lanes' worktrees: never. Banned: amend,
rebase, `git stash`, `git add -A/./-u`, `commit -a`, `reset --hard`, any product edit here. Free only your own processes,
by PID; never delete anything in Temp you did not create. **If two routes fail (e.g. the plain run and one snapshot edit),
stop, commit a short note of what you found, and report.** Never fake a frame: every image comes from a Godot render.

## Report (short), then END
Route taken, commands, the per-octant table, still path, commit sha, snapshot cleanup, what you could not do.
