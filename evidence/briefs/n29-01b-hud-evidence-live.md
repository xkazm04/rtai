# Brief n29-01b-hud-evidence: the gauntlet HUD's same-tick pair, handheld still, mutate, decision line (lane keys, n29)

Builder for lane `keys`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n29-keys`). Repo law: `AGENTS.md`.
Read `evidence/briefs/n29-01-hud.md` (the item, the allowlist, the repo law: all hold) and `evidence/n29-keys/hud.md`
(what was done: `24fc9c4c3`, `26d320430`).

## Wall clock
`04:14` launched. Commit by `04:50`. **Report and END by `05:02`.**

## What to do
1. **Same-tick before | after at 1080p**: `node tools/film/compare.mjs` (see `tools/README.md`: same shot, `--a=c649a15d6`
   `--b=24fc9c4c3`; snapshots under `%TEMP%/gtai-film-<sha>`, `--native=donor`) on the bond film or the gauntlet bot film,
   a tick where chips and the caption both show. If compare cannot take that scene, find the nearest shot it takes that
   shows the strip and the caption, and say so. Write `C:/Users/kazda/kiro/gtai-masters/n29/keys/hud/hud_pair_1080.png`
   (before left, after right, labelled) and `hud_pair_same_tick_crop_3x.png`. Delete only what you created in Temp.
2. **Handheld still** at 1280x800 with the compact layout (`DeviceProfile` hud = compact: find how a run selects it — a
   launch flag or device row — and use that; no code change): `hud_after_handheld.png`, and measure chip 1's plate there.
3. **Mutate** (time-boxed 15 min): `node tools/mutate/mutate.mjs --file=project/features/souls/ghost_chip_number.gd
   --max=12 --lines=<the anchor() lines> --tests=test_ghost_chip_number,test_ghost_form_hud,test_ghost_form_layout`; quote
   killed/(killed+survived). If the baseline import times out again, say so with the time.
4. **Caption text centred** in its box (`horizontal_alignment = 1` on `Caption/Act`), a one-line change in
   `gauntlet_bot_film.tscn`; commit it.
5. **Decision line**, appended (one line) to `docs/decisions.md`:
   `- [2026-11-25] DECISION n29 keys HUD: the bot film's action caption moved to the bottom centre (it covered the ghost chip numbers); chip number plates anchored inside the strip's plate and >= 8 px off the screen edge on both layouts (GhostChipNumber.anchor; chip 1 7 -> 15 px at 1080p), number sizes unchanged (30/24). Rejected: smaller numbers (owner's n27 size).`
6. Update `evidence/n29-keys/hud.md` with the numbers; frames.json entries in
   `C:/Users/kazda/kiro/gtai-masters/n29/keys/frames.json` (create or append: `file`, `title`, `ppm`, `before`, `note`).

Godot: Godot is shared with the sword-rings builder through the mutex `build/n29-godot.lock`: before EVERY Godot step (an --import, a run_unit run, a film/compare/mutate run, and every git commit because the pre-commit hook runs Godot) take it with `(set -o noclobber; echo "hud $(date +%H:%M)" > build/n29-godot.lock)` (fails while held: re-try every 60 s; older than 25 min = stale, delete it) and `rm build/n29-godot.lock` as soon as that step ends. On END delete it if yours and create `build/n29-hud2.done`; exports, d3d12, `--position 0,1440` and the commit law as in n29-01. Allowlist as n29-01 plus
`docs/decisions.md` (that one line). Report (short), then END.

## Added 02:59 (director)
7. Also append this second line to `docs/decisions.md` (one line):
   `- [2026-11-25] DECISION n29 keys plasma sword: walks and runs on its own p70 grids edited from the katana's (3dbef1803, d72d49bd8; one image edit per row, 16 rows, bars in evidence/n29-keys/grid_plasma_sword.md), blade amber as the shipped strip; walk_grid.by_weapon.plasma_sword left unset (RivetWalk plays a weapon's own sheet first; setting it empties the p55 walk, which has no sword grid). Run step 8.29/9.38 cm misses the 7 cm bar, inherited from the katana's legs (7.76/9.15). Rejected: the stop-gap bare run with the thin grey held blade.`
8. Run `node tools/tests/run_unit.mjs --select=test_rivet_walk_every_weapon,test_rivet_grid_stride,test_rivet_walk_sprint_fallback` once
   on HEAD and quote it (the sword commit's full `--changed` run was with a line later removed).

## Added 04:14 (director)
- Order by value: 4 (caption centred, commit), 5 + 7 + 9 (decision lines, one commit with 4 or alone), 1 (same-tick pair), 8, 2, 3 (mutate last, 15 min box).
- If `compare.mjs` cannot snapshot (the temp worktree import timed out last time, 647 s under load): give it one try with a 20 min
  shell timeout; if it fails, say so and render the "before" by checking out only the two HUD files at `c649a15d6` into a scratch
  copy under `build/` is NOT allowed (product files): instead report it owed.
9. Also append these two lines to `docs/decisions.md` (one line each):
   `- [2026-11-25] DECISION n29 keys Gloria: walks and runs on her own p70 grids edited from the pistol's (eac8b4e34, ba764e395; one image edit per row, 16 rows, bars in evidence/n29-keys/grid_gloria.md); walk_grid.by_weapon.gloria deleted and the old long-gun run8 removed; run_row_k p70/gloria/5 0.64 by the own-vs-bare stride rule (the pistol's row has no entry; one value to drop). Run row 8 cell 5 keeps the pistol's legs under a seam. Rejected: the bare stride with the gun on the palm (n27-n28 stop-gap).`
   `- [2026-11-25] DECISION n29 keys molotov flame: the lit rag/torch flame recoloured red -> amber #EDAB42 by a masked hue remap in the item art and Rivet's strips (0b6814366, baf0b209d; 0 px changed outside the flame masks, the hazard collar excluded), red audit row 12 (combat's NEED). Rejected: an image redraw (would move accepted shapes).`
