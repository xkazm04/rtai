class_name DentSteerMesh
extends Polygon2D
## Subdivide the existing STEER cell so both fists move with the strings. UVs stay on that cell.
## The colour card and apparition outline use identical vertices and their own original materials.

const DIVS: int = 12

var _card: Sprite2D
var _rest: PackedVector2Array = []
var _frame: int = -1
var _mirrored: bool


func _init(card: Sprite2D) -> void:
	_card = card
	card.add_child(self)
	use_parent_material = true
	hide()


func bend(grips: PackedVector2Array, shifts: PackedVector2Array) -> void:
	var active: bool = shifts.size() == 2
	if active != visible:
		visible = active
		_card.self_modulate.a = 0.0 if active else 1.0
	if not active:
		return
	if texture != _card.texture or _frame != _card.frame or _mirrored != _card.flip_h:
		_rebuild(grips)
	var pts: PackedVector2Array = _rest.duplicate()
	for i: int in pts.size():
		var p: Vector2 = _rest[i]
		var left: float = p.distance_to(grips[0])
		var right: float = p.distance_to(grips[1])
		var weight: float = smoothstep(0.0, 1.0, right / (left + right))
		var arm: float = 1.0 - smoothstep(18.0, 73.0, minf(left, right))
		pts[i] += shifts[1].lerp(shifts[0], weight) * arm
	polygon = pts


func _rebuild(grips: PackedVector2Array) -> void:
	texture = _card.texture
	_frame = _card.frame
	_mirrored = _card.flip_h
	var cell: Vector2 = _card.get_rect().size
	var origin: Vector2 = Vector2(_card.frame_coords) * cell
	var texels: PackedVector2Array = []
	_rest.clear()
	var a: Vector2 = grips[0] - _card.offset
	var b: Vector2 = grips[1] - _card.offset
	var xs: PackedFloat32Array = _axis(cell.x, a.x, b.x)
	var ys: PackedFloat32Array = _axis(cell.y, a.y, b.y)
	var faces: Array[PackedInt32Array] = []
	for y: int in ys.size():
		for x: int in xs.size():
			var pt: Vector2 = Vector2(xs[x], ys[y])
			var i: int = _rest.size()
			if x + 1 < xs.size() and y + 1 < ys.size():
				var below: int = i + xs.size()
				faces.append(PackedInt32Array([i, i + 1, below + 1]))
				faces.append(PackedInt32Array([i, below + 1, below]))
			@warning_ignore("return_value_discarded")
			_rest.append(pt + _card.offset)
			if _mirrored:
				pt.x = cell.x - pt.x
			@warning_ignore("return_value_discarded")
			texels.append(origin + pt)
	polygons = faces
	uv = texels


## Put a vertex exactly on each grip, including in profile where the two palms are close.
func _axis(size_px: float, a: float, b: float) -> PackedFloat32Array:
	var coords: PackedFloat32Array = [a]
	if a != b:
		@warning_ignore("return_value_discarded")
		coords.append(b)
	for i: int in DIVS + 1:
		var v: float = float(i) * size_px / DIVS
		if absf(v - a) > 0.5 and absf(v - b) > 0.5:
			@warning_ignore("return_value_discarded")
			coords.append(v)
	coords.sort()
	return coords
