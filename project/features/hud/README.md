# features/hud

Feature `hud`: its scene, script and local art together. Depends only on `core/` and WorldContext (LAY-05).

## The HUD (slice-play, 2026-11-03)

- `hud_view.gd` (`HudView`, a Node2D under a CanvasLayer) draws a `HudState` (`hud_state.gd`: plain
  values, words already translated) each frame: the beat panel with heat as police pips, the cash
  frame in the inked numerals, the weapon on the ammo ticket, and the subtitle box.
- Art comes **by id** from `data/tables/hud_art.json` through `HudArt` (`hud_art.gd`), never by path
  in the scene. To swap a frame, change its row's `art` (and `size_px` if the authored size moved).
  An unknown id or a file that fails to load draws a flat ink square and logs once; it never crashes.
- The caller fills the state: quest 1 does it in `boot/collect_call/view/hud_feed.gd` (`HudFeed`).
  The feature reads no quest or stage internals (LAY-05).
- The soul cards are not drawn while the soul trail is descoped (owner verdict 3). The art stays here.
