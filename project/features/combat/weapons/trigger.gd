class_name Trigger
extends RefCounted
## The trigger state of one weapon in one hand: cooldown, bloom (spread that grows per shot and
## recovers over time), magazine and reload. Pure data, stepped on the 60 Hz tick.

var spec: WeaponSpec
var cooldown: int = 0
var bloom_rad: float = 0.0
var ammo: int = 0
var reload_left: int = 0
var _was_held: bool = false


func _init(p_spec: WeaponSpec) -> void:
	spec = p_spec
	ammo = spec.magazine


func step() -> void:
	cooldown = maxi(cooldown - 1, 0)
	bloom_rad = maxf(bloom_rad - spec.bloom_recover_per_tick, 0.0)
	if reload_left > 0:
		reload_left -= 1
		if reload_left == 0:
			ammo = spec.magazine


func reloading() -> bool:
	return reload_left > 0


func start_reload() -> void:
	if spec.magazine > 0 and ammo < spec.magazine and not reloading():
		reload_left = spec.reload_ticks


## Called once per tick with the button state; true when a shot leaves this tick. Semi weapons
## fire on the press edge only, auto weapons while held.
func pull(held: bool) -> bool:
	var edge: bool = held and not _was_held
	_was_held = held
	if not held or cooldown > 0 or reloading():
		return false
	if not spec.auto and not edge:
		return false
	if spec.magazine > 0 and ammo <= 0:
		start_reload()
		return false
	cooldown = spec.interval_ticks
	if spec.magazine > 0:
		ammo -= 1
		if ammo == 0:
			start_reload()
	return true


## The cone half-angle a shot leaves inside right now (base spread plus current bloom).
func cone_rad() -> float:
	return spec.spread_rad + bloom_rad


## The direction one pellet leaves at, then the bloom it adds (call once per shot).
func shot_dir(aim: Vector2, rng: RandomNumberGenerator) -> Vector2:
	var cone: float = cone_rad()
	return aim.rotated(rng.randf_range(-cone, cone)) if cone > 0.0 else aim


func add_bloom() -> void:
	bloom_rad = minf(bloom_rad + spec.bloom_rad, maxf(spec.bloom_max_rad - spec.spread_rad, 0.0))
