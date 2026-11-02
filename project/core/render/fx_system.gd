class_name FxSystem
extends Node2D
## Data-driven FX (data/tables/fx.json, gtai.fx/1; core/render/README.md): muzzle, tracer,
## impact, explosion, smoke, debris, ink splat and the melee crackle as pooled particles in one
## MultiMesh on the `fx` band of the actors canvas (world px). spawn() is budgeted per frame and
## per pool; particles advance on the 60 Hz sim tick (step(tick)), never on a frame delta, and
## spread by a hash of the spawn serial (no RNG stream: render only, replay untouched).
## With the d4-production FX sheet present (fx.json `atlas`), kinds draw atlas cells ("pick" a
## cell by seed or "anim" through them); without it the analytic placeholder shapes draw.

const TABLE: String = "res://data/tables/fx.json"
const SHADER: String = "res://assets/shaders/fx_ink.gdshader"
const SHAPES: Dictionary[String, float] = {
	"disc": 0.0, "streak": 1.0, "burst": 2.0, "splat": 3.0, "bolt": 4.0
}
const MAX_STEPS: int = 4

var kinds: Dictionary[StringName, Dictionary] = {}
var max_spawns_per_frame: int = 24
## The light layer an fx kind's `light` goes to (null = no lights).
var lights: LightLayer = null
var dropped: int = 0
var spawned_this_frame: int = 0
var last_us: int = 0
## True when the FX sheet loaded: kinds use their `atlas` blocks.
var atlas_live: bool = false

var _pool: FxPool = null
var _mm: MultiMesh = MultiMesh.new()
var _node: MultiMeshInstance2D = MultiMeshInstance2D.new()
var _serial: int = 0
var _last_tick: int = -1
var _atlas_path: String = ""
var _atlas_grid: Vector2 = Vector2.ONE


func _init() -> void:
	z_index = RenderLayers.z(&"fx")
	var cap: int = _load(FileAccess.get_file_as_string(TABLE))
	_pool = FxPool.new(cap)
	_mm.transform_format = MultiMesh.TRANSFORM_2D
	_mm.use_colors = true
	_mm.use_custom_data = true
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(2, 2)
	_mm.mesh = quad
	_mm.instance_count = cap
	_mm.visible_instance_count = 0
	_node.multimesh = _mm
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = load(SHADER)
	if atlas_live:
		mat.set_shader_parameter(&"atlas", load(_atlas_path))
		mat.set_shader_parameter(&"grid", _atlas_grid)
	_node.material = mat
	add_child(_node)


func alive() -> int:
	return _pool.alive


## Emits one `kind` at `pos_px` (world px) along `angle` on sim tick `tick`. False when the kind
## is unknown or the frame / pool budget is spent (counted in `dropped`).
func spawn(kind: StringName, pos_px: Vector2, angle: float, tick: int) -> bool:
	if not kinds.has(kind):
		return false
	var k: Dictionary = kinds[kind]
	var count: int = k["count"]
	if spawned_this_frame >= max_spawns_per_frame or _pool.alive + count > _pool.capacity():
		dropped += 1
		return false
	spawned_this_frame += 1
	var spread_deg: float = k["spread_deg"]
	var spread: float = deg_to_rad(spread_deg)
	var speed: float = k["speed_mps"]
	for i: int in count:
		_serial += 1
		var h: float = _hash01(_serial)
		var a: float = angle + (h - 0.5) * spread
		var v: Vector2 = (
			Vector2.from_angle(a) * speed * FxPool.PX_PER_M * (0.6 + 0.4 * _hash01(~_serial))
		)
		_pool.put(k, Transform2D(a, pos_px), v, tick, h)
	var light: String = k["light"]
	if lights != null and light != "":
		@warning_ignore("return_value_discarded")
		lights.add(StringName(light), pos_px, angle, tick)
	return true


## Advances the particles to sim tick `tick` and draws them; call once a frame.
func step(tick: int) -> void:
	var t0: int = Time.get_ticks_usec()
	var steps: int = clampi(tick - _last_tick, 0, MAX_STEPS) if _last_tick >= 0 else 0
	_last_tick = tick
	_pool.step(steps, tick, _mm)
	spawned_this_frame = 0
	last_us = Time.get_ticks_usec() - t0


static func _hash01(n: int) -> float:
	var x: int = (n * 0x45D9F3B) & 0x7FFFFFFF
	x = ((x ^ (x >> 16)) * 0x45D9F3B) & 0x7FFFFFFF
	return float(x ^ (x >> 16)) / float(0x7FFFFFFF)


func _load(text: String) -> int:
	var parser: JSON = JSON.new()
	if parser.parse(text) != OK or not parser.data is Dictionary:
		return 1
	var d: Dictionary = parser.data
	var spf: float = d["max_spawns_per_frame"]
	max_spawns_per_frame = int(spf)
	var atlas: Dictionary = d.get("atlas", {})
	_load_atlas(atlas)
	var pal: PaletteTokens = PaletteTokens.shared()
	for row: Dictionary in d["kinds"]:
		var k: Dictionary = row.duplicate()
		if atlas_live and row.has("atlas"):
			var a: Dictionary = row["atlas"]
			k.merge(a, true)
			var cells: Array = a["cells"]
			var first: float = cells[0]
			var n: float = cells[1]
			k["cell0"] = first
			k["cell_n"] = n
			k["anim"] = a["mode"] == "anim"
		var token: String = row["token"]
		var shape: String = row["shape"]
		k["color"] = pal.color(StringName(token))
		k["shape_id"] = SHAPES.get(shape, 0.0)
		var kid: String = row["id"]
		kinds[StringName(kid)] = k
	var cap: float = d["max_particles"]
	return int(cap)


func _load_atlas(a: Dictionary) -> void:
	if a.is_empty():
		return
	var path: String = a["path"]
	if not ResourceLoader.exists(path):
		return
	var cols: float = a["cols"]
	var rows: float = a["rows"]
	_atlas_path = path
	_atlas_grid = Vector2(cols, rows)
	atlas_live = true
