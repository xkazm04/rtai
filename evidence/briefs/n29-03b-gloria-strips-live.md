# Brief n29-03b-gloria-strips: Gloria's p55 held strips in brass + the left p70 strip's muzzle (lane keys, run n29)

Art builder for lane `keys`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n29-keys`). Repo law: `AGENTS.md`.

## Wall clock (run `date +%H:%M` first and often)
`04:15` launched. **Commit by `04:52`.** **Report and END by `05:05`**, committed or not; never end with finished,
passing work uncommitted. Keep the round's `STATE.md` current.

## The owner's pick
Gloria's 55 degree held strips in brass (today p55 still carries n27's compact gun: only p70 went brass in n28), and the
left p70 strip's cells 2 and 3 widened: there the muzzle is clipped flat by the cell edge.

## Route
- Read `C:/Users/kazda/kiro/gtai-art/rivet-n28/gloria-brass/STATE.md` whole (how the p70 brass strips were made: one
  image edit per strip of the pistol's noflash strip with the concept crop as image 2, cut, `install.py`, flash pasted,
  muzzle re-measured in `rivet_muzzle.json`), and the n27 p55 round it names.
- p55: one image edit per strip (main, diag, left) of the **p55 pistol strips** (`p55/rivet_eq_pistol_noflash.png`,
  `_diag_noflash`, `_left`) with the **n28 p70 brass cells** as image 2 (the gun exactly as drawn there, scaled to p55);
  then the flash/noflash pairs, `held_55` if the p55 held art reads from them, and `rivet_muzzle.json` p55 gloria rows
  re-measured. At most 5 images. Bars: brass median hue 35-45 deg like p70, one claw holds it, the other free,
  every non-gun pixel within the pistol strip's (IoU >= 0.90 outside the gun), no red, no teal, flash amber/yellow.
- p70 left strip `p70/rivet_eq_gloria_left.png` (573x170) and its flash/noflash twins: widen cells 2 and 3 so the muzzle is
  whole. First check whether the muzzle exists in the image source (`gtai-art/rivet-n28/gloria-brass/out/` or `p70/`): if
  the source has it, re-cut with wider cells (no new image); if the source is clipped too, one image edit of that strip.
  Widening cells changes the strip's cell width: find every reader (`weapon_art.json`, `rivet_muzzle.json`, the held-art
  code) and keep it consistent; if a code change outside this allowlist is needed, stop and report a NEED. Bar: the muzzle's
  outline closes inside the cell (0 opaque px on the cell edge column in cells 2, 3).

## Checks and commit
`--import`; provenance appended to `steam/ai-provenance/2026-11.jsonl`; `node tools/tests/run_unit.mjs --changed`;
`node tools/gate/quick.mjs`; commit each part separately (`keys n29: Gloria's p55 held strips in brass`,
`keys n29: Gloria's left p70 strip keeps the whole muzzle`) with `git add <paths>` + `git commit -m ... -- <paths>` incl.
`.png.import`. Banned: amend, rebase, `git stash`, `git add -A/./-u`, `commit -a`, `reset --hard`. Fix lint and format
findings in your own edit and go on. Never skip the hook (up to 12 min); if it fails only on
`tools/film/kill_reel_*.break.test.mjs` / `tools/merge/clash.test.mjs`: `--import`, commit again once.

## Godot
`export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; only through the repo
tools (`tools/dev/run.mjs`, `run_unit.mjs`, `tools/godot/check.mjs`, film tools, `tools/lib/godot.mjs`); d3d12; windowed
`--position 0,1440`. Godot is shared with the HUD-evidence builder through the mutex `build/n29-godot.lock`: before EVERY Godot step (an --import, a run_unit run, a capture, and every git commit because the pre-commit hook runs Godot) take it with `(set -o noclobber; echo "strips $(date +%H:%M)" > build/n29-godot.lock)` (fails while held: re-try every 60 s; older than 25 min = stale, delete it) and `rm build/n29-godot.lock` as soon as that step ends; never hold it during image jobs. On END delete it if yours and create `build/n29-strips.done`.

## Evidence (after the commits)
`C:/Users/kazda/kiro/gtai-masters/n29/keys/gloria/`: `gloria_p55_strips.png` (n27 | n29 brass | pistol, sheet pixels 3x
nearest), `gloria_left_p70_cells.png` (before | after, 4x), and an in-game 64 px/m still of her firing left and right at
p55 if time. `evidence/n29-keys/gloria_strips.md`.

## Allowlist (anything else: stop and report a NEED)
`project/features/characters/art/view/{p55,p70}/rivet_eq_gloria*.png(.import)`, Gloria's held/held_55 art if it is cut from
these strips, `project/data/tables/rivet_muzzle.json` (gloria rows), `steam/ai-provenance/2026-11.jsonl` (append),
`evidence/n29-keys/**`, `C:/Users/kazda/kiro/gtai-art/rivet-n29/**`, `C:/Users/kazda/kiro/gtai-masters/n29/keys/**`, `build/**`.
Forbidden: the walk/run sheets (another call owns `rivet_{walk,run8}_eq_gloria.png`), `rivet_motion.json`, other weapons'
art, `weapons.json`, the HUD files, `project/features/souls/**`, `project/features/combat/**`, `project/boot/prologue/**`,
cast art, `native/`, `JOURNAL.md`, `REPORT.md`, `docs/decisions.md`.

## Report (short), then END
IMAGES n, bars per strip, commit shas, stills, STATE `Next`.

## Added 04:14 (director)
- Order: the p70 left strip first if it is a re-cut with no image (cheap, commit it alone), then p55 main, diag, left (one image
  each, launched two at a time in the background; hand-copy rule: the png lands under `~/.codex/generated_images/<new dir>/` and
  may never reach `out/`: copy it by hand and stop only that job's tree by PID). Lane image cap: 5 this call, hard.
- Commit whatever passes by 04:52 (partial is fine; say which strips stay n27's compact gun). Look at a 4x crop of every
  strip before committing (`C:/Users/kazda/kiro/gtai-masters/n29/keys/gloria/p55_strips_4x.png`, pistol | n27 | new).
- Keep a resumable `STATE.md` in the round dir `C:/Users/kazda/kiro/gtai-art/rivet-n29/gloria_p55/`.
