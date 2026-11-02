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
| `memo_frame` | 672 x 322 | mission memo / pager text; tape strip across the top |
