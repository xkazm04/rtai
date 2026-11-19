class_name GhostTail
extends Node2D
## A ribbon of linked ground points. Height is projected separately so the tip returns to ground.

const TEAL: Color = Color(0.18, 0.77, 0.71)

var _row: GhostHoverRow.Tail
var _chain: PackedVector2Array = []
var _vertices: PackedVector2Array = []
var _indices: PackedInt32Array = []
var _colours: PackedColorArray = []
var _height_m: float = 0.0


func _init(row: GhostHoverRow.Tail) -> void:
	_row = row
	@warning_ignore("return_value_discarded")
	_vertices.resize((row.segments + 1) * 2)
	for i: int in row.segments + 1:
		var k: float = float(i) / row.segments
		var ink: Color = Color(TEAL.lerp(Color.WHITE, 0.22 * (1.0 - k)), 0.72 * (1.0 - k))
		_colours.append_array([ink, ink])
		if i < row.segments:
			var j: int = 2 * i
			_indices.append_array([j, j + 1, j + 2, j + 1, j + 3, j + 2])


## root_px is the body-frame anchor already rotated and translated into world pixels.
func step(root_px: Vector2, facing: float, speed_mps: float, lift_m: float, ticks: int) -> void:
	if ticks <= 0:
		return
	var back: Vector2 = -Vector2.from_angle(facing)
	var length_m: float = _row.length_m + speed_mps * _row.stretch_k
	var link: float = length_m * SimConst.PX_PER_M / _row.segments
	if _chain.is_empty():
		for i: int in _row.segments + 1:
			@warning_ignore("return_value_discarded")
			_chain.append(root_px + back * link * i)
	for i: int in ticks:
		_chain[0] = root_px
		for j: int in range(1, _chain.size()):
			var behind: Vector2 = _chain[j - 1].direction_to(_chain[j])
			var dir: Vector2 = back.slerp(behind, _row.swing_k) if behind != Vector2.ZERO else back
			_chain[j] = _chain[j - 1] + dir * link
	_height_m = lift_m
	queue_redraw()


func _draw() -> void:
	if _chain.is_empty():
		return
	var up: Vector2 = ViewMode.shared().lift_px(_height_m)
	var previous_edge: Vector2 = Vector2.ZERO
	for i: int in _chain.size():
		var k: float = float(i) / _row.segments
		var centre: Vector2 = _chain[i] + up * (1.0 - k)
		var before: int = maxi(0, i - 1)
		var after: int = mini(_row.segments, i + 1)
		var axis: Vector2 = _chain[after] - _chain[before] - up * (after - before) / _row.segments
		var width: float = _row.width_m * (1.0 - k) * (1.0 + _row.fray * sin(i * 2.4))
		var edge: Vector2 = axis.normalized().orthogonal() * width * SimConst.PX_PER_M * 0.5
		if edge.dot(previous_edge) < 0.0:
			edge = -edge
		_vertices[2 * i] = centre - edge
		_vertices[2 * i + 1] = centre + edge
		previous_edge = edge
	RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), _indices, _vertices, _colours)
