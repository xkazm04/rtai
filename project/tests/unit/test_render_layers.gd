extends GutTest
## The render layer stack as data (core/render/README.md): the table is well formed and the
## real city scene (World + CitySystem + CityView + the characters) draws only on its layers.

var _layers: RenderLayers
## Built once: a second CityTextures threaded load in one headless process can race the dummy
## renderer (a null texture in texture_2d_initialize, seen once in 3 runs).
var _view: CityView


func before_all() -> void:
	_layers = RenderLayers.shared()
	_view = _city_scene()


func after_all() -> void:
	_view.get_parent().free()


func test_the_table_loads_with_every_band_on_a_declared_canvas() -> void:
	assert_true(_layers.ok)
	for id: StringName in _layers.bands:
		assert_true(_layers.canvases.values().has(_layers.bands[id].x), "%s canvas" % id)


func test_bands_are_unique_and_spaced_inside_a_canvas() -> void:
	var seen: Dictionary[Vector2i, StringName] = {}
	for id: StringName in _layers.bands:
		var b: Vector2i = _layers.bands[id]
		assert_false(seen.has(b), "%s shares a band with %s" % [id, seen.get(b, &"")])
		seen[b] = id
	for a: StringName in _layers.bands:
		for b: StringName in _layers.bands:
			var pa: Vector2i = _layers.bands[a]
			var pb: Vector2i = _layers.bands[b]
			if a != b and pa.x == _layers.canvases[&"actors"] and pa.x == pb.x:
				assert_gte(absi(pa.y - pb.y), RenderLayers.BAND_SPAN, "%s vs %s" % [a, b])


func test_the_stack_is_in_the_documented_order() -> void:
	var order: Array[StringName] = [
		&"ground",
		&"ground_decals",
		&"building_shadows",
		&"props",
		&"roofs",
		&"print_pass",
		&"actor_shadows",
		&"actors",
		&"vehicles",
		&"roof_occluders",
		&"fx",
		&"grade",
		&"lights",
		&"world_markers",
		&"hud"
	]
	for i: int in order.size() - 1:
		var lo: Vector2i = _layers.bands[order[i]]
		var hi: Vector2i = _layers.bands[order[i + 1]]
		assert_true(
			lo.x < hi.x or (lo.x == hi.x and lo.y < hi.y), "%s below %s" % order.slice(i, i + 2)
		)


func test_the_city_scene_uses_only_declared_layers() -> void:
	var view: CityView = _view
	var bad: Array[String] = _layers.audit(view)
	assert_eq(bad.size(), 0, "\n".join(bad))
	assert_eq(view.actor_layer().layer, RenderLayers.canvas(&"actors"))
	assert_eq(view.crowd.nodes[SimConst.RL_CARS].z_index, RenderLayers.z(&"vehicles"))


func test_the_audit_catches_an_undeclared_layer() -> void:
	var view: CityView = _view
	var stray: Node2D = Node2D.new()
	stray.z_index = 7
	view.actor_layer().add_child(stray)
	var rogue: CanvasLayer = CanvasLayer.new()
	rogue.layer = 64
	view.add_child(rogue)
	assert_eq(_layers.audit(view).size(), 2)
	stray.free()
	rogue.free()
	assert_eq(_layers.audit(view).size(), 0)


func _city_scene() -> CityView:
	var world: World = World.new()
	world.start(Events, Data, 7)
	add_child(world)
	var city: CitySystem = CitySystem.new(true)
	world.add_system(city)
	var view: CityView = CityView.new()
	world.add_child(view)
	view.setup(city)
	@warning_ignore("return_value_discarded")
	CityCharacters.new(city, view, world.context())
	return view


func test_look_toggle_keeps_a_layer_material_it_did_not_set() -> void:
	var people: MultiMeshInstance2D = _view.crowd.nodes[SimConst.RL_PEDS]
	var cars: MultiMeshInstance2D = _view.crowd.nodes[SimConst.RL_CARS]
	var saved: Material = people.material
	var atlas: ShaderMaterial = ShaderMaterial.new()
	people.material = atlas  # what CityCharacters.bake does with the crowd atlas material
	_view.set_look_enabled(false)
	assert_eq(people.material, atlas, "--look=off must not drop the crowd atlas material")
	if _view.crowd.car_print == null:  # no traffic atlas in the tree: the plain steel quad
		assert_null(cars.material)
	else:  # the traffic atlas keeps its cell lookup unprinted
		assert_ne(cars.material, _view.crowd.car_print)
	_view.set_look_enabled(true)
	assert_eq(people.material, atlas)
	assert_not_null(cars.material)
	people.material = saved


func test_traffic_grid_is_read_from_the_atlas_size() -> void:
	assert_eq(CrowdLayers.traffic_grid(Vector2i(1536, 768)), Vector2i(3, 3), "n-d4's 3 x 3 atlas")
	assert_eq(CrowdLayers.traffic_grid(Vector2i(2048, 768)), Vector2i(4, 3))
	assert_eq(
		CrowdLayers.traffic_grid(Vector2i(1024, 1024)), Vector2i.ZERO, "2 x 4: no cell 8 (police)"
	)
	assert_eq(CrowdLayers.traffic_grid(Vector2i(1500, 768)), Vector2i.ZERO, "not whole cells")
