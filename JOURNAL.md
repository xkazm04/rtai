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
