# KILLS: the existing signature deaths, ranked (n16 kills-polish)

Doctrine (owner 2026-11-11): each kill is a small, inventive, readable piece of animation that rewards the player;
gore = drawn innards, bone and skulls in riso ink-and-cream, red for blood only; pacing = hit-stop (<= ~6 ticks) plus a
camera punch, never slow motion; reads at 32 px/m in a crowd; leaves an aftermath on the street.

Scores 1-5 per axis: **Read** (at 32 px/m in a crowd), **Invent** (inventive, ours), **Brutal** (within the gore level),
**After** (what stays on the street). **Seen** = how often a player meets it (H/M/L: H = a reel/arena main weapon).
Work order = weakest total among the most seen first.

Status: iteration 3 (13:52-15:20): electro (A3 per kind), plasma hole (A4) and chainsaw (A5 chunks) raised on films. Iteration 2 (12:30-14:00): rocket, katana, plasma sword, chainsaw, electro, hand cannon, homing shard and mini nuke scored on films; iteration 1 draft for the rest. Beat sheets are from the rows (`signature_kills.json` docs) and the FX code; the
"film" column says which are confirmed on a film of this branch. Scores marked `?` are provisional until filmed.

| # | Row | Seen | Beat sheet (anticipation / impact / held beat / aftermath) | Read | Invent | Brutal | After | Total | Film |
|---|---|---|---|---|---|---|---|---|---|
| 1 | rocket_gib | H | - / blast, body into 6 drawn torn pieces (n16: every human kind WITH BONE, fdb3a0d2d + 76f023a08) / no hold (hit-stop 0) / pieces, red fan + ink splat, scorch 1.3 m | 3 | 3 | 4 (bone at 64; lost at 32) | 4 | 14 | bone64/32_patrol it2: bone reads at 64 px/m, not at 32 (pieces ~10-15 px over the smoke) |
| 2 | katana_split | H | wind-up cell / diagonal cut, 6-tick hit-stop, streak 1 m x 0.06 m / halves part and topple away from each other / two halves lying, raw red edges, smears, pool | 2 -> 4 | 3 | 2 -> 3 | 3 -> 4 | 10 -> 14 | kat64_long it2: the 'halves' were the whole cop + his feet -> 7d3ba705a cut_up_m 0.8 -> e69fd5359 split_topple_deg 80: two halves lie on the street. Next: A2 cut faces (wiring) |
| 3 | electro_shock | H | - / bolt flash / k+3: the victim kind's OWN drawn skeleton (n16 it3: A3, cap/helmet/hood/hard hat as gear, b037d283f), upright on his feet in a zap star, strobing to the inverse frame / k+40 still convulsing / stiff drop, scorch | 4 | 4 -> 5 | 2 -> 3 | 2 | 12 -> 14 | xray per kind 64/32 it3: the patrol cop's skull under his cap at 64; at 32 reads by the cap, busier than the plain sticker on dark asphalt (Call) |
| 4 | burn_char | H | burning run / the jet's flame wall hides him at k+0..k+10 / char cell stands, smoking / ash heap (after k+40, not in the strip) | 3 | 3 | 3 | 4 | 13 | rank64 1b823dbf7: the floor-fire column covers the death beat |
| 5 | plasma_hole | M | - / bolt, hole at the chest / the drawn charred ring (A4, 0dce9f3b6: torn cloth, cauterised flesh, rib ends, spine) white-hot -> amber -> char, ink-grey smoke / lies with the street showing through the hole | 3 | 2 -> 3 | 2 -> 3 | 2 -> 3 | 9 -> 12 | ph64/ph32 it3: a hole, not a bullseye; the impact bloom is weaker at 32 (Call) |
| 6 | chainsaw_grind | M | wind-up / bite at the waist: cop held, blood spurts, cream sparks AND 8 drawn chunks thrown out (A5: meat, bone chips, a rib, a tooth) k+0..k+54 / torso off the legs, halves topple, cut faces / halves + chunks lying 1.3-2.6 m off + smears + pool | 4 | 4 | 3 -> 4 | 4 -> 5 | 15 -> 17 | sc64/sc32 it3: chunks read at both zooms past the pool |
| 7 | hand_cannon_blowback | M | - / blown back in one piece, a big red exit fan / 3-tick stop / body tumbles ~3 m off, big pool + drops stay | 4 | 2 | 3 | 4 | 13 | rank64 1b823dbf7: reads, but it is a plain knock-back: nothing torn, no hole |
| 8 | plasma_sword_split | M | as katana, hot cauterised edge, no blood; halves topple | 2 -> 4 | 3 | 1 -> 2 | 1 -> 2 | 7 -> 11 | rank64 + ps64_c it2: a cream-edged head-and-shoulder half falls one way, the legs the other. Aftermath: the two halves only (no blood by design) |
| 9 | ray_gun_dissolve | M | - / k+0 burst, a cream disc on the chest / k+10 the cop falls back over (reads as a plain death) while a grey disc stays / k+40 dust ring | 2 | 4 | 2 | 3 | 11 | rank64 1b823dbf7: the dissolve does not read at k+10..k+30 |
| 10 | homing_shard_burst | M | shards stick / frozen 36 ticks, ink rings pulse per shard / burst into a red mist and pool at k+40 | 3 | 4 | 3 | 3 | 13 | rank64 1b823dbf7: the frozen beat reads (rings), the victim is small inside them at 64 |
| 11 | mini_nuke_vaporise | L | - / full-screen cream-and-vermilion flash k+0..k+10 / grey wash / charcoal shadows of the squad stay | 4 | 4 | 2 | 5 | 15 | rank64 1b823dbf7: the shadows of the vaporised squad are the strongest aftermath of all |
| 12 | tonnage_crush / tonnage_ram | M (ghost) | slam / pressed wide and dark, red splat / - / flat body | 4? | 4? | 3? | 4? | 15? | owed |
| 13 | dent_blast_gib / dent_car_hit | M (ghost) | as rocket gib / blowback | 4? | 2? | 3? | 4? | 13? | owed |
| 14 | kerf_split | M (ghost) | as plasma sword, teal-white soul edge | 4? | 3? | 2? | 2? | 11? | owed |
| 15 | ohm_shock | M (ghost) | as electro, soul-teal arcs | 4? | 4? | 2? | 2? | 12? | owed |

