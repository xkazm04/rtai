class_name AudioHooks
extends Node
## Wires the F-04 Events (data/schemas/events.json) and Rivet's own movement to AudioService cues.
## `fx_cues` true = the FX trigger sink already voices player_hit (the riot:
## core/render/fx_triggers.gd fires it with a position), so this does not double it. Cue ids it
## fires: crowd_panic (wave_started), attack_telegraphed, player_hit / player_hit_robo_tazer (only
## without fx_cues), footstep + servo (Rivet walking, one step per stride), and the loops
## siren_loop (wanted_changed) and engine_loop (vehicle_entered / vehicle_exited).
## With the vehicles lane merged: a run-over (pedestrian_struck) is a thud, a hijack
## (vehicle_hijacked) a door slam.

const WALK_MAX_MPS: float = 8.0
const SIREN_TRIM_DB_PER_STAR: float = 1.5

var service: AudioService
var fx_cues: bool = false
## True for the frame an actor_killed was heard: the stage feed voices a body hit, not a wall hit.
var kill_pending: bool = false
## Steps walked so far (heard or not: a busy pool may drop one).
var steps: int = 0
var _tick: Callable = Callable()
var _at: Callable = Callable()
var _last_at: Vector2 = Vector2.INF
var _driving: bool = false
var _stride_m: float = 0.0


func attach(p_service: AudioService, bus: EventBus, tick: Callable, at: Callable) -> void:
	service = p_service
	_tick = tick
	_at = at
	@warning_ignore("return_value_discarded")
	bus.wave_started.connect(func(_e: StringName, _w: int) -> void: _cue(&"crowd_panic"))
	@warning_ignore("return_value_discarded")
	bus.attack_telegraphed.connect(_on_telegraph)
	@warning_ignore("return_value_discarded")
	bus.boss_engaged.connect(func(_boss: StringName) -> void: _flat_if(true, &"boss_stinger"))
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
	@warning_ignore("return_value_discarded")
	bus.cash_changed.connect(
		func(_total: int, delta: int) -> void: _flat_if(delta > 0, &"cash_ding")
	)
	@warning_ignore("return_value_discarded")
	bus.contract_started.connect(func(_id: StringName) -> void: _flat_if(true, &"objective_ping"))
	@warning_ignore("return_value_discarded")
	bus.contract_completed.connect(func(_id: StringName) -> void: _flat_if(true, &"ui_confirm"))
	_connect_vehicles(bus)


## The vehicles lane's Events (pedestrian_struck, vehicle_hijacked) exist once that lane is merged.
func _connect_vehicles(bus: EventBus) -> void:
	if bus.has_signal(&"pedestrian_struck"):
		@warning_ignore("return_value_discarded")
		bus.connect(&"pedestrian_struck", _on_struck)
	if bus.has_signal(&"vehicle_hijacked"):
		@warning_ignore("return_value_discarded")
		bus.connect(&"vehicle_hijacked", func(_kind: StringName) -> void: _cue(&"hit_metal"))


func _flat_if(when: bool, id: StringName) -> void:
	if when:
		@warning_ignore("return_value_discarded")
		service.cue(id, Vector2.ZERO, _now())


func _on_struck(_victim: int, killed: bool) -> void:
	_cue(&"hit_flesh")
	if killed:
		_cue(&"death")


func _cue(id: StringName) -> void:
	var pos: Vector2 = _at.call() if _at.is_valid() else Vector2.ZERO
	@warning_ignore("return_value_discarded")
	service.cue(id, pos, _now())


func _on_telegraph(weapon: StringName) -> void:
	_cue(&"tazer_charge" if weapon == &"robo-tazer" else &"attack_telegraphed")


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


## One step per stride while Rivet moves on foot at walking pace; now and then his servo whines too.
func _process(_delta: float) -> void:
	var frame_s: float = service.frame_s
	if not _at.is_valid() or frame_s <= 0.0:
		return
	var here: Vector2 = _at.call()
	if _driving:
		_last_at = here
	else:
		walk_to(here, frame_s)
	kill_pending = false


## Rivet moved from the last frame's position to `here` in `frame_s`: step when a stride is walked.
func walk_to(here: Vector2, frame_s: float) -> void:
	var prev: Vector2 = _last_at
	_last_at = here
	if prev == Vector2.INF:
		return
	var moved: float = here.distance_to(prev)
	var min_mps: float = service.tables.mix_float("footstep_speed_mps", 0.6)
	if moved / frame_s <= min_mps or moved / frame_s >= WALK_MAX_MPS:
		_stride_m = 0.0
		return
	_stride_m += moved
	if _stride_m >= service.tables.mix_float("footstep_stride_m", 1.15):
		_stride_m = 0.0
		_step()


func _step() -> void:
	steps += 1
	if service.cue(&"footstep", _last_at, _now()):
		if service.dice.unit() < service.tables.mix_float("servo_chance", 0.12):
			_cue(&"servo")


func _now() -> int:
	var tick: int = _tick.call() if _tick.is_valid() else 0
	return tick
