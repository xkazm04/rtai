extends GutTest


func test_shipped_tilt_uses_one_legacy_blob_per_person() -> void:
	var saved: ViewMode = ViewMode.shared()
	ViewMode.select("tilt70")
	var writers: Array[CitySimBackend] = [CitySimRef.new()]
	if CitySimNative.available():
		writers.append(CitySimNative.new())
	for sim: CitySimBackend in writers:
		sim.init(5)
		var crowd := CrowdLayers.new()
		var layer: Node2D = autofree(Node2D.new())
		crowd.attach(layer)
		var shadow: MultiMeshInstance2D = crowd.nodes[SimConst.RL_PED_SHADOWS]
		var blob: Texture2D = shadow.texture
		var quad: Mesh = shadow.multimesh.mesh
		for slot: int in 3:
			var kind: int = SimConst.K_COP if slot == 0 else SimConst.K_PED
			assert_eq(sim.spawn(PackedFloat64Array([kind, slot, 2, 1, 0, 0, 0, 1, 0, 0])), slot)
		sim.set_rig_slots(PackedInt32Array([1]))
		sim.strike(2, 1.0, 0.0, true)
		CityCrowdContact.setup(crowd, sim)
		sim.write_render(-10, -10, 10, 10)
		assert_same(shadow.texture, blob)
		assert_same(shadow.multimesh.mesh, quad)
		assert_eq(layer.get_child_count(), SimConst.RL_COUNT, "no additional rig shadow pass")
		assert_eq(sim.get_render_counts()[SimConst.RL_PED_SHADOWS], 3, sim.backend_name())
	ViewMode._shared = saved


func test_baked_rings_match_the_standing_rig_at_both_hip_heights() -> void:
	var dir: Vector2 = ViewMode.of("tilt70").cast_dir()
	var mesh: ArrayMesh = CityCrowdContact.mesh(dir)
	var arrays: Array = mesh.surface_get_arrays(0)
	var verts: PackedVector2Array = arrays[Mesh.ARRAY_VERTEX]
	var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR]
	var pool: RigPool = add_child_autofree(RigPool.new())
	for kind: BodyPlan.Kind in [BodyPlan.Kind.PED, BodyPlan.Kind.COP]:
		var look: RigVariant = RigVariant.crowd(5 if kind == BodyPlan.Kind.COP else 0)
		@warning_ignore("return_value_discarded")
		pool.prewarm(kind, 1)
		var rig: CutRig = pool.acquire(kind, look, Vector2.ZERO, 0.0)
		var hip: float = RigCastShadows.hip_px(rig)
		var scale_px: float = CityCrowdContact.standing_hip(kind)
		var vertex: int = 0
		for ring: Vector2 in RigCastShadows.CONTACT_RINGS:
			var at: Vector2 = dir * hip * RigCastShadows.CONTACT_SLIDE_HIPS
			var radius: float = hip * RigCastShadows.CONTACT_R_HIPS * ring.x
			for expected: Vector2 in RigCastShadows.contact_ellipse(at, radius):
				assert_lt((verts[vertex] * scale_px).distance_to(expected), 0.001)
				assert_almost_eq(colors[vertex].a, ring.y, 1.0 / 255.0)
				vertex += 1
		assert_eq(vertex, verts.size())


func test_only_baked_living_slots_get_their_own_contact() -> void:
	var sim: CitySimRef = CitySimRef.new()
	sim.init(5)
	var crowd: CrowdLayers = CrowdLayers.new()
	var layer: Node2D = autofree(Node2D.new())
	crowd.attach(layer)
	for i: int in 3:
		assert_eq(sim.spawn(PackedFloat64Array([SimConst.K_PED, i, 2, 1, 0, 0, 0, 1, 0, 0])), i)
	sim.set_rig_slots(PackedInt32Array([0]))
	sim.strike(2, 1.0, 0.0, true)
	var saved: ViewMode = ViewMode.shared()
	ViewMode.select("tilt70")
	ViewMode.shared().crowd_contact_hip_scale = 0.5
	RigCastShadows.attach(layer)
	CityCrowdContact.setup(crowd, sim)
	assert_eq(layer.get_child_count(), SimConst.RL_COUNT + 1, "reuse the existing rig pass")
	ViewMode._shared = saved
	sim.write_render(-10, -10, 10, 10)
	assert_eq(sim.get_render_counts()[SimConst.RL_PED_SHADOWS], 1)
	var row := PackedFloat32Array(sim._render._layers[SimConst.RL_PED_SHADOWS])
	assert_eq(
		Vector2(row[0], row[5]),
		Vector2.ONE * 0.5 * CityCrowdContact.standing_hip(BodyPlan.Kind.PED)
	)
	assert_eq(Vector2(row[3], row[7]), Vector2(1, 2) * SimConst.PX_PER_M)
	sim.set_render(crowd.rids(), CrowdAtlas.clip_table())
	sim.write_render(-10, -10, 10, 10)
	assert_eq(sim.get_render_counts()[SimConst.RL_PED_SHADOWS], 3)


