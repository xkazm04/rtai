# REPORT - lane audio (branch `d-audio`), 2026-11-03, iteration 59 (REPORT, 17:30)

Nothing new was built in this phase. This is the state of the branch at the head commit, `e244e44` plus this file.
Labels: **measured** = a number from a tool. **heard** = a human listened. **Nobody has heard any of this.**
This session has no audio device, so everything below is measured, spectrogram-checked or Whisper-read-back only.
All GPU clips were recorded on a CONTENDED machine, with D3D12 and Godot's movie maker. None is a timed bench.

## 1. What works

| Claim | Evidence |
|---|---|
| **Audio service.** 24 pooled `AudioStreamPlayer2D`, at most 4 starts per frame. Per-cue cooldown, voices and priority steal. Distance cull. Engine panning with the camera as listener. Buses sfx / sfx_far / voice / music / radio / ui, built at boot from `audio_mix.json` (no `default_bus_layout.tres` touched). | `project/features/audio/*.gd`, `project/data/tables/audio_cues.json`, `audio_mix.json`. Unit tests `project/tests/unit/test_audio.gd`, `test_audio_hooks.gd`, `test_audio_driving.gd` (358 pass at a14dd64). |
| **Event table.** F-04 events (shots, hits, `actor_killed`, `player_hit`, electroshock, `pedestrian_struck`, `actor_knocked_down`, `vehicle_*`, `attack_telegraphed`, `boss_engaged`, `contract_*`) and the CitySim projectile feed map to cue ids. Variation and pitch jitter come from `AudioDice`, seeded off the registry seed. | `evidence/sfx_map.json`. Tip check at 17:19 (JOURNAL iteration 58): no Event on any lane tip lacks a hook. |
| **SFX set.** 69 files in `project/assets/audio/sfx`, plus 4 music files. Covers all the briefed sounds (pistol, rifle, nail gun, flesh/metal/concrete impacts, electroshock, engine loop, horn, crash, tyre screech, siren, crowd, footsteps, servo). Added: `car_wreck`, `fire_crackle`, `body_fall`, `blood_splat` and `blood_spurt` (layered under deaths and kill punches), `boss_stinger`, `boss_loop`, `crowd_roar` bed, UI cues. | `evidence/audio_report.json` (QC). `evidence/spectro/fire_crackle_0{1,2}.png`. Provenance: `steam/ai-provenance/2026-11.jsonl` (783 lines in the file; the lane's lines are the audio ones). |
| **QC, measured.** 36 raw SFX takes in the first pass: 32 kept, 4 rejected (pistol takes 02, 03, 04 and `impact_concrete_02`). Later passes rejected `kill_punch_02`, `ui_back_02`, `boss_stinger_01`, `boss_stinger_02` and `blood_spurt_02`. Targets: SFX peak -3 dBFS, loops -6 dBFS, voice -18 LUFS, music peak -6 dBFS. QC caught three faults after my first "0 rejected" (noise-burst pistols, a growing concrete impact, a radio loop that faded to silence). | `evidence/audio_report.json`, JOURNAL iteration 1 and 49. |
| **23 quest-1 voice lines**, ElevenLabs stock premade voices, no clones, profanity as written. Marked `"status": "temp"` in `tools/audio/casting.json` and `project/data/tables/voice_lengths.json`. The `audio` field is filled on all 23 lines in `project/quests/collect-call/quest.json`. Whisper read-back: mean WER 2.9% (the remainder is digits vs words). It found one real fault ("...One" read as a stray syllable), fixed with `tools/audio/fix_who_is_this.sh` (WER 0 after). | `evidence/voice_stt.json`. `project/assets/audio/voice/` (23 files). |
| **Radio stub.** 3 loops and 1 stinger from ElevenLabs `/v1/music`, on a band-limited `radio` bus. On with `vehicle_entered`, off with `vehicle_exited`. `radio_next` changes the station. Stinger on `contract_completed`. | `project/assets/audio/music/`, `project/features/audio/car_radio.gd`, `data/tables/audio_radio.json`. |
| **Mix pass, recorded clips with levels in a data table.** Riot with blood layers: -19.9 LUFS, true peak -2.2 dBFS. Quest opening: -17.5 / -3.5. Quest fight: -18.8 / -1.0. Vehicles carnage with fire bed: -17.5 / -1.1 (hot). Vehicles merge carnage: -16.5 / -3.1. Slice with the patch: -19.5 / -2.9. | `evidence/mix/mix_levels.md`, `riot_mix6.mp4`, `q1_opening_mix3.mp4`, `q1_fight_mix4.mp4`, `vehicles_fire.mp4`, `vehicles_merge_carnage.mp4`, `slice_q1_audio.mp4`, each with `*_cues.json`. Frames I looked at: about 12 across the day, all straight down, **0 camera breaks rejected**. Index: `C:\Users\kazda\kiro\gtai-masters\day-d5\audio\frames.json` (12 entries) and `ladder.png`. |
| **Pan and distance.** 14 m left/right = ±6.3 dB; 25-45 m = ±9.5 dB; sources beyond 22 m go to a 2.5 kHz low-pass bus. | `evidence/mix/pan_check.txt` (the low-pass check is not a clean A/B: the probe draws a random take per shot). |
| **Service cost.** 30 µs mean / 335 µs max per frame in the 300-person riot, plus 25 µs per cue. **Headless, contended CPU, not a bench**; real device mixing is unmeasured. | `evidence/audio_cost.json` |
| **Proven merges** (scratch worktrees, since deleted). Six tips (d-slice, d-vehicles, d-combat, d-audio, and the patch): 463 unit tests pass, 13 scenarios 0 failed (with the d-vehicles native DLL). Also d-bodies + d-audio: 367 unit tests pass. | JOURNAL iterations 49-53 (the 463 / 13 figure is from the f2c955d check, iteration 53). Lint re-run today at 17:30: 13/13 over 353 GDScript files. |
| **Credits.** About 4.6k of the lane's 25k ElevenLabs cap, used mostly on SFX and music. Voice characters spent after the 11:45 owner rule: 0. These are my own estimates; I never read the balance back from the API. | JOURNAL (cost lines) |

## 2. What does not work, or is unproven

1. **The slice is silent until the Director applies `evidence/requests/quest1_game_audio.patch`** (9 lines in `boot/quest1_game.gd`). Nothing in d-slice calls `StageAudio`. The patch applies clean on every slice tip I checked, and the last scratch merge proved it works.
2. **6-7 of 23 voice lines are dropped from the voice queue** in the real timeline: `rivet-third-person`, `rivet-who-is-this`, `juno-load-bearing`, `brass-gloria`, `kilohm-accents`, `rivet-buildings-talk`. The voice runs about 272 s against 121 s of subtitles. In the slice's scripted-pad clip, a Whisper read-back found only 8 lines clear in the mix (`evidence/mix/slice_q1_intelligibility.json`).
   - No audio-side policy fixes this: I tried priority drop and a longer backlog and rejected both on measurement.
   - The fix is the line timing: REQUEST 1 to slice-play, either `line_type_cps` ~15 and `line_max_s` ~22, or a per-line max(text time, voice length + 0.4 s). It moves the replay and scenario goldens, so it was never mine to change.
3. **Not heard by a human, any of it.** Pacing, acting and timbre of the 23 temp voices, the pistol tails, the footstep feel, Patch's phone filter, the 3 radio loops, the boss loop and the blood sounds.
4. **Voices are TEMP.** The PoF Voice room (lane `pof-voice`) replaces them. I did not check whether it landed.
5. **POF-GAP 1 (HIGH):** PoF `/api/audio-gen` refuses every sfx/ambient request. Its prompt wrapper pushes the text to 568-592 characters against ElevenLabs' 450 limit. I re-checked this 4 times (10:08, 11:25, 12:07 and once more). Every SFX file therefore came from a direct `/v1/sound-generation` call. The craft pack is also hard-wired to a dark-fantasy hall reverb. **So the dual-development goal (exercise PoF's pipeline) was not met for SFX.**
   - POF-GAP 2 (no tts) is HIGH for narrative games; the Voice room should close it.
   - POF-GAP 3 (no music kind) is MEDIUM.
