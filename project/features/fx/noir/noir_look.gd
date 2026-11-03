class_name NoirLook
extends CanvasLayer
## D-Noir print pass (lane noir): look_noir.gdshader on a full-rect ColorRect on the top canvas
## layer, over the D4-printed world AND the actors. Its uniforms are data
## (look_noir.params.json `frame`). Render only; switch it on with --look=noir.

const SHADER: String = "res://assets/shaders/look_noir.gdshader"
const PARAMS: String = "res://assets/shaders/look_noir.params.json"
const LAYER: int = 10
const LOOK_ID: String = "noir"
const CROWD_SHADOW: Shader = preload("res://assets/shaders/look_noir_crowd_shadow.gdshader")

## true: the D4 world print stays under the noir pass (params `keep_d4`).
var keep_d4: bool = true
var params: Dictionary = {}
## >= 0 pins the rain (deterministic A/B frames); < 0 follows the caller's phase.
var fixed_phase: float = -1.0
## The street light (lamp posts as pools of light); null until the first light_street().
var street: NoirLamps = null
## Microseconds the last light_street() took (CPU: the lamp lookup + the snapshot read).
var light_us: int = 0
## Scripted cars (dev hosts): noses in world metres (x, y) with headings (z, w), lit before the
## sim's cars.
var extra_cars: PackedVector4Array = PackedVector4Array()
## Long cast shadows in the world canvas (params `shadows`); null until the first light_street().
var shadows: NoirShadows = null
## The people's shadows (params `shadows.figures`), cast by the city's CharacterRigs; null until
## a CharacterRigs is on the actor layer (or when a host attached its own).
var figures: NoirFigureShadows = null
var _lamp_r_px: float = 0.0
var _beam_len_px: float = 0.0
var _rect: ColorRect = ColorRect.new()
var _mat: ShaderMaterial = ShaderMaterial.new()


func _init() -> void:
	layer = LAYER
	_mat.shader = load(SHADER) as Shader
	_rect.material = _mat
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_rect)
	params = read_params(PARAMS)
	var keep: Variant = params.get("keep_d4", true)
	keep_d4 = keep is bool and keep
	var frame: Variant = params.get("frame", {})
	if frame is Dictionary:
		var u: Dictionary = frame
		apply(u)
		_lamp_r_px = u.get("lamp_r", 0.0)
		_beam_len_px = u.get("beam_len", 0.0)


## True when the launch args ask for the noir look (--look=noir).
static func requested() -> bool:
	return LaunchArgs.value("--look") == LOOK_ID


## The params table, or {} when it is missing or not a JSON object.
static func read_params(path: String) -> Dictionary:
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK or not parser.data is Dictionary:
		return {}
	var d: Dictionary = parser.data
	return d


## Sets every uniform in `u` (2-number arrays become Vector2).
func apply(u: Dictionary) -> void:
	for k: String in u:
		var v: Variant = u[k]
		if v is Array:
			var a: Array = v
			if a.size() == 2:
				var x: float = a[0]
				var y: float = a[1]
				v = Vector2(x, y)
		_mat.set_shader_parameter(StringName(k), v)


## Per frame: the camera's world offset in screen px and the rain phase (sim ticks).
func update(world_px: Vector2, rain_phase: float) -> void:
	_mat.set_shader_parameter(&"world_px", world_px)
	var cam: Camera2D = get_viewport().get_camera_2d() if is_inside_tree() else null
	_mat.set_shader_parameter(&"zoom", cam.zoom.x if cam != null else 1.0)
	_mat.set_shader_parameter(&"rain_phase", fixed_phase if fixed_phase >= 0.0 else rain_phase)


func set_amount(a: float) -> void:
	_mat.set_shader_parameter(&"amount", a)
	_rect.visible = a > 0.001


