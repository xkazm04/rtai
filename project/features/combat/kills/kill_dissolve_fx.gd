class_name KillDissolveFx
extends Node2D
## The ray gun kill (lane brutality, style `dissolve`), render only. wrap() puts the victim's body
## copy under a round clip mask; the body glows stiff for row.stand_ticks, then the mask shrinks
## over row.crumble_ticks, so the body is eaten from its outline inward by a hot cream ring while
## echo rings ripple outward and fade. Glowing motes fall onto a dust pile that is left with the
## empty uniform (a crumpled blue cloth) and the cap (the row's hat piece) lying on it. Timings
## against the sim tick, shapes from a hash of the kill serial: no dice, a replay shows the same.

const INK: Color = Color(0.07, 0.06, 0.07)
const HOT: Color = Color(1.0, 0.96, 0.78)
const GOLD: Color = Color("#E9A23B")
const DUST: Color = Color("#C9B98F")
const CLOTH: Color = Color("#2C4E86")
const CLOTH_DARK: Color = Color("#1B2F55")
const MASK_PX: int = 64
## The mask's starting radius (metres): the whole posed body fits inside.
const BODY_R_M: float = 0.62
const PILE_M: float = 0.42
const ECHOES: int = 3
const MOTES: int = 26

static var _disc: ImageTexture = null


class Dissolve:
	extends RefCounted
	var serial: int = 0
	var root: Node2D = null
	var row: SignatureKill = null
	var born: int = 0
	var at: Vector2 = Vector2.ZERO


var kills: SignatureKills = null
var ppm: float = 32.0
var reduced_motion: bool = false
var _all: Array[Dissolve] = []


## The body group under a round clip mask (the group's origin is the body's centroid).
static func wrap(body: Node2D) -> Node2D:
	var root: Node2D = Node2D.new()
	root.name = body.name
	var mask: Sprite2D = Sprite2D.new()
	mask.texture = _disc_texture()
	mask.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	mask.name = "mask"
	root.add_child(mask)
	body.position = Vector2.ZERO
	KillSplitFx.flatten(body)
	mask.add_child(body)
	return root


static func _disc_texture() -> ImageTexture:
	if _disc != null:
		return _disc
	var img: Image = Image.create(MASK_PX, MASK_PX, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 1.0, 1.0, 0.0))
	var c: Vector2 = Vector2.ONE * (MASK_PX * 0.5 - 0.5)
	for y: int in MASK_PX:
		for x: int in MASK_PX:
			if Vector2(x, y).distance_to(c) < MASK_PX * 0.5 - 0.5:
				img.set_pixel(x, y, Color.WHITE)
	_disc = ImageTexture.create_from_image(img)
	return _disc


func add(serial: int, root: Node2D, row: SignatureKill, at: Vector2) -> void:
	var d: Dissolve = Dissolve.new()
	d.serial = serial
	d.root = root
	d.row = row
	d.born = kills.tick
	d.at = at
	_all.append(d)


func forget(serial: int) -> void:
	_all = _all.filter(func(d: Dissolve) -> bool: return d.serial != serial)


## After KillView placed the bodies: the mask shrinks (its child undoes the scale).
func pose() -> void:
	for d: Dissolve in _all:
		var mask: Sprite2D = d.root.get_node_or_null("mask") as Sprite2D
		if mask == null:
			continue
		var r: float = BODY_R_M * ppm * (1.0 - _eat(d))
		mask.scale = Vector2.ONE * maxf(r * 2.0, 0.01) / MASK_PX
		var body: Node2D = mask.get_child(0) as Node2D
		body.transform = mask.transform.affine_inverse()
		mask.visible = r > 0.5
	if not _all.is_empty():
		queue_redraw()


## 0 while the body stands glowing, rising to 1 as the rings eat it.
func _eat(d: Dissolve) -> float:
	var t0: int = d.born + d.row.hitstop_ticks + d.row.stand_ticks
	return clampf(float(kills.tick - t0) / maxf(1.0, float(d.row.crumble_ticks)), 0.0, 1.0)


