class_name KillSplitFx
extends Node2D
## The blade kill (lane brutality, style `split`: katana), render only. cut() copies the posed
## victim twice, each copy masked to one side of the cut line (a half-plane Polygon2D that clips
## its children), so each half is the real cop in the D5 print with a clean straight edge; a raw
## red band with an ink lip runs along each edge. The node itself draws the blade's path: a cream
## slash streak with an ink rim along the cut that thins out over STREAK_TICKS. No RNG.

const STREAK_TICKS: int = 12
const STREAK_M: float = 1.7
const EDGE_M: float = 0.34
const INK: Color = Color(0.07, 0.06, 0.07)
const CREAM: Color = Color(0.96, 0.92, 0.8)
const RAW: Color = Color(0.62, 0.05, 0.06)

static var _white: ImageTexture = null

var kills: SignatureKills = null
var ppm: float = 32.0
## serial -> Vector4(at.x, at.y, cut angle, kill tick), metres.
var _streaks: Dictionary[int, Vector4] = {}


## The two halves of `rig` cut along `cut` (unit, world): groups by SignatureKill.PIECE_IDS,
## only HALF_A and HALF_B filled, each centred where its piece starts (SignatureKills offsets).
static func cut(rig: CutRig, cut_dir: Vector2, view_ppm: float) -> Array[Node2D]:
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
		_flatten(body)
		mask.add_child(body)
		var lip: KillCutEdge = KillCutEdge.new()
		lip.a = o - cut_dir * EDGE_M * view_ppm
		lip.b = o + cut_dir * EDGE_M * view_ppm
		lip.side = side
		lip.z_index = 30
		root.add_child(lip)
		out[p] = root
	return out


## A clip mask only holds children on its own z: the copies' z order becomes tree order.
static func _flatten(body: Node2D) -> void:
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


func add(serial: int, at: Vector2, cut_dir: Vector2) -> void:
	_streaks[serial] = Vector4(at.x, at.y, cut_dir.angle(), kills.tick)


func forget(serial: int) -> void:
	@warning_ignore("return_value_discarded")
	_streaks.erase(serial)


func pose() -> void:
	if not _streaks.is_empty():
		queue_redraw()


func _draw() -> void:
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
