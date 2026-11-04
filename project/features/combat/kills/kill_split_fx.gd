class_name KillSplitFx
extends Node2D
## The blade kill (lane brutality, style `split`: katana), render only. cut() copies the posed
## victim twice, each copy masked to one side of the cut line (a half-plane Polygon2D that clips
## its children), so each half is the real cop in the D5 print with a clean straight edge; a raw
## red band with an ink lip runs along each edge. The node itself draws the blade's path: a cream
## slash streak with an ink rim along the cut that thins out over STREAK_TICKS. No RNG.
## A row with grind_ticks (the chainsaw) plays the grind instead of the streak: the halves held
## together (GibSim.wait) shake on a hash of the tick while blood spurts and cream sparks fly off
## the saw's bite, then the halves fall apart.

const STREAK_TICKS: int = 12
const STREAK_M: float = 1.7
const EDGE_M: float = 0.34
const INK: Color = Color(0.07, 0.06, 0.07)
const CREAM: Color = Color(0.96, 0.92, 0.8)
const RAW: Color = Color(0.62, 0.05, 0.06)
const SHAKE_M: float = 0.035
## The held body's z during the grind (over Rivet's rig parts, which reach +30).
const HELD_Z: int = 40
## The grind's spurts: drops per tick, how long a drop flies (ticks), its speed (m/s).
const DROPS: int = 3
const DROP_LIFE: int = 16
const DROP_MPS: Vector2 = Vector2(2.2, 5.0)


class Grind:
	extends RefCounted
	var halves: Array[Node2D] = []
	var at: Vector2 = Vector2.ZERO
	var dir: Vector2 = Vector2.RIGHT
	var born: int = 0
	var ticks: int = 0


static var _white: ImageTexture = null

var kills: SignatureKills = null
var ppm: float = 32.0
var reduced_motion: bool = false
## serial -> Vector4(at.x, at.y, cut angle, kill tick), metres.
var _streaks: Dictionary[int, Vector4] = {}
var _grinds: Dictionary[int, Grind] = {}


## The two halves of `rig` cut along `cut` (unit, world): groups by SignatureKill.PIECE_IDS,
## only HALF_A and HALF_B filled, each centred where its piece starts (SignatureKills offsets).
## `hot`: a cauterising blade (the plasma sword): the edges glow instead of showing raw red.
static func cut(rig: CutRig, cut_dir: Vector2, view_ppm: float, hot: bool = false) -> Array[Node2D]:
	var out: Array[Node2D] = []
	@warning_ignore("return_value_discarded")
	out.resize(SignatureKill.PIECE_IDS.size())
	var offs: PackedVector2Array = SignatureKills.split_offsets(cut_dir)
	for p: int in [SignatureKill.HALF_A, SignatureKill.HALF_B]:
		var root: Node2D = Node2D.new()
		root.name = SignatureKill.PIECE_IDS[p]
		var o: Vector2 = -offs[p] * view_ppm  # the body's centre in the half's space
		var side: Vector2 = offs[p].normalized()
		var mask: Sprite2D = _mask(o, cut_dir, side, view_ppm)
		root.add_child(mask)
		var parts: Array[Node2D] = GibCut.cut(rig, true)
		var body: Node2D = parts[SignatureKill.BODY]
		for g: Node2D in parts:
			if g != body:
				g.free()
		body.position += o
		body.transform = mask.transform.affine_inverse() * body.transform  # undo the stretch
		flatten(body)
		mask.add_child(body)
		var lip: KillCutEdge = KillCutEdge.new()
		lip.a = o - cut_dir * EDGE_M * view_ppm
		lip.b = o + cut_dir * EDGE_M * view_ppm
		lip.side = side
		lip.hot = hot
		lip.z_index = 30
		root.add_child(lip)
		out[p] = root
	return out


## A clip mask only holds children on its own z: the copies' z order becomes tree order.
static func flatten(body: Node2D) -> void:
	var parts: Array[Node] = body.get_children()
	parts.sort_custom(
		func(x: Node, y: Node) -> bool: return (x as CanvasItem).z_index < (y as CanvasItem).z_index
	)
	for i: int in parts.size():
		body.move_child(parts[i], i)
		(parts[i] as CanvasItem).z_index = 0


## A half-plane (2 m deep) on `side` of the line through `o` along `cut_dir`, clipping its children.
## (A white sprite stretched over the half-plane: a Polygon2D clipped nothing in the 4.7 print.)
static func _mask(o: Vector2, cut_dir: Vector2, side: Vector2, view_ppm: float) -> Sprite2D:
	if _white == null:
		var img: Image = Image.create(2, 2, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)
		_white = ImageTexture.create_from_image(img)
	var m: Sprite2D = Sprite2D.new()
	m.texture = _white
	m.centered = false
	var l: float = 2.0 * view_ppm
	var up: float = 1.0 if side.dot(cut_dir.rotated(PI * 0.5)) > 0.0 else -1.0
	m.rotation = cut_dir.angle()
	m.scale = Vector2(l, l * 0.5 * up)  # the 2 px texture: 2l along the cut, l deep
	m.position = o - cut_dir * l
	m.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	return m


