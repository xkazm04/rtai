# REPORT: n16 kills-polish (final, 19:40)

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
- Burn collapse (A8): every kind with a char cell crumbles in three drawn cells, on his knees with the skull and ribs
  showing, onto a skull heap with his charred gear that stays (b3b03286c, 934a815c6);
  `burn_collapse_{patrol_ab_64ppm_x2,hood_ab_64ppm_x2,riot_ab_32ppm_x3}_t590-740.png`.
- Hand cannon exit wound (A6, then the A6b redraw): a drawn wound in the thrown man's chest (512caa62b, 6140efc62,
  944ea5fa9, a4a2dcda1, 0.2 m 80d1c959b); `hand_cannon_exit_wound_a6b_ab_{64ppm_x2_t51-90,32ppm_x3_t51-72}.png`
  (the first try read as a grinning mouth: `hand_cannon_exit_wound_ab_64ppm_x2_t51-72.png`).
- Ray gun remains (A7): the drawn ash heap with a half-sunk skull, ribs, a forearm bone and the empty uniform (84589b1ad);
  `ray_gun_drawn_remains_ab_{64ppm_x2,32ppm_x3}_t110-199.png`.
- Plasma sword scorch line along the cut (c43cae42d, test 78dd90f40), wider 7998ee3fa;
  `plasma_sword_scorch_line_{ab_64ppm_x11,wider_ab_64ppm_x15}_t70-200.png`.

Item 5 (defect loop): a card victim's empty cap group cast a dark shadow disc that hung on the street (ray gun, hand
cannon) -> bd9af660f (`ray_gun_cap_shadow_ab_64ppm_x2_t150-199.png`). A blade half's shadow lay ~1 m from the
toppled top half -> bbf62f6f3 (test 42cf70c8a; `plasma_sword_half_shadow_ab_64ppm_x15_t90-200.png`).
Gate: whole gate PASS on 05715ef5f incl. reels (18:10; `build/gate/05715ef5f249/gate.json`): lint 19/19, unit
2700/0/2, scenarios 55, parity bit-exact (planted mutation caught), look goldens 11/11 worst 0.00, export-audit 690/0,
reels top/tilt70/combo. After it only bbf62f6f3 (view-only shadow anchor) + its test + docs: on the tip 338603083
lint 19/19 PASS (19:31) and the full unit suite 2687/0 (`run_unit.mjs --changed`, 18:14). Scenarios, parity, goldens
and reels were NOT re-run on the tip (no time before freeze); the change cannot move sim or parity (view only).

## What does not work / not done

- Burn collapse is drawn in one facing (towards the camera): a man burnt facing away turns round at the cut (A8c
  requested). Rocket bone does not read at 32 px/m.
- Hand cannon: the thrown body never lies down (an upright card flies back); the wound is on an upright torso.
- The ghosts' four (Tonnage, Dent, Kerf, Ohm) are not filmed (scores provisional).
- Perf: `tools/perf/fight_gate.mjs` under the bench lock not run yet (new preloads: 16 X-ray strips, plasma ring,
  chunks, cut faces).
- Aftermath durations are derived from the decay table, not measured on film (KILLS.md, "Aftermath").

## What blocked me, and for how long

- Nothing blocked the lane outright. Time losses (JOURNAL FRICTION lines):
  - 11:05-11:22 (17 min): a first before/after chained `HEAD~1/HEAD` while I committed mid-run; re-filmed on explicit SHAs.
  - The gate takes about 40 min with reels, and the lane gets one Godot process. Each gate stopped filming for that long; I stopped one at 13:12.
    Because of this, the tip has no full gate: the last full PASS is 05715ef5f.
  - Pre-commit full lint takes about 2 min on any commit that stages a path outside project/ (provenance, tools/art).
  - Asset waits: the A8c back facings for the burn collapse have not landed (requested, open).

## Calls for the owner

