class_name CrowdLayers
extends RefCounted
## The five MultiMesh layers the bubble sim writes into (WLD-04): people, people shadows, cars,
## car shadows, bullets, drawn car shadows -> people shadows -> cars -> people -> bullets. One
## quad mesh, 2D transforms, per-instance colour and custom data. Placeholder art in the D4 inks
## (a paper disc with an ink rim for people, a steel body for cars, soft ink blobs for shadows)
## until the character atlas and vehicle art land (F-09).

const DRAW_ORDER: Array[int] = [3, 1, 2, 0, 4]
## Each sim render layer's band in the render stack (data/tables/render_layers.json): shadows
## under people, people under vehicles, projectiles in the fx band.
const BAND: Array[StringName] = [&"actors", &"actor_shadows", &"vehicles", &"actor_shadows", &"fx"]
const INK: Color = Color(0.09, 0.075, 0.106)
const PAPER: Color = Color(0.949, 0.91, 0.835)
const STEEL: Color = Color(0.561, 0.533, 0.506)

var multimeshes: Array[MultiMesh] = []
var nodes: Array[MultiMeshInstance2D] = []


func _init() -> void:
	var quad: ArrayMesh = _quad()
	var blob: Texture2D = _blob()
	var body: Texture2D = _body()
	var figure: Texture2D = _figure()
	for k: int in SimConst.RL_COUNT:
		var mm: MultiMesh = MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_2D
		mm.use_colors = true
		mm.use_custom_data = true
		mm.mesh = quad
		mm.instance_count = SimConst.PCAP if k == SimConst.RL_BULLETS else SimConst.CAP
		mm.visible_instance_count = 0
		mm.custom_aabb = AABB(Vector3(-1e7, -1e7, -10), Vector3(2e7, 2e7, 20))
		var node: MultiMeshInstance2D = MultiMeshInstance2D.new()
		node.multimesh = mm
		node.texture = body if k == SimConst.RL_CARS or k == SimConst.RL_CAR_SHADOWS else blob
		if k == SimConst.RL_PEDS:
			node.texture = figure
		node.z_index = RenderLayers.z(BAND[k])
		multimeshes.append(mm)
		nodes.append(node)


func rids() -> Array[RID]:
	var out: Array[RID] = []
	for mm: MultiMesh in multimeshes:
		out.append(mm.get_rid())
	return out


## Placeholder clip table: every variant and clip is one frame at cell 0.
static func placeholder_clips() -> PackedInt32Array:
	var clips: Array[int] = []
	for v: int in SimConst.CLIP_VARIANTS * SimConst.CLIPS:
		clips.append_array([0, 1, 1])
	return PackedInt32Array(clips)


func attach(parent: Node) -> void:
	for k: int in DRAW_ORDER:
		parent.add_child(nodes[k])


static func _quad() -> ArrayMesh:
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


static func _blob() -> Texture2D:
	var tex: GradientTexture2D = GradientTexture2D.new()
	tex.width = 32
	tex.height = 32
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	var g: Gradient = Gradient.new()
	g.set_color(0, Color(1, 1, 1, 1))
	g.set_color(1, Color(1, 1, 1, 0))
	tex.gradient = g
	return tex


## A car body inset in its quad (the quad is the spike's 6.4 x 3.2 m atlas cell; a car ~4.9 x 2.15).
static func _body() -> Texture2D:
	var img: Image = Image.create_empty(64, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	img.fill_rect(Rect2i(7, 5, 50, 22), INK)
	img.fill_rect(Rect2i(9, 7, 46, 18), STEEL)
	return ImageTexture.create_from_image(img)


## A person: a small paper disc with an ink rim, centred in the 3.84 m atlas cell (~0.7 m wide).
static func _figure() -> Texture2D:
	var img: Image = Image.create_empty(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y: int in 64:
		for x: int in 64:
			var d: float = Vector2(x + 0.5 - 32.0, y + 0.5 - 32.0).length()
			if d < 4.5:
				img.set_pixel(x, y, PAPER)
			elif d < 6.0:
				img.set_pixel(x, y, INK)
	return ImageTexture.create_from_image(img)
