class_name CameraRig
extends RefCounted
## Camera feel as data (data/tables/camera.json, gtai.camera/1): eased zoom between the modes
## (32 px/m on foot, 48 in a car, 64 in an arena), velocity look-ahead in a car, screen shake and
## hit-stop by id, all scaled down under reduced motion. Steps on the 60 Hz sim tick; the shake is
## a hash of the tick (no RNG stream). Render only: CityView reads ppm() and offset_px() each frame;
## a hit-stop (hitstop()) is held by the caller on the SimClock (SimClock.hold).

const TABLE: String = "res://data/tables/camera.json"
## A focus faster than this (m/s) jumped (a cut, a respawn, a bench reset): it leads nothing.
const JUMP_MPS: float = 90.0

var reduced_motion: bool = false
var mode: StringName = &"on_foot"
var modes: Dictionary[StringName, Dictionary] = {}
var shakes: Dictionary[StringName, Dictionary] = {}
var hitstops: Dictionary[StringName, int] = {}
var reduced: Dictionary = {}
var ease_ticks: int = 36
var look_ease: float = 0.06
var stop_cooldown: int = 20

var _from_ppm: float = 32.0
var _ppm: float = 32.0
var _ease_start: int = 0
var _tick: int = 0
var _look_m: Vector2 = Vector2.ZERO
var _shake_id: StringName = &""
var _shake_tick: int = -100000
var _clock: SimClock = null
var _focus_m: Vector2 = Vector2.ZERO
var _focus_tick: int = -1
var _stop_tick: int = -100000


func _init() -> void:
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(TABLE)) != OK or not parser.data is Dictionary:
		return
	var d: Dictionary = parser.data
	for row: Dictionary in d["modes"]:
		modes[StringName(str(row["id"]))] = row
	for row: Dictionary in d["shakes"]:
		shakes[StringName(str(row["id"]))] = row
	for row: Dictionary in d["hitstops"]:
		var t: float = row["ticks"]
		hitstops[StringName(str(row["id"]))] = int(t)
	reduced = d["reduced_motion"]
	var e: float = d["zoom_ease_ticks"]
	ease_ticks = int(e)
	look_ease = d["look_ahead_ease"]
	var c: float = d["hitstop_cooldown_ticks"]
	stop_cooldown = int(c)
	_ppm = _target_ppm()
	_from_ppm = _ppm


## Switches mode (on_foot / car / arena) at sim tick `tick`; the zoom eases from where it is.
func set_mode(id: StringName, tick: int) -> void:
	if id == mode or not modes.has(id):
		return
	mode = id
	_from_ppm = _ppm
	_ease_start = tick


## Follows the F-04 events on `bus` (the Events autoload) at the tick `clock` reads when one fires:
## entering a vehicle eases to `car`, leaving it to `on_foot`; a boss engaging eases to `arena`
## (64 px/m, where the `auto` look reaches D5) and the contract completing back to `on_foot`.
func listen(bus: EventBus, clock: SimClock) -> void:
	_clock = clock
	@warning_ignore("return_value_discarded")
	bus.vehicle_entered.connect(_on_vehicle.bind(&"car"))
	@warning_ignore("return_value_discarded")
	bus.vehicle_exited.connect(_on_vehicle.bind(&"on_foot"))
	@warning_ignore("return_value_discarded")
	bus.boss_engaged.connect(_on_named.bind(&"arena"))
	@warning_ignore("return_value_discarded")
	bus.contract_completed.connect(_on_named.bind(&"on_foot"))


func _on_vehicle(_vehicle_id: int, id: StringName) -> void:
	set_mode(id, _clock.tick() if _clock != null else 0)


func _on_named(_what: StringName, id: StringName) -> void:
	set_mode(id, _clock.tick() if _clock != null else 0)


## Jumps to mode `id` with no ease (boot, a cut).
func snap(id: StringName) -> void:
	if modes.has(id):
		mode = id
		_ppm = _target_ppm()
		_from_ppm = _ppm


