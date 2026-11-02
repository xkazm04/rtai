# features/hud/art: D4 HUD frames (night lane d4-production)

Ink-on-cream paper frames with **empty interiors**: the HUD prints its own numbers and words (`tr()` keys) on top.
Authored at 2x: draw at UI scale **0.5** on a 1280 x 800 view (e.g. the cash panel ~353 x 75 px). Mipmaps on.
Doctrine: vermilion only on the full / army wanted pips and the ammo-ticket bullet; teal only on the active soul card.
Master `art_src/d4.manifest.json#d4n_hud`. Layout mock (Python composite, not in-engine):
`masters:night/d4-production/after_h/hud-mock-{32,48}ppm.png`.

| File | px (2x) | Use |
|---|---|---|
| `cash_frame` | 706 x 149 | banknote glyph at the left; text area x 130..680, y 25..125 |
| `wanted_frame` | 665 x 148 | five sockets, centres x = 137.5, 235.5, 334, 432, 530.5, y = 72.5 (inner diameter ~61) |
| `wanted_pip_empty`, `wanted_pip_full`, `wanted_pip_army` | ~148 x 150 | pips: draw at 64 / 148 of the frame's scale, centred on a socket |
| `ammo_ticket` | 649 x 297 | bullet stub left of the perforation (x < 120); count / weapon text area x 135..620 |
| `soul_card`, `soul_card_active` | ~273 x 406 | portrait area inset ~28 px; the active card has the teal border |
| `memo_frame` | 650 x 298 | mission memo / pager text; tape strip across the top |
