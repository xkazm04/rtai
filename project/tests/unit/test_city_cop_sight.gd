extends GutTest
## n18 police item 1 (n15 DEFECTS "cops pressed against a sidewalk wall's foot"): a cop inside
## FF_NEAR_M of the target steers straight at it only when the tile grid shows a clear line of
## sight (CitySimFlow.sight, an integer cell walk); behind a wall he keeps following the flow field
## round its end. Same wall as test_city_flow_field: x 300..302, gap at y 320..327.

const CAM: Vector2 = Vector2(305.0, 300.0)
const TICKS: int = 3000


## 9 m apart, the wall between: before, the cop pressed into the wall's west face for good.
func test_a_near_cop_behind_a_wall_goes_round_it() -> void:
	var reached: int = _ticks_to_cross(Vector2(296.5, 290.5), Vector2(305.5, 290.5))
	gut.p("near cop (9 m, wall between): crossed at tick %d (-1 = never)" % reached)
	assert_gt(reached, 0, "the cop got round the wall's end inside %d ticks" % TICKS)


## 6 m apart (inside the 7 m stand-off), the wall between: before, he stood still for good.
func test_a_cop_inside_the_stand_off_behind_a_wall_still_moves() -> void:
	var reached: int = _ticks_to_cross(Vector2(297.5, 290.5), Vector2(303.5, 290.5))
	gut.p("stand-off cop (6 m, wall between): crossed at tick %d (-1 = never)" % reached)
	assert_gt(reached, 0, "the cop got round the wall's end inside %d ticks" % TICKS)


## In plain sight inside 10 m nothing changes: straight at the target, stop at 7 m.
func test_a_cop_in_sight_still_steers_straight_and_stands_off() -> void:
	var sim: CitySimRef = CityWallMap.walled(true)
	var cop: int = CityWallMap.spawn_cop(sim, Vector2(285.5, 300.5))
	var goal: Vector2 = Vector2(294.5, 300.5)
	for t: int in 120:
		sim.step(SimClock.TICK_DT, CAM.x, CAM.y, goal.x, goal.y)
	var p: Vector2 = CityWallMap.pos(sim, cop)
	assert_almost_eq(p.y, 300.5, 0.05, "straight along the row")
	assert_almost_eq(goal.x - p.x, 7.0, 0.1, "stands off at 7 m")


func test_sight_walks_the_cells_between() -> void:
	var sim: CitySimRef = CityWallMap.walled(true)
	assert_true(sim.sight(296.5, 290.5, 299.5, 295.5), "west of the wall")
	assert_false(sim.sight(296.5, 290.5, 305.5, 290.5), "across the wall")
	assert_false(sim.sight(305.5, 299.9, 296.5, 290.1), "across it the other way, diagonal")
	assert_true(sim.sight(296.5, 322.5, 305.5, 323.5), "through the gap")
	assert_false(sim.sight(299.5, 319.5, 300.5, 320.5), "a corner touch counts as blocked")


func _ticks_to_cross(start: Vector2, goal: Vector2) -> int:
	var sim: CitySimRef = CityWallMap.walled(true)
	var cop: int = CityWallMap.spawn_cop(sim, start)
	for t: int in TICKS:
		sim.step(SimClock.TICK_DT, CAM.x, CAM.y, goal.x, goal.y)
		if CityWallMap.pos(sim, cop).x > 303.0:
			return t + 1
	return -1
