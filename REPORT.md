# REPORT: lane visual-fixes (branch `e-fixes`), 2026-11-03 evening

Four items: the sticker rim, the road width, the voice lines, the riot slowdown. Items 1-3 are built and evidenced; item 4 is a finding with no fix. Every path below was checked to exist at 23:41. Copies of the evidence are in `C:\Users\kazda\kiro\gtai-masters\eve\visual-fixes\` (`frames.json` is there too).

Not listened to or played by a human: the voice proof ran on a dummy audio driver. Not driven by a person: the narrow streets.

## 1. White border thinned by 50 % (commit `70a1d668`): works
- **Where the rim comes from.** It is the halo sprite under each part, in `CutRig._on_view`. Both rig tiers use it, and the crowd atlas bake renders real CutRigs, so the atlas follows too. `CutRig.RIM_K = 0.5` multiplies the halo growth. It is one constant, no art repainted.
- **Rim width in screen px, before -> after** (`evidence/rim/rim-before.json`, `evidence/rim/rim-after.json`; method: one rig alone on flat asphalt, halos on vs off, area delta / perimeter, `project/dev/showcase/rim_measure.gd`):

| px/m | rivet | cop | ped |
|---|---|---|---|
| 32 | 1.31 -> 0.60 | 1.86 -> 0.90 | 1.26 -> 0.60 |
| 48 | 1.90 -> 0.95 | 2.32 -> 1.16 | 1.72 -> 0.80 |
| 64 | 0.79 -> 0.36 | 1.20 -> 0.56 | 0.67 -> 0.27 |
| 128 | 0 -> 0 | 0 -> 0 | 0 -> 0 |

  At 128 px/m the halo already fades out, so there is nothing to thin there. Frames per site: `evidence/rim/rim-{before,after}-{rivet,cop,ped}-{32,48,64,128}.png`.
- **Crowd atlas.** The mean rim over 8 looks at 48 px/m went from 1.97 to 0.98 px (`evidence/rim/atlas-rim-summary.json`, `project/dev/showcase/atlas_rim.gd`; frames `evidence/rim/atlas-before.png` and `atlas-after.png`). The halving is exact by construction. The widths are measured.
- **Silhouette still separates from asphalt.** Edge contrast drops but stays well above the 128 px/m baseline of about 0.16-0.19, where there is no rim at all. Rivet at 32 px/m goes 0.525 -> 0.418 and at 48 px/m 0.496 -> 0.464. The ped is the weakest case: 32 px/m 0.577 -> 0.444, 48 px/m 0.594 -> 0.483. The cop at 48 px/m goes 0.529 -> 0.492.
- **Look goldens re-blessed once** at both sites, with a dated line in `docs/decisions.md`. Look frames: `evidence/look/block`, `evidence/look/junction`.
- **Not done or not measurable:**
  - There is no robot rig kind in the repo, so no robot was measured.
  - Portraits carry no sticker rim (inked drawings on cream paper), so they were left alone (`e3d53957`, in `docs/decisions.md`).
  - The measurement is per rig on flat asphalt, not on a lit scene with every layer on.

## 2. Roads narrowed from 18 m to 12 m (commit `1601c660`): works, width is a placeholder
- **Change.** The generator constant `CityGen.WALK_M = 6` is the whole change. The 8 m tile grid, the 8 m lane tile, the nav tile classes and the junction box are unchanged. Each kerb tile now holds a 6 m sidewalk and a 2 m kerb-side strip for parked cars. The new art is `curb12_*`, composed by `tools/art/narrow_kerb.py`.
  - Lamps, kerb props, drains and the zebra follow the kerb.
  - A parked car's solid footprint is the 1.8 m strip.
  - GENERATOR_VERSION 13 -> 14, `city_chunks.sha256` re-baked (AST-12 ok).
  - Quest 1's stage origin was re-fitted (the bot stalled on a parked car) and the cop-shoots test victim was moved. A texture-count test was updated.
- **Width question.** I asked the owner (`gtai-eve\decisions\asks\visual-fixes-1.json`: 10 m, 12 m, or keep 17 m; default B). The answer was B, taken as a placeholder ("not judgeable in this state"). T1 shows about 10 m. 10 m would be `WALK_M = 7` plus a 1 m parking strip, which needs new art. Back to 18 m: `WALK_M = 3.0`, `KERB_TEX = [7, 8, 9]`, `CORNER_TEX = 10`, re-bake.
- **Evidence.**
  - Same foci before/after at 32 and 48 px/m: `evidence/roads/before/city-N-{32,48}ppm.png`, `evidence/roads/after/city-N-{32,48}ppm.png`.
  - Side-by-side comparisons with the mock: `evidence/roads/cmp-focus{0,2,3}-{32,48}ppm.png`. T1 is `C:\Users\kazda\kiro\pof\games\gtai\art-direction\directions-v2\d4h2_mock.jpg`.
  - Real-time driving clip, 20 s on the 12 m street: `evidence/roads/drive-12m-clip.mp4`, with stills `drive-12m-t{300,660,900}.png` and `evidence/roads/drive/run.log`. The car holds full throttle, takes an S-bend and a handbrake slide inside the kerbs.
  - Quest 1 slice on the 12 m city at 32 and 48 px/m: `evidence/roads/quest1/p32`, `evidence/roads/quest1/p48`. No script errors, exit 0.
- **Gates on the commit.** Lint 13/13, unit 538/538, scenarios 19/19, parity exact. Replay and AST-12 goldens were moved and re-blessed on purpose, recorded in `docs/decisions.md`.
- **What does not work or is unproven:**
  - The only driving coverage on the narrow lanes is `vehicle_drive`, `vehicle_yield` and my clip. I did no traffic-jam or car-chase check in the city.
  - Arena finding (REQUEST 1 -> arena): the city-block spawn `range/strafe_05m` at (529,509) lands in a building on the 12 m city. It is dropped silently with a log line, which is harmless but unintended. I found this on a throwaway merge of `e-arena`, and the worktree is removed. Only the arena owner can fix it.
  - The 12 m width is not a settled design value.

## 3. Voice lines play in full (commit `3ebecaf5`): works on the timeline and the queue; not heard
- **Rule.** Each voiced line lasts `max(text time, voice_s + 0.4 s)`, with `voice_s` from `data/tables/voice_lengths.json` through `VoiceLengths` and `QuestLine.VOICE_BEAT_S`. Silent barks keep the old pacing.
- **Timeline.** The slice run went from 190.6 s to 329.7 s, and all 23 lines are at least voice + 0.4 s (`evidence/lines/timeline_before.json` and `timeline_after.json`, from `project/dev/audio/line_timeline.tscn`).
- **Queue replay, offline model** (`tools/evidence/voice_queue_sim.py`): before, 17/23 lines were spoken and 6 were dropped. Those 6 are rivet-third-person, rivet-who-is-this, juno-load-bearing, brass-gloria, kilohm-accents and rivet-buildings-talk, which matches the owner's 6-7. After: 23/23, 0 dropped, queue never backs up (`evidence/lines/voice_queue_{before,after}.json`).
- **Engine run.** The real `CollectCallPlay`, `StageAudio` and `VoiceChannel` ran through the whole 329.7 s quest with `project/dev/audio/audio_beat.tscn` (`evidence/lines/voice_engine_run.json` and `.log`). Result: 23/23 voice lines spoken in order, 0 drops. The channel never cuts a line, so 0 drops means each one played to its end.
- **Not shown:** nothing was heard by a human, because the engine run used a dummy audio driver. The quest timeline is 140 s longer, and no pacing or feel judgement was made. No golden covers line durations, so none moved. Re-run the voice-length generator and the sim when the PoF voice room replaces the temporary voices.

## 4. Riot p99 doubled (commits `0845e3c1`, `a166225c`): found, not fixed
- **Table and raw runs:** `evidence/riot-bisect/riot-bisect.md`, `runs.json`, `step.sh`, `sum.py`. Method: a throwaway worktree per commit, an exported windows-bench, riot 3 x 45 s, median, bench lock held per run.
- **Contended, not idle:** 4-5 other Godot sessions were running, so absolute p99 is noisy. I judged on the average frame and on same-commit A/B pairs.
- **Result.** The step is the d-combat merge `f54c4ec`: average frame 1.13 -> 2.08 ms, p99 4.9 -> 8.3 ms. d-vehicles and the main tip stay at 2.06 ms.
- **Cost.** `CityBlood` (`boot/city_blood.gd`, attached by `CityCharacters._init`). The same commit with its two lines commented out (`CityBlood.attach` and `blood.follow`) is back at 1.13 ms average and 5.2 ms p99. Muzzle pop off: 2.13 ms, so not it. Corpse stains: inconclusive (a load spike).
- **Suspects inside it, not split:** the `CombatBlood` -> `BloodFx` redraw (`queue_redraw` every frame while drops fly, else every `settled_redraw_ticks` = 6), `BloodSplatMesh.update` every frame, and the extra canvas items.
- **Why no fix.** The code is in `features/fx`, not look, render or city. There was no idle bench slot to split it.
- **Not measured** (unmeasured is not zero): d-city alone, d-bodies, d-save and d-audio alone. The d-slice number (15.75 ms p99) is noise from an overlapping run.

## Blocked or slow
- Unit tests failed 170-560 tests at random while other lanes ran Godot (shared `user://` save slots). Setting `APPDATA` to a lane-private folder fixed it. It cost several re-runs of the gates across iterations (not timed), and it is in `docs/decisions.md`. Known flakes under load: `test_noir_shadows` and the `city_chase` 2 ms budget.
- The bisect needed the windows export templates inside the private APPDATA. The whole bisect ran 22:35-23:06, shared with the other lanes.
- `M project/features/characters/cut_rig.gd` in `git status` is a stale-index phantom (`git diff` is empty). The untracked `evidence/look` (25 MB) and `evidence/roads` (89 MB) are not committed on purpose. Their copies are in `gtai-masters\eve\visual-fixes\`.

## Gates
Lint was re-run at 23:41 on HEAD: 13/13 over 483 GDScript files. Unit 538/538, scenarios 19/19 and parity exact were last run in full on the road-width commit and at `e3d53957`, with a private APPDATA. No game code has changed since. I did not re-run them in this report phase.

## Next steps
1. Owner's final-look judgement on 12 m and on `RIM_K` (the rim is 0.6-1.2 px at 32-48 px/m now). For 10 m, use `WALK_M 7` plus a 1 m parking strip (new art). For a thinner or thicker rim, change `RIM_K` and re-bless the look goldens. Re-ask only with a real-time clip in the final look.
2. Riot blood, handed to the combat owner (REQUEST 2 in JOURNAL):
   - Print `CombatBlood.spent_us / frames` and `BloodFx.draw_us` in the bench JSON. The counters already exist.
   - Then raise `settled_redraw_ticks` 6 -> 30, redraw pools only when one changes, and bake settled pools into the ground print.
   - Re-bench on an idle machine against the 4.835 ms of record.
3. Arena owner: move `range/strafe_05m` off (529,509) on the 12 m city (for example (5,-10)).
4. Drive the 12 m city with traffic and a chase on the merged tree (vehicles lane and quest 1 service) before calling the width done.
5. A human listen-through of the 329.7 s quest 1 voice timeline for pacing.
