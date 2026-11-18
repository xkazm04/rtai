extends GutTest


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
	RigCastShadows.attach(layer)
	CityCrowdContact.setup(crowd, sim)
	assert_eq(layer.get_child_count(), SimConst.RL_COUNT + 1, "reuse the existing rig pass")
	ViewMode._shared = saved
	sim.write_render(-10, -10, 10, 10)
	assert_eq(sim.get_render_counts()[SimConst.RL_PED_SHADOWS], 1)
	var row := PackedFloat32Array(sim._render._layers[SimConst.RL_PED_SHADOWS])
	assert_eq(
		Vector2(row[0], row[5]), Vector2.ONE * CityCrowdContact.standing_hip(BodyPlan.Kind.PED)
	)
	assert_eq(Vector2(row[3], row[7]), Vector2(1, 2) * SimConst.PX_PER_M)
	sim.set_render(crowd.rids(), CrowdAtlas.clip_table())
	sim.write_render(-10, -10, 10, 10)
	assert_eq(sim.get_render_counts()[SimConst.RL_PED_SHADOWS], 3)
