"""Writes data/tables/audio_cues.json, audio_mix.json and their schemas (sorted keys, DAT-02). Run from the repo root."""
import json
import pathlib

P = pathlib.Path("project/data")


def dump(path: pathlib.Path, obj: dict) -> None:
    path.write_text(json.dumps(obj, indent=2, sort_keys=True, ensure_ascii=False) + "\n", newline="\n", encoding="utf-8")


# id, doc, sound, takes, bus, gain_db, pitch, jitter, max_m, cooldown_ticks, max_voices, priority, loop
CUES = [
    ("shot", "a round leaves a gun in the riot (CitySim projectile feed, no weapon id): 9mm pistol", "pistol_shot", 3, "sfx", -6, 1.0, 0.07, 60, 2, 6, 2, False),
    ("shot_gloria", "Gloria the nail gun fires (quest stage)", "nailgun_shot", 3, "sfx", -5, 1.0, 0.05, 55, 3, 4, 3, False),
    ("shot_assault_rifle", "a contractor's assault rifle fires (quest stage)", "rifle_shot", 3, "sfx", -4, 1.0, 0.05, 70, 2, 6, 3, False),
    ("projectile_end", "a round stops against a wall, car or its range", "impact_concrete", 2, "sfx", -9, 1.0, 0.1, 45, 2, 5, 1, False),
    ("hit_flesh", "a round stops in a body", "impact_flesh", 2, "sfx", -6, 1.0, 0.1, 45, 2, 5, 2, False),
    ("hit_metal", "a round or a bumper hits metal (vehicles lane)", "impact_metal", 2, "sfx", -7, 1.0, 0.1, 45, 3, 4, 2, False),
    ("death", "a person dies in the riot: a wet thud", "impact_flesh", 2, "sfx", -8, 0.85, 0.08, 45, 3, 4, 2, False),
    ("player_hit", "Rivet is hit: the body blow, loud and close", "impact_flesh", 2, "sfx", -2, 0.8, 0.05, 0, 4, 2, 5, False),
    ("player_hit_robo_tazer", "the Robo-tazer arc lands on Rivet: the electroshock crackle", "shock_crackle", 2, "sfx", -1, 1.0, 0.04, 0, 10, 2, 5, False),
    ("attack_telegraphed", "a boss weapon winds up (the charge whine)", "servo_whine", 2, "sfx", -4, 0.7, 0.06, 0, 30, 2, 4, False),
    ("servo", "Rivet's joints, layered over his steps now and then", "servo_whine", 2, "sfx", -16, 1.2, 0.1, 0, 60, 1, 1, False),
    ("footsteps", "Rivet walking on concrete (four steps, replayed while he moves)", "footsteps", 2, "sfx", -12, 1.0, 0.04, 0, 100, 1, 1, False),
    ("crowd_panic", "a crowd screams and scatters", "crowd_panic", 2, "sfx", -10, 1.0, 0.05, 60, 240, 2, 2, False),
    ("horn", "a car horn (vehicles lane)", "horn", 2, "sfx", -8, 1.0, 0.06, 60, 20, 3, 2, False),
    ("crash", "a car crash (vehicles lane)", "crash", 2, "sfx", -3, 1.0, 0.06, 70, 20, 3, 4, False),
    ("tyre_screech", "tyres screech in a hard turn (vehicles lane)", "tyre_screech", 2, "sfx", -9, 1.0, 0.08, 60, 30, 3, 2, False),
    ("engine_loop", "the car Rivet drives: engine bed (vehicle_entered)", "engine_loop", 1, "sfx", -14, 1.0, 0.0, 0, 0, 1, 3, True),
    ("siren_loop", "police sirens while wanted (wanted_changed)", "siren_loop", 1, "sfx", -16, 1.0, 0.0, 0, 0, 1, 2, True),
    ("city_ambience", "the night city bed under everything", "city_ambience", 1, "sfx", -22, 1.0, 0.0, 0, 0, 1, 0, True),
]
KEYS = ["id", "doc", "sound", "takes", "bus", "gain_db", "pitch", "pitch_jitter", "max_m", "cooldown_ticks", "max_voices", "priority", "loop"]

