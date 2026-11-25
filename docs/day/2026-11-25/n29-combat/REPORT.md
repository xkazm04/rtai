# REPORT lane combat, run n29 (2026-11-25)

Branch `n29-combat`, worktree `gtai-wt/n23-street`, cut from `main` `c649a15d6`. Director Opus 5.5; builders Claude
sub-agents (Agent tool, Sonnet 5.5 for most calls, Opus 5.5 for the fire group and the kill card scale). Films and stills:
`C:/Users/kazda/kiro/gtai-masters/n29/combat/` (`frames.json`). IMAGES 0/25: every repaint is a deterministic hue remap of
the shipped pixels or a code colour, no image-tool call (the shapes are accepted art, only their hue broke the colour law).
Final gate on the last code commit `2aa9e6748` (06:43-07:01): `gate: PASS` (lint 19/19 checks over 2275 GDScript files;
unit 4270 passed, 0 failed, 2 skipped; scenarios 68 passed; parity bit for bit over 1200 steps, planted mutation caught at
step 629; selftest; export-audit 999 loaded, 0 failed), `build/gate/2aa9e6748681/gate.json`. The gate before it, at
`30d4cf525`, also passed (`build/gate/30d4cf52551b/gate.json`); between the two only tests and evidence were added. Every
later commit touches only JOURNAL, REPORT, briefs and `evidence/` (all inert to the gate).
Reel gate (code frozen since `2aa9e6748`, run at `03b9c4aaf` because this lane's last session stops before the 08:45 freeze;
`git diff 2aa9e6748 03b9c4aaf` = JOURNAL and REPORT only): `node tools/gate/run.mjs --rev=HEAD --reels`, 07:04-07:31, `gate: PASS`
(the same lint, unit 4270/0, scenarios 68, parity, selftest, export-audit 999/0, plus `reels: exit 0`, views top 284 s, tilt70
283 s, combo 283 s), `build/gate/03b9c4aafe04/gate.json`.

## What works

### 1. Tonnage's bar 85 -> 70 (`cc2945082`, table `52d8b7102`, `c264b41ca`, film script `1de3e21c5`)
- `ghost_forms.json` `bond.master_at_by_form.tonnage` 70; nothing else moved. Ten seeds of the average test player, the
  same measurement as n28 (`evidence/n29/bond/mastery.md`):

| Arm | Runs with a mastery | First-mastery waves | Ghosts mastered | Tonnage mastered | Kerf mastered |
|---|---:|---|---|---|---|
| n28 (Tonnage 85, cut 5) | 2/10 | 8, 8 | kerf, ohm | none | yes |
| **n29 (Tonnage 70, cut 5)** | 3/10 | 7, 8, 8 | kerf, ohm, tonnage | seed 1, wave 7 | yes (seed 5, wave 10) |

- Seed 2 died in wave 5 with Tonnage at 64; seed 8 reached 70 during wave 9, but wave 9 ended on its 55 s timeout and
  waves 9 and 10 share block 9, so no rest offered the card. On these seeds reaching the next rest limits his mastery
  more than the bar does.
- Film `films/tonnage_mastery_70.mp4` (1920x1080, 60 fps, 35.15 s, seed 2 expert, prefill 6, the same take as n28),
  still `stills/tonnage_chip_70_64.png`.

