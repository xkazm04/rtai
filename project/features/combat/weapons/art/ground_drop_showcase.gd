class_name GroundDropShowcase
extends RefCounted
## The dead guard's rifle uses the floor pickup drawing at this pitch.
## BODY_GAP measures from the opaque resting pose to the nearest edge of the pickup.
const ON: bool = true
const PICKUP: StringName = &"assault-rifle"
const VERTICAL_X: float = 0.05
const PAST_M: float = 0.75
const SIDE_M: float = 0.6
const MATCH_M: float = 1.5
const LATCH: bool = true
const LATCH_MAX: int = 256

static var _outlines: Dictionary[String, PackedVector2Array] = {}
static var _showcase: WeaponShowcase = null
static var _art: StringName = &""
static var _lies: Dictionary[Vector4, Vector2] = {}


static func texture() -> Texture2D:
	var form: String = WeaponShowcase.form_of(ViewMode.shared())
	if not ON or form == "":
		return null
	if _showcase == null:
		_showcase = WeaponShowcase.new()
		_art = ArsenalTable.shipped().art_id(PICKUP)
	return _showcase.texture(_art, form)


static func draw(ci: CanvasItem, at: Vector2, shot: Vector2, length_m: float) -> bool:
	var tex: Texture2D = texture()
	if tex == null:
		return false
	var lies: Vector2 = lies_at(at, shot, ci, tex)
	var gk: float = maxf(ViewMode.shared().ground_k(), 0.1)
	var k: float = length_m * Ink.PX_PER_M / float(tex.get_width())
	var size: Vector2 = Vector2(tex.get_width() * k, tex.get_height() * k / gk)
	var px: Vector2 = Ink.px(lies)
	ci.draw_set_transform(px + GroundRifle.SHADOW_OFF, 0.0, Vector2(sign_x(shot), 1.0))
	ci.draw_texture_rect(tex, Rect2(-size * 0.5, size), false, Color(0, 0, 0, GroundRifle.SHADOW.a))
	ci.draw_set_transform(px, 0.0, Vector2(sign_x(shot), 1.0))
	ci.draw_texture_rect(tex, Rect2(-size * 0.5, size), false)
	ci.draw_set_transform_matrix(Transform2D.IDENTITY)
	return true


## With a canvas, use its resting corpse. A null canvas selects the legacy drop-point offsets.
static func lies_at(
	at: Vector2, shot: Vector2, ci: CanvasItem = null, tex: Texture2D = null
) -> Vector2:
	var key: Vector4 = Vector4(at.x, at.y, shot.x, shot.y)
	if LATCH and _lies.has(key):
		return _lies[key]
	if _lies.size() >= LATCH_MAX:  # a long session's old drops (they decay long before)
		_lies.clear()
	_lies[key] = (
		settled(ci, at, shot, tex) if GroundRifle.BODY_GAP and ci != null else place(at, shot)
	)
	return _lies[key]


static func place(at: Vector2, shot: Vector2) -> Vector2:
	var segment: PackedVector2Array = body_segment(at)
	if segment.size() == 2:
		return at - segment[0].direction_to(segment[1]) * PAST_M
	var side: Vector2 = shot.normalized().orthogonal()
	if side.y < 0.0 or (is_zero_approx(side.y) and side.x < 0.0):
		side = -side
	return at + side * SIDE_M


static func body_segment(at: Vector2) -> PackedVector2Array:
	var best: float = MATCH_M
	var segment: PackedVector2Array = [at]
	for r: Vector4 in StreetDeadRests.all.values():
		var feet: Vector2 = Vector2(r.x, r.y) / Ink.PX_PER_M
		var chest: Vector2 = Vector2(r.z, r.w) / Ink.PX_PER_M
		if feet.distance_to(at) < best and chest != feet:
			best = feet.distance_to(at)
			segment = [feet, chest]
	return segment


static func sign_x(shot: Vector2) -> float:
	return -1.0 if shot.x < -VERTICAL_X else 1.0


## Measure each alpha silhouette once. Keep the body, excluding detached sparks and headgear.
static func _outline(tex: Texture2D, grid: Vector2i, frame: Vector2i) -> PackedVector2Array:
	var key: String = "%s:%s:%s" % [tex.get_rid(), grid, frame]
	if not _outlines.has(key):
		var image: Image = tex.get_image()
		if image.is_compressed():
			@warning_ignore("return_value_discarded")
			image.decompress()
		@warning_ignore("integer_division")
		var size: Vector2i = image.get_size() / grid
		var bits: BitMap = BitMap.new()
		bits.create_from_image_alpha(image.get_region(Rect2i(size * frame, size)), 0.5)
		var largest: PackedVector2Array = [Vector2.ZERO]
		var area: float = 0.0
		for poly: PackedVector2Array in bits.opaque_to_polygons(Rect2i(Vector2i.ZERO, size), 1.0):
			var twice_area: float = 0.0
			for i: int in poly.size():
				twice_area += poly[i - 1].cross(poly[i])
			if absf(twice_area) > area:
				area = absf(twice_area)
				largest = poly
		_outlines[key] = Transform2D(0.0, -Vector2(size) * 0.5) * largest
	return _outlines[key]


