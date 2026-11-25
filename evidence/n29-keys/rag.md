# keys n29: the molotov's lit rag, red -> amber (red audit row 12)

Script: `evidence/n29-keys/rag/recolour_rag.py` (hue remap of combat's `recolour.py`, copied as `_ref.py`, to #EDAB42,
alpha/max/min channel kept), restricted to the rag box `x 440..646` of the sheet.

| file | strict reddish px before -> after | changed px | changed outside the rag box |
|---|---|---|---|
| `project/features/combat/weapons/art/held_55/molotov.png` | 6815 -> 17 | 12100 | 0 |

Outside-mask proof: the script asserts `changed & ~box == 0`; re-checked against the HEAD~1 file: 0 changed px with x < 440,
alpha identical everywhere. The 17 left are dark edge px. 4x before | after crop: `evidence/n29-keys/rag/rag_cells_4x.png`
(also `C:/Users/kazda/kiro/gtai-masters/n29/keys/rag/rag_cells_4x.png`). The cream neck ring and glass are visibly unchanged.

Not changed, and why:
- `showcase/{icon,p55,p70}/molotov.png`: the bottle has an unlit cream rag, no flame; its "reddish" px are dark outline/rust.
- Rivet's `p55|p70/rivet_eq_molotov{,_left}.png`, `p70/rivet_walk_eq_molotov.png`: they draw a small torch flame in the hand,
  but the hazard-collar vermilion is in the same strips (thousands of reddish px); a safe flame-only box per cell needs
  hand-checked boxes. OWED (a follow-up with per-cell boxes).
- `pickup.png` / `held.png` named by the audit do not exist in the tree; the 6815 count is `held_55/molotov.png` only.

Tests: the 9 mapped files (arsenal_audit, gatling, held_lod, held_pitch_art, held_tube, rig_grip, rivet_carry_angle,
rivet_held_warm, strike_over): 55 passed, 0 failed (1 FLAKY, test_arsenal_audit, passed on re-run). No pin changed.

In-game still: OWED. `tools/film/arsenal_turn.mjs --weapon=molotov` has no attack pose for the molotov
("no attack for molotov at octant 0"), so no same-scene before | after was possible.


## Part 2 (brief n29-05b): the item art and Rivet's strips

Scripts (all in `evidence/n29-keys/rag/`): `recolour_strips.py` (the same hue remap from `_ref.py`; item art = a box on the rag,
strips = a per-cell flame mask), `flame_cells.py`/`annot.py`/`sheet.py` (review helpers), `verify.py` (re-checks every file against
HEAD), `proof.json` (per-cell numbers). Commit `baf0b209d`.

Flame mask per strip cell: the cell's loose reddish blobs (hue 345..25 deg S>0.35 or R>170 G<110 B<90), never the cell's biggest
blob (the striped collar plus the rust lines of the body), the one with the most yellow-white flame core around it, plus the small
narrow rag blobs right under it. Where the flame is joined to the body blob by a thin neck (the walk grid rows 2-3, a few eq cells)
the body blob is eroded 1..3 px, the core-rich small piece is grown back inside the mask and the body piece is subtracted; a result
wider than 33 px is rejected (it leaked into the head).

| file | reddish px (strict) before -> after | changed px | changed outside the mask | alpha changed |
|---|---|---|---|---|
| `weapons/art/molotov/held.png` (box x 345..474) | 5860 -> 23 | 7519 | 0 | 0 |
| `weapons/art/molotov/pickup.png` (box x 337..462) | 5457 -> 0 | 6571 | 0 | 0 |
| `weapons/art/molotov/icon.png` | 0 | not changed (no reddish px) | | |
| `weapons/art/held_55/molotov.png` (box x 440..646, wider rule hue 345..30 S>0.30) | 17 -> 17 strict | 1296 (the orange specks in the rag) | 0 | 0 |
| `view/p55/rivet_eq_molotov.png` (8 cells, 6 flames done) | 2903 -> 2402 | 1337 | 0 | 0 |
| `view/p55/rivet_eq_molotov_left.png` (3 cells, 2 done) | 1332 -> 1258 | 428 | 0 | 0 |
| `view/p70/rivet_eq_molotov.png` (8 cells, 8 done) | 5637 -> 4655 | 2816 | 0 | 0 |
| `view/p70/rivet_eq_molotov_left.png` (3 cells, 3 done) | 2151 -> 1812 | 1057 | 0 | 0 |
| `view/p70/rivet_walk_eq_molotov.png` (32 cells, 30 done) | 13370 -> 11972 | 6058 | 0 | 0 |

`p55|p70/rivet_run8_eq_molotov.png` do not exist. The held_55 row 440..646 box is the commit `0b6814366` one; the wider rule only
adds the specks inside it (re-checked: the cream ring and glass unchanged, see `held55_specks_3x.png`).

Proofs: every run asserts `changed & ~mask == 0` and alpha identical; `verify.py` re-derives it against HEAD (via `git lfs smudge`):
item art 0 changed px outside the box; strips: every changed px sits in a flame blob (7 / 4 / 13 / 3 / 42 blobs per file, largest
639 px, widest 58 px, tallest 74 px), the collar is a striped band of thousands of px that no changed blob touches: the biggest
blob of every cell is excluded from the mask by construction (asserted `flame & collar == 0`), and the collar's vermilion/black
stripes are visibly unchanged in the 4x sheets. I did not find a numeric "collar rows" definition that did not also contain
flame pixels (the bare `rivet_run8.png` / `rivet_walk.png` are packed on a different grid than the eq strips, so a byte compare of
the collar crop was not possible); the proof for the collar is therefore the construction plus the sheets, not a per-row count.

Left unchanged, flame still red-orange: `p55/rivet_eq_molotov.png` cells 1 and 7 (flame touches the body blob and the erosion
split leaked or found nothing), `p55/rivet_eq_molotov_left.png` cell 2, `p70/rivet_walk_eq_molotov.png` cells 5 and 9 (rejected
as leaking into the head). Owed: hand boxes for these 5 cells.

Sheets (before | after): `gtai-masters/n29/keys/rag/strips_4x_p55.png`, `strips_4x_p70.png`, `strips_4x_p70_walk.png` (2x),
`items_2x.png`, `held55_specks_3x.png`.

Tests: `run_unit.mjs --changed`: 1158 passed, 0 failed. No pin changed.

In-game still: `gtai-masters/n29/keys/rag/molotov_ingame_64.png` (1:1 crop, 64 px/m, after only; the walk-grid capture
`capture28.py molotov rag2`, tick 670, `rivet_walk_eq_molotov.png`, full frames in
`gtai-masters/n29/keys/gloria/grid_molotov_arena/rag2_64/`). Flame amber, collar vermilion. No before still (no worktree at the old commit was built).

## The last five cells (n29-06 step 2)
`evidence/n29-keys/rag/leftover_cells.py` (hand-checked flame boxes after 6x crops; same `_ref.remap`): `p55/rivet_eq_molotov.png` cells 1 and 7,
`p55/rivet_eq_molotov_left.png` cell 2, `p70/rivet_walk_eq_molotov.png` cells 5 and 9 (changed px 204, 192, 105, 284, 287). Changed outside the boxes 0, alpha
unchanged (`rag/leftover_proof.json`). Before | after 4x: `gtai-masters/n29/keys/rag/leftover_cells_4x.png` (looked at: flames amber; collar, visor and body unchanged).
