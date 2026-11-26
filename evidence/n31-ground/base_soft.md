# PropBase soft contact shade (n31-28)

Before = 7b73c0d20, after = live (e1c54b29a). Stills 1920x1080 both, 64 px/m yard (mid), gauntlet market_stalls (rule_stills, same size).
Method: column-mean luminance profile (80 px wide) down the south edge below each prop's art outline; darkening = darkest 3-row mean of the pad vs the open floor 35-45 px south; step = max luminance change per px below the outline.

| prop (yard mid) | darkening before -> after | edge step before -> after |
|---|---|---|
| fridge B (clean south edge) | 72.7 -> 68.5 % | 27.7 -> 12.8 (0.46x, bar <= 0.5 met) |
| fridge top | 78.0 -> 71.9 % | 32.9 -> 33.2 (art outline in window) |
| fridge A | 47.4 -> 48.9 % | 51.4 -> 58.2 (art outline in window) |

Only fridge B is a clean read; the others have the art overhanging the pad so the outline dominates the step. Forklift, press_carcass and the gauntlet stalls: looked at (crops in masters item4/base_soft_*), not measured. Look check: pads read as soft contact shade and still as a base; no 0.72 fallback needed.
