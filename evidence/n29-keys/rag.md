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
