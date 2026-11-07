class_name HandheldRumble
extends Node
## d9-handheld: pad rumble under a device profile whose row sets `rumble` (a gain, 0..1; the desktop
## row has none, so the shipped game never vibrates). It listens to the Events bus only (gameplay
## emits, this never reads or writes the sim) and plays one pulse per event on every connected pad.
## A weaker pulse never cuts a stronger one that is still running. LaunchArgs adds it next to the
## profile. Patterns: weak motor, strong motor, seconds (docs/handheld/LEDGER.md, the pad audit).

const PULSES: Dictionary[StringName, Vector3] = {
	&"player_hit": Vector3(0.3, 0.8, 0.18),
	&"rivet_hurt": Vector3(0.25, 0.55, 0.12),
	&"boss_hit": Vector3(0.15, 0.35, 0.07),
	&"struck_killed": Vector3(0.4, 0.6, 0.16),
	&"struck": Vector3(0.3, 0.3, 0.1),
	&"knocked_down": Vector3(0.5, 0.2, 0.1),
	&"boss_engaged": Vector3(0.6, 0.6, 0.5),
	&"hijacked": Vector3(0.3, 0.1, 0.12),
	&"whispers": Vector3(0.2, 0.0, 0.4),
}
## The rest in sim ticks after a felt hurt of a kind before the next one of that kind pulses (it14:
## a fast gun lands a boss hit every 2 ticks, so 70 ms pulses chained into one buzz; 8 ticks = at
## most 7.5 taps a second, the stock gun's 16-tick shortest gap untouched; 0 = before).
const REST_TICKS: Dictionary[StringName, int] = {&"boss_hit": 8}

## The live node (null without a rumble row: feel_hurt() is then a no-op, the desktop's case).
static var _live: HandheldRumble = null
## The player's rumble level (PlayerSettings.rumble: 1, 0.5, 0), times the row's gain.
static var player_gain: float = 1.0

var gain: float = 1.0
## Pulses played (tests and the log read it).
var played: int = 0
## Pulses played per kind (the exit log names them: which hits a fight is felt by).
var by_kind: Dictionary[StringName, int] = {}
var last: Vector3 = Vector3.ZERO
## The shortest gap in sim ticks between two fresh hurts per kind (see(); the log names it).
var min_gap: Dictionary[StringName, int] = {}
## Fresh hurts not felt because their kind was resting (REST_TICKS; the log names it).
var rested: int = 0
var _until_ms: int = 0
var _strength: float = 0.0
## The last hurt tick seen per kind (feel_hurt, feel_landed); the first one seen only primes.
var _seen: Dictionary[StringName, int] = {}
## The last felt hurt tick per kind (REST_TICKS counts from it).
var _felt: Dictionary[StringName, int] = {}


func _init(rumble_gain: float = 1.0) -> void:
	gain = clampf(rumble_gain, 0.0, 1.0)


func _ready() -> void:
	_live = self
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


func _exit_tree() -> void:
	if _live == self:
		_live = null
	Log.info(
		"device",
		(
			"rumble: %d pulses played %s, %d rested, shortest gaps (ticks) %s"
			% [played, by_kind, rested, min_gap]
		)
	)


## A view's per-frame read of Rivet's `hurt_tick` (the sim's Fighter.hurt_tick, set by every
## CombatArena.damage on him: guards, the pit, the bosses): a rise plays `rivet_hurt`. Reads only.
static func feel_hurt(hurt_tick: int) -> void:
	if _live != null:
		@warning_ignore("return_value_discarded")
		_live.see(&"rivet_hurt", hurt_tick)


## The boss bar's per-frame read of the boss body's `hurt_tick` (BossFight.hurt sets it on every
## hit that takes hp; a transition takes none): a rise plays the light `boss_hit`. Reads only.
static func feel_landed(hurt_tick: int) -> void:
	if _live != null:
		@warning_ignore("return_value_discarded")
		_live.see(&"boss_hit", hurt_tick)


## True when `hurt_tick` is a new hurt for `kind` (and plays its pulse unless the kind is resting,
## REST_TICKS); the first call only primes.
func see(kind: StringName, hurt_tick: int) -> bool:
	var fresh: bool = _seen.has(kind) and hurt_tick > _seen[kind]
	if fresh and _seen[kind] > 0:
		var gap: int = hurt_tick - _seen[kind]
		var was: int = min_gap.get(kind, gap)
		min_gap[kind] = mini(gap, was)
	_seen[kind] = hurt_tick
	if not fresh:
		return false
	if _felt.has(kind) and hurt_tick - _felt[kind] < REST_TICKS.get(kind, 0):
		rested += 1
		return true
	_felt[kind] = hurt_tick
	_fire(kind)
	return true


## Rivet's hurt (see()); the tests' name for it.
func see_hurt(hurt_tick: int) -> bool:
	return see(&"rivet_hurt", hurt_tick)


## The pulse `kind` at `rumble_gain`: weak, strong, seconds (zero for an unknown kind).
static func pulse(kind: StringName, rumble_gain: float) -> Vector3:
	var p: Vector3 = PULSES.get(kind, Vector3.ZERO)
	return Vector3(p.x * rumble_gain, p.y * rumble_gain, p.z)


## Plays `kind` on every connected pad unless a stronger pulse is still running; true when it did.
func play(kind: StringName) -> bool:
	var p: Vector3 = pulse(kind, gain * player_gain)
	var now: int = Time.get_ticks_msec()
	var strength: float = maxf(p.x, p.y)
	if strength <= 0.0 or (now < _until_ms and strength < _strength):
		return false
	_until_ms = now + int(p.z * 1000.0)
	_strength = strength
	played += 1
	by_kind[kind] = by_kind.get(kind, 0) + 1
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