6. **Hot clip:** `vehicles_fire.mp4` true peak is -1.1 dBFS when two wrecks and crashes stack (AAC re-encoded). If it clips on a device, lower the `car_wreck` `gain_db` from -1 to -3.
7. **Settings sliders:** `AudioBuses.set_user_gain` exists and is unit-tested, but the pause card has only a master slider (REQUEST 5, optional).
8. **Not built:** positional cruiser sirens (the siren is one bed by wanted level), tyre screech as a slide loop (the vehicles lane fires a one-shot at slide start), per-surface footsteps, real boss and tazer SFX beyond the generated charge, stinger and loop.
9. **Open flake, not audio:** `test_noir_shadows::test_only_shadow_commands_with_a_length_are_swept` fails intermittently (an engine texture error), and the import occasionally crashes on a contended machine.
10. **Bench never run by this lane** (shared GPU, bench lock held; the audio service has no GPU work). The server-side cost is only the headless figure above.

## 3. What blocked me, and for how long

- **POF-GAP 1:** from 10:08 for the whole day (about 7 h). It forced the direct ElevenLabs route for every SFX and all music.
- **POF-GAP 2/3:** from 10:08 for the whole day. TTS and music were direct calls as well; TTS stopped at 11:45 by the owner's rule.
- **Slice-play's REQUESTS 1, 3 and 6** (voice timing, the `StageAudio` wiring, the `radio_next` input row): open from about 11:50. Nothing of mine blocked on them, but the quest is silent and clipped until they land.
- **Environment friction:** no audio device, so no listening. Python under Git Bash resolves `/c/...` and `/tmp` differently from bash. My shell's cwd drifted between worktrees. All three cost me about two runs and no more. `tools/audio/build_tables.py` went stale and is now retired.
- **d-slice vs d-combat conflict** in `boot/collect_call/view/collect_call_view.gd`. Lint's gd-size fails (`_ready` is 43 lines) unless combat's blood block moves into `_ready_blood()`. The text is in `evidence/requests/collect_call_view_ready_blood.txt`. It is not audio's file; the Director merges it.

