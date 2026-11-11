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
