# n30-08 collar-install: install the 4 leftover cells, fix 4 shipped row 6 visors, in-game proof (lane keys, 0 images)

**Commit the install within 20 minutes of launch, report and END within 40** (`date +%H:%M` first; write both deadlines in your
first line). Work in `C:/Users/kazda/kiro/gtai-wt/n23-controls` (branch `n30-keys`). Same law, Godot rules, lock (tag `n30-08`)
and allowlist as `evidence/briefs/n30-04-collar-cells.md` (read it; it binds this call). **No image generation.** You hold the
lane's only Godot this call (no other builder runs Godot meanwhile).

## Where it stands
Round `C:/Users/kazda/kiro/gtai-art/rivet-n30/collar_cells/`, `STATE.md` NEXT 1-5 (n30-06). Ready: `comp/install_n3006.png`
(sha e94deb4e: HEAD's sheet + r7c3, r7c4, r6c2, r6c6, accepted by n30-06 and by the director on its report), `comp/n3006_prov.jsonl`,
`comp/n3006_table.md`. Worktree sheet = HEAD (ba3e1d97); check both shas before you start.

## Do
1. STATE NEXT 1-4 exactly: install, `--import` (`.import` unchanged), the in-game harness after-run (`scripts/godot_row.sh`), the frame
   diff against `runs/r67_after_64` (only r6c6's tick 448 in the neck window may differ), provenance line, `node tools/gate/quick.mjs`,
   commit `art(keys n30): p55 sprint collar leftovers (cells 7.3 7.4 6.2 6.6)`, append the table to `evidence/n30-keys/collar_cells.md`.
2. NEXT 5: re-composite the shipped r6c3, r6c5, r6c7, r6c8 from their accepted raw edits (in `out/`) with `CELL_PROTECT` visor boxes,
   so their visor/frame px equal the shipped-before-n30 pixels (0 visor px changed) and the collar stays as accepted (look at a 4x
   before/after of each). Proof as always (0 outside mask, alpha identical, other cells bit-identical). Install, `--import`, one
   after-run + diff, provenance, quick gate, commit `art(keys n30): p55 collar row 6 cells keep their visor (protect boxes)`.
3. Regenerate `C:/Users/kazda/kiro/gtai-masters/n30/keys/collar/row6_4x.png`, `row7_4x.png` from the final sheet and an in-game
   `row67_64_ingame_final.png` (before = HEAD 5114a4441's sheet run `runs/n3004_before_64`, after = final) and add it to
   `C:/Users/kazda/kiro/gtai-masters/n30/keys/frames.json` (keep the other entries). Commit the md.

## Report (short), then END
Commit shas, the diff numbers, visor px per cell before/after, stills, STATE Next.

## Update 12:35 (director, session 2): NEXT 1 is already running from n30-06's leftover chain
At 12:21 n30-06's waiting `godot_row.sh` took the lock after all (lock `build/n30-godot.lock` = `n30-06 61601 12:21:26 n3006_after_64`),
installed `comp/install_n3006.png` into the worktree (sheet sha e94deb4e now, uncommitted) and at 12:27 started the harness
run `runs/n3006_after_64` (python run_hands.py pid 48900 -> node 29044 -> Godot 39296/25980). **Do not start a second Godot
while it lives.** Wait (poll every 30 s, `tasklist`/`Get-CimInstance` by PID) until pid 29044 has exited, check the run is
complete (godot.log ends cleanly, 0 SCRIPT ERROR, the stills exist), and if the chain left the lock behind and pid 61601 is
dead, the lock is now yours: rewrite it with tag `n30-08` + your pid. If the run is incomplete, re-run it yourself. Then go on
from NEXT 2 (`ingame.py`). `.import`: check `git diff` shows only the png.
A second builder `n30-09` (molotov run step, files `p70/rivet_run8_eq_molotov.png`, `rivet_motion.json`) shares the lane lock:
take the lock per Godot run and release it right after each run (never hold it across your own thinking or editing); when
you wait more than 10 min, write it in STATE and go on with offline steps. Your commit deadline is 13:05, END 13:25.
