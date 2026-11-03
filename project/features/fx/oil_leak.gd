class_name OilLeak
extends RefCounted
## A hit robot leaks (lane d5-combat): after each hit, for blood_fx.json drip.bleed_ticks, its
## fluid drips one drop every drip.every_px moved (stretched along the move) and one every
## drip.still_ticks standing, so Rivet leaves an oil trail where he walks after a tazer hit.
## Render only: stepped on the sim tick by CombatBlood, no RNG, nothing written to the sim.

var left: int = 0
var drips: int = 0
var _every_px: float = 9.0
var _still: int = 45
var _bleed: int = 360
var _at: Vector2 = Vector2.INF
var _t: int = 0


func _init(drip: Dictionary) -> void:
	_every_px = drip.get("every_px", 9.0)
	_still = drip.get("still_ticks", 45)
	_bleed = drip.get("bleed_ticks", 360)


## A new hit: the leak runs bleed_ticks again from here.
func start() -> void:
	left = _bleed
	_t = 0


## `n` ticks passed with the robot at `px` (Vector2.INF = unknown); drips into `fx`.
func step(n: int, px: Vector2, fx: BloodFx) -> void:
	if left <= 0 or px == Vector2.INF or fx == null:
		return
	left -= n
	_t += n
	if _at == Vector2.INF:
		_at = px
	var move: Vector2 = px - _at
	if move.length() >= _every_px or _t >= _still:
		fx.drip(px, move / maxf(_t, 1.0))
		drips += 1
		_at = px
		_t = 0
