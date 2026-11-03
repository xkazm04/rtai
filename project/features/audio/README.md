# features/audio

Sound for the combat, the city and quest 1, plus the first voiced lines. Render-side only: it reads the
game (FX cues, `Events`, the quest line player) and never writes the sim, so replay and parity stay put.

| Piece | File | What it does |
|---|---|---|
| Service | `audio_service.gd` | `cue(id, pos_m, tick)`: 24 pooled `AudioStreamPlayer2D`, per-frame voice cap, per-cue cooldown / max voices / priority steal, distance cull, pan + fade by the listener (the camera focus), variation + pitch jitter from `AudioDice` |
| Tables | `audio_tables.gd`, `audio_cue.gd` | `data/tables/audio_cues.json` (cue -> sound, takes, bus, gain, pitch, range) and `audio_mix.json` (buses, cap, duck, loudness targets) |
| Dice | `audio_dice.gd` | variation + jitter, seeded from the RNG registry's master seed; deliberately not a registry stream (see decisions) |
| Buses | `audio_buses.gd` | sfx / voice / music / ui / radio built at boot from the mix table; voice ducks music and sfx |
| Loops | `audio_loops.gd` | engine, siren, city beds with fades |
| Voice | `voice_channel.gd`, `quest_voice.gd` | one line at a time (FIFO), played when the line player shows a line; the path is the line's `audio` field in the quest package |
| Radio | `car_radio.gd` | 3 loops + a stinger on the band-limited `radio` bus; on while driving |
| Hooks | `audio_hooks.gd`, `world_audio.gd`, `stage_audio.gd` | Events -> cues, the FX trigger sink (riot), the shot feed (quest stage) |

## Playing a sound from another lane

* Anything that already fires an FX trigger (`FxTriggers.fire(id, pos_px, angle, tick)`) is heard when `id` is a cue id; the
  sink runs before the row lookup, so an id with no `fx_triggers.json` row still plays (`horn`, `crash`, `tyre_screech`, `hit_metal`).
* A new sound: add the files `assets/audio/sfx/<sound>_01..NN.wav` and a row in `audio_cues.json`.
* Quest voice: set the line's `audio` to `res://assets/audio/voice/<line id>.ogg`; `tools/audio/` makes the files.

## Tools (`tools/audio/`)

`gen_sfx.py`, `gen_voice.py`, `gen_music.py` (ElevenLabs direct; PoF's audio route could not serve them, see JOURNAL POF-GAP 1-3),
`process.py` (trim / loudness / QC), `provenance.py`, `voice_lengths.py`, `build_tables.py`. The key comes from the environment only.
