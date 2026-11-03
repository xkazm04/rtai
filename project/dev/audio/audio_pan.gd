extends Node
## Spatial check for the audio service (record with the movie maker for the audio track):
##   godot --rendering-driver d3d12 --path project --write-movie <f.avi> --fixed-fps 60
##     res://dev/audio/audio_pan.tscn
## The listener stays at the origin; one shot a second at the positions in SHOTS (metres). The
## recorded stereo balance and level per shot proves the 2D pan and the distance fade
## (tools/audio/pan_check.py reads the wav).

const SHOTS: Array[Vector2] = [
	Vector2(-14.0, 0.0),
	Vector2(14.0, 0.0),
	Vector2(-4.0, 0.0),
	Vector2(4.0, 0.0),
	Vector2(0.0, -10.0),
	Vector2(0.0, 10.0),
	Vector2(5.0, 0.0),
	Vector2(25.0, 0.0),
	Vector2(45.0, 0.0),
]

var _service: AudioService = null
var _n: int = 0


func _ready() -> void:
	_service = AudioService.new(AudioTables.shipped(), 1)
	add_child(_service)


func _process(_delta: float) -> void:
	_n += 1
	var second: int = floori(_n / 60.0)
	if _n % 60 == 30 and second < SHOTS.size():
		@warning_ignore("return_value_discarded")
		_service.cue(&"shot_assault_rifle", SHOTS[second], _n)
	if _n > 60 * (SHOTS.size() + 1):
		get_tree().quit(0)
