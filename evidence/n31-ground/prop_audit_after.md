# Prop audit after (n31-19: yard conveyor boxes on the drawn machines, 12 arch supports solid, fuel_vessel art cropped to its box; gauntlet rows below are flat-art, see prop_audit_strip_after.md)

Gauntlet measured on the flat art (city/art/props PNG, 48 px/m); the tilt70 strip cards the game actually shows are NOT measured here. In the tilt70 stills (masters n31/ground/item4/audit_gauntlet_before.png) market stalls, kiosk and loading-bay props fill their footprint outline, so the gauntlet "invisible wall" rows below are flat-art numbers and are re-measured on the tilt70 strip cards in prop_audit_strip.md (n31-18: 7 of the 8 flagged rows confirmed). The yard numbers read the art the yard really draws. The existing overlays (show_solid_bounds, --footprints) draw one thin white outline for every solid and do not label class. Tolerance 0.25 m. Mismatch = footprint minus drawn base per side in m (positive: the footprint reaches beyond the drawing). Gauntlet N is not measurable (front-facing card).

```json
{
 "props": 140,
 "solid": 68,
 "solid_mismatch_over_0_25_m": 8,
 "solid_unmeasured": 0,
 "decorative_looks_solid": 29,
 "by_verdict": {
  "ok": 97,
  "decorative-looks-solid candidate": 27,
  "invisible wall": 8,
  "overhead span (passable by rule: offset floor shadow, no base)": 6,
  "decorative-looks-solid": 2
 }
}
```

