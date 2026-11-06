class_name ServoShift
extends RefCounted
## Servo's phase transitions on the rig's canvas (docs/bosses/servo.md section 4), in sim ticks,
## render only. Into rush hour (the 2 s invulnerable TRANSITION) he rises on revving pads while
## the rack reloads in a ripple, bay by bay. Into overtime the failing wing (ServoRack.break_wing's
## cells) shakes and spits sparks, blows off in a burst of debris the tick the phase begins, and
## its empty socket smokes for the rest of the fight (he runs hot).

const BURST_TICKS: int = 45
const SPARK: Color = Color(1.0, 0.93, 0.7)

var px: float = 32.0
var _pal: PaletteTokens = PaletteTokens.shared()
var _phase_seen: int = -1
var _phase_at: int = -100000


## Called on every pose: notes the tick a new phase began (the blow-off's clock).
func observe(f: BossFight) -> void:
	if f.phase != _phase_seen:
		if _phase_seen >= 0:
			_phase_at = f.now()
		_phase_seen = f.phase


## 0..1 through the transition into phase `index` (0-based), or -1 outside it.
static func into(f: BossFight, index: int) -> float:
	if f.state != BossFight.State.TRANSITION or f.phase + 1 != index:
		return -1.0
	return clampf(float(f.t) / maxi(f.spec.phases[index].transition, 1), 0.0, 1.0)


## The body's scale: he rises 8 % on his pads into rush hour and settles as it begins.
static func lift_k(f: BossFight) -> float:
	var u: float = into(f, 1)
	return 1.0 + 0.08 * sin(u * PI) if u >= 0.0 else 1.0


## The failing wing's jitter into overtime (metres), growing to the blow-off.
static func shake(f: BossFight) -> Vector2:
	var u: float = into(f, 2)
	if u < 0.0:
		return Vector2.ZERO
	return Vector2(sin(f.now() * 1.7), cos(f.now() * 2.3)) * 0.12 * u


func draw(c: CanvasItem, f: BossFight, rack: ServoRack) -> void:
	var u1: float = into(f, 1)
	if u1 >= 0.0:
		_reload(c, rack, u1)
	var u2: float = into(f, 2)
	if u2 >= 0.0:
		_sparks(c, _socket(rack), f.now(), u2)
	if f.phase >= 2 and f.state != BossFight.State.DEFEATED:
		_burst(c, rack, f.now() - _phase_at)


## The bays light in order, two at a time, across the rack.
func _reload(c: CanvasItem, rack: ServoRack, u: float) -> void:
	var lit: float = u * (rack.state.size() + 2)
	for i: int in rack.state.size():
		if lit >= i and lit < i + 2 and rack.state[i] != ServoRack.Cell.BROKEN:
			c.draw_arc(rack.cell_pos(i) * px, 0.4 * px, 0.0, TAU, 18, _pal.color(&"paper"), 3.0)


func _sparks(c: CanvasItem, at: Vector2, tick: int, u: float) -> void:
	for j: int in 3 + int(u * 5.0):
		var a: float = fmod(tick * 0.9 + j * 2.4, TAU)
		var r0: float = 0.4 + fmod(tick * 0.07 + j * 0.31, 0.6)
		var dir: Vector2 = Vector2.from_angle(a)
		c.draw_line((at + dir * r0) * px, (at + dir * (r0 + 0.35)) * px, SPARK, 2.5)


## The wing's debris flying off at the phase's first tick, then the socket's thin smoke.
func _burst(c: CanvasItem, rack: ServoRack, dt: int) -> void:
	var at: Vector2 = _socket(rack)
	var out: Vector2 = (at - rack.origin).normalized()
	if dt < BURST_TICKS:
		var u: float = float(dt) / BURST_TICKS
		var go: float = 1.0 - (1.0 - u) * (1.0 - u)
		c.draw_arc(at * px, (0.5 + 2.0 * u) * px, 0.0, TAU, 24, Color(SPARK, 1.0 - u), 4.0)
		for j: int in 6:
			var dir: Vector2 = out.rotated((j - 2.5) * 0.32)
			var p: Vector2 = (at + dir * (0.6 + 3.2 * go)) * px
			c.draw_set_transform(p, u * 6.0 * (1.0 if j % 2 == 0 else -1.0))
			var h: Vector2 = Vector2(0.22, 0.15) * px
			c.draw_rect(Rect2(-h, h * 2.0), Color(_pal.color(&"paper_2"), 1.0 - u * 0.5))
			c.draw_rect(Rect2(-h, h * 2.0), _pal.color(&"ink"), false, 1.5)
			c.draw_set_transform(Vector2.ZERO)
	for j: int in 3:
		var ph: float = fmod(dt * 0.015 + j / 3.0, 1.0)
		var col: Color = Color(_pal.color(&"ink"), 0.35 * (1.0 - ph))
		c.draw_circle((at + ServoFall.WIND * ph * 2.0) * px, (0.2 + 0.5 * ph) * px, col)


## The blown wing's centre: the mean of ServoRack.break_wing's cells.
static func _socket(rack: ServoRack) -> Vector2:
	var per_row: int = rack.cols()
	var sum: Vector2 = Vector2.ZERO
	var n: int = 0
	for i: int in rack.state.size():
		if (i % per_row) < per_row * 0.5:
			sum += rack.cell_pos(i)
			n += 1
	return sum / maxi(n, 1)
