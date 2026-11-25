# n30 combat call 22: 32 px/m film of the blast cells after the soot fix (evidence only)

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. **Hard clock: commit by 16:18, END by 16:20** (your
session dies ~16:25). If the film is not on disk by 16:14, write nothing, commit nothing, report and END.
Env: `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
No other builder runs; the gate finished. Do not edit any project/ file.

1. `CHAPTERS=rocket_launcher,mini_nuke QUIT=1500 node evidence/n29/red/film.mjs build/n30floorfilm/after.mp4` (same command as
   `evidence/n30/lights/rim_proof.md` `## 32 px/m film (c16)`; before = `C:/Users/kazda/kiro/gtai-masters/n30/combat/films/round_band_32.mp4`,
   same chapters and QUIT, made before the fix).
2. Copy to `C:/Users/kazda/kiro/gtai-masters/n30/combat/films/blast_floor_after_32.mp4`; `ffprobe -v error -select_streams v:0
   -show_entries stream=width,height,r_frame_rate -show_entries format=duration -of csv=p=0 <file>` (quote it).
3. Find the nuke blast floor seconds by diffing frames of before and after (ffmpeg `-ss <t> -frames:v 1`, e.g. every 0.1 s in
   7.8-8.6 s, and 0.9-1.6 s for the rocket); make `C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/blast_floor_32_pair.png`
   (before | after at the second with the most vermilion difference, labelled with the second). LOOK at it: one sentence.
4. Append `## 32 px/m film (c22)` to `evidence/n30/floor/specks.md` (command, ffprobe line, seconds, what you saw). Commit only that
   file: `git add evidence/n30/floor/specks.md && git commit -m "n30 combat c22: blast cells 32 px/m film" -- evidence/n30/floor/specks.md`
   (end the message with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`; never skip the hook, no amend).
Do NOT edit frames.json (the director does). Report: ffprobe line, seconds, what you saw, commit hash.