| arena | id | class | footprint m | drawn base m | W | E | N | S | verdict | worst m |
|---|---|---|---|---|---|---|---|---|---|---|
| gauntlet | plain_block#0:wall_high | blocks movement + shots | 30x1 |  |  |  |  |  | ok | 0 |
| gauntlet | plain_block#1:wall_high | blocks movement + shots | 30x1 |  |  |  |  |  | ok | 0 |
| gauntlet | plain_block#2:cover_high | blocks movement + shots | 3x1.5 | 2.92 x front card, no floor depth | 0.04 | 0.04 | 1.377 | 0.04 | ok | 0 |
| gauntlet | plain_block#3:cover_low | blocks movement + shots | 2.5x1.2 | 2.42 x front card, no floor depth | 0.04 | 0.04 | 1.02 | 0.04 | ok | 0 |
| gauntlet | plain_block:payphone@11,-6.7 | decorative | h 2.275 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | plain_block:street_sign@22,-6.6 | decorative | h 0.958 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | plain_block:bike_racks@8,7.6 | decorative | h 1.627 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | crosswalk#0:wall_high | blocks movement + shots | 32x1 |  |  |  |  |  | ok | 0 |
| gauntlet | crosswalk#1:wall_high | blocks movement + shots | 32x1 |  |  |  |  |  | ok | 0 |
| gauntlet | crosswalk#2:cover_high | blocks movement + shots | 3x2 | 2.509 x front card, no floor depth | 0.238 | 0.253 | 1.867 | 0.04 | invisible wall | 0.253 |
| gauntlet | crosswalk#3:cover_low | blocks movement + shots | 4x1 | 3.92 x front card, no floor depth | 0.04 | 0.04 | 0.904 | 0.04 | ok | 0 |
| gauntlet | crosswalk:traffic_light@13,-6.35 | decorative | h 1.35 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | crosswalk:traffic_light@19,7.25 | decorative | h 1.35 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | crosswalk:down_bollards@9,7.35 | decorative | h 1.5 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | barricade_line#0:wall_high | blocks movement + shots | 30x1 |  |  |  |  |  | ok | 0 |
| gauntlet | barricade_line#1:wall_high | blocks movement + shots | 30x1 |  |  |  |  |  | ok | 0 |
| gauntlet | barricade_line#2:cover_high | blocks movement + shots | 1.25x4.5 |  |  |  |  |  | ok | 0 |
| gauntlet | barricade_line#3:cover_low | blocks movement + shots | 1.25x4 |  |  |  |  |  | ok | 0 |
| gauntlet | barricade_line#4:cover_high | blocks movement + shots | 1.25x4 |  |  |  |  |  | ok | 0 |
| gauntlet | barricade_line:traffic_cone@9,-6.45 | decorative | h 0.917 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | barricade_line:traffic_cone@22,-6.45 | decorative | h 0.917 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | barricade_line:traffic_cone@15,6.95 | decorative | h 0.917 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | barricade_line:barricade@14,7.35 | decorative | h 4 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | loading_bay#0:wall_high | blocks movement + shots | 28x1 |  |  |  |  |  | ok | 0 |
| gauntlet | loading_bay#1:wall_high | blocks movement + shots | 28x1 |  |  |  |  |  | ok | 0 |
| gauntlet | loading_bay#2:cover_high | blocks movement + shots | 4x2 | 3.657 x front card, no floor depth | 0.195 | 0.148 | 1.876 | 0.04 | ok | 0 |
| gauntlet | loading_bay#3:cover_high | blocks movement + shots | 4x2 | 3.657 x front card, no floor depth | 0.195 | 0.148 | 1.876 | 0.04 | ok | 0 |
| gauntlet | loading_bay#4:cover_high | blocks movement + shots | 4x2 | 3.657 x front card, no floor depth | 0.195 | 0.148 | 1.876 | 0.04 | ok | 0 |
| gauntlet | loading_bay#5:cover_low | blocks movement + shots | 2x1.2 | 1.213 x front card, no floor depth | 0.381 | 0.406 | 1.109 | 0.04 | invisible wall | 0.406 |
| gauntlet | loading_bay:container2@6,-6.5 | decorative | h 4 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | loading_bay:dock_scrap_skip@24,-6.55 | decorative | h 4.396 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | loading_bay:barrel_cluster@18,7.5 | decorative | h 3.333 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | alley_neck#0:wall_high | blocks movement + shots | 32x1 |  |  |  |  |  | ok | 0 |
| gauntlet | alley_neck#1:wall_high | blocks movement + shots | 32x1 |  |  |  |  |  | ok | 0 |
| gauntlet | alley_neck#2:wall_high | blocks movement + shots | 12x2 |  |  |  |  |  | ok | 0 |
| gauntlet | alley_neck#3:wall_high | blocks movement + shots | 12x2 |  |  |  |  |  | ok | 0 |
| gauntlet | alley_neck#4:cover_high | blocks movement + shots | 3x1.7 | 2.92 x front card, no floor depth | 0.04 | 0.04 | 1.566 | 0.04 | ok | 0 |
| gauntlet | alley_neck:down_litter_bins@5,-6.45 | decorative | h 1.484 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | alley_neck:lamp_post@26,-6.5 | decorative | h 0.934 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | alley_neck:bike_racks@25,7 | decorative | h 1.479 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | kiosk_plaza#0:wall_high | blocks movement + shots | 34x1 |  |  |  |  |  | ok | 0 |
| gauntlet | kiosk_plaza#1:wall_high | blocks movement + shots | 34x1 |  |  |  |  |  | ok | 0 |
| gauntlet | kiosk_plaza#2:cover_high | blocks movement + shots | 4x4 | 2.475 x front card, no floor depth | 0.775 | 0.75 | 3.84 | 0.04 | invisible wall | 0.775 |
| gauntlet | kiosk_plaza#3:cover_low | blocks movement + shots | 4.5x1 | 4.42 x front card, no floor depth | 0.04 | 0.04 | 0.904 | 0.04 | ok | 0 |
| gauntlet | kiosk_plaza#4:cover_low | blocks movement + shots | 4.5x1 | 4.42 x front card, no floor depth | 0.04 | 0.04 | 0.904 | 0.04 | ok | 0 |
| gauntlet | kiosk_plaza:down_street_clock@10,-6.6 | decorative | h 2.1 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | kiosk_plaza:down_plaza_steps@17,-6.85 | decorative | h 3.522 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | kiosk_plaza:bench@23,7.4 | decorative | h 1.4 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | kiosk_plaza:down_chess_tables@8,7.5 | decorative | h 7.2 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | underpass#0:wall_high | blocks movement + shots | 32x1 |  |  |  |  |  | ok | 0 |
| gauntlet | underpass#1:wall_high | blocks movement + shots | 32x1 |  |  |  |  |  | ok | 0 |
| gauntlet | underpass#2:cover_high | blocks movement + shots | 2.3x2 |  |  |  |  |  | ok | 0 |
| gauntlet | underpass#3:cover_high | blocks movement + shots | 2.3x2 |  |  |  |  |  | ok | 0 |
| gauntlet | underpass#4:cover_high | blocks movement + shots | 2.3x2 |  |  |  |  |  | ok | 0 |
| gauntlet | underpass#5:cover_high | blocks movement + shots | 2.3x2 |  |  |  |  |  | ok | 0 |
| gauntlet | underpass:lamp_post@6,-6.5 | decorative | h 0.813 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | underpass:lamp_post@28,-6.5 | decorative | h 0.813 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | underpass:bike_racks@27,7.2 | decorative | h 1.627 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | market_stalls#0:wall_high | blocks movement + shots | 34x1 |  |  |  |  |  | ok | 0 |
| gauntlet | market_stalls#1:wall_high | blocks movement + shots | 34x1 |  |  |  |  |  | ok | 0 |
| gauntlet | market_stalls#2:cover_high | blocks movement + shots | 3.2x2 | 2.681 x front card, no floor depth | 0.251 | 0.268 | 1.867 | 0.04 | invisible wall | 0.268 |
| gauntlet | market_stalls#3:cover_low | blocks movement + shots | 2.3x1.8 | 0.358 x front card, no floor depth | 1.377 | 0.565 | 1.692 | 0.04 | invisible wall | 1.377 |
| gauntlet | market_stalls#4:cover_low | blocks movement + shots | 2.3x1.8 | 0.358 x front card, no floor depth | 1.377 | 0.565 | 1.692 | 0.04 | invisible wall | 1.377 |
| gauntlet | market_stalls#5:cover_low | blocks movement + shots | 2.3x1.8 | 0.358 x front card, no floor depth | 1.377 | 0.565 | 1.692 | 0.04 | invisible wall | 1.377 |
| gauntlet | market_stalls#6:cover_low | blocks movement + shots | 2.3x1.8 | 0.358 x front card, no floor depth | 1.377 | 0.565 | 1.692 | 0.04 | invisible wall | 1.377 |
| gauntlet | market_stalls:down_flower_crates@8,-6.8 | decorative | h 2.578 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | market_stalls:dock_cargo_tarp@20,7.5 | decorative | h 3 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | market_stalls:down_flower_crates@26,-7.1 | decorative | h 2.372 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| gauntlet | market_stalls:bench@10,7.7 | decorative | h 1.342 |  |  |  |  |  | decorative-looks-solid candidate | 0 |
| yard | pallet_west | blocks movement + shots | 2.4x1.6 | 2.025 x 1.561 | 0.195 | 0.18 | 0.023 | 0.016 | ok | 0 |
| yard | fuel_vessel | blocks movement + shots | 2.4x1.6 | 2.361 x 1.567 | 0.023 | 0.016 | 0.011 | 0.022 | ok | 0 |
| yard | burnt_pickup | blocks movement + shots | 4.3x2.7 | 4.3 x 2.7 | 0 | 0 | 0 | 0 | ok | 0 |
| yard | press_carcass | blocks movement + shots | 2.5x3.7 | 2.5 x 3.7 | 0 | 0 | 0 | 0 | ok | 0 |
| yard | fallen_fridges | blocks movement + shots | 4x1.8 | 4 x 1.8 | 0 | 0 | 0 | 0 | ok | 0 |
| yard | scrap_skip | blocks movement + shots | 4.4x2.4 | 4.4 x 2.4 | 0 | 0 | 0 | 0 | ok | 0 |
| yard | stack_broken_sw | blocks movement + shots | 2.4x0.85 | 2.369 x 0.819 | 0.023 | 0.008 | 0.016 | 0.016 | ok | 0 |
| yard | stack_double_west | blocks movement + shots | 2.4x1 | 2.369 x 0.977 | 0.023 | 0.008 | 0.008 | 0.016 | ok | 0 |
| yard | arch_door | passable (not in layout.cover) | 8.668x3.806 |  |  |  |  |  | ok | 0 |
| yard | arch_feed | passable (not in layout.cover) | 8.646x4.598 |  |  |  |  |  | ok | 0 |
| yard | arch_turn | passable (not in layout.cover) | 8.723x3.817 |  |  |  |  |  | ok | 0 |
| yard | arch_return | passable (not in layout.cover) | 8.646x4.598 |  |  |  |  |  | ok | 0 |
| yard | arch_bend | passable (not in layout.cover) | 8.668x3.806 |  |  |  |  |  | ok | 0 |
| yard | arch_tail | passable (not in layout.cover) | 8.921x3.674 |  |  |  |  |  | ok | 0 |
| yard | span_door_feed | passable (not in layout.cover) | 8.514x4.928 |  |  |  |  |  | overhead span (passable by rule: offset floor shadow, no base) | 0 |
| yard | span_feed_turn | passable (not in layout.cover) | 6.039x5.269 |  |  |  |  |  | overhead span (passable by rule: offset floor shadow, no base) | 0 |
| yard | span_turn_return | passable (not in layout.cover) | 7.161x6.204 |  |  |  |  |  | overhead span (passable by rule: offset floor shadow, no base) | 0 |
| yard | span_return_bend | passable (not in layout.cover) | 6.963x7.491 |  |  |  |  |  | overhead span (passable by rule: offset floor shadow, no base) | 0 |
| yard | span_bend_tail | passable (not in layout.cover) | 4.367x5.687 |  |  |  |  |  | overhead span (passable by rule: offset floor shadow, no base) | 0 |
| yard | span_mouth_door | passable (not in layout.cover) | 8.789x5.192 |  |  |  |  |  | overhead span (passable by rule: offset floor shadow, no base) | 0 |
| yard | conveyor_door vs arch_door | blocks movement + shots | 4.19x1.2 | 8.481 x 0.154 | -2.161 | -2.13 | 1.046 | 0 | ok | 0 |
| yard | conveyor_feed vs arch_feed | blocks movement + shots | 4.04x1.2 | 8.459 x 0.154 | -1.884 | -2.535 | 1.049 | -0.003 | ok | 0 |
| yard | conveyor_turn vs arch_turn | blocks movement + shots | 4.22x1.2 | 8.525 x 0.154 | -2.131 | -2.174 | 1.047 | -0.001 | ok | 0 |
| yard | conveyor_return vs arch_return | blocks movement + shots | 4.04x1.2 | 8.459 x 0.154 | -2.535 | -1.884 | 1.049 | -0.003 | ok | 0 |
| yard | conveyor_bend vs arch_bend | blocks movement + shots | 4.19x1.2 | 8.481 x 0.154 | -2.13 | -2.161 | 1.046 | 0 | ok | 0 |
| yard | conveyor_tail vs arch_tail | blocks movement + shots | 4.41x1.2 | 8.734 x 0.154 | -1.966 | -2.358 | 1.047 | -0.001 | ok | 0 |
| yard | leg_door_1 vs arch_door | blocks movement + shots | 1.93x0.3 | 1.914 x 0.311 | 0.011 | 0.005 | 0 | -0.011 | ok | 0 |
| yard | leg_door_2 vs arch_door | blocks movement + shots | 2.03x0.3 | 2.024 x 0.313 | -0.004 | 0.01 | 0 | -0.013 | ok | 0 |
| yard | leg_feed_1 vs arch_feed | blocks movement + shots | 1.65x0.3 | 1.65 x 0.312 | -0.008 | 0.008 | 0 | -0.012 | ok | 0 |
| yard | leg_feed_2 vs arch_feed | blocks movement + shots | 0.58x0.3 | 0.682 x 0.309 | 0.005 | -0.107 | 0 | -0.009 | ok | 0 |
| yard | leg_turn_1 vs arch_turn | blocks movement + shots | 1.85x0.3 | 1.848 x 0.31 | 0 | 0.002 | 0 | -0.01 | ok | 0 |
| yard | leg_turn_2 vs arch_turn | blocks movement + shots | 2.04x0.3 | 2.046 x 0.314 | -0.004 | -0.002 | 0 | -0.014 | ok | 0 |
| yard | leg_return_1 vs arch_return | blocks movement + shots | 0.58x0.3 | 0.682 x 0.309 | -0.107 | 0.005 | 0 | -0.009 | ok | 0 |
| yard | leg_return_2 vs arch_return | blocks movement + shots | 1.65x0.3 | 1.65 x 0.312 | -0.002 | 0.002 | 0 | -0.012 | ok | 0 |
| yard | leg_bend_1 vs arch_bend | blocks movement + shots | 2.02x0.3 | 2.024 x 0.313 | -0.005 | 0.001 | 0 | -0.013 | ok | 0 |
| yard | leg_bend_2 vs arch_bend | blocks movement + shots | 1.93x0.3 | 1.914 x 0.311 | -0.005 | 0.021 | 0 | -0.011 | ok | 0 |
| yard | leg_tail_1 vs arch_tail | blocks movement + shots | 0.52x0.3 | 0.594 x 0.313 | -0.004 | -0.07 | 0 | -0.013 | ok | 0 |
| yard | leg_tail_2 vs arch_tail | blocks movement + shots | 1.13x0.3 | 1.155 x 0.375 | -0.128 | 0.103 | 0 | -0.075 | ok | 0 |
| yard | gate_lamp@41.2,32.5 | decorative | h 1.6 |  |  |  |  |  | decorative-looks-solid | 0 |
| yard | hook_drum@34.15,8.79 | decorative | h 0.88 |  |  |  |  |  | decorative-looks-solid | 0 |
| yard | drag_door | decorative |  |  |  |  |  |  | ok | 0 |
| yard | drag_feed | decorative |  |  |  |  |  |  | ok | 0 |
| yard | drag_turn | decorative |  |  |  |  |  |  | ok | 0 |
| yard | drag_return | decorative |  |  |  |  |  |  | ok | 0 |
| yard | drag_tail | decorative |  |  |  |  |  |  | ok | 0 |
| yard | enamel_feed | decorative |  |  |  |  |  |  | ok | 0 |
| yard | enamel_turn | decorative |  |  |  |  |  |  | ok | 0 |
| yard | enamel_tail | decorative |  |  |  |  |  |  | ok | 0 |
| yard | belt_door | decorative |  |  |  |  |  |  | ok | 0 |
| yard | roller_door_1 | decorative |  |  |  |  |  |  | ok | 0 |
| yard | roller_door_2 | decorative |  |  |  |  |  |  | ok | 0 |
| yard | roller_door_3 | decorative |  |  |  |  |  |  | ok | 0 |
| yard | belt_feed | decorative |  |  |  |  |  |  | ok | 0 |
| yard | roller_feed_1 | decorative |  |  |  |  |  |  | ok | 0 |
| yard | roller_feed_2 | decorative |  |  |  |  |  |  | ok | 0 |
| yard | roller_feed_3 | decorative |  |  |  |  |  |  | ok | 0 |
| yard | belt_turn | decorative |  |  |  |  |  |  | ok | 0 |
| yard | roller_turn_1 | decorative |  |  |  |  |  |  | ok | 0 |
| yard | roller_turn_2 | decorative |  |  |  |  |  |  | ok | 0 |
| yard | roller_turn_3 | decorative |  |  |  |  |  |  | ok | 0 |
| yard | belt_return | decorative |  |  |  |  |  |  | ok | 0 |
| yard | roller_return_1 | decorative |  |  |  |  |  |  | ok | 0 |
| yard | roller_return_2 | decorative |  |  |  |  |  |  | ok | 0 |
| yard | roller_return_3 | decorative |  |  |  |  |  |  | ok | 0 |
| yard | belt_tail | decorative |  |  |  |  |  |  | ok | 0 |
| yard | roller_tail_1 | decorative |  |  |  |  |  |  | ok | 0 |
| yard | roller_tail_2 | decorative |  |  |  |  |  |  | ok | 0 |
| yard | roller_tail_3 | decorative |  |  |  |  |  |  | ok | 0 |
| yard | washer_feed | decorative |  |  |  |  |  |  | ok | 0 |
| yard | door_return | decorative |  |  |  |  |  |  | ok | 0 |
| yard | washer_tail | decorative |  |  |  |  |  |  | ok | 0 |
