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
	var faces: Array[PackedInt32Array] = []
	for y: int in DIVS:
		for x: int in DIVS:
			var i: int = y * (DIVS + 1) + x
			faces.append(PackedInt32Array([i, i + 1, i + DIVS + 2, i + DIVS + 1]))
	polygons = faces


func bend(grips: PackedVector2Array, shifts: PackedVector2Array) -> void:
	var active: bool = shifts.size() == 2
	if active != visible:
		visible = active
		_card.self_modulate.a = 0.0 if active else 1.0
	if not active:
		return
	if texture != _card.texture or _frame != _card.frame or _mirrored != _card.flip_h:
		_rebuild()
	var pts: PackedVector2Array = _rest.duplicate()
	for i: int in pts.size():
		var p: Vector2 = _rest[i]
		for hand: int in 2:
			var weight: float = 1.0 - smoothstep(20.0, 73.0, p.distance_to(grips[hand]))
			pts[i] += shifts[hand] * weight
	polygon = pts


func _rebuild() -> void:
	texture = _card.texture
	_frame = _card.frame
	_mirrored = _card.flip_h
	var cell: Vector2 = _card.get_rect().size
	var origin: Vector2 = Vector2(_card.frame_coords) * cell
	var texels: PackedVector2Array = []
	_rest.clear()
	for y: int in DIVS + 1:
		for x: int in DIVS + 1:
			var pt: Vector2 = Vector2(x, y) * cell / DIVS
			@warning_ignore("return_value_discarded")
			_rest.append(pt + _card.offset)
			if _mirrored:
				pt.x = cell.x - pt.x
			@warning_ignore("return_value_discarded")
			texels.append(origin + pt)
	uv = texels