One line per changed death; each with its 64 and 32 px/m before/after (sheets in `evidence/n16-kills-polish/`):
- Ray gun: the man is eaten whole by the ring (was legs in a disc + a spinning cop): `ray_gun_ellipse_mask_ab_{64ppm_t82-109,32ppm_x2_t50-109}.png`.
- Burn: smouldering on his shoulders (was a hot scrap at his feet): `burn_embers_on_figure_ab_{64ppm_x2_t150-250,32ppm_x2_t150-285}.png`.
- Plasma hole: drawn ring + bloom (Call: the drawn ring vs the old procedural bullseye): `plasma_hole_bloom_ab_{64ppm_t55-70,32ppm_x2_t55-80}.png`.
- Electro X-ray per kind: at 32 px/m darker and busier than the plain sticker on dark asphalt (Call):
  `electro_xray_per_kind_ab_{64ppm,32ppm_x15}_t118-150.png`; p55: `electro_xray_p55_{set,scale}_ab_tilt64ppm_x2_t119-146.png`.
- Plasma sword hot face: charred crust vs glowing cream band (Call): `plasma_sword_hot_face_ab_64ppm_x11_t72-102.png`.
- Blade topple 80 deg and cut_up_m 0.8: `katana_topple_ab_*`, `katana_cut_up_ab_*`.
- Saw chunk size 0.46 m: `chainsaw_chunks_ab_{64ppm,32ppm_x2}_t100-230.png`.
- Bone gib: `rocket_gib_bone_patrol_ab_{64ppm_x2_t360-371,32ppm_x2_t352-371}.png`.
- Burn collapse onto a skull heap (A8; was a fade): `burn_collapse_hood_ab_64ppm_x2_t590-740.png`,
  `burn_collapse_riot_ab_32ppm_x3_t590-740.png`.
- Hand cannon exit wound (A6b, 0.2 m on the chest): `hand_cannon_exit_wound_a6b_ab_{64ppm_x2_t51-90,32ppm_x3_t51-72}.png`.
- Ray gun drawn remains with the skull (A7; Call: at 32 px/m the grey heap is quieter than the old cream smear):
  `ray_gun_drawn_remains_ab_{64ppm_x2,32ppm_x3}_t110-199.png`.
- Blade half shadows under the halves (defect fix, no Call): `plasma_sword_half_shadow_ab_64ppm_x15_t90-200.png`.

KILLS.md ranking (total of read / inventive / brutal / aftermath, 4 x 5; before -> after n16):
burn_char 13 -> 17 (riot/hood), chainsaw_grind 15 -> 17, ray_gun_dissolve 11 -> 17, hand_cannon_blowback 13 -> 15,
mini_nuke_vaporise 15, rocket_gib 14 (bone lost at 32), katana_split 10 -> 14, electro_shock 12 -> 14,
plasma_hole 12 -> 13, homing_shard_burst 13, plasma_sword_split 7 -> 12; ghosts unfilmed (tonnage 15?, dent 13?,
ohm 12?, kerf 11?). Weakest now: plasma_sword_split (no blood by design; scorch line only) and the ghosts.

## Merge notes

- Shared files: `signature_kills.json` + schema (new keys: streak_m, streak_w_m, hole_up_m, cut_up_m,
  split_topple_deg, saw_chunks, scorch_line_m, wound_m; `wound_m` sorts after `weapon`, off kills-new's hunks); kills-new adds rows to the same table (merge by row id).
- `steam/ai-provenance/2026-11.jsonl` gains lines for every new PNG.
- No sim, replay or parity change (all view); look goldens unchanged as of the gate on 05715ef5f (11/11, worst 0.00).

## Next steps

1. Full gate on the tip incl. reels (`node tools/gate/run.mjs --rev=<tip> --reels`). Code is unchanged from 338603083
   to the tip (`git diff --stat 338603083 HEAD -- project tools` is empty); docs/evidence only since.
2. Hand cannon: the thrown body lies down on landing (swap to the kind's fall cell's last frame, as KillCharCells.swap).
3. Burn collapse back facings when A8c lands; rocket bone at 32 px/m; film the ghosts' four.
4. `tools/perf/fight_gate.mjs` under the bench lock for the new preloads; a quest 1 p55 peek still.

## Path check (19:44)

Every `.png` cited above exists under `evidence/n16-kills-polish/` (a brace-expansion loop over REPORT.md found 0 MISSING).
`node tools/evidence/cites.mjs REPORT.md`: 4 paths, 4 ok. `build/gate/05715ef5f249/gate.json` is present (git-ignored).
