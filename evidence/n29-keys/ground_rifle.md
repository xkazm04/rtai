# keys n29: the dropped rifle's stock (brief n29-12): measured, nothing to recolour, no art changed

What the game draws for a dead guard's dropped rifle (`GroundRifle.draw` -> `GroundDropShowcase.draw`, `PICKUP = &"assault-rifle"`):
the showcase drawing `project/features/combat/weapons/art/showcase/<form>/assault_rifle.png`, form = the view's art key
(`p70` play pitch 92x256, `p55` boss pitch 80x256). `ground_rifle_70.png` (the 8-heading sheet) is only the fallback when no
showcase form exists (flat view or `--showcase=off`); the cast films at 64 / 32 px/m draw the showcase one.

Measured (band hue <= 20 or >= 300, s > 0.25, v > 0.25, alpha > 0): p70 8 px, p55 4 px; they are dark ink / rivet-edge px, none on
the stock. Stock part (x < 100, opaque, r>g>b): mean hue 26.4 deg (p5-p95 17-30), s about 0.56-0.62 at the lit grain, 3726 px (p70)
/ 3264 px (p55). The stock is already brown wood, in the brief's target hue band; there is no mauve or pink pixel in the file.
The cast count (R>G+60 and R>B+40: 25 px p70, 23 px p55) is exactly the lit wood-grain px, RGB about (190-199,129-137,74-88),
hue 25-29: orange-brown, not pink. The (230,80,97) the cast saw in the mp4 is therefore a yuv420 chroma fringe of this
saturated wood against grey asphalt, not the drawing. 4x crops: `C:/Users/kazda/kiro/gtai-masters/n29/keys/ground_rifle/before_p70_4x.png`, `before_p55_4x.png`
(brown stock, dark steel body, olive sling remnants).

Decision: no recolour (a hue remap would move px that are already in the target band; 0 px changed, nothing to prove outside a mask).
Option if the owner still wants it calmer in encoded video: lower the stock's saturation from about 0.6 to 0.45-0.5 (value kept);
it is a taste call, not a colour-law fix. NEED for that: owner OK, and the same on `icon/assault_rifle.png` (14 strict px).

Not done: the in-game before | after still and the 90x40 pink count (nothing to compare: no change). Tests not run (no file changed).
