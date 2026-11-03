class_name AudioBuses
extends RefCounted
## The bus layout from data/tables/audio_mix.json, built at boot (no default_bus_layout.tres, so no
## shared binary file to merge): sfx, voice, music, ui under Master. Also the duck: while a voice
## line plays, the ducked buses sink by duck_db and come back at the release rate. Frames are
## rendered frames, not sim ticks; the mix never touches the sim.

var _mix: Dictionary = {}
var _duck: float = 0.0  # 0 = open, 1 = fully ducked
var _base_db: Dictionary[StringName, float] = {}


func _init(mix: Dictionary) -> void:
	_mix = mix


## Adds any missing bus (idempotent: tests and a second World share the AudioServer).
func ensure() -> void:
	for row: Dictionary in _mix.get("buses", []):
		var id: StringName = StringName(str(row["id"]))
		var idx: int = AudioServer.get_bus_index(id)
		if idx < 0:
			AudioServer.add_bus()
			idx = AudioServer.bus_count - 1
			AudioServer.set_bus_name(idx, id)
		AudioServer.set_bus_send(
			idx, StringName(str(row["parent"])) if str(row["parent"]) != "" else &"Master"
		)
		var base: float = row["volume_db"]
		_base_db[id] = base
		AudioServer.set_bus_volume_db(idx, _base_db[id])
	_limit_master()


## Moves the duck toward `want` (true = a voice is speaking) by `frame_s` of wall time.
func step_duck(want: bool, frame_s: float) -> void:
	var duck: Dictionary = _mix.get("duck", {})
	var attack: float = duck.get("duck_attack_s", 0.12)
	var release: float = duck.get("duck_release_s", 0.6)
	var rate: float = frame_s / (attack if want else release)
	_duck = clampf(_duck + (rate if want else -rate), 0.0, 1.0)
	var db: Dictionary = duck.get("duck_db", {})
	for id: String in duck.get("buses", []):
		var bus: StringName = StringName(id)
		var idx: int = AudioServer.get_bus_index(bus)
		if idx >= 0 and _base_db.has(bus):
			var cut: float = db.get(id, 0.0)
			AudioServer.set_bus_volume_db(idx, _base_db[bus] + cut * _duck)


func duck_amount() -> float:
	return _duck


## A hard limiter on Master (ceiling master_limiter_db): the mix never clips, whatever stacks up.
func _limit_master() -> void:
	var ceiling: float = _mix.get("master_limiter_db", -1.0)
	var master: int = AudioServer.get_bus_index(&"Master")
	for i: int in AudioServer.get_bus_effect_count(master):
		if AudioServer.get_bus_effect(master, i) is AudioEffectHardLimiter:
			return
	var limiter: AudioEffectHardLimiter = AudioEffectHardLimiter.new()
	limiter.ceiling_db = ceiling
	AudioServer.add_bus_effect(master, limiter)
