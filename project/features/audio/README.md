# features/audio

Sound for the combat, the city and quest 1, plus the first voiced lines. Render-side only: it reads the
game (FX cues, `Events`, the quest line player) and never writes the sim, so replay and parity stay put.

| Piece | File | What it does |
|---|---|---|
| Service | `audio_service.gd` | `cue(id, pos_m, tick)`: 24 pooled `AudioStreamPlayer2D`, per-frame voice cap, per-cue cooldown / max voices / priority steal, distance cull, pan + fade by the listener (the camera focus), variation + pitch jitter from `AudioDice`; a cue row's optional `layer` names a second cue started along with it (`death` -> `blood_splat`, `rivet_kill` -> `blood_spurt`) |
| Tables | `audio_tables.gd`, `audio_cue.gd` | `data/tables/audio_cues.json` (cue -> sound, takes, bus, gain, pitch, range) and `audio_mix.json` (buses, cap, duck, loudness targets) |
| Dice | `audio_dice.gd` | variation + jitter, seeded from the RNG registry's master seed; deliberately not a registry stream (see decisions) |
| Buses | `audio_buses.gd` | sfx / voice / music / ui / radio built at boot from the mix table; voice ducks music and sfx |
| Loops | `audio_loops.gd` | engine, siren, city beds with fades |
| Voice | `voice_channel.gd`, `quest_voice.gd` | one line at a time (FIFO), played when the line player shows a line; the path is the line's `audio` field in the quest package |
| Radio | `car_radio.gd` | 3 loops + a stinger on the band-limited `radio` bus; on while driving; the `radio_next` input action (a row in `data/tables/input_actions.json`, see `evidence/requests/input_actions_radio_next.txt`) changes the station |
| Hooks | `audio_hooks.gd`, `world_audio.gd`, `stage_audio.gd` | Events -> cues, the FX trigger sink (riot), the shot feed (quest stage) |

## Playing a sound from another lane

* Anything that already fires an FX trigger (`FxTriggers.fire(id, pos_px, angle, tick)`) is heard when `id` is a cue id; the
  sink runs before the row lookup, so an id with no `fx_triggers.json` row still plays (`horn`, `crash`, `tyre_screech`, `hit_metal`).
* A new sound: add the files `assets/audio/sfx/<sound>_01..NN.wav` and a row in `audio_cues.json`.
* Quest voice: set the line's `audio` to `res://assets/audio/voice/<line id>.ogg`; `tools/audio/` makes the files.

## Settings sliders

`service.buses.set_user_gain(&"music", 0.5)` (0..1) scales one bus on top of the table level and the voice duck (buses: sfx, voice, music, ui; the pause card's
master volume is `PlayerSettings`, which writes the AudioServer's Master). Positional sfx beyond `far_m` run on the muffled `sfx_far` bus.

## What fires what (`audio_hooks.gd`)

| Source | Cue |
|---|---|
| Rivet walking (one step per `footstep_stride_m`, 8 single-step takes) | `footstep`, now and then `servo` |
| `wave_started` / `attack_telegraphed` (`robo-tazer` = `tazer_charge`) / `boss_engaged` | `crowd_panic` / `attack_telegraphed` or `tazer_charge` / `boss_stinger` |
| `player_hit` (+ `robo-tazer`) | `player_hit` (+ `player_hit_robo_tazer`) |
| `cash_changed` (delta > 0) / `contract_started` / `contract_completed` | `cash_ding` / `objective_ping` / `ui_confirm` (bus `ui`) |
| `wanted_changed` / `vehicle_entered`..`exited` | `siren_loop` / `engine_loop` (pitch follows the car's speed, `engine_*` in `audio_mix.json`) + radio |
| `boss_engaged` / `contract_completed` | `boss_stinger` then the `boss_loop` bed (music bus) / bed off |
| FX sink id `car_wreck` (vehicles lane explosion) | `car_wreck` (3 takes) + its layer `fire_crackle` (19.6 s positional bed, fades out over the last 5 s like the wreck's 24 s fire) |
| vehicles lane, once merged: `pedestrian_struck` / `vehicle_hijacked` | `hit_flesh` (+ `death`) / `hit_metal` |
| FX trigger sink (riot) | `shot`, `projectile_end`, `death`, `player_hit`, `rivet_kill` (= `kill_punch`) |
| API only: `ui_click`, `ui_back` | `service.cue(&"ui_click", Vector2.ZERO, tick)` |

## Tools (`tools/audio/`)

`gen_sfx.py`, `gen_voice.py`, `gen_music.py` (ElevenLabs direct; PoF's audio route could not serve them, see JOURNAL POF-GAP 1-3),
`process.py` (trim / loudness / QC), `split_steps.py` (a run of steps -> single steps), `provenance.py`, `voice_lengths.py`. (`build_tables.py` is retired: edit the JSON tables directly.) The key comes from the environment only.