## Per frame, with the city: the lamp posts around focus (m) light their pools and the cars
## throw their headlight cones (each off when the params have no lamp_r / beam_len).
## Positions go in as screen uv (the canvas view can be larger than the window: canvas_items
## stretch), sizes as px at 32 px/m that the shader scales by zoom and view_h.
func light_street(city: CitySystem, focus: Vector2, zoom: float) -> void:
	if city == null or not visible or not is_inside_tree():
		return
	var t0: int = Time.get_ticks_usec()
	var view: Vector2 = get_viewport().get_visible_rect().size
	var half: Vector2 = view * 0.5 / (zoom * SimConst.PX_PER_M)
	_mat.set_shader_parameter(&"view_h", view.y)
	if _lamp_r_px > 0.0 and city.residency != null:
		if street == null:
			street = NoirLamps.new(CityGen.read_json(CitySystem.TEXTURES))
		var reach: float = _lamp_r_px / SimConst.PX_PER_M
		var lamps: PackedVector2Array = street.near(city.residency, focus, half, reach)
		var px: PackedVector2Array = NoirLamps.to_uv(lamps, focus, zoom, view)
		_mat.set_shader_parameter(&"lamp_count", px.size())
		@warning_ignore("return_value_discarded")
		px.resize(NoirLamps.MAX_LAMPS)
		_mat.set_shader_parameter(&"lamps", px)
	if _beam_len_px > 0.0 and city.sim != null:
		var reach_m: float = _beam_len_px / SimConst.PX_PER_M
		var cars: PackedVector4Array = extra_cars.duplicate()
		cars.append_array(NoirHeadlights.near(city.sim.snapshot(), focus, half, reach_m))
		var beams: PackedVector4Array = NoirHeadlights.to_uv(cars, focus, zoom, view)
		_mat.set_shader_parameter(&"car_count", mini(beams.size(), NoirHeadlights.MAX_CARS))
		@warning_ignore("return_value_discarded")
		beams.resize(NoirHeadlights.MAX_CARS)
		_mat.set_shader_parameter(&"cars", beams)
	_cast_shadows(city)
	light_us = Time.get_ticks_usec() - t0


func _cast_shadows(city: CitySystem) -> void:
	var view: CityView = get_parent() as CityView
	if view == null or view.textures == null or not params.has("shadows"):
		return
	if shadows == null:
		var table: Dictionary = CityGen.read_json(CitySystem.TEXTURES)
		shadows = NoirShadows.new(view.get_canvas_item(), view.textures, table, params)
		@warning_ignore("return_value_discarded")
		visibility_changed.connect(func() -> void: shadows.set_visible(visible))
	shadows.update(city.residency)
	if figures == null:
		_cast_figures(view)
	_ink_crowd_shadows(view)


## The figure shadows on the city's actor layer, cast by its CharacterRigs (the game's rigs);
## skipped when a host already put its own NoirFigureShadows there.
func _cast_figures(view: CityView) -> void:
	var layer: CanvasLayer = view.actor_layer()
	if layer == null:
		return
	var rigs: CharacterRigs = null
	for child: Node in layer.get_children():
		if child is NoirFigureShadows:
			figures = child as NoirFigureShadows
			return
		if child is CharacterRigs and rigs == null:
			rigs = child as CharacterRigs
	if rigs == null:
		return
	figures = NoirFigureShadows.attach(layer, params, rigs)
	@warning_ignore("return_value_discarded")
	visibility_changed.connect(func() -> void: figures.visible = visible)


## The crowd's soft shadow blobs print as hard ink stretched away from the light (one material).
func _ink_crowd_shadows(view: CityView) -> void:
	var node: MultiMeshInstance2D = view.crowd.nodes[SimConst.RL_PED_SHADOWS]
	if node.has_meta(&"noir_ink"):
		return
	node.set_meta(&"noir_ink", true)
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = CROWD_SHADOW
	var frame: Dictionary = params["frame"]
	var d: Array = frame.get("light_dir", [-0.6, -0.8])
	var lx: float = d[0]
	var ly: float = d[1]
	var away: Vector2 = -Vector2(lx, ly).normalized()
	mat.set_shader_parameter("away", away)
	var d4: Material = node.material  # the D4 item print; back when the noir look is off
	node.material = mat if visible else d4
	@warning_ignore("return_value_discarded")
	visibility_changed.connect(func() -> void: node.material = mat if visible else d4)


func _exit_tree() -> void:
	if shadows != null:
		shadows.dispose()
		shadows = null
