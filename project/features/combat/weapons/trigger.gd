class_name Trigger
extends RefCounted
## The trigger state of one weapon in one hand: cooldown, bloom (spread that grows per shot and
## recovers over time), magazine and reload. Pure data, stepped on the 60 Hz tick.

var spec: WeaponSpec
var cooldown: int = 0
var bloom_rad: float = 0.0
var ammo: int = 0
var reload_left: int = 0
## Ticks a held charge gun has charged since it was ready (spec.charge_ticks = full).
var charge: int = 0
## The shot pull() let go this tick was a full charge.
var charged: bool = false
## Ticks the barrels have spun (spec.spin_ticks = up to speed): up while held, down when released.
var spin: int = 0
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
## fire on the press edge only, auto weapons while held. A charge gun held on after its shot
## charges once it is ready and lets the charged round go when full (a press always fires at
## once: the tap is the plain round; a release drops the charge).
func pull(held: bool) -> bool:
	var edge: bool = held and not _was_held
	_was_held = held
	charged = false
	if not held:
		charge = 0
	if spec.spin_ticks > 0:
		spin = clampi(spin + (1 if held else -1), 0, spec.spin_ticks)
	if not held or cooldown > 0 or reloading() or spin < spec.spin_ticks:
		return false
	if not spec.auto and not edge and not _charged_up():
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


## The barrels turn (spinning up, firing or winding down): the walk slows (fire_move_mult).
func spinning() -> bool:
	return spin > 0


## The charge as a fraction of full (views: the claw's crackle).
func charge_frac() -> float:
	return float(charge) / float(spec.charge_ticks) if spec.charge_ticks > 0 else 0.0


func _charged_up() -> bool:
	if spec.charge_ticks <= 0:
		return false
	charge += 1
	if charge < spec.charge_ticks:
		return false
	charge = 0
	charged = true
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
