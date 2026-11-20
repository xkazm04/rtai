class_name DentGlass
extends Node2D
## Pale splinters drift from the belt to the ribbon tip. Phases come from sim ticks only.

const PPM: float = SimConst.PX_PER_M
const INK: Color = Color("#173c40")
const GLASS: Color = Color("#b5fff2")
const SHAPE: PackedVector2Array = [
	Vector2(-0.58, 0), Vector2(0.12, -0.56), Vector2(0.42, 0), Vector2(0.24, 0.44)
]

var _points: PackedVector2Array = []
var _row: GhostHoverRow = GhostHoverRow.of(&"dent")
var _revision: int = -1
var _tick: int = -1
var _speed: float = 0.0
var _vertices: PackedVector2Array = []
var _colours: PackedColorArray = []
var _indices: PackedInt32Array = []


## Flight has already integrated every intervening tick and projected the lifted ribbon.
func sync(flight: GhostFlight, tick: int) -> void:
	if tick == _tick and _revision == ViewMode.revision:
		return
	_revision = ViewMode.revision
	_points = flight.tail.points()
	for i: int in _points.size():
		_points[i] = to_local(_points[i])
	_speed = clampf(flight.hover.speed_mps / _row.top_mps, 0.0, 1.0)
	_tick = tick
	var count: int = 6 + roundi(4.0 * _speed)
	if count * 8 != _vertices.size():
		_allocate(count)
	queue_redraw()


func reset() -> void:
	_tick = -1


func _allocate(count: int) -> void:
	@warning_ignore("return_value_discarded")
	_vertices.resize(count * 8)
	@warning_ignore("return_value_discarded")
	_colours.resize(count * 8)
	_indices.clear()
	for i: int in count * 2:
		var v: int = i * 4
		_indices.append_array([v, v + 1, v + 2, v, v + 2, v + 3])


func _draw() -> void:
	if _points.size() < 2:
		return
	@warning_ignore("integer_division")
	for i: int in _vertices.size() / 8:
		_shard(i)
	RenderingServer.canvas_item_add_triangle_array(get_canvas_item(), _indices, _vertices, _colours)


func _shard(i: int) -> void:
	# A common drift and staggered starts keep the splinters spread along the ribbon.
	var phase: float = fposmod(float(_tick % 59) / 59.0 + i * 0.618034, 1.0)
	var along: float = lerpf(0.10, 0.96, phase) * (_points.size() - 1)
	var link: int = floori(along)
	var centre: Vector2 = _points[link].lerp(_points[link + 1], along - link)
	var tangent: Vector2 = _points[link].direction_to(_points[link + 1])
	var side: float = -1.0 if i % 2 == 0 else 1.0
	var arc: float = sin(PI * phase)
	centre += tangent.orthogonal() * side * (0.07 + arc * (0.13 + 0.05 * (i % 3))) * PPM
	var axis: Vector2 = tangent.rotated(side * (0.23 + 0.31 * arc))
	var length_px: float = (0.16 + 0.035 * (i % 4) + 0.19 * _speed) * PPM
	var width_px: float = (0.075 + 0.014 * (i % 3) + 0.012 * _speed) * PPM
	var flash: bool = (_tick + 13 * i) % (29 + 4 * i) < 2
	for j: int in SHAPE.size():
		var sliver: Vector2 = (
			axis * SHAPE[j].x * length_px + axis.orthogonal() * SHAPE[j].y * width_px
		)
		var v: int = i * 8 + j
		_vertices[v] = centre + sliver
		_vertices[v + 4] = centre + sliver * 0.69
		_colours[v] = Color(INK, 0.70 + 0.26 * arc)
		_colours[v + 4] = Color.WHITE if flash else Color(GLASS, 0.72 + 0.25 * arc)
