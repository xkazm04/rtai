class_name HandheldRumble
extends Node
## d9-handheld: pad rumble under a device profile whose row sets `rumble` (a gain, 0..1; the desktop
## row has none, so the shipped game never vibrates). It listens to the Events bus only (gameplay
## emits, this never reads or writes the sim) and plays one pulse per event on every connected pad.
## A weaker pulse never cuts a stronger one that is still running. LaunchArgs adds it next to the
## profile. Patterns: weak motor, strong motor, seconds (docs/handheld/LEDGER.md, the pad audit).

const PULSES: Dictionary[StringName, Vector3] = {
	&"player_hit": Vector3(0.3, 0.8, 0.18),
	&"struck_killed": Vector3(0.4, 0.6, 0.16),
	&"struck": Vector3(0.3, 0.3, 0.1),
	&"knocked_down": Vector3(0.5, 0.2, 0.1),
	&"boss_engaged": Vector3(0.6, 0.6, 0.5),
	&"hijacked": Vector3(0.3, 0.1, 0.12),
	&"whispers": Vector3(0.2, 0.0, 0.4),
}

var gain: float = 1.0
## Pulses played (tests and the log read it).
var played: int = 0
var last: Vector3 = Vector3.ZERO
var _until_ms: int = 0
var _strength: float = 0.0


func _init(rumble_gain: float = 1.0) -> void:
	gain = clampf(rumble_gain, 0.0, 1.0)


func _ready() -> void:
	var bus: Node = get_node_or_null(^"/root/Events")
	if bus == null:
		return
	for pair: Array in [
		[&"player_hit", _on_player_hit],
		[&"pedestrian_struck", _on_struck],
		[&"actor_knocked_down", _on_knocked_down],
		[&"boss_engaged", _on_boss],
		[&"vehicle_hijacked", _on_hijacked],
		[&"whispers_spiked", _on_whispers],
	]:
		var signal_name: StringName = pair[0]
		var handler: Callable = pair[1]
		@warning_ignore("return_value_discarded")
		bus.connect(signal_name, handler)


## The pulse `kind` at `rumble_gain`: weak, strong, seconds (zero for an unknown kind).
static func pulse(kind: StringName, rumble_gain: float) -> Vector3:
	var p: Vector3 = PULSES.get(kind, Vector3.ZERO)
	return Vector3(p.x * rumble_gain, p.y * rumble_gain, p.z)


## Plays `kind` on every connected pad unless a stronger pulse is still running; true when it did.
func play(kind: StringName) -> bool:
	var p: Vector3 = pulse(kind, gain)
	var now: int = Time.get_ticks_msec()
	var strength: float = maxf(p.x, p.y)
	if strength <= 0.0 or (now < _until_ms and strength < _strength):
		return false
	_until_ms = now + int(p.z * 1000.0)
	_strength = strength
	played += 1
	last = p
	for pad: int in Input.get_connected_joypads():
		Input.start_joy_vibration(pad, p.x, p.y, p.z)
	return true


func _on_player_hit(_weapon: StringName) -> void:
	_fire(&"player_hit")


func _on_struck(_victim: int, killed: bool) -> void:
	_fire(&"struck_killed" if killed else &"struck")


func _on_knocked_down(_attacker: int, _defender: int, _klass: StringName, _at: Vector2) -> void:
	_fire(&"knocked_down")


func _on_boss(_boss: StringName) -> void:
	_fire(&"boss_engaged")


func _on_hijacked(_kind: StringName) -> void:
	_fire(&"hijacked")


func _on_whispers() -> void:
	_fire(&"whispers")


func _fire(kind: StringName) -> void:
	@warning_ignore("return_value_discarded")
	play(kind)