### 2. Red repaint (28 audit rows re-run: `evidence/n29/red/audit.md`, `722bf49b0`)
Reddish px (the n28 counter, R>170 G<110 B<90), n28 -> n29: fire and muzzle rows 1-10 **125452 -> 98** (the 98 are dark
edge px of the `colour/` flash cells). Status: FIXED 15, KEPT 8 (blood, danger cues, objectives, Rivet's rounds), NEED keys
2, NOT ON SCREEN 3.
- **Fire** (`3a7fcfed0`, `3c2f41d94`, `12b7c141b`, `ddd15787f`, film `f6eeedc29`): blast, flame, flame cone, ground fire,
  explosion atlas cells 9-12, `fx_fire.png` (quest 1's fire loop, burning ground, flame hit bursts) and the rag/nuke-tip
  glow to amber `#edab42`. The PNG repaint alone did not reach the screen: the item print snaps every non-ink colour to
  the nearest palette ink, and amber's nearest was vermilion. So the FX view got its own print copy with amber as an ink
  (`look_profiles.json` `fx_amber_ink`, false = off). 0 px changed outside the fire boxes. Crop px at 64 px/m: blast 53046
  -> 953, flame 38143 -> 3379, burning ground 22026 -> 2819, explosion 18217 -> 1127 (the rest is blood). Stills
  `stills/red_fire_{blast_pair2,flame_pair3,ground_fire_pair3,explosion_pair2}_64.png`; film `films/red_fire_after3_32.mp4`
  (1920x1080, 60 fps, 25.0 s).
- **Muzzle** (`62234251c`, `2a1069f77`, `a7365210b`): 24 `flash_*` PNGs and atlas cells 0-2, 8, 13, 14 to amber, source
  reddish -> 0. On screen the d4 `muzzle` star turns amber (`stills/red_muzzle_d4_muzzle_pair_64.png`). The arena gun
  flashes are pixel-identical before and after over 22 ticks: they print as a cream star with an ink rim and are not
  drawn from these cells (`stills/red_muzzle_nuke_pair_64.png`). No film: it would show no change.
- **Electric** (`330ad6592`, `3bf74f0c7`, `9481dc887`, film `13c172ce4`): Mertz's tazer prongs and the arena burst arcs
  are drawn as live current (`CurrentLook`: cream core, opaque amber body); the tazer barrel stripe is amber. Quest 1's
  cast view prints with the same amber ink. Crop px: tazer 2370 -> 1366 (what is left is Mertz's gloves, cast art), burst
  327 -> 196 (what is left is the arena robot's red-striped coil, cast art). Stills
  `stills/red_elec_{tazer,burst}_pair2_64.png`; film `films/red_elec_mertz_after.mp4` (1920x1080, 60 fps, 28.9 s).
- **Sword** (`85c6b0c53`): the hilt rings of `held_long`, `held`, `pickup` and `held_55/plasma_sword` are steel (masked
  recolour, value and alpha kept): reddish 378 -> 15, 287 -> 3, 296 -> 16, 224 -> 13; the blade is untouched. The last
  specks (copper emitter lights that the lit render pushed past the red gate) went amber in `edac413f2`: all four files
  are now at 0. In game at 64 px/m (blade6 take, seed 1, tick 62, before = the PNGs of `3e2fde824`): sword box 40 -> 3 -> 0
  reddish px. The whole-frame diff is 43 px, all on the rings. The rings print ink-dark with grey (steel at this size),
  not cream and not vermilion. Stills `stills/red_sword_pair_64.png`, `stills/red_sword_after2_64_crop.png`; film
  `films/red_sword_after_32.mp4` (1920x1080, 60 fps, 24.0 s, four sword chapters). `evidence/n29/red/sword.md`
  (`f6384699d`, `a4dbbe3aa`). In the wind-up swing the sword is drawn from Rivet's own `rivet_eq_plasma_sword*` sheet,
  whose copper rings remain: NEED keys.

### 3. The in-flight electro bolt as live current (`3e2fde824`, `3ba4b1fdd`, `25fb82801`, `a33cfc186`, `87a5688c0`)
- `WeaponFxBolt` draws the bolt in flight as a jagged amber current with a forked head star; `--electro-cells` keeps the
  old arc/spark cells. One width is shared by the bolt, the chain hop and the daze stun: 10 px opaque amber body, 4 px
  cream core, 13 px ink outline. The bolt and the chain hop swing `JAG_K` 3.0 times the arc kink (about 0.22 m; the cells'
  zigzag swings about 0.25 m). At 64 px/m the swing is 24.9 px for the current against 22.4 px for the cells. Red 0 and
  teal 0 in the bolt and hop boxes.
- Owner take `electro_gun_hop` (`8b356974f`): two robot thugs 2.5 m apart, inside the 4 m hop range of one bolt. Hop proof
  in both looks: `chain_hits` 1 and the second thug is hurt on tick 119. Films
  `films/electro_bolt_{cells,current}_32.mp4` (1920x1080, 60 fps, 18.0 s) and `films/electro_bolt_pair_32.mp4` (cells left);
  stills `stills/electro_bolt_pair_64.png` (tick 114) and `stills/electro_hop_pair_64.png` (tick 121), with the earlier
  thin and flat tries kept as `*_thin.png` / `*_flat.png`. `evidence/n29/electric/bolt.md`.
- Mutate: `weapon_fx_bolt.gd` lines 8-30 10/14 = 71 % (4 equivalent survivors listed in bolt.md); `weapon_fx_electro.gd`
  changed lines 6/11 = 55 % before the pin test.

### 4. NEED from cast served: a killed card foe keeps his card size (`6d1fa3959`, `d924402d2`, `3082c6402`)
- `KillFallCells.victim_scale`: a card foe falls at the crowd build times the card row's `body_scale`, the same value
  `StreetWalkerCards.place` draws him at. Street walkers are unchanged. Headless probe: Mulroney used to fall at 0.901 of
  his live card size and the warden at 0.909; now both fall at their card size. `test_kill_card_scale` 4/4, mutate 7/8 =
  87.5 %. `evidence/n29/kills/card_scale.md`.
- In game (`88140e5b1`: the kill lab's gun guard now honours a single `--foe-mix=<archetype>`, no new flag, 3 tests):
  `node tools/film/kill_reel.mjs --weapons=machine_pistol --ppm=64 --dirs=90 -- --controls=legacy --foe-mix=sergeant_mulroney`,
  the stitch style on the fall grid, kill on tick 174. Before = `kill_fall_cells.gd` of `49befa075`. Measured in the frames:
  the living figure is 54x78 px in both; the fallen body grows from 61x47 to 69x53 (x1.13; about 1/0.90 was expected). Pair
  `stills/card_kill_pair_64.png` (before left; ticks 172, 180, 194). Checked by eye (session 5) against
  `view/p70/sergeant_mulroney_{armed_walk,fall}.png`: the standing figure matches his armed_walk back view (cross strap,
  shotgun stock out to the left), but the fallen body is not his fall art (no shotgun or cap flying, no chevrons): the kill
  draws a generic cop fall grid (in the headless probe the style had no own cells and resolved to `cop/head_swat`). The still proves
  that grid now falls at his card scale (x1.13); the numbers are in the headless table in `card_scale.md`.
- Clips at 32 px/m (`d6fa9ba69`): `films/card_kill_pair_32.mp4` (1920x720, 60 fps, 2.52 s, before left) and
  `films/card_kill_{before,after}_32.mp4` (the reel tool's 384x288 clips). I looked at t 2.3 s: the fallen body is larger on
  the right, everything else identical. Short of the 15 s film bar: the kill lab's shot is 420 ticks and a reel clip ends
  at most 230 ticks after the kill, so this kill cannot be filmed longer with the shipped tool.

### 5. Mutate and a dev crash
- `pressure_rifles.gd` (lines 36-41, 69-85, `test_pressure_takes`): 13/19 = 68.4 % -> 14/17 = 82.4 % (the re-run was cut
  at its 590 s cap). The shooter-pick line is now reached and killed. The 3 survivors are equivalent (explained in
  `evidence/n29/mutate/pressure_rifles.md`).
- `current_look.gd` (`test_collect_call_current`): 1/20 = 5 % -> 15/20 = 75 %. The 5 survivors are in `draw()` and change
  pixels only (`evidence/n29/mutate/current_look.md`).
- `weapon_fx_bolt.gd` 10/14 = 71 % (`amplify`, lines 8-30), `kill_fall_cells.gd` 7/8 = 87.5 % (above).
- The electro hash and fork arithmetic are pinned (tests only, `32f60f1a4`, `4d2e8f403`, `2aa9e6748`;
  `test_weapon_fx_electro_hash.gd`): `spawn_id` and `_serial` exact values worked out by hand (including posmod and
  the `* 31` weight), `add_path` widths, order and count at k = 1 and 0.5, and a fork sweep that hits both 3 and 4.
  The exact fork count per serial and one fork tip are pinned from observed values. Mutate: `weapon_fx_bolt.gd`
  `spawn_id`/`draw` lines 9/9 = 100 %; `weapon_fx_electro.gd` star/add_path/_serial lines 9/13 = 69 % -> 13/13 =
  100 % (14 of 54 mutants sampled, 1 invalid). `evidence/n29/electric/bolt.md` "Call 9".
- `dev/ghost-forms/bond_film.gd`: `--bond-prefill=0` no longer crashes (`820c8dfe5`; SCRIPT ERROR 0).

## What does not
- The arena gun flashes look the same as before (cream star with ink rim); the repainted cells are not what draws them.
- The shipped chain hop and stun changed look along with the bolt (n28's faint line is now the bold current): see Calls.

## What blocked or slowed you
- FRICTION about 25 min: the fire PNG repaint did not show on screen because the item print snapped amber to vermilion.
- FRICTION 4 min: c3 committed an unwired class that only the tests called.
- FRICTION: shared staging of `docs/decisions.md`: two builders' lines landed in each other's commits (the text is right).
- A Godot `--import` ran once outside `runGodot` (session 1, ~01:20).

## Calls for the owner
1. `fx_amber_ink` (`look_profiles.json`, on): the FX and cast views print with amber as an ink. Without it no amber
   reaches the screen. Diff against a forced-off control: 5-58 px outside the effect boxes (ember speckle). Off = one value.
2. The chain hop and daze stun now share the bolt's bold current: `stills/electro_hop_pair_64_thin.png` (before) beside
   `stills/electro_hop_pair_64.png`.
3. Row 11: Rivet's rocket and nuke shell keep their red nose band (it is his own round; amber would read as a pickup).
   `stills/call_rocket_band_pair_8x.png`: the shipped sprites beside an amber mock (not shipped; reddish 336 -> 0, 1029 -> 0).
4. The explosion light (`lights.json`) keeps its vermilion rim: amber needs a new palette token (not this lane's file).
   Seen in `stills/red_fire_explosion_pair2_64.png`.
5. Mertz's vermilion gloves and the arena robot's red-striped coil are cast art: NEED cast if they should change.
   `stills/call_mertz_gloves_64.png` (both gloves boxed, 705 + 661 px; the coil: `stills/red_elec_burst_pair2_64.png`).
6. A killed card foe falls as the generic cop fall grid, not his own fall sheet (Next step 7): `stills/card_kill_pair_64.png`
   (the standing figure is Mulroney's card art, the fallen body is not).

## Merge notes
- After `n29-cast` merges, `KillFallCells.victim_scale`'s last line becomes
  `return k if pose == null else pose.sheets.scale_of(rig.actor_id)`; `test_a_card_victim_falls_at_his_live_card_scale`
  fails if this is left stale.
- NEED keys: the molotov rag (`molotov/held.png`, `pickup.png`, `held_55/molotov.png`, row 12); 124 item and held files
  (row 16); the showcase and small plasma swords; the `rivet_eq_plasma_sword*` sheets in view/p55 and p70.
- NEED tooling: `tools/godot/check.mjs` noise filter lacks "Pages in use exist at exit in PagedAllocator".
- NEED kills tooling: `tools/film/kill_reel.mjs` at HEAD kills nothing unless `-- --controls=legacy` is passed (the dev
  arena starts on wheel/hands controls and takes the lab's gun away); its default should pass it.
- `KillLabTurn.melee_victim` now serves gun labs too for a single `--foe-mix` (dev only; the name is kept).
- Root `JOURNAL.md` / `REPORT.md`: keep this lane's on an add/add conflict.

## Next steps
1. The owner's calls above, above all `fx_amber_ink` and the chain hop's new weight.
2. Keys: repaint the molotov rag, the `rivet_eq_plasma_sword*` sheets and the showcase/small swords with the same masked
   recolour (`python -I evidence/n29/red/recolour.py --sword` / `--sword-specks --hot` already handles the hilt mask).
   Then re-run `evidence/n29/red/audit_count.py` for rows 12 and 16.
3. Pin `current_look.gd`'s five `draw()` survivors with a render readback; mutate the rest of `weapon_fx_electro.gd` (40 of
   54 mutants unsampled).
4. Fold `CurrentLook`'s copied `_serial` back into `WeaponFxElectro`, and replace the match-guard side effect in
   `weapon_fx_art.gd` (`Kind.BOLT when WeaponFxBolt.draw(...)`) with a plain branch.
5. `kill_reel.mjs`: pass `--controls=legacy` by default (or arm the lab gun under the new controls).
6. Measure the gauntlet once with a natural (no prefill) bond film now that `--bond-prefill=0` runs.
7. A killed card foe falls as the generic cop fall grid, not his own `sergeant_mulroney_fall.png` (shotgun and cap
   flying): route the card row's own fall sheet into `KillFallCells.attach` when the kill style has no own cells
   (owner call: it changes a kill's look).

## Builder ledger
20 calls, all Claude sub-agents (Sonnet 5.5, except c2a fire and c6 kill card scale on Opus 5.5), 535 minutes in all.
19 accepted, 1 bounced (c2c: its code was right, but amber did not reach the screen; c2e finished it).

| call | min | result | note |
|---|---:|---|---|
| c1 bond 70 | 42 | accepted | one send-back (seed 8 explained from the raw result) |
| c2a red fire | 63 | accepted | two send-backs (amber print ink; `fx_fire.png` was the real burning ground) |
| c2a2 fire film | 8 | accepted | 1080p staging trick |
| c2c red electric | 33 | bounced | prints cream/vermilion under the item print |
| c2e amber on screen | 55 | accepted | cast view amber ink, opaque body, Mertz film |
| c2b red muzzle | 36 | accepted | source fixed; arena flashes not drawn from these cells |
| c2d red sword | 12 | accepted | masked repaint only |
| c2d2 sword stills + film | 7 | accepted | |
| c2f sword specks | 4 | accepted | `--hot` for the lit copper lights |
| c5 audit re-run | 13 | accepted | 28 rows with status |
| c3 bolt | 43 | accepted | one send-back (committed an unwired class) |
| c3b bolt bold | 30 | accepted | one width for bolt, hop, stun |
| c3c bolt jag | 26 | accepted | JAG_K 3.0 |
| c6 kill card scale | 55 | accepted | Opus; served cast's NEED |
| c7 card kill still | 16 | accepted | found the `--controls=legacy` trap |
| c4 mutate | 51 | accepted | 3 files, dev crash fix |
| c8 frames curate | 1 | accepted | frames.json to 15 best first, full list kept |
| c9 electro pins | 36 | accepted | tests only; both mutate runs at 100 % |
| c10 call stills | 1 | accepted | rocket band amber mock, Mertz gloves boxed (no Godot) |
| c11 card kill clips | 3 | accepted | 32 px/m before/after pair, 2.5 s (tool limit) |

What I would brief differently: (1) every art/colour brief asks for an in-game still at 64 px/m before commit A ("does
the change reach the screen through the print?"): the item print snapping amber to vermilion cost two calls; (2) "prove
the new path is the one the game draws" before any commit of new draw code; (3) give `tasklist` /
`Get-CimInstance Win32_Process` for the one-Godot check (`wmic` is missing in the builders' shell); (4) the decisions line
goes in the director's own brief list, not as a builder commit, since two parallel builders staged each other's lines.
