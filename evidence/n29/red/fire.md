# n29 combat 02a: the fire cells from red to amber (red audit rows 1-4, 13, 14)

Env for every Godot run: `APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/combat`,
`GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`, `GTAI_GODOT_EST_MB=1000`.
Both takes run through `runGodot` with `--rendering-driver d3d12 --windowed --position 0,1440 --resolution 1920x1080 --fixed-fps 60`.

## Takes (same command before and after; `<side>` = before | after)

1. Reel director cut, chapters rocket_launcher + flamethrower + molotov, 64 px/m, tick-exact stills every 5 ticks:
   `node evidence/n29/red/take.mjs build/n29red/<side>/reel $(seq -s, 5 5 1200) --rigs --bot=reel --reel=director --loadout=pistol --chapter=rocket_launcher,flamethrower,molotov --ppm=64 --clean --silent --shot=user://n29red_end.png --shot-tick=1205`
   - blast (`blast_1`): tick **70** (blast_0 at tick 65), crop x760-1440 y200-860
   - flame + flame cone: tick **470**, crop x560-1320 y260-860 (the crop also holds blood: reddish there is not all fire)
   - burning ground (molotov): tick **1000**, crop x740-1400 y320-900
2. FX showcase (every fx kind on the selftest junction, paused, at a third of its life): the `explosion` kind cloud
   (`fx_atlas.png` cells 9-12) at 64 px/m: `node evidence/n29/red/fxshow.mjs build/n29red/<side>/fxshow`
   -> `fx-64ppm-1-fx.png`, crop x540-1120 y660-1080 (the crop's top edge holds some blood).
3. `python -I evidence/n29/red/stills.py <side>` copies each frame to
   `C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/red_fire_<effect>_<side>_64.png` (+ `_crop`) and counts
   reddish px per crop (`evidence/n29/red/count_red.py --crop`, the n28 gate).
4. Colour path (an A/B the reel offers, not the shipped look): the same reel command with `--fx-colour=on` and
   `--film-stills=65,70,470,1000 --shot-tick=1005` into `build/n29red/after_colour/reel`, then
   `python -I evidence/n29/red/stills.py after_colour` and `... stills.py pair` (pairs + triples).
5. Rag light (`rag_light.gd`) and the nuke tip (`fight_nuke_art.gd`): no take above shows them; code-only change.

## The remap (evidence/n29/red/recolour.py, commit 3a7fcfed0)

A pixel moves when alpha > 0 and it is reddish by the n28 gate (R>170, G<110, B<90) or its HSV hue is in
345..25 deg with saturation > 0.35. It goes to the hue of `ElectricArc.HALO` `#edab42` (36.8 deg) keeping alpha,
its max channel (HSV value) and its min channel (so the saturation): R = max, G = min + (max - min) * 36.8 / 60,
B = min. No darkening (DARKEN 1.0): the cells on cream read as amber fire, not pale. Everything else keeps its
bytes; fx_atlas cells 0-8 and 13-31 are pixel-identical (sha256 of cells 0, 1, 2, 8, 13, 14 before = after:
9514b682f6dabf52, 73647034ad18f293, 12fdab41a8fc9dc0, 9bf0fc40877cc3e7, e9872c3143ebe8a9, a4fae96c67b4ba35).
Code: `Ink.AMBER` (`#edab42`, appended to `boot/collect_call/view/ink.gd`) in `rag_light.gd` and `fight_nuke_art.gd`.

## Reddish px (n28 gate)

| effect | file(s) | cells px before -> after (changed) | crop px before -> after (default look) | crop px after, `--fx-colour=on` |
|---|---|---|---|---|
| blast | `fx/blast_0.png`, `fx/blast_1.png` | 6105 -> 0 (6424), 34363 -> 0 (35776) | 53046 -> 52948 | 107 |
| flame + cone | `fx/flame_0..2.png`; `fx/colour/flame_0..2.png`, `fx/colour/flame_cone_0..2.png` | 6926/7949/7940 -> 0; 3057/3324/3455 -> 0; 5676/5786/5805 -> 0 | 38143 -> 38089 (blood in the crop) | 687 (blood) |
| burning ground | `fx/colour/ground_fire.png` | 3093 -> 0 (37256 changed: the orange-red fringe) | 22026 -> 22026 | 306 |
| explosion cloud | `fx_atlas.png` cells 9, 10, 11, 12 | 2032/4676/1966/965 -> 0 | 18217 -> 1127 (the rest is blood at the crop top) | - |

## What the pairs show (finding)

- **explosion**: the star in the cloud is amber with its ink rim; reads as fire. Done in the game.
- **blast, flame, burning ground: no visible change in the default look.** The shipped look draws the weapon FX
  as ink cells under the actors' nearest-ink item print (`weapon_art.json` `fx_colour_dir` "", owner pick d7
  look-3; `WeaponFxColour` doc): the print snaps every non-ink colour to its nearest palette ink, and the
  nearest ink to amber is vermilion. The repainted PNGs are only seen under `--fx-colour=on` (the colour folder
  on `look_d5_fx`, the cell's own colour): there blast, flame and ground fire read amber (triples, right column),
  the blast keeps its cream core and ink rim, the flame tongues and bursts are amber-yellow, never pink or brown.
- So the fire group's red on screen comes from the item print, not the PNG pixels. Clearing it needs one of
  (outside this call's allowlist): an amber ink in the item print's palette (the look shader / `palette.json`),
  or `fx_colour_dir` set to the colour folder (a table, and a reversal of the owner's d7 look-3 pick).
- Rag light / nuke tip: no take shows them; both draw through the same views, so they may snap to vermilion too
  (unverified).

Stills: `C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/red_fire_<effect>_{before,after,after_colour}_64[_crop].png`,
`red_fire_<effect>_pair_64.png` (before | after), `red_fire_<effect>_triple_64.png` (before | after | after `--fx-colour=on`).
No before exists under `--fx-colour=on` (the PNGs had changed when the colour path was found).

## After2: the amber ink in the FX view's print (director-authorised, 01:46)

`look_d4_item.gdshader` gains `uniform float amber_ink` (0 = the D4 inks alone) and `AMBER` (#edab42) as a nearest-ink
candidate; `PrintStage.fx_material()` is a copy of the item print (same uniforms each look update, same world_px) with
`amber_ink` from `look_profiles.json` `"fx_amber_ink"` (true; **false = off**); `CollectCallView` gives it to `fx_view`
only. Takes: the same reel command with `--film-stills=65,70,470,1000 --shot-tick=1005` into `build/n29red/after2/reel`
and `fxshow.mjs build/n29red/after2/fxshow`; `stills.py after2`, `stills.py pair2` -> `red_fire_<effect>_after2_64.png`
(+ `_crop`), `red_fire_<effect>_pair2_64.png` (before | after2).

| effect | crop px before | after (PNG remap) | after, amber ink |
|---|---:|---:|---:|
| blast | 53046 | 52948 | 953 |
| flame + cone | 38143 | 38089 | 17342 (blood and the hit bursts) |
| burning ground | 22026 | 22026 | 21934 |
| explosion cloud | 18217 | 1127 | 1127 |

Proof nothing else moved (`python -I evidence/n29/red/ink_diff.py build/n29red/after build/n29red/after2`, a pixel
counts when a channel moves > 24): blast 52416 px inside the box, **0 outside**; flame 24883 inside, **0 outside**;
burning ground 181 inside, 0 outside; explosion 0 / 0. Rivet's collar, the cops and pickups are outside the boxes.

Read: the blast is an amber star with its cream core and ink rim; the flame tongues are amber with cream hearts.
**Left red:** the flamethrower's hit bursts and the molotov's burning-ground bursts (the ragged starbursts at t470 and
t1000) do not move with either change: they come from another source than the PNGs of this call (not traced in time).
