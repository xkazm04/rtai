class_name BotRoute
extends RefCounted
## A walking route for the quest bots across the generated city (n18 districts item 5: with
## --quest1-places, Dock 9 sits on the city's dock block, ~1.6 km from Harbor Road, so a straight
## walk ends against a building). A* (AStarGrid2D) over STEP_M cells of the city's 1 m walk
## cells (StageCells): a cell is open when none of its 1 m cells is solid. The search box is the
## two ends' bounds plus MARGIN_M. Waypoints are the open cells' centres, the first and last
## replaced by the true ends; empty when no route exists.

const STEP_M: int = 4
const MARGIN_M: int = 96
## How near a waypoint counts as passed (m).
const PASS_M: float = 2.0

var waypoints: PackedVector2Array = PackedVector2Array()
var goal: Vector2 = Vector2.INF
var _next: int = 0


## The route from `from` to `to` over `cells`; null when the ends share no open network.
static func find(cells: StageCells, from: Vector2, to: Vector2) -> BotRoute:
	var lo: Vector2i = Vector2i(from.min(to)) - Vector2i(MARGIN_M, MARGIN_M)
	var hi: Vector2i = Vector2i(from.max(to)) + Vector2i(MARGIN_M, MARGIN_M)
	var grid: AStarGrid2D = AStarGrid2D.new()
	grid.region = Rect2i(lo / STEP_M, (hi - lo) / STEP_M + Vector2i.ONE)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.update()
	for gy: int in range(grid.region.position.y, grid.region.end.y):
		for gx: int in range(grid.region.position.x, grid.region.end.x):
			if not is_open(cells, gx, gy):
				grid.set_point_solid(Vector2i(gx, gy))
	var a: Vector2i = _nearest_open(grid, Vector2i(from) / STEP_M)
	var b: Vector2i = _nearest_open(grid, Vector2i(to) / STEP_M)
	if a == -Vector2i.ONE or b == -Vector2i.ONE:
		return null
	var ids: Array[Vector2i] = grid.get_id_path(a, b)
	if ids.is_empty():
		return null
	var r: BotRoute = BotRoute.new()
	r.goal = to
	for id: Vector2i in ids:
		@warning_ignore("return_value_discarded")
		r.waypoints.push_back(Vector2(id * STEP_M) + Vector2.ONE * (STEP_M * 0.5))
	r.waypoints[0] = from
	r.waypoints[r.waypoints.size() - 1] = to
	return r


## The point to walk at now from `at`: the first waypoint not yet passed.
func steer(at: Vector2) -> Vector2:
	while _next < waypoints.size() - 1 and at.distance_to(waypoints[_next]) <= PASS_M:
		_next += 1
	return waypoints[_next]


func size() -> int:
	return waypoints.size()


static func is_open(cells: StageCells, gx: int, gy: int) -> bool:
	for y: int in range(gy * STEP_M, gy * STEP_M + STEP_M):
		for x: int in range(gx * STEP_M, gx * STEP_M + STEP_M):
			if cells.solid(x, y):
				return false
	return true


## The open cell nearest c (rings out to 3 cells), or (-1, -1).
static func _nearest_open(grid: AStarGrid2D, c: Vector2i) -> Vector2i:
	for ring: int in 4:
		for dy: int in range(-ring, ring + 1):
			for dx: int in range(-ring, ring + 1):
				var p: Vector2i = c + Vector2i(dx, dy)
				if grid.is_in_boundsv(p) and not grid.is_point_solid(p):
					return p
	return -Vector2i.ONE
