# n30 combat call 24: write the 32 px/m film section into specks.md (evidence only, no Godot)

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. **Commit by 16:55, END by 17:00.** No Godot runs.

## Do
1. Append to `evidence/n30/floor/specks.md` a section `## 32 px/m film (c22)` with exactly these facts (the c22 builder
   rendered the film; its Bash was denied before it could write this):
   - Command: `CHAPTERS=rocket_launcher,mini_nuke QUIT=1500 node evidence/n29/red/film.mjs build/n30floorfilm/after.mp4`
     at HEAD `93d37aea1`; copied to `C:/Users/kazda/kiro/gtai-masters/n30/combat/films/blast_floor_after_32.mp4`.
   - ffprobe: h264, 1920x1080, 60/1, 25.000000 s. Before = `films/round_band_32.mp4` (same chapters, QUIT 1500, before c18).
   - Whole-frame vermilion px (`r - max(g,b) >= 79` of 255): 8.3 s (nuke floor) 2149 -> 491; 1.3 s (rocket) 324 -> 252;
     every other sampled second within +-40 (blood, props).
   - Seen at 8.3 s (`stills/blast_floor_32_pair.png`): the thin orange-red outline along the burst's amber edge is gone; the
     edge reads ink/soot; subtle at 32 px/m.
   Verify first that both mp4 files and the still exist (`ls`); if one is missing, write what exists and say so.
2. Commit only that file: `git commit -m "evidence: n30 combat c22 blast floor 32 px/m film numbers" -- evidence/n30/floor/specks.md`
   ending with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Never skip the hook (it may take ~12 min); no
   amend, rebase, stash, add -A. Another builder (c23) may commit `nuke_shell.png` and `evidence/n30/rounds/**` meanwhile:
   never stage or restore those. Touch no other file.

## Report and END
The commit hash or what failed.
