# n7-melee REPORT (night 2026-11-05/06): Rivet's melee and the four ghosts' attacks

DRAFT written 23:40 (iteration 6), updated 00:55 (iteration 8). The final version lands at 08:40, after the freeze and the exe
export. Clips are under `C:\Users\kazda\kiro\gtai-masters\n7\melee\` (`M/` below); the shortlist is in
`M/frames.json`. Every change below is view only: no sim tick, replay or parity hash moved. Quest 1's
final hash moved once, deliberately, when quest 1 started carrying the katana (`fbc5a982`).

## What works (with its evidence)
| Item | Commit | What changed | Before / after |
|---|---|---|---|
| Non-lethal melee wound (brief 2) | `1e32a7fd`, `a1716c1d` | a riot cop or SWAT now twists on a jab or first cut (MeleeWound, view only; the chainsaw grind does not restart it) | `M/melee_wound_riot_ab_48ppm_64slow.mp4` (before `--soft-swing`) |
| Melee weight (brief 3) | `65dd07e1` + rows | every melee hit reaches FeelCam (n7-ranged's layer): a hold on the hit frame, a kick along the blow, the kill stop; per-weapon rows for the claw, katana, baton and chainsaw | `M/melee_feel_claw_ab_32ppm_48slow.mp4` (before `--feel=off`) |
| Kerf's chain | `cb3e5caa` | a hold and a cream-and-ink cut flare per cut: it reads cut by cut instead of one blur | `M/kerf_chain_ab_32ppm_64slow.mp4` |
| Plasma sword deflect | `2502aaa7`, `a7ed5d4c` | a parry beat (a stop, a kick toward the shooter), a starburst on the bat frame and a streak along the return | `M/plasma_deflect_ab_32ppm_48slow.mp4` |
| Ohm's tell | `0555878c` | white sparks edged in ink reach from Ohm's fingertips toward the aim while the charge refills | `M/ohm_tell_ab_32ppm_crop.mp4` |
| Chainsaw kill | `49cc45d1` | a cream burst where the halves part, the grind's drops kept clear of the held body | `M/chainsaw_kill_ab_32ppm_48slow.mp4` |
| Tonnage press slam | `4c6c6bf5` | a landing flash, paper chips and dust on the slam | `M/tonnage_slam_ab_32ppm_48slow.mp4` |
| Dent's blast and blow | `cb3e5caa`, `4a522dfe` | felt: a kick outward from the car (blast), the melee stop plus a crash shake (blow) | `M/dent_blast_ab_32ppm.mp4`, `M/dent_car_blow_ab_32ppm_04x.mp4` |
| Tonnage ram | `0c4161d8` | a cream burst past each rammed body, paper chips along the shove | `M/tonnage_ram_ab_32ppm_48slow.mp4` |
| Tonnage plates | `8375c763`, `330779ff`, `d97a976d` | an enemy round now stops at the plate face with a small capped glance spark (it drew through his body before) | `M/tonnage_plates_ab_32ppm.mp4` |
| Ohm mass arc | `454490ce`, `7ce7b33d` | the branches draw at 0.55 of the bolt; a stunned crowd keeps full marks on the 2 newest bodies only, so the cops' blue reads through | `M/ohm_mass_arc_ab_32ppm_04x.mp4`, `M/ohm_stun_crowd_ab_32ppm_04x.mp4` |
| Melee and ghost hit sounds | `f593aac4` | each attack family plays its own sound on the hit tick, built from the shipped bank (claw knock, blade cut, chainsaw bite, baton zap, ghost slam, Ohm bolt) | `M/hit_cues_ab_32ppm.mp4` (before `--hit-cues=off`) |
| Claw jab reads at 32 | `f45ad8e6` | three cream rakes edged in ink across the struck cop on the hit frame, fading over 10 ticks | `M/claw_rake_ab_32ppm.mp4`, `M/claw_rake_48ppm_04x.mp4` (before `melee_marks.json` claw `flash_ticks` 0) |
| Ghost hits move the victim | `91700e01` | a body Tonnage rams or throws with the slam, and that survives, now plays a knockdown on the hit (before: no reaction at all); a rammed riot cop goes down instead of standing braced | `M/ghost_wound_ram_ab_32ppm.mp4` (before `human_reactions.json` `ghost_wound` {}) |
| Quest 1 shows melee (brief 5) | `fbc5a982`, `8237d411`, `becfeb7f`, `806a657e`, `5f80e67c` | Rivet carries the katana on key 2 in quest 1; the shipped sprite cast draws the blade, the swing and the smear | `M/quest1_katana_ab_32ppm.mp4` (before `--quest-blade=off`) |

The whole polished set in the city block at 32 px/m, with the game audio:
`M/melee_polished_set_city_32ppm.mp4` (53 s).

Gates on the last build commit `7ce7b33d`:
- lint 13/13;
- unit 1178/1178 (`test_noir_shadows` flaked once, green alone);
- scenarios 52/52 with 0 SCRIPT ERROR;
- director reel 19/19 in the arena and 19/19 in the city block.

The logs are in `evidence/n7-melee/`.

## What does not (yet)
- The hit sounds reuse the shipped bank, pitched per family. Real recorded swings, cuts and slams
  are still missing (sound scores 3, not higher).
- The heap at the car under Tonnage's ram still reads as one blob at 32 px/m: the sim shoves the
  bodies into the car. Two view-only tries were reverted because they could not be seen in motion:
  a bigger burst on a ram kill (no ram kills in the beat), and ink speed lines over the shove (they
  lie under the press). The rammed bodies now react (`91700e01`): in the city the riot cop is
  thrown clear and reads, but a body that stays inside the press's footprint is hidden. The cause
  is draw order, not marks: the ghost form draws above every rig (ghost-forms' rule), so no view
  mark can show a body under it. That is call (h).
- Tonnage's plates in quest 1 are on the same view path as in the arena, but they are not filmed:
  the quest bot never takes Tonnage.
- Kerf at full player cadence: the camera's 20-tick stop cooldown means only every other cut holds.
  The kick and the flare still mark every cut.

## Calls for the owner
(a) Quest 1 carries the katana on key 2.
- Options: katana (built), electro baton, none.
- Clip: `M/quest1_katana_ab_32ppm.mp4`.
- Exe (quest 1 is the slice build): `build/export/windows-slice/RTAI.exe -- --quest-blade=off`
  (before), `-- --quest-blade=electro_baton` (the baton instead); no flag = the katana. The arena exe
  `build/export/windows/RTAI.exe` cannot open quest 1 (release templates take no scene path).

(b) Tonnage's stomp ignores `--feel=off`. The stomp's stop and shake come from HaulerKick, outside
the shared layer.
- Options: leave it, or route it through FeelCam.

(c) Dent's blow feel (`hit_feel.json` `dent_car`, class ram).
- Clip: `M/dent_car_blow_ab_32ppm_04x.mp4`.
- The off value is to delete the row.

(d) Tonnage's plates stop rounds in the view only; the sim radius is unchanged.
- Clip: `M/tonnage_plates_ab_32ppm.mp4`.
- Before: `--feel=off`.

(e) Ohm's branches draw at 0.55 of the bolt.
- Clip: `M/ohm_mass_arc_ab_32ppm_04x.mp4`.
- Before: `ghost_attacks.json` ohm `branch_k` 1.

(f) A stunned crowd draws full stun marks on its 2 newest bodies only; the rest get a spit and a
head spark.
- Clip: `M/ohm_stun_crowd_ab_32ppm_04x.mp4`.
- Before: `human_reactions.json` `stun_crowd.full` 0, or `--feel=off`.

(g) A ghost blow reaches past a riot shield like Rivet's melee (the rammed riot cop goes down).
- Options: past the slab (built), or the shield braces and shows its block sparks.
- Clip: `M/ghost_wound_ram_ab_32ppm.mp4`.
- Before: `human_reactions.json` `ghost_wound` {} (no ghost wounds at all), or `--feel=off`.

(h) The ram heap: a body the press shoves into a car sits inside the press's footprint, under it.
- Options: leave it (built); pop the struck body above the form for the shove's ~0.3 s (breaks the
  ghost-forms rule that no human draws over a ghost body); or let the sim keep rammed bodies out of
  the footprint (a sim change and a deliberate re-bless).
- Still: `M/ram_heap_under_press_32ppm_2x.png` (city, 32 px/m at 2x, frames 138/146/150: the star,
  the bonnet cop's head peeking from under the press arm, the riot cop thrown clear).
- See it: `RTAI.exe -- --arena=city --bot=ghosts --ghost=tonnage --rigs --ppm=32` (contact at
  about 2.3 s).

## Next steps
See the last NEXT entry in `JOURNAL.md`.
