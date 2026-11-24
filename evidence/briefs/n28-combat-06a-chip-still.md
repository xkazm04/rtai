# Brief n28-combat-06a: a true 64 px/m still of the bond chip strip

Lane `combat`, branch `n28-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP 19:22 (wall clock): report and END, even mid-task.** Small job: one still, one frames.json fix, one commit.

## Why
`C:/Users/kazda/kiro/gtai-masters/n28/combat/stills/bond_chips_64.png` is listed in `frames.json` as 64 px/m, but it is a
32 px/m gameplay frame (Rivet ~32 px/m scale; the chip strip is tiny at the lower left and chip "1" is clipped by the
screen edge). The owner judges by these: the label must be true.

## What
1. Render a real 64 px/m frame with Tonnage's ring partly filled: `evidence/n28/bond/render_bond.mjs` already knows a
   64 path (`res://dev/ghost-forms/bond_film_64.tscn`); read it and use it (seed 1, prefill 16 or what gives a part-filled
   ring by the frame you pick). `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe GTAI_GODOT_EST_MB=1000` first. Renders go through runGodot only.
   Note: the HUD is drawn at screen scale, so a 64 px/m world zoom may not enlarge the chips. If it does not, ALSO write
   `stills/bond_chips_crop_3x.png`: a 3x nearest-neighbour crop of the chip strip from the frame, and say so in the note.
2. Read the PNG(s) yourself: Tonnage's ring part-filled, numbers 1 to 4 readable, chip 1 not clipped (if it is clipped in
   the game itself, say so: that is a finding for the owner, do not fix it).
3. Replace `stills/bond_chips_64.png` with the true 64 frame (keep the old one as `stills/bond_chips_32.png`) and fix the
   two entries in `C:/Users/kazda/kiro/gtai-masters/n28/combat/frames.json` (read, edit, write valid JSON; keep the others).
4. If you changed `render_bond.mjs`, commit it alone (stage per path; never touch root JOURNAL.md/REPORT.md).

Repo law: AGENTS.md; one Godot at a time; d3d12 for renders; windowed only at `--position 0,1440`; no amend/rebase/push.

## Report and END
Paths, ppm truth, what the chips look like, whether chip 1 is clipped in the game.
