class_name D5RigShadow
extends CanvasGroup
## d5-close hero and arena scenes (iteration 8): a hatched cast shadow for every rig up close, as
## King's sprite shadow and the concept's ground shadow. Up close the rig halos (and the
## look_d5_halo drop shadow) are gone, so the robots and cops floated over the floor. Each frame
## this mirrors every visible part sprite of the rigs under `source` (not the halos, not the D5
## overlays) onto the world layer, offset down-right by LENGTH_M; the group merges them and
## look_d5_shadow_group prints the merged silhouette as the pen hatch. Fades in 56 -> 64 px/m
## with the D5 part tier, "d5" tier only. Proposal for the characters lane; D5_RIG_SHADOW=0 off.

const SHADER: String = "res://assets/shaders/look_d5_shadow_group.gdshader"
const LENGTH_M: float = 0.45
const SKIP: Array[StringName] = [&"d5", &"halo_ink"]
const NAME: StringName = &"rig_shadow"

var source: Node = null
var px: float = 32.0
var _pool: Array[Sprite2D] = []
var _mat: ShaderMaterial = ShaderMaterial.new()


## One call per tier switch from a scene: makes the group on `world` once (named NAME), then
## sets it for the view.
static func on_tier(world: Node, rigs: Node, px_per_m: float, ppm: float, tier: String) -> void:
	var g: D5RigShadow = world.get_node_or_null(NodePath(NAME)) as D5RigShadow
	if g == null:
		g = make(rigs, px_per_m)
		g.name = NAME
		world.add_child(g)
	g.set_view(ppm, tier)


static func make(from: Node, px_per_m: float) -> D5RigShadow:
	var g: D5RigShadow = D5RigShadow.new()
	g.source = from
	g.px = px_per_m
	g._mat.shader = load(SHADER) as Shader
	g.material = g._mat
	g.visible = false
	return g


func set_view(ppm: float, tier: String) -> void:
	var on: bool = OS.get_environment("D5_RIG_SHADOW") != "0" and tier == "d5"
	var a: float = clampf((ppm - 56.0) / 8.0, 0.0, 1.0)
	visible = on and a > 0.0
	_mat.set_shader_parameter("amount", a)
	_mat.set_shader_parameter("zoom", ppm / 32.0)


func _process(_delta: float) -> void:
	if visible and source != null:
		_sync()


func _sync() -> void:
	var parts: Array[Sprite2D] = []
	var skip: Array[Sprite2D] = []
	_collect(source, parts, skip)
	while _pool.size() < parts.size():
		var s: Sprite2D = Sprite2D.new()
		add_child(s)
		_pool.append(s)
	var off: Vector2 = Vector2.ONE * LENGTH_M * px * 0.7071
	for i: int in _pool.size():
		var s: Sprite2D = _pool[i]
		s.visible = i < parts.size()
		if s.visible:
			var p: Sprite2D = parts[i]
			s.texture = p.texture
			s.centered = p.centered
			s.offset = p.offset
			s.flip_h = p.flip_h
			s.flip_v = p.flip_v
			s.region_enabled = p.region_enabled
			s.region_rect = p.region_rect
			var g: Transform2D = p.global_transform
			s.global_transform = Transform2D(g.x, g.y, g.origin + off)


func _collect(n: Node, out: Array[Sprite2D], skip: Array[Sprite2D]) -> void:
	for c: Node in n.get_children():
		var rig: CutRig = c as CutRig
		if rig != null:
			skip.append_array(rig.halos)
		var s: Sprite2D = c as Sprite2D
		if s != null and s.texture != null and s.is_visible_in_tree():
			if not skip.has(s) and not SKIP.has(s.name):
				out.append(s)
		_collect(c, out, skip)
