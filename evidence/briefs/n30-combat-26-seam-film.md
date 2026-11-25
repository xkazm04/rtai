# n30 combat call 26: 32 px/m film of the nuke round after the soot seam (evidence only)

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`, HEAD has `b0fcfedf5` (nuke_shell.png soot seam).
**Commit by 17:30, END by 17:35.** Check `date +%H:%M` at start. No product file changes.
Env before Godot: `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
You are the only Godot user of this worktree now. Godot only through the shipped tools.

## Do
1. Film: `CHAPTERS=rocket_launcher,mini_nuke QUIT=1500 node evidence/n29/red/film.mjs build/n30seamfilm/after.mp4` (the same
   command as `films/round_band_32.mp4` and `films/blast_floor_after_32.mp4`; read film.mjs for how it runs). Copy to
   `C:/Users/kazda/kiro/gtai-masters/n30/combat/films/nuke_seam_32.mp4`. `ffprobe -v error -select_streams v:0
   -show_entries stream=codec_name,width,height,r_frame_rate -show_entries format=duration -of csv=p=0 <file>`: quote it
   (bar: 1920x1080, 60/1, 15-40 s).
2. Find the seconds where the nuke round is in flight (before the blast at ~8.0 s; step through 6.0-8.1 s in 0.1 s with
   ffmpeg frame grabs of after AND before = `C:/Users/kazda/kiro/gtai-masters/n30/combat/films/blast_floor_after_32.mp4`,
   which has the HEAD-before-seam round). Count vermilion px (`r - max(g,b) >= 79` of 255) inside the round's crop in both
   at 2-3 in-flight seconds. Make a before | after still of the round at the best second, cropped and upscaled 6x nearest,
   labelled: `C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/nuke_seam_32_pair.png`. LOOK at it. If the round is too
   small to judge at 32 px/m, say so plainly with the numbers.
3. Append `## c26 32 px/m film` to `evidence/n30/rounds/band.md` (command, ffprobe line, seconds, counts, what you saw).
   Commit only that file: `git commit -m "evidence: n30 combat c26 nuke seam 32 px/m film" -- evidence/n30/rounds/band.md`,
   message ending `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Never skip the hook; no amend, rebase, stash,
   add -A. Do not edit frames.json, JOURNAL.md, REPORT.md, docs/decisions.md. Delete `build/n30seamfilm/` scratch frames
   you do not cite (keep the mp4).

## Report and END
ffprobe line, seconds, counts, what you saw, the commit hash, what you could not do.
