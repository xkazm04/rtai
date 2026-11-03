class_name HaulerForm
extends RefCounted
## Hauler, the press-and-haul soul (powers.json `hauler`): Rivet becomes the bulky ghost tank.
## While on he is the `rivet_ghost` body class (bodies.json: the tackle matrix knocks down humans
## AND robots), moves with momentum (accel-limited, turn-limited, a lower top speed), rams above
## ram_mps and stomps a radial shockwave. morph_k() is the readable grow/shrink for the rig.

const BASE_CLASS: StringName = &"rivet_base"

var on: bool = false
var body_class: StringName = BASE_CLASS
var vel: Vector2 = Vector2.ZERO
## Counters for evidence: stomps fired and bodies knocked down by a stomp.
var stomps: int = 0
var stomp_knocks: int = 0
var _t: Dictionary = {}
var _morph_ticks: int = 1
## Ticks into the morph: counts up while on, down while off (0..morph_ticks).
var _morph: int = 0
var _stomp_wait: int = 0
## Ticks left in an armed stomp's telegraph (-1 = none armed).
var _windup: int = -1


func _init(tuning: Dictionary) -> void:
	_t = tuning
	_morph_ticks = maxi(1, PowerDef.ticks(num(&"morph_s")))


## Wire to SoulPowers.started/ended (only the `hauler` id matters).
func bind(powers: SoulPowers) -> void:
	@warning_ignore("return_value_discarded")
	powers.started.connect(_on_started)
	@warning_ignore("return_value_discarded")
	powers.ended.connect(_on_ended)


func num(key: StringName) -> float:
	return SoulTuning.num(_t, key)


## A string tuning value as an id (cue ids, shake ids); &"" when missing.
func id_of(key: StringName) -> StringName:
	return StringName(str(_t.get(key, "")))


## 0 = base Rivet, 1 = the full tank (a smoothstep over morph_s; the rig scales by it).
func morph_k() -> float:
	return smoothstep(0.0, 1.0, float(_morph) / float(_morph_ticks))


## One tick of heavy movement toward `want_dir` (unit or zero): turn-limited, accel-limited.
func step(want_dir: Vector2) -> void:
	_morph = clampi(_morph + (1 if on else -1), 0, _morph_ticks)
	_stomp_wait = maxi(0, _stomp_wait - 1)
	if _windup > 0:
		_windup -= 1
	var dt: float = SimClock.TICK_DT
	var target: Vector2 = want_dir.limit_length(1.0) * num(&"top_mps")
	if vel.length() > 0.5 and target.length() > 0.01:
		var max_turn: float = deg_to_rad(num(&"turn_dps")) * dt
		var ang: float = clampf(vel.angle_to(target), -max_turn, max_turn)
		target = vel.rotated(ang).normalized() * target.length()
	vel = vel.move_toward(target, num(&"accel_mps2") * dt)


## True while a contact at the current speed is a ram (knocks down, damages cars).
func ramming() -> bool:
	return on and vel.length() > num(&"ram_mps")


## The damage a ram deals to a car this contact (0 when not ramming).
func ram_car_damage() -> float:
	return num(&"ram_car_damage") if ramming() else 0.0


## Fires a stomp at `at` over `bodies`; returns one dict per body hit:
## {i, push (Vector2 knockback, m), knock (bool), stun_s}. Empty when off or cooling.
func stomp(at: Vector2, bodies: PackedVector2Array) -> Array[Dictionary]:
	var hits: Array[Dictionary] = []
	if not on or _stomp_wait > 0:
		return hits
	_windup = -1
	_stomp_wait = PowerDef.ticks(num(&"stomp_cooldown_s"))
	stomps += 1
	var radius: float = num(&"stomp_radius_m")
	for i: int in bodies.size():
		var d: Vector2 = bodies[i] - at
		var dist: float = d.length()
		if dist > radius:
			continue
		var falloff: float = 1.0 - dist / radius
		var dir: Vector2 = d / dist if dist > 0.001 else Vector2.RIGHT
		var push: Vector2 = dir * num(&"stomp_knock_m") * falloff
		hits.append({"i": i, "push": push, "knock": true, "stun_s": num(&"stomp_stun_s")})
		stomp_knocks += 1
	return hits


func stomp_ready() -> bool:
	return on and _stomp_wait == 0 and _windup < 0


## Starts the stomp telegraph (stomp_windup_s); true when armed. The host shows the wind-up
## and calls stomp() on the tick stomp_due() turns true.
func arm() -> bool:
	if not stomp_ready():
		return false
	_windup = PowerDef.ticks(num(&"stomp_windup_s"))
	return true


## True once an armed stomp's telegraph has run out (the host then calls stomp()).
func stomp_due() -> bool:
	return on and _windup == 0


## 0..1 through the telegraph (for the wind-up pose); 0 when none armed.
func windup_k() -> float:
	if _windup < 0:
		return 0.0
	var total: int = maxi(1, PowerDef.ticks(num(&"stomp_windup_s")))
	return 1.0 - float(_windup) / float(total)


func _on_started(id: StringName, _bark: StringName) -> void:
	_switch(id, true)


func _on_ended(id: StringName, _reason: StringName, _bark: StringName) -> void:
	_switch(id, false)


func _switch(id: StringName, value: bool) -> void:
	if id != &"hauler":
		return
	on = value
	body_class = StringName(str(_t.get("body_class", BASE_CLASS))) if value else BASE_CLASS
