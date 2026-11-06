class_name VehicleCardMesh
extends RefCounted
## n8 vehicles: one MultiMesh layer of VehicleCards (a unit quad per card, 2D transforms, colour
## and custom data, the card atlas shader with its grid).


static func make(cap: int, shader: Shader, cols: int, rows: int) -> MultiMeshInstance2D:
	var mm: MultiMesh = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_2D
	mm.use_colors = true
	mm.use_custom_data = true
	mm.mesh = quad()
	mm.instance_count = cap
	mm.visible_instance_count = 0
	mm.custom_aabb = AABB(Vector3(-1e7, -1e7, -10), Vector3(2e7, 2e7, 20))
	var node: MultiMeshInstance2D = MultiMeshInstance2D.new()
	node.multimesh = mm
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	node.material = mat
	set_grid(node, Vector2i(cols, rows))
	return node


## The atlas grid (columns, rows) the layer's shader reads its cells from.
static func set_grid(node: MultiMeshInstance2D, grid: Vector2i) -> void:
	var mat: ShaderMaterial = node.material as ShaderMaterial
	mat.set_shader_parameter("cols", grid.x)
	mat.set_shader_parameter("rows", grid.y)


static func quad() -> ArrayMesh:
	var arr: Array = []
	@warning_ignore("return_value_discarded")
	arr.resize(Mesh.ARRAY_MAX)
	var h: float = 0.5
	arr[Mesh.ARRAY_VERTEX] = PackedVector2Array(
		[Vector2(-h, -h), Vector2(h, -h), Vector2(h, h), Vector2(-h, h)]
	)
	arr[Mesh.ARRAY_TEX_UV] = PackedVector2Array(
		[Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
	)
	arr[Mesh.ARRAY_INDEX] = PackedInt32Array([0, 1, 2, 0, 2, 3])
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)
	return mesh
