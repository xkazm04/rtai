extends GutTest
## Servo's landed CS crates are solid (ServoMoves.solids, synced into the stage's ArenaWalls by
## BossHook): a body is pushed out of one, a shot line through one is stopped, and with
## parcels.crates_solid = false they are paint only.

const AT: Vector2 = Vector2(4.0, 2.0)


func _moves(solid: bool) -> ServoMoves:
	var m: ServoMoves = ServoMoves.new()
	var t: ServoTuning = ServoTuning.shipped()
	t.crates_solid = solid
	m.setup_swarm(RngRegistry.new(3).stream(ServoSwarm.STREAM), t)
	m.swarm.parcels.drop(AT, ServoParcels.CRATE, 1)
	m.swarm.parcels.step()
	return m


func test_a_landed_crate_is_a_solid_box() -> void:
	var m: ServoMoves = _moves(true)
	var boxes: Array[Rect2] = m.solids()
	assert_eq(boxes.size(), 1, "one crate, one box")
	assert_almost_eq(boxes[0].get_center().distance_to(AT), 0.0, 0.001, "centred on the crate")
	assert_almost_eq(boxes[0].size.x, m.swarm.tuning.crate_m, 0.001, "crate_m wide")
	var walls: ArenaWalls = ArenaWalls.new()
	walls.boxes.append_array(boxes)
	var pushed: Vector2 = walls.push_out(AT + Vector2(0.3, 0.0), 0.5)
	assert_gt(pushed.distance_to(AT), m.swarm.tuning.crate_m * 0.5, "the body is pushed out")
	assert_true(walls.blocks(AT - Vector2(3.0, 0.0), AT + Vector2(3.0, 0.0)), "the shot is stopped")


func test_crates_as_paint_only() -> void:
	var none: Array = _moves(false).solids()
	assert_eq(none.size(), 0, "crates_solid = false: nothing solid")
	# BossHook keeps it in an Array[Rect2]: an untyped [] was a script error every tick.
	assert_eq(none.get_typed_builtin(), TYPE_RECT2, "still an Array[Rect2]")


func test_a_shot_apart_crate_stops_blocking() -> void:
	var m: ServoMoves = _moves(true)
	for i: int in m.swarm.tuning.crate_hp:
		assert_true(m.swarm.parcels.hit_crate(AT, 1))
	assert_eq(m.solids().size(), 0, "a crate at 0 hp is gone")


func test_the_dash_smashes_the_crates_it_crosses() -> void:
	var m: ServoMoves = _moves(true)
	m.swarm.parcels.drop(AT + Vector2(5.0, 0.0), ServoParcels.CRATE, 1)
	m.swarm.parcels.step()
	assert_eq(m.solids().size(), 2)
	assert_eq(m.swarm.parcels.smash(AT + Vector2(0.4, 0.0), 0.8), 1, "the crate under the body")
	assert_eq(m.solids().size(), 1, "the far crate still stands")
	assert_eq(m.swarm.parcels.smashed_total, 1)
