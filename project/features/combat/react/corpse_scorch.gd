class_name CorpseScorch
extends Node2D
## The electro corpse's floor mark (showcase REQUEST 24: a stiff body alone read as a standing
## cop from above): a soot blot along the body, a star of soot burns round it (the current that
## went to ground) and a few smoke puffs that swell and fade over SMOKE_S. A child of the
## CutRig (part px, x = the facing), drawn under every part; it shows while the rig lies stiff
## (CutRig.c_plank) and hides itself when a pooled rig stands again. Render only: no RNG (the
## shape comes from the actor id's hash), never read by the sim (lane human-reactions).

const NAME: StringName = &"Scorch"
const SOOT: Color = Color(0.090, 0.075, 0.106, 0.7)
const CORE: Color = Color(0.090, 0.075, 0.106, 0.55)
const BURN: Color = Color(0.090, 0.075, 0.106, 0.8)
const SMOKE: Color = Color(0.80, 0.78, 0.72, 0.38)
## Inked to read at 48 px/m (REQUEST 24b: 0.5 / 0.32 / 0.5 and 22 px burns did not show).
## The blot runs from FEET_PX past the feet to HEAD_PX past the head (part px), HALF_W across.
const FEET_PX: float = 400.0
const HEAD_PX: float = 280.0
const HALF_W: float = 170.0
const BURNS: int = 11
const BURN_W: float = 32.0
const SMOKE_S: float = 2.4
const Z: int = -20

var _rig: CutRig = null
var _seed: int = 0
var _t0: float = -1.0
var _feet: float = -1.0
var _amount: float = 0.0


## Adds the mark under `rig` once (later calls only find it).
static func ensure(rig: CutRig) -> void:
	if rig.get_node_or_null(NodePath(NAME)) is CorpseScorch:
		return
	var s: CorpseScorch = CorpseScorch.new()
	s.name = NAME
	s._rig = rig
	s._seed = hash(rig.actor_id) & 0xffff
	s.z_index = Z
	s.visible = false
	rig.add_child(s)


func _process(_delta: float) -> void:
	var a: float = _rig.c_plank if _rig != null else 0.0
	if a <= 0.01:
		visible = false
		_t0 = -1.0
		return
	if _t0 < 0.0:
		_t0 = _rig.t_alive
	var smoking: bool = _rig.t_alive - _t0 < SMOKE_S
	if not visible or smoking or absf(a - _amount) > 0.01 or _feet != _rig.plank_feet:
		visible = true
		_amount = a
		_feet = _rig.plank_feet
		queue_redraw()


func _draw() -> void:
	var f: float = _feet
	var mid: float = f * (FEET_PX - HEAD_PX) * 0.5
	var half_l: float = (FEET_PX + HEAD_PX) * 0.5
	draw_colored_polygon(_blot(mid, half_l * _amount, HALF_W * _amount, 0), _a(SOOT))
	draw_colored_polygon(_blot(mid, half_l * 0.6, HALF_W * 0.55, 7), _a(CORE))
	for i: int in BURNS:
		draw_colored_polygon(_burn(i, mid, half_l), _a(BURN))
	_smoke(_rig.t_alive - _t0)


func _a(c: Color) -> Color:
	return Color(c, c.a * _amount)


## An irregular blot (ink edge, not a clean ellipse) centred `mid` along x.
func _blot(mid: float, half_l: float, half_w: float, salt: int) -> PackedVector2Array:
	var pts: PackedVector2Array = []
	@warning_ignore("return_value_discarded")
	pts.resize(20)
	for i: int in 20:
		var ang: float = TAU * i / 20.0
		var wob: float = 0.82 + 0.18 * _n(i + salt * 31)
		pts[i] = Vector2(mid + cos(ang) * half_l * wob, sin(ang) * half_w * wob)
	return pts


## One burn wedge: out of the blot's edge at its own angle, tapering to a bent tip (the floor's
## burn star; thin ink lines from the chest read as an insect's legs).
func _burn(i: int, mid: float, half_l: float) -> PackedVector2Array:
	var ang: float = TAU * (i + 0.6 * _n(i * 7)) / BURNS
	var c: Vector2 = Vector2(cos(ang), sin(ang))
	var base: Vector2 = Vector2(mid + c.x * half_l * 0.85, c.y * HALF_W * 0.85) * _amount
	var dir: Vector2 = Vector2(c.x / half_l, c.y / HALF_W).normalized()
	var side: Vector2 = dir.orthogonal() * BURN_W * (0.7 + 0.6 * _n(i * 11))
	var reach: float = (95.0 + 130.0 * _n(i * 5)) * _amount
	var bend: Vector2 = dir.rotated((_n(i * 13) - 0.5) * 0.9)
	var knee: Vector2 = base + dir * reach * 0.5
	var tip: Vector2 = knee + bend * reach * 0.5
	return [base + side, knee + side * 0.35, tip, knee - side * 0.35, base - side]


func _smoke(age: float) -> void:
	if age >= SMOKE_S:
		return
	var k: float = age / SMOKE_S
	for i: int in 3:
		var at: Vector2 = Vector2((_n(i * 3) - 0.5) * 300.0, (_n(i * 3 + 1) - 0.5) * 160.0)
		at += Vector2(40.0, -60.0) * k * (1.0 + i)
		var r: float = 60.0 + 140.0 * k + 20.0 * i
		draw_circle(at, r, Color(SMOKE, SMOKE.a * (1.0 - k) * (1.0 - k)))


## A stable 0..1 value per index (the actor's hash): the same corpse draws the same mark.
func _n(i: int) -> float:
	var h: int = hash(_seed * 7919 + i * 104729) & 0xffff
	return float(h) / 65535.0
