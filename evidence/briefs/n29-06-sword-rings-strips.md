# Brief n29-06-sword-rings-strips: the plasma sword's copper hilt rings to steel in Rivet's strips (lane keys, run n29)

Builder for lane `keys`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n29-keys`). Repo law: `AGENTS.md`.

## Wall clock (run `date +%H:%M` first and often)
`{START}` launched. **Commit by `{COMMIT}`.** **Report and END by `{END}`**, committed or not; never end with passing work uncommitted.

## Why
Owner (n28 verdicts): "the plasma sword's hilt rings to steel". The combat lane recoloured the rings in the weapon's own held
art (`85c6b0c53` in `C:/Users/kazda/kiro/gtai-wt/n23-street`, READ ONLY: rings = hue <= 24 or >= 345, s > 0.5, v > 0.45,
connected parts >= 25 px + 1 px fringe -> hue 218 s 0.10, value and alpha kept; script
`C:/Users/kazda/kiro/gtai-wt/n23-street/evidence/n29/red/recolour.py`, copy it, never edit theirs) and wrote NEED keys
(their audit row 15): Rivet's own strips that draw the sword in his claw still carry copper/red rings:
`project/features/characters/art/view/{p55,p70}/rivet_eq_plasma_sword{,_left,_left_strike,_left_windup,_windup}.png`,
and check the new n29 sheets `p70/rivet_walk_eq_plasma_sword.png`, `p70/rivet_run8_eq_plasma_sword.png` too.

## Method (deterministic, 0 images)
1. Count per file and per cell the pixels the ring rule catches. **Rivet's hazard collar is vermilion by law and sits in the
   same cells**: the mask must exclude it. Build the mask from the ring rule AND the sword's region only (the connected
   blobs that touch the hilt / grip, away from the neck; or per cell the part nearest the claw's hilt end). Prove: pixels
   changed outside the ring mask = 0 per file (script, json), and the collar region (the neck band's pixels) byte-identical.
2. Look at a 4x nearest crop of every changed cell before | after (`C:/Users/kazda/kiro/gtai-masters/n29/keys/sword_rings/rings_cells_4x.png`):
   rings read steel, blade amber unchanged, collar untouched. A file where the rule cannot separate rings from collar: leave
   it and say so.
3. `--import`, `node tools/tests/test_map.mjs <each png>`, run what it maps + `node tools/tests/run_unit.mjs --changed`;
   re-pin only a pure hash of a file you changed. Commit "keys n29: the plasma sword's hilt rings drawn steel in Rivet's strips".
4. Evidence (separate commit): one in-game 64 px/m still before | after of Rivet holding the sword (same scene, same tick;
   "before" from a temp worktree at the base commit, or swap the old PNGs in a scratch copy), `evidence/n29-keys/sword_rings.md`
   (file px table, outside-mask proof, stills).

## Godot
`export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. `{GODOT_RULE}`.
Godot only through repo tools; d3d12; windowed `--position 0,1440`; `mem-budget: waiting` = machine full. The pre-commit hook
can take 12 min: no shell timeout under 20 min; hook failing only on `tools/film/kill_reel_*.break.test.mjs`: `--import`, commit again.

## Allowlist (anything else: stop and report a NEED)
The `rivet_eq_plasma_sword*`, `rivet_walk_eq_plasma_sword`, `rivet_run8_eq_plasma_sword` PNGs (+ `.import`),
`steam/ai-provenance/2026-11.jsonl` (append only, if a provenance line pins the hash), a test pin that hashes one of those PNGs
(that line only), `evidence/n29-keys/sword_rings/**`, `evidence/n29-keys/sword_rings.md`,
`C:/Users/kazda/kiro/gtai-masters/n29/keys/sword_rings/**`, `build/**`. Forbidden: the weapon's own art under
`project/features/combat/**` (combat's), code, other weapons, `JOURNAL.md`, `REPORT.md`, `docs/decisions.md`, other worktrees.
Banned: amend, rebase, `git stash`, `git add -A/./-u`, `commit -a`, `reset --hard`. Fix lint and format findings in your own
edit and go on. Free only your own processes, by PID; never delete anything in Temp you did not create.

## Report (short), then END
Files with px table, outside-mask and collar proof, commit shas, still paths, what you could not do.
