# Gauntlet strip-card audit (n31-18, view art p70)

Same fit as GauntletPropArt.cover: strip cell 0, width cell_w_m, height / sin(pitch), trimmed to the opaque cell, size = min(card * scale, box - 0.08), foot on the box south edge. Mismatch = box minus drawn lowest-15 cm base per side (m, positive = box reaches beyond the art). `stretch` is the drawn aspect over the art aspect (1 = undistorted; the trim is stretched into the box-clipped rect). The base is only the lowest 15 cm of art: `body w` is the whole card width (above the base the art is usually wider, which is why a still shows the prop filling its outline while the base mismatch reads 0.3-0.6 m). Tolerance 0.25 m; N is not measurable (front card).

| id | art | footprint | base w | body w | card h | stretch | W | E | S | strip verdict | flat verdict (worst) | flagged row |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| plain_block#2:cover_high | bus_stop | 3x1.5 | 2.429 | 2.92 (fills box) | 1.42 | 1.628 | 0.274 | 0.297 | 0.04 | invisible wall 0.297 | ok 0 |  |
| plain_block#3:cover_low | bench | 2.5x1.2 | 2.277 | 2.375 | 1.12 | 1.166 | 0.112 | 0.112 | 0.04 | ok 0 | ok 0 |  |
| crosswalk#2:cover_high | newsstand | 3x2 | 2.336 | 2.92 (fills box) | 1.92 | 1.503 | 0.326 | 0.338 | 0.04 | invisible wall 0.338 | invisible wall 0.253 | confirmed |
| crosswalk#3:cover_low | down_planter_bed | 4x1 | 3.434 | 3.434 | 0.92 | 1.88 | 0.283 | 0.283 | 0.04 | invisible wall 0.283 | ok 0 |  |
| loading_bay#2:cover_high | dock_cargo_tarp | 4x2 | 3.836 | 3.92 (fills box) | 1.92 | 1.716 | 0.09 | 0.074 | 0.04 | ok 0 | ok 0 |  |
| loading_bay#3:cover_high | dock_cargo_tarp | 4x2 | 3.836 | 3.92 (fills box) | 1.92 | 1.716 | 0.09 | 0.074 | 0.04 | ok 0 | ok 0 |  |
| loading_bay#4:cover_high | dock_cargo_tarp | 4x2 | 3.836 | 3.92 (fills box) | 1.92 | 1.716 | 0.09 | 0.074 | 0.04 | ok 0 | ok 0 |  |
| loading_bay#5:cover_low | dock_oil_drums | 2x1.2 | 1.602 | 1.92 (fills box) | 1.12 | 2.666 | 0.176 | 0.222 | 0.04 | ok 0 | invisible wall 0.406 | not confirmed |
| alley_neck#4:cover_high | dumpster | 3x1.7 | 2.358 | 2.92 (fills box) | 1.62 | 1.844 | 0.315 | 0.327 | 0.04 | invisible wall 0.327 | ok 0 |  |
| kiosk_plaza#2:cover_high | coffee_kiosk | 4x4 | 1.667 | 3.91 | 3.92 | 1.404 | 0.878 | 1.455 | 0.04 | invisible wall 1.455 | invisible wall 0.775 | confirmed |
| kiosk_plaza#3:cover_low | down_planter_bed | 4.5x1 | 3.434 | 3.434 | 0.92 | 1.88 | 0.533 | 0.533 | 0.04 | invisible wall 0.533 | ok 0 |  |
| kiosk_plaza#4:cover_low | down_planter_bed | 4.5x1 | 3.434 | 3.434 | 0.92 | 1.88 | 0.533 | 0.533 | 0.04 | invisible wall 0.533 | ok 0 |  |
| market_stalls#2:cover_high | newsstand | 3.2x2 | 2.496 | 3.12 (fills box) | 1.92 | 1.606 | 0.345 | 0.359 | 0.04 | invisible wall 0.359 | invisible wall 0.268 | confirmed |
| market_stalls#3:cover_low | food_cart | 2.3x1.8 | 1.076 | 2.22 (fills box) | 1.72 | 1.805 | 0.601 | 0.624 | 0.04 | invisible wall 0.624 | invisible wall 1.377 | confirmed |
| market_stalls#4:cover_low | food_cart | 2.3x1.8 | 1.076 | 2.22 (fills box) | 1.72 | 1.805 | 0.601 | 0.624 | 0.04 | invisible wall 0.624 | invisible wall 1.377 | confirmed |
| market_stalls#5:cover_low | food_cart | 2.3x1.8 | 1.076 | 2.22 (fills box) | 1.72 | 1.805 | 0.601 | 0.624 | 0.04 | invisible wall 0.624 | invisible wall 1.377 | confirmed |
| market_stalls#6:cover_low | food_cart | 2.3x1.8 | 1.076 | 2.22 (fills box) | 1.72 | 1.805 | 0.601 | 0.624 | 0.04 | invisible wall 0.624 | invisible wall 1.377 | confirmed |
