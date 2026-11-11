# JOURNAL - n17 rivet-strike

## Session 1 (2026-11-11 20:02-21:32), BUILD

- Read: brief, common rules, AGENTS.md, decisions tail, tools/README.md, HUD code (hud_view, hud_feed, WeaponShowcase).
- Registry: item 1 is HUD layout, not combat semantics; no subject governs it directly (sprite-and-atlas-production only for the ICON form choice: the asset drawn for the display it is shown on).
- DECISION hud/weapon-slot: bottom-right slot, showcase ICON cut + WEAPON__<id> name + magazine count; above the subtitle while a line is up (cut); `--hud-weapon=off` = before. (docs/decisions.md)
- FRICTION: the arena/city film hides the HUD (arena_game.gd:59), so HUD evidence comes from the dialogue board (`dev/showcase/dialogue_board.gd --slots`) over a filmed city frame (t400 of `film.mjs city`).
