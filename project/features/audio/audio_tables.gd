class_name AudioTables
extends RefCounted
## The audio data, parsed once: the cue table and the mix (buses, voice cap, ducking). Read-only.

const CUES_PATH: String = "res://data/tables/audio_cues.json"
const MIX_PATH: String = "res://data/tables/audio_mix.json"

var cues: Dictionary[StringName, AudioCue] = {}
var mix: Dictionary = {}


static func shipped() -> AudioTables:
	var t: AudioTables = AudioTables.new()
	var cue_doc: Variant = _read(CUES_PATH)
	if cue_doc is Dictionary:
		var doc: Dictionary = cue_doc
		for row: Dictionary in doc.get("cues", []):
			var parsed: AudioCue = AudioCue.from_row(row)
			t.cues[parsed.id] = parsed
	var mix_doc: Variant = _read(MIX_PATH)
	if mix_doc is Dictionary:
		t.mix = mix_doc
	return t


func cue(id: StringName) -> AudioCue:
	return cues.get(id, null)


func mix_float(key: String, fallback: float) -> float:
	var v: float = mix.get(key, fallback)
	return v


static func _read(path: String) -> Variant:
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK:
		Log.warn("audio", "cannot parse %s" % path)
		return null
	return parser.data
