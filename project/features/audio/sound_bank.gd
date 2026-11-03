class_name SoundBank
extends RefCounted
## Cue sounds, loaded on first use and kept: res://assets/audio/sfx/<sound>_<NN>.wav (or .ogg for
## the loops and anything over 3 s, AST-07). Imported resources only; nothing player-editable
## is loaded.

const DIR: String = "res://assets/audio/sfx/"
const EXTENSIONS: PackedStringArray = ["wav", "ogg"]

var missing: Array[String] = []
var _streams: Dictionary[String, AudioStream] = {}


## Take `take` (0-based) of `cue`'s sound; null when the file is not there (logged once).
func stream(cue: AudioCue, take: int) -> AudioStream:
	var key: String = "%s_%02d" % [cue.sound, take + 1]
	if _streams.has(key):
		return _streams[key]
	for ext: String in EXTENSIONS:
		var path: String = "%s%s.%s" % [DIR, key, ext]
		if ResourceLoader.exists(path):
			var s: AudioStream = load(path) as AudioStream
			if cue.loop:
				_set_loop(s)
			_streams[key] = s
			return s
	if not missing.has(key):
		missing.append(key)
		Log.warn("audio", "no sound file for %s" % key)
	return null


## Loads every take of every cue now (a hitch at the first gunshot is worse than a longer boot).
func prewarm(cues: Dictionary[StringName, AudioCue]) -> int:
	var n: int = 0
	for cue: AudioCue in cues.values():
		for take: int in cue.takes:
			if stream(cue, take) != null:
				n += 1
	return n


static func _set_loop(s: AudioStream) -> void:
	if s is AudioStreamOggVorbis:
		(s as AudioStreamOggVorbis).loop = true
	elif s is AudioStreamWAV:
		(s as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
