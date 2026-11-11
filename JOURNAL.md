# JOURNAL - n17 rivet-strike

## Session 1 (2026-11-11 20:02-21:32), BUILD

- Read: brief, common rules, AGENTS.md, decisions tail, tools/README.md, HUD code (hud_view, hud_feed, WeaponShowcase).
- Registry: item 1 is HUD layout, not combat semantics; no subject governs it directly (sprite-and-atlas-production only for the ICON form choice: the asset drawn for the display it is shown on).
- DECISION hud/weapon-slot: bottom-right slot, showcase ICON cut + WEAPON__<id> name + magazine count; above the subtitle while a line is up (cut); `--hud-weapon=off` = before. (docs/decisions.md)
- FRICTION: the arena/city film hides the HUD (arena_game.gd:59), so HUD evidence comes from the dialogue board (`dev/showcase/dialogue_board.gd --slots`) over a filmed city frame (t400 of `film.mjs city`).
- MILESTONE 20:02 item 1 committed bb09b7574 (HUD slot; evidence gtai-masters/n17/rivet-strike/hud_slot_*.png, before/after at 1280x800 and 1920x1080, with and without a subtitle up).
- MILESTONE item 2a committed 3abb72f83: `lunge_ticks` (katana_3 4, chainsaw_1 4): the lunge arrives on the contact tick. Measured in test_melee_lunge_contact: before 1.25/2.5 m at contact + 1.04 m slid after; after 2.5 m at contact, 0 after.
- Registry: realtime-combat-semantics (contact on the frame that shows it; movement committed before the hit test), motion-quality-gating (measure foot drift / pops in px per tick, not by eye).
- FOUND: katana slash cells pop Rivet's boot line 4.3 px up then 1.9 px down at 48 px/m (chapter:katana t59-62). DEFECTS #4.
- Working: RivetLean (weapon strikes lean back in wind-up, in from contact, about the feet), `--rivet-lean=off` = before.
- MILESTONE 415dc9ad1 RivetLean (strike lean about the feet), films katana t61/t64 + baton_left t64 at 64/32 px/m.
- MILESTONE 0e01165a3 + 7b1f03b7c RivetCellFeet: the p70 blades' strike cells (side 5, camera 6) seated on their boots. The camera cells were a body height up (katana_cam t66: Rivet off frame, blade only). Evidence gtai-masters/n17/rivet-strike/frames.json (11 entries).
- Scenarios 55/55 on 3abb72f83 (the lunge change: replay unmoved).
- FOUND (open): the rig's screen point rises 1.5-2.6 px through a katana strike while sim y is constant (probe `screen`).
- MILESTONE fcd603180 a strike cell stands planted (no gait bob on it): probe screen y 400.0 every tick through the katana strike (before 397.4-399.4).
- MILESTONE 6bdb6dd4b p55 camera strike cells seated (katana 46, plasma 34, saw 18, baton 30; side cells already fine). Not filmed in a boss arena yet.
- Item 4 started: weapon:pistol at 64 px/m. Flash + tail leave the drawn muzzle (OK). DEFECTS #9-#13.
- MILESTONE 6ae388e38 + 6822e1036 RivetFireTurn: no flash on a turn after the last round (t339-340), `--rivet-fire-turn=keep` = before.
- REQUEST assets: flashless fire cells for Rivet's equipped gun strips (DEFECTS #9: one pistol round shows 8 ticks of the painted flash because the fire cell is held FIRE_TICKS 7 for the recoil pose). Beat: the fire/recoil pose WITHOUT the muzzle flash, same canvas, same grip and muzzle point, same foot line. Frames: cells 5 (FIRE_SIDE) and 6 (FIRE_CAM) of `art/view/<pitch>/rivet_eq_<gun>.png` as a 2-cell strip `rivet_eq_<gun>_fire_noflash.png`. Cell size: the strip's own (p70 pistol 283x180; others: width/8 x height). Pitches: p70 and p55. Guns: pistol, machine_pistol, gatling, plasma_rifle, hand_cannon, gloria, electro_gun, rocket_launcher (not the flamethrower: its cell is the stream).
- REQUEST assets: a thrust-lunge cell for the katana (DEFECTS #5: the 2.5 m thrust now travels in 4 ticks before contact, drawn on one held strike cell). Beat: mid-lunge, front foot forward off the ground, back foot pushing, blade level and forward. Frames: 1 per facing, side (cell 5 order) and camera (cell 6), plus the left side if drawn. Cell size: rivet_eq_katana.png cells (473x256 at p70). Pitches: p70 and p55.

NEXT: (1) wire the flashless fire cells when the asset lane delivers (#9: painted cell for muzzle_ticks, flashless for the rest of the latch); (2) item 4 per gun: film machine_pistol, gatling, plasma_rifle, hand_cannon, gloria, electro_gun, rocket_launcher with `film.mjs weapon:<id> --ppm=64 --on=fire:1+3` and log aim-vs-arm angle (#11) and recoil kick (#12); (3) item 5: figure-height pop at strip handovers (#13), measure each eq/fire cell's figure height vs the walk grid; (4) film the p55 camera strike cells in a boss arena; (5) item 6 arena loop over every weapon; (6) the claw lunge_ticks is an owner Call (replay golden); (7) before the freeze: full gates (lint, unit, scenarios, evidence/run.mjs parity + goldens, reels).
