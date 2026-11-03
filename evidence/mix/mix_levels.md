# Mix pass (lane audio, 2026-11-03)

Levels live in `project/data/tables/audio_mix.json` (buses, duck, limiter) and `audio_cues.json` (per-cue gain). All four clips were re-recorded on the final assets and the final (widened) audio space. Clips are recorded
with Godot's movie maker (`--write-movie`, fixed 60 fps, D3D12, audio from the real AudioServer), scenes `dev/audio/audio_riot.tscn`
(the real World + CitySystem + CityView, WorldAudio) and `dev/audio/audio_beat.tscn` (quest 1 played by its bot on CollectCallView,
StageAudio). Loudness by ffmpeg ebur128. I could not LISTEN (no human in the loop here): these are measured, not heard.

| Clip | Mix 1 (sfx 0 dB, voice +2 dB, no limiter) | Mix 2 (sfx +3 dB, voice -2 dB, Master hard limiter -1 dB) |
|---|---|---|
| riot, 30 s | -24.0 LUFS, peak -5.7 dBFS, LRA 1.7 | -20.4 LUFS, peak -2.3 dBFS, LRA 1.7 (pistol cue +3 dB, new pistol takes; L-R std 2.4 dB, was 0.9) |
| quest 1 opening (5 voiced lines), 45 s | -13.4 LUFS, peak **+0.1 dBFS (clipping)**, LRA 2.2 | -17.4 LUFS, peak -3.0 dBFS, LRA 2.2 |
| quest 1 fight (Dock 9), 30 s | -14.6 LUFS, peak **+0.1 dBFS (clipping)**, LRA 13.7 | -19.8 LUFS, peak -2.5 dBFS, LRA 8.4 |

Mix 1 had the voice 11 LU above the riot and clipped under dialogue; mix 2 brings the three clips within 4 LU of each other and
holds the peak under the limiter ceiling. The riot stays ~3 LU quieter than the voiced quest clips (a flat city bed + capped shots, no
dialogue): a candidate for the next iteration. `*_cues.json` = the cues played / dropped (culled by cooldown, voice cap, distance) in each clip.

## Demo tour (evidence/mix/riot_demo_mix2.mp4, `audio_riot.tscn --demo`)

The riot clip again, with a scripted tour of the sounds nothing in the game fires yet (the vehicles lane will): second 5 vehicle_entered
(engine bed + car radio, station 1), 9 horn, 11 tyre screech, 13 crash, 15 radio next (station 2), 21 wanted level 3 (siren bed),
25 vehicle_exited (engine + radio off), 26 contract_completed (radio stinger). -17.3 LUFS, sample peak -1.0 dBFS (the limiter ceiling), LRA 4.6. The windows' RMS levels of the first demo take
(bed -16.2 dBFS; engine + radio on -14.8; horn -10.7; screech -13.1; crash -11.2; radio station 2 -12.4; siren on -13.2) showed each
sound clearly above the bed. Measured, not heard.

## Pan and distance check (`dev/audio/audio_pan.tscn`, `tools/audio/pan_check.py`, evidence/mix/pan_check.txt)

One rifle shot per second at known positions around a listener at the origin, recorded stereo. With m_to_px 32 / panning_strength 0.7
the pan was nearly invisible (14 m left: L-R +2.1 dB, std of L-R over the whole riot clip 0.9 dB), so the audio space was widened:
m_to_px 64, panning_strength 1.0. Now: 14 m left +6.3 dB L-R, 14 m right -6.3 dB, 25 m / 45 m right -9.5 dB, straight ahead / behind 0.0 dB;
level (total) -19.0 dB at 5 m, -21.1 dB at 25 m, -29.9 dB at 45 m. Godot's 2D pan depends on the viewport width, so a wider window pans less.

## Iteration 2 re-records (`*_mix3.mp4`, replace the mix2 clips; 960 px, 30 fps, contended GPU)

Same mix tables, new assets: one footstep per stride (8 single-step takes), the kill punch (`rivet_kill`) in the quest stage, the night-city bed under the
quest stage (-3 dB trim). riot 25 s: -20.4 LUFS, peak -1.4 dBFS, LRA 1.8. quest opening 45 s: -17.5 LUFS, peak -3.5 dBFS, LRA 2.2 (7 of the bot's lines started,
2 voice drops in 45 s). quest fight 30 s: -19.2 LUFS, peak -1.0 dBFS, LRA 7.6 (39 body hits, 37 kill punches, 28 steps, 54 shots). Measured, not heard.
Voice vs the quest timeline over the whole quest: see JOURNAL (6 of 23 lines dropped, `dev/audio/line_timeline.tscn`).

## Iteration 4: demo tour 4 (`riot_demo_mix4.mp4`, replaces riot_demo_mix2; `audio_riot.tscn --demo`, 800 px, contended GPU)

New: the engine pitch follows the driven car (the demo "car" circles at 30 m radius, speed ramping 0 -> 24 m/s over seconds 5-13, held, braking
16-21; logged engine pitch scale per second: 0.84, 0.93, 1.03, 1.13, 1.23, 1.32, 1.42, 1.52, 1.53 ... 1.40, 1.24, 1.09, 0.93, 0.77 = engine_pitch_idle 0.75 ..
engine_pitch_top 1.6 in audio_mix.json), `car_wreck` explosion (second 16), the boss stinger + boss loop (second 22, off with the contract at 28: the loop
fades in over ~2.3 s and out the same). Tour: 5 enter (engine + radio 1), 8 horn, 10 screech, 12 crash, 14 radio next, 16 wreck, 18 wanted 3 (siren), 21 exit,
22 boss, 28 contract_completed (radio stinger, boss loop off). -18.1 LUFS, true peak -0.9 dBFS, LRA 3.9 LU. Per-second RMS (dBFS): bed -15..-13.5, wreck second -10.6,
boss second range -12.9..-11.8 (the boss loop sits ~1-2 dB above the riot bed, under the shots). Frame at 12 s looked at: straight down, 0 rejected.
Measured, not heard.
