class_name LightLayer
extends CanvasLayer
## The 2D light model (data/tables/lights.json, gtai.lights/1; core/render/README.md): the
## time-of-day grade (a full-screen multiply, day = white) under a pool of additive light quads,
## one MultiMesh draw, banded by light_ink.gdshader so lights print as paper / accent ink. Lights
## live on the 60 Hz tick (add() takes the tick, step() fades them), never on a frame delta.
## Render only. Usage: add_child(LightLayer.new()), then add()/remove() and step(tick) per frame.

const TABLE: String = "res://data/tables/lights.json"
const SHADER: String = "res://assets/shaders/light_ink.gdshader"

var kinds: Dictionary[StringName, Dictionary] = {}
var grades: Dictionary[StringName, Color] = {}
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
	_grade.color = Color.WHITE
	_grade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_grade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_grade.z_index = RenderLayers.z(&"grade")
	var mul: CanvasItemMaterial = CanvasItemMaterial.new()
	mul.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
	_grade.material = mul
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


## The grade by id (`day`, `night`); unknown ids grade as day.
func set_grade(id: StringName) -> void:
	_grade.color = grades.get(id, Color.WHITE)


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
	for row: Dictionary in d.get("kinds", []):
		var k: Dictionary = row.duplicate()
		var token: String = row["token"]
		var alt: String = row.get("alt_token", token)
		k["color"] = pal.color(StringName(token))
		k["alt_color"] = pal.color(StringName(alt))
		var kid: String = row["id"]
		kinds[StringName(kid)] = k
	for row: Dictionary in d.get("grades", []):
		var gid: String = row["id"]
		var hex: String = row["multiply"]
		grades[StringName(gid)] = Color.html(hex)
