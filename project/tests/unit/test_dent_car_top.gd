extends GutTest

var _previous: String
var _floor: Node2D
var _view: DentView
var _cars: Array[VehicleBody]
var _tilt: VehicleStageCards


func before_each() -> void:
	_previous = ViewMode.shared().id
	_floor = Node2D.new()
	add_child_autofree(_floor)
	_view = DentView.new()
	add_child_autofree(_view)
	_view.set_process(false)
	_view.dent = DentStage.shipped()
	_cars = [VehicleBody.new(7, null, Vector2(3, -4), Vector2.UP)]
	_view.stage = CollectCallStage.new(StageLayout.shipped())
	_view.stage.vehicles = VehicleService.new()
	_view.stage.vehicles.cars = _cars
	_cars[0].art = VehicleCards.POLICE_ART
	ViewMode.select("tilt70")
	_tilt = VehicleStageCards.attach(_floor, func() -> Array[VehicleBody]: return _cars)
	_tilt.set_process(false)


func after_each() -> void:
	ViewMode.select(_previous)


func test_actor_canvas_uses_tilt_paint_and_alpha_on_the_live_top_footprint() -> void:
	var car: VehicleBody = _cars[0]
	car.state = VehicleBody.State.HIJACKED
	car.vel = Vector2.UP * 3.0
	_view.dent.car = car
	_tilt.refresh()
	var tilted: Color = _tilt.cards._cds[0]
	var ink: Color = _tilt.cards._cs[0]
	ViewMode.select("top")
	_view._process(0.0)
	var top: MultiMeshInstance2D = _view._top_car.node
	assert_true(top.is_visible_in_tree())
	assert_true(DentCarTop.covers(_floor, _view.stage, car))
	assert_eq(top.modulate, ink)
	assert_eq(top.modulate.a, 1.0)
	assert_eq(
		(top.material as ShaderMaterial).shader,
		(_tilt.cards._node.material as ShaderMaterial).shader
	)
	assert_eq(top.texture.resource_path.get_file(), "traffic_atlas.png")
	var grid: ShaderMaterial = top.material as ShaderMaterial
	var columns: int = grid.get_shader_parameter(&"cols")
	var rows: int = grid.get_shader_parameter(&"rows")
	assert_eq(Vector2i(columns, rows), Vector2i(3, 4))
	assert_eq(DentCarTop._cell(car), Color(car.art, 0, tilted.b, 0))
	assert_true(int(tilted.b) & VehicleCards.SOUL != 0)
	assert_true(int(tilted.b) & VehicleCards.SIREN != 0)
	for ppm: float in [32.0, 64.0]:
		_view.ppm = ppm
		_view._process(0.0)
		assert_eq(top.scale, Vector2.ONE * ppm / SimConst.PX_PER_M)
		assert_eq(top.multimesh.visible_instance_count, 1)


func test_top_hands_back_the_body_on_release_damage_and_pitch_changes() -> void:
	var car: VehicleBody = _cars[0]
	_view.dent.car = car
	for state: VehicleBody.State in [
		VehicleBody.State.HIJACKED,
		VehicleBody.State.D1,
		VehicleBody.State.HIJACKED,
		VehicleBody.State.WRECK
	]:
		car.state = state
		ViewMode.select("tilt70")
		_tilt.refresh()
		_view._process(0.0)
		assert_false(DentCarTop.covers(_floor, _view.stage, car))
		var painted: bool = int(_tilt.cards._cds[0].b) & VehicleCards.SOUL != 0
		ViewMode.select("top")
		_view._process(0.0)
		assert_eq(DentCarTop.covers(_floor, _view.stage, car), painted)
		assert_eq(_view._top_car.node.visible, painted)
	car.state = VehicleBody.State.HIJACKED
	_view._process(0.0)
	_view.hide()
	assert_false(DentCarTop.covers(_floor, _view.stage, car))
	_view.show()
	assert_true(DentCarTop.covers(_floor, _view.stage, car))
	_view.dent.car = null
	car.state = VehicleBody.State.INTACT
	_view._process(0.0)
	assert_false(DentCarTop.covers(_floor, _view.stage, car))
	assert_false(_view._top_car.node.visible)
	assert_eq(_view._top_car.node.modulate, Color.WHITE)


func test_real_seize_and_blast_switch_both_paint_jobs_on_the_same_tick() -> void:
	var bus: EventBus = autofree(EventBus.new())
	var data: DataStore = autofree(DataStore.new())
	var session: ArenaSession = ArenaSession.open(bus, data)
	var take: GhostReviewInput = GhostReviewInput.new(session, &"dent", true)
	session.world.loop().set_input(take)
	_view.stage = session.stage
	_view.dent = session.pilot.dent
	_cars = session.stage.cars()
	var was_held: bool = false
	var changes: int = 0
	for tick: int in 242:
		session.step()
		var held: bool = _view.dent.car != null
		if held == was_held:
			continue
		was_held = held
		changes += 1
		ViewMode.select("tilt70")
		_tilt.refresh()
		var index: int = _cars.find(take.car)
		assert_eq(int(_tilt.cards._cds[index].b) & VehicleCards.SOUL != 0, held)
		ViewMode.select("top")
		_view._process(0.0)
		assert_eq(DentCarTop.covers(_floor, session.stage, take.car), held)
		assert_eq(_view._top_car.node.modulate, _tilt.cards._cs[index])
	assert_eq(changes, 2)
	assert_eq(_view.dent.blasts, 1)
	assert_eq(_view._top_car.node.modulate, Color.WHITE)
	session.world.loop().set_input(session.live)
	session.close()


func test_only_hijacked_atlas_cells_cross_the_world_print() -> void:
	var other: VehicleBody = VehicleBody.new(12, null, Vector2(-8, 5), Vector2.LEFT)
	_cars.append(other)
	_cars[0].state = VehicleBody.State.HIJACKED
	ViewMode.select("top")
	_view._process(0.0)
	var mesh: MultiMesh = _view._top_car.node.multimesh
	assert_eq(mesh.visible_instance_count, 1)
	assert_false(DentCarTop.covers(_floor, _view.stage, other))
	other.state = VehicleBody.State.HIJACKED
	_view._process(0.0)
	assert_eq(mesh.visible_instance_count, 2)
	assert_true(DentCarTop.covers(_floor, _view.stage, other))
	_cars.clear()
	_view._process(0.0)
	assert_eq(mesh.visible_instance_count, 0)
	assert_false(_view._top_car.node.visible)
