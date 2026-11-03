# JOURNAL - lane audio (branch d-audio)

## 2026-11-03 iteration 1 (BUILD)
- 10:08 start. Credits at start (ElevenLabs creator tier): 70,719 / 143,292 used -> 72,573 left. Lane cap: 25,000.
- FRICTION: PoF `POST /api/audio-gen` refuses EVERY sfx/ambient request: `audioPromptFor()` composes subject + a ~350 char
  dark-fantasy craft clause + ~170 char negative tail, and ElevenLabs sound-generation caps text at 450 chars (got 568-571 for a
  1-word subject). Nothing was billed (400 from the provider).
- POF-GAP 1: PoF audio-gen sfx/ambient is unusable as shipped. The craft pack (a) alone exceeds the provider's 450 char limit,
  (b) is hard-coded "dark-fantasy action-RPG, cavernous stone-hall reverb", wrong for a modern top-down city game, (c) its
  tail says "no vocals / no voice", which fights crowd screams. Needed: per-request `rawPrompt`/`pack:none` opt-out, a length guard
  that trims the pack before the call, and a game-style-configurable pack. Severity: HIGH (blocks the whole route).
  Workaround: direct `/v1/sound-generation` call (tools/audio/gen_sfx.py), key passed by env var only.
- POF-GAP 2: no `tts` (PoF has no /v1/text-to-speech integration or voice catalogue). Severity: HIGH for narrative games.
  Workaround: direct ElevenLabs TTS (tools/audio/gen_voice.py).
- POF-GAP 3: no `music` kind (ElevenLabs /v1/music not integrated). Severity: MEDIUM. Workaround: direct call or placeholder.