CUES_DOC = (
    "Sound cues as data (features/audio/README.md). A cue id is an FX trigger id (data/tables/fx_triggers.json: shot, "
    "projectile_end, death, player_hit, ...), an F-04 Events signal, or an id a lane fires itself (hit_flesh, horn, crash, "
    "tyre_screech). sound/takes: res://assets/audio/sfx/<sound>_<01..takes>.wav (.ogg when longer than 3 s). gain_db trims the "
    "cue before the bus. pitch is the base pitch scale, pitch_jitter the +/- fraction drawn per play from the audio dice (seeded "
    "from the RNG registry's master seed, never a registry stream: render-side draws must not enter the replay hash). max_m: "
    "hearing distance in metres, 0 = not positional. cooldown_ticks: min sim ticks between two plays of the cue. max_voices: "
    "simultaneous players for the cue. priority: who may steal a pool voice when it is full (0 lowest)."
)
MIX_DOC = (
    "The mix as data (features/audio/audio_buses.gd builds the buses at boot, no default_bus_layout.tres). buses: id, parent bus "
    "id ('' = Master), volume_db. voice_cap_per_frame: most new positional voices started in one rendered frame (a riot frame can "
    "ask for dozens). pool_size: AudioStreamPlayer2D voices. m_to_px: audio-space pixels per metre (cue max_m scales by it). "
    "attenuation: AudioStreamPlayer2D attenuation exponent. panning_strength: 0..1 stereo spread for the top-down camera. duck: "
    "while a voice line plays, these buses drop by duck_db over duck_attack_s and recover over duck_release_s (rendered frames, "
    "not ticks). loudness: the targets the files were normalised to (tools/audio/process.py). footstep_speed_mps: Rivet's speed "
    "above which footsteps play. servo_chance: odds a footstep run also gets Rivet's servo whine."
)

dump(P / "tables/audio_cues.json", {"schema": "gtai.audio-cues/1", "doc": CUES_DOC, "cues": [dict(zip(KEYS, c)) for c in CUES]})
dump(P / "tables/audio_mix.json", {
    "schema": "gtai.audio-mix/1", "doc": MIX_DOC,
    "buses": [
        {"id": "sfx", "parent": "", "volume_db": 0.0},
        {"id": "voice", "parent": "", "volume_db": 2.0},
        {"id": "music", "parent": "", "volume_db": -8.0},
        {"id": "ui", "parent": "", "volume_db": -4.0},
    ],
    "voice_cap_per_frame": 4, "pool_size": 24, "m_to_px": 32.0, "attenuation": 1.6, "panning_strength": 0.7,
    "duck": {"buses": ["music", "sfx"], "duck_db": {"music": -9.0, "sfx": -3.0}, "duck_attack_s": 0.12, "duck_release_s": 0.6},
    "loudness": {"sfx_peak_db": -3.0, "loop_peak_db": -6.0, "voice_lufs": -18.0, "voice_true_peak_db": -2.0},
    "footstep_speed_mps": 0.6, "servo_chance": 0.35,
})


def num(lo: float, hi: float, kind: str = "number") -> dict:
    return {"minimum": lo, "maximum": hi, "type": kind}


ident = {"pattern": "^[a-z][a-z0-9_]*$", "type": "string"}
dump(P / "schemas/audio_cues.schema.json", {
    "$id": "gtai.audio-cues/1", "additionalProperties": False, "type": "object", "required": ["schema", "doc", "cues"],
    "properties": {
        "doc": {"minLength": 1, "type": "string"}, "schema": {"const": "gtai.audio-cues/1"},
        "cues": {"minItems": 1, "type": "array", "items": {
            "additionalProperties": False, "type": "object", "required": KEYS,
            "properties": {
                "id": ident, "doc": {"minLength": 1, "type": "string"}, "sound": ident, "takes": num(1, 9, "integer"),
                "bus": {"enum": ["sfx", "voice", "music", "ui"]}, "gain_db": num(-60, 12), "pitch": num(0.25, 4),
                "pitch_jitter": num(0, 0.5), "max_m": num(0, 300), "cooldown_ticks": num(0, 3600, "integer"),
                "max_voices": num(1, 16, "integer"), "priority": num(0, 9, "integer"), "loop": {"type": "boolean"}}}}}})
dump(P / "schemas/audio_mix.schema.json", {
    "$id": "gtai.audio-mix/1", "additionalProperties": False, "type": "object",
    "required": ["schema", "doc", "buses", "voice_cap_per_frame", "pool_size", "m_to_px", "attenuation", "panning_strength", "duck", "loudness", "footstep_speed_mps", "servo_chance"],
    "properties": {
        "doc": {"minLength": 1, "type": "string"}, "schema": {"const": "gtai.audio-mix/1"},
        "buses": {"minItems": 1, "type": "array", "items": {
            "additionalProperties": False, "type": "object", "required": ["id", "parent", "volume_db"],
            "properties": {"id": ident, "parent": {"type": "string"}, "volume_db": num(-80, 12)}}},
        "voice_cap_per_frame": num(1, 32, "integer"), "pool_size": num(4, 64, "integer"), "m_to_px": num(1, 128),
        "attenuation": num(0.1, 8), "panning_strength": num(0, 1),
        "duck": {"additionalProperties": False, "type": "object", "required": ["buses", "duck_db", "duck_attack_s", "duck_release_s"],
                 "properties": {"buses": {"items": {"type": "string"}, "type": "array"},
                                "duck_db": {"additionalProperties": {"type": "number"}, "type": "object"},
                                "duck_attack_s": num(0.01, 5), "duck_release_s": num(0.01, 10)}},
        "loudness": {"additionalProperties": {"type": "number"}, "type": "object"},
        "footstep_speed_mps": num(0, 10), "servo_chance": num(0, 1)}})