func add(
	serial: int, at: Vector2, cut_dir: Vector2, row: SignatureKill, parts: Array[Node2D]
) -> void:
	if row.grind_ticks <= 0:
		_streaks[serial] = Vector4(at.x, at.y, cut_dir.angle(), kills.tick)
		return
	var g: Grind = Grind.new()
	for p: int in [SignatureKill.HALF_A, SignatureKill.HALF_B]:
		if p < parts.size() and parts[p] != null:
			g.halves.append(parts[p])
	g.at = at
	g.dir = cut_dir
	g.born = kills.tick
	g.ticks = row.hitstop_ticks + row.grind_ticks
	_grinds[serial] = g


func forget(serial: int) -> void:
	@warning_ignore("return_value_discarded")
	_streaks.erase(serial)
	@warning_ignore("return_value_discarded")
	_grinds.erase(serial)


## After KillView placed the halves: a grinding body shakes in one piece.
func pose() -> void:
	for serial: int in _grinds.keys():
		var g: Grind = _grinds[serial]
		var age: int = kills.tick - g.born
		for half: Node2D in g.halves:  # held on the saw: over Rivet's claws, then back down
			half.z_index = HELD_Z if age < g.ticks else 0
		if age < 0 or age >= g.ticks or reduced_motion:
			continue
		var amp: float = SHAKE_M * ppm
		var off: Vector2 = Vector2(_h(serial, age) - 0.5, _h(serial, age + 300) - 0.5) * 2.0 * amp
		var turn: float = (_h(serial, age + 700) - 0.5) * 0.12
		for half: Node2D in g.halves:
			half.position += off
			half.rotation += turn
	if not _streaks.is_empty() or not _grinds.is_empty():
		queue_redraw()


func _draw() -> void:
	for serial: int in _grinds.keys():
		_draw_grind(serial, _grinds[serial])
	for serial: int in _streaks.keys():
		var s: Vector4 = _streaks[serial]
		var age: int = kills.tick - int(s.w)
		if age < 0 or age > STREAK_TICKS:
			continue
		var k: float = 1.0 - float(age) / float(STREAK_TICKS)
		var c: Vector2 = Vector2.from_angle(s.z)
		var mid: Vector2 = Vector2(s.x, s.y) * ppm
		var half: float = STREAK_M * 0.5 * ppm
		var lead: Vector2 = c * half * (0.6 + 0.4 * (1.0 - k))  # the streak runs on with the blade
		var w: float = 0.11 * ppm * k
		draw_line(mid - c * half, mid + lead, INK, w + 3.0, true)
		draw_line(mid - c * half * 0.8, mid + lead * 0.95, CREAM, w, true)


## The saw's bite: blood drops spurting out of the cut (each born on a tick, flying
## DROP_LIFE ticks) and short cream sparks off the chain, for the grind and a little after.
func _draw_grind(serial: int, g: Grind) -> void:
	var age: int = kills.tick - g.born
	if age < 0 or age > g.ticks + DROP_LIFE:
		return
	var bite: Vector2 = (g.at - g.dir * 0.12) * ppm
	var back: float = g.dir.angle()  # out through the body, away from the saw (Rivet hides behind)
	for born: int in range(maxi(0, age - DROP_LIFE), mini(age, g.ticks) + 1):
		var t: float = float(age - born) / 60.0
		for j: int in DROPS:
			var key: int = born * DROPS + j
			var a: float = back + (_h(serial, key + 1100) - 0.5) * 2.8
			var sp: float = lerpf(DROP_MPS.x, DROP_MPS.y, _h(serial, key + 1900))
			var p: Vector2 = bite + Vector2.from_angle(a) * sp * t * ppm * (1.0 - t * 1.2)
			var r: float = (0.06 + 0.05 * _h(serial, key + 2600)) * ppm * (1.0 - t * 2.0)
			if r > 0.6:
				draw_circle(p, r + 1.2, INK)
				draw_circle(p, r, RAW)
	if age < g.ticks:
		for j: int in 4:
			var a: float = g.dir.angle() + PI * 0.5 + (_h(serial, age * 4 + j + 4000) - 0.5) * 2.2
			var s: Vector2 = Vector2.from_angle(a) * (0.18 + 0.3 * _h(serial, age * 4 + j)) * ppm
			draw_line(bite, bite + s, CREAM, 0.035 * ppm, true)


## A hash in [0, 1) of the serial and a key (the shake and the drops: no dice in render).
static func _h(serial: int, key: int) -> float:
	return fposmod(sin(float(serial) * 12.9898 + float(key) * 78.233) * 43758.5453, 1.0)
