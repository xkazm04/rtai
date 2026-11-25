# n30 combat call 16: the nuke blast at 32 px/m with the rim patch applied (after film only), restored at once

Worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n30-combat`. **Hard clock: patch reversed by 15:07 whatever happens,
evidence committed by 15:10, END 15:12** (the parent session dies at 15:15).
Env before Godot: `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot at a time: no file in `$LOCALAPPDATA/gtai/runs/*.json` may name `n23-street` before you launch.

## Do
1. `git apply evidence/n30/lights/rim.patch` (it applies clean on HEAD). Then the same film the "before" used
   (`evidence/n30/rounds/band.md` line 26): `CHAPTERS=rocket_launcher,mini_nuke QUIT=1500 node evidence/n29/red/film.mjs build/n30rimfilm`
   (read film.mjs first for where the mp4 lands). If the film tool needs a class-cache import first, it does that itself.
2. The moment the film process exits (or at 15:07), reverse: `git apply -R evidence/n30/lights/rim.patch`; if that fails,
   `git checkout -- <each modified path>` and delete `project/tests/unit/test_light_pool_rim.gd` and its `.uid`. Prove with
   `git status --short` that no `project/` path is modified or untracked.
3. Copy the mp4 to `C:/Users/kazda/kiro/gtai-masters/n30/combat/films/explosion_rim_after_32.mp4`; `ffprobe` it (width, height,
   r_frame_rate, duration). Extract the frame at the nuke blast (the before film `films/round_band_32.mp4` has it at ~12 s; take the
   same second from both, e.g. `ffmpeg -ss 12.2 -i ... -frames:v 1`) into `build/n30rimfilm/` and LOOK at both: one sentence.
4. Append to `evidence/n30/lights/rim_proof.md` a `## 32 px/m film (c16)` section: command, ffprobe line, the before film it pairs
   with (`films/round_band_32.mp4`, same chapters and QUIT), what you saw. Commit only that file:
   `git commit -m "n30 combat: rim patch 32 px/m after film (patch reversed)" -- evidence/n30/lights/rim_proof.md`, trailer
   `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Do not edit frames.json. No stash, amend, add -A. Never commit a
   `project/` path.

## Report and END
ffprobe line, what you saw, `git status --short` after the reverse, commit hash.