## Starts shake `id` at `tick` (a stronger shake in progress is kept).
func kick(id: StringName, tick: int) -> void:
	if not shakes.has(id):
		return
	if _shake_id != &"" and _shake_amp(tick) > _amp_of(id):
		return
	_shake_id = id
	_shake_tick = tick


## The ticks the game should freeze for hit-stop `id` (0 under reduced motion).
func hitstop_ticks(id: StringName) -> int:
	var base: int = hitstops.get(id, 0)
	return roundi(base * _scale("hitstop_scale"))


## Hit-stop `id` asked for at sim tick `tick`: the ticks to hold (0 under reduced motion, for an
## unknown id, or inside the cooldown of the last stop). The caller holds the clock (SimClock.hold).
func hitstop(id: StringName, tick: int) -> int:
	var ticks: int = hitstop_ticks(id)
	if ticks <= 0 or tick - _stop_tick < stop_cooldown:
		return 0
	_stop_tick = tick
	return ticks


## Advances to sim tick `tick` with the followed body's velocity (m/s).
func step(tick: int, vel_mps: Vector2) -> void:
	var steps: int = clampi(tick - _tick, 0, 8)
	_tick = tick
	var span: float = ease_ticks * _scale("zoom_ease_scale")
	var t: float = clampf((tick - _ease_start) / maxf(span, 1.0), 0.0, 1.0)
	_ppm = lerpf(_from_ppm, _target_ppm(), smoothstep(0.0, 1.0, t))
	var m: Dictionary = modes[mode]
	var per: float = m["look_ahead_m_per_mps"]
	var cap: float = m["look_ahead_max_m"]
	cap *= _scale("look_ahead_scale")
	var want: Vector2 = (vel_mps * per).limit_length(cap)
	for i: int in steps:
		_look_m = _look_m.lerp(want, look_ease)


## Advances to sim tick `tick` following the focus at `focus_m` (metres): its velocity is how far
## it moved since the last tick it was seen at, so whoever moves the focus feeds the look-ahead.
## Frames with no new tick lead nothing and keep the last sample.
func follow(tick: int, focus_m: Vector2) -> void:
	var vel: Vector2 = Vector2.ZERO
	var ticks: int = tick - _focus_tick
	if _focus_tick >= 0 and ticks > 0:
		vel = (focus_m - _focus_m) / (ticks * SimClock.TICK_DT)
		if vel.length() > JUMP_MPS:
			vel = Vector2.ZERO
	if ticks != 0:
		_focus_m = focus_m
		_focus_tick = tick
	step(tick, vel)


func ppm() -> float:
	return _ppm


## The camera offset from the focus in world px: look-ahead plus shake.
func offset_px(px_per_m: float) -> Vector2:
	var amp: float = _shake_amp(_tick)
	var shake: Vector2 = Vector2.ZERO
	if amp > 0.0:
		var hz: float = shakes[_shake_id]["freq_hz"]
		var ph: float = (_tick - _shake_tick) * SimClock.TICK_DT * hz * TAU
		shake = Vector2(sin(ph), cos(ph * 1.37 + 0.6)) * amp / (_ppm / px_per_m)
	return _look_m * px_per_m + shake


func _target_ppm() -> float:
	var p: float = modes.get(mode, {"ppm": 32.0})["ppm"]
	return p


func _amp_of(id: StringName) -> float:
	var a: float = shakes[id]["amp_px"]
	return a * _scale("shake_scale")


func _shake_amp(tick: int) -> float:
	if _shake_id == &"":
		return 0.0
	var ticks: float = shakes[_shake_id]["ticks"]
	var k: float = 1.0 - (tick - _shake_tick) / ticks
	return _amp_of(_shake_id) * k if k > 0.0 else 0.0


## A reduced-motion factor from the table (1 when reduced motion is off).
func _scale(key: String) -> float:
	if not reduced_motion:
		return 1.0
	var v: float = reduced.get(key, 1.0)
	return v
