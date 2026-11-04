# Showcase lane: night run 2026-11-04, report

**Extension (09:00-11:00), FINAL (written 10:16):** the final build is merge round 19
(`08e1b72f`, the five lane tips at about 10:00 plus REQUEST 30 as merge glue). It is gated green:
lint 13/13, unit 931/931, scenarios 45/45, parity bit-exact, look 11/11 + block 5/5, no
re-bless. It is filmed in **reel-1012**, the final morning reel: 128.5 s, 17 director chapters at
48 px/m plus 18 CITY BLOCK at 32 px/m, with 0 script errors. `build\export\windows\RTAI.exe`
was re-exported on it at 10:12, and its three boot tests (arena, director, city block) ran with 0
script errors.

Since the 08:40 report, merge rounds 16-19 are in, and so is everything the "After the freeze"
list below names. REQUEST 29 and REQUEST 30 are closed: the electro victim falls along the shot,
and its signature corpse now lies full length, legs together, shoes toward Rivet. showcase-1 is
answered by that (the plank won) and showcase-3 is closed (the city's pit walls are grey concrete
barriers). Other changes:
- A ROBOT THUG chapter, filmed in human-reactions' dev pit (there is no live robot fighter).
- The ray gun's cream lock wash holds the victim for about 1 s before the dust heap.
- The fire-death char keeps a zoom-scaled ash rim.
- Weapon-art's inked ground pickups in the hub armory.

Bench of record is now **r19** (10:16-10:28, CONTENDED: other lanes active; the exported
release, 3 x 4 x 60 s): aggregate p99 8.792 ms, 1 % low 74 fps, MISSES p99CpuMs (about r16's
8.515 / 88); worst frame 424 ms, 26 hitches over 50 ms (0 unexplained). One run, not bisected
(freeze); evidence/r19/bench.log. Rounds 17-18 were not benched. Reels in this window: reel-0857 (r16),
reel-0930 (r17), reel-0954 (r18), **reel-1012 (r19, final)**. The play commands below are for
this exe.

**10:35 stabilize check (after the freeze):** no gate, reel or exe changed after reel-1012. The
lane tips moved after round 19 with docs and evidence logs only, with one exception:
human-reactions `1623e625` (10:11, `ReactLink.MELEE_IDS`: claw, chainsaw, baton, katana and
plasma sword hits play the melee wound and fold death instead of the light fallback; render only,
one unit test). It is **not in this build**: it landed after the round 19 merge, and it changes
what the claw, katana and chainsaw chapters show, so taking it would leave reel-1012 out of date
with no time to re-film. The Director's morning merge takes it along with the lane's branch.

The text below is the 08:40 report.

Status: FINAL on merge round 15 (06051f21, merged 08:14: the lane tips up to 08:10). Gates r15
green; exe re-exported 08:19 on round 15. The final reel **reel-0808** is round 14 (e13dc36b): no
time for another reel before the 08:30 freeze. Round 15 adds only small fixes, not filmed by the
showcase lane: the molotov's glass slivers and inked scorch patch (weapon-art), long guns and tubes
carried beside Rivet's helmet instead of across his face (rivet-arsenal), no stuck homing shards on
a corpse (gunplay), a steadier blade solo frame (brutality) and `--armored=k` in the arena
(human-reactions). Each owning lane filmed its fix in its own clips; the showcase lane filmed the molotov and the
rocket on round 15 in **reel-0821-r15-close64** (64 px/m, 0 script errors).

The showcase lane merges the five night lanes (weapon-art, rivet-arsenal, gunplay,
human-reactions, brutality) into `n-showcase` each round, runs the gates, cuts the director reel
and benches it. It also sends what reads badly back to the owning lane as REQUESTs (see JOURNAL.md).

## Play it

From the `n-showcase` worktree (`C:\Users\kazda\kiro\gtai-wt\n-showcase`):

| What | Command |
|---|---|
| The arena with every finished weapon (hub armory: walk over a gun, **E** swaps, **1-4** / wheel switch) | `build\export\windows\RTAI.exe` |
| The city block fight (32 px/m) | `build\export\windows\RTAI.exe -- --arena=city --loadout=pistol,plasma_rifle,rocket_launcher,molotov` |
| The director cut, live (16 arena chapters, deterministic; the robot thug chapter is filmed in a dev pit, not in the exe) | `build\export\windows\RTAI.exe -- --bot=reel --reel=director --loadout=pistol` |

