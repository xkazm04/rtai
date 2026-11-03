class_name AudioHooks
extends Node
## Wires the F-04 Events (data/schemas/events.json) and Rivet's own movement to AudioService cues.
## `fx_cues` true = the FX trigger sink already voices player_hit (the riot:
## core/render/fx_triggers.gd fires it with a position), so this does not double it. Cue ids it
## fires: crowd_panic (wave_started), attack_telegraphed, player_hit / player_hit_robo_tazer (only
## without fx_cues), footsteps + servo (Rivet walking), and the loops siren_loop (wanted_changed)
## and engine_loop (vehicle_entered / vehicle_exited).

const WALK_MAX_MPS: float = 8.0
const SIREN_TRIM_DB_PER_STAR: float = 1.5

var service: AudioService
var fx_cues: bool = false
## True for the frame an actor_killed was heard: the stage feed voices a body hit, not a wall hit.
var kill_pending: bool = false
var _tick: Callable = Callable()
var _at: Callable = Callable()
var _last_at: Vector2 = Vector2.INF
var _driving: bool = false


func attach(p_service: AudioService, bus: EventBus, tick: Callable, at: Callable) -> void:
	service = p_service
	_tick = tick
	_at = at
	@warning_ignore("return_value_discarded")
	bus.wave_started.connect(func(_e: StringName, _w: int) -> void: _cue(&"crowd_panic"))
	@warning_ignore("return_value_discarded")
	bus.attack_telegraphed.connect(func(_w: StringName) -> void: _cue(&"attack_telegraphed"))
	@warning_ignore("return_value_discarded")
	bus.player_hit.connect(_on_player_hit)
	@warning_ignore("return_value_discarded")
	bus.actor_killed.connect(func(_k: int, _v: int, _kind: StringName) -> void: kill_pending = true)
	@warning_ignore("return_value_discarded")
	bus.wanted_changed.connect(_on_wanted)
	@warning_ignore("return_value_discarded")
	bus.vehicle_entered.connect(func(_id: int) -> void: _set_driving(true))
	@warning_ignore("return_value_discarded")
	bus.vehicle_exited.connect(func(_id: int) -> void: _set_driving(false))


func _cue(id: StringName) -> void:
	var pos: Vector2 = _at.call() if _at.is_valid() else Vector2.ZERO
	@warning_ignore("return_value_discarded")
	service.cue(id, pos, _now())


func _on_player_hit(weapon: StringName) -> void:
	if fx_cues:
		return
	_cue(&"player_hit")
	if weapon == &"robo-tazer":
		_cue(&"player_hit_robo_tazer")


func _on_wanted(level: int) -> void:
	service.loops.set_on(&"siren_loop", level > 0, float(level - 3) * SIREN_TRIM_DB_PER_STAR)


func _set_driving(on: bool) -> void:
	_driving = on
	service.loops.set_on(&"engine_loop", on)


## Footsteps while Rivet moves on foot at walking pace; now and then his servo whines too.
func _process(_delta: float) -> void:
	var frame_s: float = service.frame_s
	if not _at.is_valid() or frame_s <= 0.0:
		return
	var here: Vector2 = _at.call()
	if _last_at != Vector2.INF and not _driving:
		var speed: float = here.distance_to(_last_at) / frame_s
		var min_mps: float = service.tables.mix_float("footstep_speed_mps", 0.6)
		if speed > min_mps and speed < WALK_MAX_MPS:
			_walk()
	_last_at = here
	kill_pending = false


func _walk() -> void:
	if service.cue(&"footsteps", _last_at, _now()):
		if service.dice.unit() < service.tables.mix_float("servo_chance", 0.35):
			_cue(&"servo")


func _now() -> int:
	var tick: int = _tick.call() if _tick.is_valid() else 0
	return tick
