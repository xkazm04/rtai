class_name NoirLook
extends CanvasLayer
## D-Noir print pass (lane noir): look_noir.gdshader on a full-rect ColorRect on the top canvas
## layer, over the D4-printed world AND the actors. Its uniforms are data
## (look_noir.params.json `frame`). Render only; switch it on with --look=noir.

const SHADER: String = "res://assets/shaders/look_noir.gdshader"
const PARAMS: String = "res://assets/shaders/look_noir.params.json"
const LAYER: int = 10
const LOOK_ID: String = "noir"

## true: the D4 world print stays under the noir pass (params `keep_d4`).
var keep_d4: bool = true
var params: Dictionary = {}
## >= 0 pins the rain (deterministic A/B frames); < 0 follows the caller's phase.
var fixed_phase: float = -1.0
## The street light (lamp posts as pools of light); null until the first light_street().
var street: NoirLamps = null
var _lamp_r_px: float = 0.0
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


## Per frame, with the city: the lamp posts around focus (m) light their pools (none when the
## params have no lamp_r, or without a city).
func light_street(res: CityResidency, focus: Vector2, world_px: Vector2, zoom: float) -> void:
	if res == null or _lamp_r_px <= 0.0 or not is_inside_tree():
		return
	if street == null:
		street = NoirLamps.new(CityGen.read_json(CitySystem.TEXTURES))
	var half: Vector2 = get_viewport().get_visible_rect().size * 0.5 / (zoom * SimConst.PX_PER_M)
	var lamps: PackedVector2Array = street.near(res, focus, half, _lamp_r_px / SimConst.PX_PER_M)
	var px: PackedVector2Array = NoirLamps.to_screen(lamps, world_px, zoom)
	_mat.set_shader_parameter(&"lamp_count", px.size())
	@warning_ignore("return_value_discarded")
	px.resize(NoirLamps.MAX_LAMPS)
	_mat.set_shader_parameter(&"lamps", px)
