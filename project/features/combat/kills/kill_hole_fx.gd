class_name KillHoleFx
extends Node2D
## The plasma kill (lane brutality, style `hole`), render only. punch() wraps the victim's body
## copy in a clip mask with a round hole at the torso, so the street shows through the body; a
## ring sits on the hole's edge: an ink rim, a hot cream glow that cools over GLOW_TICKS to a
## charred brown, and an inner bright lip. The ring is a child of the body (it falls with it).
## No RNG.

const HOLE_M: float = 0.26
const GLOW_TICKS: int = 150
const MASK_PX: int = 64
const MASK_M: float = 2.0
const INK: Color = Color(0.07, 0.06, 0.07)
const HOT: Color = Color(1.0, 0.96, 0.78)
const COOL: Color = Color(0.3, 0.2, 0.14)
const EMBER: Color = Color("#E9A23B")
## The drop (showcase REQUEST 21): the victim stands LOOK_TICKS after the hit-stop, looking at the
## hole, then falls flat back along the shot over TOPPLE_TICKS (eased in, like a fall). Seen
## straight down, a fall reads as the body laid out along the shot: it slides back FALL_M, stretches
## LIE_STRETCH along the fall line (the head going away from the feet), narrows across it and
## twists a little.
const LOOK_TICKS: int = 3
const TOPPLE_TICKS: int = 12
const FALL_M: float = 0.85
const LIE_STRETCH: float = 0.55
const LIE_NARROW: float = 0.12
const LIE_TWIST: float = 0.35
## The kick (combat-notes, "thrown back along the bolt"): on the hit tick the body snaps KICK_M back
## along the shot, stretched KICK_STRETCH (the bolt's shove), and holds it while it looks; the
## topple then carries it on to FALL_M. Off under --no-plasma-heat.
const KICK_M: float = 0.3
const KICK_STRETCH: float = 0.14
## Smoke out of the burned hole (owner note 2026-11-04: "hot and heavy"): SMOKE_PUFFS ash puffs
## rising out of the ring, each living SMOKE_CYCLE ticks, for SMOKE_TICKS after the hit (0 = none).
const SMOKE_TICKS: int = 300
const SMOKE_PUFFS: int = 5
const SMOKE_CYCLE: int = 48
const SMOKE: Color = Color(0.84, 0.8, 0.74, 0.9)

## The night's throw (the A/B's before, with no smoke).
const OLD_LOOK_TICKS: int = 8
const OLD_FALL_M: float = 0.45

## False (`--no-plasma-heat`): the night's throw and no wound smoke (the A/B's before).
static var heat: bool = not OS.get_cmdline_user_args().has("--no-plasma-heat")
static var _holed: ImageTexture = null

var kills: SignatureKills = null
var tick0: int = 0
var radius_px: float = 4.0


## The body group with a hole punched through its centre (the group's origin is the centroid);
## its one child is the lay node Topple bends, holding the clipped body and the ring.
static func punch(body: Node2D, p_kills: SignatureKills, view_ppm: float) -> Node2D:
	var root: Node2D = Node2D.new()
	root.name = body.name
	var lay: Node2D = Node2D.new()  # the fall's lay-out (Topple), under KillView's placement
	root.add_child(lay)
	var mask: Sprite2D = Sprite2D.new()
	mask.texture = _mask_texture()
	mask.scale = Vector2.ONE * MASK_M * view_ppm / MASK_PX
	mask.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	lay.add_child(mask)
	body.position = Vector2.ZERO
	body.transform = mask.transform.affine_inverse()
	KillSplitFx.flatten(body)
	mask.add_child(body)
	var ring: KillHoleFx = KillHoleFx.new()
	ring.kills = p_kills
	ring.tick0 = p_kills.tick
	ring.radius_px = HOLE_M * view_ppm
	ring.z_index = 30
	lay.add_child(ring)
	return root


