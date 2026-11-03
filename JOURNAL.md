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
