# Gauntlet strip-card audit after n31-19 (view art p70): GauntletPropArt.cover base-fit (trim undistorted, lowest 15 cm spans the box, past 2x the body spans it); the intro below describes the n31-18 fit, kept as `legacy` in strip_cards.mjs

Same fit as GauntletPropArt.cover: strip cell 0, width cell_w_m, height / sin(pitch), trimmed to the opaque cell, size = min(card * scale, box - 0.08), foot on the box south edge. Mismatch = box minus drawn lowest-15 cm base per side (m, positive = box reaches beyond the art). `stretch` is the drawn aspect over the art aspect (1 = undistorted; the trim is stretched into the box-clipped rect). The base is only the lowest 15 cm of art: `body w` is the whole card width (above the base the art is usually wider, which is why a still shows the prop filling its outline while the base mismatch reads 0.3-0.6 m). Tolerance 0.25 m; N is not measurable (front card).

| id | art | footprint | base w | body w | card h | stretch | W | E | S | strip verdict | flat verdict (worst) | flagged row |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| plain_block#2:cover_high | bus_stop | 3x1.5 | 2.92 | 3.578 (fills box) | 2.833 | 1 | 0.04 | 0.04 | 0.04 | ok 0 | ok 0 |  |
| plain_block#3:cover_low | bench | 2.5x1.2 | 2.42 | 2.524 (fills box) | 1.388 | 1 | 0.04 | 0.04 | 0.04 | ok 0 | ok 0 |  |
| crosswalk#2:cover_high | newsstand | 3x2 | 2.904 | 3.67 (fills box) | 3.628 | 1 | 0.04 | 0.056 | 0.04 | ok 0 | invisible wall 0.253 | not confirmed |
| crosswalk#3:cover_low | down_planter_bed | 4x1 | 3.92 | 3.92 (fills box) | 1.974 | 1 | 0.04 | 0.04 | 0.04 | ok 0 | ok 0 |  |
| loading_bay#2:cover_high | dock_cargo_tarp | 4x2 | 3.92 | 4.077 (fills box) | 3.427 | 1 | 0.04 | 0.04 | 0.04 | ok 0 | ok 0 |  |
| loading_bay#3:cover_high | dock_cargo_tarp | 4x2 | 3.92 | 4.077 (fills box) | 3.427 | 1 | 0.04 | 0.04 | 0.04 | ok 0 | ok 0 |  |
| loading_bay#4:cover_high | dock_cargo_tarp | 4x2 | 3.92 | 4.077 (fills box) | 3.427 | 1 | 0.04 | 0.04 | 0.04 | ok 0 | ok 0 |  |
| loading_bay#5:cover_low | dock_oil_drums | 2x1.2 | 1.86 | 2.535 (fills box) | 3.943 | 1 | 0.085 | 0.055 | 0.04 | ok 0 | invisible wall 0.406 | not confirmed |
| alley_neck#4:cover_high | dumpster | 3x1.7 | 2.871 | 3.817 (fills box) | 3.906 | 1 | 0.056 | 0.073 | 0.04 | ok 0 | ok 0 |  |
| kiosk_plaza#2:cover_high | coffee_kiosk | 4x4 | 1.671 | 3.92 (fills box) | 5.517 | 1 | 0.875 | 1.454 | 0.04 | invisible wall 1.454 | invisible wall 0.775 | confirmed |
| kiosk_plaza#3:cover_low | down_planter_bed | 4.5x1 | 4.42 | 4.42 (fills box) | 2.226 | 1 | 0.04 | 0.04 | 0.04 | ok 0 | ok 0 |  |
| kiosk_plaza#4:cover_low | down_planter_bed | 4.5x1 | 4.42 | 4.42 (fills box) | 2.226 | 1 | 0.04 | 0.04 | 0.04 | ok 0 | ok 0 |  |
| market_stalls#2:cover_high | newsstand | 3.2x2 | 3.103 | 3.922 (fills box) | 3.877 | 1 | 0.04 | 0.057 | 0.04 | ok 0 | invisible wall 0.268 | not confirmed |
| market_stalls#3:cover_low | food_cart | 2.3x1.8 | 0.252 | 2.22 (fills box) | 3.105 | 1 | 1.013 | 1.036 | 0.04 | invisible wall 1.036 | invisible wall 1.377 | confirmed |
| market_stalls#4:cover_low | food_cart | 2.3x1.8 | 0.252 | 2.22 (fills box) | 3.105 | 1 | 1.013 | 1.036 | 0.04 | invisible wall 1.036 | invisible wall 1.377 | confirmed |
| market_stalls#5:cover_low | food_cart | 2.3x1.8 | 0.252 | 2.22 (fills box) | 3.105 | 1 | 1.013 | 1.036 | 0.04 | invisible wall 1.036 | invisible wall 1.377 | confirmed |
| market_stalls#6:cover_low | food_cart | 2.3x1.8 | 0.252 | 2.22 (fills box) | 3.105 | 1 | 1.013 | 1.036 | 0.04 | invisible wall 1.036 | invisible wall 1.377 | confirmed |
