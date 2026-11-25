# Brief n29-05-molotov-rag: the molotov's lit rag from red to amber in keys' held art (lane keys, run n29)

Builder for lane `keys`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n29-keys`). Repo law: `AGENTS.md`.

## Wall clock (run `date +%H:%M` first and often)
`03:48` launched. **Commit by `04:30`.** **Report and END by `04:48`**, committed or not; never end with finished,
passing work uncommitted.

## Why
The owner: "repaint all the red the audit found". Colour law: red is blood only; amber is fire and heat. The n28 red audit
(`C:/Users/kazda/kiro/gtai-wt/n23-street/evidence/n28/red/audit.md` row 12, READ ONLY: another lane's worktree) found the
molotov's lit rag drawn red on the held art (audit names `weapons/art/molotov/held.png`, `pickup.png`, `held_55/molotov.png`;
the tree today has `project/features/combat/weapons/art/held_55/molotov.png`, `showcase/{icon,p55,p70}/molotov.png` and
the bottle is also drawn inside Rivet's strips `p55|p70/rivet_eq_molotov{,_left}.png` and `p70/rivet_walk_eq_molotov.png`).
The combat lane owns the fire effects and `rag_light.gd`; the weapon held art is keys'. Combat wrote `NEED keys` for it.

## Method (deterministic, no image tool, 0 images)
Use the combat lane's hue remap exactly (copy, do not edit theirs):
`C:/Users/kazda/kiro/gtai-wt/n23-street/evidence/n29/red/recolour.py` -> `evidence/n29-keys/rag/recolour_rag.py`: a pixel
moves when it is reddish (R>170, G<110, B<90, or HSV hue 345..25 deg with S > 0.35) and keeps alpha, max and min channel,
hue moved to amber #EDAB42 (36.8 deg). **But mask it to the rag flame only**: Rivet's hazard collar is vermilion by law and
sits in the same strips; the bottle's glass/label may be reddish too. Restrict each file to the flame's region (the
reddish connected blobs that touch the bottle's neck/rag, found per cell, or a hand-checked box per cell from the
bottle's position) and **prove the collar unchanged**: hash or count the pixels outside the rag mask, before vs after =
0 changed. Find first which of the files above actually draw a red rag (count reddish px inside the bottle region per
file and cell); change only those. List every file: reddish rag px before -> after, px changed outside the mask (must be 0).

## Checks
`export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Godot is shared with the Gloria builder through a mutex: before EVERY Godot step (an --import, a run_unit run, a capture, a film, and every git commit because the pre-commit hook runs Godot) take the lock with `(set -o noclobber; echo "rag $(date +%H:%M)" > build/n29-godot.lock)` (it fails while the other builder holds it: re-try every 60 s; a lock older than 25 min is stale, delete it), and `rm build/n29-godot.lock` as soon as that step ends. Never hold it while image jobs run. When you END, delete the lock if it is yours and create `build/n29-rag.done`.
Godot only through repo tools (`run_unit.mjs`, `tools/godot/check.mjs`, `tools/dev/run.mjs`, the film tools); d3d12;
windowed `--position 0,1440`; `mem-budget: waiting` = machine full. `--import` (PNGs changed);
`node tools/tests/test_map.mjs <each changed png>` and run what it maps (`run_unit.mjs --select=...`) plus
`node tools/tests/run_unit.mjs --changed`; watch for tests/goldens that hash these PNGs or count accent pixels (re-pin only
what is a pure hash of a file you changed, and say which). Commit:
`git add <paths>` + `git commit -m "keys n29: the molotov's lit rag drawn amber, not red (red audit row 12)" -- <paths>`.
Banned: amend, rebase, `git stash`, `git add -A/./-u`, `commit -a`, `reset --hard`. Fix lint and format findings in your
own edit and go on. Hook failing only on `tools/film/kill_reel_*.break.test.mjs` / `tools/merge/clash.test.mjs`:
`--import`, commit again once; never skip it (it can take 12 min: no shell timeout under 20 min).

## Evidence (separate commit)
A 4x nearest crop before | after of each changed file's bottle (`C:/Users/kazda/kiro/gtai-masters/n29/keys/rag/rag_cells_4x.png`)
and one in-game 64 px/m still of Rivet holding the lit molotov, before | after (same scene, same tick:
`node tools/dev/run.mjs <scene>`; find a take that shows Rivet with the molotov in hand: arena / showcase under
`project/dev/`, `tools/film/arsenal_turn.mjs`; the "before" from a temp worktree at `c649a15d6`, or the n28 frames in
`C:/Users/kazda/kiro/gtai-masters/n28/keys/` if one shows it at the same zoom: say which). `evidence/n29-keys/rag.md`
(files, px table, outside-mask 0 proof, stills). Commit: "keys n29: molotov rag evidence".

## Allowlist (anything else: stop and report a NEED)
The molotov PNGs named above that draw the rag (+ their `.import` if Godot rewrites them), `evidence/n29-keys/rag/**`,
`evidence/n29-keys/rag.md`, `C:/Users/kazda/kiro/gtai-masters/n29/keys/rag/**`, `build/**`, and a test pin that hashes one
of those PNGs (only that line). Forbidden: `rag_light.gd` and every fire effect (combat's), the cop/swat molotov torch
strips (cast's), other weapons' art, the sword/Gloria round dirs, code, the HUD files, `project/features/souls/**`,
`project/boot/prologue/**`, `native/`, `JOURNAL.md`, `REPORT.md`, `docs/decisions.md`, the other lanes' worktrees (read only).

## Report (short), then END
Files changed with px table, outside-mask proof, commit shas, still paths, what you could not do.
