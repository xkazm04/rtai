# assets/pickups: D4 pickup tokens (night lane d4-production)

8 bold ink tokens, 128 x 128, seen straight down: a cream disc, a thick ink ring, a thin cream sticker rim, one
big glyph. Draw at about **1.2 m** (38 px at 32 px/m) in the **item pass** (`look_d4_item`, above the world print):
under the world pass the Sobel ink edges fill the glyphs in (tested, `masters:night/d4-production/after_k`).

| File | Accent |
|---|---|
| `cash` | vermilion strap (iteration 2: one solid ink banknote + strap; the first busy grey bundle went muddy at 32 px/m) |
| `cash_coins`, `cash_bundle`, `cash_bag` | value tiers small / medium (vermilion strap) / large; optional |
| `health` | vermilion cross |
| `armor` | solid ink shield, cream chevron (iteration 2) |
| `ammo` | three solid ink cartridges, vermilion tips (iteration 2) |
| `briefcase` | ink, cream clasp |
| `keycard` | solid ink card, cream stripe, vermilion chip (iteration 2) |
| `weapon` | solid ink pistol (iteration 2; the wrench + pistol glyph was busy at 32 px/m) |
| `soul` | **teal** ring and wisp (the dead only) |

Masters `art_src/d4.manifest.json#d4n_pickups` (briefcase, health, soul), `#d4n_cash` (cash + tiers), `#d4n_tokens2`
(weapon, ammo, armor, keycard). Evidence `after_k` -> `after_k2` -> `after_k3`. No pickup system draws them yet.
