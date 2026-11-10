class_name PlateShock
extends RefCounted
## n12 C2 (plate misregistration shock): a blast knocks the print's existing off-register plates
## (the D5 overlay's ink ghost `ink_mis`, vermilion pass `verm_mis` and colour plate `plate_mis`)
## a few screen px along the blow, and they settle back over a few ticks. It moves plates that
## exist: no new colour, no luminance flash. One shock in flight and a cooldown after it, so a
## volley of blasts is one shock. The feature side (FeelCam) kicks it from hit_feel.json's
## plate_shock_px / plate_shock_ticks and calls advance() every frame with the sim tick (so a
## hit-stop holds it); LookOverlay adds offset() to its plates. Zero at rest: the plates are the
## params file's own values whenever no shock runs. Render only, no RNG.

## Ticks after a shock ends before another may start (with the shock's own length: about 2 a s).
const COOLDOWN_TICKS: int = 20

static var _start: int = -1
static var _ticks: int = 0
static var _px: float = 0.0
static var _dir: Vector2 = Vector2.ZERO
static var _now: int = 0


## Starts a shock of `px` screen px along `dir` lasting `ticks` from `tick`; false when one is in
## flight or cooling down (the budget: at most one), or the row asks for none.
static func kick(px: float, ticks: int, dir: Vector2, tick: int) -> bool:
	if px <= 0.0 or ticks <= 0 or dir == Vector2.ZERO:
		return false
	if _start >= 0 and tick < _start + _ticks + COOLDOWN_TICKS:
		return false
	_start = tick
	_ticks = ticks
	_px = px
	_dir = dir.normalized()
	_now = tick
	return true


## The view's sim tick, once a frame.
static func advance(tick: int) -> void:
	_now = tick


## The plates' extra offset now (screen px): full on the kick tick, eased back (quadratic) to zero.
static func offset() -> Vector2:
	return offset_at(_now)


static func offset_at(tick: int) -> Vector2:
	if _start < 0:
		return Vector2.ZERO
	var age: int = tick - _start
	if age < 0 or age >= _ticks:
		return Vector2.ZERO
	var k: float = 1.0 - float(age) / float(_ticks)
	return _dir * _px * k * k


static func reset() -> void:
	_start = -1
	_ticks = 0
	_px = 0.0
	_dir = Vector2.ZERO
	_now = 0
