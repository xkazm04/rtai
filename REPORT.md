# Showcase lane: night run 2026-11-04, report

Status: DRAFT written at 07:00, updated 07:12 on round 11. The final round (07:45-08:30) updates it with the
last merge, its gates, the final reel and the final exe.

The showcase lane merges the five night lanes (weapon-art, rivet-arsenal, gunplay,
human-reactions, brutality) into `n-showcase` each round, runs the gates, cuts the director reel
and benches it. It also sends what reads badly back to the owning lane as REQUESTs (see JOURNAL.md).

## Play it

From the `n-showcase` worktree (`C:\Users\kazda\kiro\gtai-wt\n-showcase`):

| What | Command |
|---|---|
| The arena with every finished weapon (hub armory: walk over a gun, **E** swaps, **1-4** / wheel switch) | `build\export\windows\RTAI.exe` |
| The city block fight (32 px/m) | `build\export\windows\RTAI.exe -- --arena=city --loadout=pistol,plasma_rifle,rocket_launcher,molotov` |
| The director cut, live (16 chapters, deterministic) | `build\export\windows\RTAI.exe -- --bot=reel --reel=director --loadout=pistol` |

The exe is a release export (`windows-showcase` preset, embedded pck, 234 MB) with the release
sim DLL beside it (re-exported on round 11, 07:11). Round 11 boot tests (headless, 0 script errors): the arena opens with 16
stations and "armory: 15 weapons on the hub floor"; the director run kills its chapters; the
city block loads with the loadout.

## The reels, in time order (`C:\Users\kazda\kiro\gtai-masters\n4\showcase\`)

| Reel | What |
|---|---|
| reel-0130, reel-0130-64ppm | round 1: first wave fight in the pit |
| reel-0145(-rocket, -city-rocket, -rocket-64ppm), reel-0155-city-rocket | rocket end to end, arena and city block |
| reel-0210-pistol, reel-0215-pistol-64ppm, reel-0235-city-pistol, reel-0235-rocket-64ppm | pistol chain (held, fired, reactions, deaths) |
| reel-0240-mpistol | machine pistol on a group |
| reel-0315-arsenal, reel-0320-arsenal-64ppm | Rivet's arsenal (melee + switch) |
| reel-0355-uniques | the advanced weapons' signature kills |
| reel-0412-riot-64ppm, reel-0417-city-riot | riot cop with shield, city riot |
| reel-0500-director, reel-0520-director | first director cuts (16 chapters, 48 px/m) |
| reel-0530, reel-0545 | morning-reel drafts (director + 15 s city block) |
| reel-0550-close64 | 64 px/m close-ups of seven kills |
| reel-0615-r9-fixes | round 9 check: electro, plasma rifle, riot cop after the lanes' fixes |
| reel-0640 | morning-reel draft on round 10, 122 s: 16 chapters + 17 CITY BLOCK |
| reel-0700-close64 | 64 px/m close-ups of the round 9-10 changes |
| **reel-0710** | **morning-reel draft on round 11, 122 s: 16 chapters + 17 CITY BLOCK** |

## Gates per merge round (all under private APPDATAs, CONTENDED machine)

| Round | Tree | Lint | Unit | Scenarios | Parity | Look / block goldens |
|---|---|---|---|---|---|---|
| r2 | 2813ef81 | 13/13 | 732/732 | 30/30 | exact | 11/11 + 5/5 |
| r3 | d7632ac1 | 13/13 | 745/745 | 32/32 | exact | 11/11 + 5/5 |
| r4c | 62f60be4 | 13/13 | 773/773 | 37/37 | exact | - |
| r5 | 461819e7 | 13/13 | 802/802 | 39/39 | not re-run (no sim change) | 11/11 + 5/5 |
| r6 | f8c0f817 | 13/13 | 820/821 -> glue | 39/39 | - | - |
| r7 | 15b48cb4 | 13/13 | 825/825 | 41/41 | - | - |
| r8 | e3d3567d | 13/13 | 848/848 | 43/43 | exact | 11/11 + 5/5 |
| r9 | 54a7d5c0 | 13/13 | 868/868 | 43/44 (REQUEST 25) | exact | 4/11 (shield slab + spray tilt, intended) |
| r10b | ef43fb36 | 13/13 | 871/871 | 44/44 | exact | 11/11 (re-blessed, decisions line) + 5/5 |
| **r11** | **9f6b2fbe** | **13/13** | **889/889** | **44/44** | **exact** | **11/11 + 5/5** |

## Bench (exported release, 3 x 60 s, CONTENDED; p99 / 1 % low from frame_ms)

| Round | drive | drive48 | riot |
|---|---|---|---|
| record (main 9ebc5918) | 3.56 ms | - | 6.0 ms / 124 fps |
| r7 | 3.45 / 158 | 3.69 / 166 | 11.48 / 63 |
| r8 | 4.33 / 140 | 2.54 / 224 | 10.37 / 71 |
| **r10** | **3.39 / 108** | **2.17 / 376** | **5.58 / 118** |

The riot is back under its p99 record after human-reactions trimmed the trip scan (REQUEST 23).

## Calls for the owner

- **showcase-1, electro death pose:** the stiff "plank" corpse vs a lying fall along the shot
  (reel-0710 chapter 06; REQUEST 24/24b -> human-reactions).
- **showcase-2, hub crowding:** the melee-line dummies stand in front of the weapon wall's base,
  and the hub has no free row left (evidence/r8/armory-48ppm.png).
- **showcase-3, pit wall bars on the city plaza:** the pit's wall bars still draw on the city
  block (reel-0710 chapter 17).

## Known wrong in the current reel (REQUESTs out)

- ch 06 electro: the corpse now lies long, but across the shot; the scorch does not read at 48 px/m (REQUEST 24b -> human-reactions).
- ch 07 molotov: the victim is hidden under the fire stars to the end (REQUEST 27 -> brutality, cc gunplay).
- ch 13 ray gun: the dust pile reads as a round cream token (REQUEST 26 -> brutality).
- ch 17 city block: the plasma topple logs a script error every frame there (REQUEST 28 -> brutality).
