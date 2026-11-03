class_name VoiceLengths
extends RefCounted
## data/tables/voice_lengths.json (gtai.voice-lengths/1, from the audio lane): seconds of each
## voiced quest line, keyed by the voice file's base name. The line player reads it so a line
## stays on screen until its voice has played to the end (owner C21). Read once (DAT-05).

const PATH: String = "res://data/tables/voice_lengths.json"

static var _lengths: Dictionary[String, float] = {}
static var _loaded: bool = false


## Seconds of the voice file at `audio_path` (res://assets/audio/voice/<name>.ogg), 0 if unknown.
static func seconds_for(audio_path: String) -> float:
	if not _loaded:
		_load()
	return _lengths.get(audio_path.get_file().get_basename(), 0.0)


static func _load() -> void:
	_loaded = true
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(PATH)) != OK or not parser.data is Dictionary:
		return
	var doc: Dictionary = parser.data
	var rows: Dictionary = doc["lines"] if doc.get("lines") is Dictionary else {}
	for key: Variant in rows:
		var seconds: Variant = rows[key]
		if seconds is float or seconds is int:
			var value: float = seconds
			_lengths[str(key)] = value
