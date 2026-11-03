class_name LightLayer
extends CanvasLayer
## The 2D light model (data/tables/lights.json, gtai.lights/1; core/render/README.md): the
## time-of-day grade (grade_ink.gdshader re-prints the screen darker; day = hidden) under a pool
## of additive light quads, one MultiMesh draw, banded by light_ink.gdshader so lights print as
## paper / accent ink. Lights live on the 60 Hz tick (add() takes the tick, step() fades them),
## never on a frame delta. Render only. Usage: add_child(LightLayer.new()), then add() /
## remove() and step(tick) per frame.

const TABLE: String = "res://data/tables/lights.json"
const SHADER: String = "res://assets/shaders/light_ink.gdshader"
const GRADE_SHADER: String = "res://assets/shaders/grade_ink.gdshader"
## Photosensitivity: at most 3 flashes a second (WCAG 2.3.1, Harding), whatever the table says.
const MAX_FLASH_HZ: float = 3.0
## A grade row's shader uniforms (lights.json `grades`).
const GRADE_KEYS: Array[StringName] = [&"paper_level", &"gamma", &"accent_keep"]

var kinds: Dictionary[StringName, Dictionary] = {}
var grades: Dictionary[StringName, Dictionary] = {}
var grade: StringName = &"day"
var max_lights: int = 64
var active: int = 0
var dropped: int = 0
var last_us: int = 0

var _mm: MultiMesh = MultiMesh.new()
var _node: MultiMeshInstance2D = MultiMeshInstance2D.new()
var _grade: ColorRect = ColorRect.new()
var _mat: ShaderMaterial = ShaderMaterial.new()
var _pool: LightPool = null
var _last_tick: int = -1
## A light was added, moved or removed since the last write.
var _dirty: bool = true


func _init() -> void:
	layer = RenderLayers.canvas(&"light")
	_load(FileAccess.get_file_as_string(TABLE))
	_pool = LightPool.new(max_lights)
	_grade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_grade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_grade.z_index = RenderLayers.z(&"grade")
	var gm: ShaderMaterial = ShaderMaterial.new()
	gm.shader = load(GRADE_SHADER)
	var pal: PaletteTokens = PaletteTokens.shared()
	gm.set_shader_parameter(&"verm_gate", pal.verm_gate)
	gm.set_shader_parameter(&"teal_gate", pal.teal_gate)
	_grade.material = gm
	_grade.visible = false
	add_child(_grade)
	_mm.transform_format = MultiMesh.TRANSFORM_2D
	_mm.use_colors = true
	_mm.use_custom_data = true
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(2, 2)
	_mm.mesh = quad
	_mm.instance_count = max_lights
	_mm.visible_instance_count = 0
	_node.multimesh = _mm
	_node.z_index = RenderLayers.z(&"lights")
	_mat.shader = load(SHADER)
	_node.material = _mat
	add_child(_node)


## The grade by id (`day`, `night`); unknown ids grade as day. An identity grade (paper_level 1,
## gamma 1: `day`) hides the rect, so the day print pays no screen read.
func set_grade(id: StringName) -> void:
	grade = id if grades.has(id) else &"day"
	var row: Dictionary = grades.get(grade, {})
	var mat: ShaderMaterial = _grade.material
	for key: StringName in GRADE_KEYS:
		mat.set_shader_parameter(key, row.get(String(key), 1.0 if key != &"accent_keep" else 0.0))
	_grade.visible = not is_identity(row)


## True when a grade row leaves the print untouched (the rect stays hidden).
static func is_identity(row: Dictionary) -> bool:
	var level: float = row.get("paper_level", 1.0)
	var g: float = row.get("gamma", 1.0)
	return is_equal_approx(level, 1.0) and is_equal_approx(g, 1.0)


## A light of `kind` at `pos_px` (world px), pointing along `angle`, born on sim tick `tick`.
## Returns a handle for remove(), or -1 when the kind is unknown or the budget is spent.
func add(kind: StringName, pos_px: Vector2, angle: float, tick: int) -> int:
	if not kinds.has(kind):
		return -1
	var life: float = kinds[kind]["life_ticks"]
	var h: int = _pool.take(int(life) > 0)
	if h < 0:
		dropped += 1
		return -1
	_pool.set_light(h, kind, Transform2D(angle, pos_px), tick, int(life))
	_dirty = true
	return h


func remove(handle: int) -> void:
	_pool.free_light(handle)
	_dirty = true


## Moves a held light (headlights follow their car).
func move(handle: int, pos_px: Vector2, angle: float) -> void:
	_pool.move(handle, Transform2D(angle, pos_px))
	_dirty = true


## Fades and expires lights at sim tick `tick`, follows the camera, writes the MultiMesh (only
## when the tick moved or a light changed: fades and flicker are functions of the tick).
func step(tick: int, world_px: Vector2) -> void:
	var t0: int = Time.get_ticks_usec()
	_node.transform = get_viewport().get_canvas_transform() if is_inside_tree() else Transform2D()
	_mat.set_shader_parameter(&"world_px", world_px)
	if tick != _last_tick or _dirty:
		active = _pool.write(_mm, kinds, tick)
		_last_tick = tick
		_dirty = false
	last_us = Time.get_ticks_usec() - t0


func _load(text: String) -> void:
	var parser: JSON = JSON.new()
	if parser.parse(text) != OK or not parser.data is Dictionary:
		return
	var d: Dictionary = parser.data
	var cap: float = d.get("max_lights", 64)
	max_lights = int(cap)
	var pal: PaletteTokens = PaletteTokens.shared()
	var flash_cap: float = d.get("max_flash_hz", MAX_FLASH_HZ)
	flash_cap = minf(flash_cap, MAX_FLASH_HZ)
	for row: Dictionary in d.get("kinds", []):
		var k: Dictionary = row.duplicate()
		var hz: float = row["flicker_hz"]
		if hz > flash_cap:
			Log.warn("lights", "%s flickers %.1f Hz > %.1f: clamped" % [row["id"], hz, flash_cap])
			k["flicker_hz"] = flash_cap
		var token: String = row["token"]
		var alt: String = row.get("alt_token", token)
		k["color"] = pal.color(StringName(token))
		k["alt_color"] = pal.color(StringName(alt))
		var kid: String = row["id"]
		kinds[StringName(kid)] = k
	for row: Dictionary in d.get("grades", []):
		var gid: String = row["id"]
		grades[StringName(gid)] = row
