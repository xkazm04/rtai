# Brief n29-combat-02d-red-sword: the plasma sword's hilt rings from red to steel (red audit row 15)

Lane `combat`, branch `n29-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadline: see "Wall clock" at the end (binding). At the hard stop write your report and END, even
mid-task.** Never stop to ask: at a fork pick what best serves the owner's words, write it in your report, go on. Fix lint
and format findings in your own edit and go on. No amend, no rebase, no push. Read `AGENTS.md` (repo law) first, briefly.

## Why (owner, 2026-11-25)
"The plasma sword's hilt rings to steel." Audit `evidence/n28/red/audit.md` row 15: two orange-red rings on the grip in
`project/features/combat/weapons/art/plasma_sword/held_long.png` (378 reddish px), `held.png` (287), `pickup.png` (296),
`held_55/plasma_sword.png` (224), showcase variants (421-483). Seen in
`C:/Users/kazda/kiro/gtai-masters/n28/combat/stills/deflect_blade_after_64_crop.png` (92 px there). Only the rings
change: the blade, glow and everything else stay byte-identical.

## What
A. **Before still first**: the n28 deflect blade take at 64 px/m (`evidence/n28/deflect/`, the commands in
   `docs/day/2026-11-25/n28-combat/JOURNAL.md`; e.g. `build/dev/n28-deflect.mjs` if it still exists, or the pressure
   `blade6` take) at a tick where the hilt is visible, + crop: `stills/red_sword_before_64.png` under
   `C:/Users/kazda/kiro/gtai-masters/n29/combat/`. Command + tick into `evidence/n29/red/sword.md`.
B. **Repaint** by a deterministic recolour of the ring pixels only (a mask: the reddish band of
   `evidence/n29/red/recolour.py` restricted to the hilt region of each file; print the bounding box per file) to steel:
   the same value, saturation near 0, a faint cool tint (about `#8a9099` at mid value), keeping alpha and the ink
   outline. Files: the plasma sword's `held_long.png`, `held.png`, `pickup.png`, `held_55/plasma_sword.png`, and the
   showcase `icon/p55/p70` plasma sword files the audit counts (find them by `count_red.py`). Check first that a
   red-band pixel outside the hilt (the blade's plasma? a label?) is NOT moved: list what the mask leaves. Godot
   `--import`, `test_map.mjs` + mapped tests, `run_unit.mjs --changed`, re-pin only pure consequences. Commit B with
   ONE `docs/decisions.md` line `- [2026-11-25] DECISION n29 combat: plasma sword hilt rings repainted red -> steel (held_long, held, pickup, held_55, showcase) by a masked deterministic recolour; red audit row 15; the blade untouched.`
   Rivet's walk/run sheets that carry the sword (keys' `rivet_*` art) may show the rings too: do not touch them; list
   which ones do for a `NEED keys` line.
C. **After still** at the same tick, pair `red_sword_pair_64.png` (before left), px before -> after per file and crop in
   `evidence/n29/red/sword.md`. LOOK at it. A 32 px/m clip 1920x1080 60 fps 15-40 s of the sword in a fight
   (`films/red_sword_after_32.mp4`, ffprobe), frames.json entries (re-read before writing). Commit C.

## Repo law, allowlist
As `evidence/briefs/n29-combat-02a-red-fire.md` "Repo law" (APPDATA, GODOT_BIN, est MB, d3d12, `--position 0,1440`, one
Godot for the lane, quick gate + ~12 min hook, banned git verbs, trailer `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`).
Allowlist: the plasma sword PNGs named in B (+ `.import`), `evidence/n29/red/**` (a masked mode in `recolour.py` that
leaves its other results unchanged), pure-consequence re-pins under `project/tests/**` / `art_src/*manifest*`,
`docs/decisions.md` (one line), `build/**`, `C:/Users/kazda/kiro/gtai-masters/n29/combat/`. Forbidden: every other PNG
(other held/pickup/icon art and `rivet_*` sheets are keys'), tables, code, other worktrees, root `JOURNAL.md` / `REPORT.md`.

## Report and END (short)
Commits; mask boxes and px table; pair/film paths + ffprobe; how it reads; gates; NEED keys list; what was left.
