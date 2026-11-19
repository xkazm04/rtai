extends GutTest

var stage: ArenaStage
var body: Fighter
var cover: PlayerCover


func before_each() -> void:
	stage = VaultTrial.stage_for(false)
	body = stage.arena.rivet
	body.pos = Vector2(4, 11.65)
	cover = stage.pilot.motion.cover
	cover.enabled = true


func _step(press: bool = false) -> void:
	var bits: int = (1 << stage.pilot.actions.bit(&"cover")) if press else 0
	stage.step(stage.tick + 1, TickInput.new(bits))


func test_blocked_start_refuses_cover_before_selecting_a_spot() -> void:
	body.pos = Vector2(4, 13)
	_step(true)
	assert_eq(cover.phase, PlayerCover.Phase.OFF)
	assert_null(cover.spot)


func test_active_state_serializes_both_coordinates_for_all_six_points() -> void:
	var start: Vector2 = body.pos
	_step(true)
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	cover.write_state(out)
	assert_eq(out.get_size(), 13 + 6 * 8)
	if out.get_size() != 61:
		return
	out.seek(13)
	var spot: CoverQuery.CoverSpot = cover.spot
	for p: Vector2 in [start, body.pos, spot.at, spot.box.position, spot.box.size, spot.normal]:
		assert_eq(Vector2(out.get_float(), out.get_float()), p)


func test_final_snap_uses_the_representable_face_even_if_lerp_rounds_inside() -> void:
	var prop: ArenaStation.Prop = ArenaStation.Prop.new()
	prop.kind = "cover_low"
	prop.at = Vector2(-6, 0.43736148)
	prop.size = Vector2(2, 0.2)
	stage.stations.stations[0].props.append(prop)
	stage.walls = ArenaWalls.from_stations(stage.stations, stage.plan.base)
	stage.pilot.motion.vault.probe.stations(stage.stations, stage.plan.base)
	var start: Vector2 = Vector2(-6, -0.76766557)
	body.pos = start
	_step(true)
	assert_not_null(cover.spot)
	if cover.spot == null:
		return
	var face: Vector2 = cover.spot.at
	assert_ne(start.lerp(face, 1.0), face, "the interpolated coordinate rounds into the wall")
	for i: int in cover.snap_ticks - 1:
		_step()
	assert_eq(cover.phase, PlayerCover.Phase.IN)
	assert_eq(body.pos, face)
