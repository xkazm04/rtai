extends GutTest
## t-5 (n11 Call 5, owner 2026-11-10): a promoted actor stays tier A out to rb * 1.6 from the camera
## (city_sim_ref.gd and step.cpp, `d2 > rb2 * 2.56`), so the hash window must reach that far on
## both axes, or query() never returns it (no neighbour or collision checks).

const RB: float = 160.0  # CitySystem.RB, the game's bubble (bench's dense run uses 80)
const KEEP: float = 1.6  # sqrt(2.56): how far past rb a promoted actor stays tier A
const CAM: Vector2 = Vector2(1001.0, 1003.0)

var _s: CitySimState
var _h: CitySimHash


func before_each() -> void:
	_s = CitySimState.new()
	_s.init(1)
	_h = CitySimHash.new(_s)


func _place(i: int, p: Vector2) -> void:
	_s.alive[i] = 1
	_s.tier[i] = 0
	_s.px[i] = p.x
	_s.py[i] = p.y


func test_a_promoted_actor_at_the_keep_radius_is_found_on_every_side() -> void:
	var reach: float = RB * KEEP - 0.01
	var dirs: Array[Vector2] = [
		Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP, Vector2(1, 1).normalized()
	]
	for k: int in dirs.size():
		_place(k, CAM + dirs[k] * reach)
	_h.build(CAM.x, CAM.y)
	for k: int in dirs.size():
		var p: Vector2 = CAM + dirs[k] * reach
		assert_has(_h.query(p.x, p.y, 1), k, "promoted actor %s at %.0f m" % [dirs[k], reach])


func test_the_window_covers_the_keep_radius_with_a_cell_to_spare() -> void:
	var half_cells: int = SimConst.HW >> 1
	var keep_cells: int = ceili(RB * KEEP / SimConst.HC)
	assert_gt(half_cells, keep_cells, "left/top: the camera cell less the keep radius stays in")
	assert_gt(SimConst.HW - half_cells, keep_cells + 1, "right/bottom: plus the camera's own cell")
