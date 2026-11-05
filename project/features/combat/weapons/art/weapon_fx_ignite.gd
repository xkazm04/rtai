class_name WeaponFxIgnite
extends RefCounted
## n7-ranged (brief item 5, the flamer's ignition read): the first round after the trigger rested
## (FeelCam.IGNITE_IDLE_TICKS, the same rule as the ignition kick) draws the nozzle lick as a big
## flare that shrinks back to the stream's lick over hit_feel.json `ignite_flare_ticks`. View only;
## a weapon with no `ignite_flare_k` (or `--feel=off`) keeps its plain lick.

static var _feel: HitFeel = null
## Per weapon id: the last round seen and the round that lit the stream.
static var _last: Dictionary[StringName, int] = {}
static var _lit: Dictionary[StringName, int] = {}


## The lick scale of `weapon`'s muzzle cell at `tick` for the round fired at `shot_tick`.
static func lick_k(weapon: StringName, shot_tick: int, tick: int, base_k: float) -> float:
	if _feel == null:
		_feel = HitFeel.shipped()
	var flare: Vector2 = _feel.ignite_flare(weapon)
	if flare.x <= 0.0:
		return base_k
	var last: int = _last.get(weapon, -FeelCam.IGNITE_IDLE_TICKS - 1)
	if shot_tick != last:
		if shot_tick - last > FeelCam.IGNITE_IDLE_TICKS:
			_lit[weapon] = shot_tick
		_last[weapon] = shot_tick
	var lit: int = _lit.get(weapon, -1000)
	var since: float = float(tick - lit)
	if since < 0.0 or since >= flare.y:
		return base_k
	return lerpf(flare.x, base_k, since / flare.y)


## Forget the streams (a test); `feel` replaces the shipped table (null = load it on next use).
static func reset(feel: HitFeel = null) -> void:
	_last.clear()
	_lit.clear()
	_feel = feel