Work order after the first five films (11:45, weak x seen): plasma_hole (7, fixing now; then A4 insides), electro_shock (11, H:
the skeleton upright on the body, then A3 per kind), ray_gun_dissolve (11), burn_char (13, H), katana (A2 cut faces), gib
bone (A1: 4 kinds packed 11:40, 7 more coming), chainsaw chunks (A5).

Work order at 13:20 (iteration 2): plasma_sword_split (10: the halves stand upright; no aftermath; A2 hot cut face), plasma_hole
(9: cream halo, A4 insides), ray_gun_dissolve (11), electro_shock (12: A3 per kind), katana (13: topple the halves, A2), burn_char
(13, H: the flame column hides the death), hand_cannon (13: nothing torn). Kerf and Ohm inherit the split lift and the upright X-ray.

Work order at 13:25 (iteration 2, after the blade work): plasma_hole (9: the cream halo at 32 px/m, A4 insides when drawn),
ray_gun_dissolve (11: the dissolve does not read at k+10..k+30), electro_shock (12: A3 per-kind skeletons), plasma_sword
(11: aftermath; the hot face's glow is an owner Call), burn_char (13, H: the flame column hides the death beat),
hand_cannon (13: nothing torn: a drawn exit wound?), rocket_gib (14: the bone at 32 px/m), the ghosts' four (owed films).

Work order at 14:40 (iteration 3, after A3/A4/A5): ray_gun_dissolve (11: the dissolve does not read at k+10..k+30; the
weakest now), plasma_sword (11: aftermath), plasma_hole (12: impact pop at 32), burn_char (13, H: the flame column hides
the death beat), hand_cannon (13: nothing torn), rocket_gib (14: bone at 32 px/m), the ghosts' four (owed films).
