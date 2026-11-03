class_name VoiceChannel
extends Node
## The one voice-line channel (bus `voice`): one line at a time, in order, so two characters never
## talk over each other. Streams come from the quest's `audio`
## field (res://assets/audio/voice/<line id>.ogg).

const MAX_PENDING: int = 2

var line_id: String = ""
var plays: int = 0
var drops: int = 0
## Ids of the lines dropped from the backlog (evidence: which lines the player never heard).
var dropped_ids: Array[String] = []
var _player: AudioStreamPlayer = AudioStreamPlayer.new()
var _pending: Array[Array] = []


func _ready() -> void:
	_player.bus = &"voice"
	add_child(_player)


func playing() -> bool:
	return _player.playing


## Queues line `id` behind the one speaking (sentences are never cut mid-word); when the backlog
## passes MAX_PENDING the oldest waiting line is dropped. Returns false without a stream.
func speak(id: String, stream: AudioStream) -> bool:
	if stream == null:
		return false
	if _player.playing and _pending.size() >= MAX_PENDING:
		var lost: Array = _pending.pop_front()
		dropped_ids.append(str(lost[0]))
		drops += 1
	if _player.playing:
		_pending.append([id, stream])
		return true
	_begin(id, stream)
	return true


func _begin(id: String, stream: AudioStream) -> void:
	_player.stream = stream
	_player.volume_db = 0.0
	_player.play()
	line_id = id
	plays += 1


func stop() -> void:
	_player.stop()
	line_id = ""


## Called by AudioService every rendered frame: starts the next waiting line when one ends.
func step(_frame_s: float) -> void:
	if not _player.playing and not _pending.is_empty():
		var next: Array = _pending.pop_front()
		var stream: AudioStream = next[1]
		_begin(str(next[0]), stream)
