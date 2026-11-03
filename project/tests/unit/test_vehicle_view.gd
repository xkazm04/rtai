extends GutTest
## features/vehicles view: sim traffic the service rammed to D1 or soul-hijacked gets its D1 /
## hijacked cell laid over it at the sim's own car transform; unmarked traffic gets nothing.


## Three sim cars: slot 4 heading north, slot 5 east, slot 6 west (records of CAR_STRIDE floats).
class Traffic:
	extends VehicleWorld

	func cars_near(_at: Vector2, _radius: float) -> PackedFloat64Array:
		var flat: PackedFloat64Array = PackedFloat64Array()
		flat.append_array([4, 0, 10.0, 20.0, 0.0, -1.0, 8.0, 3])
		flat.append_array([5, 0, 30.0, 20.0, 1.0, 0.0, 6.0, 1])
		flat.append_array([6, 0, 50.0, 20.0, -1.0, 0.0, 9.0, 2])
		return flat


func _view(svc: VehicleService, n_tex: int = VehicleBody.State.HIJACKED + 1) -> VehicleView:
	var mesh: QuadMesh = QuadMesh.new()
	var layers: Array[MultiMeshInstance2D] = []
	for k: int in 2:
		var node: MultiMeshInstance2D = autofree(MultiMeshInstance2D.new())
		node.multimesh = MultiMesh.new()
		node.multimesh.mesh = mesh
		layers.append(node)
	var tex: Array[Texture2D] = []
	for k: int in n_tex:
		tex.append(PlaceholderTexture2D.new())
	var view: VehicleView = autofree(VehicleView.new())
	view.setup(svc, tex, layers[0], layers[1])
	return view


func _service() -> VehicleService:
	var svc: VehicleService = VehicleService.new()
	svc.profiles = VehicleProfile.load_all()
	svc.traffic = VehicleTraffic.new(VehicleDamage.load_rules())
	svc.world = Traffic.new()
	return svc


func test_marked_traffic_gets_its_cell_at_the_sim_transform() -> void:
	var svc: VehicleService = _service()
	svc.traffic.state[4] = VehicleBody.State.D1
	svc.traffic.state[5] = VehicleBody.State.HIJACKED
	var view: VehicleView = _view(svc)
	view._process(0.0)
	var d1: MultiMesh = view._bodies[VehicleBody.State.D1]
	var soul: MultiMesh = view._bodies[VehicleBody.State.HIJACKED]
	assert_eq(d1.visible_instance_count, 1)
	assert_eq(soul.visible_instance_count, 1)
	assert_eq(view._bodies[VehicleBody.State.INTACT].visible_instance_count, 0, "slot 6: none")


func test_the_car_quad_matches_the_sim_render_rows() -> void:
	# native render.cpp: {dx * CL, -dy * CW, 0, X, dy * CL, dx * CW, 0, Y}
	var xf: Transform2D = VehicleView.car_xf(Vector2(10.0, 20.0), Vector2(0.0, -1.0))
	assert_eq(xf.origin, Vector2(10.0, 20.0) * SimConst.PX_PER_M)
	assert_eq(xf.x, Vector2(0.0, -1.0) * VehicleView.CAR_L, "length along the heading")
	assert_eq(xf.y, Vector2(1.0, 0.0) * VehicleView.CAR_W, "width along its left normal")


func test_an_empty_book_draws_no_traffic() -> void:
	var view: VehicleView = _view(_service())
	view._process(0.0)
	for mm: MultiMesh in view._bodies:
		assert_eq(mm.visible_instance_count, 0)


func test_a_wreck_draws_the_burnt_atlas_untinted() -> void:
	var svc: VehicleService = _service()
	var b: VehicleBody = svc.spawn_parked(&"sedan", Vector2(5, 5), Vector2.RIGHT)
	b.state = VehicleBody.State.WRECK
	var view: VehicleView = _view(svc, VehicleBody.State.WRECK + 1)
	view._process(0.0)
	var wreck: MultiMesh = view._bodies[VehicleBody.State.WRECK]
	assert_eq(wreck.visible_instance_count, 1)
	assert_eq(view._bodies[VehicleBody.State.D2].visible_instance_count, 0)
	assert_true(view._burnt)


func test_without_the_burnt_atlas_a_wreck_is_its_d2_cell_darkened() -> void:
	var svc: VehicleService = _service()
	var b: VehicleBody = svc.spawn_parked(&"sedan", Vector2(5, 5), Vector2.RIGHT)
	b.state = VehicleBody.State.WRECK
	var view: VehicleView = _view(svc)
	assert_false(view._burnt)
	var nodes: Array[MultiMeshInstance2D] = []
	for c: Node in view.get_children():
		if c is MultiMeshInstance2D:
			nodes.append(c)
	# children: shadow, then one body layer per state
	var d2: MultiMeshInstance2D = nodes[1 + VehicleBody.State.D2]
	var wreck: MultiMeshInstance2D = nodes[1 + VehicleBody.State.WRECK]
	assert_eq(wreck.texture, d2.texture)
