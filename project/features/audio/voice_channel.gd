class_name VoiceChannel
extends Node
## The one voice-line channel (bus `voice`): one line at a time. A new line cuts the old one with a
## short fade, so two characters never talk over each other. Streams come from the quest's `audio`
## field (res://assets/audio/voice/<line id>.ogg).

const FADE_S: float = 0.12
const SILENT_DB: float = -60.0

var line_id: String = ""
var plays: int = 0
var cuts: int = 0
var _player: AudioStreamPlayer = AudioStreamPlayer.new()
var _fading: AudioStreamPlayer = AudioStreamPlayer.new()
var _fade_left: float = 0.0


func _ready() -> void:
	_player.bus = &"voice"
	_fading.bus = &"voice"
	add_child(_player)
	add_child(_fading)


func playing() -> bool:
	return _player.playing


## Speaks `stream` as line `id`; a line still running is faded out. Returns false without a stream.
func speak(id: String, stream: AudioStream) -> bool:
	if stream == null:
		return false
	if _player.playing:
		_fading.stream = _player.stream
		_fading.volume_db = 0.0
		_fading.play(_player.get_playback_position())
		_fade_left = FADE_S
		cuts += 1
	_player.stream = stream
	_player.volume_db = 0.0
	_player.play()
	line_id = id
	plays += 1
	return true


func stop() -> void:
	_player.stop()
	line_id = ""


## Called by AudioService every rendered frame with the clock's frame_delta().
func step(frame_s: float) -> void:
	if _fade_left <= 0.0:
		return
	_fade_left -= frame_s
	_fading.volume_db = lerpf(SILENT_DB, 0.0, clampf(_fade_left / FADE_S, 0.0, 1.0))
	if _fade_left <= 0.0:
		_fading.stop()