## 4. Next steps

1. **Director at merge**
   - Apply `evidence/requests/quest1_game_audio.patch`.
   - Add the `radio_next` row (`evidence/requests/input_actions_radio_next.txt`).
   - Resolve the slice/combat conflict with `_ready_blood()`.
   - Build the native DLL from d-vehicles for the scenarios.
2. **Slice-play:** decide REQUEST 1 (line timing). It is the single biggest audio defect, 6-7 lost lines.
3. **A human listens, in this order:**
   - the 23 temp voices;
   - the pistol and nail gun takes;
   - footsteps;
   - the boss loop;
   - the 3 radio loops;
   - blood, fire and body_fall.
   
   Reject anything that sounds wrong; QC so far is numbers and spectrograms only.
4. **Replace the temp voices** with the PoF Voice room's output (casting in `tools/audio/casting.json`), then re-run `tools/audio/voice_lengths.py` and `stt_check.py`.
5. **PoF:** add a raw-prompt opt-out, a length guard and a game-style-configurable pack to `/api/audio-gen`, plus tts and music kinds. Then redo one SFX through PoF to exercise it.
6. **After the merge:** re-run the three scratch scenes in `evidence/requests/*.gd.txt` on main (the slice clip must stay near -19.5 LUFS) and re-take the bench with the lock.
7. **Mix:** the riot is about 3 LU under the voiced quest; no occlusion; per-bus sliders.