### 10:55-ish MILESTONE audio service + SFX + voice landed (commits 06cf11c, cac8e98)
- Code (project/features/audio/): AudioService (24 pooled AudioStreamPlayer2D, per-frame cap 4, per-cue cooldown/voices/priority steal,
  distance cull + engine panning with the camera focus as AudioListener2D), AudioTables (data/tables/audio_cues.json + audio_mix.json,
  schemas), SoundBank, AudioBuses (sfx/voice/music/ui + radio built at boot from the table: no default_bus_layout.tres touched),
  AudioLoops (engine/siren/city beds), VoiceChannel (one line at a time, FIFO, max 2 waiting), AudioHooks (Events -> cues, footsteps
  by Rivet speed), StageAudio (quest 1 stage: shot feed + hooks + radio + QuestVoice), WorldAudio (riot world: FX sink + hooks + radio),
  QuestVoice (reads each line's `audio` field), CarRadio (stub).
- Shared-file edits (minimal): `core/render/fx_triggers.gd` +4 lines (a `sink` Callable called first thing in fire(), so any cue id
  fired, table row or not, is audible); `boot/world.gd` +2 lines (WorldAudio.attach after the fx_triggers listen, windowed only).
- DECISION audio dice: the brief says pitch jitter / variation "drawn from the RNG registry". A registry STREAM created mid-run enters
  RngRegistry.write_state, so a windowed recording (audio on) would diverge from its headless replay (audio off, no views). AudioDice is
  seeded from RngRegistry.seed_for(master, &"audio") but is its own counter, so the draw is a pure function of the seed and no stream
  is registered. (A unit test caught my first version dropping the master seed: seed_for puts it in the high 32 bits.)
- Credits: ElevenLabs 70,719 -> 73,091 used after 32 SFX + 23 voice lines (2,372 credits; TTS text was 4,011 chars). Lane cap 25,000.
- QC (tools/audio/process.py, evidence/audio_report.json): SFX 32 of 32 kept, 0 rejected. NOTE my first QC rule rejected 17 of 32 as
  "clipped" because MP3 decode overshoots 0 dBFS on hot sources (+4.6 dB float peaks); the rule was wrong (counted samples above 0.999),
  replaced by a flat-top test (>= 6 consecutive samples within 0.5% of the peak = hard clip); none of the takes has flat tops. I did
  NOT listen to the files (no audio device in this session): the checks are duration, peak, RMS, flat-top, silence, voice LUFS only.
  Targets: SFX peak -3 dBFS (loops -6 dBFS, 0.3 s equal-power crossfaded seam), voice -18 LUFS / -2 dBTP (measured -17.9..-18.8 LUFS,
  peaks -1.2..-3.8 dB), music peak -6 dBFS. Formats: SFX <= 3 s WAV mono 44.1k, longer Ogg q4 (AST-07).
- Voice casting (tools/audio/casting.json), stock ElevenLabs premade voices only, no clones: rivet=Liam, patch=Jessica (+telephone
  band-pass in post), don-fax=Roger, nurse=Sarah, gunsmith=Bill, scientist=Alice, dock-guard=Chris, mertz=Brian. Profanity as written.
- FRICTION voice vs subtitle timing: quest_rules line timing shows a line 2.2-9 s (121 s total for the 23 lines) while the voice runs
  4-20 s (272 s total); ALL 23 voices outlast their subtitle. Played sequentially (VoiceChannel FIFO, backlog 2) so nobody talks over
  anybody, but the subtitle runs ahead of the voice.
- REQUEST 1 -> slice-play (quest runtime owner): QuestLine.duration_ticks should be max(text time, voice_s + ~0.4 s) with voice_s from
  data/tables/voice_lengths.json (I ship it, gtai.voice-lengths/1). It moves the quest timeline and so the replay/scenario goldens: your call.
- REQUEST 2 -> vehicles: fire the audio through the FX trigger path or the cue API: `FxTriggers.fire(&"horn"|&"crash"|&"tyre_screech"|
  &"hit_metal", pos_px, 0.0, tick)` (the sink hears ids that have no fx_triggers row) and emit Events.vehicle_entered/exited (engine bed,
  radio on/off). `CarRadio.next()` flips the station, bind it to an input action.
- REQUEST 3 -> slice-play: in the real quest scene call `StageAudio.attach(parent, stage, system, bus, seed)` (one call: service + hooks
  + shot feed + voice + radio); the dev clip scene dev/audio/audio_beat.gd shows it.

### MILESTONE radio, mix pass, clips, QC hardening (commits ef91ab6 .. f35b092)
- Radio stub: CarRadio (data/tables/audio_radio.json): 3 x ~20 s loops + 1 stinger from ElevenLabs /v1/music (direct; POF-GAP 3), on a band-limited
  `radio` bus under `music`; on while Events.vehicle_entered..exited, stinger on contract_completed. Music cost 866 credits.
- Mix pass: first mix (sfx 0 dB, voice +2 dB) clipped under dialogue (+0.1 dBFS) and put the voice 11 LU above the riot. Now sfx +3 dB, voice -2 dB,
  Master hard limiter -1 dB (audio_mix.json). Clips (evidence/mix/*.mp4, recorded with Godot's movie maker, D3D12, real game scenes):
  riot -21.0 LUFS / -2.7 dBFS, quest opening -17.4 / -2.9, quest fight -19.8 / -2.7, demo tour -17.9 / -1.8. See evidence/mix/mix_levels.md.
- QC caught three real faults AFTER my first "0 rejected": (1) spectrogram sheet showed pistol takes 02/03 were constant broadband noise bursts
  with no decay -> new decay rule (second half vs first <= -18 dB, guns only), 4 new pistol takes; (2) impact_concrete_02 peaks at 224 ms and its
  energy grows -> rejected; (3) radio_loop_2 kept the generator's fade-out, so the loop dipped to silence -> dead tail cut before the seam.
  Final: SFX 32 kept / 4 rejected of 36 takes (raw pistol takes 02, 03 and 04 + impact_concrete_02), voice 23/23, music 4/4. (The commit message of e4f6d4a says +580 credits for the new pistol takes: wrong, the 4 takes cost ~36.)
  STILL NOT HEARD by a human. Measured: duration, peak, RMS, LUFS, flat-top clipping, silence, envelope, spectrogram look (sheet in masters).
- Credits: ElevenLabs used so far this lane: 3274 (started at 70,719; lane cap 25,000; account limit 143,292).
- Tests: 340 unit tests green incl. 15 new audio ones (tests/unit/test_audio.gd, test_audio_hooks.gd); scenarios 8/8, replay identical; evidence/run.mjs
  --no-bench green (lint, unit, scenarios, parity, selftest). NOT run: bench (lane rule: shared GPU; the audio service adds no per-frame GPU work).
  Pool cost not measured under the bench; the service does one array walk per cue and is capped at 4 starts per frame.

### FRICTION flaky unit test (not audio)
- `tests/unit/test_noir_shadows.gd::test_only_shadow_commands_with_a_length_are_swept` fails intermittently ("Parameter "t" is null", an engine
  texture error) in 2 of 5 full unit runs here (it passed alone and in 3 other full runs; the 340 tests are green otherwise). Not in my lane's files;
  looks like a GPU/Windows contention or import-order flake. Whoever owns the noir tests should look.

### MILESTONE final state of iteration 1 (HEAD f1210a0 + this entry)
- Pan/distance: a recorded probe (dev/audio/audio_pan.tscn, tools/audio/pan_check.py) showed the first audio space (32 px/m, strength 0.7) panned only
  +-2 dB at 14 m; widened to 64 px/m, strength 1.0 -> +-6.3 dB at 14 m, +-9.5 dB at 25-45 m, level -19.0 dB at 5 m / -29.9 dB at 45 m. Godot's 2D pan
  depends on the viewport width, so wider windows pan less.
- All four clips (evidence/mix/*.mp4 + *_cues.json + mix_levels.md) were re-recorded on the final assets and mix: riot -20.4 LUFS / -2.3 dBFS,
  quest opening -17.4 / -3.0, quest fight -19.8 / -2.5, vehicle/radio demo tour -17.3 / -1.0. Frames I looked at: 4, camera breaks: 0 rejected.
- Gates at f1210a0: lint 13/13, scenarios 8/8, parity exact + planted mutation caught, selftest + look goldens 11/11 unchanged (audio adds no pixels),
  unit 340 (1 flake above). Bench NOT run (lane rule; audio has no GPU work).
- masters: C:\Users\kazda\kiro\gtai-masters\day-d5\audio\ (raw takes + gen/voice/music logs, clips with raw AVI, spec/ spectrogram sheets,
  frames.json, ladder.png). Repo evidence: evidence/audio_report.json (QC), evidence/sfx_map.json, evidence/mix/.

NEXT:
1. Wire quest 1 for real: slice-play calls `StageAudio.attach(...)` in the playable quest scene and takes REQUEST 1 (line timing from voice_lengths.json,
   every voiced line outlasts its subtitle 2.2x on average: 272 s of speech vs 121 s of subtitles). Until then voices queue FIFO (max 2 waiting).
2. A human has to LISTEN: every SFX, the 23 voices (casting in tools/audio/casting.json), the 3 radio loops. I only have numbers and spectrograms.
   Likely weak spots: pistol takes 02-04 (long tails), footsteps (a 4-step clip replayed, not per-step), nailgun takes 02/03 (mostly tail), Patch's phone filter.
3. Vehicles lane: emit vehicle_entered/exited, fire horn/crash/tyre_screech/hit_metal through FxTriggers.fire (REQUEST 2); input action for CarRadio.next().
4. d5-combat/boss work: a boss telegraph cue exists (attack_telegraphed -> servo whine at 0.7 pitch); real boss/robo-tazer charge sounds are still a placeholder.
5. Mix: the riot is ~3 LU under the voiced quest; no occlusion or distance low-pass (Godot's 2D player has none); settings sliders (a volume per bus) not built.
6. POF-GAP 1-3 stand (audio-gen refuses every request; no tts; no music). Ask the PoF lane: raw-prompt opt-out, a length guard, tts + music kinds.
- Voice artifact check (ffmpeg silencedetect -40 dB, >= 1 s): 21 of 23 lines have no pause that long; rivet-who-is-this has 1 (the written "...One"), brass-gloria 2
  (check by ear whether the pauses are the written ellipses or a TTS stall). Speech runs ~14-15 characters/s.

## 2026-11-03 iteration 2 (BUILD, started 11:19)
- POF-GAP 1 re-checked at ~11:25 with a 2-word prompt: PoF audio-gen still 400s (568 chars > 450). Direct ElevenLabs route again (credits: 74,117 used after
  this iteration's first 17 SFX takes; lane total 3,398 of 25,000).
- MILESTONE footsteps: the old 2 s "4 steps" clips replayed every 1.7 s sounded like a loop. tools/audio/split_steps.py cuts the two generated runs into 8 single
  steps (footstep_01..08.wav, each with a decaying envelope: checked per 50 ms window); the hook now fires one per `footstep_stride_m` (1.15 m) of Rivet's walk
  (cue `footstep`, 8 takes, cooldown 8 ticks; servo chance per step 0.12). Unit tests: stride cadence (4 steps in 4.8 m), standing still = none.
- MILESTONE new cues, all generated direct (ElevenLabs sound-generation, 24 takes, QC rejected 4 of them for hard-clipped sources: kill_punch_02, ui_back_02,
  boss_stinger_01, boss_stinger_02; the others kept): `rivet_kill` (= kill_punch, 3 takes; the FX trigger sink already routes this id), `cash_ding`
  (cash_changed delta>0), `objective_ping` (contract_started), `ui_confirm` (contract_completed), `ui_click` / `ui_back` (API only: the pause card and
  menus are slice-play's), `tazer_charge` (attack_telegraphed with weapon robo-tazer; the other weapons keep the servo whine), `boss_stinger` (boss_engaged;
  one take, the others clipped). ui_click_01 had a stray blip at 0.45 s: cut to its first 120 ms by hand.
- Vehicles lane (their branch d-vehicles, not merged yet): it emits vehicle_entered/exited (already hooked), `vehicle_hijacked` and `pedestrian_struck(victim, killed)`
  and fires NO FxTriggers: hooks now connect to those two when the Events bus has them (has_signal guard; the unit test adds the signal with add_user_signal):
  run-over = hit_flesh (+ death when killed), hijack = hit_metal. No crash/tyre screech/horn event exists in their branch -> REQUEST 4 below.
- Clip re-recorded: evidence/mix/riot_mix3.mp4 (25 s, 960 px, replaces riot_mix2): -20.4 LUFS, peak -1.4 dBFS, LRA 1.8; played 38 steps, 199 shots, 208 projectile ends,
  135 deaths, 5 servo; Rivet does not kill in the riot so rivet_kill/kill_punch is covered by unit tests only, not by this clip. Frame at 12 s looked at: straight down, 0 rejected.
- FINDING (the biggest audio defect left) voice vs the quest timeline, measured, not guessed: dev/audio/line_timeline.tscn plays the bot through quest 1 and logs when
  each line is on screen; simulating the VoiceChannel FIFO (max 2 waiting) against voice_lengths.json: **6 of 23 lines are dropped** (rivet-third-person,
  rivet-who-is-this, juno-load-bearing, brass-gloria, kilohm-accents, rivet-buildings-talk) and the 17 that play start 0-16 s late (the subtitle has long gone).
  Quest 1 lasts 190.6 s; the voices alone are 272 s. Experiment (local, reverted): quest_rules line_type_cps 45 -> 15 and line_max_s 9 -> 22 puts every line on
  screen for its voice length +-3 s (one line, brass-gloria, 5 s short) and nothing is dropped, but quest 1 then lasts 344 s (the lines gate the quest).
- REQUEST 1 (revised) -> slice-play: that data change (`line_type_cps` ~15, `line_max_s` ~22 in data/tables/quest_rules.json; or a per-line max(text time, voice_s + 0.4)
  from data/tables/voice_lengths.json) is yours to decide: it moves the replay/scenario goldens and the quest's pace. Without it 6 lines are lost.
- REQUEST 3 (revised, exact) -> slice-play: in boot/quest1_game.gd after `add_child(view)` (non-headless branch): `StageAudio.attach(self, session.stage, session.system, Events, Quest1Session.MASTER_SEED)`.
- REQUEST 4 -> vehicles: emit something for a car-vs-car / car-vs-wall crash with a closing speed (or call `FxTriggers.fire(&"crash", pos_px, 0.0, tick)`), and for a
  hard drift (tyre_screech) and a horn key; audio has the sounds (crash, tyre_screech, horn, hit_metal), nothing triggers them in your branch.
- MILESTONE (11:50) quest stage: StageAudio now turns on the night bed (-3 dB) and passes Rivet's actor id to the hooks, so each of his kills punches (`rivet_kill`)
  in the quest too (the riot's FX sink already did). Quest fight clip: 37 kill punches / 39 body hits in 30 s: dense; the punch cue has cooldown 6 ticks + 2 voices.
- MILESTONE riot roar: `crowd_roar` (generated, loop, 2 takes, both kept, take 1 shipped) = RiotBed: counts the gun / death / body-hit cues the service started per
  frame, smooths (rise 1.5 s, fall 4 s), sets the bed between -18 and 0 dB trim (audio_mix.json riot_bed_*). First gain (-16 dB) was inaudible: the riot clip stayed at
  -20.4 LUFS; at -7 dB the bed sits ~4 dB under the mix (bed ~ -24 dBFS vs the -20 LUFS clip) and moves the clip to -20.2 LUFS. Measured the bed level
  in the headless smoke (report beds_db). A bed that moves with the fight is not heard yet by a human.
- Clips this iteration (all contended GPU, D3D12, movie maker, 960 px): riot_mix4 -20.2 LUFS / -1.5 dBFS; q1_opening_mix3 -17.5 / -3.5; q1_fight_mix3 -19.2 / -1.0.
  Frames looked at: 5 (riot, fight, opening, + earlier), camera breaks 0. frames.json + ladder.png in masters updated.
- Credits: ElevenLabs used by this iteration: ~74,117 after the first 17 takes; plus boss/tazer (6 takes) and crowd_roar (2 takes of 8 s): lane total ~3.5k of 25k.
- MILESTONE (12:0x) distance muffling: positional sfx heard from beyond far_m (22 m) play on a new `sfx_far` bus (child of sfx, low-pass 2.5 kHz); all in
  audio_mix.json (far_m, far_lowpass_hz). Unit test proves the routing (a 40 m shot runs on sfx_far, a 5 m shot on sfx). Pan probe (evidence/mix/pan_check.txt) now
  prints the share of energy above 4 kHz: 25 m shot -46 dB vs -20..-31 dB for the close ones, but the probe draws a random take per shot, so that is consistent with
  the filter, not a clean A/B. The riot clip (riot_mix5, -20.2 LUFS, peak -1.4) did not change in loudness or in its >4 kHz level (-28.1 LU both): few cues land
  beyond 22 m there. Not heard by a human.
- MILESTONE per-bus player volume: `AudioBuses.set_user_gain(bus, 0..1)` (unit-tested: -6 dB at 0.5, ducking stacks on top, 1.0 restores). The pause card only has a master
  slider (PlayerSettings): REQUEST 5 -> slice-play, optional: music / sfx / voice sliders call `StageAudio.service.buses.set_user_gain(...)`.

NEXT (iteration 2 end):
1. Open requests to other lanes (nothing of mine blocks on them, but audio is incomplete without): REQUEST 1 slice-play (voice timing: 6 of 23 lines dropped, `line_type_cps` 15 / `line_max_s` 22 or per-line voice length),
   REQUEST 3 slice-play (one line in boot/quest1_game.gd: `StageAudio.attach(self, session.stage, session.system, Events, Quest1Session.MASTER_SEED)` after `add_child(view)`),
   REQUEST 2/4 vehicles (crash / tyre screech / horn triggers; `FxTriggers.fire(&"crash", pos_px, 0.0, tick)` or a cue API call; a `radio_next` input action for `CarRadio.next()`), REQUEST 5 optional sliders.
2. A human must LISTEN: all SFX, the 23 voices, 3 radio loops, the new roar/kill punch/tazer charge/boss stinger. Still numbers + spectrograms only.
3. After merge with d-vehicles: re-record the demo tour with real vehicle events (pedestrian_struck thud, hijack slam are unit-tested only).
4. Boss/tazer: tazer_charge is stretched by pitch 0.8 to the 1.5 s wind-up; the boss_stinger has one take; no boss music loop (a /v1/music call ~300 credits would do it).
5. Bench: never run by this lane (no GPU work); the pool is capped at 24 players / 4 starts per frame, the RiotBed does a 6-key lookup per frame.
- GATES at the NEXT commit (clean evidence run, `node tools/evidence/run.mjs --no-bench`, exit 0, tree untouched during the run): lint 13/13, unit 350 passed, scenarios 8/8,
  parity exact + planted mutation caught, selftest + look goldens unchanged. Bench NOT run (lane rule; contended GPU, audio has no GPU work). Earlier run's unit "FAIL" was only my journal commit mid-run.

## 2026-11-03 iteration 4 (BUILD, started 12:07; iteration 3 left no journal entry, the log above is its state)
- MILESTONE (12:20) new sounds: `car_wreck` (ElevenLabs sound-generation direct, 3 takes, QC 3 kept / 0 rejected; the vehicles lane fires `car_wreck` with every explosion),
  `boss_loop` (ElevenLabs /v1/music, 24 s, loop; starts with `boss_engaged` after the stinger, ends with `contract_completed` like the arena camera; file lives in assets/audio/sfx
  because SoundBank only reads that dir, bus `music` so the voice duck applies). Engine pitch follows the driven car (AudioHooks.drive_to: position change per rendered frame, smoothed;
  `engine_pitch_idle` 0.75 .. `engine_pitch_top` 1.6 at `engine_top_mps` 26 in audio_mix.json + schema). Unit tests: test_audio_driving.gd (4). Demo tour 4 clip (evidence/mix/riot_demo_mix4.mp4, -18.1 LUFS).
- POF-GAP 1 re-checked at 12:07 (4th time): /api/audio-gen still 400 "text_too_long 450" (PoF wraps the prompt to 592 chars). Direct route again.
- Credits: car_wreck 3 takes + boss_loop (24 s music): about 450-500 credits (not read back from the API; the key is not printed). Lane total ~4.0k of 25k. No voice characters spent today after 11:45 (owner rule).
- FIXED (I missed it at 11:45): the 23 voice lines are marked temp: `tools/audio/casting.json` `"status": "temp"`, `data/tables/voice_lengths.json` `"status": "temp"` (+ schema).
- NEW QC, an ear proxy: tools/audio/stt_check.py reads all 23 voices back with a local Whisper (base.en, HF cache, offline) and compares the words with the quest text: mean WER 2.9% (the rest is digits vs words:
  "forty" -> "40"). It found ONE real fault: rivet-who-is-this had the written "...One" read as a stray syllable ("a fraced one"). Cut by tools/audio/fix_who_is_this.sh (raw take 4.45-5.36 s, 0.25 s beat back, same loudnorm),
  12.9 -> 12.3 s, STT re-check "Everything's dead tonight. One. I pressed one." (WER 0). evidence/voice_stt.json. This is a read-back, not a listening test (pacing, acting, timbre still unheard).
- MILESTONE (12:31) REQUEST 3 proven on the real slice: scratch merge d-slice + d-audio + `evidence/requests/quest1_game_audio.patch` (9 lines in boot/quest1_game.gd) -> 150 s of the slice's own main scene
  (title -> Start -> scripted input pad) with sound: -19.5 LUFS, true peak -2.9 dBFS, 20 of 23 voice lines requested by the line player and **7 of them dropped from the voice queue (13 spoke; I first wrote "20 started": `QuestVoice.played` counts requests, `VoiceChannel.drops` the losses)**, 123 footsteps, 44 kill punches, 3 tazer charges, boss stinger, nothing missing.
  Clip evidence/mix/slice_q1_audio.mp4 (frames at 20 s and 140 s looked at, straight down, 0 rejected). WITHOUT THE PATCH THE SLICE IS SILENT: nothing in d-slice calls StageAudio.
- MILESTONE (12:35) merge with the vehicles lane proven: scratch merge d-vehicles + d-audio, one conflict (JOURNAL.md), 386 unit tests green (my run-over test re-declared `pedestrian_struck`: fixed). On the vehicles lane's real cars
  (their carnage route): 5 crashes, 1 car_wreck, 2 hit_metal, 3 horns heard; their plain route: 1 tyre_screech, 1 thud + 1 death for the run-over; engine pitch 0.99 .. 1.60 .. 0.75 with the car speed.
  evidence/mix/vehicles_merge_carnage.mp4 (-16.5 LUFS, peak -3.1) and *_cues.json. Hence REQUEST 2 and 4 are DONE by the vehicles lane (they fire FxTriggers and Events as asked).
- REQUESTS still open: REQUEST 1 slice-play (voice vs subtitle timing: in the real slice 7 of the first 20 lines were dropped, 13 spoke), REQUEST 3 slice-play (apply evidence/requests/quest1_game_audio.patch: it is the whole wiring), REQUEST 6 -> slice-play/Director:
  `CarRadio.next()` needs an input action (the radio only starts on vehicle_entered; no way to change station yet).
- FRICTION: my shell's cwd drifted between worktrees several times (a `cd ../d-vehicles` in one command leaves the primary dir changed): always `git -C`/absolute paths. Python on Windows resolves bash `/tmp/..` and `/c/..` differently from bash
  (a write to `/tmp/stt/x` went to %LOCALAPPDATA%\Temp, `/c/...` args need `cygpath -m`): I lost two runs to it. No debris was left outside the repo and masters.
- MEASURED (12:47) which lines the voice queue loses, on this branch's own quest scene with the bot (dev/audio/audio_beat.tscn, movie maker so audio time = frame time, 185 s, 22 of the 23 lines requested):
  **6 dropped: rivet-third-person, rivet-who-is-this, juno-load-bearing, brass-gloria, kilohm-accents, rivet-buildings-talk** (exactly the 6 my offline simulation predicted), 16 spoke; VoiceChannel now keeps `dropped_ids`.
  In the slice's scripted-pad clip: 7 of 20 dropped, and a Whisper read-back of that clip's mix finds 8 lines clear (tools/audio/mix_intelligibility.py, evidence/mix/slice_q1_intelligibility.json).
  TRIED AND REJECTED (offline simulation on the measured line timeline + voice_lengths.json): a priority drop policy (keep lines tagged `progression`, drop the others first) = 11 of 12 progression lines spoken, same as drop-oldest, and
  the lines start later (mean 9.8 s late vs 8.7); a longer backlog (3-4) trades drops for 22-23 s lateness. Only the line timing (REQUEST 1) fixes this; no audio-side policy does.
- NEW: the `radio_next` input action (CarRadio listens while the radio is on; needs the row in data/tables/input_actions.json: REQUEST 6, text in evidence/requests/input_actions_radio_next.txt, R + joypad button 5).
- GATES at 0d95243 (`node tools/evidence/run.mjs --no-bench`, exit 0, tree untouched): lint 13/13, unit 355 passed, scenarios 8/8, parity exact + planted mutation caught at step 629, selftest + look goldens unchanged (audio adds no pixels).
  Bench NOT run (lane rule: contended GPU; the audio service has no GPU work). Cost of the pool is unmeasured under the bench.

NEXT (iteration 4 end):
1. Slice-play must APPLY `evidence/requests/quest1_game_audio.patch` (the slice is silent without it), decide REQUEST 1 (line timing: 6-7 of 23 lines are lost; `line_type_cps` ~15 / `line_max_s` ~22 or max(text time, voice_s + 0.4 s) from
   data/tables/voice_lengths.json), add the `radio_next` row (REQUEST 6). REQUEST 5 (music / sfx / voice sliders in the pause card: `StageAudio.service.buses.set_user_gain`) is optional.
2. A human must LISTEN: all SFX (new: car_wreck, boss_loop), the 23 TEMP voices (casting in tools/audio/casting.json; the PoF Voice room replaces them), the radio loops. Still numbers, spectrograms and a Whisper read-back only.
3. After the merge of d-vehicles + d-audio + d-slice: re-run the three scratch scenes in evidence/requests/*.gd.txt (copy to project/dev/audio/ as .gd + a .tscn) on the merged main; the slice clip must keep its -19.5 LUFS.
4. Boss: the loop ends with `contract_completed`; when the combat lane emits a boss-defeated event (or the arena does), stop it there. Still no real boss/tazer SFX beyond the generated charge and stinger.
5. Not done: positional siren from cruisers (the siren is one bed by wanted level), tyre screech as a loop while sliding (it is a one-shot at the slide's start), per-surface footsteps, a settings slider UI.
6. POF-GAP 1-3 stand (audio-gen: prompt wrapper pushes every request past ElevenLabs' 450-char limit; no tts kind; no music kind). The pof-voice lane's Voice room closes POF-GAP 2.
- 13:05 MILESTONE tuning from a per-cue audit: Gloria's nail gun (the quest's own weapon) sat 12 dB under the guards' rifle by exposure level (mean SEL -32.0 vs -19.9 dB); cue gain -5 -> -1, quest fight clip re-recorded (q1_fight_mix4.mp4, -18.8 LUFS, peak -1.0).
  slice_q1_audio.mp4 was recorded before that tune (Gloria at -5). The boss loop now also ends when Mertz goes down (StageAudio polls `arena.boss.alive()`; checked on a 200 s bot run: loop level -60 dB, boss dead).
  All shot / impact / punch takes are below -30 dB of their peak by 0.44 s (tail check). Masters: frames.json (8 frames) + ladder.png refreshed.
- GATES at 53fb7d7 (final, `node tools/evidence/run.mjs --no-bench`, exit 0, tree untouched during the run): lint 13/13, unit 355 passed, scenarios 8/8, parity exact + planted mutation caught at step 629, selftest + look goldens unchanged.
  Bench NOT run (lane rule). Credits: ElevenLabs ~4.0k of the lane's 25k used (sfx + music only today after 11:45; voice 0 chars).
- 13:06 COST measured (evidence/audio_cost.json; HEADLESS, CONTENDED CPU; the GPU bench lock was held by another lane so no bench was taken): in the 300-person riot the service's own frame work is 30 us mean / 335 us max,
  a cue() call through the FX sink 25 us mean / 2.1 ms max (1264 calls in 25 s), about 0.05 ms per frame against 16.6 ms. This replaces "pool cost unmeasured" above for the script side; the real positional mixing on a device is still unmeasured.
  Final HEAD: 2af3b1f (gates last run at 53fb7d7; only the service's timing probe and a dev scene changed after, lint + 355 unit tests green at HEAD).
- 13:15 THREE-WAY MERGE CHECK (scratch worktree, deleted): d-slice 2de6c16 + d-vehicles + d-audio 2af3b1f + `evidence/requests/quest1_game_audio.patch` applied: the only conflict is JOURNAL.md (every lane's own file); lint 13/13 over 413 GDScript files,
  **425 unit tests pass, 13 scenarios ran / 0 failed** (quest 1 input run: replay identical, 187 s; vehicle drive and yield pass; city replay 20 checkpoints identical). So the whole audio wiring is: merge + that 9-line patch + the input row (REQUEST 6).

## 2026-11-03 iteration 49 (BUILD, started 15:40)
- MILESTONE (15:55) blood sounds for the D5 blood (owner verdict 5: red blood, spurts, splats; the d-combat lane's CombatBlood draws them off `FxTriggers.cued`): deaths used a pitched flesh thud only.
  Generated direct (ElevenLabs sound-generation, 5 takes, ~0.9 s, SFX credits only, no voice characters; POF-GAP 1 unchanged): `blood_splat` x3, `blood_spurt` x2. QC: 0 rejected by the pipeline,
  by hand rejected 1 (blood_spurt_02: a quiet -35 dB RMS click after a gap, nothing a player would hear as a spurt). Kept: blood_splat_01..03, blood_spurt_01 (env decays 12-30 dB in the first 100 ms: no long tails).
  New optional cue field `layer` (a second cue started along with the first; unit-tested, README): `death` -> `blood_splat` (-8 dB), `rivet_kill` -> `blood_spurt` (-7 dB). No change to the event hooks, the riot bed (it counts only the
  parent cues) or the FX sink: the layer starts inside `AudioService.cue`. Provenance +4 lines. Unit 356 (355 pass; the one fail is the known test_noir_shadows engine-error flake, not audio),
  lint 13/13, scenarios 8/8. Not heard by a human.
- FRICTION: tools/audio/build_tables.py is STALE (it lacks car_wreck / boss_loop and has Gloria at -5 instead of the tuned -1): running it clobbers hand edits. The tables are edited as JSON now; do not regenerate.
- 15:52 clip evidence/mix/riot_mix6.mp4 (25 s, 960 px, replaces riot_mix5; D3D12 movie maker, CONTENDED GPU, not timed): **-19.9 LUFS, true peak -2.2 dBFS, LRA 1.8** (riot_mix5 was -20.2 / -1.4): the blood layer moves the mix +0.3 LU.
  Headless report (evidence/mix/riot_cues_blood.json, 25 s): 88 deaths started, 44 blood splats started (44 more dropped by the 3-voice cap: the riot saturates it), 110 shots, 38 steps. Frame at 12 s looked at: straight down, 0 camera breaks rejected.
- 16:20 FOUR-WAY MERGE CHECK (scratch worktree, deleted): d-audio a744d47 + d-slice 69ee1cd + d-vehicles + d-combat + the quest1_game_audio.patch (applies clean): **457 unit tests pass, 13 scenarios ran / 0 failed**.
  Conflicts: JOURNAL.md (every lane's own file, took ours) and, NOT audio's: **d-slice vs d-combat in project/boot/collect_call/view/collect_call_view.gd** (both add vars after `print_stage` and both extend `_ready`).
  Keeping both sides compiles and passes the tests, but lint gd-size then FAILS: `func _ready is 43 lines > 40` (slice's city branch + combat's blood block). For the Director: move combat's blood block
  (the `if _stage != null and _stage.events() != null:` part) into its own function, e.g. `_ready_blood()`. Nothing in audio's files conflicts with any other lane.
- Masters: frames.json now 10 entries (riot with the blood layers, blood spectrograms).
- 16:12 GATES at af5272a (`node tools/evidence/run.mjs --no-bench`, exit 0, tree untouched): lint 13/13, unit 356 passed, scenarios 8/8, parity exact + planted mutation caught at step 629, selftest + look goldens 11/11 unchanged. Bench NOT run (lane rule).
  ElevenLabs credits today after 11:45: SFX only. This iteration: 5 takes (blood), ~150-250 credits (not read back). Lane total ~4.2k of 25k; voice characters spent after 11:45: 0.

NEXT (iteration 49 end):
1. Director at merge: apply `evidence/requests/quest1_game_audio.patch` (the slice is silent without it; applies clean on d-slice 69ee1cd), the `radio_next` input row (REQUEST 6), decide REQUEST 1 (line timing: 6-7 of 23 lines lost). Resolve d-slice vs d-combat in collect_call_view.gd by extracting combat's blood block out of `_ready` (gd-size).
2. A human must LISTEN: every SFX (new: blood_splat x3, blood_spurt, car_wreck, boss_loop), the 23 TEMP voices (PoF Voice room replaces them), the 3 radio loops.
3. tools/audio/build_tables.py is stale: edit the JSON tables directly, or back-port car_wreck / boss_loop / Gloria -1 / the `layer` field first.
4. Not done: positional cruiser sirens, tyre screech as a loop (the vehicles lane fires a one-shot at slide start and does not publish the slide state), per-surface footsteps, a settings slider UI for music / sfx / voice.
5. POF-GAP 1-3 stand (audio-gen prompt wrapper > 450 chars; no tts; no music kind). POF-GAP 2 is closed by pof-voice's Voice room when it lands.

## 2026-11-03 iteration 50 (BUILD, started 16:03)
- MILESTONE (16:12) burning wrecks were silent: the vehicles lane's VehicleFire (a wreck burns 24 s, fading over the last 6) has no event, only the `car_wreck` FX at the explosion.
  New cue `fire_crackle` (2 takes, ElevenLabs sound-generation direct, 20 s each, SFX credits only, ~100-200; POF-GAP 1 unchanged; no voice characters), started as the `layer` of `car_wreck`:
  positional at the wreck, 19.6 s, RMS -24.9 dBFS (the beds sit at -18..-20), peak -1.0..-2.4 after a tanh soft limit at -3, 0.25 s fade in, 5 s fade out. QC by hand: 2 of 2 kept, 0 rejected;
  per-second RMS steady within 4 dB for 15 s (no explosion, no voices), peaky crackle (spectrogram evidence/spectro/fire_crackle_0{1,2}.png: broadband pops over a steady bed, fade at the end).
  Unit test `test_a_car_wreck_also_starts_its_fire_bed` (357 tests pass; the run printed `import exit 3221225477` with 0 failed: an import crash on a contended machine, not a test failure), lint 13/13. Provenance +2 lines. Not heard by a human; not yet recorded on the real vehicles lane (it is in its own branch: the clip needs the merge).
- MILESTONE (16:25) fire bed proven on the vehicles lane's real carnage route (scratch merge d-vehicles f2259ec + d-audio, deleted afterwards; scene = evidence/requests/audio_vehicle.gd.txt): 30 s, headless cue report
  evidence/mix/vehicles_fire_cues.json: `car_wreck` 2, `fire_crackle` 2, crash 5, hit_metal 2, horn 3, missing [], dropped only `crash:cooldown` 2. FOUND + FIXED: with `car_wreck` cooldown 30 ticks the second wreck
  (0.3 s after the first) got no boom and no fire (1 of 2 wrecks heard); cooldown -> 8 ticks on `car_wreck` and `fire_crackle` (max_voices 2 / 3 still bound it): 2 of 2.
  Clip evidence/mix/vehicles_fire.mp4 (30 s, D3D12 movie maker, 640 px, CONTENDED GPU, not timed): **-17.5 LUFS, true peak -1.1 dBFS (AAC re-encoded; two booms + crashes stack, the hottest clip of the lane, watch it)**.
  Frame at 14 s looked at: straight down, two burning wrecks with flames, 0 camera breaks rejected. 357 unit tests pass, lint 13/13.
- MILESTONE (16:40) bodies lane's new Event `actor_knocked_down(attacker_id, defender_id, defender_class, at)` (a tackle, d-bodies; wired true) had no sound. New cue `body_fall` (3 takes, ElevenLabs sound-generation direct, 0.8 s each,
  SFX credits only ~100-200; no voice characters): dull body thud + cloth scuff, no voice. QC by the pipeline's rules (trim, peak at the start <= 80 ms, tails -26 .. -33 dB by 0.3 s, flat run <= 5): 3 of 3 kept, 0 rejected;
  0.32-0.39 s, peak -3.0, RMS -18.4 / -24.8 / -24.0 dBFS (take 1 is the most sustained). Hook: AudioHooks connects `actor_knocked_down` only when the Events bus declares it (same pattern as pedestrian_struck), cue positional at `at` (metres).
  Unit test with a user-signal stand-in; 358 unit tests pass, lint 13/13. Provenance +3. Not tried on the real bodies lane (needs the merge), not heard by a human.
- RETIRED tools/audio/build_tables.py (exits with a message; it would clobber the hand-edited tables).
- 16:48 MERGE CHECK d-audio 32f33af + d-bodies (scratch worktree, deleted; the one conflict was JOURNAL.md / docs, took ours): **367 unit tests pass** with the real `actor_knocked_down` signal (the test used the real declaration, not the stand-in).
- GATES at a14dd64 (`node tools/evidence/run.mjs --no-bench`, exit 0, tree untouched during the run): lint 13/13, unit 358 passed, scenarios 8/8, parity exact + planted mutation caught at step 629, selftest + look goldens 11/11 unchanged. Bench NOT run (lane rule).
  ElevenLabs after 11:45: SFX only; this iteration 2 x 20 s fire takes + 3 body_fall takes, ~300-500 credits (not read back). Lane total ~4.6k of 25k; voice characters spent after 11:45: 0.
  Masters: frames.json now 12 entries (+ fire wrecks frame, fire spectrogram).

NEXT (iteration 50 end):
1. Director at merge: apply `evidence/requests/quest1_game_audio.patch` (still applies clean on d-slice 36eab8f), the `radio_next` input row (REQUEST 6), decide REQUEST 1 (line timing: 6-7 of 23 lines lost),
   and split combat's blood block out of `_ready` in collect_call_view.gd (gd-size).
2. A human must LISTEN: every SFX (new: fire_crackle x2, body_fall x3, blood_*, car_wreck, boss_loop), the 23 TEMP voices (PoF Voice room replaces them), the 3 radio loops. Numbers + spectrograms only so far.
3. Hot clip: vehicles_fire.mp4 true peak -1.1 dBFS when two booms + crashes stack (car_wreck cooldown is now 8 ticks); if it clips on a device, lower `car_wreck` gain_db -1 -> -3.
4. Not done: positional cruiser sirens, tyre screech as a loop, per-surface footsteps, settings slider UI.
5. POF-GAP 1-3 stand (audio-gen wrapper > 450 chars; no tts; no music kind).

## 2026-11-03 iteration 52 (BUILD, started 16:23)
- 16:40 FIVE-WAY MERGE CHECK at the latest tips (scratch worktree, deleted): d-slice c0b0f76 + d-vehicles ac7827b + d-combat 73396ae + d-audio e417bd2 + `quest1_game_audio.patch` (applies clean).
  Conflicts: JOURNAL.md (took ours) and, NOT audio's, collect_call_view.gd (d-slice vs d-combat: both add vars + extend `_ready`). Resolved by keeping both and moving combat's blood block into `_ready_blood()`:
  the text is in `evidence/requests/collect_call_view_ready_blood.txt` (the `_ready` body then ends with `_ready_blood()`); lint 13/13 over 429 files. **462 unit tests pass, 13 scenarios ran / 0 failed.**
  FRICTION for whoever merges: the scenarios need the native DLL BUILT FROM d-vehicles (CitySim::set_obstacles); int-day's older DLL fails 3 vehicle scenarios (unrelated to audio). With the d-vehicles DLL: 0 failed.
  d-bodies fa31133 does NOT merge cleanly on top of that (look goldens, generated sim_constants, SConstruct, city_parity.gd, collect_call_stage.gd: all the Director's, nothing in audio); abandoned, the earlier d-bodies + d-audio check (367 tests) still stands.
- No new audio code this iteration (freeze 17:00; what is left needs a human listen, not more numbers). No ElevenLabs calls; lane total still ~4.6k of 25k; voice characters after 11:45: 0.

NEXT (iteration 52 end): unchanged from iteration 50, plus: use the d-vehicles native DLL for the scenarios, and `_ready_blood()` in collect_call_view.gd at the slice/combat merge.

## 2026-11-03 iteration 53 (BUILD, started 16:35)
- 16:55 SIX-TIP MERGE CHECK at the latest tips (scratch worktree, deleted): d-slice 3db4792 + d-vehicles a927e19 + d-combat a8d3905 + d-audio f2c955d + `quest1_game_audio.patch` (applies clean).
  Conflicts: JOURNAL.md (took ours) and collect_call_view.gd (d-slice vs d-combat, as before; resolved with `evidence/requests/collect_call_view_ready_blood.txt`): lint 13/13 over 429 files,
  **463 unit tests pass, 0 failed; 13 scenarios ran / 0 failed** (with the d-vehicles native DLL). No new Event from d-vehicles / d-combat / d-bodies / d-slice that audio lacks a hook for (pedestrian_struck, actor_knocked_down both wired).
  FRICTION: Python under Git Bash for Windows does not resolve `/c/...` paths; use `C:/...` in scripts.
- No new audio code or ElevenLabs calls (freeze 17:00); lane total still ~4.6k of 25k; voice characters after 11:45: 0.

NEXT (iteration 53 end): unchanged from iteration 52 (Director: patch + radio_next row + `_ready_blood()` at the slice/combat merge; a human must LISTEN to every SFX, the 23 TEMP voices and the radio loops).

## 2026-11-03 iteration 54 (BUILD, started 16:40, freeze 17:00)
- 16:44 Tip check: d-slice ef3f425, d-vehicles ecd9fb0, d-combat 195debc, d-bodies bfe31d9. Events schema diffs vs main add only `pedestrian_struck` (d-vehicles) and `actor_knocked_down` (d-bodies); audio hooks both. No new Event audio lacks a hook for.
- No new audio code, no ElevenLabs calls (lane total still ~4.6k of 25k; voice characters after 11:45: 0). Tree clean; last gates green at a14dd64 / six-tip merge check at eb2dc3f (463 unit, 13 scenarios).

NEXT (iteration 54 end): unchanged from iteration 52 (Director: apply `evidence/requests/quest1_game_audio.patch`, the `radio_next` input row, `_ready_blood()` at the slice/combat merge; a human must LISTEN to every SFX, the 23 TEMP voices and the 3 radio loops; hot clip vehicles_fire.mp4 -> lower `car_wreck` gain_db if it clips).
