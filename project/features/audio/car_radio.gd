class_name CarRadio
extends Node
## The car radio stub (data/tables/audio_radio.json): a few looping stations on the `radio` bus, a
## band-pass so they sound like a dashboard speaker, and a one-shot stinger. It switches on while
## Rivet drives (Events.vehicle_entered / vehicle_exited); next() flips the station, and so does the
## `radio_next` input action while the radio is on (the action is a row of the input table
## data/tables/input_actions.json, slice-play's: without the row nothing listens). Placeholder
## music; the owner picks the real playlist later.

const TABLE: String = "res://data/tables/audio_radio.json"
const DIR: String = "res://assets/audio/music/"
const BUS: StringName = &"radio"
const ACTION: StringName = &"radio_next"

var stations: Array[Dictionary] = []
var station: int = 0
var on: bool = false
var stingers: int = 0
var _doc: Dictionary = {}
var _player: AudioStreamPlayer = AudioStreamPlayer.new()
var _sting: AudioStreamPlayer = AudioStreamPlayer.new()


func _ready() -> void:
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(TABLE)) == OK and parser.data is Dictionary:
		_doc = parser.data
		for row: Dictionary in _doc.get("stations", []):
			stations.append(row)
	_player.bus = BUS
	_sting.bus = &"ui"
	add_child(_player)
	add_child(_sting)
	_band_limit()


## Follows the Events: the radio plays while Rivet is in a car, the sting marks a finished contract.
func listen(bus: EventBus) -> void:
	@warning_ignore("return_value_discarded")
	bus.vehicle_entered.connect(func(_id: int) -> void: power(true))
	@warning_ignore("return_value_discarded")
	bus.vehicle_exited.connect(func(_id: int) -> void: power(false))
	@warning_ignore("return_value_discarded")
	bus.contract_completed.connect(func(_id: StringName) -> void: sting())


func _unhandled_input(event: InputEvent) -> void:
	if on and InputMap.has_action(ACTION) and event.is_action_pressed(ACTION):
		next()


func power(want: bool) -> void:
	on = want
	if want and not stations.is_empty():
		_tune()
	else:
		_player.stop()


func next() -> void:
	if stations.is_empty():
		return
	station = (station + 1) % stations.size()
	if on:
		_tune()


func sting() -> void:
	var row: Dictionary = _doc.get("stinger", {})
	var s: AudioStream = _load(str(row.get("file", "")), false)
	if s == null:
		return
	var gain: float = row.get("gain_db", 0.0)
	_sting.stream = s
	_sting.volume_db = gain
	_sting.play()
	stingers += 1


func _tune() -> void:
	var row: Dictionary = stations[station]
	var s: AudioStream = _load(str(row["file"]), true)
	if s == null:
		return
	var gain: float = row["gain_db"]
	_player.stream = s
	_player.volume_db = gain
	_player.play()


func _load(file: String, loop: bool) -> AudioStream:
	var path: String = "%s%s.ogg" % [DIR, file]
	if file == "" or not ResourceLoader.exists(path):
		return null
	var s: AudioStreamOggVorbis = load(path) as AudioStreamOggVorbis
	if s != null:
		s.loop = loop
	return s


func _band_limit() -> void:
	var idx: int = AudioServer.get_bus_index(BUS)
	if idx < 0 or AudioServer.get_bus_effect_count(idx) > 0:
		return
	var hp: AudioEffectHighPassFilter = AudioEffectHighPassFilter.new()
	var lp: AudioEffectLowPassFilter = AudioEffectLowPassFilter.new()
	var hp_hz: float = _doc.get("high_pass_hz", 320.0)
	var lp_hz: float = _doc.get("low_pass_hz", 5200.0)
	hp.cutoff_hz = hp_hz
	lp.cutoff_hz = lp_hz
	AudioServer.add_bus_effect(idx, hp)
	AudioServer.add_bus_effect(idx, lp)
