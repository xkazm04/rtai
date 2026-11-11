# REPORT: n16 kills-polish (DRAFT, iteration 4, 16:15; final at 19:40)

Branch `n16-kills-polish`, cut from main `5843f5a28`. Lane brief: make the 13 existing signature deaths brutal and
beautiful (owner 2026-11-11: inventive, readable at 32 px/m, drawn innards/bone/skulls in riso ink-and-cream, hit-stop
plus camera punch only). Ranking and beat sheets: `KILLS.md`. Defects: `DEFECTS.md`. Diary: `JOURNAL.md`.
Evidence sheets: `evidence/n16-kills-polish/` (`frames.json`, newest first; mirrored to `gtai-masters/n16/kills-polish/`).

## What works (with evidence)

Item 1, the owner's n15 view verdicts:
- Slash streak shorter and thinner: row `streak_m` 1 / `streak_w_m` 0.06 (de9f68f8a); `katana_streak_ab_{64ppm_t61-68,32ppm_x2_t63-70}.png`.
- Blade strike holds through short gaps (6 ticks, view only): e4d81df1b; `boss_katana_strike_hold_ab_64ppm_t305-310.png`.
- Rocket gib drawn torn pieces for the thug and hooded ped as rigs (and cap, suit, worker, SWAT): 917d75a5e, torso
  0.7 m 1b823dbf7; `rocket_gib_{thug,ped_head_hood}_drawn_pieces_ab_*.png`.
- Quest 1 p55 peek card: already wired on main (n15 hero b536742b4); no change needed. A quest 1 still is OWED.

Item 3, deaths raised (one commit each; asset lane A1-A5 and A3 p55 wired):
- Gib pieces WITH BONE for every human kind (fdb3a0d2d, 76f023a08, d99019902).
- Blade splits cut through the torso (cut_up_m 0.8), halves topple 80 deg, drawn cut faces with ribs and spine
  (7d3ba705a, e69fd5359, 0dcdf95c1, 794f27f80).
- Electro X-ray: upright on his feet, the victim kind's own drawn skeleton (8 kinds, p70 and p55), as tall as the
  view's cards (455148cb5, b037d283f, 4329ed869, 16748e860).
- Plasma hole at the chest, drawn charred ring, 20-tick heat bloom (bb9314a83, 0dce9f3b6, ab2de6592, 6c52eaa7d).
- Chainsaw throws 8 drawn chunks that lie on the street (af3f9af1c).
- Ray gun: no spinning whole-cop "cap", the dissolve eats the whole drawn man (06deed4b5, 999ec13db).
- Burn: embers and smoke on the burnt man, not at his feet, drawn over him (051802ce0, b2c4051c2, 6963740ef).

## What does not work / not done

- Plasma sword scorch line (c43cae42d) is committed lint-only: UNFILMED and its unit test is not yet run (the gate held
  the lane's Godot). Next iteration first.
- Burn: the char man still only fades; no collapse (A8 requested). Rocket bone does not read at 32 px/m.
- Hand cannon is a plain knock-back (A6 exit wound requested). Ray gun remains have no skull (A7 requested).
- The ghosts' four (Tonnage, Dent, Kerf, Ohm) are not filmed (scores provisional).
- Perf: `tools/perf/fight_gate.mjs` under the bench lock not run yet (new preloads: 16 X-ray strips, plasma ring,
  chunks, cut faces).
- Aftermath durations are derived from the decay table, not measured on film (KILLS.md, "Aftermath").

## Calls for the owner

One line per changed death; each with its 64 and 32 px/m before/after (TO FINISH at 19:40):
- Ray gun: the man is eaten whole by the ring (was legs in a disc + a spinning cop): `ray_gun_ellipse_mask_ab_{64ppm_t82-109,32ppm_x2_t50-109}.png`.
- Burn: smouldering on his shoulders (was a hot scrap at his feet): `burn_embers_on_figure_ab_{64ppm_x2_t150-250,32ppm_x2_t150-285}.png`.
- Plasma hole: drawn ring + bloom (Call: the drawn ring vs the old procedural bullseye): `plasma_hole_bloom_ab_{64ppm_t55-70,32ppm_x2_t55-80}.png`.
- Electro X-ray per kind: at 32 px/m darker and busier than the plain sticker on dark asphalt (Call):
  `electro_xray_per_kind_ab_{64ppm,32ppm_x15}_t118-150.png`; p55: `electro_xray_p55_{set,scale}_ab_tilt64ppm_x2_t119-146.png`.
- Plasma sword hot face: charred crust vs glowing cream band (Call): `plasma_sword_hot_face_ab_64ppm_x11_t72-102.png`.
- Blade topple 80 deg and cut_up_m 0.8: `katana_topple_ab_*`, `katana_cut_up_ab_*`.
- Saw chunk size 0.46 m: `chainsaw_chunks_ab_{64ppm,32ppm_x2}_t100-230.png`.
- Bone gib: `rocket_gib_bone_patrol_ab_{64ppm_x2_t360-371,32ppm_x2_t352-371}.png`.

## Merge notes

- Shared files: `signature_kills.json` + schema (new keys: streak_m, streak_w_m, hole_up_m, cut_up_m,
  split_topple_deg, saw_chunks, scorch_line_m); kills-new adds rows to the same table (merge by row id).
- `steam/ai-provenance/2026-11.jsonl` gains lines for every new PNG.
- No sim, replay or parity change (all view); look goldens unchanged as of the gate on 49c7c0be9.

## Next steps

See JOURNAL `NEXT:`.
