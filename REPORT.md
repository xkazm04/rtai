# REPORT: night n15, lane hero (Rivet and the four ghosts)

DRAFT written 04:40 (it15) while the gates ran; the last session before 07:40 brings it current.
Branch `n15-hero`, cut from main `5c5c03611`. Every claim cites a still in this branch's `evidence/`
(the best 15 are copied to `gtai-masters/n15/hero/` with `frames.json`). Record: `JOURNAL.md`, `LEVEL.md`.

## What works (with evidence)

1. **h-4, Dent's fallback strike** (owner Call). With no car seized, a melee press was nothing in the sim
   (not an undrawn strike). Built `DentJab`: an arm jab no stronger than Rivet's claw jab (claw_1
   reach and damage), gated by `ghost_attacks.json` `dent.jab` (1 = on, the default; 0 = the before).
   Replay and parity goldens did not move: no re-bless; `city_replay` ok and parity bit-exact on every
   full gate run since (JOURNAL GATES lines from 23:10 on).
   - 8 directions at 64 px/m: `evidence/it4/dent_jab_8dir_before_after_64ppm.png` (placeholder act cell),
     then the drawn jab cells (wind-up, jab, recoil) `evidence/it8/dent_jab_cells_8dir_before_after_64ppm.png`,
     the left jab drawn `evidence/it12/dent_jab_left_rows_before_after_64ppm.png`, at p55
     `evidence/it12/dent_jab_p55_8dir_before_after_64ppm.png`.
2. **h-3, drawn left facings for all four ghosts** (owner Call), at p70 and p55, walk, run, act, jab
   and HIT: `evidence/it8/{dent,kerf,ohm}_left_rows_before_after_64ppm.png`,
   `evidence/it12/tonnage_left_rows_before_after_64ppm.png`, `evidence/it12/*_left_rows_p55_*`;
   the left rows re-toned to their right rows' saturation `evidence/it13/ohm_left_retone_before_after_64ppm.png`.
   No act, jab or HIT cell is mirrored for any ghost now.
3. **n11 next steps**:
   - blow source: the hit lean goes away from the attacker (`Fighter.hurt_dir`, `GhostRecoil.BY_BLOW`):
     `evidence/it4/ghost_recoil_blow_before_after_64ppm.png`;
   - Ohm's diagonal HIT cells and his p55 HIT: `evidence/it4/ohm_hit_diag_before_after_64ppm.png`,
     `evidence/it4/ohm_hit_p55_before_after_64ppm.png`; Tonnage's p55 HIT `evidence/it4/tonnage_hit_p55_before_after_64ppm.png`;
   - Rivet's strips at x1.5: every p70 and p55 gun strip (and the drawn left strips) is native x1.5
     (`evidence/it4/rivet_x15_*`, `evidence/it8/rivet_x15_p55_*`);
   - the soul teal line on the drawn ghosts: `evidence/it8/*_soul_line_before_after_64_32ppm.png`;
   - quest 1's hide spot at x1.5: Rivet now tucks into the bin, and under a tilt the bin draws the asset
     lane's peek card (`HidePeek`): `evidence/s14/rivet_hide_peek_before_after_64ppm.png`;
   - planted feet: Kerf and Dent run on 16 drawn frames stepped on measured stance tables
     (`GhostStride.RUN_TABLES`): sawtooth 16.6 -> 8.3 px@32 (Kerf), 13.5 -> 6.7 (Dent); drift 2.0 (Dent),
     3.0 (Kerf) px@32. `evidence/s14/{kerf,dent}_run16_before_after_64ppm.png`, 32 px/m clips
     `evidence/s14/*_run16_before_after_clip_32ppm_x2.gif`, diagonals `evidence/s14/*_34*`, left profile
     `evidence/s14/{kerf,dent}_run16_left_before_after_64ppm.png`.
4. **Combat feel (the lowest LEVEL row), `GhostLunge`**: a drawn ghost leans into its strike about its
   feet (Ohm 13 deg, Kerf/Dent 9, Tonnage 4), eased over the 0.25 s follow-through, and leans back on
   a committed wind-up (Tonnage's slam, Dent's jab). View only, no sim change.
   `evidence/s15/ghost_lunge_ohm_ticks_before_after_64ppm.png` (+ clip `_clip_64ppm.gif`),
   `evidence/s15/ghost_lunge_{ohm,kerf,dent}_8dir_before_after_64ppm.png`,
   `evidence/s15/ghost_lunge_tonnage_windup_before_after_32ppm.png`.

## What does not work / not done

- Tonnage's lean is barely visible at 32 px/m (3 deg); his slam's landing with the lean is not filmed.
- Ohm's bolt leaves from the sim's hand point (`OhmStage.HANDS_M`), not his drawn hand: visible at 64 px/m,
  before and after GhostLunge.
- Kerf and Ohm have no anticipation: their sim strikes are instant by design (registry
  `realtime-combat-semantics`); a sim wind-up was rejected.
- Run16: the 3/4 left rows of Dent and Kerf (except Kerf's toward-left) still show each run8 frame twice.
- `scenario_rig_stress`: the n11 intermittent `Parameter "t" is null` fired once (03:25 on dcc583214),
  3/3 alone ok, green on every later full run.
- The clips are short (a form lasts a few seconds in the film rigs), not the 10-40 s rule.

## Calls for the owner

1. **Dent's fallback jab** (`dent.jab` 0 = off): `evidence/it8/dent_jab_cells_8dir_before_after_64ppm.png`.
2. **The blow lean from behind** fights the front-hit pose (`GhostRecoil.BY_BLOW` false = before):
   `evidence/it4/ghost_recoil_blow_before_after_64ppm.png`.
3. **The soul line on Ohm and Kerf**, whose bodies are already teal (`GhostSoulLine.WIDTH_PX`/`ALPHA`,
   `--ghost-soul-line=off`): `evidence/it8/ohm_soul_line_before_after_64_32ppm.png`.
4. **Quest 1's hide: the peek card** vs the token (`HidePeek.PEEK` false = token):
   `evidence/s14/rivet_hide_peek_before_after_64ppm.png`; which card: `evidence/s14/rivet_hide_peek_70_vs_55_64ppm.png`.
5. **Run16 on Kerf and Dent** (`GhostStride.RUN_TABLES` {} = run8): `evidence/s14/kerf_run16_before_after_64ppm.png`.
6. **GhostLunge strength** (`GhostLunge.BY_FORM`, `--ghost-lunge=off`): Ohm's 13 deg is the boldest;
   `evidence/s15/ghost_lunge_ohm_ticks_before_after_64ppm.png`.

## Merge notes

- `features/characters/cast_flags.gd` is also edited by combat (`_windup()`); hero's lines are in `_ghost()`
  (`--ghost-soul-line=off`, `--ghost-lunge=off`). Keep both.
- `ghost_drawn.gd` is at 200 lines (the soft cap): new logic goes into its own class (as GhostLunge).
- Large PNGs under `project/features/souls/art/view/p70/*run16*` need their `.import` after merge (`--import`).

## Next steps

1. Wire the remaining run16 left rows (Kerf 3/4 away-left, Dent both 3/4 left) as they arrive.
2. Combat feel to 3: judge GhostLunge in motion at 32 px/m with a long clip; anchor Ohm's bolt to the drawn hand.
3. Planted feet: a world-space frame-diff measure of the stance foot for Ohm and Tonnage's walk clips.
