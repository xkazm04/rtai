class_name KillHoleFx
extends Node2D
## The plasma kill (lane brutality, style `hole`), render only. punch() wraps the victim's body
## copy in a clip mask with a round hole at the torso, so the street shows through the body; a
## ring sits on the hole's edge: an ink rim, a hot cream glow that cools over GLOW_TICKS to a
## charred brown, and an inner bright lip. The ring is a child of the body (it falls with it).
## No RNG.

const HOLE_M: float = 0.2
const GLOW_TICKS: int = 90
const MASK_PX: int = 64
const MASK_M: float = 2.0
const INK: Color = Color(0.07, 0.06, 0.07)
const HOT: Color = Color(1.0, 0.96, 0.78)
const COOL: Color = Color(0.3, 0.2, 0.14)

static var _holed: ImageTexture = null

var kills: SignatureKills = null
var tick0: int = 0
var radius_px: float = 4.0


## The body group with a hole punched through its centre (the group's origin is the centroid).
static func punch(body: Node2D, p_kills: SignatureKills, view_ppm: float) -> Node2D:
	var root: Node2D = Node2D.new()
	root.name = body.name
	var mask: Sprite2D = Sprite2D.new()
	mask.texture = _mask_texture()
	mask.scale = Vector2.ONE * MASK_M * view_ppm / MASK_PX
	mask.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	root.add_child(mask)
	body.position = Vector2.ZERO
	body.transform = mask.transform.affine_inverse()
	KillSplitFx.flatten(body)
	mask.add_child(body)
	var ring: KillHoleFx = KillHoleFx.new()
	ring.kills = p_kills
	ring.tick0 = p_kills.tick
	ring.radius_px = HOLE_M * view_ppm
	ring.z_index = 30
	root.add_child(ring)
	return root


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
	if kills != null and kills.tick - tick0 <= GLOW_TICKS + 1:
		queue_redraw()


func _draw() -> void:
	var k: float = clampf(float(kills.tick - tick0) / GLOW_TICKS, 0.0, 1.0) if kills else 1.0
	var glow: Color = HOT.lerp(COOL, k)
	var halo: Color = Color(HOT, 0.55 * (1.0 - k))  # the heat bloom reads at 32 px/m, then cools
	draw_arc(Vector2.ZERO, radius_px * 1.55, 0.0, TAU, 24, halo, radius_px * 0.7, true)
	draw_arc(Vector2.ZERO, radius_px + 2.0, 0.0, TAU, 24, INK, 3.0, true)
	draw_arc(Vector2.ZERO, radius_px, 0.0, TAU, 24, glow, maxf(radius_px * 0.3, 2.0), true)
