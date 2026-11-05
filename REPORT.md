# n7-melee REPORT (night 2026-11-05/06): Rivet's melee and the four ghosts' attacks

DRAFT written 23:40 (iteration 6). The final version lands at 08:40, after the freeze and the exe
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
| Quest 1 shows melee (brief 5) | `fbc5a982`, `8237d411`, `becfeb7f`, `806a657e`, `5f80e67c` | Rivet carries the katana on key 2 in quest 1; the shipped sprite cast draws the blade, the swing and the smear | `M/quest1_katana_ab_32ppm.mp4` (before `--quest-blade=off`) |

Gates on the last build commit `7ce7b33d`:
- lint 13/13;
- unit 1178/1178 (`test_noir_shadows` flaked once, green alone);
- scenarios 52/52 with 0 SCRIPT ERROR;
- director reel 19/19 in the arena and 19/19 in the city block.

The logs are in `evidence/n7-melee/`.

## What does not (yet)
- No attack has its own sound: every sound score is 1. Sound needs audio assets that this lane did
  not make.
- The heap at the car under Tonnage's ram (bodies pile into one blob at 32 px/m) is unchanged. A
  bigger burst on a ram kill was tried and reverted: no ram kills in the beat, so nothing could be
  seen.
- Kerf at full player cadence: the camera's 20-tick stop cooldown means only every other cut holds.
  The kick and the flare still mark every cut.

## Calls for the owner
(a) Quest 1 carries the katana on key 2.
- Options: katana (built), electro baton, none.
- Clip: `M/quest1_katana_ab_32ppm.mp4`.
- Exe: `RTAI.exe -- --quest-blade=off` (before), `--quest-blade=electro_baton` (the baton instead).

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

## Next steps
See the last NEXT entry in `JOURNAL.md`.
