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

## Iteration 4: the real slice with the REQUEST 3 patch (`slice_q1_audio.mp4`, 150 s, contended GPU)

A scratch merge (d-slice fe40b14 + d-audio) with `evidence/requests/quest1_game_audio.patch` applied (3 hunks, 9 lines in boot/quest1_game.gd: attach StageAudio after the
view is built, free it on restart). The scene is the slice's own `boot/quest1.tscn` (title card -> Start -> quest 1 driven by CollectCallInputDriver's scripted pad, one tick per
rendered frame; the scratch driver is `evidence/requests/slice_clip.gd.txt`). 150 s of play = tick 9000, beats b1 dumpster .. b5 quartermaster (the Dock 9 boss): **-19.5 LUFS integrated,
true peak -2.9 dBFS, LRA 3.3 LU**, 5 s windows -21.8 .. -15.0 dBFS; 20 of the 23 voice lines were requested by the line player in those 150 s (the other 3 come later), **7 of those 20 were dropped from the voice queue (13 actually spoke)**,
123 footsteps, 44 kill punches, 74 shots, 3 Robo-tazer charges, 1 boss stinger, no missing sound file. Frames at 20 s and 140 s looked at: straight down, 0 rejected.
Measured, not heard. Without the patch the slice is silent (nothing in d-slice calls StageAudio).

## Iteration 4: audio on the vehicles lane's real cars (`vehicles_merge_carnage.mp4`, 20 s, scratch merge d-vehicles 01bd7a0.. + d-audio, contended GPU)

A scratch merge of d-vehicles and d-audio (one conflict, JOURNAL.md; boot/world.gd auto-merged; **386 unit tests pass** after fixing my run-over hook test, which re-declared
`pedestrian_struck` once the vehicles lane declares it). The scene replays the vehicles lane's own carnage route (`VehicleFrameSetup`: hijack a taxi, ram two cars, reverse, wreck;
scratch driver `evidence/requests/audio_vehicle.gd.txt`) with the sink hung the WorldAudio way. What the sink heard from VehicleCues, no code on either side beyond the merge:
**5 crashes, 1 car_wreck explosion (a second one dropped by the 30-tick cooldown), 2 hit_metal, 3 horns**, no missing sound file. The engine bed's pitch followed the car:
speeds 8.2 / 15.7 / 19.2 / 5.1 / 1.1 m/s per second -> pitch scale 0.99 / 1.23 / 1.41 / 0.90 / 0.79. -16.5 LUFS integrated, true peak -3.1 dBFS, LRA 22 LU (the engine bed runs, then
the clip goes quiet after the wreck). Frames at 3, 9, 13 s looked at: straight down, 0 rejected. Not covered: tyre_screech (the route has no slide), hijack slam (`vehicle_hijacked`),
`pedestrian_struck` thud (unit-tested only). Measured, not heard. (The native DLL of my lane lacks `CitySim::set_obstacles`: with it the engine logs one error per call; the vehicles lane's DLL does not.)

Second run on the vehicles lane's plain route (`--route`: enter the sedan, full throttle through a pedestrian, S-bend, handbrake slide; 12 s, report only, no clip,
`vehicles_merge_route_cues.json`): the sink heard `tyre_screech` 1, and the `pedestrian_struck` Event gave 1 body thud + 1 death (the pedestrian was killed); engine pitch 0.99 -> 1.60 at
28 m/s top speed -> 0.75 at rest (all four vehicle sounds now covered against real cars; the hijack slam is the `hit_metal` of the carnage run). Not heard.

## Iteration 4: are the voice lines intelligible in the real mix? (`tools/audio/mix_intelligibility.py`, evidence/mix/slice_q1_intelligibility.json)

Whisper (base.en, local) transcribes the audio of `slice_q1_audio.mp4` (150 s of the real slice) and each line the line player asked for is matched against the transcript (best word-window
difflib ratio): **8 of the 20 requested lines come through clearly (>= 0.78: rivet-line-stopped, rivet-my-hands, fax-slow-motion, fax-statistically, rivet-buildings-talk, guard-who-do-we-call,
mertz-inventory, mertz-appliances), 3 are partial (0.36-0.52), 9 are not in the audio (<= 0.21)**. That matches the voice-queue loss (7 drops; the voices alone run 272 s against 121 s of subtitles),
not a masking problem: the same lines read back clean in isolation (mean WER 2.9%, evidence/voice_stt.json) and the clip's mix has the voice -2 dB under sfx +3 dB with a 9 dB music duck.
The lost lines include **the Patch call itself (`patch-collect-call`, 0.16)**, a line the quest opens on. This is REQUEST 1 (slice-play): until the line timing follows the voice length, a third to a half of the
voiced lines never play. A read-back, not a listening test.