func test_contact_view_installs_a_rig_pass_only_between_the_cast_thresholds() -> void:
	var saved: ViewMode = ViewMode.shared()
	for k: float in [0.0, RigCastShadows.CONTACT_BELOW_K * 0.5, RigCastShadows.CONTACT_BELOW_K]:
		var view := ViewMode.new()
		view.cast_k = k
		view.crowd_contact_hip_scale = 1.0
		ViewMode._shared = view
		var layer: Node2D = autofree(Node2D.new())
		var crowd := CrowdLayers.new()
		crowd.attach(layer)
		var shadow := crowd.nodes[SimConst.RL_PED_SHADOWS]
		var original: Mesh = shadow.multimesh.mesh
		CityCrowdContact.setup(crowd, CitySimRef.new())
		var contact: bool = k > 0.0 and k < RigCastShadows.CONTACT_BELOW_K
		assert_eq(shadow.multimesh.mesh != original, contact, "contact mesh at cast_k %s" % k)
		var passes: int = 0
		for child: Node in layer.get_children():
			if child is RigCastShadows:
				passes += 1
		assert_eq(passes, int(contact), "standalone city pass at cast_k %s" % k)
	ViewMode._shared = saved


func test_every_ring_covers_its_ellipse_once() -> void:
	var mesh := CityCrowdContact.mesh(Vector2.RIGHT)
	var indices: PackedInt32Array = mesh.surface_get_arrays(0)[Mesh.ARRAY_INDEX]
	var n: int = RigCastShadows.CONTACT_POINTS
	var expected := PackedInt32Array()
	for ring: int in RigCastShadows.CONTACT_RINGS.size():
		var first: int = ring * n
		for edge: int in range(1, n - 1):
			expected.append_array(PackedInt32Array([first, first + edge, first + edge + 1]))
	assert_eq(indices, expected, "each consecutive edge closes a triangle inside its own ring")


func test_reference_shadow_buffers_preserve_the_top_print_and_baked_cop_contact() -> void:
	var sim := CitySimRef.new()
	var crowd := CrowdLayers.new()
	var layer: Node2D = autofree(Node2D.new())
	crowd.attach(layer)
	var pos := Vector2(2, 3)
	var slot: int = sim.spawn(PackedFloat64Array([SimConst.K_COP, 2, 3, 1, 0, 5, 0, 1, 0, 0]))
	assert_eq(slot, 0)
	sim.set_render(crowd.rids(), CrowdAtlas.clip_table())
	sim.write_render(0, 0, 10, 10)
	var ink: Color = Color(CitySimRender.INK, 0.3)
	var px: Vector2 = pos * SimConst.PX_PER_M
	_check_print(sim, px + Vector2(2, 3), CitySimRender.S_SHADOW, ink)
	sim.set_render(crowd.rids(), CrowdAtlas.clip_table(), Vector2(12, 17))
	sim.write_render(0, 0, 10, 10)
	_check_print(sim, px, 17.0, Color.WHITE)
	sim._s.mode[slot] = SimConst.M_DOWN
	sim.write_render(0, 0, 10, 10)
	assert_eq(sim.get_render_counts()[SimConst.RL_PED_SHADOWS], 0)
	sim.set_render(crowd.rids(), CrowdAtlas.clip_table(), Vector2.ZERO)
	sim.write_render(0, 0, 10, 10)
	_check_print(sim, px + Vector2(2, 3), CitySimRender.S_SHADOW, ink)


func _check_print(sim: CitySimRef, pos: Vector2, size_px: float, color: Color) -> void:
	var row := PackedFloat32Array(sim._render._layers[SimConst.RL_PED_SHADOWS])
	assert_eq(row.size(), SimConst.RL_STRIDE)
	if row.size() != SimConst.RL_STRIDE:
		return
	assert_eq(Vector2(row[0], row[5]), Vector2.ONE * size_px, "world size")
	assert_eq(Vector2(row[3], row[7]), pos, "foot position")
	assert_eq(Vector2(row[1], row[4]), Vector2.ZERO, "unrotated ground print")
	assert_eq(Color(row[8], row[9], row[10], row[11]), color, "shadow ink")
	assert_eq(row.slice(12), PackedFloat32Array([0, 0, 0, 0]), "untextured shadow cell")
