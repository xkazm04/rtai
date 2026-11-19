class_name CityCrowdContact
extends RefCounted
## With nonzero contact hips, the baked crowd uses the rig's ground print in contact views.
## At zero the original textured quad and the writers' one-blob-per-person path stay paired.


static func setup(crowd: CrowdLayers, sim: CitySimBackend) -> void:
	var view: ViewMode = ViewMode.shared()
	var hips: Vector2 = Vector2.ZERO
	if (
		view.crowd_contact_hip_scale > 0.0
		and view.cast_k > 0.0
		and view.cast_k < RigCastShadows.CONTACT_BELOW_K
	):
		var shadow: MultiMeshInstance2D = crowd.nodes[SimConst.RL_PED_SHADOWS]
		shadow.multimesh.mesh = mesh(view.cast_dir())
		shadow.texture = null
		# The rings carry the rig's own ink. Keep the city's item print from tinting it twice.
		shadow.material = CanvasItemMaterial.new()
		hips = Vector2(standing_hip(BodyPlan.Kind.PED), standing_hip(BodyPlan.Kind.COP))
		hips *= view.crowd_contact_hip_scale
		_ensure_rig_shadows(shadow.get_parent())
	sim.set_render(crowd.rids(), CrowdAtlas.clip_table(), hips)


static func standing_hip(kind: BodyPlan.Kind) -> float:
	var plan: BodyPlan = RigPool.plan_of(kind)
	return plan.hip_z * (CutRig.SC * plan.size_k)


## The arena installs a cast pass on this canvas before the crowd bake. The city alone needs one.
static func _ensure_rig_shadows(layer: Node) -> void:
	for child: Node in layer.get_children():
		if child is RigCastShadows:
			return
	RigCastShadows.attach(layer)


static func mesh(direction: Vector2) -> ArrayMesh:
	var verts: PackedVector2Array = PackedVector2Array()
	var colors: PackedColorArray = PackedColorArray()
	var indices: PackedInt32Array = PackedInt32Array()
	var at: Vector2 = direction * RigCastShadows.CONTACT_SLIDE_HIPS
	for ring: Vector2 in RigCastShadows.CONTACT_RINGS:
		var radius: float = RigCastShadows.CONTACT_R_HIPS * ring.x
		var points: PackedVector2Array = RigCastShadows.contact_ellipse(at, radius)
		var base: int = verts.size()
		verts.append_array(points)
		for i: int in points.size():
			@warning_ignore("return_value_discarded")
			colors.append(Color(RigCastShadows.SHADOW, ring.y))
			if i >= 2:
				indices.append_array(PackedInt32Array([base, base + i - 1, base + i]))
	var arrays: Array = []
	@warning_ignore("return_value_discarded")
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices
	var result: ArrayMesh = ArrayMesh.new()
	result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return result
