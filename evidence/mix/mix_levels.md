# Mix pass (lane audio, 2026-11-03)

Levels live in `project/data/tables/audio_mix.json` (buses, duck, limiter) and `audio_cues.json` (per-cue gain). Clips are recorded
with Godot's movie maker (`--write-movie`, fixed 60 fps, D3D12, audio from the real AudioServer), scenes `dev/audio/audio_riot.tscn`
(the real World + CitySystem + CityView, WorldAudio) and `dev/audio/audio_beat.tscn` (quest 1 played by its bot on CollectCallView,
StageAudio). Loudness by ffmpeg ebur128. I could not LISTEN (no human in the loop here): these are measured, not heard.

| Clip | Mix 1 (sfx 0 dB, voice +2 dB, no limiter) | Mix 2 (sfx +3 dB, voice -2 dB, Master hard limiter -1 dB) |
|---|---|---|
| riot, 30 s | -24.0 LUFS, peak -5.7 dBFS, LRA 1.7 | -21.0 LUFS, peak -2.7 dBFS, LRA 1.7 |
| quest 1 opening (5 voiced lines), 45 s | -13.4 LUFS, peak **+0.1 dBFS (clipping)**, LRA 2.2 | -17.4 LUFS, peak -2.9 dBFS, LRA 2.2 |
| quest 1 fight (Dock 9), 30 s | -14.6 LUFS, peak **+0.1 dBFS (clipping)**, LRA 13.7 | -19.8 LUFS, peak -2.7 dBFS, LRA 8.2 |

Mix 1 had the voice 11 LU above the riot and clipped under dialogue; mix 2 brings the three clips within 4 LU of each other and
holds the true peak under the limiter ceiling. The riot is still 3-4 LU quieter than the quest (a flat city bed + capped shots):
a candidate for the next iteration. `*_cues.json` = the cues played / dropped (culled by cooldown, voice cap, distance) in each clip.

## Demo tour (evidence/mix/riot_demo_mix2.mp4, `audio_riot.tscn --demo`)

The riot clip again, with a scripted tour of the sounds nothing in the game fires yet (the vehicles lane will): second 5 vehicle_entered
(engine bed + car radio, station 1), 9 horn, 11 tyre screech, 13 crash, 15 radio next (station 2), 21 wanted level 3 (siren bed),
25 vehicle_exited (engine + radio off), 26 contract_completed (radio stinger). -17.9 LUFS, true peak -1.8 dBFS, LRA 4.8. RMS by window
(dBFS, 24 kHz mono mixdown of the recorded audio): bed only -16.2; engine + radio on -14.8; horn -10.7; screech -13.1; crash -11.2;
radio station 2 -12.4; siren on -13.2. Measured, not heard.
