# d5-city evidence index (2026-11-03, branch d-city)

Lane goal: the real generated city at gameplay zoom looks like the D5 hero scene (H2) and the target
mock (T1). Every folder holds real-game frames from `dev/showcase/city_frame.tscn` (real World +
CitySystem + CityView, seed 91) unless its README says otherwise. Frames for the owner's page:
`gtai-masters/day-d5/d5-city/frames.json` (15 entries) and `ladder.png` (copy: ladder-iter5.png, 6 foci).

## Adopted (in the generator / look stack)

| folder | change |
|---|---|
| 01-doctrine | palette `blood`, `blood_dark`, `cop_blue`, `cop_blue_hi`; accent audit: vermilion on cops is debt; `noir` look row |
| 03-prop-shadows | hero-scene hatched cast shadow lengths for props and parked cars |
| 04-d5-roofs | the 7 landmark roofs draw n-d5's D5 plates |
| 05-parapets | parapet ink core on every building |
| 06-siren | siren strobes cop_blue_hi |
| 07, 08, 12 | zebras kerb to kerb outside the crossing, dashes stop short, no edge lines (T1 streets) |
| 09-wall-clutter | crates / dumpsters / vending / bins flush to the walls |
| 14-plaza | plaza dressing on fixed slots, no vermilion barrels |
| 15-lamp | the inked D5 lamp post |
| 16-no-arrows | no lane arrows (T1 has none) |
| 17-snap-cam | pixel-snapped world camera: no swim under a pan (0.02 vs 6.9 mean change per frame) |
| 18-d5-earlier | D5 overlay from 32 px/m (0.5 / 0.75 at 48 / 1 at 64), gated against D4 |
| 19-corner-lamps | two junction corners carry street lamps (T1), two keep signals |
| 20-story-paint | H2's STRIKE and union fist road paint on 8% of lane tiles |
| 22, 23, 25 | T1-scale rooftops: one 16.4 m building (3 Codex plates A/B/C, 80 px/m) over the 2 x 2 interior of 35% of blocks; plates cycle along a block row |

Also: 10-drive (48 px/m car drive frame), 13-bench (contended bench + D5 cost per pass at 64 px/m),
21-overlay-cost (D5 overlay cost at 32/48/64), 24-bench-end (end-of-day bench PASS, contended),
evidence-9df230f (all gates PASS on a clean tree),
11-road-width-mock (concept, labelled).

## Rejected by eye (frames kept)

package v9 print `d5c` at 32 px/m (02), D5 sidewalk tile alone (rejected-d5-sidewalk-32ppm.png), plain
D5 lamp (rejected/), axis-aligned corner traffic lights (rejected/), full D5 at 32 px/m (18), the
corner lamp turned into the block (19), the chalk robot decal (20).

## Owner calls for the 18:00 sync

1. Road width: ~17 m kerb to kerb vs T1 ~10 m; the biggest remaining gap at 48/64 px/m (frames are
   mostly asphalt). What-if mock: 11-road-width-mock/. Sim data: needs vehicles + slice-play.
2. Plazas: 12% of blocks are open plazas; T1 has none.
3. D5 at gameplay zoom: adopted at 0.5 (32 px/m) / 0.75 (48). Pure D4 back is one number.
4. Share of T1-scale 2 x 2 buildings: 35% of blocks now; T1 is that coarse almost everywhere.

## Not this lane's (requests in JOURNAL.md)

Cop vermilion on rigs / crowd atlas (d5-cast), cruiser accents (vehicles), blood palette names (d5-combat).
