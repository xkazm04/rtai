# n29 combat call 11: the card-foe kill at 32 px/m as clips, before | after (film only, no product change)

Wall clock: started 07:34. Before arm rendered and `git status` clean again by 07:55. Pair clip done by 08:12.
Hard stop 08:18: report and END. Nothing to commit except one line appended to `evidence/n29/kills/card_scale.md`.

## Goal
Call 7 made `C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/card_kill_pair_64.png` (Mulroney killed by the
machine pistol: before = `kill_fall_cells.gd` of 49befa075, after = HEAD; fallen body 61x47 -> 69x53). The owner judges by
films: make the same kill as 32 px/m clips, before and after, and one side-by-side clip.

## How (read `evidence/n29/kills/card_scale.md` lines 60-90 first: the exact commands and traps)
- Every shell: `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/combat` and
  `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`.
- One Godot for this lane: nothing else of ours is running (the gate finished at 07:31). Check with
  `tasklist //FI "IMAGENAME eq Godot*"` before you start; other lanes' Godots are fine, never kill any process you did not start.
- AFTER arm (HEAD): `node tools/film/kill_reel.mjs --out=build/n29/cardkill32/after --weapons=machine_pistol --ppm=32 --dirs=90 --clips -- --controls=legacy --foe-mix=sergeant_mulroney`
  (`--controls=legacy` is required or nothing dies).
- BEFORE arm: `--before=<commit>` does NOT work here (49befa075 lacks the lab's gun `--foe-mix` of 88140e5b1). Do as call 7 did:
  `git show 49befa075:project/features/combat/kills/kill_fall_cells.gd > project/features/combat/kills/kill_fall_cells.gd`, run the
  same command with `--out=build/n29/cardkill32/before`, then IMMEDIATELY `git checkout HEAD -- project/features/combat/kills/kill_fall_cells.gd`
  and confirm `git status --short` shows no tracked change. If the reel tool refuses a dirty tree, read its message and use
  the flag it names for that (do not commit the old file, ever). Render the before arm FIRST so the tree is clean early.
- Copy the two clips to `C:/Users/kazda/kiro/gtai-masters/n29/combat/films/card_kill_{before,after}_32.mp4` and build
  `films/card_kill_pair_32.mp4` with ffmpeg hstack (before left; scale each to 960 wide, 1920x540 or keep 1080 height
  as 1920x1080 with pad; drawtext labels are optional). Check every clip with `ffprobe` (resolution, fps, duration);
  the owner wants 1080p60 for the single clips where the tool allows it; report what it produced if not.
- LOOK at one frame of the pair clip after the kill (ffmpeg -ss <t> -frames:v 1 to build/n29/cardkill32/look.png and Read it):
  is the fallen body visibly larger on the right? Say what you see.
- Append to `C:/Users/kazda/kiro/gtai-masters/n29/combat/frames_all.json` one entry for the pair clip (keys `file`, `title`,
  `ppm` 32, `before` "49befa075 kill_fall_cells.gd", `note`). Do NOT edit `frames.json`.
- Append ONE line to `evidence/n29/kills/card_scale.md` (commands, clip paths, durations) and commit only that file:
  `git add -- evidence/n29/kills/card_scale.md` then `git commit -m "n29 kills: card kill clips at 32 px/m" -- evidence/n29/kills/card_scale.md`
  with trailer `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Allowlist
Write: `build/n29/cardkill32/**`, the masters files named above, `evidence/n29/kills/card_scale.md`, and the temporary
overwrite + restore of `kill_fall_cells.gd` described above (never committed). Any other path: stop and report a NEED.
Never stash, amend, rebase, `reset --hard`, `git add -A/./-u`. Other lanes' worktrees are forbidden. Fix lint/format findings
in your own edit and go on.

## Report (short)
Commands run, exit codes, clip paths with ffprobe numbers, what you saw, `git status --short` at the end, the commit hash.
If the kill does not happen or a run fails twice, stop, restore the file, report, END.
