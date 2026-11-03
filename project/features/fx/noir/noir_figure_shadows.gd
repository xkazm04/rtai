class_name NoirFigureShadows
extends Node2D
## D-Noir figure shadows (lane noir): the actors that cast() (the rigs) are rendered a second
## time, alone, into a SubViewport that shares their canvas layer (a cull-mask bit picks them
## out); look_noir_figure.gdshader sweeps that silhouette away from the light (look params
## `frame.light_dir`, the same light as NoirShadows) and prints it flat at `value` on the ground,
## under the blood and the rigs. Lives in the actor layer; render only, never sim state.

## The cull-mask bit only the casters carry (CanvasItem.visibility_layer).
const CAST_BIT: int = 1 << 19
const SHADER: String = "res://assets/shaders/look_noir_figure.gdshader"
## Screen px between two taps of the sweep.
const STEP_PX: float = 4.0
## Bodies the shader tapers (look_noir_figure.gdshader MAX_BODIES).
const MAX_BODIES: int = 16

## World px (at 32 px/m) of the sweep; 0 = off.
var len_px: float = 0.0
## World px (at 32 px/m) around a body's centre that is its own silhouette (params reach_m).
var reach_px: float = 32.0
## The silhouette viewport's size per screen px (params res_scale; 0.5 = a quarter of the fill).
var res_scale: float = 1.0
var _dir: Vector2 = Vector2(0.6, 0.8)
var _layer: CanvasLayer = null
var _sub: SubViewport = SubViewport.new()
var _mat: ShaderMaterial = ShaderMaterial.new()
var _casters: Array[Node] = []
## The bodies (CutRigs) among the casters: their centres scale the silhouette (the taper).
var _bodies: Array[CutRig] = []
## Screen px per drawn body: one quad over its reach and its sweep (the shader runs only there).
var _quads: Array[Rect2] = []


## params = look_noir.params.json (frame.light_dir, shadows.figures {len_m, value}).
func _init(params: Dictionary) -> void:
	var frame: Dictionary = params.get("frame", {})
	var light: Array = frame.get("light_dir", [-0.6, -0.8])
	var lx: float = light[0]
	var ly: float = light[1]
	_dir = -Vector2(lx, ly).normalized()
	var all: Dictionary = params.get("shadows", {})
	var cfg: Dictionary = all.get("figures", {})
	var len_m: float = cfg.get("len_m", 0.0)
	var value: float = cfg.get("value", 0.1)
	len_px = len_m * SimConst.PX_PER_M
	var reach_m: float = cfg.get("reach_m", 1.0)
	reach_px = reach_m * SimConst.PX_PER_M
	var res: float = cfg.get("res_scale", 1.0)
	res_scale = clampf(res, 0.25, 1.0)
	_mat.shader = load(SHADER) as Shader
	_mat.set_shader_parameter(&"value", value)
	material = _mat
	z_index = -2
	_sub.transparent_bg = true
	_sub.canvas_cull_mask = CAST_BIT
	_sub.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_sub.world_2d = World2D.new()
	add_child(_sub)


## A figure-shadow node in `layer` with `caster` (and its future children) casting.
static func attach(layer: CanvasLayer, params: Dictionary, caster: Node) -> NoirFigureShadows:
	var fs: NoirFigureShadows = NoirFigureShadows.new(params)
	layer.add_child(fs)
	fs.cast(caster)
	return fs


## The silhouette viewport (dev cost meters read its render time).
func sub_rid() -> RID:
	return _sub.get_viewport_rid()


## Marks `node` and everything under it (now and later) as a shadow caster.
func cast(node: Node) -> void:
	_casters.append(node)
	_mark(node)


func _ready() -> void:
	_layer = get_parent() as CanvasLayer
	if _layer != null:
		RenderingServer.viewport_attach_canvas(_sub.get_viewport_rid(), _layer.get_canvas())
	@warning_ignore("return_value_discarded")
	get_tree().node_added.connect(_on_node_added)


