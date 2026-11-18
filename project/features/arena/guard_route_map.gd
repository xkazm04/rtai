class_name GuardRouteMap
extends RefCounted
## Shared, static walk grid for arena guards. Cell centres are a metre apart. Only blocked
## approaches need A*, and the waypoints are shortened against the actual body clearance.

const HALF: Vector2 = Vector2(0.5, 0.5)
const WALL_MARGIN_M: float = 0.01
const SECTOR_M: float = 8.0

var searches: int = 0
var _grid: AStarGrid2D = AStarGrid2D.new()
var _sectors: Dictionary[Vector2i, Array] = {}
var _paths: Dictionary[Vector2i, PackedVector2Array] = {}
var _destination: Vector2i
var _radius: float


func _init(bounds: Rect2, boxes: Array[Rect2], cells: StageCells, radius: float) -> void:
	_radius = maxf(radius - WALL_MARGIN_M, 0.0)
	_grid.region = Rect2i(bounds.grow(4.0))
	_grid.offset = HALF
	_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	_grid.update()
	for box: Rect2 in boxes:
		_add_box(box)
	if cells != null:
		_index_city(cells)


## Contiguous solid city cells in a row make one box. The same geometry supplies both the
## search grid and the radius-wide sight check, including city props and parked cars.
func _index_city(cells: StageCells) -> void:
	for y: int in range(_grid.region.position.y, _grid.region.end.y):
		var x: int = _grid.region.position.x
		while x < _grid.region.end.x:
			var start: int = x
			while x < _grid.region.end.x and cells.solid(x, y):
				x += 1
			if x > start:
				_add_box(Rect2(start, y, x - start, 1))
			x += 1


func _add_box(box: Rect2) -> void:
	var lo: Vector2i = Vector2i(box.position.floor())
	var hi: Vector2i = Vector2i(box.end.ceil())
	_grid.fill_solid_region(Rect2i(lo, hi - lo).intersection(_grid.region))
	var g: Rect2 = box.grow(_radius)
	var slab: AABB = AABB(Vector3(g.position.x, g.position.y, -1), Vector3(g.size.x, g.size.y, 2))
	lo = Vector2i((g.position / SECTOR_M).floor())
	hi = Vector2i((g.end / SECTOR_M).floor())
	for y: int in range(lo.y, hi.y + 1):
		for x: int in range(lo.x, hi.x + 1):
			var key: Vector2i = Vector2i(x, y)
			if not _sectors.has(key):
				_sectors[key] = []
			_sectors[key].append(slab)


func clear_line(a: Vector2, b: Vector2) -> bool:
	# Outside the authored arena, hand control back to the ordinary guard approach.
	if not (_grid.is_in_boundsv(Vector2i(a.floor())) and _grid.is_in_boundsv(Vector2i(b.floor()))):
		return true
	var lo: Vector2i = Vector2i((a.min(b) / SECTOR_M).floor())
	var hi: Vector2i = Vector2i((a.max(b) / SECTOR_M).floor())
	var start: Vector3 = Vector3(a.x, a.y, 0)
	var end: Vector3 = Vector3(b.x, b.y, 0)
	for y: int in range(lo.y, hi.y + 1):
		for x: int in range(lo.x, hi.x + 1):
			for slab: AABB in _sectors.get(Vector2i(x, y), []):
				if slab.intersects_segment(start, end) == null:
					continue
				if not (_leaves_corner(slab, start, end) or _leaves_corner(slab, end, start)):
					return false
	return true


## Separation can put a round body inside the square padding at a corner. A step tangent
## to or away from its nearest point on the actual prop is clear for the whole segment.
func _leaves_corner(slab: AABB, a: Vector3, b: Vector3) -> bool:
	if not slab.has_point(a):
		return false
	var pad: Vector3 = Vector3(_radius, _radius, 0)
	var outward: Vector3 = a - a.clamp(slab.position + pad, slab.end - pad)
	return outward.length_squared() >= _radius * _radius and outward.dot(b - a) >= 0.0


func route(from: Vector2, to: Vector2) -> PackedVector2Array:
	var start: Vector2i = _entry(from)
	var end: Vector2i = _entry(to)
	if not _grid.is_in_boundsv(start) or not _grid.is_in_boundsv(end):
		return PackedVector2Array()
	if end != _destination:
		_paths.clear()
		_destination = end
	if not _paths.has(start):
		searches += 1
		_paths[start] = _bends(_grid.get_point_path(start, end))
	var path: PackedVector2Array = _paths[start]
	if path.size() > 1 and clear_line(from, path[1]):
		return path.slice(1)
	return path


func _bends(points: PackedVector2Array) -> PackedVector2Array:
	if points.size() < 2:
		return points
	var anchor: Vector2 = points[0]
	var bends: PackedVector2Array = PackedVector2Array([anchor])
	for i: int in range(2, points.size()):
		if not clear_line(anchor, points[i]):
			anchor = points[i - 1]
			@warning_ignore("return_value_discarded")
			bends.append(anchor)
	@warning_ignore("return_value_discarded")
	bends.append(points[-1])
	return bends


## An actor at a wall's foot can be in a partly occupied grid cell. Join the nearest visible
## centre, never snap the body across the wall. Out of bounds means no local route.
func _entry(at: Vector2) -> Vector2i:
	var cell: Vector2i = Vector2i(at.floor())
	if _grid.is_in_boundsv(cell) and not _grid.is_point_solid(cell):
		return cell
	var best: Vector2i = _grid.region.end
	var nearest: float = INF
	for y: int in range(cell.y - 1, cell.y + 2):
		for x: int in range(cell.x - 1, cell.x + 2):
			var id: Vector2i = Vector2i(x, y)
			if not _grid.is_in_boundsv(id) or _grid.is_point_solid(id):
				continue
			var p: Vector2 = Vector2(id) + HALF
			var d: float = at.distance_squared_to(p)
			if d < nearest and clear_line(at, p):
				best = id
				nearest = d
	return best
