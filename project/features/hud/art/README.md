# features/hud/art: D4 HUD frames (night lane d4-production)

Ink-on-cream paper frames with **empty interiors**: the HUD prints its own numbers and words (`tr()` keys) on top.
Authored at 2x: draw at UI scale **0.5** on a 1280 x 800 view (e.g. the cash panel ~353 x 75 px). Mipmaps on.
Doctrine: vermilion only on the full / army wanted pips and the ammo-ticket bullet; teal only on the active soul card.
Master `art_src/d4.manifest.json#d4n_hud`. The frames (not the pips) are **plated**: a 5 px solid ink rim plus an
8,10 px charcoal drop shadow (`masters:night/d4-production/tools/hud_plate.py`), because the bare cream frames melted
into the cream D4 pavement in-engine. The rim adds **7 frame px** before every coordinate below (add (7, 7)).
In-engine layout: `res://dev/showcase/hud_overlay.gd` via `city_frame.tscn -- --hud=0.5,0.4`; evidence
`masters:night/d4-production/after_hud` (bare) vs `after_hud2` (plated). UI scale 0.4 keeps more of the street
visible at 1280 x 800 and still reads; 0.5 is the upper bound.

| File | px (2x, plated) | Use |
|---|---|---|
| `cash_frame` | 728 x 173 | banknote glyph at the left (ends x ~165); text area x 185..680, y 25..125 |
| `wanted_frame` | 687 x 172 | five sockets, centres x = 137.5, 235.5, 334, 432, 530.5, y = 72.5 (inner diameter ~61) |
| `wanted_pip_empty`, `wanted_pip_full`, `wanted_pip_army` | ~148 x 150 | pips: draw at 64 / 148 of the frame's scale, centred on a socket |
| `ammo_ticket` | 671 x 321 | bullet stub left of the perforation (x < 120); count / weapon text area x 135..620 |
| `soul_card`, `soul_card_active` | ~295 x 430 | portrait area inset ~28 px; the active card has the teal border |
| `soul_<id>`, `soul_<id>_idle` | 220 x 350 | soul portraits (`gearbox`, `sentry`, `hauler`, `mop`, the pitch's working names): draw at the card's scale, centred across the card, 40 card px from its top. Teal = the active card; `_idle` is the same portrait in ink for an idle / locked card |
| `memo_frame` | 672 x 322 | mission memo / pager text; tape strip across the top |
| `hud_digits` | 2240 x 160 | hand-inked numeral strip: 20 cells of 112 x 160 in the order `0123456789$/x+-:,.%#`, cap height 120 px centred in the cell (baseline at y 140), ink 17131B with a thin cream rim; advances in strip px: digits 70 (tabular), `$` 70, `/` 58, `x` 74, `+` 66, `-` 62, `:` 36, `,` 32, `.` 32, `%` 98, `#` 80, space 30 (the comma tail hangs to y 158) |

Soul portraits (night iteration 4): master `art_src/d4.manifest.json#d4n_souls`, styled on the D5 concept's teal soul
ghosts (`ref-4-rivet-concept.jpg`); front-on busts, the lower edge dissolving into smoke at the card's foot. The
teal is a pure deep-teal / look_d4-teal / cream ramp (doctrine: teal belongs to the dead). Evidence in-engine:
`masters:night/d4-production/before_soul|after_soul/city-*-hud{40,50}.png` (dev HudOverlay: Gearbox active, Sentry idle).

Quest 1's HUD (`boot/collect_call/view/hud_view.gd` on main, night iteration 6): `cash_frame` drawn into its cash box
(420 x 104 px at 1080p, text from x 112), `wanted_pip_full` / `_empty` as the heat pips (38 px), and `memo_frame` as
a **9-slice** (source margin 44 frame px, drawn at 0.5) for the beat panel and the subtitle box (grown to 236 px tall
so three lines clear the torn edge). Patch and frames: lane masters `q1_view_art.patch`, `before_q1/` vs `after_q1p/`.

Numerals (night iteration 12): `hud_digits.png`, masters `art_src/d4.manifest.json#d4n_digits` + `#d4n_digits2` (Codex, sign-painter
condensed caps matched to the world's "LOCAL 9" lettering). No font is bundled, so the counters are drawn from this
strip (own art; no font licence needed for digits). A real HUD can wrap it as a Godot image font or draw one
`AtlasTexture` per glyph (as the dev overlay does: cap height = 0.92 of the old Label font size). Words still need a
font (AST-10, owner OK). Evidence: `masters:night/d4-production/before_i12h|after_i12h2/city-*-hud{40,50}.png`.
