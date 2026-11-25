# Brief n29-05b-molotov-rag-strips: the rest of the molotov's red flame (lane keys, run n29)

Follows `evidence/briefs/n29-05-molotov-rag-live.md` (read whole: method, Godot mutex, allowlist, bans all hold) and its
result: `0b6814366` (held_55/molotov.png only, box x 440..646, 6815 -> 17 reddish px) + `0af6512f3` (`evidence/n29-keys/rag.md`).

## Wall clock (run `date +%H:%M` first and often)
03:50 launched. **Commit by 04:30.** **Report and END by 04:45**, committed or not; never end with passing work uncommitted.
Godot mutex `build/n29-godot.lock` as in the base brief (tag "rag2"); the Gloria builder shares it. Create `build/n29-rag2.done` on END.

## Correction: these files DO exist (the last call missed them)
`project/features/combat/weapons/art/molotov/held.png`, `molotov/pickup.png`, `molotov/icon.png` (check `git ls-files project | grep molotov`).
Audit counts: held 5860, pickup 5457 reddish px.

## Jobs
1. `molotov/held.png`, `pickup.png`, `icon.png`: count reddish px in the flame/rag region; recolour the flame only (box or
   connected blobs from the rag), outside-mask proof = 0 px.
2. **Rivet's strips, the art the player sees**: `project/features/characters/art/view/{p55,p70}/rivet_eq_molotov{,_left}.png`
   and `p70/rivet_walk_eq_molotov.png` (+ `p70/rivet_run8_eq_molotov.png` if it exists). Per cell: the flame = reddish connected
   blobs whose bounding box touches the bottle's top (the bottle: cream/glass blob in Rivet's claw), never a blob in the neck
   band's rows. Build per-cell masks automatically, then **prove the collar unchanged**: the reddish px count of the neck band
   (per cell, the rows of the collar, found from the bare `rivet_run8.png` / `rivet_walk.png` collar rows or by the blob that
   sits on the head/torso seam) before == after, and every px outside the flame masks byte-identical (json). Write a 4x crop
   sheet of 8 cells per strip (before | after) to `C:/Users/kazda/kiro/gtai-masters/n29/keys/rag/strips_4x.png` and look at it:
   the flame amber, the collar still vermilion/black. A strip whose cells you cannot separate safely: leave it, say which.
   Leave the cop/swat `*_molotov_torch.png` (cast's).
3. The orange specks left inside the held_55 rag (see `rag_cells_4x.png` after side): widen the rule inside the existing box
   only (hue 345..30 deg, S > 0.30) if that takes them, re-prove 0 outside.
4. `--import`, `node tools/tests/test_map.mjs <pngs>` + mapped tests + `run_unit.mjs --changed`; commit
   "keys n29: the molotov's flame amber in Rivet's strips and the item art (red audit row 12)"; update `evidence/n29-keys/rag.md`
   (px table per file before -> after, outside-mask + collar proofs) in a separate commit.
5. In-game still: `arsenal_turn.mjs --weapon=molotov` fails ("no attack for molotov at octant 0"); instead use the walk-grid
   capture `C:/Users/kazda/kiro/gtai-art/rivet-n29/gloria_walk/scripts/capture28.py molotov n29` at 64 px/m only if the Godot
   lock is free by 04:20 (read the script; it must leave `git status --short project/` empty); 1:1 crop of Rivet holding the lit
   bottle -> `gtai-masters/n29/keys/rag/molotov_ingame_64.png`. Otherwise report it owed.

## Allowlist
The molotov PNGs named above (+ `.import`), `evidence/n29-keys/rag/**`, `evidence/n29-keys/rag.md`,
`C:/Users/kazda/kiro/gtai-masters/n29/keys/rag/**`, `build/**`, `steam/ai-provenance/2026-11.jsonl` (append only, if a line pins
a hash you change), a test pin that hashes one of those PNGs (that line). Everything else: NEED.
