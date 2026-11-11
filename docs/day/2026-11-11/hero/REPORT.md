# REPORT: night n15, lane hero (Rivet and the four ghosts)

FINAL, 07:35 (it17, after freeze); corrected 07:42 (it25: the Tonnage walk16 delivery). Last full gate: `node tools/gate/run.mjs --rev=HEAD --reels` on 5f9b18955 PASS (lint 16/16, unit 2528/0, scenarios 55/55, parity bit-exact, look goldens 11/11, release-compile 674/0, reels exit 0); later commits (to 736dbfcb9 and this REPORT) are docs/evidence only (`git diff --stat 5f9b18955 HEAD`: JOURNAL, LEVEL, REPORT, evidence/s15). No golden moved or re-blessed; no replay or parity re-bless.
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
   At 32 px/m tick by tick: `evidence/s15/ghost_lunge_kerf_dent_ticks_before_after_32ppm_x2.png`.
   Ohm's bolt now leaves from his drawn fingertips (`GhostHand`, `--ghost-ohm-hand=sim` = before):
   `evidence/s15/ohm_bolt_hand_8dir_before_after_64ppm.png`, at p55 `evidence/s15/ohm_bolt_hand_p55_8dir_before_after_64ppm.png`.
5. **Kerf and Dent run on 16 drawn frames in all eight octants** (it15-it16): every right and left row
   takes the asset lane's halfway frames, plus 9 second takes judged on their boards; keys byte-identical
   (`evidence/s15/tools/key_shift.py`), left cells padded where a frame was wider (Kerf 145 -> 157,
   Dent 156 -> 162). `evidence/s15/dent_run16_away_before_after_64ppm.png`,
   `evidence/s15/kerf_run16_left34_before_after_64ppm.png`, `evidence/s15/kerf_run16_left_rows_before_after_64ppm.png`,
   `evidence/s15/dent_run16_left_rows_before_after_64ppm.png`, `evidence/s15/dent_run16_alts_before_after_64ppm.png`.
6. **Planted feet looked at at the play zoom with a measure, not by eye** (it16): `evidence/s15/tools/feet_trace.py`
   (the ground held still, one row a tick) and `evidence/s15/tools/hold_ride.py` (how far each held frame rides
   over the ground). Ohm and Tonnage reach 3 (Tonnage on the edge: mean ride 8.3 px@32, his stance foot keeps its ground place
   over 30 ticks, `evidence/s15/tonnage_feet_track_32ppm.txt`); his worst hold rides 16.1 px (two long steps in his walk16, art requested). `evidence/s15/ghost_feet_32ppm_tonnage_ohm.png`.
   Dent and Kerf sprints measured the same way (`evidence/s15/dent_kerf_run_hold_ride_32ppm.txt`): the pose changes
   on most ticks, the worst hold 5 px (Dent: 5.3 px at worst in all eight octants, level 4 on the worst-hold bar) and 9 px (Kerf: drift 3.0, stays 2) in the three octants filmed
   (the long holds first seen were Rivet, after the form expired in the film rig).
7. **Rivet's reload strips at x1.5, both pitches** (it16, one weapon per commit): pistol, plasma_rifle, gatling, each
   + its drawn left strip, cut at 1.5 x each row's own fig_h after reproducing the 110 cut byte for byte.
   `evidence/s16/rivet_x15_reload_p70_before_after_64ppm.png`, `evidence/s16/rivet_x15_reload_p55_before_after_64ppm.png`,
   zoom `evidence/s16/rivet_x15_reload_p70_zoom_x2_64ppm.png`. Still 110: the base strip, knock, plasma sword, electro baton.

## What does not work / not done

- Tonnage's lean is barely visible at 32 px/m (3 deg); his slam's landing with the lean is not filmed.
- Ohm's hand spot on the drawn left rows is the right row mirrored (within 3 px at p70; p55 left not checked).
- Kerf and Ohm have no anticipation: their sim strikes are instant by design (registry
  `realtime-combat-semantics`); a sim wind-up was rejected.
- Tonnage's walk: two held frames ride 11-16 px over the ground at 32 px/m (table steps 1 and 5). The two redrawn frames (REQUEST it16) were DELIVERED at 06:01 (`gtai-assets/replies/n15-hero.md` "06:01 it379") but I missed the reply until the it25 REPORT check, so they are not wired or measured. Lost: about 90 min in which they could have shipped.
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

1. Tonnage's walk16 frames 2 and 6: delivered 06:01, ready-placed in the sheet's 163 x 230 cell at
   `gtai-art/library/keyed/ghosts/tonnage_walk16_70_cells_req221/placed_163x230/3_{3,7}.png` (paste over row 3, columns 2 and 6).
   Swap them, judge them in game, re-run `hold_ride.py build/film/gait32_tonnage 2 48 0,45 70,150,190,222` (bar: worst hold under 9 px@32).
2. Combat feel to 3: the owner judges GhostLunge in motion; Kerf's blade and Dent's fist as GhostHand rows if an effect should leave from them.
3. Planted feet: Dent is done in all 8 octants (worst 5.3 px@32). Kerf: film his other 5 octants on leg 2
   (`--film-turn=<deg>`) and check `RUN_TABLES` against `feet_track.py` with a dark threshold of 90 (his blades are not dark).
4. Rivet x1.5: the knock grid (`tools/art/rivet_knock.py` has a fixed FIG_H 110: add `--fig_h`, reproduce at 110 byte for
   byte first), then the base `rivet_frames` strip (many readers), plasma sword, electro baton.
5. Asset-lane offers delivered after 06:30, not taken (freeze): Ohm's cast WIND-UP at p70 and p55 (LEVEL combat feel
   level 4; Dent's R2 cell is 4 px over the act cell, so pad), Ohm's walk legs on the left profile, a drawn HIT FROM BEHIND for
   Dent and Ohm (right facings only; the asset lane's own board says it reads as a forward lurch at 30 px, so judge it in game
   against `GhostRecoil.BY_BLOW` first). All in `gtai-assets/replies/n15-hero.md` 06:37-07:33 (07:33: Dent R1 redrawn, the hit-from-behind set also at p55, 10/10 A by the asset lane, not seen in game). Also two Kerf run16 alternates (4_8 at 05:39, 4_10 at 06:05) for row 4's weak slots, not taken.
