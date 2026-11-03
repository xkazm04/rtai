class_name NoirShadows
extends RefCounted
## D-Noir cast shadows (lane noir): every shadowed draw command of the resident chunks (props,
## parked cars, the roof blocks) also casts a LONG hard shadow - its own silhouette swept away
## from the light (look params `light_dir`) by a length per texture class (look params
## `shadows`), one quad per caster that look_noir_shadow.gdshader sweeps. Printed near-black
## into the world canvas, above the ground and under every prop and roof, so the noir pass
## prints them as ink masses (and the street lamps still lift them: the value sits just over
## lamp_gate). Render only: reads chunk data, never sim state.
## One chunk is recorded per update(), once; an evicted chunk's item is cleared and pooled.

## World px (at 32 px/m) between two taps of one sweep.
const STEP_PX: float = 2.0
## The shader's sweep packing range (texture uv per colour unit; look_noir_shadow.gdshader).
const D_SCALE: float = 16.0
const SHADER: String = "res://assets/shaders/look_noir_shadow.gdshader"

## Swept casters recorded so far (one quad each).
var stamps: int = 0
## The slowest chunk recording so far (CPU, microseconds; one chunk per update()).
var record_max_us: int = 0
var _parent: RID
var _root: RID
var _tex: CityTextures
var _len_px: PackedFloat32Array = PackedFloat32Array()
var _dir: Vector2 = Vector2(0.6, 0.8)
var _drawn: Dictionary[Vector2i, RID] = {}
var _pool: Array[RID] = []
var _mat: ShaderMaterial = ShaderMaterial.new()


## params = look_noir.params.json; table = the city texture table (class + name per id).
func _init(parent: RID, textures: CityTextures, table: Dictionary, params: Dictionary) -> void:
	_parent = parent
	_tex = textures
	var frame: Dictionary = params.get("frame", {})
	var light: Array = frame.get("light_dir", [-0.6, -0.8])
	var lx: float = light[0]
	var ly: float = light[1]
	_dir = -Vector2(lx, ly).normalized()
	var cfg: Dictionary = params.get("shadows", {})
	var value: float = cfg.get("value", 0.1)
	_mat.shader = load(SHADER) as Shader
	_mat.set_shader_parameter(&"value", value)
	_len_px = lengths(table, cfg)
	_root = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(_root, _parent)
	# above the ground items (z 0), before every overlay item (z 1: shadows, props, roofs)
	RenderingServer.canvas_item_set_z_index(_root, 1)
	RenderingServer.canvas_item_set_draw_index(_root, -1000)
	RenderingServer.canvas_item_set_material(_root, _mat.get_rid())


## The sweep length (world px at 32 px/m) per texture id: `by_name` first, else `len_m` by class.
static func lengths(table: Dictionary, cfg: Dictionary) -> PackedFloat32Array:
	var by_class: Dictionary = cfg.get("len_m", {})
	var by_name: Dictionary = cfg.get("by_name", {})
	var out: PackedFloat32Array = PackedFloat32Array()
	for row: Dictionary in table.get("textures", []):
		var m: float = by_name.get(row.get("name", ""), by_class.get(row.get("class", ""), 0.0))
		@warning_ignore("return_value_discarded")
		out.append(m * SimConst.PX_PER_M)
	return out


## Records the nearest resident chunk without shadows (at most one per call) and drops evicted ones.
func update(res: CityResidency) -> void:
	if res == null:
		return
	for key: Vector2i in _drawn.keys():
		if not res.is_resident(key):
			RenderingServer.canvas_item_clear(_drawn[key])
			_pool.append(_drawn[key])
			@warning_ignore("return_value_discarded")
			_drawn.erase(key)
	for key: Vector2i in res.resident_keys():
		if not _drawn.has(key):
			var t0: int = Time.get_ticks_usec()
			_drawn[key] = _record(res.chunk_at(key))
			record_max_us = maxi(record_max_us, Time.get_ticks_usec() - t0)
			return


func set_visible(on: bool) -> void:
	RenderingServer.canvas_item_set_visible(_root, on)


func chunk_count() -> int:
	return _drawn.size()


func _record(chunk: CityChunk) -> RID:
	var item: RID = (
		_pool.pop_back() if not _pool.is_empty() else RenderingServer.canvas_item_create()
	)
	RenderingServer.canvas_item_set_parent(item, _root)
	RenderingServer.canvas_item_set_use_parent_material(item, true)
	if chunk == null:
		return item
	for k: int in chunk.command_count():
		var o: int = k * CityChunk.XF_STRIDE
		var t: int = chunk.tex[k]
		if chunk.xf[o + 3] < 0.5 or t >= _len_px.size() or _len_px[t] <= 0.0:
			continue
		var pos: Vector2 = Vector2(chunk.xf[o], chunk.xf[o + 1]) * SimConst.PX_PER_M
		RenderingServer.canvas_item_add_set_transform(item, Transform2D(chunk.xf[o + 2], pos))
		_sweep(item, t, (_dir * _len_px[t]).rotated(-chunk.xf[o + 2]))
		stamps += 1
	return item


## One quad over the caster's texture and its sweep d (local px): the shader takes the max
## alpha along the sweep; the region runs past the texture so the quad's uv is texture uv.
func _sweep(item: RID, t: int, d: Vector2) -> void:
	var sz: Vector2 = _tex.size_px[t]
	var r: Rect2 = Rect2(-sz * 0.5, sz).merge(Rect2(-sz * 0.5 + d, sz))
	var tex_px: Vector2 = _tex.textures[t].get_size()
	var src: Rect2 = Rect2((r.position + sz * 0.5) / sz * tex_px, r.size / sz * tex_px)
	var d_uv: Vector2 = d / sz
	var taps: float = clampf(ceilf(d.length() / STEP_PX), 1.0, 255.0)
	var pack: Color = Color(0.5 + d_uv.x / D_SCALE, 0.5 + d_uv.y / D_SCALE, taps / 255.0)
	RenderingServer.canvas_item_add_texture_rect_region(
		item, r, _tex.rids[t], src, pack, false, false
	)


## Frees every canvas item this created (WLD-05: the creator frees).
func dispose() -> void:
	for item: RID in _drawn.values():
		RenderingServer.free_rid(item)
	for item: RID in _pool:
		RenderingServer.free_rid(item)
	RenderingServer.free_rid(_root)
	_drawn.clear()
	_pool.clear()
