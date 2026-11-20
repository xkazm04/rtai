# n20 flight, package 1b (follow-up to your interface session): spectral sheets in GhostDrawn

The ghost lanes have started. Three of them draw the new tilted body as whole-body POSE cells (no walk
cycle) and need GhostDrawn to show them under the spectral look. Their requests:
- ohm (NEED flight, 00:24): under spectral, load `<card>_spec_hover.png` (5 facing rows like the legacy
  sheets; col 0 idle, col 1 drift/cruise chosen by GhostHover speed above ~0.5 m/s; a `_left.png` twin
  optional, else mirrored as today) in place of walk8/run16, and `<card>_spec_act.png` (same 4 act columns as
  the legacy act sheet: wind-up, strike, follow, hit) in place of `<card>_act.png`, each only when the file
  exists under `art/view/<art>/` (fallback: the legacy sheets with your hover standing column). Plus a public
  `func sprite() -> Sprite2D` (the shown sprite after step) so a form can lay a mask overlay on the exact cell.
- tonnage (00:17): pose sheet of 4 poses x 5 facings (carry / cruise / armed / recoil), act sheet of 4.
- dent: body to the belt + short plume; the long comet tail is the shared GhostTail; Dent draws glass shards
  OVER the tail and needs the tail's geometry.

Build, in flight's files only (`ghost_drawn.gd`, `ghost_sheet.gd`, `ghost_tail.gd`, `ghost_flight.gd`,
README), keeping every name you already committed:
1. GhostDrawn under the spectral look (`hover == true`): if `path_of(art, card, "spec_hover")` exists, load it
   as the pose sheet (columns = the PNG's width / its cell width: read the cell size the way GhostSheet does
   for the other sheets, or a `const SPEC_CELL` documented in the README if the sheets fix it; say which), and
   `spec_act` likewise in place of `act`. Column choice: `var pose: int = -1` a form may set each frame
   (`-1` = automatic: col 0 below `SPEC_CRUISE_MPS` = 0.5 m/s, col 1 at or above; a sheet with one column
   always col 0). Act columns win over pose exactly as act wins over walk today. Missing files = today's
   legacy-sheet hover behaviour. No walk phase, no stride, no run grid under spectral.
2. `func sprite() -> Sprite2D` on GhostDrawn. And (ohm, 00:5x): `_instant_windup` (set for card "ohm" from
   `bolt_windup_ticks`) becomes a public `var instant_windup: int`, and it is 0 when
   `GhostLook.spectral(&"ohm")` (the spectral Ohm goes straight to the strike column on an instant bolt; the
   delayed cast `release_tick` path keeps its real wind-up exactly as now). Legacy unchanged. A unit test.
3. GhostTail: a public read of its geometry for overlays: `func points() -> PackedVector2Array` (root first,
   world/canvas px as drawn this frame) and `func half_widths() -> PackedFloat32Array` (same length), and
   `GhostFlight.tail` readable. Document both in README "Spectral look" with the sheet naming
   (`<card>_spec_hover.png`, `<card>_spec_hover_left.png`, `<card>_spec_act.png`, rows = the legacy 5 facings,
   cell size), the `pose` value, `sprite()`, and the tail geometry.
4. Tests: a unit test with a tiny generated sheet (TestTmp dir, or a committed 2-column test fixture under
   `project/tests/support/` if loading from user:// does not work with ResourceLoader; say which) that pose -1
   picks col 0 still and col 1 moving, a set pose wins, act wins over pose, and a missing sheet falls back.
5. Checks: `node tools/godot/check.mjs` on changed files, `node tools/lint/lint.mjs`,
   `node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs`. Legacy look unchanged.
6. One commit: `Draw spectral pose and act sheets in GhostDrawn under the spectral look`. Then stop and
   report (sha, checks). Same environment rules as before (APPDATA, GODOT_BIN, stage per path, never push).

## Also (dent, NEED flight 00:5x)
- GhostFormView keeps calling `DentBody.step(...)` under the spectral look, with the Dent body placed by its
  GhostFlight (`body_offset/body_scale/body_rotation`, or the mount) exactly like the other three; DentBody
  decides what it draws (under spectral it hides GhostDrawn's sprite itself). Dent does NOT use the
  spec_hover/spec_act sheets. Say in your report how DentBody is driven under spectral now and confirm it.
- Dent's glass shards ride the tail: item 3's `points()` / `half_widths()` serve that.
