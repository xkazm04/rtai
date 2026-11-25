# Brief n29-07-held-red-triage: which of the 124 weapon item/held files draw red that breaks the colour law (lane keys, run n29)

Builder for lane `keys`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n29-keys`). Repo law: `AGENTS.md`.

## Wall clock
`{START}` launched. **Commit by `{COMMIT}`.** **Report and END by `{END}`.**

## Why
Owner: "repaint all the red the audit found". The combat lane's re-audit (READ ONLY:
`C:/Users/kazda/kiro/gtai-wt/n23-street/evidence/n29/red/audit.md` row 16, counter `audit_count.py`) counts 77379 reddish px in
124 files: `project/features/combat/weapons/art/held_55/*`, `showcase/{icon,p55,p70,crate}/*`, `<weapon>/held,pickup,mag`
(minus the molotov and plasma sword). Biggest: mini_nuke 6304, rocket_launcher 4534, crate p70 4400, homing_shard 2177,
electro_gun icon 2028, ray_gun p70 2019. Colour law: red is blood only; **vermilion is allowed for danger** (a warhead, a
hazard stripe, a live trigger light); amber for fire, heat and electric current. "Reddish" in their counter includes vermilion.

## What to do (this call triages; it recolours only the plain cases)
1. Per file: reddish px split by hue band: true red / crimson / maroon (hue >= 345 or <= 8, or dark v < 0.45 with hue <= 20)
   vs vermilion (hue 9..24, s > 0.6, v > 0.6). Table `evidence/n29-keys/held_red/table.md` sorted by true-red px.
2. A contact sheet `C:/Users/kazda/kiro/gtai-masters/n29/keys/held_red/contact_4x.png` of the top 20 files by true-red px:
   each file at 4x nearest with its true-red px tinted magenta beside it, labelled.
3. Classify each of those 20: **danger accent** (a warhead, a hazard mark: becomes vermilion by a masked hue shift to the
   collar's vermilion, keeping value/alpha), **heat/fire/current** (to the palette amber #EDAB42), **housing/body paint**
   (maroon / red casing: to steel, hue 218 s 0.10 as the combat lane did with the sword's rings), or **leave** (reason).
   Write the class per file in the table.
4. Recolour only the files whose class is plain (one obvious part, a mask that touches nothing else); prove 0 px changed
   outside the mask per file (json); 4x before | after crops in the same masters dir. `--import`, `test_map.mjs` + mapped
   tests + `run_unit.mjs --changed`. Commit "keys n29: weapon item art red -> law colours (red audit row 16, <n> files)".
   The rest stays for the director with the table.

## Godot
`export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. `{GODOT_RULE}`.
Godot only through repo tools; the pre-commit hook can take 12 min (no shell timeout under 20 min).

## Allowlist (anything else: stop and report a NEED)
The PNGs under `project/features/combat/weapons/art/{held_55,showcase}/**` and `<weapon>/{held,pickup,mag}.png` EXCEPT the
molotov's and the plasma sword's (+ `.import`), a test pin that hashes one of them (that line), `evidence/n29-keys/held_red/**`,
`C:/Users/kazda/kiro/gtai-masters/n29/keys/held_red/**`, `build/**`. Forbidden: effect atlases and fire/muzzle/electric code
(combat's), Rivet's strips, code, `JOURNAL.md`, `REPORT.md`, `docs/decisions.md`, other worktrees. Banned: amend, rebase,
`git stash`, `git add -A/./-u`, `commit -a`, `reset --hard`. Fix lint and format findings in your own edit and go on.

## Report (short), then END
Table path, the 20 classes, files recoloured with px and proofs, commit shas, what is left for the director.