The exe is a release export (`windows-showcase` preset, embedded pck, 236 MB) with the release
sim DLL beside it (re-exported on round 19, 10:12; evidence/r19/export.log). Round 19 boot tests (headless, 0 script errors, evidence/r19/boot-*.log): the arena opens with 16
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
| reel-0710 | morning-reel draft on round 11, 122 s: 16 chapters + 17 CITY BLOCK |
| reel-0716-final, reel-0745-final, reel-0801-final | intermediate final-reel assemblies (superseded by reel-0722, reel-0751, reel-0808; not in frames.json) |
| reel-0722 | morning reel on round 12, 122 s, 0 script errors (the city block's plasma error fixed) |
| reel-0751 | morning reel on round 13, 122 s, 0 script errors; ray gun dust heap, molotov victim in the opened fire |
| reel-0756-close64 | 64 px/m close-ups on round 13: molotov, ray gun, rocket, mini-nuke, flamethrower |
| **reel-0808** | **the final morning reel on round 14 (the exe's build), 122 s: 16 chapters at 48 px/m + 17 CITY BLOCK at 32 px/m, 0 script errors** |
| reel-0821-r15-close64 | round 15 (the exe build), 64 px/m: the molotov's glass slivers and inked scorch patch; the rocket tube carried at Rivet's side; 0 script errors |
| reel-0930 | extension, round 17 (e977a394, the 09:30 exe), 128.5 s, 0 script errors: + 16 ROBOT THUG (power-down death, filmed in human-reactions' dev pit), the electro corpse in the shock plank, the mini-nuke's own bomb |
| **reel-1012** | **the final morning reel, extension round 19 (08e1b72f, the 10:12 exe), 128.5 s, 0 script errors: the electro signature corpse lies full length in the plank (REQUEST 30), the char rim scales with the zoom** |
| reel-0954 | extension, round 18 (9c9f59a5), 128.5 s, 0 script errors: the ray gun lock wash, the electro corpse's legs reading to the feet, the lighter thug spray, the burn char's ash rim |
| reel-0857 | extension, round 16 (8a8215a3), 122 s, 0 script errors: the rocket blast thins out as smoke; the electro victim lies along the shot (REQUEST 29 closed); the city block's pit walls are grey concrete barriers, not black bars (showcase-3 closed) |

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
| r11 | 9f6b2fbe | 13/13 | 889/889 | 44/44 | exact | 11/11 + 5/5 |
| r12 | 9c52b656 | 13/13 | 893/893 | 44/44 | exact | 11/11 (worst 0.00) + 5/5 |
| r13 | 2643fbbd | 13/13 | 903/903 | 45/45 | exact | 11/11 (worst 0.00) + 5/5 |
| r14 | e13dc36b | 13/13 | 906/906 | 45/45 | exact | 11/11 + 5/5 |
| r15 (08:19 exe) | 06051f21 | 13/13 | 912/912 | 45/45 | exact | 11/11 (worst 0.00) + 5/5 (worst 1.81) |
| r17 (extension, the 09:30 exe, superseded) | e977a394 | 13/13 | 927/927 | 45/45 | exact (planted caught at 629) | 11/11 (worst 0.00) + 5/5 (worst 1.81) |
| **r19 (extension, the final 10:12 exe)** | **08e1b72f** | **13/13** | **931/931** | **45/45** | **exact (planted caught at 629)** | **11/11 (worst 0.00) + 5/5** |
| r18 (extension, 09:53 exe, superseded) | 9c9f59a5 | 13/13 | 929/929 | 45/45 | exact (planted caught at 629) | 11/11 (worst 0.00) + 5/5 (worst 1.81) |
| r16 (extension) | 8a8215a3 | 13/13 | 913/913 | 45/45 | exact (planted caught at 629) | 11/11 (worst 0.00) + 5/5 (worst 1.81) |

## Bench (exported release, 3 x 60 s, CONTENDED; p99 / 1 % low from frame_ms)

| Round | drive | drive48 | riot |
|---|---|---|---|
| record (main 9ebc5918) | 3.56 ms | - | 6.0 ms / 124 fps |
| r7 | 3.45 / 158 | 3.69 / 166 | 11.48 / 63 |
| r8 | 4.33 / 140 | 2.54 / 224 | 10.37 / 71 |
| r10 | 3.39 / 108 | 2.17 / 376 | 5.58 / 118 |
| r12 | 2.00 / 280 | 2.21 / 252 | 8.50 / 73 (my own merge load in its window) |
| r16 (extension) | 3.72 / 166 | 2.47 / 260 | 8.52 / 88 (no Godot of mine during it; other lanes busy) |
| **r19 (final exe, 10:16-10:28)** | **aggregate only: p99 8.79 ms / 1 % low 74 fps, MISSES p99CpuMs; worst frame 424 ms (CONTENDED)** | | |

The riot went back under its p99 record on r10 after human-reactions trimmed the trip scan (REQUEST 23).
The r12 riot number is not clean: my round-13 merges (git + the lint hook) ran during it. No r13
bench (the lock was taken by another lane at 07:41 and the session ended at 08:12).

## Calls for the owner

(10:16: showcase-1 and showcase-3 are resolved in reel-1012: the electro corpse lies in the plank, and the city pit walls are grey barriers. showcase-2 stands. The "Known wrong", "After the freeze" and "Next steps" sections below are the 08:40 text; everything they list is merged by round 19.)

- **showcase-1, electro death pose:** the stiff "plank" corpse vs a lying fall along the shot
  (reel-0808 chapter 06 shows neither yet: REQUEST 29 -> brutality; the plank exists in
  human-reactions 3a8d3931 on the pit path).
- **showcase-2, hub crowding:** the melee-line dummies stand in front of the weapon wall's base,
  and the hub has no free row left (evidence/r8/armory-48ppm.png).
- **showcase-3, pit wall bars on the city plaza:** the pit's wall bars still draw on the city
  block (reel-0808 chapter 17).

## Known wrong in the current reel (REQUESTs out)

- ch 06 electro: CLOSED on round 16 (reel-0857). Brutality's `63cc3ce1` lays the body out along the
  shot after the X-ray (REQUEST 29). At 48 px/m it still reads as a low blue lump; brutality
  `88ff881d` (08:57, the corpse lands in the shock death plank) lands in the final round.
- ch 07 molotov: fixed mid-chapter (REQUEST 27, gunplay aa471560: the fire opens round the corpse); at the chapter's end the victim sinks into the char.
- ch 13 ray gun: fixed (REQUEST 26, brutality 9c9aaabf): a long dust heap with the crumpled uniform.
- ch 17 city block: fixed (REQUEST 28, brutality 584b3f77): 0 script errors on the city film.

## After the freeze (08:30): lane commits NOT in this build

The exe and the gates are round 15 (`06051f21`). Landed on lane tips after it, not merged (freeze;
gates plus re-export did not fit before the 08:40 report):
- weapon-art `3a703dbd`: the rocket blast ends in smoke, not a ring of cream beads (render only).
- gunplay `83429487`: a knocked-down fighter is held 29 ticks while his rise plays (sim-side; the
  Director's merge must re-run parity and scenarios).
- brutality `63cc3ce1`: the electro kill lays the body out long along the shot instead of the
  standing rig (REQUEST 29's answer; render only). Landed 08:20, after round 15's merge, so the
  08:22 re-check could not show it.
- rivet-arsenal, human-reactions: docs only.

## What blocked the lane, and for how long

- **The bench lock** (shared, one bench at a time): skipped r6 (held by another lane from 05:27),
  r9, r11 (a 12 min bench would outrun the session) and r13-r15 (held by another lane at 07:41;
  then the freeze). Final bench of record is r12; r15 (the exe) is **unbenched**.
- **Stale class cache after a merge** (06:30, ~10 min lost): a director cut started before the
  `--import` ran chapters 01-10 without gunplay's hook (14 script errors each); re-cut clean.
  Rule since then: `--import` once after every merge, before any capture.
- **evidence/run.mjs refuses a dirty tree** (three times, ~5-10 min each): logs moved out of the
  worktree during the run; never commit while it runs.
- **Bench export path** in a fresh worktree (02:30, one run lost): `mkdir -p build/export/windows-bench` first.
- Nothing blocked the merges themselves: 15 rounds, every conflict was JOURNAL/REPORT (kept ours) or
  one-line glue (listed per round in JOURNAL.md).

## Next steps (for the Director)

1. Merge `n-weapon-art` (3a703dbd), `n-gunplay` (83429487, sim-side), `n-brutality` (63cc3ce1)
   into `n-showcase`; run the four gates (parity and scenarios matter for gunplay's rise hold).
2. `--import` once, then film the electro chapter first (`cut.sh`) to close REQUEST 29, then the
   full director reel (`reel.sh`), and look at every frame.
3. Re-export `RTAI.exe` and bench it alone under `bench.lock` (r15/r16 have no bench).
4. Open for the owning lanes: showcase-3 (pit wall bars on the city plaza), the molotov victim
   not reading inside the fire mid-chapter (REQUEST 27 remainder), the rocket's thrown parts
   leaving the 64 px/m frame, and no live robot thug fighter (human-reactions scoped it, pit-only).

Evidence paths in this report checked 08:42: the masters reels listed above, `evidence/r15/*`
(boot logs, export log, evidence log, the three sheets), `evidence/r8/armory-48ppm.png`,
`build/export/windows/RTAI.exe` + the release DLL (08:19).
