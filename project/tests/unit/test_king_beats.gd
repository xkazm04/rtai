extends GutTest
## King's phase beats: he steps down off the car into phase 3 and the car stays where it stalled.


func _fight(phase: int) -> BossFight:
	var spec: BossSpec = BossSpec.shipped(&"king")
	var f: BossFight = BossFight.new(spec, RngRegistry.new(5).stream(spec.rng), Vector2(10, 4))
	f.moves.bind(f, RngRegistry.new(5))
	f.start(phase)
	return f


func test_phase_three_leaves_the_car_and_steps_king_down_beside_it() -> void:
	var f: BossFight = _fight(2)
	var km: KingMoves = f.moves as KingMoves
	assert_eq(km.car_at, Vector2(10, 4), "the car rests where it stalled")
	assert_eq(f.body.pos, Vector2(10, 4) + KingMoves.step_down(f.body.facing), "King beside it")
	assert_almost_eq(f.body.pos.distance_to(km.car_at), 2.46, 0.05)


func test_the_car_phases_keep_king_on_the_throne() -> void:
	var f: BossFight = _fight(0)
	assert_eq((f.moves as KingMoves).car_at, Vector2.INF, "no wreck while the car runs")
	assert_eq(KingBeats.step_k(f), 0.0)
	assert_eq(KingBeats.smoke_amount(f), 0.0, "no smoke in the procession")


func test_the_wreck_is_cover_from_phase_three_only() -> void:
	assert_eq(_fight(1).moves.solids().size(), 0, "the stalled car is King himself in the court")
	var f: BossFight = _fight(2)
	var boxes: Array[Rect2] = f.moves.solids()
	assert_eq(boxes.size(), 3, "three boxes along the wreck")
	assert_true(boxes[1].has_point((f.moves as KingMoves).car_at), "the middle box on the car")
	var walls: ArenaWalls = ArenaWalls.new()
	walls.boxes = boxes
	var through: Vector2 = (f.moves as KingMoves).car_at
	var axis: Vector2 = f.body.facing.orthogonal() * 4.0
	assert_true(walls.blocks(through - axis, through + axis), "a shot across the wreck stops")
	assert_false(walls.blocks(f.body.pos, f.body.pos + axis), "King's side of it is open")