static func _gun(tex: Texture2D, at: Vector2, shot: Vector2) -> PackedVector2Array:
	if tex != null:
		var k: float = GroundRifle.LENGTH_M / tex.get_width()
		var flip: Vector2 = Vector2(sign_x(shot), 1.0) * k
		return Transform2D.IDENTITY.scaled(flip) * _outline(tex, Vector2i.ONE, Vector2i.ZERO)
	var i: int = GroundRifle.heading(GroundRifle.turn(at))
	var grid: Vector2i = Vector2i(GroundRifle.HEADINGS, 1)
	if GroundRifle.sheet() != null:
		var k: float = GroundRifle.LENGTH_M / GroundRifle.DRAWN_LEN_PX
		return (
			Transform2D.IDENTITY.scaled(Vector2.ONE * k)
			* _outline(GroundRifle.sheet(), grid, Vector2i(i, 0))
		)
	var tip: Vector2 = Vector2.from_angle(GroundRifle.turn(at)) * GroundRifle.LENGTH_M * 0.5
	return [-tip, tip]


static func settled(ci: CanvasItem, at: Vector2, shot: Vector2, tex: Texture2D) -> Vector2:
	var squash: Vector2 = Vector2(1.0, ViewMode.shared().ground_k())
	var body: PackedVector2Array = _signature(ci, at)
	if body.is_empty():
		body = body_segment(at)
	var projected: PackedVector2Array = Transform2D.IDENTITY.scaled(squash) * body
	return GroundRifle.beside(projected, _gun(tex, at, shot), shot * squash) / squash


## The kill's mark records the same victim position as the drop. Read its final grid cell
## and slide at first draw, so a settling corpse never makes a landed pickup jump.
static func _signature(ci: CanvasItem, at: Vector2) -> PackedVector2Array:
	var layer: CanvasLayer = ci.get_canvas_layer_node()
	if layer == null:
		return []
	var cast: CastView
	for node: Node in layer.get_children():
		if node is CastView:
			cast = node
		if node is KillView:
			var view: KillView = node
			for d: KillNewStyles.Death in view.styles.new_fx._deaths:
				var ground: KillGround = view._grounds.get(d.serial)
				if ground != null and ground.mark.at.is_equal_approx(at) and d.cells != null:
					return _rest(ci, view, d)
	if cast != null and cast.stage != null and (not cast.fighters_on_rigs or QuestGuardCast.ON):
		for h: Fighter in cast.stage.arena.hostiles:
			if h.pos.is_equal_approx(at) and not h.alive() and h.kind != Fighter.Kind.BOSS:
				return _quest(h)
	return []


static func _quest(h: Fighter) -> PackedVector2Array:
	var tex: Texture2D = StreetQuestDeadPlan._strip()
	if StreetQuestDeadPlan.ENABLED and ViewMode.shared().cards and tex != null:
		var at: Vector2 = Ink.px(h.pos)
		var pose: int = StreetDeadPlan.pick(StreetQuestDeadPlan.ID_BASE - h.id, &"", at)
		var grid: Vector2i = Vector2i(StreetDeadPlan.POSES, 1)
		var xf: Transform2D = StreetQuestDeadPlan.transform_of(at, h, Ink.PX_PER_M)
		return xf.scaled(Vector2.ONE / Ink.PX_PER_M) * _outline(tex, grid, Vector2i(pose, 0))
	tex = QuestArt.shared().texture(&"guard_down")
	var scale: Vector2 = Vector2(1.6, 1.6) / tex.get_size()  # CastView's guard_down draw size
	return (
		Transform2D(h.facing.angle() + PI * 0.5, scale, 0.0, h.pos)
		* _outline(tex, Vector2i.ONE, Vector2i.ZERO)
	)


static func _rest(ci: CanvasItem, view: KillView, d: KillNewStyles.Death) -> PackedVector2Array:
	var c: Sprite2D = d.cells
	var last: int = c.vframes - 1
	var angle: float = KillDeathCells.face_of(d, last) if KillDeathCells.owns(c) else d.fall.angle()
	if d.row.style == &"stitch":
		angle = KillStitchArt.facing(d, 2147483647)
	var face: Vector2i = RigHeadCard.frame_of(angle)
	var grid: Vector2i = Vector2i(c.hframes, c.vframes)
	var shape: PackedVector2Array = _outline(c.texture, grid, Vector2i(face.x, last))
	var scale: Vector2 = c.get_meta(KillDeathCells.BASE, c.get_meta(StreetFallFit.BASE, c.scale))
	scale.x *= -1.0 if face.y == 1 else 1.0
	var slide: Vector2 = d.dir * KillDeathCells.slide_m_of(d) * view.ppm
	if d.row.style == &"pin":
		slide += KillPinArt.shift(d, 2147483647, view.ppm)
	var xf: Transform2D = (
		ci.get_global_transform_with_canvas().affine_inverse()
		* d.root.get_global_transform_with_canvas().scaled_local(Vector2.ONE / d.root.scale)
	)
	var local: Transform2D = Transform2D(0.0, scale, 0.0, c.position + slide)
	return xf.scaled(Vector2.ONE / Ink.PX_PER_M) * local * shape
