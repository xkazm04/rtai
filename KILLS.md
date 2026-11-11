# KILLS: the existing signature deaths, ranked (n16 kills-polish)

Doctrine (owner 2026-11-11): each kill is a small, inventive, readable piece of animation that rewards the player;
gore = drawn innards, bone and skulls in riso ink-and-cream, red for blood only; pacing = hit-stop (<= ~6 ticks) plus a
camera punch, never slow motion; reads at 32 px/m in a crowd; leaves an aftermath on the street.

Scores 1-5 per axis: **Read** (at 32 px/m in a crowd), **Invent** (inventive, ours), **Brutal** (within the gore level),
**After** (what stays on the street). **Seen** = how often a player meets it (H/M/L: H = a reel/arena main weapon).
Work order = weakest total among the most seen first.

Status: iteration 1 draft. Beat sheets are from the rows (`signature_kills.json` docs) and the FX code; the
"film" column says which are confirmed on a film of this branch. Scores marked `?` are provisional until filmed.

| # | Row | Seen | Beat sheet (anticipation / impact / held beat / aftermath) | Read | Invent | Brutal | After | Total | Film |
|---|---|---|---|---|---|---|---|---|---|
| 1 | rocket_gib | H | - / blast, body into 6 pieces (drawn torn pieces: patrol, riot; n16: + thug, hood, cap, suit, worker, swat) / no hold (hit-stop 0) / pieces, red fan + ink splat, scorch 1.3 m | 4? | 3? | 3? (no bone) | 4? | 14? | owed |
| 2 | katana_split | H | wind-up cell / diagonal cut, 6-tick hit-stop, streak (n16: 1 m x 0.06 m) / halves slide apart on smears / two halves, raw red edges, smears | 4? | 3? | 3? (paper edge, no ribs) | 3? | 13? | owed |
| 3 | electro_shock | H | - / bolt flash / k+3: ONE generic skeleton sticker drawn LYING (turned along the shot) while the cop stands, strobing with his card / k+40 still convulsing / stiff drop, scorch | 3 | 4 | 2 | 2 | 11 | rank32/64 1b823dbf7: the skeleton lies sideways beside a standing man: reads as a sticker, not his X-ray |
| 4 | burn_char | H | burning run / the jet's flame wall hides him at k+0..k+10 / char cell stands, smoking / ash heap (after k+40, not in the strip) | 3 | 3 | 3 | 4 | 13 | rank64 1b823dbf7: the floor-fire column covers the death beat |
| 5 | plasma_hole | M | - / bolt, hole ring at the HIPS (the body group's centre) / cream smoke puffs (0.49 m, alpha 0.9) wash the standing body pale / lies with a big amber ring | 2 | 2 | 1 | 2 | 7 | rank32/64 1b823dbf7: WEAKEST; fixing (hole_up_m, ink-grey smoke) |
| 6 | chainsaw_grind | M | wind-up / bite: cop held, blood spurts and cream sparks k+0..k+40 / halves part at k+56 / halves + smears | 4 | 4 | 3 | 3 | 14 | rank64 1b823dbf7: reads; no chunks, the held body barely shakes at 64 |
| 7 | hand_cannon_blowback | M | - / blown back in one piece, cap spins / 3-tick stop / long smear + exit spray | 4? | 2? | 2? | 4? | 12? | owed |
| 8 | plasma_sword_split | M | as katana, hot cauterised edge, no blood | 4? | 3? | 2? | 2? | 11? | owed |
| 9 | ray_gun_dissolve | M | - / k+0 burst, a cream disc on the chest / k+10 the cop falls back over (reads as a plain death) while a grey disc stays / k+40 dust ring | 2 | 4 | 2 | 3 | 11 | rank64 1b823dbf7: the dissolve does not read at k+10..k+30 |
| 10 | homing_shard_burst | M | shards stick / frozen 36 ticks, jolts per shard / burst into 6 rig parts, red mist ring | 3? | 4? | 3? | 3? | 13? | owed |
| 11 | mini_nuke_vaporise | L | - / vaporised: flat charcoal shadow / - / shadow + soot ring stay | 4? | 3? | 2? | 4? | 13? | owed |
| 12 | tonnage_crush / tonnage_ram | M (ghost) | slam / pressed wide and dark, red splat / - / flat body | 4? | 4? | 3? | 4? | 15? | owed |
| 13 | dent_blast_gib / dent_car_hit | M (ghost) | as rocket gib / blowback | 4? | 2? | 3? | 4? | 13? | owed |
| 14 | kerf_split | M (ghost) | as plasma sword, teal-white soul edge | 4? | 3? | 2? | 2? | 11? | owed |
| 15 | ohm_shock | M (ghost) | as electro, soul-teal arcs | 4? | 4? | 2? | 2? | 12? | owed |

Work order after the first five films (11:45, weak x seen): plasma_hole (7, fixing now; then A4 insides), electro_shock (11, H:
the skeleton upright on the body, then A3 per kind), ray_gun_dissolve (11), burn_char (13, H), katana (A2 cut faces), gib
bone (A1: 4 kinds packed 11:40, 7 more coming), chainsaw chunks (A5).
