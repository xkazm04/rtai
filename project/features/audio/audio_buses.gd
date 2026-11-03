class_name AudioBuses
extends RefCounted
## The bus layout from data/tables/audio_mix.json, built at boot (no default_bus_layout.tres, so no
## shared binary file to merge): sfx, voice, music, ui under Master. Also the duck: while a voice
## line plays, the ducked buses sink by duck_db and come back at the release rate. Frames are
## rendered frames, not sim ticks; the mix never touches the sim.

var _mix: Dictionary = {}
var _duck: float = 0.0  # 0 = open, 1 = fully ducked
var _base_db: Dictionary[StringName, float] = {}
var _user_db: Dictionary[StringName, float] = {}


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
	_far_filter()
	_limit_master()


## Moves the duck toward `want` (true = a voice is speaking) by `frame_s` of wall time.
func step_duck(want: bool, frame_s: float) -> void:
	var duck: Dictionary = _mix.get("duck", {})
	var attack: float = duck.get("duck_attack_s", 0.12)
	var release: float = duck.get("duck_release_s", 0.6)
	var rate: float = frame_s / (attack if want else release)
	_duck = clampf(_duck + (rate if want else -rate), 0.0, 1.0)
	for id: String in duck.get("buses", []):
		_apply(StringName(id))


## A player's own level for `bus` (0..1, a settings slider), on top of the table level and the duck.
func set_user_gain(bus: StringName, linear: float) -> void:
	_user_db[bus] = linear_to_db(clampf(linear, 0.0001, 1.0))
	_apply(bus)


## The bus level = table level + the player's gain + the duck's share (if the bus is ducked).
func _apply(bus: StringName) -> void:
	var idx: int = AudioServer.get_bus_index(bus)
	if idx < 0 or not _base_db.has(bus):
		return
	var duck: Dictionary = _mix.get("duck", {})
	var cuts: Dictionary = duck.get("duck_db", {})
	var ducked: Array = duck.get("buses", [])
	var cut: float = 0.0
	if ducked.has(String(bus)):
		var depth: float = cuts.get(String(bus), 0.0)
		cut = depth * _duck
	var user: float = _user_db.get(bus, 0.0)
	AudioServer.set_bus_volume_db(idx, _base_db[bus] + user + cut)


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


## The `sfx_far` bus muffles what is heard from far away: a low-pass at far_lowpass_hz.
func _far_filter() -> void:
	var idx: int = AudioServer.get_bus_index(&"sfx_far")
	if idx < 0 or AudioServer.get_bus_effect_count(idx) > 0:
		return
	var lp: AudioEffectLowPassFilter = AudioEffectLowPassFilter.new()
	lp.cutoff_hz = _mix.get("far_lowpass_hz", 2500.0)
	AudioServer.add_bus_effect(idx, lp)