func _draw() -> void:
	for d: Dissolve in _all:
		var e: float = _eat(d)
		var c: Vector2 = d.root.position
		_pile(d, e)
		if e < 1.0:
			_rings(d, c, e)
		_motes(d, c, e)


## The glow on the eating edge plus echo rings rippling outward (none under reduced motion).
func _rings(d: Dissolve, c: Vector2, e: float) -> void:
	var r: float = BODY_R_M * ppm * (1.0 - e)
	var age: int = kills.tick - d.born
	var pulse: float = 1.0 if reduced_motion else 0.8 + 0.2 * sin(float(age) * 0.7)
	if e <= 0.0:  # the stiff glow before the rings start
		draw_arc(c, r * 0.9, 0.0, TAU, 32, Color(HOT, 0.35 * pulse), r * 0.35, true)
		return
	draw_arc(c, r + 2.0, 0.0, TAU, 32, INK, 3.5, true)
	draw_arc(c, r, 0.0, TAU, 32, Color(HOT, pulse), maxf(0.07 * ppm, 2.0), true)
	if reduced_motion:
		return
	for n: int in ECHOES:
		var k: float = fposmod(e * 3.0 + float(n) / ECHOES, 1.0)
		var er: float = r + k * 0.7 * ppm
		draw_arc(c, er, 0.0, TAU, 32, Color(GOLD, 0.6 * (1.0 - k)), 0.035 * ppm * (1.0 - k) + 1.0)


## The dust heap grows with the eating; the empty uniform lies crumpled on it.
func _pile(d: Dissolve, e: float) -> void:
	var g: float = clampf(e * 1.4, 0.0, 1.0)
	if g <= 0.0:
		return
	var p: Vector2 = d.at * ppm
	var cloth: PackedVector2Array = PackedVector2Array()
	for n: int in 9:
		var a: float = TAU * float(n) / 9.0
		var rr: float = (0.2 + 0.1 * _h(d.serial, n)) * ppm * g
		@warning_ignore("return_value_discarded")
		cloth.append(p + Vector2(cos(a) * rr * 1.3, sin(a) * rr * 0.8))
	draw_circle(p, PILE_M * ppm * g + 1.5, INK)
	draw_circle(p, PILE_M * ppm * g, DUST)
	KillPoly.fill(self, cloth, CLOTH)
	@warning_ignore("return_value_discarded")
	cloth.append(cloth[0])
	draw_polyline(cloth, INK, 2.0, true)
	draw_line(
		p + Vector2(-0.22, 0.02) * ppm * g, p + Vector2(0.2, -0.04) * ppm * g, CLOTH_DARK, 3.0
	)
	var glow: float = clampf(1.6 - e * 0.6 - float(kills.tick - d.born) / 900.0, 0.25, 1.0)
	for n: int in 14:  # the dust still glows, cooling slowly to a faint shimmer
		var o: Vector2 = Vector2.from_angle(_h(d.serial, n + 50) * TAU) * _h(d.serial, n + 90)
		draw_circle(p + o * PILE_M * ppm * g, 0.025 * ppm + 1.0, Color(HOT, glow))


## Glowing motes shed off the eating edge, falling to the pile.
func _motes(d: Dissolve, c: Vector2, e: float) -> void:
	if e <= 0.0 or e >= 1.0 or reduced_motion:
		return
	var r: float = BODY_R_M * ppm * (1.0 - e)
	var age: int = kills.tick - d.born
	for n: int in MOTES:
		var a: float = _h(d.serial, n + 200) * TAU + float(age) * 0.02
		var k: float = fposmod(_h(d.serial, n + 300) + float(age) / 40.0, 1.0)
		var at: Vector2 = c + Vector2.from_angle(a) * r * (1.0 - k * 0.6)
		draw_circle(at, (0.03 * ppm + 1.0) * (1.0 - k), Color(GOLD.lerp(HOT, k), 1.0 - k))


static func _h(serial: int, key: int) -> float:
	return fposmod(sin(float(serial) * 12.9898 + float(key) * 78.233) * 43758.5453, 1.0)
