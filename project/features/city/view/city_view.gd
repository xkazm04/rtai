class_name CityView
extends Node2D
## Draws the city: a camera on the CitySystem's focus, the resident chunks (ChunkView, time
## sliced) and the actors (one write_render() per frame into CrowdLayers). Reads no frame delta
## (SIM-01): everything it shows is sim state. Render only; never needed headless or in replay.
## Layers, bottom up: the world (this node's canvas: ground, decals, shadows, props, roofs) on
## canvas layer 0; the D4 print pass (look_d4, reads the world through the screen texture) on
## LOOK_LAYER; the actors (look_d4_item) on ACTOR_LAYER, following the camera.

const VIEW_MARGIN_M: float = 4.0
const LOOK_LAYER: int = 1
const ACTOR_LAYER: int = 2
const LOOK_SHADER: String = "res://assets/shaders/look_d4.gdshader"
const ITEM_SHADER: String = "res://assets/shaders/look_d4_item.gdshader"

## Pixels per metre on screen / 32: 1.0 on foot, 1.5 in a car (48 px/m).
var zoom: float = 1.5
## The D4 print pass (the default look); false draws the raw art (A/B, crop tests).
var look_enabled: bool = true:
	set = set_look_enabled
var camera: Camera2D = Camera2D.new()
var chunks: ChunkView = null
var crowd: CrowdLayers = CrowdLayers.new()
var textures: CityTextures = null
var visible_actors: int = 0
var warming: bool = false
var _city: CitySystem = null
var _look_rect: ColorRect = ColorRect.new()
var _look_mat: ShaderMaterial = ShaderMaterial.new()
var _item_mat: ShaderMaterial = ShaderMaterial.new()


func setup(city: CitySystem) -> void:
	_city = city
	add_child(camera)
	if is_inside_tree():
		camera.make_current()
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_build_layers()
	textures = CityTextures.new(CityGen.read_json(CitySystem.TEXTURES))
	chunks = ChunkView.new(get_canvas_item(), textures)
	city.sim.set_render(crowd.rids(), CrowdLayers.placeholder_clips())
	set_look_enabled(look_enabled)


func set_look_enabled(on: bool) -> void:
	look_enabled = on
	_look_rect.visible = on
	for node: MultiMeshInstance2D in crowd.nodes:
		node.material = _item_mat if on else null


## The loading-screen prewarm (WLD-07): every texture, every actor layer and both shaders drawn
## for a couple of frames before gameplay. Await it; returns the microseconds it took.
func prewarm() -> int:
	warming = true
	if _city != null:
		_place_camera(_city.focus)
	var us: int = await ViewPrewarm.new(self).run()
	warming = false
	return us


func _process(_delta: float) -> void:
	if _city == null or warming:
		return
	var focus: Vector2 = _city.focus
	_place_camera(focus)
	chunks.update(focus, _city.residency)
	var half: Vector2 = get_viewport_rect().size * 0.5 / (zoom * SimConst.PX_PER_M)
	half += Vector2.ONE * VIEW_MARGIN_M
	_city.sim.write_render(focus.x - half.x, focus.y - half.y, focus.x + half.x, focus.y + half.y)
	var counts: PackedInt32Array = _city.sim.get_render_counts()
	visible_actors = counts[SimConst.RL_PEDS] + counts[SimConst.RL_CARS] if counts.size() > 2 else 0


## Camera on the focus; world_px locks the print pass's grime and hatch to the world.
func _place_camera(focus: Vector2) -> void:
	camera.zoom = Vector2.ONE * zoom
	camera.position = focus * SimConst.PX_PER_M
	var world_px: Vector2 = (camera.position * zoom).round() - get_viewport_rect().size * 0.5
	_look_mat.set_shader_parameter(&"world_px", world_px)


func _build_layers() -> void:
	var look: CanvasLayer = CanvasLayer.new()
	look.layer = LOOK_LAYER
	var look_shader: Shader = load(LOOK_SHADER)
	_look_mat.shader = look_shader
	_look_rect.material = _look_mat
	_look_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_look_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	look.add_child(_look_rect)
	add_child(look)
	var actors: CanvasLayer = CanvasLayer.new()
	actors.layer = ACTOR_LAYER
	actors.follow_viewport_enabled = true
	var item_shader: Shader = load(ITEM_SHADER)
	_item_mat.shader = item_shader
	add_child(actors)
	crowd.attach(actors)


func _exit_tree() -> void:
	if chunks != null:
		chunks.dispose()