func _process(_delta: float) -> void:
	if _layer == null or len_px <= 0.0 or not is_visible_in_tree():
		return
	var view: Vector2 = get_viewport().get_visible_rect().size
	var sub_size: Vector2i = Vector2i((view * res_scale).ceil())
	if _sub.size != sub_size:
		_sub.size = sub_size
	var xf: Transform2D = _layer.get_final_transform()
	RenderingServer.viewport_set_canvas_transform(
		_sub.get_viewport_rid(),
		_layer.get_canvas(),
		Transform2D().scaled(Vector2.ONE * res_scale) * xf
	)
	# this node draws in screen px: undo the layer's (camera) transform
	transform = xf.affine_inverse()
	var d_px: Vector2 = _dir * len_px * xf.get_scale().x
	_mat.set_shader_parameter(&"sweep", d_px / view)
	_mat.set_shader_parameter(&"taps", clampi(ceili(d_px.length() / STEP_PX), 1, 128))
	_mat.set_shader_parameter(&"view", view)
	var reach: float = reach_px * xf.get_scale().x
	_mat.set_shader_parameter(&"reach_px", reach)
	_set_bodies(xf, view)
	_set_quads(view, d_px, reach)
	queue_redraw()


## The visible bodies' centres as screen uv (at most MAX_BODIES).
func _set_bodies(xf: Transform2D, view: Vector2) -> void:
	var uv: PackedVector2Array = PackedVector2Array()
	for rig: CutRig in _bodies:
		if not is_instance_valid(rig):
			continue
		# the dead lie flat: no standing figure's shadow (the bit off hides the whole body)
		var stands: bool = not rig.dead
		rig.visibility_layer = (
			rig.visibility_layer | CAST_BIT if stands else rig.visibility_layer & ~CAST_BIT
		)
		if stands and rig.is_visible_in_tree() and uv.size() < MAX_BODIES:
			@warning_ignore("return_value_discarded")
			uv.append(xf * rig.global_position / view)
	_mat.set_shader_parameter(&"body_count", uv.size())
	@warning_ignore("return_value_discarded")
	uv.resize(MAX_BODIES)
	_mat.set_shader_parameter(&"bodies", uv)


## One screen-px quad per body: its own reach around the centre, merged with the swept one.
func _set_quads(view: Vector2, d_px: Vector2, reach: float) -> void:
	_quads.clear()
	var bodies: PackedVector2Array = _mat.get_shader_parameter(&"bodies")
	var n: int = _mat.get_shader_parameter(&"body_count")
	var half: Vector2 = Vector2.ONE * reach
	for k: int in n:
		var c: Vector2 = bodies[k] * view
		var r: Rect2 = Rect2(c - half, half * 2.0).merge(Rect2(c + d_px - half, half * 2.0))
		_quads.append(r.intersection(Rect2(Vector2.ZERO, view)))


func _draw() -> void:
	var tex: Texture2D = _sub.get_texture()
	for k: int in _quads.size():
		var r: Rect2 = _quads[k]
		var src: Rect2 = Rect2(r.position * res_scale, r.size * res_scale)
		# the body index rides in the modulate colour (look_noir_figure.gdshader reads it)
		draw_texture_rect_region(tex, r, src, Color(k / 255.0, 0.0, 0.0))


func _on_node_added(node: Node) -> void:
	for c: Node in _casters:
		if is_instance_valid(c) and c.is_ancestor_of(node):
			_mark_one(node)
			return


func _mark(node: Node) -> void:
	_mark_one(node)
	for child: Node in node.get_children():
		_mark(child)


func _mark_one(node: Node) -> void:
	var item: CanvasItem = node as CanvasItem
	if item != null:
		item.visibility_layer |= CAST_BIT
	if node is CutRig:
		_bodies.append(node as CutRig)


func _exit_tree() -> void:
	if _layer != null:
		RenderingServer.viewport_remove_canvas(_sub.get_viewport_rid(), _layer.get_canvas())
