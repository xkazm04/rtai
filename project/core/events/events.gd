class_name EventBus
extends Node
## Events autoload (ARC-06): typed, past-tense, low-frequency domain events that cross features.
## Every signal is registered with its emitter and typed params in res://data/schemas/events.json
## (cap 40); the param NAMES are the achievements contract. Gameplay only emits, through the
## WorldContext it was given (ARC-04); AchievementTracker (owned by Platform) listens (ACH-07).
## Never route per-frame or per-actor data through here (ARC-07).
## The only state is the debug emit log (ARC-06): debug builds record every emit with its tick.

@warning_ignore_start("unused_signal")
signal tutorial_completed
signal soul_swapped(from: int, to: int)
signal vehicle_hijacked(vehicle_kind: StringName)
## The payload is decided before the damage chokepoint applies the lethal hit (events.json).
signal actor_killed(killer_id: int, victim_id: int, kind: StringName)
signal wanted_changed(level: int)
signal cash_changed(amount: int, delta: int)
signal contract_started(id: StringName)
signal contract_completed(id: StringName)
signal vehicle_entered(vehicle_id: int)
signal vehicle_exited(vehicle_id: int)
## The next wave of a combat encounter began (encounter = its place id, wave from 1).
signal wave_started(encounter: StringName, wave: int)
## A boss stepped into the fight (boss = its character id).
signal boss_engaged(boss: StringName)
## An attack aimed at Rivet began its tell (wind-up, charge whine).
signal attack_telegraphed(weapon: StringName)
## Rivet took a hit. Rivet only, never every actor (ARC-07).
signal player_hit(weapon: StringName)
## The voices in Rivet's head spiked (madness).
signal whispers_spiked
@warning_ignore_restore("unused_signal")

const DEBUG_LOG_SIZE: int = 256

var _debug_log: EventLog = null


func _ready() -> void:
	if OS.is_debug_build():
		_debug_log = EventLog.new(DEBUG_LOG_SIZE)
		_debug_log.attach(self, Engine.get_physics_frames)


## The composition root points the debug log at the sim clock once it exists.
func set_tick_source(tick_source: Callable) -> void:
	if _debug_log != null:
		_debug_log.set_tick_source(tick_source)


## The last emits, oldest first ("<tick> <signal> <args json>"); empty in release builds.
func recent_emits() -> PackedStringArray:
	return _debug_log.lines() if _debug_log != null else PackedStringArray()


## Names of every domain signal this bus declares (not Node's built-in signals).
func signal_names() -> Array[StringName]:
	var names: Array[StringName] = []
	var script: Script = get_script()
	for info: Dictionary in script.get_script_signal_list():
		var signal_name: StringName = info["name"]
		names.append(signal_name)
	return names


func reset() -> void:
	if _debug_log != null:
		_debug_log.clear()
		_debug_log.set_tick_source(Engine.get_physics_frames)