## A holed body toppling (KillStyles keeps one per plasma kill).
class Topple:
	extends RefCounted
	var serial: int = 0
	var body: Node2D = null
	var born: int = 0
	var row: SignatureKill = null
	var dir: Vector2 = Vector2.RIGHT

	## After KillView placed the body this frame: `tick` is the sim tick.
	func pose(tick: int, ppm: float) -> void:
		var look: int = LOOK_TICKS if KillHoleFx.heat else OLD_LOOK_TICKS
		var t: float = float(tick - born - row.hitstop_ticks - look) / TOPPLE_TICKS
		var k: float = clampf(t, 0.0, 1.0)
		k *= k  # eased in: slow off balance, fast to the street
		var axis: Vector2 = dir.normalized() if dir != Vector2.ZERO else Vector2.RIGHT
		axis = axis.rotated(-body.rotation)  # into the body's frame (KillView turns it)
		var turn: Transform2D = Transform2D(axis.angle(), Vector2.ZERO)
		var kick: float = 1.0 - k if KillHoleFx.heat and tick >= born else 0.0
		var stretch: float = LIE_STRETCH * k + KICK_STRETCH * kick
		var lay: Transform2D = Transform2D(
			0.0, Vector2(1.0 + stretch, 1.0 - LIE_NARROW * k), 0.0, Vector2.ZERO
		)
		var side: float = -1.0 if axis.y < 0.0 else 1.0
		var twist: Transform2D = Transform2D(side * LIE_TWIST * k, Vector2.ZERO)
		var t2: Transform2D = turn * lay * turn.affine_inverse() * twist
		var inner: Node2D = body.get_child(0) as Node2D if body.get_child_count() > 0 else null
		if inner == null:  # no rig was cut (the city block at 32 px/m): nothing to topple
			return
		var fall: float = FALL_M if KillHoleFx.heat else OLD_FALL_M
		inner.transform = t2.translated(axis * (fall * k + KICK_M * kick) * ppm)


## A white square with a transparent disc in the middle (HOLE_M of MASK_M).
static func _mask_texture() -> ImageTexture:
	if _holed != null:
		return _holed
	var img: Image = Image.create(MASK_PX, MASK_PX, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	var c: Vector2 = Vector2.ONE * (MASK_PX * 0.5 - 0.5)
	var r: float = HOLE_M / MASK_M * MASK_PX
	for y: int in MASK_PX:
		for x: int in MASK_PX:
			if Vector2(x, y).distance_to(c) < r:
				img.set_pixel(x, y, Color(1.0, 1.0, 1.0, 0.0))
	_holed = ImageTexture.create_from_image(img)
	return _holed


func _process(_delta: float) -> void:
	if kills != null and kills.tick - tick0 <= maxi(GLOW_TICKS, SMOKE_TICKS) + 1:
		queue_redraw()


func _draw() -> void:
	var k: float = clampf(float(kills.tick - tick0) / GLOW_TICKS, 0.0, 1.0) if kills else 1.0
	if kills != null:
		_smoke(kills.tick - tick0)
	var glow: Color = HOT.lerp(COOL, k)
	var halo: Color = Color(HOT, 0.55 * (1.0 - k))  # the heat bloom reads at 32 px/m, then cools
	draw_arc(Vector2.ZERO, radius_px * 1.55, 0.0, TAU, 24, halo, radius_px * 0.7, true)
	draw_arc(Vector2.ZERO, radius_px + 2.0, 0.0, TAU, 24, INK, 3.0, true)
	draw_arc(Vector2.ZERO, radius_px, 0.0, TAU, 24, glow, maxf(radius_px * 0.3, 2.0), true)
	# a thin ember lip that never quite goes out, so the hole still reads at 32 px/m once cooled
	draw_arc(Vector2.ZERO, radius_px * 0.82, 0.0, TAU, 24, Color(EMBER, 0.9 - 0.45 * k), 1.5, true)


## The wound smokes: puffs rise out of the hole (the ring's -y), swell and thin, the column
## fading out over SMOKE_TICKS. Phases from the age only: a replay draws the same smoke.
func _smoke(age: int) -> void:
	if age < 0 or age >= SMOKE_TICKS or not heat:
		return
	var fade: float = 1.0 - float(age) / float(SMOKE_TICKS)
	for i: int in SMOKE_PUFFS:
		var p: float = float((age + i * SMOKE_CYCLE / SMOKE_PUFFS) % SMOKE_CYCLE) / SMOKE_CYCLE
		var sway: float = sin(float(age) * 0.07 + float(i) * 2.1) * radius_px * 0.5
		var at: Vector2 = Vector2(sway, -p * radius_px * 5.0)
		var a: float = SMOKE.a * (1.0 - p) * fade
		var r: float = radius_px * (0.6 + 1.3 * p)
		draw_circle(at, r, Color(SMOKE, a))
		draw_arc(at, r, 0.0, TAU, 16, Color(INK, a * 0.8), 1.5, true)
